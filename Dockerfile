FROM golang:1.13 as builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

# CGO_ENABLED=0 - Disable dynamically linked C libraries
# -a - Build dependency packages with cgo disabled
RUN CGO_ENABLED=0 go build -v -a -o main .

# Special Dockerfile that is empty
# "scratch is not a parent image. Rather it indicates Docker that the image is
# not built on top of any other image."
FROM scratch

# Copy certs for SSL in scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /app/main .

CMD ["/main"]
