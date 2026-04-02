# Use Node.js LTS
FROM node:20-slim

WORKDIR /app

# Copia tudo (package.json, src, scripts, tsconfig.json etc.)
COPY . .

# Instala TODAS as dependências (incluindo devDependencies para fazer o build)
RUN npm ci --include=dev

# Executa o build completo (typecheck + scripts/build.js)
RUN npm run build

# Remove as devDependencies para deixar a imagem leve
RUN npm ci --omit=dev --ignore-scripts

# Diretório de configuração (onde vão ficar os tokens)
RUN mkdir -p /config

ENV NODE_ENV=production
ENV GOOGLE_DRIVE_OAUTH_CREDENTIALS=/config/gcp-oauth.keys.json
ENV GOOGLE_DRIVE_MCP_TOKEN_PATH=/config/tokens.json

RUN chmod +x dist/index.js

# Roda como usuário não-root por segurança
USER node

ENTRYPOINT ["node", "dist/index.js"]
