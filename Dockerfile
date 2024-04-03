FROM golang:1.21

WORKDIR /app
COPY go.mod go.sum /app/
RUN go mod download
# TODO: Just copy over required files
COPY . ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /chushi ./cmd/chushi

ENTRYPOINT ["/chushi"]