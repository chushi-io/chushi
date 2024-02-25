build:
	go build cmd/chushi/*.go

minikube:
	docker build -t chushi:latest .
	minikube image load chushi --profile chushi

dev:
	air server --agent

agent:


.PHONY: proto
proto:
	buf generate proto