package server

import (
	"context"
	"encoding/base64"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/chushi-io/chushi/internal/controller"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/chushi-io/chushi/internal/service/run_manager"
	"github.com/go-oauth2/oauth2/v4/errors"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/go-oauth2/oauth2/v4/manage"
	"github.com/go-oauth2/oauth2/v4/server"
	"github.com/golang-jwt/jwt"
	abrenderer "github.com/volatiletech/authboss-renderer"
	"github.com/volatiletech/authboss/v3/otp/twofactor"
	"github.com/volatiletech/authboss/v3/otp/twofactor/sms2fa"
	"github.com/volatiletech/authboss/v3/otp/twofactor/totp2fa"
	"regexp"

	// Authentication modules
	abclientstate "github.com/volatiletech/authboss-clientstate"
	"github.com/volatiletech/authboss/v3"
	_ "github.com/volatiletech/authboss/v3/auth"
	//_ "github.com/volatiletech/authboss/v3/confirm"
	"github.com/volatiletech/authboss/v3/defaults"
	_ "github.com/volatiletech/authboss/v3/logout"
	_ "github.com/volatiletech/authboss/v3/otp/twofactor"
	_ "github.com/volatiletech/authboss/v3/register"

	"gorm.io/gorm"
	"log"
	"net/http"
	"os"
)

type Factory struct {
	Database *gorm.DB
	S3Client *s3.Client
}

func NewFactory(database *gorm.DB) (*Factory, error) {
	var client *s3.Client
	if os.Getenv("USE_MINIO") != "" {
		client = GetMinioClient()
	} else {
		sdkConfig, err := config.LoadDefaultConfig(context.TODO())
		if err != nil {
			return nil, err
		}
		client = s3.NewFromConfig(sdkConfig)
	}
	return &Factory{
		Database: database,
		S3Client: client,
	}, nil
}

func (f *Factory) NewWorkspaceController() *controller.WorkspacesController {

	return &controller.WorkspacesController{
		Repository: workspaces.NewWorkspacesRepository(f.Database),
		FileManager: &file_manager.FileManagerImpl{
			S3Client: f.S3Client,
		},
	}
}

func (f *Factory) NewVcsConnectionsController() *controller.VcsConnectionsController {
	return &controller.VcsConnectionsController{Repository: vcs_connection.New(f.Database)}
}

func (f *Factory) NewOrganizationsController() *controller.OrganizationsController {
	return &controller.OrganizationsController{
		Repository: organization.NewOrganizationRepository(f.Database),
	}
}

func (f *Factory) NewMeController(ab *authboss.Authboss) *controller.MeController {
	return &controller.MeController{
		Database: f.Database,
		Auth:     ab,
	}
}

func (f *Factory) NewAgentsController() *controller.AgentsController {
	return &controller.AgentsController{
		Repository:     agent.NewAgentRepository(f.Database, oauth.NewClientStore(f.Database)),
		RunsRepository: run.NewRunRepository(f.Database),
	}
}

func (f *Factory) NewRunsController() *controller.RunsController {
	workspaceRepo := workspaces.NewWorkspacesRepository(f.Database)
	runsRepo := run.NewRunRepository(f.Database)
	return &controller.RunsController{
		Runs:       runsRepo,
		Workspaces: workspaceRepo,
		FileManager: &file_manager.FileManagerImpl{
			S3Client: f.S3Client,
		},
		RunManager: run_manager.New(runsRepo, workspaceRepo),
	}
}

func (f *Factory) NewOauthServer() *server.Server {
	manager := manage.NewDefaultManager()
	manager.MustTokenStorage(oauth.NewTokenStore(f.Database))
	manager.MapAccessGenerate(generates.NewJWTAccessGenerate("", []byte(os.Getenv("JWT_SECRET_KEY")), jwt.SigningMethodHS512))

	// client memory store
	clientStore := oauth.NewClientStore(f.Database)
	manager.MapClientStorage(clientStore)
	srv := server.NewDefaultServer(manager)
	srv.SetClientInfoHandler(server.ClientFormHandler)
	srv.SetUserAuthorizationHandler(func(w http.ResponseWriter, r *http.Request) (userID string, err error) {
		userID = "testing"
		return
	})
	srv.SetInternalErrorHandler(func(err error) (re *errors.Response) {
		log.Println("Internal Error:", err.Error())
		return
	})
	srv.SetResponseErrorHandler(func(re *errors.Response) {
		log.Println("Response Error:", re.Error.Error())
	})
	return srv
}

