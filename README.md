# Svelte PWA Todo App

Svelte 5 + Vite + TypeScript + vite-plugin-pwa で構築したシンプルなTodoアプリケーションです。PWA（Progressive Web App）として動作し、オフラインでも使用できます。

## 🚀 特徴

- **Svelte 5**: 最新のSvelte 5を使用した高速でリアクティブなUI
- **PWA対応**: Service Workerによるオフライン対応とインストール可能
- **TypeScript**: 型安全な開発環境
- **localStorage**: ローカルストレージによるデータ永続化
- **Docker対応**: 開発環境と本番環境の両方をサポート
- **レスポンシブデザイン**: モバイルとデスクトップに対応

## 📦 必要な環境

- Node.js LTS版以上（ローカル環境の場合）
- Docker & Docker Compose（推奨）
- Make（コマンド簡略化用）

## 🛠️ セットアップ

### 環境変数の設定

外部ドメイン（ngrokなど）からアクセスする場合は、環境変数を設定してください:

```bash
# .env.localファイルを作成（.env.exampleをコピー）
cp .env.example .env.local

# .env.localを編集して、許可するホストを設定
# 例: ALLOWED_HOSTS=localhost,your-domain.ngrok-free.dev
```

**セキュリティ上の注意:**

- `.env.local`はGit管理対象外です（個人の開発環境用）
- デフォルトでは`localhost`のみ許可されています
- 外部ドメインを追加する場合は、信頼できるドメインのみを指定してください

### クイックスタート（推奨）

```bash
# 初回セットアップ（一括実行）
make all

# 開発環境を起動（Docker優先で自動判定）
make start
```

### 個別コマンド

```bash
# 依存関係のインストール（Docker優先）
make install

# 開発サーバー起動（Docker優先）
make dev

# 本番ビルド（Docker優先）
make build

# ビルドプレビュー
make preview

# 型チェック
make typecheck

# クリーンアップ
make clean

# 完全リセット
make reset
```

### Docker直接操作

```bash
# Docker開発環境
make docker-dev

# Docker本番環境
make docker-prod

# Dockerイメージビルド
make docker-build

# コンテナ停止
make docker-down

# Docker完全削除
make docker-clean
```

### ヘルプ

```bash
# 利用可能なコマンド一覧
make help
```

## 🌐 アクセス

- **ローカル開発**: http://localhost:5173
- **Docker開発環境**: http://localhost:5173
- **Docker本番環境**: http://localhost:8080

## 📱 PWA機能とインストール方法

このアプリはPWA（Progressive Web App）として動作し、ネイティブアプリのようにホーム画面からアクセスできます。

### 🍎 iPhoneでのインストール（Safari必須）

**⚠️ 注意: iPhoneではSafariブラウザのみPWAインストールに対応しています**

1. **Safariでアプリを開く**
2. **画面下部の共有ボタン**(↑アイコン)をタップ
3. **「ホーム画面に追加」**を選択
4. アプリ名を確認して**「追加」**をタップ
5. ホーム画面にアイコンが追加されます

### 🖥️ デスクトップ（Chrome/Edge）でのインストール

1. **ブラウザでアプリを開く**
2. **アドレスバーの「インストール」ボタン**（⊕アイコン）をクリック
3. **「インストール」**をクリック
4. アプリがスタンドアロンウィンドウで起動します

### 🤖 Androidでのインストール（Chrome）

1. **Chromeでアプリを開く**
2. **メニュー**(︙)から**「ホーム画面に追加」**を選択
3. **「追加」**をタップ
4. ホーム画面にアイコンが追加されます

### ✨ PWAの特徴

- ✅ **オフライン動作**: 一度アクセスすれば、ネット接続なしでも利用可能
- ✅ **スタンドアロン起動**: ブラウザのUIなしで、アプリとして起動
- ✅ **自動キャッシュ**: 静的ファイルが自動的にキャッシュされる
- ✅ **データ永続化**: localStorageでTodoデータを保存

### 🔧 開発環境でのテスト

開発環境（`npm run dev`）では、PWAのService Worker機能が制限されます。完全なPWA機能をテストする場合は、本番ビルドを使用してください:

```bash
# 本番ビルド
npm run build

# プレビューサーバーで確認
npm run preview
```

### 📱 モバイルデバイスでのテスト

ローカル開発サーバーをモバイルデバイスでテストする場合は、以下の方法があります:

**方法1: ngrokを使用（推奨）**

```bash
# ngrokをインストール
brew install ngrok

# ngrokアカウントでログイン後
ngrok http 5173
```

表示されたHTTPS URLをモバイルデバイスで開いてください。

**方法2: 同一ネットワーク内でアクセス**

```bash
# MacのローカルIPを確認
ipconfig getifaddr en0

# モバイルデバイスで http://[IPアドレス]:5173 にアクセス
```

⚠️ **注意**: PWAの完全な機能にはHTTPS接続が必要です（localhost除く）

## 🎯 主な機能

- ✅ タスクの追加
- ✅ タスクの完了/未完了切り替え
- ✅ タスクの削除
- ✅ ローカルストレージへの自動保存
- ✅ オフライン動作
- ✅ レスポンシブデザイン

## 📁 プロジェクト構造

```
svelte-pwa-test/
├── src/
│   ├── components/
│   │   ├── TodoList.svelte    # Todoリストコンポーネント
│   │   └── TodoItem.svelte    # Todo項目コンポーネント
│   ├── App.svelte             # メインアプリコンポーネント
│   ├── main.ts                # エントリーポイント
│   └── app.css                # グローバルスタイル
├── public/
│   ├── manifest.json          # PWAマニフェスト
│   ├── icon-192.png           # PWAアイコン (192x192)
│   ├── icon-512.png           # PWAアイコン (512x512)
│   └── favicon.ico            # ファビコン
├── vite.config.ts             # Vite設定 (PWAプラグイン含む)
├── tsconfig.json              # TypeScript設定
├── docker-compose.yml         # Docker Compose設定
├── Dockerfile                 # 本番環境用Dockerfile
└── Dockerfile.dev             # 開発環境用Dockerfile
```

## 🔧 技術スタック

- **フロントエンド**: Svelte 5
- **ビルドツール**: Vite 5
- **言語**: TypeScript
- **PWA**: vite-plugin-pwa (Workbox)
- **コンテナ**: Docker & Docker Compose
- **Webサーバー**: Nginx (本番環境)

## 📝 開発のポイント

### Svelte 5の新機能

このプロジェクトではSvelte 5の新しいリアクティビティシステムを使用しています:

- `$state`: リアクティブな状態管理
- `$props`: コンポーネントプロップス
- Runesベースのシンプルな記法

### PWA設定

`vite.config.ts`で以下のPWA設定を行っています:

- **registerType**: `autoUpdate` - 自動更新
- **precaching**: 全ての静的アセットをプリキャッシュ
- **manifest**: アプリのメタデータ定義

## 🚢 デプロイ

本番環境へのデプロイ:

```bash
# Dockerイメージのビルド
docker build -t svelte-pwa-todo .

# コンテナの実行
docker run -p 8080:80 svelte-pwa-todo
```

## 📄 ライセンス

MIT

## 🤝 コントリビューション

実験用プロジェクトですが、改善提案は歓迎します！
