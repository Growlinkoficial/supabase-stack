#!/bin/bash
# utils.sh - Funções utilitárias para o instalador

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local msg=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    case $level in
        "INFO") echo -e "${BLUE}[INFO]${NC} $timestamp - $msg" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $timestamp - $msg" ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $timestamp - $msg" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $timestamp - $msg" ;;
    esac
}

# Limpeza de CRLF
fix_crlf() {
    if grep -q $'\r' "$1" 2>/dev/null; then
        sed -i 's/\r$//' "$1"
    fi
}
