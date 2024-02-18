build:
	go build cmd/chushi/*.go

minikube:
	docker build -t chushi:latest .
	minikube image load chushi --profile chushi

dev:
	air server --agent

.PHONY: proto
proto:
	protoc --go_out=. --go_opt=paths=source_relative \
        --go-grpc_out=. --go-grpc_opt=paths=source_relative \
        proto/api/v1/run.proto