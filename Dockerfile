# Build go
FROM golang:1.22.0-alpine AS builder

WORKDIR /app

# 添加必要的构建工具
RUN apk add --no-cache git gcc musl-dev

# 复制源代码
COPY . .

# 设置环境变量
ENV CGO_ENABLED=0
ENV GO111MODULE=on

# 下载依赖并构建
RUN go mod tidy && \
    go mod download && \
    go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM alpine

# 安装必要的工具包
RUN apk --update --no-cache add tzdata ca-certificates && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 创建配置目录
RUN mkdir /etc/XrayR/

# 从构建阶段复制二进制文件
COPY --from=builder /app/XrayR /usr/local/bin

# 设置入口点
ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/config.yml"]
