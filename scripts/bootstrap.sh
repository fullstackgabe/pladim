#!/usr/bin/env bash
set -euo pipefail

# =====================================================================
# Pladim — from-zero setup automation
# =====================================================================
# Automates everything that CAN be automated when standing up a fresh
# Supabase project: database schema, Row Level Security and the Google
# SSO provider config. Also writes the frontend .env.
#
# The ONLY manual prerequisite (cannot be scripted) is creating the
# Google OAuth client in Google Cloud Console. See the banner printed
# at the end for the exact redirect URI to register there.
#
# Required environment variables (export before running):
#   PROJECT_REF                              Supabase project ref
#   SUPABASE_DB_PASSWORD                     Database password
#   SITE_URL                                 Production site URL (https://...)
#   VITE_SUPABASE_PROJECT_URL                https://<ref>.supabase.co
#   VITE_SUPABASE_PUBLISHABLE_KEY            publishable key (sb_publishable_...)
#   SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID  from Google Cloud Console
#   SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET     from Google Cloud Console
#
# Usage:
#   ./scripts/bootstrap.sh
# =====================================================================

cd "$(dirname "$0")/.."

require() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "ERRO: variavel de ambiente '$name' nao definida." >&2
    exit 1
  fi
}

require PROJECT_REF
require SUPABASE_DB_PASSWORD
require SITE_URL
require VITE_SUPABASE_PROJECT_URL
require VITE_SUPABASE_PUBLISHABLE_KEY
require SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID
require SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET

echo "==> 1/4  Linkando o projeto ($PROJECT_REF)"
if ! supabase projects list >/dev/null 2>&1; then
  echo "Voce nao esta logado na CLI. Rode primeiro: supabase login" >&2
  exit 1
fi
supabase link --project-ref "$PROJECT_REF"

echo "==> 2/4  Aplicando schema + RLS (supabase/migrations)"
supabase db push

echo "==> 3/4  Aplicando config de Auth/SSO (supabase/config.toml)"
supabase config push

echo "==> 4/4  Gerando .env do frontend"
cat > .env <<EOF
VITE_SUPABASE_PROJECT_URL=$VITE_SUPABASE_PROJECT_URL
VITE_SUPABASE_PUBLISHABLE_KEY=$VITE_SUPABASE_PUBLISHABLE_KEY
EOF

cat <<EOF

=====================================================================
 Setup automatizado concluido.
=====================================================================
 PASSO MANUAL (Google Cloud Console) — unico que nao da pra script:
   1. https://console.cloud.google.com -> APIs & Services -> Credentials
   2. Create Credentials -> OAuth client ID -> Web application
   3. Authorized redirect URI (registre exatamente esta):
        https://${PROJECT_REF}.supabase.co/auth/v1/callback
   4. Copie Client ID / Secret para as variaveis:
        SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID
        SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET
      e rode este script de novo (o passo 3 aplica no Supabase).
=====================================================================
EOF
