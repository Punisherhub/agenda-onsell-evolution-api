# Evolution API - Dockerfile para Deploy no Render
# Usando v2.0.10 (versão estável) - latest v2.2.3 tem bug de inicialização
FROM atendai/evolution-api:v2.0.10

# Criar diretórios necessários
RUN mkdir -p /evolution/instances /evolution/store

# CRÍTICO: Remover arquivo .env interno que sobrescreve variáveis do Render
RUN rm -f /evolution/.env /evolution/.env.* || true

# Copiar scripts customizados
COPY start-debug.sh /evolution/start.sh
COPY db-deploy.sh /evolution/db-deploy.sh
RUN chmod +x /evolution/start.sh /evolution/db-deploy.sh

# CRÍTICO: Sobrescrever os scripts no package.json
# para usar nossa lógica que suporta banco compartilhado (P3005)
WORKDIR /evolution
RUN npm pkg set scripts.db:deploy="/evolution/db-deploy.sh"
RUN npm pkg set scripts.start:prod="/evolution/start.sh"

# Expor porta
EXPOSE 8080

# Healthcheck desabilitado temporariamente para debug de timeout
# HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=3 \
#   CMD curl -f http://localhost:8080 || exit 1

# Usar script customizado que verifica DATABASE_URL antes de rodar migrations
ENTRYPOINT ["/bin/bash", "/evolution/start.sh"]
