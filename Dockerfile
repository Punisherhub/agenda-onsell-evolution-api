# Evolution API - Dockerfile para Deploy no Render
FROM atendai/evolution-api:v2.1.1

# Configurações de ambiente serão injetadas pelo Render
# Não é necessário configurar nada aqui, tudo via variáveis de ambiente

# Criar diretórios necessários
RUN mkdir -p /evolution/instances /evolution/store

# Expor porta
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1

# O comando de start já vem da imagem base
CMD ["node", "./dist/src/main.js"]
