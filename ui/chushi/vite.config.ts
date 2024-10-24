import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: "/app/",
  build: {
    outDir: '../../public/app',
    emptyOutDir: true, // also necessary
    minify: false
  }
})
