// import { defineConfig } from "vite";
// import react from "@vitejs/plugin-react-swc";
// import path from "path";
// import { componentTagger } from "lovable-tagger";

// // https://vitejs.dev/config/
// export default defineConfig(({ mode }) => ({
//   server: {
//     host: "::",
//     port: 8080,
//     hmr: {
//       port: 8080,
//     },
//   },
//   plugins: [
//     react(),
//     mode === 'development' &&
//     componentTagger(),
//   ].filter(Boolean),
//   resolve: {
//     alias: {
//       "@": path.resolve(__dirname, "./src"),
//     },
//   },
//   build: {
//     // Enable code splitting and chunk optimization
//     rollupOptions: {
//       output: {
//         // Manual chunk splitting for better caching - only include packages that exist
//         manualChunks: {
//           vendor: ['react', 'react-dom', 'react-router-dom'],
//           ui: ['@radix-ui/react-dialog', '@radix-ui/react-select', '@radix-ui/react-slot'],
//           supabase: ['@supabase/supabase-js'],
//           query: ['@tanstack/react-query'],
//           icons: ['lucide-react'],
//         },
//         // Add cache-busting hashes to filenames
//         chunkFileNames: 'assets/[name]-[hash].js',
//         entryFileNames: 'assets/[name]-[hash].js',
//         assetFileNames: 'assets/[name]-[hash].[ext]'
//       }
//     },
//     // Enable minification and compression
//     minify: 'terser',
//     terserOptions: {
//       compress: {
//         drop_console: mode === 'production',
//         drop_debugger: mode === 'production',
//       }
//     },
//     // Increase chunk size warning limit
//     chunkSizeWarningLimit: 1000,
//     // Enable source maps for production debugging (optional)
//     sourcemap: mode === 'development'
//   },
//   // Configure dev server headers for caching during development
//   preview: {
//     headers: {
//       'Cache-Control': 'public, max-age=7200', // 1 year cache for static assets
//     }
//   }
// }));

import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import path from "path";
import { componentTagger } from "lovable-tagger";

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => ({
  server: {
    host: "0.0.0.0",
    port: 8080,
    strictPort: true,
  },
  plugins: [react(), mode === "development" && componentTagger()].filter(
    Boolean
  ),
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  build: {
    // Enable minification and compression
    minify: "terser",
    terserOptions: {
      compress: {
        drop_console: mode === "production",
        drop_debugger: mode === "production",
      },
    },
    // Increase chunk size warning limit
    chunkSizeWarningLimit: 1000,
    // Enable source maps for production debugging (optional)
    sourcemap: mode === "development",
  },
  preview: {
    host: "0.0.0.0",
    port: 8080,
    strictPort: true,
  },
}));
