#!/usr/bin/env bash
# =============================================================================
# Environment Variables Validation Script
# =============================================================================
# Este script valida variáveis de ambiente de duas formas:
# 1. Se .env existe: valida o arquivo
# 2. Se .env não existe: valida variáveis do sistema no ambiente
#
# Uso:
#   ./envs_validation.sh [var1] [var2] [var3] ...
# Caso queira variáveis adicionais, basta passar como parâmetro.
# Exemplo: ./envs_validation.sh SECRET_KEY_BASE
# OBS: As variáveis adicionais serão validadas no arquivo .env ou no ambiente do sistema.
# Exemplo: SECRET_KEY_BASE=1234567890
# =============================================================================

set -e

# =============================================================================
# VARIÁVEIS BASE (COMUNS A TODOS OS AMBIENTES)
# =============================================================================

REQUIRED_VARS_BASE=(
  "DB_HOST"
  "DB_PORT"
  "POSTGRES_USER"
  "POSTGRES_PASSWORD"
  "POSTGRES_DB"
  "RAILS_PORT"
  "RAILS_INTERNAL_PORT"
  "RAILS_MAX_THREADS"
)

# =============================================================================
# VARIÁVEIS ADICIONAIS (VIA PARÂMETROS)
# =============================================================================

REQUIRED_VARS_EXTRA=("$@")
REQUIRED_VARS=("${REQUIRED_VARS_BASE[@]}" "${REQUIRED_VARS_EXTRA[@]}")

# =============================================================================
# DETECTA MODO DE VALIDAÇÃO
# =============================================================================

if [ -f ".env" ]; then
  echo "🔍 Validando variáveis do arquivo .env..."
  USE_FILE=true
else
  echo "🔍 Validando variáveis de ambiente do sistema..."
  USE_FILE=false
fi

echo "📋 Variáveis obrigatórias: ${#REQUIRED_VARS[@]}"

# =============================================================================
# VALIDAÇÃO DAS VARIÁVEIS
# =============================================================================

missing=()
empty=()

for var in "${REQUIRED_VARS[@]}"; do
  if [ "$USE_FILE" = true ]; then
    # Modo 1: Valida do arquivo .env
    if ! grep -q "^${var}=" ".env"; then
      missing+=("$var")
    else
      value=$(grep "^${var}=" ".env" | cut -d '=' -f2-)
      if [ -z "$value" ]; then
        empty+=("$var")
      fi
    fi
  else
    # Modo 2: Valida do ambiente do sistema
    if [ -z "${!var}" ]; then
      missing+=("$var")
    fi
  fi
done

# =============================================================================
# REPORTA ERROS
# =============================================================================

if [ ${#missing[@]} -gt 0 ]; then
  echo "❌ Variáveis faltando:"
  printf '   - %s\n' "${missing[@]}"
  exit 1
fi

if [ ${#empty[@]} -gt 0 ]; then
  echo "❌ Variáveis vazias:"
  printf '   - %s\n' "${empty[@]}"
  exit 1
fi

echo "✅ Todas as variáveis estão configuradas!"
exit 0