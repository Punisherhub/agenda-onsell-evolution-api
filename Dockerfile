# Evolution API - Dockerfile para Deploy no Render
FROM atendai/evolution-api:v2.1.1

# Criar diretórios necessários
RUN mkdir -p /evolution/instances /evolution/store

# CRÍTICO: Remover arquivo .env interno que sobrescreve variáveis do Render
RUN rm -f /evolution/.env /evolution/.env.* || true

# Copiar script de inicialização customizado
COPY start.sh /evolution/start.sh
RUN chmod +x /evolution/start.sh

# Expor porta
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1

# Usar script customizado que verifica DATABASE_URL antes de rodar migrations
CMD ["/evolution/start.sh"]
