# -------- STAGE 1: Build --------
FROM node:20-alpine AS builder

RUN apk add --no-cache libc6-compat

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

# -------- STAGE 2: Runtime --------
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

# Copiar solo lo necesario para correr la app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY package.json ./

EXPOSE 3000

CMD ["node", "dist/main.js"]
