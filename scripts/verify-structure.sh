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
case "$PHASE" in seed|mold) ;; initializing|project) ;; *) fail "phase desconocida '$PHASE'; usa seed, mold, initializing o project." ;; esac

# Common governance and tools remain required in derived projects.
for file in AGENTS.md README.md STATE.md \
  docs/adr/0000-adopcion-gobernanza-agentica.md docs/adr/0001-perfiles-y-aplicabilidad.md \
  docs/adr/0003-autonomia-y-continuidad.md docs/adr/0004-producto-comportamiento-y-cierre.md \
  docs/adr/0005-gobernanza-proporcional-al-riesgo.md docs/adr/0006-gobernanza-verificable.md \
  docs/agent-capabilities.md \
  scripts/verify.sh scripts/verify-structure.sh scripts/install-hooks.sh \
  scripts/prepare-derivative.sh scripts/verify-scope.sh \
  scripts/tests/verify-contract.sh scripts/tests/bootstrap-pilot.sh .githooks/pre-commit; do
  require_content "$file"
done
if [[ "$PHASE" == seed ]]; then
  for file in .agents/bootstrap.md .agents/stack-presets.md .agents/master-prompt.template.md \
    .agents/prd.template.md docs/adr/0000-template.md specs/templates/feature.template.md \
    .env.example .github/workflows/verify.yml; do
    require_content "$file"
  done
elif [[ "$PHASE" == mold ]]; then
  # The mold governs itself as father: it requires the mold files (same governance
  # and templates as seed) but no product artifacts (no PRD, ADR-0002, verifier).
  for file in .agents/bootstrap.md .agents/stack-presets.md .agents/master-prompt.template.md \
    .agents/prd.template.md docs/adr/0000-template.md specs/templates/feature.template.md \
    .env.example .github/workflows/verify.yml; do
    require_content "$file"
  done
  printf 'El molde se gobierna a si mismo como padre; no corre scope-lock ni verificador de producto.\n' >&2
else
  for key in application_kind surfaces language runtime framework persistence ci_platform; do
    profile_value "$key" >/dev/null
  done
  for file in docs/adr/0002-arquitectura-base.md specs/templates/feature.md PROMPT-MAESTRO.md PRD.md docs/learning.md; do
    require_content "$file"
  done
  # Deliberately bounded: known unfilled template fields, not all Markdown brackets.
  # HITO0_PENDING is a LEGITIMATE pending marker (see profile L17 and Notion Modo A),
  # not a generic placeholder: validate its ID/record and impact before sealing.
  # Other [placeholders] keep failing.
  for file in PRD.md PROMPT-MAESTRO.md docs/adr/0002-arquitectura-base.md; do
    if grep -Eq '\[Nombre del|\[Nombre de|\[Aceptado por|\[Referencia a|\[Autoaceptación|\[Quién|\[Autorización|\[Por (spec|registro|unidad)|\[Umbral|\[Lista o ninguno\]|\[Resolver|\[Problema|\[Capacidades|\[Flujo|\[Requisito|\[Prueba|\[Medición|\[Decisiones|\[Título|\[Modalidad|\[Registro ligero|\[Decisiones que|\[Chequeo rápido|\[Detalla|\[Describe|\[Punto principal|Borrador \| Aprobado|Propuesto \| Aceptado' "$file"; then
      fail "$file contiene placeholders críticos; personalizar y confirmar antes del gate."
    fi
    pending_count="$(grep -c 'HITO0_PENDING' "$file" || true)"
    if [[ "$pending_count" -gt 0 ]]; then
      printf 'HITO0_PENDING: %s declara %s pendiente(s) sin resolver.\n' "$file" "$pending_count" >&2
    fi
  done
  # Match pending IDs to explicit records, never to an incidental word in STATE.
  references="$(for file in PRD.md PROMPT-MAESTRO.md docs/adr/0002-arquitectura-base.md; do
    while IFS= read -r marker; do printf '%s %s\n' "$file" "$marker"; done \
      < <(grep -oE 'HITO0_PENDING(:[A-Za-z0-9_-]+)?' "$file" || :)
  done)"
  pending_report="$(printf '%s\n' "$references" | awk -v phase="$PHASE" '
    function trim(v) {gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); return v}
    function issue(v) {bad=1; print "PENDING ERROR: " v}
    FNR == NR {
      if ($0 ~ /^[[:space:]]*\|[[:space:]]*PEND-[0-9]+[[:space:]]*\|/) {
        n=split($0, row, "|"); id=trim(row[2]); impact=trim(row[3]); owner=trim(row[4]); condition=trim(row[5]); state=trim(row[6]);
        if (seen[id]++) issue(id " duplicado en STATE.md.");
        if (n != 7 || (impact != "critico" && impact != "diferible") || owner == "" || condition == "" || owner ~ /\[/ || condition ~ /\[/ || (state != "abierto" && state != "resuelto")) {
          issue(id " tiene registro incompleto o invalido en STATE.md.")
        } else {
          status[id]=state; kind[id]=impact; records++;
          if (state == "abierto" && impact == "critico") {
            if (phase == "project") issue(id " critico abierto: impide sellado/cierre.");
            else print "PENDING WARNING: " id " critico abierto; inicializacion pendiente.";
          } else if (state == "abierto") print "PENDING WARNING: " id " diferible abierto y registrado.";
        }
      }
      next
    }
    NF {
      file=$1; marker=$2; refs++;
      if (marker !~ /^HITO0_PENDING:PEND-[0-9]+$/) {
        issue(file " usa marcador sin ID valido; migrar a HITO0_PENDING:PEND-n."); next
      }
      sub(/^HITO0_PENDING:/, "", marker);
      if (!(marker in status)) issue(file ": " marker " no tiene registro valido en STATE.md.");
      else if (status[marker] != "abierto") issue(file ": " marker " resuelto conserva marcador pendiente.");
    }
    END {
      if (bad) print "CONTROL pendientes=omitido";
      else if (records || refs) print "CONTROL pendientes=verificado";
      else print "CONTROL pendientes=no_aplica";
    }
  ' STATE.md -)"
  printf '%s\n' "$pending_report"
  if [[ "$PHASE" == project && "$pending_report" == *"PENDING ERROR:"* ]]; then
    fail "pendientes sin trazabilidad o criticos abiertos; resolver antes del sellado/cierre."
  fi
  require_content scripts/verify-project.sh
  [[ -x scripts/verify-project.sh ]] || fail 'scripts/verify-project.sh debe ser ejecutable.'
  if [[ "$PHASE" == initializing ]]; then require_content .agents/bootstrap.md; fi
fi
printf 'Integridad documental: %s. No certifica aceptación semántica del producto.\n' "$PHASE"
