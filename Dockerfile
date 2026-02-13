# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY index.ts auth.ts ./
COPY tools/ tools/

RUN npm run build

# Run stage
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

# Credentials dir can be mounted at runtime (e.g. -v ./creds:/app/creds)
ENV GDRIVE_CREDS_DIR=/app/creds

EXPOSE 8080

# mcp-proxy converts stdio MCP server to streamable HTTP + SSE; --tunnel exposes via public URL
CMD ["npx", "mcp-proxy", "--port", "8080", "--tunnel", "--", "node", "./dist/index.js"]
