# Use Node.js LTS
FROM node:20-slim

WORKDIR /app

# Copia tudo (incluindo tsconfig, src, scripts etc.)
COPY . .

# Instala TODAS as dependências (precisa do typescript + scripts de build)
RUN npm ci --include=dev

# Faz o build completo (typecheck + scripts/build.js)
RUN npm run build

# Agora remove as devDependencies para deixar a imagem leve
RUN npm ci --omit=dev --ignore-scripts

# Diretório de configuração
RUN mkdir -p /config

ENV NODE_ENV=production
ENV GOOGLE_DRIVE_OAUTH_CREDENTIALS=/config/gcp-oauth.keys.json
ENV GOOGLE_DRIVE_MCP_TOKEN_PATH=/config/tokens.json

RUN chmod +x dist/index.js

# Roda como usuário não-root
USER node

ENTRYPOINT ["node", "dist/index.js"]
