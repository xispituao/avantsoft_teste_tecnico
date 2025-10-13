# 🚀 Guia de Deploy - Render

Este guia explica como fazer o deploy da aplicação no Render.com com deploy automático via Git.

## 📋 Pré-requisitos

1. Conta no [Render](https://render.com) (plano free funciona perfeitamente)
2. Repositório no GitHub com o código da aplicação
3. Rails Master Key (arquivo `config/master.key`)

## 🎯 Configuração Inicial

### 1. Preparar a Master Key

A aplicação precisa da `RAILS_MASTER_KEY` para descriptografar as credenciais:

```bash
# Ver sua master key
cat config/master.key
```

**⚠️ IMPORTANTE:** Guarde esta chave em um local seguro. Você vai precisar dela no próximo passo.

**Nota:** O `SECRET_KEY_BASE` será gerado automaticamente pelo Render.

### 2. Conectar Repositório ao Render

1. Acesse [dashboard.render.com](https://dashboard.render.com)
2. Clique em **"New +"** no topo
3. Selecione **"Blueprint"**
4. Conecte seu repositório do GitHub: `<seu_usuario>/<nome_do_seu_projeto>`
5. O Render vai detectar automaticamente o arquivo `render.yaml` ✨

### 3. Configurar Variáveis de Ambiente

Durante a criação, o Render vai pedir a `RAILS_MASTER_KEY`:

1. Cole o conteúdo do seu `config/master.key`
2. Clique em **"Apply"**

O Render vai criar automaticamente:
- ✅ Web Service (aplicação Rails)
- ✅ PostgreSQL Database (free tier)
- ✅ Todas as variáveis de ambiente necessárias
- ✅ Conexão entre a aplicação e o banco

### 4. Primeiro Deploy

O Render vai iniciar o primeiro deploy automaticamente:

1. **Build:** Imagem Docker é construída usando o Dockerfile de produção (`base_files/production/Dockerfile`)
   - O Dockerfile copia automaticamente os arquivos necessários
   - Gems são instaladas durante o build (multi-stage build otimizado)
2. **Setup:** `entrypoint.sh` configura banco de dados e executa migrations
3. **Start:** Aplicação inicia

⏱️ **Tempo estimado:** 5-10 minutos

**Como funciona:**
- O projeto usa `base_files/production/Dockerfile` com build multi-stage otimizado
- O Dockerfile copia automaticamente os arquivos necessários de `base_files/`
- O `entrypoint.sh` de produção cuida do setup automaticamente (database config, migrations, etc)

## 🔄 Deploy Automático (CD)

### Como Funciona

Após a configuração inicial, **todo push na branch `main` dispara um deploy automático**:

```bash
git add .
git commit -m "feat: nova funcionalidade"
git push origin main
```

➡️ O Render detecta o push e inicia o deploy automaticamente!

### Acompanhar o Deploy

1. Acesse o dashboard do Render
2. Selecione seu serviço `avantsoft-api`
3. Veja os logs em tempo real na aba **"Logs"**

## 🔍 Verificar a Aplicação

Após o deploy, teste sua aplicação:

### Health Check
```bash
curl https://seu-app.onrender.com/up
```

Resposta esperada: `200 OK`

### Documentação API
Acesse no navegador:
```
https://seu-app.onrender.com/api-docs
```

### Testar Endpoints
```bash
# Criar um frame
curl -X POST https://seu-app.onrender.com/frames \
  -H "Content-Type: application/json" \
  -d '{
    "frame": {
      "width": 100,
      "height": 100,
      "circles": [
        {"x": 10, "y": 10, "radius": 5}
      ]
    }
  }'
```

## 🛠️ Configuração Avançada

### Variáveis de Ambiente Disponíveis

O `render.yaml` já configura automaticamente:

| Variável | Valor | Descrição |
|----------|-------|-----------|
| `RAILS_ENV` | `production` | Ambiente Rails |
| `RAILS_MASTER_KEY` | *(manual)* | Chave para credenciais |
| `SECRET_KEY_BASE` | *(gerado)* | Chave secreta da sessão |
| `DB_HOST` | *(automático)* | Host do PostgreSQL |
| `DB_PORT` | *(automático)* | Porta do PostgreSQL |
| `POSTGRES_USER` | *(automático)* | Usuário do banco |
| `POSTGRES_PASSWORD` | *(automático)* | Senha do banco |
| `POSTGRES_DB` | *(automático)* | Nome do banco |
| `RAILS_LOG_TO_STDOUT` | `1` | Logs no stdout |
| `RAILS_MAX_THREADS` | `5` | Threads por worker |
| `RAILS_INTERNAL_PORT` | `3000` | Porta interna da app |

### Adicionar Novas Variáveis

1. Vá em **Dashboard > avantsoft-api > Environment**
2. Clique em **"Add Environment Variable"**
3. Adicione a variável e valor
4. Clique em **"Save Changes"**

O serviço será reiniciado automaticamente.

### Executar Comandos no Container

Você pode executar comandos via Shell do Render:

1. Vá em **Dashboard > avantsoft-api > Shell**
2. Execute comandos Rails:

```bash
# Console
bundle exec rails console

# Seeds (migrations já rodam automaticamente)
bundle exec rails db:seed

# Verificar status das migrations
bundle exec rails db:migrate:status
```

**Nota:** O `entrypoint.sh` já executa migrations automaticamente em cada deploy!

## 🐛 Troubleshooting

### Deploy Falhou

1. Verifique os logs: **Dashboard > Logs**
2. Problemas comuns:
   - `RAILS_MASTER_KEY` incorreta
   - Migrations com erro
   - Gems faltando no Gemfile

### Aplicação Não Responde

1. Verifique o health check: `/up`
2. Veja os logs da aplicação
3. Verifique se o banco está conectado:
   ```bash
   bundle exec rails runner "puts ActiveRecord::Base.connection.execute('SELECT 1').to_a"
   ```

### Banco de Dados

1. **Conexão:** O `DATABASE_URL` é configurado automaticamente
2. **Backup:** Render faz backup automático no plano free
3. **Acessar:** Use o Shell ou conecte via cliente PostgreSQL

### Rollback

Se precisar voltar para uma versão anterior:

1. Vá em **Dashboard > avantsoft-api**
2. Selecione a aba **"Events"**
3. Encontre o deploy anterior
4. Clique em **"Redeploy"**

## 📊 Monitoramento

### Logs

Ver logs em tempo real:
1. **Dashboard > avantsoft-api > Logs**
2. Filtre por nível (INFO, ERROR, etc)
3. Baixe logs para análise local

### Métricas

O Render fornece métricas gratuitas:
- CPU usage
- Memory usage
- Request count
- Response time

Acesse em: **Dashboard > avantsoft-api > Metrics**

## 🔐 Segurança

### Boas Práticas

1. ✅ Nunca commite `config/master.key` no Git
2. ✅ Use variáveis de ambiente para secrets
3. ✅ Mantenha gems atualizadas
4. ✅ Execute `bundle audit` regularmente
5. ✅ CI/CD já executa Brakeman (security scan)

### SSL/HTTPS

✅ O Render fornece SSL/HTTPS automaticamente para todos os serviços.

## 📚 Recursos Úteis

- [Documentação do Render](https://render.com/docs)
- [Render + Rails Guide](https://render.com/docs/deploy-rails)
- [Blueprint Spec](https://render.com/docs/blueprint-spec)
- [Render Status](https://status.render.com/)

**🎉 Pronto! Sua aplicação está no ar!**
