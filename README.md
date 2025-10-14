# Avantsoft Teste Técnico

API REST para gerenciamento de quadros (frames) e círculos com validações geométricas.

## 🚀 Stack

- **Ruby** 3.2.2
- **Rails** 8.0
- **PostgreSQL** 16
- **Docker** + Docker Compose

## 📋 Pré-requisitos

Para rodar este projeto, você precisa ter instalado:

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **Make**

### Verificar instalação

```bash
docker --version          # Docker version 20.10+
docker compose version    # Docker Compose version 2.0+
make --version           # GNU Make 4.0+
```

## 🛠️ Gems Utilizadas

### Backend
- **active_model_serializers** `~> 0.10.14` - Serialização de JSON
- **kaminari** `~> 1.2` - Paginação

### Qualidade & Testes
- **rspec-rails** `~> 8.0.0` - Framework de testes
- **factory_bot_rails** `~> 6.4` - Factories para testes
- **faker** `~> 3.4` - Geração de dados fake
- **shoulda-matchers** `~> 6.0` - Matchers para testes
- **rubocop-rails-omakase** - Linting
- **brakeman** - Análise de segurança

### Documentação
- **rswag** - Geração de Swagger/OpenAPI

## 🏗️ Projeto Base

Este projeto foi iniciado usando [Project Builder](https://github.com/xispituao/project_builder), um template automatizado para criação de projetos em várias linguagens (Rails suportado) com Docker.

## 📦 Setup

```bash
# Subir aplicação
make up

# Rodar migrations
make migrate
```

Aplicação disponível em `http://localhost:3000`

## 🧪 Testes

```bash
make test          # Rodar suite completa
make rubocop       # Verificar linting
make brakeman      # Análise de segurança
```

## 📚 Documentação

Swagger UI: `http://localhost:3000/api-docs`

```bash
make swagger       # Regenerar documentação
```

## 🌍 Internacionalização

Suporte a PT-BR (padrão) e EN via header:

```bash
curl -H "Accept-Language: en" http://localhost:3000/circles
```

Ou via query parameter: `?locale=en`

## 🔧 Comandos Disponíveis

### Aplicação
```bash
make up              # Iniciar aplicação em modo detached
make up-interactive  # Iniciar e ver logs em tempo real
make down            # Parar e remover containers
make restart         # Reiniciar container da aplicação
make logs            # Ver logs em tempo real
make clean           # Remover tudo (containers, volumes, dados)
make build           # Rebuildar imagens Docker
```

### Desenvolvimento
```bash
make console         # Abrir Rails console
make bash            # Abrir shell bash no container
make migrate         # Executar migrations pendentes
```

### Qualidade
```bash
make test            # Executar suite completa de testes
make rubocop         # Verificar padrões de código
make rubocop-fix     # Corrigir automaticamente issues do Rubocop
make brakeman        # Análise de vulnerabilidades de segurança
make swagger         # Gerar documentação Swagger
```

## 📊 Features

### Quadros
- ✅ Criar com círculos aninhados
- ✅ Validação de sobreposição
- ✅ Métricas de posições extremas
- ✅ Deleção com proteção

### Círculos
- ✅ Filtro por raio euclidiano
- ✅ Paginação (25 itens/página)
- ✅ Validação de overlap
- ✅ Validação de limites do frame

### API
- ✅ RESTful endpoints
- ✅ JSON serializers
- ✅ Services layer
- ✅ Performance otimizada (SQL puro)
- ✅ Pagination headers

## 🏗️ Arquitetura

```
Controllers → Services → Models
     ↓
Serializers (JSON output)
```

- **Controllers**: Apenas HTTP
- **Services**: Lógica de negócio
- **Models**: Validações e associações
- **Serializers**: Formatação de resposta

## 🚀 Deploy

A aplicação foi deployada no **[Render](https://render.com)** utilizando Continuous Deployment (CD).

**🌐 Aplicação em produção:**  
👉 https://avantsoft-api-pixr.onrender.com/api-docs/index.html

### CI Pipeline

Pipeline automático configurado via GitHub Actions:

- ✅ Testes automáticos em cada PR/push
- ✅ Rubocop + Brakeman
- ✅ Validação do Swagger

## 📈 Performance

- Zero N+1 queries
- SQL otimizado com índices compostos
- Counter cache
- Paginação com Kaminari

Testado para até 100K registros com performance < 200ms.