func (f *Factory) NewAuthBoss() *authboss.Authboss {
	userStore := organization.NewUserStore(f.Database)
	ab := authboss.New()
	ab.Config.Paths.RootURL = "http://localhost:5000"
	ab.Config.Storage.Server = userStore
	ab.Config.Storage.SessionState = f.NewSessionStore()
	ab.Config.Storage.CookieState = f.NewSessionStore()
	ab.Config.Modules.TwoFactorEmailAuthRequired = true
	ab.Config.Modules.LogoutMethod = "GET"

	// Set paths for redirection
	ab.Config.Paths.Mount = "/auth"
	ab.Config.Paths.AuthLoginOK = "/ui"
	ab.Config.Paths.RegisterOK = "/ui" // TODO: This should be the organization creation screen?

	ab.Config.Core.MailRenderer = abrenderer.NewEmail("/auth", "ab_views")
	ab.Config.Core.ViewRenderer = abrenderer.NewHTML("/auth", "internal/server/views/auth")
	ab.Config.Modules.TOTP2FAIssuer = "Chushi"
	ab.Config.Modules.ResponseOnUnauthed = authboss.RespondRedirect

	defaults.SetCore(&ab.Config, false, false)

	emailRule := defaults.Rules{
		FieldName: "email", Required: true,
		MatchError: "Must be a valid e-mail address",
		MustMatch:  regexp.MustCompile(`.*@.*\.[a-z]{1,}`),
	}
	passwordRule := defaults.Rules{
		FieldName: "password", Required: true,
		MinLength: 4,
	}
	//nameRule := defaults.Rules{
	//	FieldName: "name", Required: true,
	//	MinLength: 2,
	//}

	ab.Config.Core.BodyReader = defaults.HTTPBodyReader{
		ReadJSON: false,
		Rulesets: map[string][]defaults.Rules{
			"register":    {emailRule, passwordRule}, // nameRule},
			"recover_end": {passwordRule},
		},
		Confirms: map[string][]string{
			"register":    {"password", authboss.ConfirmPrefix + "password"},
			"recover_end": {"password", authboss.ConfirmPrefix + "password"},
		},
		Whitelist: map[string][]string{
			"register": []string{"email", "name", "password"},
		},
	}

	twofaRecovery := &twofactor.Recovery{Authboss: ab}
	if err := twofaRecovery.Setup(); err != nil {
		panic(err)
	}

	totp := &totp2fa.TOTP{Authboss: ab}
	if err := totp.Setup(); err != nil {
		panic(err)
	}

	sms := &sms2fa.SMS{Authboss: ab, Sender: smsLogSender{}}
	if err := sms.Setup(); err != nil {
		panic(err)
	}

	if err := ab.Init(); err != nil {
		panic(err)
	}

	return ab
}

func GetMinioClient() *s3.Client {
	key := os.Getenv("AWS_ACCESS_KEY_ID")
	secret := os.Getenv("AWS_SECRET_ACCESS_KEY")

	creds := credentials.NewStaticCredentialsProvider(key, secret, "")

	customResolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, options ...interface{}) (aws.Endpoint, error) {
		return aws.Endpoint{
			URL: "http://localhost:9000",
		}, nil
	})
	cfg, _ := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion("us-east-1"),
		config.WithCredentialsProvider(creds),
		config.WithEndpointResolverWithOptions(customResolver))
	// Create an Amazon S3 service client
	return s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = true
	})
}

func (f *Factory) NewCookieStore() abclientstate.CookieStorer {
	cookieStoreKey, _ := base64.StdEncoding.DecodeString(`NpEPi8pEjKVjLGJ6kYCS+VTCzi6BUuDzU0wrwXyf5uDPArtlofn2AG6aTMiPmN3C909rsEWMNqJqhIVPGP3Exg==`)
	return abclientstate.NewCookieStorer(cookieStoreKey, nil)
}

func (f *Factory) NewSessionStore() abclientstate.SessionStorer {
	sessionStoreKey, _ := base64.StdEncoding.DecodeString(`AbfYwmmt8UCwUuhd9qvfNA9UCuN1cVcKJN1ofbiky6xCyyBj20whe40rJa3Su0WOWLWcPpO1taqJdsEI/65+JA==`)
	return abclientstate.NewSessionStorer("test", sessionStoreKey, nil)
}

type smsLogSender struct {
}

// Send an SMS
func (s smsLogSender) Send(_ context.Context, number, text string) error {
	fmt.Println("sms sent to:", number, "contents:", text)
	return nil
}
