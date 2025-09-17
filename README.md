# 🎯 AvantSoft - Teste Técnico Rails API

## 📋 Sobre o Projeto

Este é um projeto Rails API desenvolvido como teste técnico para a AvantSoft. A aplicação gerencia **Frames** (quadros) e **Circles** (círculos) com validações geométricas avançadas para evitar sobreposições e garantir que os círculos se encaixem perfeitamente dentro dos quadros.

### 🎨 Funcionalidades Principais

- **📦 Gestão de Frames**: Criação e gerenciamento de quadros com dimensões personalizadas
- **⭕ Gestão de Circles**: Adição de círculos dentro dos quadros com validações geométricas
- **🔍 Validações Inteligentes**: 
  - Círculos não podem sair dos limites do quadro
  - Círculos não podem se sobrepor
  - Quadros não podem se sobrepor
- **🌐 API RESTful**: Endpoints completos para CRUD de frames e circles
- **📚 Documentação Swagger**: API documentada automaticamente
- **🧪 Testes RSpec**: Cobertura completa de testes

## 🛠️ Tecnologias Utilizadas

### **Backend**
- **Ruby 3.4.2** - Linguagem principal
- **Rails 8.0.1** - Framework web
- **PostgreSQL 17.6** - Banco de dados
- **Puma** - Servidor web

### **Desenvolvimento & Testes**
- **RSpec** - Framework de testes
- **Factory Bot** - Criação de dados de teste
- **Shoulda Matchers** - Matchers para testes Rails
- **Database Cleaner** - Limpeza de banco entre testes
- **Rswag** - Documentação Swagger/OpenAPI

### **Infraestrutura**
- **Docker & Docker Compose** - Containerização
- **Makefile** - Automação de comandos
- **Multi-ambiente** - Development, Staging, Production

## 🚀 Como Executar o Projeto

### **Pré-requisitos**
- Docker e Docker Compose instalados
- Make (opcional, mas recomendado)

### **🚀 Início Rápido**

```bash
# 1. Clone o repositório
git clone <repository-url>
cd avantsoft_teste_tecnico

# 2. Inicie o ambiente de desenvolvimento
make dev

# 3. Acesse a aplicação
# API: http://localhost:3000
# Swagger: http://localhost:3000/api-docs
```

### **📋 Comandos Disponíveis**

```bash
# 🏗️ Desenvolvimento
make dev              # Inicia ambiente de desenvolvimento
make dev-interactive  # Modo interativo (sem detach)
make logs             # Visualiza logs da aplicação
make console          # Abre console Rails
make bash             # Abre bash no container

# 🧪 Testes
make test             # Executa todos os testes
make swagger          # Gera documentação Swagger

# 🗄️ Banco de Dados
make migrate          # Executa migrações

# 🧹 Limpeza
make clean            # Remove containers e volumes
make down             # Para containers

# 🚀 Produção
make prod             # Inicia ambiente de produção
make staging          # Inicia ambiente de staging
```

## 📊 Estrutura do Banco de Dados

### **Frames (Quadros)**
```ruby
# Atributos
x_axis: decimal      # Posição X do canto superior esquerdo
y_axis: decimal      # Posição Y do canto superior esquerdo  
width: decimal       # Largura do quadro
height: decimal      # Altura do quadro
total_circles: integer # Contador de círculos (cache)
```

### **Circles (Círculos)**
```ruby
# Atributos
x_axis: decimal      # Posição X do centro
y_axis: decimal      # Posição Y do centro
diameter: decimal    # Diâmetro do círculo
frame_id: integer    # Referência ao quadro pai
```

## 🔗 Endpoints da API

### **Frames**
```
GET    /api/v1/frames           # Lista todos os quadros
POST   /api/v1/frames           # Cria novo quadro
GET    /api/v1/frames/:id       # Mostra quadro específico
PUT    /api/v1/frames/:id       # Atualiza quadro
DELETE /api/v1/frames/:id       # Remove quadro
```

### **Circles**
```
GET    /api/v1/circles          # Lista todos os círculos
POST   /api/v1/circles          # Cria novo círculo
GET    /api/v1/circles/:id      # Mostra círculo específico
PUT    /api/v1/circles/:id      # Atualiza círculo
DELETE /api/v1/circles/:id      # Remove círculo
```

## 🧪 Executando Testes

```bash
# Executar todos os testes
make test

# Executar testes específicos
docker compose -f docker-compose.development.yml --env-file .env.development exec app bundle exec rspec spec/models/
docker compose -f docker-compose.development.yml --env-file .env.development exec app bundle exec rspec spec/requests/
```

## 📚 Documentação da API

A documentação Swagger está disponível em:
- **URL**: `http://localhost:3000/api-docs`
- **Geração**: `make swagger`

## 🔧 Configuração de Ambientes

### **Development**
- Arquivo: `.env.development` (criado automaticamente)
- Banco: PostgreSQL local
- Logs: Detalhados
- Assets: Não compilados

### **Staging/Production**
- Variáveis de ambiente do sistema
- Assets pré-compilados
- Configurações otimizadas

## 🐳 Docker & Volumes

### **Volumes Otimizados**
- **Código fonte**: Mapeado para desenvolvimento ativo
- **Gems cache**: Volume persistente para dependências
- **Banco de dados**: Volume persistente para dados

### **Cache de Dependências**
O projeto foi otimizado para evitar reinstalação constante de gems:
- Volume nomeado `gems_cache` para persistência
- Configuração otimizada do Bundle
- PATH configurado corretamente

## 🌍 Internacionalização

O projeto suporta múltiplos idiomas:
- **Português (pt-BR)**: Idioma padrão
- **Inglês (en)**: Idioma secundário

Mensagens de erro e validações são traduzidas automaticamente.

## 📁 Estrutura do Projeto

```
avantsoft_teste_tecnico/
├── app/
│   ├── controllers/api/v1/    # Controllers da API
│   ├── models/                # Modelos (Frame, Circle)
│   ├── serializers/           # Serializadores JSON
│   └── services/              # Serviços de negócio
├── config/
│   ├── environments/          # Configurações por ambiente
│   └── locales/               # Arquivos de tradução
├── spec/                      # Testes RSpec
├── swagger/                   # Documentação Swagger
├── docker-compose.*.yml       # Configurações Docker
├── Dockerfile.*               # Imagens Docker
└── makefile                   # Comandos automatizados
```
