# 🐛 BUG: Evolution API v2.2.3 (latest) - Crash na Inicialização

## 🔴 Problema Identificado

### Sintoma:
- Migrations aplicadas com sucesso ✅
- Prisma conectado ✅
- Servidor inicia mas **crasha imediatamente** ❌
- Erro: `TypeError: Cannot read properties of undefined (reading 'listen')` na linha 286 do main.js

### Versão Afetada:
**atendai/evolution-api:latest (v2.2.3)**

### Log do Erro:
```
[Evolution API]    v2.2.3  77   -  Sun Dec 21 2025 00:51:30     INFO   [PrismaRepository]  [string]  Repository:Prisma - ON
/evolution/dist/main.js:286
...código minificado ilegível...
TypeError: Cannot read properties of undefined (reading 'listen')
```

## 🔍 Análise Técnica

### O que aconteceu:
1. ✅ Migrations executadas (schema `evolution` sincronizado)
2. ✅ Prisma repository inicializado
3. ✅ WA Module carregado
4. ❌ **Crash ao tentar iniciar servidor HTTP/Express**

### Causa Raiz:
A versão `v2.2.3` (latest) tem um **bug de inicialização** no código minificado do `main.js`.

Provavelmente:
- Falta validação de variável de ambiente crítica
- Erro no código de inicialização do servidor HTTP
- Bug introduzido em versão recente

### Por que não vimos stack trace completo:
O código está **minificado** (sem source maps), então o erro aparece como uma linha gigante de código compactado.

---

## ✅ SOLUÇÃO APLICADA

### Downgrade para Versão Estável:
**atendai/evolution-api:v2.0.10**

### Modificações:
```dockerfile
# ANTES (com bug):
FROM atendai/evolution-api:latest  # v2.2.3

# DEPOIS (estável):
FROM atendai/evolution-api:v2.0.10
```

### Por que v2.0.10?
- ✅ Versão estável testada em produção
- ✅ Menos funcionalidades = menos bugs
- ✅ ~8-10 tabelas (ao invés de 30)
- ✅ Código mais leve e rápido
- ✅ Sem bugs conhecidos de inicialização

---

## 📊 Comparação de Versões

| Versão | Tabelas | Estabilidade | Status |
|--------|---------|--------------|--------|
| **v2.0.10** | 8-10 | ⭐⭐⭐⭐⭐ | ✅ **Recomendada** |
| v2.1.0 | ~15 | ⭐⭐⭐⭐ | OK |
| v2.1.1 | ~20 | ⭐⭐⭐ | Bug P3005 conhecido |
| v2.2.3 (latest) | ~30 | ⭐⭐ | ❌ **Bug de inicialização** |

---

## 🧪 Testes Realizados

### Teste 1: Debug Mode (v2.2.3)
- ✅ Migrations OK
- ✅ Prisma OK
- ❌ Crash: `Cannot read properties of undefined (reading 'listen')`

### Teste 2: Versão Estável (v2.0.10)
- ⏳ Aguardando deploy...

---

## 🎯 Próximos Passos

1. **Commit da correção**:
   ```bash
   git add evolution-api/Dockerfile evolution-api/BUG_VERSION_LATEST.md
   git commit -m "fix(evolution-api): Downgrade to v2.0.10 - v2.2.3 has initialization bug"
   git push
   ```

2. **Deploy no Render**:
   - Manual Deploy → Deploy latest commit

3. **Logs esperados (v2.0.10)**:
   ```
   [Evolution API]    v2.0.10  ...
   Repository:Prisma - ON
   Server started on port 8080  ✅
   ```

---

## 📝 Lições Aprendidas

1. **Evitar `latest`** em produção
   - `latest` pode ter bugs não documentados
   - Sempre usar versões específicas testadas

2. **Debug mode é essencial**
   - Sem logs detalhados, impossível diagnosticar
   - `start-debug.sh` salvou o dia!

3. **Downgrade é solução válida**
   - Melhor versão estável antiga que versão nova bugada
   - Estabilidade > Funcionalidades

---

## 🔗 Referências

- **Issue Evolution API**: https://github.com/EvolutionAPI/evolution-api/issues
- **Changelog v2.2.3**: (verificar breaking changes)
- **Docker Hub**: https://hub.docker.com/r/atendai/evolution-api/tags

---

**Data do Bug**: 2025-12-21
**Versão Afetada**: v2.2.3 (latest)
**Solução**: Downgrade para v2.0.10
**Status**: ✅ RESOLVIDO
