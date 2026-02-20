#!/usr/bin/env bash
set -euo pipefail

LEDGE_URL="http://localhost:8080"
RAW_KEY="code-whisperer-dev"
ENV_FILE="$(dirname "$0")/../.env"

echo "==> Bootstrapping Ledge tenant + agent..."

# SHA-256 hash the raw key (ledge stores the hash, authenticates with the raw key)
API_KEY_HASH=$(echo -n "$RAW_KEY" | shasum -a 256 | awk '{print $1}')

# 1. Create tenant (unauthenticated) — idempotent attempt: ignore 409 conflicts
echo "    Creating tenant..."
TENANT_RESP=$(curl -sf -X POST "$LEDGE_URL/api/v1/tenants" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"code-whisperer\", \"apiKeyHash\": \"$API_KEY_HASH\"}" || true)

if [ -z "$TENANT_RESP" ]; then
  echo "    Tenant may already exist, continuing..."
fi

# 2. Create agent (authenticated with raw key)
echo "    Creating agent..."
AGENT_RESP=$(curl -sf -X POST "$LEDGE_URL/api/v1/agents" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $RAW_KEY" \
  -d '{"name": "code-whisperer-agent", "description": "Code Whisperer Spring AI demo agent"}')

AGENT_ID=$(echo "$AGENT_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['agentId'])")

if [ -z "$AGENT_ID" ]; then
  echo "ERROR: Failed to extract agentId from response: $AGENT_RESP"
  exit 1
fi

echo "    Agent ID: $AGENT_ID"

# 3. Write / update .env
# Remove any existing LEDGE_* lines then append fresh values
if [ -f "$ENV_FILE" ]; then
  grep -v "^LEDGE_API_KEY=" "$ENV_FILE" | grep -v "^LEDGE_AGENT_ID=" > "$ENV_FILE.tmp"
  mv "$ENV_FILE.tmp" "$ENV_FILE"
fi

echo "LEDGE_API_KEY=$RAW_KEY" >> "$ENV_FILE"
echo "LEDGE_AGENT_ID=$AGENT_ID" >> "$ENV_FILE"

echo "==> Done. Written to $ENV_FILE:"
grep "LEDGE_" "$ENV_FILE"
