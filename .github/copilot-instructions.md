# Svelte PWA プロジェクト開発ルール

このドキュメントは、Svelte 5ベースのPWAプロジェクトにおける開発ガイドラインとベストプラクティスを定義します。

---

## 1. Svelte 5 コーディング規約

### ✅ 必須: Runes構文の使用

Svelte 5の新しいリアクティビティシステム（Runes）を使用してください。

#### リアクティブな状態管理
```typescript
// ✅ 正しい
let count = $state(0);
let items = $state<Item[]>([]);
let text = $state("");

// ❌ 間違い（レガシー構文）
let count = 0; // $: で監視
```

#### コンポーネントプロップス
```typescript
// ✅ 正しい
interface Props {
  title: string;
  count?: number;
}
let { title, count = 0 }: Props = $props();

// ❌ 間違い（レガシー構文）
export let title: string;
export let count: number = 0;
```

#### 派生値の計算
```typescript
// ✅ 正しい
let doubled = $derived(count * 2);
let total = $derived(items.reduce((sum, item) => sum + item.price, 0));

// 複雑な計算の場合
let expensive = $derived.by(() => {
  // 重い計算処理
  return items.filter(item => item.active).length;
});

// ❌ 間違い（レガシー構文）
$: doubled = count * 2;
```

#### 副作用の処理
```typescript
// ✅ 正しい
$effect(() => {
  console.log('Count changed:', count);
  // クリーンアップが必要な場合
  return () => {
    // cleanup code
  };
});

// ❌ 間違い（レガシー構文）
$: console.log('Count changed:', count);
```

#### エントリーポイント
```typescript
// ✅ 正しい（main.ts）
import { mount } from 'svelte';
import App from './App.svelte';

const app = mount(App, {
  target: document.getElementById('app')!
});

// ❌ 間違い（レガシー構文）
import App from './App.svelte';
const app = new App({ target: document.getElementById('app')! });
```

### ❌ 禁止: レガシー構文

以下の構文は使用しないでください:

- `$:` リアクティブ文 → `$derived` または `$effect` を使用
- `export let` → `$props()` を使用
- `new Component()` → `mount()` を使用
- `on:click` → `onclick` を使用（後述）

### イベントハンドラ

Svelte 5では、ネイティブHTMLイベント属性スタイルを使用します。

```typescript
// ✅ 正しい
<button onclick={handleClick}>クリック</button>
<input oninput={handleInput} />
<form onsubmit={handleSubmit} />
<div onkeydown={handleKeyDown} />

// ❌ 間違い（レガシー構文）
<button on:click={handleClick}>クリック</button>
```

---

## 2. TypeScript規約

### 厳格モード必須

`tsconfig.json` で `"strict": true` を維持してください。

### すべてのSvelteファイルでTypeScript使用

```svelte
<!-- ✅ 正しい -->
<script lang="ts">
  interface Todo {
    id: number;
    text: string;
    completed: boolean;
  }
  
  let todos = $state<Todo[]>([]);
</script>

<!-- ❌ 間違い -->
<script>
  let todos = $state([]);
</script>
```

### 型定義のガイドライン

#### インターフェースの明示
```typescript
// ✅ 正しい
interface User {
  id: number;
  name: string;
  email: string;
}

function getUser(id: number): User | null {
  // ...
}

// ❌ 型推論に頼りすぎない
function getUser(id) {
  // ...
}
```

#### 型定義の配置場所

1. **コンポーネント固有の型**: 同じ `.svelte` ファイル内に定義
   ```typescript
   <script lang="ts">
     interface Todo {
       id: number;
       text: string;
       completed: boolean;
     }
   </script>
   ```

2. **共有型**: `src/types/` ディレクトリに配置
   ```typescript
   // src/types/user.ts
   export interface User {
     id: number;
     name: string;
     email: string;
   }
   ```

