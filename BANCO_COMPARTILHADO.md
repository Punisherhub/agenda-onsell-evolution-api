# 📊 Banco de Dados Compartilhado - AgendaOnSell + Evolution API

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│  PostgreSQL: agenda_db (Render.com)                         │
│  Host: dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  📁 Tabelas do AgendaOnSell (Backend FastAPI):               │
│  ├── empresas                                                │
│  ├── estabelecimentos                                        │
│  ├── users                                                   │
│  ├── clientes                                                │
│  ├── servicos                                                │
│  ├── agendamentos                                            │
│  ├── materiais                                               │
│  ├── consumos_materiais                                      │
│  ├── configuracao_fidelidade                                 │
│  ├── premios                                                 │
│  ├── resgates_premios                                        │
│  └── whatsapp_configs                                        │
│                                                               │
│  📁 Tabelas da Evolution API (WhatsApp):                     │
│  ├── Instance          (instâncias WhatsApp)                 │
│  ├── Message           (mensagens enviadas/recebidas)        │
│  ├── Contact           (contatos do WhatsApp)                │
│  ├── Chat              (conversas)                           │
│  ├── MessageUpdate     (atualizações de mensagens)           │
│  ├── Webhook           (webhooks configurados)               │
│  ├── Session           (sessões de conexão)                  │
│  └── _prisma_migrations (controle de versões Evolution)      │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Vantagens do Banco Compartilhado

1. **Custo Zero** - Um único banco PostgreSQL (Free tier do Render)
2. **Integração Direta** - Possibilidade de JOINs entre tabelas do sistema
3. **Backup Único** - Um único backup contém tudo
4. **Simplificado** - Menos recursos para gerenciar
5. **Queries Cross-System** - Backend pode consultar dados do WhatsApp diretamente

## ⚠️ Pontos de Atenção

1. **Naming Conflicts** - Cuidado com nomes de tabelas duplicados
   - ✅ **OK**: Evolution usa nomes em PascalCase (`Instance`, `Message`)
   - ✅ **OK**: AgendaOnSell usa snake_case (`agendamentos`, `clientes`)
   - ✅ **Sem conflito!**

2. **Migrations Independentes**
   - Backend AgendaOnSell: Alembic (Python)
   - Evolution API: Prisma (Node.js)
   - ✅ Ambos podem coexistir sem problemas

3. **Schema Público**
   - Ambos usam schema `public` (padrão PostgreSQL)
   - ✅ Compatível

## 🔧 Como Funciona o Deploy

### Primeira Vez (Banco Não Vazio - P3005):

1. **Evolution API tenta rodar migrations**
   ```
   npm run db:deploy
   ```

2. **Prisma detecta banco não vazio**
   ```
   Error: P3005 - The database schema is not empty
   ```

3. **start.sh detecta P3005 e usa fallback**
   ```bash
   # Aplica schema sem rodar migrations
   prisma db push --skip-generate --accept-data-loss
   ```

4. **Prisma cria APENAS tabelas da Evolution API**
   - Verifica quais tabelas já existem
   - Cria apenas as que faltam (Instance, Message, etc.)
   - **NÃO toca** nas tabelas do AgendaOnSell

5. **Servidor inicia normalmente**

### Próximos Deploys (Banco Já Configurado):

1. Prisma verifica schema
2. Aplica apenas novas migrations (se houver)
3. Servidor inicia

## 📋 Estrutura Final do Banco

Após deploy bem-sucedido, o banco `agenda_db` terá:

```sql
-- Tabelas do AgendaOnSell (12 tabelas)
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
  'empresas', 'estabelecimentos', 'users', 'clientes',
  'servicos', 'agendamentos', 'materiais', 'consumos_materiais',
  'configuracao_fidelidade', 'premios', 'resgates_premios',
  'whatsapp_configs'
);

-- Tabelas da Evolution API (~8 tabelas)
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
AND tablename LIKE '%Message%' OR tablename LIKE '%Instance%';

-- Total: ~20 tabelas compartilhando o mesmo banco
```

## 🚀 Deploy Passo a Passo

### 1. Commit as Mudanças

```bash
cd evolution-api
git add start.sh
git commit -m "Fix: Support shared database with AgendaOnSell (P3005 baseline)"
git push
```

### 2. Redeploy no Render

- Render Dashboard → Serviço **agenda-onsell-evolution-api**
- **Manual Deploy** → **Deploy latest commit**
- Aguarde ~5-10 minutos

### 3. Verificar Logs de Sucesso

Procure por estas mensagens:

```
✅ === Iniciando Evolution API ===
✅ Removendo arquivos .env locais...
✅ DATABASE_URL encontrada: postgresql://***@dpg-d2195c6uk2gs7380vemg-a...
✅ Variáveis exportadas
✅ Executando migrations do Prisma...

⚠️ Banco compartilhado detectado (P3005)
📊 Aplicando schema da Evolution API ao banco existente agenda_db...
✅ As tabelas do AgendaOnSell não serão afetadas

Prisma schema loaded from prisma/postgresql-schema.prisma
Datasource "db": PostgreSQL database "agenda_db"...
🚀 The database is now in sync with the Prisma schema.

✅ Schema da Evolution API aplicado com sucesso!
📋 Tabelas criadas: Instance, Message, Webhook, Chat, Contact, etc.

✅ Migrations executadas com sucesso!
✅ Iniciando servidor Evolution API na porta 8080...
```

### 4. Testar a API

```bash
curl https://sua-url.onrender.com

# Resposta esperada:
# {"status":"ok","version":"2.1.1"}
```

## ✅ Checklist Final

- [ ] `start.sh` atualizado com lógica de banco compartilhado
- [ ] Commit feito e pushed
- [ ] Redeploy iniciado no Render
- [ ] Logs mostram "Banco compartilhado detectado (P3005)"
- [ ] Logs mostram "Schema da Evolution API aplicado com sucesso"
- [ ] Servidor iniciado na porta 8080
- [ ] Teste com curl retorna `{"status":"ok"}`
- [ ] Tabelas da Evolution API criadas no banco
- [ ] Tabelas do AgendaOnSell intactas

## 🔍 Verificar Tabelas Criadas

Para verificar se tudo foi criado corretamente, você pode conectar ao banco via `psql`:

```bash
# Conectar ao banco (use a DATABASE_URL)
psql "postgresql://sasconv_user:d5DezoH9fkvGQvAldNebbIAU0FWcm4Fe@dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com:5432/agenda_db?sslmode=require"

# Listar todas as tabelas
\dt

# Deve mostrar:
# - Tabelas do AgendaOnSell (empresas, estabelecimentos, users, etc.)
# - Tabelas da Evolution API (Instance, Message, Contact, etc.)
```

## 🎯 Resultado Final

**Um único banco PostgreSQL (`agenda_db`) servindo:**
- ✅ Backend AgendaOnSell (FastAPI + SQLAlchemy)
- ✅ Evolution API (Node.js + Prisma)
- ✅ Sem conflitos
- ✅ Sem custos adicionais
- ✅ Arquitetura limpa e integrada

---

**Última atualização:** 2025-12-19
**Status:** ✅ Configurado para banco compartilhado
