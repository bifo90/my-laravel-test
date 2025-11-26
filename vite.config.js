import { defineConfig } from "vite";
import laravel from "laravel-vite-plugin";
import tailwindcss from "@tailwindcss/vite";

const port = 5173;
export default defineConfig({
    plugins: [
        laravel({
            input: ["resources/css/app.css", "resources/js/app.js"],
            refresh: true,
        }),
        tailwindcss(),
    ],
    server: {
        cors: true,
        host: "0.0.0.0",
        strictPort: true,
        origin: `${process.env.DDEV_PRIMARY_URL}:${port}`,
        port,
    },
});