3. **グローバル型宣言**: `src/vite-env.d.ts` に追加
   ```typescript
   /// <reference types="svelte" />
   /// <reference types="vite/client" />
   
   interface ImportMetaEnv {
     readonly VITE_API_URL: string;
   }
   ```

#### Props型の明示的定義

```typescript
// ✅ 正しい
interface Props {
  todo: Todo;
  onToggle: () => void;
  onDelete: () => void;
}

let { todo, onToggle, onDelete }: Props = $props();

// ❌ 間違い（型なし）
let { todo, onToggle, onDelete } = $props();
```

---

## 3. コードスタイル（Prettier/ESLint）

### Prettier設定

プロジェクトに Prettier を導入する場合の推奨設定:

#### インストール
```bash
pnpm add -D prettier prettier-plugin-svelte
```

#### `.prettierrc` 推奨設定
```json
{
  "printWidth": 100,
  "singleQuote": true,
  "semi": true,
  "trailingComma": "es5",
  "tabWidth": 2,
  "useTabs": false,
  "plugins": ["prettier-plugin-svelte"],
  "overrides": [
    {
      "files": "*.svelte",
      "options": {
        "parser": "svelte"
      }
    }
  ]
}
```

#### `.prettierignore`
```
node_modules
dist
.svelte-kit
pnpm-lock.yaml
```

#### `package.json` にスクリプト追加
```json
{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

### ESLint設定

#### インストール
```bash
pnpm add -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
pnpm add -D eslint-plugin-svelte svelte-eslint-parser
```

#### `.eslintrc.cjs` 推奨設定
```javascript
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:svelte/recommended',
  ],
  plugins: ['@typescript-eslint'],
  parserOptions: {
    sourceType: 'module',
    ecmaVersion: 2020,
    extraFileExtensions: ['.svelte'],
  },
  env: {
    browser: true,
    es2017: true,
    node: true,
  },
  overrides: [
    {
      files: ['*.svelte'],
      parser: 'svelte-eslint-parser',
      parserOptions: {
        parser: '@typescript-eslint/parser',
      },
    },
  ],
};
```

#### `package.json` にスクリプト追加
```json
{
  "scripts": {
    "lint": "eslint src --ext .ts,.svelte",
    "lint:fix": "eslint src --ext .ts,.svelte --fix"
  }
}
```

---

## 4. コンポーネント設計規約

### 単一責任原則

1コンポーネント = 1つの責務を持つようにしてください。

```typescript
// ✅ 正しい
// TodoList.svelte: Todoリスト全体の管理
// TodoItem.svelte: 個別のTodo項目の表示

// ❌ 間違い
// App.svelte: すべてのロジックを詰め込む
```

#### サイズガイドライン
- 150行を超える場合は分割を検討
- ロジックとUIの分離を意識

### Props定義

```typescript
// ✅ 正しい: 必須と任意を明確に
interface Props {
  // 必須プロップス
  id: number;
  title: string;
  
  // 任意プロップス（デフォルト値あり）
  count?: number;
  enabled?: boolean;
}

let { id, title, count = 0, enabled = true }: Props = $props();

// ❌ 間違い: 型定義なし
let { id, title, count = 0 } = $props();
```

### イベントハンドラのパターン

```typescript
// ✅ 正しい: コールバック関数をpropsで受け取る
interface Props {
  onSave: (data: FormData) => void;
  onCancel: () => void;
}

let { onSave, onCancel }: Props = $props();

<button onclick={onSave}>保存</button>
<button onclick={onCancel}>キャンセル</button>
```

### ファイル命名規則

- **コンポーネント**: PascalCase
  - `TodoItem.svelte`
  - `UserProfile.svelte`
  - `NavigationBar.svelte`

- **1ファイル1コンポーネント**: 複数のコンポーネントを1ファイルに含めない

### スタイル規約

#### Scoped CSS優先

```svelte
<style>
  /* このコンポーネントにのみ適用される */
  .container {
    padding: 20px;
  }
