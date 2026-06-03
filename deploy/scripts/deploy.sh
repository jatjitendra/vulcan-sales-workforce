#!/usr/bin/env bash
# Deploy per Vulcan book: https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/
set -euo pipefail

WORKSPACE="${WORKSPACE:-ct-sandbox}"
CONTEXT="${DATAOS_CONTEXT:-pacific-051426}"
VULCAN_PRODUCT="${VULCAN_PRODUCT:-retail-inventory-jk}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST="$ROOT/vulcan-sales-workforce/${VULCAN_PRODUCT}/vulcan/${VULCAN_PRODUCT}-deploy.yaml"

echo "Deploying from: $ROOT"
echo "Product: $VULCAN_PRODUCT"
echo "Context: $CONTEXT"
echo "Workspace: $WORKSPACE"
echo "Manifest: $MANIFEST"

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: missing $MANIFEST"
  exit 1
fi

export PATH="${HOME}/.dataos/v2/bin:${PATH}"
dataos-ctl context select --name "$CONTEXT"
dataos-ctl tenant select -n "$WORKSPACE" 2>/dev/null || true

# Bitbucket: use platform secret ct-sandbox:bitbucket-cred-mr (same as practice-insights).
# No git secret apply needed unless admin provisioned a custom secret.

RESOURCE_NAME="$(grep -E '^name:' "$MANIFEST" | head -1 | awk '{print $2}')"

echo "Applying Vulcan resource (Step 4)..."
echo "Pacific resource name: $RESOURCE_NAME"
dataos-ctl resource apply -f "$MANIFEST"

echo "Done. Verify (Step 5):"
dataos-ctl resource get -t vulcan -n "$RESOURCE_NAME" 2>/dev/null || \
  echo "  (403? ask admin or check Pacific UI Runtime tab for plan/run/api)"
