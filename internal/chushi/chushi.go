package chushi

import (
	"connectrpc.com/connect"
	"context"
	"encoding/base64"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/chushi-io/chushi/gen/api/v1/apiv1connect"
	"github.com/chushi-io/chushi/internal/controller"
	"github.com/chushi-io/chushi/internal/grpc"
	"github.com/chushi-io/chushi/internal/middleware"
	auth2 "github.com/chushi-io/chushi/internal/middleware/auth"
	"github.com/chushi-io/chushi/internal/resource/agent"
	"github.com/chushi-io/chushi/internal/resource/oauth"
	"github.com/chushi-io/chushi/internal/resource/organization"
	"github.com/chushi-io/chushi/internal/resource/run"
	"github.com/chushi-io/chushi/internal/resource/variables"
	"github.com/chushi-io/chushi/internal/resource/vcs_connection"
	"github.com/chushi-io/chushi/internal/resource/workspaces"
	"github.com/chushi-io/chushi/internal/server"
	"github.com/chushi-io/chushi/internal/server/config"
	"github.com/chushi-io/chushi/internal/service/file_manager"
	"github.com/chushi-io/chushi/internal/service/run_manager"
	"github.com/chushi-io/chushi/pkg/types"
	"github.com/gin-gonic/gin"
	"github.com/go-oauth2/oauth2/v4/errors"
	"github.com/go-oauth2/oauth2/v4/generates"
	"github.com/go-oauth2/oauth2/v4/manage"
	oauthserver "github.com/go-oauth2/oauth2/v4/server"
	"github.com/golang-jwt/jwt/v4"
	abclientstate "github.com/volatiletech/authboss-clientstate"
	abrenderer "github.com/volatiletech/authboss-renderer"
	"github.com/volatiletech/authboss/v3"
	"github.com/volatiletech/authboss/v3/defaults"
	"github.com/volatiletech/authboss/v3/otp/twofactor"
	"github.com/volatiletech/authboss/v3/otp/twofactor/sms2fa"
	"github.com/volatiletech/authboss/v3/otp/twofactor/totp2fa"
	"go.uber.org/fx"
	"go.uber.org/zap"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"log"
	"net/http"
	"os"
	"regexp"
)

func ProvideConfig() *config.Config {
	conf, _ := config.Load()
	return conf
}

func ProvideDatabase(conf *config.Config, log *zap.Logger, lc fx.Lifecycle) (*gorm.DB, error) {
	gormConfig := &gorm.Config{}
	if os.Getenv("APP_ENV") == "development" {
		gormConfig.Logger = logger.Default.LogMode(logger.Info)
	} else {
		gin.SetMode(gin.ReleaseMode)
	}

	database, err := gorm.Open(postgres.Open(conf.DatabaseUri), gormConfig)
	if err != nil {
		return database, err
	}
	lc.Append(fx.Hook{
		OnStart: func(ctx context.Context) error {
			log.Info("Running database migrations")
			if err := database.AutoMigrate(
				&workspaces.Workspace{},
				&variables.Variable{},
				&variables.VariableSet{},
				&variables.OrganizationVariable{},
				&variables.WorkspaceVariable{},
				&variables.WorkspaceVariableSet{},
				&variables.OrganizationVariableSet{},
				&organization.Organization{},
				&oauth.OauthClient{},
				&oauth.OauthToken{},
				&run.Run{},
				&organization.User{},
				&organization.OrganizationUser{},
				&vcs_connection.VcsConnection{},
			); err != nil {
				return err
			}

			return nil
		},
		OnStop: func(ctx context.Context) error {
			log.Info("Shutting down database")
			return nil
		},
	})
	return database, nil
}

