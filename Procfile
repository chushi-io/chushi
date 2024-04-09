server: export $(cat .env | xargs) && air server --agent
ngrok: ngrok http --domain=caring-foxhound-whole.ngrok-free.app --log=stdout 8080
ui: npm run dev --prefix ui
# proxy: export $(cat .env | xargs) && go run cmd/chushi/*.go proxy --address localhost:5002 --grpc-url http://localhost:8080/grpc --token-url https://caring-foxhound-whole.ngrok-free.app/oauth/v1/token

# agent: go run cmd/chushi/*.go agent --agent-id bb9f6297-3c9c-4855-a168-4d065fd728c7 --token-url https://caring-foxhound-whole.ngrok-free.app/oauth/v1/token --server-url https://caring-foxhound-whole.ngrok-free.app/api/v1 --org-id 51e03fca-ef9d-4c55-93a4-ebf4dc4b1b4e --driver docker