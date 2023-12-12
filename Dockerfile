# Dockerfile References: https://docs.docker.com/engine/reference/builder/
#
# Usage:
#
# docker build -t pdfcpu .
#
# Simple one off container:
# docker run pdfcpu
#
# One off container with dir binding:
# docker run -v $(pwd):/data -it --rm pdfcpu pdfcpu val test.pdf
#
# Create & run reusable container with dir binding:
# docker run --name pdfcpu -v $(pwd):/data -it pdfcpu /bin/sh
# /data # ...            // run pdfcpu commands against your data
# /data # exit           // exit container
#
# docker start -i pdfcpu // restart container with dir binding
# /data # ...            // run pdfcpu commands against your data
# /data # exit           // exit container

# Start from the latest golang base image
FROM golang:latest as builder

WORKDIR /go/src/pdfcpu

# install
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .

RUN go build -o /go ./cmd/pdfcpu

######## Start a new stage from scratch #######

FROM alpine:latest

RUN apk --no-cache add ca-certificates gcompat

WORKDIR /root

# Copy the pre-built binary file from the previous stage
COPY --from=builder /go/pdfcpu .
