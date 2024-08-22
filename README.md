# Chushi 

## Development 

```shell 
git clone git@github.com:chushi-io/chushi
cd chushi 

docker compose up -d
cp .env.example .env # And change NGROK_DOMAIN= to have your domain from above
bundle install
npm install
openssl genpkey -algorithm RSA -out oidc_key.pem -pkeyopt rsa_keygen_bits:2048

bundle exec rails db:create 
bundle exec rails db:migrate
bundle exec rails db:seeds:development
./bin/dev
```

### Credentials

#### Organization Access Token 
```shell
echo 'Organization.first.access_tokens.first.token' | bundle exec rails c
```

#### Organization ID
```shell
echo 'Organization.first.id' | bundle exec rails c
```

#### User Access Token
```shell
echo 'User.first.access_tokens.first.token' | bundle exec rails c
```


TODO: 
- State versions are created, but we need to support storing the actual file contents
- Better error handling and status management of workspace / run / plan / apply
- UX handling of locked workspace
- Streaming of logs for plan / apply operations
- Support for destroy, refresh, etc
- Implementation of Drift detection schedule
- Implementation of Auto Destroy


### Generating an OIDC token for agents / workspaces 
```ruby 
@workspace = Workspace.first
@access_token = Doorkeeper::AccessToken.create(resource_owner_id: @workspace.id)
@access_token.save! 
@id_token = Doorkeeper::OpenidConnect::IdToken.new(@access_token)
puts @id_token.as_jws_token
```

This token can then be stored in the filesystem, and used to authenticate to a CSP