</style>
```

#### グローバルスタイルは明示的に

```svelte
<style>
  :global(body) {
    margin: 0;
    font-family: sans-serif;
  }
  
  /* Scoped */
  .container {
    /* ... */
  }
  
  /* Scoped内の特定要素をグローバルに */
  .container :global(.external-class) {
    /* ... */
  }
</style>
```

#### CSS変数でテーマ管理

```svelte
<style>
  :global(:root) {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --text-color: #333;
  }
  
  .button {
    background: var(--primary-color);
    color: white;
  }
</style>
```

---

## 5. 状態管理ガイドライン

### ローカル状態（`$state`）

コンポーネント内でのみ使用する状態:

```typescript
let count = $state(0);
let items = $state<Item[]>([]);
let isLoading = $state(false);
```

### 派生状態（`$derived`）

他の状態から計算される値:

```typescript
// シンプルな計算
let doubled = $derived(count * 2);

// 配列の変換
let completedCount = $derived(
  todos.filter(todo => todo.completed).length
);

// 複雑な計算
let filteredItems = $derived.by(() => {
  return items
    .filter(item => item.active)
    .sort((a, b) => a.name.localeCompare(b.name))
    .slice(0, 10);
});
```

### 共有状態（コンテキストAPI）

複数のコンポーネント間で状態を共有する場合:

#### 親コンポーネント（プロバイダー）
```typescript
<script lang="ts">
  import { setContext } from 'svelte';
  
  interface UserContext {
    user: User;
    updateUser: (data: Partial<User>) => void;
  }
  
  let user = $state<User>({ id: 1, name: 'John' });
  
  function updateUser(data: Partial<User>) {
    user = { ...user, ...data };
  }
  
  setContext<UserContext>('user', {
    get user() { return user; },
    updateUser
  });
</script>
```

#### 子コンポーネント（コンシューマー）
```typescript
<script lang="ts">
  import { getContext } from 'svelte';
  
  interface UserContext {
    user: User;
    updateUser: (data: Partial<User>) => void;
  }
  
  const { user, updateUser } = getContext<UserContext>('user');
</script>

<p>{user.name}</p>
```

### localStorage永続化

#### キープレフィックスを使用

```typescript
const STORAGE_KEY = "svelte-pwa-todos"; // プロジェクト名をプレフィックスに

function saveTodos() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(todos));
}

function loadTodos() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored) {
    try {
      todos = JSON.parse(stored);
    } catch (e) {
      console.error("Failed to load todos:", e);
      todos = [];
    }
  }
}
```

#### エラーハンドリング必須

```typescript
// ✅ 正しい: try-catchで保護
try {
  const data = JSON.parse(localStorage.getItem(KEY) || '[]');
  items = data;
} catch (error) {
  console.error('Failed to parse data:', error);
  items = [];
}

// ❌ 間違い: エラーハンドリングなし
items = JSON.parse(localStorage.getItem(KEY));
```

---

## 6. PWA開発規約

### vite-plugin-pwa設定

#### 自動更新を推奨

```typescript
// vite.config.ts
VitePWA({
  registerType: 'autoUpdate', // ✅ 自動更新
  // registerType: 'prompt', // ユーザーに確認する場合
})
```

#### manifest.json更新時の注意

`public/manifest.json` または `vite.config.ts` の `manifest` 設定を更新した場合:

1. ビルドして確認: `make build`
2. プレビューでテスト: `make preview`
3. ブラウザのキャッシュをクリア

### Service Worker管理

#### 手動コードは書かない

`vite-plugin-pwa` が自動生成するため、手動でService Workerコードを書く必要はありません。

#### キャッシュ戦略の設定

```typescript
// vite.config.ts
VitePWA({
  workbox: {
    globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
    runtimeCaching: [
      {
        urlPattern: /^https:\/\/api\.example\.com\/.*/i,
        handler: 'NetworkFirst',
        options: {
          cacheName: 'api-cache',
          expiration: {
            maxEntries: 10,
            maxAgeSeconds: 60 * 60 * 24 // 24時間
          }
        }
      }
    ]
  }
})
```

### テスト環境

#### 開発環境の制限

`npm run dev` では、Service Worker機能が制限されます。

#### 完全なPWAテスト

```bash
# 本番ビルド
make build

