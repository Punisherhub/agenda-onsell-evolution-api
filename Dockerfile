# Evolution API - Dockerfile para Deploy no Render
FROM atendai/evolution-api:v2.1.1

# Criar diretórios necessários
RUN mkdir -p /evolution/instances /evolution/store

# CRÍTICO: Remover arquivo .env interno que sobrescreve variáveis do Render
RUN rm -f /evolution/.env /evolution/.env.* || true

# Copiar scripts customizados
COPY start.sh /evolution/start.sh
COPY db-deploy.sh /evolution/db-deploy.sh
RUN chmod +x /evolution/start.sh /evolution/db-deploy.sh

# CRÍTICO: Sobrescrever o script db:deploy no package.json
# para usar nossa lógica que suporta banco compartilhado (P3005)
WORKDIR /evolution
RUN npm pkg set scripts.db:deploy="/evolution/db-deploy.sh"

# Expor porta
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1

# Usar script customizado que verifica DATABASE_URL antes de rodar migrations
CMD ["/evolution/start.sh"]
