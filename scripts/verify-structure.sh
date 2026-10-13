#!/usr/bin/env bash
# Internal integrity check. Run verify.sh for the complete gate.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
PROFILE_FILE=.agents/project-profile.conf
fail() { printf 'QUALITY GATE ERROR: %s\n' "$1" >&2; exit 1; }
require_content() {
  [[ -f "$1" ]] || fail "falta $1."
  LC_ALL=C grep -q '[^[:space:]]' "$1" || fail "$1 está vacío o solo contiene espacios."
}
profile_value() {
  local key="$1" count value
  count="$(awk -F= -v key="$key" '$1 == key { n++ } END { print n+0 }' "$PROFILE_FILE")"
  [[ "$count" -eq 1 ]] || fail "$PROFILE_FILE debe declarar exactamente una vez: $key."
  value="$(awk -v key="$key" 'index($0, key "=") == 1 { print substr($0, length(key)+2) }' "$PROFILE_FILE")"
  [[ "$value" =~ [^[:space:]] && "$value" != *undecided* && "$value" != *HITO0_PENDING* ]] || fail "$PROFILE_FILE debe resolver $key (not_applicable si corresponde)."
  printf '%s' "$value"
}
require_content "$PROFILE_FILE"
PHASE="$(profile_value phase)"
PENDING_TOTAL=0
case "$PHASE" in seed|initializing|project) ;; *) fail "phase desconocida '$PHASE'; usa seed, initializing o project." ;; esac

# Common governance and tools remain required in derived projects.
for file in AGENTS.md README.md STATE.md \
  docs/adr/0000-adopcion-gobernanza-agentica.md docs/adr/0001-perfiles-y-aplicabilidad.md \
  docs/adr/0003-autonomia-y-continuidad.md docs/adr/0004-producto-comportamiento-y-cierre.md \
  docs/adr/0005-gobernanza-proporcional-al-riesgo.md docs/adr/0006-gobernanza-verificable.md \
  docs/agent-capabilities.md docs/seed-upgrades.md \
  scripts/verify.sh scripts/verify-structure.sh scripts/install-hooks.sh \
  scripts/tests/verify-contract.sh scripts/tests/bootstrap-pilot.sh .githooks/pre-commit; do
  require_content "$file"
done
if [[ "$PHASE" == seed ]]; then
  for file in .agents/bootstrap.md .agents/stack-presets.md .agents/master-prompt.template.md \
    .agents/prd.template.md docs/adr/0000-template.md specs/templates/feature.template.md \
    .env.example .github/workflows/verify.yml; do
    require_content "$file"
  done
else
  for key in application_kind surfaces language runtime framework persistence ci_platform; do
    profile_value "$key" >/dev/null
  done
  for file in docs/adr/0002-arquitectura-base.md specs/templates/feature.md PROMPT-MAESTRO.md PRD.md docs/learning.md; do
    require_content "$file"
  done
  # Deliberately bounded: known unfilled template fields, not all Markdown brackets.
  # HITO0_PENDING is a LEGITIMATE pending marker (see profile L17 and Notion Modo A),
  # not a critical placeholder: count it and warn by phase, never fail on it alone.
  # Other [placeholders] keep failing.
  for file in PRD.md PROMPT-MAESTRO.md docs/adr/0002-arquitectura-base.md; do
    if grep -Eq '\[Nombre del|\[Nombre de|\[Aceptado por|\[Referencia a|\[Autoaceptación|\[Quién|\[Autorización|\[Por (spec|registro|unidad)|\[Umbral|\[Lista o ninguno\]|\[Resolver|\[Problema|\[Capacidades|\[Flujo|\[Requisito|\[Prueba|\[Medición|\[Decisiones|\[Título|\[Modalidad|\[Registro ligero|\[Decisiones que|\[Chequeo rápido|\[Detalla|\[Describe|\[Punto principal|Borrador \| Aprobado|Propuesto \| Aceptado' "$file"; then
      fail "$file contiene placeholders críticos; personalizar y confirmar antes del gate."
    fi
    pending_count="$(grep -c 'HITO0_PENDING' "$file" || true)"
    if [[ "$pending_count" -gt 0 ]]; then
      printf 'HITO0_PENDING: %s declara %s pendiente(s) sin resolver.\n' "$file" "$pending_count" >&2
      PENDING_TOTAL=$((PENDING_TOTAL + pending_count))
    fi
  done
  # Pending markers are data, not violations — but at sealing (project) they must
  # stay registered in STATE so they cannot silently vanish. initializing just warns.
  if [[ "$PHASE" == project && "$PENDING_TOTAL" -gt 0 ]]; then
    if ! grep -qi 'HITO0_PENDING\|pendiente' STATE.md; then
      fail 'hay HITO0_PENDING sin resolver en archivos sellados pero STATE no registra los pendientes; decláralos en STATE antes de sellar.'
    fi
    printf 'Pendientes registrados en STATE: %s en total (rastreados, no bloquean).\n' "$PENDING_TOTAL" >&2
  fi
  require_content scripts/verify-project.sh
  [[ -x scripts/verify-project.sh ]] || fail 'scripts/verify-project.sh debe ser ejecutable.'
  if [[ "$PHASE" == initializing ]]; then require_content .agents/bootstrap.md; fi
fi
printf 'Integridad documental: %s. No certifica aceptación semántica del producto.\n' "$PHASE"
