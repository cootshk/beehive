FROM node:18.13-alpine

WORKDIR /app

COPY . .

RUN npm install -g pnpm@9.15.1
RUN pnpm install --frozen-lockfile

ENV NODE_ENV=production

RUN pnpm run build
CMD ["node", "/app/.output/server/index.mjs"]

LABEL org.opencontainers.image.source=https://github.com/Team-Resourceful/beehive
LABEL org.opencontainers.image.description="Beehive"
LABEL org.opencontainers.image.licenses=AGPL-3.0
