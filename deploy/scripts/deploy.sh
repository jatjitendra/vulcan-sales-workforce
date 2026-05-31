#!/usr/bin/env bash
# Deploy per Vulcan book: https://tmdc-io.github.io/vulcan-book/guides/deployment_guide/
set -euo pipefail

WORKSPACE="${WORKSPACE:-ct-sandbox}"
CONTEXT="${DATAOS_CONTEXT:-pacific-051426}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST="$ROOT/domain-resource.yaml"

echo "Deploying from: $ROOT"
echo "Context: $CONTEXT"
echo "Workspace: $WORKSPACE"
echo "Manifest: $MANIFEST"

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: missing $MANIFEST"
  exit 1
fi

dataos-ctl context select --name "$CONTEXT"

if [[ -f "$ROOT/deploy/resources/git_sync_secret.yml" ]]; then
  echo "Applying git sync secret..."
  dataos-ctl resource apply -f "$ROOT/deploy/resources/git_sync_secret.yml" -w "$WORKSPACE"
fi

echo "Applying Vulcan resource (Step 4)..."
dataos-ctl resource apply -f "$MANIFEST" -w "$WORKSPACE"

echo "Done. Verify (Step 5):"
dataos-ctl resource get -t vulcan -w "$WORKSPACE" -n sales-workforce-jk 2>/dev/null || \
  echo "  (403? ask admin or check Pacific UI Runtime tab for plan/run/api)"
