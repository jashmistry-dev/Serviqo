import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    port: 5174,
    strictPort: true, // Fail if 5174 is taken rather than auto-picking another port
    host: 'localhost',
  },
  preview: {
    port: 5174,
  },
})
