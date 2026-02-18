diff --git a/Dockerfile b/Dockerfile
index a6acb710ec85eb7b64a702ac5c089ae83f024739..116556093d3eb1aa4a82aff6a5466db13b9dc619 100644
--- a/Dockerfile
+++ b/Dockerfile
@@ -1,17 +1,22 @@
-FROM node:latest
+FROM node:22-bookworm-slim
 
 WORKDIR /app
 
-COPY . /app/
+# Use Corepack-managed pnpm for reproducible CI builds.
+RUN corepack enable && corepack prepare pnpm@10.30.0 --activate
 
-COPY package*.json /app/
+# Install dependencies first for improved layer caching.
+COPY package.json pnpm-lock.yaml ./
+RUN pnpm install --frozen-lockfile
 
-RUN npm install -g pnpm
+# Copy source after dependencies are installed.
+COPY . .
 
-RUN pnpm install
+# Ensure @rubynetwork/rh cache directory exists for environments where install scripts are blocked.
+RUN sh -c "for d in node_modules/.pnpm/@rubynetwork+rh@*/node_modules/@rubynetwork/rh; do [ -d \"$d\" ] && mkdir -p \"$d/cache-js\"; done"
 
 RUN pnpm run build
 
 EXPOSE 8080
 
 CMD ["pnpm", "start"]
