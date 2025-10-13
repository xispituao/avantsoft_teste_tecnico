#!/usr/bin/env bash
# =============================================================================
# Init Script
# =============================================================================
# Este script é responsável por:
# 1. Executar o script envs_validation.sh
# 2. Executar o script run_container.sh (se não for --skip-container)
# =============================================================================

set -e  # Para execução em caso de erro

SKIP_CONTAINER=${1:-""}

./base_files/envs_validation.sh SECRET_KEY_BASE

# Verificar se foi passado --skip-container
if [[ "$1" == "--skip-container" ]]; then
  echo "✅ Ambiente preparado (containers serão gerenciados externamente)"
else
  echo "🚀 Iniciando ambiente: production"
  ./base_files/run_container.sh production --detach
fi
