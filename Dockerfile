# 本番環境用Dockerfile
FROM node:lts-alpine AS builder

WORKDIR /app

# 依存関係のインストール
COPY package.json ./
RUN npm install

# ソースコードをコピーしてビルド
COPY . .
RUN npm run build

# 本番環境
FROM nginx:alpine

# ビルド成果物をNginxにコピー
COPY --from=builder /app/dist /usr/share/nginx/html

# Nginxの設定をコピー
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