# プレビューサーバーで確認
make preview
```

#### HTTPS必須

- **localhost**: HTTPでもPWA機能は動作
- **外部ドメイン**: HTTPS必須
- **ngrok等**: HTTPS URLを使用

### PWAアイコン

#### 必須サイズ

- `192x192`: 最小サイズ
- `512x512`: 推奨サイズ

#### 配置場所

```
public/
  ├── icon-192.png
  ├── icon-512.png
  └── favicon.ico
```

---

## 7. テスト戦略

### ユニットテスト（Vitest推奨）

#### インストール

```bash
pnpm add -D vitest @vitest/ui
```

#### `vitest.config.ts` 作成

```typescript
import { defineConfig } from 'vitest/config';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte({ hot: !process.env.VITEST })],
  test: {
    globals: true,
    environment: 'jsdom',
  },
});
```

#### テストファイル例

```typescript
// src/lib/utils.test.ts
import { describe, it, expect } from 'vitest';
import { formatDate } from './utils';

describe('formatDate', () => {
  it('should format date correctly', () => {
    const date = new Date('2024-01-01');
    expect(formatDate(date)).toBe('2024-01-01');
  });
});
```

#### スクリプト追加

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

### コンポーネントテスト

#### インストール

```bash
pnpm add -D @testing-library/svelte @testing-library/jest-dom @testing-library/user-event
```

#### テスト例

```typescript
// src/components/TodoItem.test.ts
import { render, screen, fireEvent } from '@testing-library/svelte';
import { describe, it, expect, vi } from 'vitest';
import TodoItem from './TodoItem.svelte';

describe('TodoItem', () => {
  it('renders todo text', () => {
    const todo = { id: 1, text: 'Test Todo', completed: false };
    render(TodoItem, { todo, onToggle: vi.fn(), onDelete: vi.fn() });
    
    expect(screen.getByText('Test Todo')).toBeInTheDocument();
  });

  it('calls onToggle when checkbox is clicked', async () => {
    const todo = { id: 1, text: 'Test', completed: false };
    const onToggle = vi.fn();
    render(TodoItem, { todo, onToggle, onDelete: vi.fn() });
    
    const checkbox = screen.getByRole('checkbox');
    await fireEvent.click(checkbox);
    
    expect(onToggle).toHaveBeenCalledOnce();
  });
});
```

### E2Eテスト（Playwright推奨）

#### インストール

```bash
pnpm create playwright
```

#### テスト例

```typescript
// e2e/todo.spec.ts
import { test, expect } from '@playwright/test';

test('add new todo', async ({ page }) => {
  await page.goto('http://localhost:5173');
  
  await page.fill('input[placeholder*="新しいタスク"]', 'Test Todo');
  await page.click('button:has-text("追加")');
  
  await expect(page.locator('text=Test Todo')).toBeVisible();
});

