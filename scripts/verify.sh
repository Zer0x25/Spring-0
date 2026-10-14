#!/usr/bin/env bash
# Single closing gate for local use, hooks and CI. No skip switches.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
if structure_report="$(bash scripts/verify-structure.sh)"; then
  printf '%s\n' "$structure_report"
else
  code=$?
  printf '%s\n' "$structure_report"
  exit "$code"
fi
for script in scripts/verify.sh scripts/verify-structure.sh scripts/install-hooks.sh \
  scripts/prepare-derivative.sh scripts/verify-scope.sh \
  scripts/tests/verify-contract.sh scripts/tests/bootstrap-pilot.sh .githooks/pre-commit; do
  bash -n "$script"
done
bash scripts/tests/verify-contract.sh
PHASE="$(awk -F= '$1 == "phase" { print substr($0, index($0, "=")+1) }' .agents/project-profile.conf)"
if [[ "$PHASE" == seed ]]; then
  bash scripts/tests/bootstrap-pilot.sh
  printf 'Gate de semilla completo. No certifica una aplicación de producto.\n'
elif [[ "$PHASE" == mold ]]; then
  # The mold is the father, not a derived product: contract runs, but the pilot
  # (seed lifecycle rehearsal) and the product verifier do not apply.
  printf 'Gate del molde superado. No certifica una aplicación de producto.\n'
else
  if scope_report="$(bash scripts/verify-scope.sh)"; then
    printf '%s\n' "$scope_report"
  else
    code=$?
    printf '%s\n' "$scope_report"
    exit "$code"
  fi
  bash -n scripts/verify-project.sh
  ./scripts/verify-project.sh
  if [[ "$PHASE" == initializing ]]; then
    printf 'Verificación de inicialización superada; pendiente de sellado.\n'
  else
    if [[ "$scope_report" == *"GOVERNANCE_STATUS=incomplete"* || "$structure_report" == *"CONTROL pendientes=omitido"* ]]; then
      printf 'Gate tecnico superado; gobernanza incompleta: revisar controles omitidos antes de cerrar.\n'
    else
      printf 'Gate del proyecto superado; comprobar también aceptación y DoD.\n'
    fi
  fi
fi
