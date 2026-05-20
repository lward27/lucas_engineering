#!/bin/sh
set -eu

: "${VITE_APP_WS_SERVER_URL:?VITE_APP_WS_SERVER_URL is required}"

asset_root="${EXCALIDRAW_ASSET_ROOT:-/usr/share/nginx/html}"
old_url="${VITE_APP_WS_SERVER_OLD_URL:-https://oss-collab.excalidraw.com}"

matches="$(grep -Rsl "$old_url" "$asset_root" || true)"
if [ -z "$matches" ]; then
  echo "expected collaboration URL not found in Excalidraw assets: $old_url" >&2
  exit 1
fi

escaped_old="$(printf '%s' "$old_url" | sed 's/[|&\\]/\\&/g')"
escaped_new="$(printf '%s' "$VITE_APP_WS_SERVER_URL" | sed 's/[|&\\]/\\&/g')"

for file in $matches; do
  sed -i "s|$escaped_old|$escaped_new|g" "$file"
done

exec nginx -g "daemon off;"
