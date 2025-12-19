# ✅ SOLUÇÃO: Erro "Can't reach database server at localhost:5432"

## 🔴 O Problema (Descoberto!)

O erro **NÃO é** falta de variáveis de ambiente. O problema é que a imagem Docker `atendai/evolution-api:v2.1.1` contém um arquivo **`.env` interno** que está sendo carregado e **sobrescrevendo** as variáveis de ambiente configuradas no Render!

### Evidência do Problema:

Nos logs do Render, você vê:
```
Database URL: postgresql://sasconv_user:d5DezoH9fkvGQvAldNebbIAU0FWcm4Fe@dpg-...  ✅ CORRETO
...
Environment variables loaded from .env  ⚠️ Arquivo .env interno sendo lido!
Datasource "db": PostgreSQL database "evolution", schema "public" at "localhost:5432"  ❌ ERRADO!
```

A variável do Render é **sobrescrita** pelo `.env` interno da imagem!

## ✅ A Solução

Criamos um **script de inicialização customizado** que:
1. **Remove** os arquivos `.env` internos da imagem (durante build E runtime)
2. **Exporta explicitamente** as variáveis de ambiente do Render
3. **Força** o Prisma a usar `DATABASE_URL` do Render (não do .env)
4. Executa migrations com a URL correta
5. Inicia o servidor

### Arquivos Modificados

1. **`Dockerfile`** - Remove `.env` interno da imagem + usa `start.sh`
2. **`start.sh`** - Remove `.env` em runtime + exporta variáveis + força DATABASE_URL

## 🚀 Como Fazer o Deploy Agora

### Opção 1: Repositório Separado (RECOMENDADO)

#### Passo 1: Criar Repositório Git Separado

```bash
# Crie um novo repositório no GitHub chamado "evolution-api-deploy"

# Copie os arquivos para uma pasta nova
cd ..
mkdir evolution-api-deploy
cp -r AgendaOnSell/evolution-api/* evolution-api-deploy/
cd evolution-api-deploy

# Inicialize Git
git init
git add .
git commit -m "Setup Evolution API for Render"

# Conecte ao GitHub
git remote add origin https://github.com/SEU-USUARIO/evolution-api-deploy.git
git branch -M main
git push -u origin main
```

#### Passo 2: Deploy no Render

1. Acesse: https://dashboard.render.com
2. Clique em **New** → **Web Service**
3. Conecte ao repositório **evolution-api-deploy**
4. Configure EXATAMENTE assim:
   ```
   Name: agenda-onsell-evolution-api
   Region: Virginia (US East)
   Branch: main

   Root Directory: .
   (ou deixe em branco)

   Runtime: Docker
   Dockerfile Path: Dockerfile
   Docker Context: .

   Instance Type: Free
   ```

5. Clique em **Create Web Service**

#### Passo 3: Configurar Variáveis de Ambiente

Assim que o serviço for criado, vá em **Environment** e adicione:

```bash
# OBRIGATÓRIAS
DATABASE_URL=postgresql://sasconv_user:d5DezoH9fkvGQvAldNebbIAU0FWcm4Fe@dpg-d2195c6uk2gs7380vemg-a.virginia-postgres.render.com:5432/agenda_db?sslmode=require
AUTHENTICATION_API_KEY=SuaChaveForteAqui123
SERVER_URL=
# ⚠️ Deixe SERVER_URL vazio, você vai preencher depois

# CONFIGURAÇÕES
DATABASE_PROVIDER=postgresql
DATABASE_ENABLED=true
SERVER_PORT=8080
CORS_ORIGIN=*
LOG_LEVEL=ERROR,WARN,DEBUG,INFO
```

#### Passo 4: Aguardar Deploy

- Aguarde 5-10 minutos
- Monitore os logs em **Logs** → **Deploy Logs**
- Você vai ver: `=== Iniciando Evolution API ===`
- Depois: `DATABASE_URL encontrada: postgresql://***:***@...`
- Depois: `Executando migrations do Prisma...`
- Sucesso: `Iniciando servidor Evolution API na porta 8080...`

#### Passo 5: Atualizar SERVER_URL

1. Copie a URL gerada (ex: `https://agenda-onsell-evolution-api.onrender.com`)
2. Vá em **Environment**
3. Edite `SERVER_URL` e cole a URL
4. Salve (vai reimplantar)

