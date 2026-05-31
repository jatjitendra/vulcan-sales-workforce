#!/usr/bin/env bash
# Deploy Sales & Workforce Vulcan resource to Pacific (Spark + s3lhdepot).
set -euo pipefail

WORKSPACE="${WORKSPACE:-ct-sandbox}"
CONTEXT="${DATAOS_CONTEXT:-pacific-051426}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEPLOY_YAML="$ROOT/deploy/sales-workforce-jk-deploy.yaml"

echo "Deploying from: $ROOT"
echo "Context: $CONTEXT"
echo "Workspace: $WORKSPACE"
echo "Manifest: $DEPLOY_YAML"
echo "Config (cloud): config.yaml → s3lhdepot / spark"

dataos-ctl context select --name "$CONTEXT"

if [[ -f "$ROOT/deploy/resources/git_sync_secret.yml" ]]; then
  echo "Applying git sync secret..."
  dataos-ctl apply -f "$ROOT/deploy/resources/git_sync_secret.yml" -w "$WORKSPACE"
fi

echo "Applying Vulcan resource..."
dataos-ctl apply -f "$DEPLOY_YAML" -w "$WORKSPACE"

echo "Done. Verify (may need admin if 403):"
dataos-ctl get -t vulcan -w "$WORKSPACE" -n sales-workforce-jk 2>/dev/null || true
