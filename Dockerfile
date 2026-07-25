# 1. Estágio de build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev
COPY src/ ./src/

# 2. Estágio final
FROM node:20-alpine

WORKDIR /app

# Requisito obrigatório: copia apenas o necessário do estágio anterior
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/src ./src

# CORREÇÃO: Cria a pasta do SQLite e altera o dono para o usuário node
USER root
RUN mkdir -p /etc/todos && chown -R node:node /etc/todos /app

# Requisito obrigatório: Porta interna 3000 e usuário não-root
EXPOSE 3000
USER node

# Comando de inicialização oficial
CMD ["node", "src/index.js"]