test('toggle todo completion', async ({ page }) => {
  await page.goto('http://localhost:5173');
  
  // Add todo
  await page.fill('input[placeholder*="新しいタスク"]', 'Test');
  await page.click('button:has-text("追加")');
  
  // Toggle
  await page.click('input[type="checkbox"]');
  await expect(page.locator('input[type="checkbox"]')).toBeChecked();
});
```

### テストファイル配置

#### オプション1: `__tests__` ディレクトリ

```
src/
├── __tests__/
│   ├── components/
│   │   ├── TodoItem.test.ts
│   │   └── TodoList.test.ts
│   └── lib/
│       └── utils.test.ts
```

#### オプション2: コンポーネントと同階層

```
src/
├── components/
│   ├── TodoItem.svelte
│   ├── TodoItem.test.ts
│   ├── TodoList.svelte
│   └── TodoList.test.ts
```

### テストファイル命名

- `*.test.ts` または `*.spec.ts`
- E2Eテスト: `*.spec.ts` 推奨

---

## 8. ディレクトリ構造

### 推奨構造

```
svelte-pwa-test/
├── .github/
│   └── copilot-instructions.md
├── public/
│   ├── manifest.json
│   ├── icon-192.png
│   ├── icon-512.png
│   └── favicon.ico
├── src/
│   ├── components/          # 再利用可能なコンポーネント
│   │   ├── TodoItem.svelte
│   │   ├── TodoItem.test.ts
│   │   ├── TodoList.svelte
│   │   └── TodoList.test.ts
│   ├── lib/                 # ユーティリティ関数
│   │   ├── utils.ts
│   │   └── utils.test.ts
│   ├── stores/              # グローバルストア（必要に応じて）
│   │   └── user.svelte.ts
│   ├── types/               # 共有型定義
│   │   ├── todo.ts
│   │   └── user.ts
│   ├── __tests__/           # テストファイル（オプション）
│   │   └── integration/
│   ├── App.svelte           # ルートコンポーネント
│   ├── main.ts              # エントリーポイント
│   ├── app.css              # グローバルスタイル
│   └── vite-env.d.ts        # 型定義
├── e2e/                     # E2Eテスト（Playwright）
│   └── todo.spec.ts
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.dev
├── Makefile
├── nginx.conf
├── package.json
├── pnpm-lock.yaml
├── tsconfig.json
├── vite.config.ts
└── vitest.config.ts
```

### 命名規則

#### ファイル・ディレクトリ

- **コンポーネント**: PascalCase
  - `TodoItem.svelte`, `UserProfile.svelte`
- **ユーティリティ**: camelCase
  - `utils.ts`, `formatDate.ts`
- **定数**: UPPER_SNAKE_CASE
  - `CONSTANTS.ts`, `API_ENDPOINTS.ts`
- **ディレクトリ**: lowercase
  - `components/`, `lib/`, `types/`

#### 変数・関数

```typescript
// ✅ 正しい
const MAX_ITEMS = 100;           // 定数: UPPER_SNAKE_CASE
let userName = $state("");        // 変数: camelCase
function getUserById(id: number) {} // 関数: camelCase

interface User {}                 // インターフェース: PascalCase
type UserId = number;             // 型エイリアス: PascalCase

// ❌ 間違い
const maxItems = 100;
let UserName = "";
function GetUserById() {}
```

---

## 9. アクセシビリティ

### セマンティックHTML

#### ボタン vs div

```svelte
<!-- ✅ 正しい -->
<button onclick={handleClick}>クリック</button>

<!-- ❌ 間違い -->
<div onclick={handleClick}>クリック</div>
```

#### 適切なHTML要素の使用

```svelte
<!-- ✅ 正しい -->
<nav>
  <ul>
    <li><a href="/">ホーム</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<main>
  <article>
    <h1>記事タイトル</h1>
    <p>本文...</p>
  </article>
</main>

<footer>
  <p>&copy; 2024</p>
</footer>
```

### ARIA属性

#### スクリーンリーダー対応

```svelte
<!-- アイコンのみのボタン -->
<button onclick={handleDelete} aria-label="削除">
  <TrashIcon />
</button>

<!-- 状態の通知 -->
<div role="status" aria-live="polite">
  {message}
</div>

<!-- ローディング状態 -->
<div aria-busy="true" aria-label="読み込み中...">
  <Spinner />
</div>
```

#### role属性

```svelte
<!-- カスタムコンポーネントにroleを付与 -->
<div role="dialog" aria-labelledby="dialog-title" aria-modal="true">
  <h2 id="dialog-title">確認</h2>
  <p>本当に削除しますか?</p>
</div>
```

### キーボードナビゲーション

#### フォーカス管理

```typescript
// ✅ 正しい
<button tabindex="0" onclick={handleClick}>クリック</button>

