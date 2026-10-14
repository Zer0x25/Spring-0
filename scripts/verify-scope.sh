#!/usr/bin/env bash
# Check a unit's scope and closure independently. Omission is visible, never proof.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$ROOT_DIR"
phase="$(awk -F= '$1 == "phase" {print $2}' .agents/project-profile.conf | tr -d '[:space:]')"
MODE=check
scope=omitido
closure=omitido
incomplete=0
warn() { printf 'SCOPE WARNING: %s\n' "$1" >&2; incomplete=1; }
report() {
  printf 'CONTROL alcance=%s\nCONTROL cierre=%s\n' "$scope" "$closure"
  if [[ "$incomplete" == 1 ]]; then printf 'GOVERNANCE_STATUS=incomplete\n'
  elif [[ "$scope" == no_aplica && "$closure" == no_aplica ]]; then printf 'GOVERNANCE_STATUS=not_applicable\n'
  else printf 'GOVERNANCE_STATUS=verified\n'; fi
}
problem() {
  printf '%s: %s\n' "$1" "$2" >&2
  if [[ "$MODE" == warn ]]; then incomplete=1; report; exit 0; fi
  exit 1
}
case "$phase" in
  seed|mold) scope=no_aplica; closure=no_aplica; report; exit 0 ;;
  initializing) MODE=warn ;;
  project) ;;
  *) problem 'SCOPE VIOLATION' "fase desconocida '$phase'." ;;
esac
# Only metadata label decoration is normalized; glob stars in values survive.
normalize() {
  sed -E 's/^[[:space:]]*>[[:space:]]*//; s/^[[:space:]]*-[[:space:]]*//; s/^\*\*([^*]+):\*\*/\1:/; s/^\*\*([^*]+)\*\*:/\1:/'
}
field() {
  local key="$1"
  awk -v key="$key" 'index(tolower($0), tolower(key) ":") == 1 {
    sub(/^[^:]+:[[:space:]]*/, ""); sub(/[[:space:]]+$/, ""); print; exit
  }'
}
unit_id="$(normalize < STATE.md | field 'Unidad activa' | awk '{print $1}' | sed -E 's/[.,;]+$//')"
if [[ -z "$unit_id" ]]; then
  warn "STATE no declara Unidad activa; alcance y cierre omitidos."
  report; exit 0
