import path from "node:path";
import process from "node:process";
import { defineConfig } from "vite";

const host = process.env.TAURI_DEV_HOST;
const repoRoot = path.resolve(__dirname, "..");

export default defineConfig({
  clearScreen: false,
  resolve: {
    alias: {
      "@yearbar/core": path.resolve(repoRoot, "core/src/time.ts"),
    },
  },
  server: {
    port: 1420,
    strictPort: true,
    host: host || false,
    fs: {
      allow: [repoRoot],
    },
    hmr: host
      ? {
          protocol: "ws",
          host,
          port: 1421,
        }
      : undefined,
    watch: {
      ignored: ["**/src-tauri/**"],
    },
  },
});
