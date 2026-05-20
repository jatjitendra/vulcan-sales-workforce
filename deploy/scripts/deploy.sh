#!/usr/bin/env bash
# Deploy Sales & Workforce to DataOS Pacific (pacific-051426 / ct-sandbox).
set -euo pipefail

WORKSPACE="${WORKSPACE:-ct-sandbox}"
CONTEXT="${DATAOS_CONTEXT:-pacific-051426}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Deploying from: $ROOT"
echo "Context: $CONTEXT"
echo "Workspace: $WORKSPACE"

dataos-ctl context select --name "$CONTEXT"

if [[ -f "$ROOT/deploy/resources/instance_secret_warehouse.yml" ]]; then
  echo "Applying warehouse secret..."
  dataos-ctl apply -f "$ROOT/deploy/resources/instance_secret_warehouse.yml" -w "$WORKSPACE"
else
  echo "Skip secret (no instance_secret_warehouse.yml — copy from .example)"
fi

echo "Applying bundle..."
dataos-ctl apply -f "$ROOT/deploy/bundle.yml" -w "$WORKSPACE"

echo "Registering data product..."
dataos-ctl product apply -f "$ROOT/deploy/data_product_spec.yml"

echo "Applying scanner..."
dataos-ctl apply -f "$ROOT/deploy/scanner/dp_scanner.yml" -w "$WORKSPACE"

echo "Done. Verify:"
dataos-ctl product get
dataos-ctl get -t workflow -n scan-sales-workforce-dp-jk -w "$WORKSPACE" -r
