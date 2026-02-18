
FROM node:22-bookworm-slim
 
 WORKDIR /app
 

# Use Corepack-managed pnpm for reproducible CI builds.
RUN corepack enable && corepack prepare pnpm@10.30.0 --activate
 

# Install dependencies first for improved layer caching.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile
 

# Copy source after dependencies are installed.
COPY . .
 

# Ensure @rubynetwork/rh cache directory exists for environments where install scripts are blocked.
RUN sh -c 'for d in node_modules/.pnpm/@rubynetwork+rh@*/node_modules/@rubynetwork/rh; do if [ -d "$d" ]; then mkdir -p "$d/cache-js" "$d/public" "$d/sessions"; fi; done'
 
 RUN pnpm run build
 
 EXPOSE 8080
 
 CMD ["pnpm", "start"]
