#!/usr/bin/env bash
# Single closing gate for local use, hooks and CI. No skip switches.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
bash scripts/verify-structure.sh
for script in scripts/verify.sh scripts/verify-structure.sh scripts/install-hooks.sh \
  scripts/tests/verify-contract.sh scripts/tests/bootstrap-pilot.sh .githooks/pre-commit; do
  bash -n "$script"
done
bash scripts/tests/verify-contract.sh
PHASE="$(awk -F= '$1 == "phase" { print substr($0, index($0, "=")+1) }' .agents/project-profile.conf)"
if [[ "$PHASE" == seed ]]; then
  bash scripts/tests/bootstrap-pilot.sh
  printf 'Gate de semilla completo. No certifica una aplicación de producto.\n'
else
  # Mechanical scope-lock + per-criterion evidence: warns in initializing, blocks in project.
  if [[ "$PHASE" == project ]]; then
    bash scripts/verify-scope.sh
  else
    bash scripts/verify-scope.sh warn || true
  fi
  bash -n scripts/verify-project.sh
  ./scripts/verify-project.sh
  if [[ "$PHASE" == initializing ]]; then
    printf 'Verificación de inicialización superada; pendiente de sellado.\n'
  else
    printf 'Gate del proyecto superado; comprobar también aceptación y DoD.\n'
  fi
fi