// ❌ 間違い: tabindex="-1"は特別な理由がない限り避ける
<button tabindex="-1">クリック</button>
```

#### キーボードイベント

```typescript
function handleKeydown(event: KeyboardEvent) {
  if (event.key === 'Enter' || event.key === ' ') {
    handleClick();
  }
  if (event.key === 'Escape') {
    handleClose();
  }
}

<div 
  role="button" 
  tabindex="0" 
  onkeydown={handleKeydown}
  onclick={handleClick}
>
  カスタムボタン
</div>
```

### カラーコントラスト

#### WCAG AA基準（4.5:1以上）

```css
/* ✅ 正しい: 十分なコントラスト */
.text {
  color: #333;           /* テキスト */
  background: #fff;      /* 背景 */
}

/* ❌ 間違い: コントラスト不足 */
.text-low-contrast {
  color: #ccc;
  background: #fff;
}
```

#### カラーだけに依存しない

```svelte
<!-- ✅ 正しい: アイコンとテキストで状態を表現 -->
<div class:completed={todo.completed}>
  {#if todo.completed}
    <CheckIcon />
  {/if}
  {todo.text}
</div>

<!-- ❌ 間違い: 色だけで状態を表現 -->
<div style="color: {todo.completed ? 'green' : 'black'}">
  {todo.text}
</div>
```

### フォームのラベル

```svelte
<!-- ✅ 正しい -->
<label for="email">メールアドレス</label>
<input id="email" type="email" bind:value={email} />

<!-- または -->
<label>
  メールアドレス
  <input type="email" bind:value={email} />
</label>

<!-- ❌ 間違い: ラベルなし -->
<input type="email" placeholder="メールアドレス" bind:value={email} />
```

---

## 10. パフォーマンス

### バンドルサイズの監視

#### ビルドサイズの確認

```bash
make build
# または
npm run build
```

出力例:
```
dist/assets/index-a1b2c3d4.js  45.23 kB │ gzip: 15.67 kB
dist/assets/index-e5f6g7h8.css  3.21 kB │ gzip: 1.23 kB
```

#### 不要なライブラリの削除

```bash
# 使用されていない依存関係を確認
pnpm prune
```

### 遅延ロード（Dynamic Import）

#### コンポーネントの遅延ロード

```typescript
<script lang="ts">
  import { onMount } from 'svelte';
  
  let HeavyComponent: any;
  
  onMount(async () => {
    const module = await import('./HeavyComponent.svelte');
    HeavyComponent = module.default;
  });
</script>

{#if HeavyComponent}
  <HeavyComponent />
{/if}
```

#### ルーティングでの遅延ロード

```typescript
// Svelte 5でのルーティング例（svelte-routingなど使用）
const routes = [
  { path: '/', component: () => import('./pages/Home.svelte') },
  { path: '/about', component: () => import('./pages/About.svelte') },
];
```

### 画像最適化

#### WebP形式の使用

```html
<!-- ✅ 正しい: WebPとフォールバック -->
<picture>
  <source srcset="/images/hero.webp" type="image/webp">
  <img src="/images/hero.jpg" alt="Hero image">
</picture>
```

#### レスポンシブ画像（srcset）

```html
<img 
  srcset="
    /images/small.jpg 480w,
    /images/medium.jpg 768w,
    /images/large.jpg 1200w
  "
  sizes="(max-width: 480px) 100vw, (max-width: 768px) 50vw, 33vw"
  src="/images/medium.jpg"
  alt="Description"
>
```

#### PWAアイコンサイズ

必須サイズ:
- `192x192`: ホーム画面アイコン
- `512x512`: スプラッシュスクリーン

```json
// manifest.json
{
  "icons": [
    {
      "src": "icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### メモ化と最適化

#### `$derived.by` で重い計算をメモ化

```typescript
// ✅ 正しい: 重い計算は$derived.byでメモ化
let expensiveResult = $derived.by(() => {
  console.log('計算実行'); // 依存値が変更されたときのみ実行
  return items
    .filter(item => item.active)
    .map(item => heavyCalculation(item))
    .sort((a, b) => b.score - a.score);
});

// ❌ 間違い: 毎回計算される
function getExpensiveResult() {
  return items.filter(item => item.active)...;
}
```

#### 不要な再レンダリングを避ける

```svelte
<!-- ✅ 正しい: key属性で最適化 -->
{#each items as item (item.id)}
  <TodoItem {item} />
{/each}

<!-- ❌ 間違い: keyなし（非効率） -->
{#each items as item}
  <TodoItem {item} />
{/each}
```

### Virtual Scrolling（大量データ）

大量のリストアイテムを扱う場合:

```bash
pnpm add svelte-virtual-list
```

```svelte
<script lang="ts">
  import VirtualList from 'svelte-virtual-list';
  
  let items = $state<Item[]>(/* 大量のデータ */);
</script>

<VirtualList items={items} let:item>
  <TodoItem {item} />
</VirtualList>
```

---

## 11. Docker/ビルド規約

### Makeコマンド使用

プロジェクトでは `Makefile` を使用して開発タスクを簡略化しています。

#### 主要コマンド

```bash
# 初回セットアップ
make all

# 開発環境起動
make dev          # Docker優先
make start        # 自動判定

# ビルド
make build        # Docker優先

# 型チェック
make typecheck

# クリーンアップ
make clean        # ビルド成果物削除
make reset        # 完全リセット
```

#### ヘルプ表示

```bash
make help         # すべてのコマンドを表示
```

### 環境変数管理

#### ローカル環境用（`.env.local`）

```bash
# .env.local（Git管理外）
ALLOWED_HOSTS=localhost,your-domain.ngrok-free.dev
```

#### テンプレート（`.env.example`）

```bash
# .env.example（Git管理対象）
ALLOWED_HOSTS=localhost
```

#### 使用方法

```bash
# 初回セットアップ
cp .env.example .env.local

# .env.localを編集
vim .env.local
```

### 本番デプロイ前チェックリスト

#### 1. 型チェック

```bash
make typecheck
```

エラーがないことを確認。

#### 2. ビルド成功確認

```bash
make build
```

`dist/` ディレクトリが正常に生成されることを確認。

#### 3. プレビューで動作確認

```bash
make preview
```

ブラウザで http://localhost:4173 を開いて動作確認。

#### 4. PWA機能の動作確認

- Service Workerが登録されているか（DevTools → Application → Service Workers）
- マニフェストが正しく読み込まれているか（DevTools → Application → Manifest）
- オフラインで動作するか（DevTools → Network → Offline）

#### 5. Lighthouseスコア確認

Chrome DevTools → Lighthouse で以下を確認:
- **Performance**: 90以上
- **Accessibility**: 90以上
- **Best Practices**: 90以上
- **SEO**: 90以上
- **PWA**: すべてのチェック項目を満たす

#### 6. 各種ブラウザでの動作確認

- Chrome/Edge（Chromium）
- Safari（iOS含む）
- Firefox

### Docker環境の使い分け

#### 開発環境（`Dockerfile.dev`）

```bash
# 起動
make dev
# または
docker compose up dev
```

- ホットリロード有効
- ポート: 5173
- ボリュームマウントで即座に変更反映

#### 本番環境（`Dockerfile`）

```bash
# ビルド
docker build -t svelte-pwa-todo .

# 実行
docker run -p 8080:80 svelte-pwa-todo

# または
docker compose up prod
```

- Nginx で静的ファイル配信
- ポート: 80（外部は8080にマップ）
- 最適化されたビルド

---

## 12. Git規約

### コミットメッセージ

#### フォーマット

```
<type>: <subject>

<body>

<footer>
```

#### Type一覧

- `feat`: 新機能の追加
- `fix`: バグ修正
- `style`: コードスタイルの変更（機能に影響なし）
- `refactor`: リファクタリング
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `docs`: ドキュメントの変更
- `chore`: ビルドプロセスやツールの変更
- `ci`: CI/CD設定の変更

#### 例

```
feat: add todo filtering functionality

- Add filter buttons (All, Active, Completed)
- Implement filter logic in TodoList component
- Update localStorage to persist filter state

Closes #123
```

```
fix: prevent duplicate todos on rapid clicks

Added debounce to addTodo function to prevent
multiple submissions when user clicks button rapidly.
```

```
docs: update README with PWA installation instructions

- Add iOS Safari installation steps
- Add Android Chrome installation steps
- Add troubleshooting section
```

### ブランチ戦略

#### ブランチ命名規則

```
<type>/<short-description>
```

例:
- `feature/add-todo-filter`
- `fix/duplicate-todo-bug`
- `refactor/extract-todo-item`
- `docs/update-readme`

#### 主要ブランチ

- **`main`**: 本番環境用の安定版
  - デプロイ可能な状態を常に維持
  - 直接プッシュは禁止

#### 作業フロー

```bash
# 1. 最新のmainを取得
git checkout main
git pull origin main

# 2. 作業ブランチを作成
git checkout -b feature/add-filter

# 3. 作業を進める
git add .
git commit -m "feat: implement filter logic"

# 4. リモートにプッシュ
git push origin feature/add-filter

# 5. プルリクエストを作成

# 6. レビュー後、mainにマージ

# 7. 作業ブランチを削除
git branch -d feature/add-filter
```

### .gitignoreの管理

#### 必須項目

```gitignore
# 依存関係
node_modules/
pnpm-lock.yaml  # プロジェクトによる

# ビルド成果物
dist/
.svelte-kit/

# 環境変数
.env.local
.env*.local

# エディタ
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore
```

---

## 13. セキュリティ

### 環境変数の管理

#### 秘密情報を含めない

```typescript
// ❌ 間違い: APIキーをコードに直接記述
const API_KEY = 'sk-1234567890abcdef';

// ✅ 正しい: 環境変数から読み込む
const API_KEY = import.meta.env.VITE_API_KEY;
```

#### 環境変数の型定義

```typescript
// src/vite-env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_API_KEY: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

### XSS対策

#### ユーザー入力のサニタイズ

```svelte
<!-- ✅ 正しい: Svelteが自動エスケープ -->
<p>{userInput}</p>

<!-- ❌ 危険: @html は信頼できる内容のみ -->
<p>{@html userInput}</p>

<!-- ✅ 正しい: @htmlを使う場合はサニタイズ -->
<script>
  import DOMPurify from 'dompurify';
  let sanitized = DOMPurify.sanitize(userInput);
</script>
<p>{@html sanitized}</p>
```

### CORS設定

#### 開発環境のみ有効化

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    cors: process.env.NODE_ENV === 'development',
  }
});
```

### 依存関係の脆弱性チェック

```bash
# 脆弱性スキャン
pnpm audit

# 修正可能な脆弱性を自動修正
pnpm audit --fix

# 依存関係の更新
pnpm update
```

---

## 14. まとめ

このガイドラインに従うことで、以下を実現できます:

✅ **Svelte 5の最新機能を最大限活用**
- Runes構文で明確なリアクティビティ
- 型安全なTypeScript開発

✅ **高品質なコード**
- Prettier/ESLintで統一されたスタイル
- 包括的なテスト（Unit/Component/E2E）

✅ **優れたユーザー体験**
- PWAによるオフライン対応
- アクセシビリティ対応
- 高速なパフォーマンス

✅ **効率的な開発**
- Makeコマンドで簡略化されたタスク
- Dockerで統一された開発環境
- 明確なGit規約

### 参考リンク

- [Svelte 5 公式ドキュメント](https://svelte.dev/docs/svelte/overview)
- [Svelte 5 Runes](https://svelte.dev/docs/svelte/what-are-runes)
- [vite-plugin-pwa](https://vite-pwa-org.netlify.app/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vitest](https://vitest.dev/)
- [Playwright](https://playwright.dev/)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

---

**最終更新日**: 2024年11月25日