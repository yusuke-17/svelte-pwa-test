.PHONY: help all start check reset install dev build preview typecheck clean docker-dev docker-prod docker-build docker-down docker-clean shell logs status

# デフォルト - ヘルプ表示
help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Svelte PWA Todo - Makeコマンド"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "🚀 一括コマンド:"
	@echo "  make all         - 完全セットアップ（install + build + check）"
	@echo "  make start       - 開発環境を起動"
	@echo "  make check       - 全チェック実行（typecheck）"
	@echo "  make reset       - 完全リセット（全削除）"
	@echo ""
	@echo "📦 開発コマンド（すべてDocker内で実行）:"
	@echo "  make install     - 依存関係インストール"
	@echo "  make dev         - 開発サーバー起動"
	@echo "  make build       - 本番ビルド"
	@echo "  make preview     - ビルドプレビュー"
	@echo "  make typecheck   - 型チェック"
	@echo "  make clean       - ビルド成果物削除"
	@echo ""
	@echo "🐳 Docker直接操作:"
	@echo "  make docker-dev   - Docker開発環境起動"
	@echo "  make docker-prod  - Docker本番環境起動"
	@echo "  make docker-build - Dockerイメージビルド"
	@echo "  make docker-down  - Dockerコンテナ停止"
	@echo "  make docker-clean - Docker完全削除"
	@echo ""
	@echo "🔧 ユーティリティ:"
	@echo "  make shell       - コンテナ内シェルアクセス"
	@echo "  make logs        - コンテナログ表示"
	@echo "  make status      - コンテナステータス確認"
	@echo ""
	@echo "⚠️  注意: すべてのコマンドはDocker内で実行されます"
	@echo "    Docker & Docker Composeが必要です"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Docker環境チェック
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "❌ Dockerがインストールされていません"; exit 1; }
	@docker compose version >/dev/null 2>&1 || { echo "❌ Docker Composeがインストールされていません"; exit 1; }

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 一括コマンド
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

all: check-docker install build check
	@echo ""
	@echo "✅ セットアップ完了！"
	@echo "開発を開始するには: make start"

start: check-docker
	@echo "🐳 Docker開発環境を起動します..."
	@docker compose up dev

check: check-docker typecheck
	@echo "✅ チェック完了"

reset: check-docker
	@echo "🧹 完全リセットを実行します..."
	@docker compose down -v --rmi all 2>/dev/null || true
	@rm -rf node_modules dist
	@echo "✅ リセット完了"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 開発コマンド（すべてDocker内で実行）
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

install: check-docker
	@echo "🐳 Dockerコンテナ内でインストール..."
	@docker compose run --rm dev npm install

dev: check-docker
	@echo "🐳 Docker開発環境を起動..."
	@docker compose up dev

build: check-docker
	@echo "🐳 Dockerコンテナ内でビルド..."
	@docker compose run --rm dev npm run build

preview: check-docker
	@echo "🐳 Dockerコンテナ内でプレビュー..."
	@docker compose run --rm -p 4173:4173 dev npm run preview -- --host 0.0.0.0

typecheck: check-docker
	@echo "🐳 Dockerコンテナ内で型チェック..."
	@docker compose run --rm dev npm run typecheck

clean: check-docker
	@echo "🐳 Dockerコンテナ内でクリーン..."
	@docker compose run --rm dev rm -rf dist

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Docker直接操作
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

docker-dev: check-docker
	@docker compose up dev

docker-prod: check-docker
	@docker compose up prod

docker-build: check-docker
	@docker compose build

docker-down: check-docker
	@docker compose down

docker-clean: check-docker
	@docker compose down -v --rmi all

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ユーティリティ
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# シェルアクセス（デバッグ用）
shell: check-docker
	@echo "🐳 Dockerコンテナ内のシェルを起動..."
	@docker compose run --rm dev sh

# ログ表示
logs: check-docker
	@docker compose logs -f dev

# コンテナステータス確認
status: check-docker
	@docker compose ps
