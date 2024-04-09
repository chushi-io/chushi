server: export $(cat .env | xargs) && air server --agent
ngrok: export $(cat .env | xargs) ngrok http --domain=$NGROK_DOMAIN --log=stdout 8080
ui: npm run dev --prefix ui
