FROM node:20-slim

WORKDIR /app

# Copia todo o código + os dois ficheiros de autenticação
COPY . .

# Instala todas as dependências (incluindo dev para fazer build)
RUN npm ci --include=dev

# Faz o build
RUN npm run build

# Remove devDependencies para deixar leve
RUN npm ci --omit=dev --ignore-scripts

# Cria pasta de config e copia os ficheiros para lá
RUN mkdir -p /config
COPY gcp-oauth.keys.json /config/gcp-oauth.keys.json
COPY tokens.json /config/tokens.json

# Protege os ficheiros (só o owner pode ler)
RUN chmod 600 /config/gcp-oauth.keys.json /config/tokens.json

# Variáveis de ambiente
ENV NODE_ENV=production
ENV GOOGLE_DRIVE_OAUTH_CREDENTIALS=/config/gcp-oauth.keys.json
ENV GOOGLE_DRIVE_MCP_TOKEN_PATH=/config/tokens.json
ENV MCP_TRANSPORT=http
ENV MCP_HTTP_HOST=0.0.0.0
ENV MCP_HTTP_PORT=3000

EXPOSE 3000

USER node

ENTRYPOINT ["node", "dist/index.js"]
CMD ["start", "--transport", "http", "--host", "0.0.0.0", "--port", "3000"]
