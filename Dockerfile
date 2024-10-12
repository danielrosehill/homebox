# Node dependencies
FROM node:18-alpine AS frontend-dependencies
WORKDIR /app
RUN npm install -g pnpm
COPY frontend/package.json frontend/pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --shamefully-hoist

# Build Nuxt
FROM node:18-alpine AS frontend-builder
WORKDIR /app
COPY frontend ./
COPY --from=frontend-dependencies /app/node_modules ./node_modules
RUN pnpm build

FROM golang:alpine AS builder-dependencies
WORKDIR /go/src/app
COPY ./backend/go.mod ./backend/go.sum ./
RUN go mod download

# Build API
FROM golang:alpine AS builder
ARG BUILD_TIME
ARG COMMIT
ARG VERSION
RUN apk update && apk upgrade && apk add --no-cache git build-base gcc g++

WORKDIR /go/src/app
COPY ./backend .
RUN rm -rf ./app/api/public
COPY --from=frontend-builder /app/.output/public ./app/api/static/public
COPY --from=builder-dependencies /go/pkg/mod /go/pkg/mod
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-s -w -X main.commit=$COMMIT -X main.buildTime=$BUILD_TIME -X main.version=$VERSION" \
    -o /go/bin/api ./app/api/*.go

# Production Stage
FROM alpine:latest
WORKDIR /app
COPY --from=builder /go/bin/api /app/api
RUN apk --no-cache add ca-certificates wget

ENTRYPOINT ["/app/api"]
CMD ["/data/config.yml"]
