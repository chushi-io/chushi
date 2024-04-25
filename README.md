# chushi

## Debug GRPC requests 
``` 
GODEBUG=http2debug=2
```

## Run agent 
```shell
go run cmd/chushi/*.go agent --agent-id $AGENT_ID --token-url https://caring-foxhound-whole.ngrok-free.app/oauth/v1/token --org-id $ORG_ID --driver docker --grpc-url http://localhost:8081
```