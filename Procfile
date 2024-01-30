server: export $(cat .env | xargs) && air server --agent
proxy: ngrok --domain=caring-foxhound-whole.ngrok-free.app http --log=stdout 5000
# ui: npm run dev --prefix ui