func Server() *fx.App {
	return fx.New(
		fx.NopLogger,
		fx.Provide(
			// Base components
			ProvideConfig,
			ProvideDatabase,
			zap.NewProduction,
			func() (*s3.Client, error) {
				if os.Getenv("USE_MINIO") != "" {
					key := os.Getenv("AWS_ACCESS_KEY_ID")
					secret := os.Getenv("AWS_SECRET_ACCESS_KEY")

					creds := credentials.NewStaticCredentialsProvider(key, secret, "")

					customResolver := aws.EndpointResolverWithOptionsFunc(func(service, region string, options ...interface{}) (aws.Endpoint, error) {
						return aws.Endpoint{
							URL: "http://localhost:9000",
						}, nil
					})
					cfg, _ := awsconfig.LoadDefaultConfig(context.TODO(),
						awsconfig.WithRegion("us-east-1"),
						awsconfig.WithCredentialsProvider(creds),
						awsconfig.WithEndpointResolverWithOptions(customResolver))
					// Create an Amazon S3 service client
					return s3.NewFromConfig(cfg, func(o *s3.Options) {
						o.UsePathStyle = true
					}), nil
				} else {
					sdkConfig, err := awsconfig.LoadDefaultConfig(context.TODO())
					if err != nil {
						return nil, err
					}
					return s3.NewFromConfig(sdkConfig), nil
				}
			},

			// OAuth
			oauth.NewClientStore,
			oauth.NewTokenStore,

			// Repositories
			organization.NewOrganizationRepository,
			organization.NewUserStore,
			agent.NewAgentRepository,
			run.NewRunRepository,
			variables.NewVariableRepository,
			variables.NewVariableSetsRepository,
			vcs_connection.New,
			workspaces.NewWorkspacesRepository,

			// Controllers
			controller.NewAgentsController,
			controller.NewOrganizationsController,
			controller.NewRunsController,
			controller.NewMeController,
			controller.NewVariablesController,
			controller.NewVariableSetsController,
			controller.NewWorkspacesController,
			controller.NewVcsConnectionsController,

			// Utils
			file_manager.New,
			run_manager.New,

			// GRPC endpoints
			func(
				clientStore *oauth.ClientStore,
				agentRepo agent.AgentRepository,
			) connect.Option {
				interceptors := connect.WithInterceptors(auth2.NewAuthInterceptor(
					clientStore,
					agentRepo,
				))
				return interceptors
			},

			// Workspaces GRPC
			fx.Annotate(func(
				interceptors connect.Option,
				repo workspaces.WorkspacesRepository,
			) types.GrpcRoute {
				path, handler := apiv1connect.NewWorkspacesHandler(
					&grpc.WorkspaceServer{Repository: repo},
					interceptors,
				)
				return types.GrpcRouteRegistration(path+"*action", gin.WrapH(http.StripPrefix("/grpc", handler)))
			}, fx.As(new(types.GrpcRoute)), fx.ResultTags(`name:"grpc_workspaces"`)),

			// Auth GRPC
			fx.Annotate(func(
				interceptors connect.Option,
				conf *config.Config,
			) types.GrpcRoute {
				path, handler := apiv1connect.NewAuthHandler(
					grpc.NewAuthServer(conf.JwtSecretKey),
					interceptors,
				)
				return types.GrpcRouteRegistration(path+"*action", gin.WrapH(http.StripPrefix("/grpc", handler)))
			}, fx.As(new(types.GrpcRoute)), fx.ResultTags(`name:"grpc_auth"`)),

			// Plans GRPC
			fx.Annotate(func(
				interceptors connect.Option,
			) types.GrpcRoute {
				path, handler := apiv1connect.NewPlansHandler(
					&grpc.PlanServer{}, interceptors,
				)
				return types.GrpcRouteRegistration(path+"*action", gin.WrapH(http.StripPrefix("/grpc", handler)))
			}, fx.As(new(types.GrpcRoute)), fx.ResultTags(`name:"grpc_plans"`)),

			// Logs GRPC
			fx.Annotate(func(
				interceptors connect.Option,
			) types.GrpcRoute {
				path, handler := apiv1connect.NewLogsHandler(
					&grpc.LogsServer{}, interceptors,
				)
				return types.GrpcRouteRegistration(path+"*action", gin.WrapH(http.StripPrefix("/grpc", handler)))
			}, fx.As(new(types.GrpcRoute)), fx.ResultTags(`name:"grpc_logs"`)),

			// Runs GRPC
			fx.Annotate(func(
				interceptors connect.Option,
				runRepo run.RunRepository,
				agentRepo agent.AgentRepository,
			) types.GrpcRoute {
				path, handler := apiv1connect.NewRunsHandler(
					&grpc.RunServer{
						RunRepository:   runRepo,
						AgentRepository: agentRepo,
					}, interceptors,
				)
				return types.GrpcRouteRegistration(path+"*action", gin.WrapH(http.StripPrefix("/grpc", handler)))
			}, fx.As(new(types.GrpcRoute)), fx.ResultTags(`name:"grpc_runs"`)),

			func(
				orgRepo organization.OrganizationRepository,
				auth *authboss.Authboss,
				userStore *organization.UserStore,
				oauthServer *oauthserver.Server,
				clientStore *oauth.ClientStore,
			) *middleware.OrganizationAccessMiddleware {
				return &middleware.OrganizationAccessMiddleware{
					OrganizationRepository: orgRepo,
					Auth:                   auth,
					UserStore:              userStore,
					OauthServer:            oauthServer,
					ClientStore:            clientStore,
				}
			},
			func(
				conf *config.Config,
				tokenStore *oauth.TokenStore,
				clientStore *oauth.ClientStore,
			) *oauthserver.Server {
				manager := manage.NewDefaultManager()
				manager.MustTokenStorage(tokenStore, nil)
				manager.MapAccessGenerate(generates.NewJWTAccessGenerate("", []byte(conf.JwtSecretKey), jwt.SigningMethodHS512))

				// client memory store
				manager.MapClientStorage(clientStore)
				srv := oauthserver.NewDefaultServer(manager)
				srv.SetClientInfoHandler(oauthserver.ClientFormHandler)
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
			},
			func() abclientstate.CookieStorer {
				cookieStoreKey, _ := base64.StdEncoding.DecodeString(`NpEPi8pEjKVjLGJ6kYCS+VTCzi6BUuDzU0wrwXyf5uDPArtlofn2AG6aTMiPmN3C909rsEWMNqJqhIVPGP3Exg==`)
				return abclientstate.NewCookieStorer(cookieStoreKey, nil)
			},
			func() abclientstate.SessionStorer {
				sessionStoreKey, _ := base64.StdEncoding.DecodeString(`AbfYwmmt8UCwUuhd9qvfNA9UCuN1cVcKJN1ofbiky6xCyyBj20whe40rJa3Su0WOWLWcPpO1taqJdsEI/65+JA==`)
				return abclientstate.NewSessionStorer("test", sessionStoreKey, nil)
			},
			func(
				store *organization.UserStore,
				cookieStore abclientstate.CookieStorer,
				sessionStore abclientstate.SessionStorer,
			) *authboss.Authboss {
				ab := authboss.New()
				ab.Config.Paths.RootURL = "http://localhost:5000"
				ab.Config.Storage.Server = store
				ab.Config.Storage.SessionState = sessionStore
				ab.Config.Storage.CookieState = cookieStore
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
			},
			// Server(s)
			server.New,
		),
		fx.Invoke(server.New),
	)
}

type smsLogSender struct {
}

// Send an SMS
func (s smsLogSender) Send(_ context.Context, number, text string) error {
	fmt.Println("sms sent to:", number, "contents:", text)
	return nil
}
