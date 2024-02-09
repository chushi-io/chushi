server: export $(cat .env | xargs) && air server --agent
proxy: ngrok http --domain=caring-foxhound-whole.ngrok-free.app --log=stdout 5000
ui: npm run dev --prefix ui