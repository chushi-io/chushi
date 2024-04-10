server: export $(cat .env | xargs) && air server --agent
ngrok: export $(cat .env | xargs) && ngrok http --domain=$NGROK_DOMAIN --log=stdout 8080
ui: npm run dev --prefix ui
proxy: export $(cat .env | xargs) && go run cmd/chushi/*.go proxy --grpc-url=http://localhost:8081 --token-url=http://localhost:8080/oauth/v1/token