fi
[[ "$unit_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || { warn "ID de unidad no interpretable."; report; exit 0; }
spec_file=""
for file in specs/*.md; do
  [[ -f "$file" ]] || continue
  stem="${file#specs/}"; stem="${stem%.md}"
  if [[ "${stem,,}" == "${unit_id,,}" ]]; then
    [[ -z "$spec_file" ]] || problem 'SCOPE VIOLATION' "más de una spec para '$unit_id'."
    spec_file="$file"
  fi
done
protected=()
authorized=()
if [[ -n "$spec_file" ]]; then
  unit_text="$(cat "$spec_file")"
  section="$(awk '/^## 4\. Archivos autorizados/{f=1;next} /^## /{f=0} f' "$spec_file")"
else
  unit_text="$(awk -v id="$unit_id" '
    /^LIG-[^[:space:]]+[[:space:]]/ {active=($1 == id)} active {print}
  ' STATE.md)"
fi
metadata="$(printf '%s\n' "$unit_text" | normalize)"
unit_status="$(printf '%s\n' "$metadata" | field Estado)"
if [[ -z "$unit_status" && "$unit_id" == LIG-* ]]; then
  unit_status="$(printf '%s\n' "$unit_text" | head -1 | awk -F ' — ' '{print $NF}')"
fi

# Closure runs BEFORE base resolution and diff checks, including clean worktrees.
if [[ "${unit_status,,}" == cerrada ]]; then
  mapfile -t criteria < <({
    printf '%s\n' "$unit_text" | grep -E '^[[:space:]]*\|[[:space:]]*CA-[0-9]+[[:space:]]*\|' || :
    printf '%s\n' "$metadata" | field Criterios
  } | grep -oE 'CA-[0-9]+' | sort -uV || :)
  if [[ ${#criteria[@]} == 0 ]]; then
    warn "unidad Cerrada sin criterios CA interpretables; cierre omitido."
  else
    for ca in "${criteria[@]}"; do
      mapfile -t evidence < <(printf '%s\n' "$metadata" | awk -v ca="$ca" '
        index($0, "Evidencia " ca ":") == 1 {sub(/^[^:]+:[[:space:]]*/, ""); print}
      ')
      [[ ${#evidence[@]} == 1 ]] || problem 'EVIDENCIA FALTANTE' "$ca necesita una declaración explícita y única."
      row="${evidence[0]}"
      evidence_field() {
        printf '%s\n' "$row" | tr ';' '\n' | awk -F= -v key="$1" '
          {k=$1; gsub(/^[[:space:]]+|[[:space:]]+$/, "", k)}
          k == key {n++; v=substr($0,index($0,"=")+1); gsub(/^[[:space:]]+|[[:space:]]+$/, "",v)}
          END {if (n == 1) print v}
        '
      }
      verification="$(evidence_field verificacion)"
      result="$(evidence_field resultado)"
      artifact="$(evidence_field artefacto)"
      digest="$(evidence_field sha256)"
      [[ -n "$verification" && ! "${verification,,}" =~ pendiente|hito0_pending|\[ ]] \
        || problem 'EVIDENCIA FALTANTE' "$ca sin verificación concreta."
      [[ "$result" == pass ]] || problem 'EVIDENCIA FALTANTE' "$ca no declara resultado=pass."
      [[ -n "$artifact" && "$artifact" != /* && "$artifact" != ../* && "$artifact" != */../* \
        && "$artifact" != */.. && -f "$artifact" && ! -L "$artifact" ]] \
        || problem 'EVIDENCIA FALTANTE' "$ca sin artefacto relativo existente."
      resolved="$(realpath -e -- "$artifact")"
      [[ "$resolved" == "$ROOT_DIR/"* && "$digest" =~ ^[0-9a-f]{64}$ ]] \
        || problem 'EVIDENCIA FALTANTE' "$ca sin huella SHA-256 válida dentro del repo."
      actual="$(sha256sum -- "$artifact" | cut -d ' ' -f 1)"
      [[ "$actual" == "$digest" ]] || problem 'EVIDENCIA FALTANTE' "$ca: el artefacto cambió después de la evidencia."
    done
    closure=verificado
  fi
elif [[ "${unit_status,,}" =~ ^(borrador|aprobada|implementada|en\ curso|pendiente)$ ]]; then
  closure=no_aplica
else
  warn "estado de '$unit_id' no interpretable; cierre omitido."
fi

base="$(printf '%s\n' "$metadata" | field 'Base de alcance')"
if [[ -z "$base" || "$base" == *'['* ]]; then
  base=origin/main
  warn "sin SHA de inicio de unidad; fallback legacy origin/main."
else
  [[ "$base" =~ ^[0-9a-f]{40}$ || "$base" =~ ^[0-9a-f]{64}$ ]] \
    || problem 'SCOPE VIOLATION' "Base de alcance debe ser un SHA completo."
fi
if ! git rev-parse --verify "$base^{commit}" >/dev/null 2>&1; then
  warn "no hay base '$base'; alcance omitido."
  report; exit 0
fi
if ! git merge-base --is-ancestor "$base" HEAD; then
  problem 'SCOPE VIOLATION' "base '$base' no es ancestro de HEAD."
fi
# Include index-only changes, worktree changes and untracked paths, NUL delimited.
mapfile -d '' -t changed < <({
  git diff --name-only -z "$base" HEAD
  git diff --name-only -z "$base"
  git diff --cached --name-only -z "$base"
  git ls-files --others --exclude-standard -z
} | sort -zu)
if [[ -z "$unit_text" ]]; then
  if [[ ${#changed[@]} != 0 ]]; then
    problem 'SCOPE VIOLATION' "unidad '$unit_id' sin spec ni bloque LIG con cambios."
  fi
  warn "unidad '$unit_id' sin registro; alcance omitido."
  report; exit 0
fi
if [[ -n "$spec_file" ]]; then
  [[ -n "$section" ]] || problem 'SCOPE VIOLATION' "sin sección '## 4. Archivos autorizados'."
  normalized="$(printf '%s\n' "$section" | grep -E '^[[:space:]]*-' | normalize || :)"
  extract_paths() {
    sed -E 's/^[^:]+:[[:space:]]*//' | tr ',' '\n' \
      | sed -E 's/^[[:space:]`]+//; s/[[:space:]`]+$//' \
      | grep -vE '^(nada adicional|ninguno|ninguna|nada|)$' | sort -u
  }
  mapfile -t authorized < <(printf '%s\n' "$normalized" | grep -iE '^(Editables|Rutas):|^[^:]*[./][^:]*$' | extract_paths)
  mapfile -t protected < <(printf '%s\n' "$normalized" | grep -iE '^Protegidos:' | extract_paths)
  authorized+=("$spec_file")
else
  lig_paths="$(printf '%s\n' "$metadata" | field 'Alcance/autoridad')"
  if [[ -z "$lig_paths" ]]; then
    warn "LIG '$unit_id' sin rutas interpretables; alcance omitido."
    report; exit 0
  fi
  # Only the first semicolon segment contains paths; author/date are not permissions.
  mapfile -t authorized < <(printf '%s\n' "${lig_paths%%;*}" | tr ',' '\n' \
    | sed -E 's/^[[:space:]`]+//; s/[[:space:]`]+$//' | grep -v '^$')
fi
authorized+=(STATE.md docs/learning.md)
is_authorized() {
  local path="$1" pattern
  for pattern in "${protected[@]}"; do [[ "$path" == $pattern ]] && return 1; done
  for pattern in "${authorized[@]}"; do [[ "$path" == $pattern ]] && return 0; done
  return 1
}
for path in "${changed[@]}"; do
  is_authorized "$path" || problem 'SCOPE VIOLATION' "la unidad '$unit_id' modificó '$path', fuera de Archivos autorizados."
done
scope=verificado
printf 'Alcance verificado para %s: %d rutas contra %s.\n' "$unit_id" "${#changed[@]}" "$base"
trace_line="$(printf '%s\n' "$metadata" | field Trazabilidad)"
while IFS= read -r tid; do
  [[ -n "$tid" ]] || continue
  [[ -f "specs/$tid.md" ]] || printf 'TRACE WARNING: SPEC:%s inexistente.\n' "$tid" >&2
done < <(printf '%s\n' "$trace_line" | grep -oE 'SPEC:[A-Za-z0-9._-]+' | sed 's/^SPEC://' || :)
report
