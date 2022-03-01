import path from "path";
import viteCompression from "vite-plugin-compression";
import eslintPlugin from "vite-plugin-eslint";

const config = (mode) => ({
    plugins: [
        viteCompression({ filter: /\.(js|css|map)$/, algorithm: "gzip", ext: ".gz" }),
        viteCompression({ filter: /\.(js|css|map)$/, algorithm: "brotliCompress", ext: ".br" }),
        eslintPlugin({ cache: true }),
    ],

    sourcemap: mode === "development",

    build: {
        outDir: "build",
        assetDir: "./assets",
        sourcemap: mode === "development",
        minify: !mode === "development",
        brotliSize: false,
        emptyOutDir: true,
    },

    optimizeDeps: {
        allowNodeBuiltins: false,
    },

    server: {
        proxy: {
            // Allows us to run the proxy server independent of the content, and still
            // get full-service.
        },
    },
});

export default config;
