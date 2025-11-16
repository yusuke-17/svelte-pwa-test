import { defineConfig, loadEnv } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig(({ mode }) => {
  // 環境変数を読み込む
  const env = loadEnv(mode, process.cwd(), '');
  
  return {
    plugins: [
      svelte(),
      VitePWA({
        registerType: 'autoUpdate',
        includeAssets: ['favicon.ico', 'icon-192.png', 'icon-512.png'],
        manifest: {
          name: 'Svelte PWA Todo',
          short_name: 'Todo PWA',
          description: 'A simple PWA todo app built with Svelte 5',
          theme_color: '#ff3e00',
          background_color: '#ffffff',
          display: 'standalone',
          icons: [
            {
              src: 'icon-192.png',
              sizes: '192x192',
              type: 'image/png'
            },
            {
              src: 'icon-512.png',
              sizes: '512x512',
              type: 'image/png'
            }
          ]
        },
        workbox: {
          globPatterns: ['**/*.{js,css,html,ico,png,svg}']
        }
      })
    ],
    server: {
      // 開発環境のみ0.0.0.0、それ以外はlocalhost
      host: process.env.NODE_ENV === 'development' ? '0.0.0.0' : 'localhost',
      port: 5173,
      strictPort: true,
      hmr: {
        clientPort: 443,
        protocol: 'wss'
      },
      // 開発環境のみCORSを有効化
      cors: process.env.NODE_ENV === 'development',
      // 環境変数で指定、デフォルトはlocalhostのみ
      allowedHosts: env.ALLOWED_HOSTS 
        ? env.ALLOWED_HOSTS.split(',')
        : ['localhost']
    }
  };
});
