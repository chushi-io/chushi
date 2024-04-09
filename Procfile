server: export $(cat .env | xargs) && air server --agent
ngrok: ngrok http --domain=caring-foxhound-whole.ngrok-free.app --log=stdout 8080
ui: npm run dev --prefix ui
