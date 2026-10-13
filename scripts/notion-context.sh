#!/usr/bin/env bash
# Notion context reader — arranque de Hito-1 en Modo A (enriquecido).
#
# IMPORTANTE (límite real de la plataforma): las tools MCP de Notion
# (GET_PAGE_MARKDOWN, etc.) solo son invocables DENTRO de una sesión del agente
# Hermes, NO desde un script de shell. El CLI `hermes tools` solo lista/habilita
# tools; no las invoca. Por eso este script tiene dos roles honestos:
#
#   1) Cuando lo ejecuta el AGENTE en su sesión, el agente llama directamente a
#      la tool MCP connectors__notion__GET_PAGE_MARKDOWN y usa su resultado.
#   2) Este script es el CONTRATO reproducible: valida argumentos, materializa
#      un payload de contexto y documenta el fail-safe. Si no hay forma de leer
#      Notion en este entorno (script/sin sesión), advierte y entrega un payload
#      "sin contexto" para que el arranque continúe con entrevista estándar.
#
# Read-only, opt-in. NO forma parte del gate de cierre: el gate nunca depende de
# Notion. Fail-safe: ante cualquier fallo de lectura, advierte y sale 0.
set -uo pipefail

usage() {
  printf 'Uso: %s <notion_url_o_id> [salida.md]\n' "$(basename "$0")" >&2
  printf 'Materializa el contexto de Notion para el arranque de Hito-1 (Modo A).\n' >&2
  exit 2
}
[[ $# -ge 1 ]] || usage

SOURCE="$1"
OUT="${2:-.notion-context.md}"
warn() { printf 'NOTION WARNING: %s\n' "$1" >&2; }

# Payload de fail-safe: vacío pero válido, para no bloquear el arranque.
emit_empty() {
  printf '# Contexto Notion\n\n%s\n' "$1" > "$OUT"
}

# Si ya se proveyó un markdown de contexto precocinado (el agente lo escribió
# tras llamar a la tool MCP en su sesión), lo adoptamos tal cual.
if [[ -f "$SOURCE" ]]; then
  if grep -q '[^[:space:]]' "$SOURCE"; then
    cp "$SOURCE" "$OUT"
    printf 'Contexto de Notion adoptado desde %s (%d bytes).\n' "$SOURCE" "$(wc -c < "$OUT")"
    exit 0
  fi
  warn "el markdown de contexto provisto está vacío."
  emit_empty "Sin contenido; continuar con entrevista estándar."
  exit 0
fi

# Si el contexto es una URL/ID de Notion y NO hay sesión de agente que lea la
# tool MCP, no inventamos lectura: advertimos y caemos a fail-safe. La lectura
# real la hace el agente vía connectors__notion__GET_PAGE_MARKDOWN en su sesión.
if ! command -v hermes >/dev/null 2>&1; then
  warn "entorno sin CLI Hermes; no se puede leer Notion aquí. El agente lo hará en su sesión."
  emit_empty "Lectura diferida a la sesión del agente; continuar con entrevista estándar."
  exit 0
fi

# El CLI Hermes no invoca tools MCP desde shell (solo las lista/habilita).
# Documentamos el hecho y caemos a fail-safe en lugar de fingir una lectura.
warn "la lectura de Notion requiere la tool MCP en sesión del agente (connectors__notion__GET_PAGE_MARKDOWN); no se invoca desde shell."
emit_empty "Lectura diferida a la sesión del agente; continuar con entreviesta estándar."
exit 0