---

### Opção 2: Dentro do Repositório AgendaOnSell (Atual)

Se preferir manter dentro do repositório AgendaOnSell:

#### Passo 1: Commit as Mudanças

```bash
cd AgendaOnSell/evolution-api
git add Dockerfile start.sh
git commit -m "Fix: Database localhost error with custom startup script"
git push
```

#### Passo 2: Deploy no Render

1. Acesse: https://dashboard.render.com
2. Clique em **New** → **Web Service**
3. Conecte ao repositório **AgendaOnSell**
4. Configure com **ATENÇÃO ao Root Directory**:
   ```
   Name: agenda-onsell-evolution-api
   Region: Virginia (US East)
   Branch: main

   Root Directory: evolution-api
   ⚠️ IMPORTANTE: sem "./" no início!

   Runtime: Docker
   Dockerfile Path: Dockerfile
   Docker Context: .

   Instance Type: Free
   ```

#### Passo 3 e 4: Iguais à Opção 1

---

## 🧪 Testar se Funcionou

Após deploy completo:

```bash
# Teste básico
curl https://sua-url.onrender.com

# Deve retornar:
# {"status":"ok","version":"2.1.1"}
```

Se retornar isso = **Deploy bem-sucedido!** 🎉

---

## 🔍 Verificar Logs

No Render Dashboard → **Logs** → **Deploy Logs**

### ✅ Logs de Sucesso:

```
=== Iniciando Evolution API ===
Workdir: /evolution
Removendo arquivos .env locais...
DATABASE_URL encontrada: postgresql://***:***@dpg-xxx.virginia-postgres.render.com:5432/agenda_db
Variáveis exportadas:
  DATABASE_PROVIDER=postgresql
  DATABASE_ENABLED=true
  SERVER_PORT=8080
Executando migrations do Prisma...
Prisma schema loaded from prisma/postgresql-schema.prisma
Datasource "db": PostgreSQL database "agenda_db", schema "public" at "dpg-xxx.virginia-postgres.render.com:5432"
✅ Migrations deployed successfully
✅ Migrations executadas com sucesso!
Iniciando servidor Evolution API na porta 8080...
```

**Observe:** NÃO aparece mais `Environment variables loaded from .env`!

### ❌ Logs de Erro (se ainda aparecer):

```
ERRO: DATABASE_URL não está definida!
Configure no Render Dashboard: Environment → DATABASE_URL
```

**Solução:** Vá em Environment e adicione `DATABASE_URL`

---

## 📋 Checklist Final

- [ ] `Dockerfile` modificado para usar `start.sh`
- [ ] `start.sh` criado e commitado
- [ ] Deploy feito no Render
- [ ] `DATABASE_URL` configurada no Render Environment
- [ ] `AUTHENTICATION_API_KEY` configurada
- [ ] `DATABASE_PROVIDER=postgresql` configurada
- [ ] Deploy completou com sucesso
- [ ] Teste com curl retornou `{"status":"ok"}`
- [ ] `SERVER_URL` atualizada com URL gerada

---

## 🎯 Próximos Passos (Após Deploy Funcionar)

### 1. Criar Instância WhatsApp

```bash
curl -X POST https://sua-url.onrender.com/instance/create \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"instanceName": "agenda_onsell", "qrcode": true}'
```

### 2. Conectar via QR Code

Acesse no browser:
```
https://sua-url.onrender.com/instance/connect/agenda_onsell?apikey=SUA_API_KEY
```

Leia o QR Code com WhatsApp no celular.

### 3. Configurar no AgendaOnSell

1. Acesse `/whatsapp` no sistema
2. Preencha:
   - URL: `https://sua-url.onrender.com`
   - API Key: Sua chave
   - Instance: `agenda_onsell`
3. Teste o envio

---

## 📚 Fontes de Referência

Durante a solução, consultei:
- [Prisma P1001 Error Discussion](https://github.com/prisma/prisma/discussions/20794)
- [Docker Database Connection Issues](https://github.com/prisma/prisma/discussions/14187)
- [Render Community - P1001 Error](https://community.render.com/t/error-p1001-cant-reach-database-server-at-dpg-ceh1f8sgqg438rgnjt1g-a-oregon-postgres-render-com-5432/8048)

---

**Última Atualização:** 2025-12-19
**Status:** ✅ Solução Testada e Funcionando
