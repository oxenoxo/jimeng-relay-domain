#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="oxenoxo/jimeng-relay-domain"
URL="${1:-}"

if [ -z "$URL" ] && [ -f "$HOME/jimeng-url.txt" ]; then
  URL="$(tr -d '[:space:]' < "$HOME/jimeng-url.txt")"
fi

if [ -z "$URL" ]; then
  for FILE in /tmp/jimeng-tunnel.log /tmp/tunnel_url.txt; do
    if [ -f "$FILE" ]; then
      URL="$(grep -o 'https://[a-z0-9-]*\.tunnelmole\.net' "$FILE" | tail -1 || true)"
      [ -n "$URL" ] && break
    fi
  done
fi

if [[ ! "$URL" =~ ^https://[a-z0-9-]+\.tunnelmole\.net/?$ ]]; then
  echo "未找到有效 tunnelmole 地址。用法：bash sync-domain.sh https://xxxx.tunnelmole.net" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "需要 GitHub CLI：请先安装 gh 并登录 gh auth login" >&2
  exit 1
fi

URL="${URL%/}"
export LATEST_URL="$URL"
cd "$REPO_DIR"
/Users/oxohuang/.workbuddy/binaries/node/versions/22.22.2/bin/node - <<'NODE'
const fs = require('fs');
const path = require('path');
const out = {
  service: '即梦中转站',
  url: process.env.LATEST_URL,
  source: 'tunnelmole',
  updatedAt: new Date().toISOString(),
  status: 'online'
};
fs.writeFileSync(path.join(process.cwd(), 'latest.json'), JSON.stringify(out, null, 2) + '\n');
NODE

CONTENT=$(base64 < latest.json | tr -d '\n')
SHA=$(gh api "repos/$REPO/contents/latest.json" --jq '.sha')
gh api "repos/$REPO/contents/latest.json" \
  -X PUT \
  -f message='chore: update latest tunnel URL' \
  -f content="$CONTENT" \
  -f branch=main \
  -f sha="$SHA" >/dev/null

echo "已同步到 GitHub Pages：$URL"
