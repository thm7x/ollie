FROM golang:1.24.0 AS buildenv

LABEL maintainer="better.tian@qq.com"

ARG SERVICE
ARG PROJECT
ENV SERVICE=${SERVICE}
ENV PROJECT=${PROJECT}
ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

# Create a location in the container for the source code.
RUN mkdir -p /${PROJECT}/app

WORKDIR /${PROJECT}/app/${SERVICE}
COPY app/${SERVICE}/. .
# COPY vendor vendor
RUN go env -w GOPRIVATE=code.pypygo.com/vertex/devkit
RUN echo "machine code.pypygo.com login <username> password <password>" >> ~/.netrc
RUN go mod download
RUN go mod verify

# RUN cd /${PROJECT}/protos_gen/ && go mod tidy

# RUN make gen service=${SERVICE} 
RUN go build \
    -mod=readonly \
    -ldflags="-w -s" \
    -a -o ${PROJECT}-${SERVICE} .

FROM alpine:3.20 AS runnerenv
RUN mkdir -p /app
WORKDIR /app
ARG SERVICE
ARG PROJECT
ARG VERSION
ARG GIT_COMMIT

ENV SERVICE=${SERVICE}
ENV PROJECT=${PROJECT}
ENV VERSION=${VERSION}
ENV GIT_COMMIT=${GIT_COMMIT}

RUN echo "https://mirrors.aliyun.com/alpine/v3.20/main/" > /etc/apk/repositories \
    && echo "https://mirrors.aliyun.com/alpine/v3.20/community/" >> /etc/apk/repositories \
    && apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  \
    && echo Asia/Shanghai > /etc/timezone \
    && apk del tzdata

COPY --from=buildenv /${PROJECT}/app/${SERVICE}/${PROJECT}-${SERVICE} /${PROJECT}/app/${SERVICE}/script/bootstrap.sh /app
# ls app/conf/{dev,online,test}
# COPY --from=buildenv /etc/ssl/certs /etc/ssl/certs
ENTRYPOINT ["/app/bootstrap.sh"]
