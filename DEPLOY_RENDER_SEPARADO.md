# 🚀 Deploy Evolution API - Repositório Separado

## ✅ Configuração para Repositório Separado no Render

### Opção 1: Blueprint (Automático - Recomendado)

1. **Commite os arquivos no repositório separado**:
   ```bash
   git add .
   git commit -m "Setup Evolution API for Render"
   git push
   ```

2. **No Render Dashboard**:
   - Acesse: https://dashboard.render.com
   - Clique: **New** → **Blueprint**
   - Conecte ao repositório: **evolution-api** (seu repo separado)
   - O Render detectará o `render.yaml` automaticamente
   - Clique: **Apply**

3. **Configure as 3 variáveis obrigatórias**:
   - `SERVER_URL`: `https://seu-servico.onrender.com`
   - `DATABASE_URL`: URL do PostgreSQL (mesma do backend)
   - `AUTHENTICATION_API_KEY`: Chave forte (gere com `openssl rand -base64 32`)

---

### Opção 2: Web Service Manual

Se preferir configurar manualmente:

1. **No Render Dashboard**:
   - New → **Web Service**
   - Conecte ao repositório **evolution-api**

2. **Configure EXATAMENTE assim**:
   ```
   Name: agenda-onsell-evolution-api
   Region: Virginia (US East)
   Branch: main

   ⚠️ IMPORTANTE - Como é repositório separado:
   Root Directory: .
   (ou deixe em branco)

   Runtime: Docker
   Dockerfile Path: Dockerfile
   (ou ./Dockerfile)

   Instance Type: Free
   ```

3. **Environment Variables** (adicione depois):
   ```
   SERVER_URL=https://seu-servico.onrender.com
   DATABASE_URL=postgresql://user:pass@host:5432/agenda_db?sslmode=require
   AUTHENTICATION_API_KEY=sua_chave_forte_aqui
   ```

---

## 🔧 Checklist Pré-Deploy

- [ ] Repositório separado criado
- [ ] Arquivo `render.yaml` está na raiz
- [ ] Arquivo `Dockerfile` está na raiz
- [ ] Arquivo `.dockerignore` está na raiz
- [ ] Commitei tudo (`git add . && git commit && git push`)

---

## ⚙️ Gerar API Key Forte

**Linux/Mac/Git Bash**:
```bash
openssl rand -base64 32
```

**PowerShell (Windows)**:
```powershell
-join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
```

**Online**:
https://www.uuidgenerator.net/api/guid

---

## ✅ Após Deploy Bem-Sucedido

### 1. Aguarde o build completar (~5-10 minutos)

### 2. Copie a URL do serviço
Exemplo: `https://agenda-onsell-evolution-api.onrender.com`

### 3. Atualize a variável `SERVER_URL`
No Render, vá em Environment → Edite `SERVER_URL` com a URL gerada

### 4. Teste a API
```bash
curl https://seu-servico.onrender.com
```

Deve retornar algo como:
```json
{
  "status": "ok",
  "version": "2.1.1"
}
```

### 5. Crie uma instância WhatsApp
```bash
curl -X POST https://seu-servico.onrender.com/instance/create \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "agenda_onsell",
    "qrcode": true
  }'
```

### 6. Conecte via QR Code

**Opção A - Via Browser** (mais fácil):
```
https://seu-servico.onrender.com/instance/connect/agenda_onsell?apikey=SUA_API_KEY
```

**Opção B - Via cURL**:
```bash
curl -X GET "https://seu-servico.onrender.com/instance/connect/agenda_onsell" \
  -H "apikey: SUA_API_KEY"
```

Abra WhatsApp no celular → **Dispositivos Conectados** → Leia o QR Code

### 7. Verifique a conexão
```bash
curl -X GET "https://seu-servico.onrender.com/instance/connectionState/agenda_onsell" \
  -H "apikey: SUA_API_KEY"
```

Resposta esperada:
```json
{
  "instance": {
    "instanceName": "agenda_onsell",
    "state": "open"
  }
}
```

---

## 🔗 Configure no AgendaOnSell

1. Acesse: `http://localhost:3000/whatsapp` (ou produção)
2. Preencha:
   - **URL da Evolution API**: `https://seu-servico.onrender.com`
   - **API Key**: Sua AUTHENTICATION_API_KEY
   - **Nome da Instância**: `agenda_onsell`
3. Configure os templates de mensagem
4. Clique em **Enviar Teste** para validar

---

## 🐛 Erros Comuns

### ❌ "Root directory does not exist"
**Causa**: Configurou Root Directory errado
**Solução**:
- Se usando Blueprint: Deixe o `render.yaml` fazer o trabalho
- Se manual: Root Directory = `.` ou deixe em branco

### ❌ "Failed to build"
**Causa**: Dockerfile não encontrado
**Solução**: Certifique-se que `Dockerfile` está na raiz do repo

### ❌ QR Code não carrega
**Solução**: Acesse com `?apikey=SUA_CHAVE` na URL ou use Postman

### ❌ "Database connection failed"
**Solução**: Verifique se `DATABASE_URL` está correta (mesma do backend)

---

## 📊 Estrutura do Repositório Separado

```
evolution-api-repo/           # ← Repositório Git raiz
├── Dockerfile                # ✅ Na raiz
├── render.yaml               # ✅ Na raiz
├── docker-compose.yml
├── .env.example
├── .dockerignore             # ✅ Na raiz
├── .gitignore
├── README.md
├── DEPLOY_GUIDE.md
└── DEPLOY_RENDER_SEPARADO.md # ← Este arquivo
```

**IMPORTANTE**: Não crie subpastas! Tudo deve estar na raiz do repositório.

---

## ✅ Resumo Rápido

```bash
# 1. Commit
git add .
git commit -m "Setup for Render"
git push

# 2. Render → New → Blueprint
# 3. Selecione repo evolution-api
# 4. Configure as 3 variáveis de ambiente
# 5. Aguarde deploy
# 6. Crie instância + conecte QR Code
# 7. Configure no AgendaOnSell /whatsapp
```

---

**🎉 Pronto! Evolution API funcionando no Render!**
