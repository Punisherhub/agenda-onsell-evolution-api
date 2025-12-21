# ⚡ Guia Rápido: Downgrade v2.2.3 → v2.0.10

## 🎯 Problema
Evolution API v2.2.3 (latest) criou 30 tabelas com ENUMs que impedem downgrade para v2.0.10.

## ✅ Solução em 2 Passos

---

### 📝 PASSO 1: Limpar Schema Evolution

Execute o script SQL no banco de dados:

```bash
psql "$DATABASE_URL" < LIMPAR_SCHEMA_EVOLUTION.sql
```

**Ou via Render Dashboard**:
1. Render Dashboard → PostgreSQL → Shell
2. Copie e cole o conteúdo de `LIMPAR_SCHEMA_EVOLUTION.sql`
3. Execute

**O que faz:**
- ✅ Deleta schema `evolution` (30 tabelas da v2.2.3)
- ✅ Recria schema `evolution` vazio
- ✅ Restaura permissões
- ✅ Schema `public` (AgendaOnSell) permanece 100% INTACTO

**Resultado esperado:**
```
✅ Schema evolution: VAZIO (pronto para v2.0.10)
✅ Schema public: INTACTO (AgendaOnSell preservado)
```

---

### 🚀 PASSO 2: Deploy no Render

1. **No Render Dashboard**:
   - Evolution API → Manual Deploy → Deploy latest commit

2. **Logs esperados (SUCESSO)**:
   ```
   🚀 Iniciando Evolution API (DEBUG MODE)
   📦 Node version: v20.16.0
   ✅ DATABASE_URL encontrada com schema isolado

   🔨 Aplicando Migrations do Prisma
   Prisma schema loaded from prisma/postgresql-schema.prisma
   Datasource "db": PostgreSQL database "agenda_db", schema "evolution" at "dpg-..."

   🚀  Your database is now in sync with your Prisma schema. Done in 2.5s

   ✅ SUCESSO: Schema Evolution API sincronizado!

   📋 Schema 'evolution' (Evolution API):
      • Instance, Message, Contact, Chat
      • Webhook, Session, MessageUpdate
      • _prisma_migrations

   🎯 Iniciando servidor Evolution API
   [Evolution API]    v2.0.10  ...
   Repository:Prisma - ON
   Server started on port 8080  ✅
   ```

3. **Teste final**:
   ```bash
   curl https://seu-servico.onrender.com
   # Deve retornar: {"status":"ok","version":"2.0.10"}
   ```

---

## 📊 Comparação: Antes vs Depois

| Item | v2.2.3 (latest) | v2.0.10 (estável) |
|------|-----------------|-------------------|
| Tabelas | 30 | 8-10 |
| ENUMs | Muitos (conflitantes) | Poucos (estáveis) |
| Status | ❌ Crasha na inicialização | ✅ Funciona |
| Tamanho | ~438KB main.js | ~352KB main.js |

---

## 🔍 Troubleshooting

### Erro: "permission denied for schema evolution"
```sql
GRANT ALL ON SCHEMA evolution TO sasconv_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA evolution GRANT ALL ON TABLES TO sasconv_user;
```

### Erro: "schema evolution does not exist" (ao executar script)
Normal! O script cria o schema se não existir.

### Servidor ainda crasha
Verifique:
1. `DATABASE_URL` tem `&schema=evolution`?
2. `AUTHENTICATION_API_KEY` está definido?
3. Logs mostram "v2.0.10" (não "v2.2.3")?

---

## ⏱️ Tempo Total
- Passo 1 (SQL): ~30 segundos
- Passo 2 (Deploy): ~5 minutos
- **Total**: ~6 minutos

---

**Última Atualização**: 2025-12-21
**Status**: 🟢 Solução Testada
