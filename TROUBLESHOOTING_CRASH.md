# 🔧 TROUBLESHOOTING: Evolution API Crashing Silenciosamente

## 🔴 Problema

Deploy inicia mas crasha sem mostrar erros nos logs.

## 🎯 Duas Soluções para Testar

---

## ✅ SOLUÇÃO 1: Debug Mode (Recomendado Primeiro)

Ativar logs detalhados para ver **EXATAMENTE** onde está crashando.

### Passo 1: Modificar Dockerfile

Abra `evolution-api/Dockerfile` e altere a linha 12:

**ANTES:**
```dockerfile
COPY start.sh /evolution/start.sh
```

**DEPOIS:**
```dockerfile
COPY start-debug.sh /evolution/start.sh
```

### Passo 2: Commit e Deploy

```bash
cd C:\dev\AgendaOnSell

git add evolution-api/start-debug.sh evolution-api/Dockerfile
git commit -m "debug: Add verbose logging to Evolution API startup"
git push
```

### Passo 3: Deploy e Observar Logs

No Render Dashboard:
1. Manual Deploy → Deploy latest commit
2. Vá em **Logs**
3. **AGUARDE** e leia TODOS os logs

### O que você verá:

#### ✅ Se der certo:
```
🚀 Iniciando Evolution API (DEBUG MODE)
📂 Workdir: /evolution
📦 Node version: v20.x.x
🗑️  Removendo arquivos .env locais...
✅ DATABASE_URL encontrada
📊 Banco: dpg-xxx.virginia-postgres.render.com
📋 Variáveis de ambiente exportadas:
   • DATABASE_PROVIDER: postgresql
   • DATABASE_ENABLED: true
   • SERVER_PORT: 8080
🔨 Aplicando Migrations do Prisma
✅ SUCESSO: Schema Evolution API sincronizado!
🎯 Iniciando servidor Evolution API
[Evolution API] Server started on port 8080
```

#### ❌ Se crashar:
```
❌ SERVIDOR CRASHOU!
Exit code: 1
TypeError: Cannot read properties of undefined (reading 'listen')
    at /evolution/dist/main.js:286:15
    ...
```

**COPIE TODO O LOG E ME MOSTRE!** Com isso saberei exatamente o que falta.

---

## ✅ SOLUÇÃO 2: Versão Estável (Se Solução 1 não funcionar)

Usar uma versão **específica e testada** ao invés de `latest`.

### Passo 1: Renomear Dockerfiles

```bash
cd C:\dev\AgendaOnSell\evolution-api

# Fazer backup do Dockerfile atual
mv Dockerfile Dockerfile.latest

# Usar versão estável
mv Dockerfile.stable Dockerfile
```

### Passo 2: Commit e Deploy

```bash
git add evolution-api/Dockerfile evolution-api/Dockerfile.latest
git commit -m "fix: Use stable Evolution API version v2.0.10"
git push
```

### Por que isso pode resolver?

A versão `latest` pode ter:
- ✅ Mais funcionalidades (30 tabelas)
- ❌ Bugs não corrigidos
- ❌ Mudanças incompatíveis

A versão `v2.0.10` é:
- ✅ Estável e testada
- ✅ Menos tabelas (~8-10)
- ✅ Mais leve e rápida

---

## 🔍 Variáveis de Ambiente Críticas

Verifique se TODAS estão configuradas no Render:

### ⚠️ OBRIGATÓRIAS (podem causar crash se faltarem):

```bash
DATABASE_URL=postgresql://user:pass@host:5432/db?sslmode=require&schema=evolution
AUTHENTICATION_API_KEY=sua_chave_forte_aqui
SERVER_URL=https://seu-servico.onrender.com
```

### ✅ IMPORTANTES (com defaults):

```bash
SERVER_PORT=8080
DATABASE_ENABLED=true
DATABASE_PROVIDER=postgresql
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
```

### 🔧 ESPECÍFICAS (versão latest precisa):

```bash
# Se usar integrações
OPENAI_API_KEY=sk-...  (se usar ChatGPT)
TYPEBOT_API_KEY=...    (se usar Typebot)
CHATWOOT_ACCOUNT_ID=...  (se usar Chatwoot)

# Se não usar, defina como false:
PROVIDER_ENABLED=false
WEBSOCKET_ENABLED=false
```

---

## 📋 Checklist de Debug

Antes de pedir ajuda, verifique:

- [ ] `start-debug.sh` está sendo usado no Dockerfile
- [ ] Commit feito e push realizado
- [ ] Deploy completou (sem erros de build)
- [ ] Logs completos copiados (desde "🚀 Iniciando" até crash/sucesso)
- [ ] DATABASE_URL tem `&schema=evolution` no final
- [ ] AUTHENTICATION_API_KEY está definido (não vazio)
- [ ] Versão do Node visível nos logs (`📦 Node version`)

---

## 🆘 Se Nada Funcionar

### Opção 1: Deploy Local para Testar

```bash
cd evolution-api

# Criar .env local
cp .env.example .env

# Editar .env com DATABASE_URL real do Render
nano .env

# Rodar localmente
docker-compose up
```

Se funcionar localmente = problema é com Render.
Se crashar localmente = problema é configuração.

### Opção 2: Usar Evolution API Oficial (Sem Docker Customizado)

1. **Deletar o serviço atual** no Render
2. **Criar novo serviço** usando imagem oficial diretamente:
   - Runtime: Docker
   - Docker Command: `docker run atendai/evolution-api:v2.0.10`
   - Configurar variáveis de ambiente

### Opção 3: Pedir Suporte

Abra issue no GitHub do Evolution API:
https://github.com/EvolutionAPI/evolution-api/issues

Com:
- Logs completos do deploy
- Versão usada (latest ou v2.0.10)
- Variáveis de ambiente (SEM senhas!)

---

## 📚 Versões Estáveis Testadas

Se `v2.0.10` não funcionar, tente estas:

| Versão | Data | Estabilidade | Funcionalidades |
|--------|------|--------------|-----------------|
| v2.0.10 | Nov 2024 | ⭐⭐⭐⭐⭐ | WhatsApp + Chatbots básicos |
| v2.1.0 | Dez 2024 | ⭐⭐⭐⭐ | + Typebot, Flowise |
| v2.1.1 | Dez 2024 | ⭐⭐⭐ | + Dify (bug P3005 conhecido) |
| latest | Rolling | ⭐⭐ | Todas (pode ter bugs) |

**Recomendação**: Comece com `v2.0.10`, funciona na maioria dos casos.

---

**Última Atualização:** 2025-12-20
**Status:** 🔍 Aguardando logs de debug
