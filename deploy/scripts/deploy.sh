#!/usr/bin/env bash
# Deploy Sales & Workforce via single Vulcan resource (DataOS 2.0).
set -euo pipefail

WORKSPACE="${WORKSPACE:-ct-sandbox}"
CONTEXT="${DATAOS_CONTEXT:-pacific-051426}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY_YAML="$ROOT/deploy/sales-workforce-jk-deploy.yaml"

echo "Deploying from: $ROOT"
echo "Context: $CONTEXT"
echo "Workspace: $WORKSPACE"
echo "Manifest: $DEPLOY_YAML"

dataos-ctl context select --name "$CONTEXT"

if [[ -f "$ROOT/deploy/resources/instance_secret_warehouse.yml" ]]; then
  echo "Applying warehouse secret..."
  dataos-ctl apply -f "$ROOT/deploy/resources/instance_secret_warehouse.yml" -w "$WORKSPACE"
else
  echo "Skip secret (copy instance_secret_warehouse.yml.example if needed)"
fi

echo "Applying Vulcan resource..."
dataos-ctl apply -f "$DEPLOY_YAML" -w "$WORKSPACE"

echo "Done. Verify:"
dataos-ctl get -t vulcan -w "$WORKSPACE" 2>/dev/null || dataos-ctl get -w "$WORKSPACE" -r
