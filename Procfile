server: export $(cat .env | xargs) && air server --agent
proxy: ngrok tcp --remote-addr=caring-foxhound-whole.ngrok-free.app --log=stdout 5000
ui: npm run dev --prefix ui