#!/usr/bin/env bash
set -euo pipefail

INPUT="-"
CONTEXT=""

usage() {
  cat <<'EOF'
Usage: redact-output.sh [--input FILE|-] [--context CONTEXT]

Read text, redact common credential-shaped values, and write sanitized text to stdout.
EOF
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --input) INPUT=${2:-}; shift 2 ;;
    --context) CONTEXT=${2:-}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

if [[ "$INPUT" != "-" ]]; then
  [[ -r "$INPUT" ]] || fail "input is not readable: $INPUT"
fi

awk '
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/ { private_key = 1; print "[REDACTED PRIVATE KEY]"; next }
  private_key && /-----END [A-Z ]*PRIVATE KEY-----/ { private_key = 0; next }
  private_key { next }
  { print }
' "$INPUT" | sed -E \
  -e 's/(Bearer[[:space:]]+)[^[:space:]]+/\1[REDACTED]/g' \
  -e 's/(Authorization:[[:space:]]*)[^[:space:]].*/\1[REDACTED]/' \
  -e 's/(([Pp]assword|[Pp]asswd|[Tt]oken|[Aa][Pp][Ii][_-]?[Kk]ey)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g' \
  -e 's/(client-certificate-data|certificate-authority-data|private-key-data):.*/\1: [REDACTED]/' \
  -e 's#(postgres|postgresql|mysql|mongodb)://[^[:space:]]+#\1://[REDACTED]#g'
