#!/usr/bin/env bash
# Mechanical scope-lock and per-criterion evidence check.
# Invoked by verify.sh in phase=project (blocks) and phase=initializing (warns).
# In phase=seed it does not run (the mold runs no product unit).
#
# Design principle: the gate governs the FLOW, not the repo structure. It blocks
# only on CONFIRMED scope violation or confirmed missing evidence. Anything it
# cannot parse/understand is a warning + skip (fail-safe), never a block — the
# molde must keep mutating with the project without the gate freezing its shape.
set -uo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="${1:-check}"   # check (default) | warn
PROFILE_FILE=".agents/project-profile.conf"
STATE_FILE="STATE.md"
warn() { printf 'SCOPE WARNING: %s\n' "$1" >&2; }
violation() { printf 'SCOPE VIOLATION: %s\n' "$1" >&2; exit 1; }
evidence_missing() { printf 'EVIDENCIA FALTANTE: %s\n' "$1" >&2; exit 1; }

phase="$(awk -F= '$1 == "phase" { print substr($0, index($0, "=")+1) }' "$PROFILE_FILE" 2>/dev/null | tr -d '[:space:]')"
case "$phase" in
  seed) exit 0 ;;
  initializing) MODE=warn ;;
  project) MODE=check ;;
  "") violation "no se puede leer la fase en $PROFILE_FILE." ;;
  *) violation "fase desconocida '$phase' en $PROFILE_FILE." ;;
esac

# --- Parse active unit id: first token after "Unidad activa:" ---------------
unit_id=""
if [[ -f "$STATE_FILE" ]]; then
  unit_id="$(grep -E '^[[:space:]-]*Unidad activa:' "$STATE_FILE" \
    | head -1 | sed -E 's/^[^:]*:[[:space:]]*//' | awk '{print $1}' | tr -d '.,;')"
fi
if [[ -z "$unit_id" ]]; then
  # No declared unit => no product unit in flight. Not a violation; the flow has
  # nothing to scope-lock yet. Warn and skip (fail-safe), do not block.
  [[ "$MODE" == check ]] || warn "STATE no declara 'Unidad activa'; se omite verificación de alcance."
  exit 0
fi

# --- Locate the unit spec: specs/<id>.md, else case-insensitive match --------
spec_file=""
[[ -f "specs/${unit_id}.md" ]] && spec_file="specs/${unit_id}.md"
if [[ -z "$spec_file" ]]; then
  match="$(ls specs/ 2>/dev/null | grep -iF "${unit_id}" | head -1)"
  [[ -n "$match" && -f "specs/${match}" ]] && spec_file="specs/${match}"
fi
if [[ -z "$spec_file" ]]; then
  # Tier 3 light unit (LIG-*) is authorized by policy to live in STATE without a
  # spec (AGENTS §2, ADR 0005). If such a block exists, read its authorized paths
  # from STATE and verify scope against them — the gate must not contradict policy.
  if [[ "$unit_id" == LIG-* ]]; then
    lig_mode=1
    lig_paths="$(grep -iE "^Alcance/autoridad:" STATE.md 2>/dev/null | head -1 | sed -E 's/^Alcance\/autoridad:[[:space:]]*//I')"
    if [[ -n "$lig_paths" ]]; then
      # Split on both ',' and ';', drop prose (the entry is "path; author; date":
      # keep only the first path-like token per segment).
      mapfile -t authorized < <(printf '%s\n' "$lig_paths" \
        | tr ',;' '\n\n' \
        | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
        | grep -E '[./]' | sort -u)
      authorized+=("STATE.md" "docs/learning.md")
      if [[ "${#authorized[@]}" -eq 0 ]]; then
        [[ "$MODE" == check ]] || { warn "bloque LIG-* de '$unit_id' sin rutas parseables; se omite verificación de alcance."; }
        exit 0
      fi
    else
      # No parseable authorized paths → fail-safe (advise, never block).
      [[ "$MODE" == check ]] || warn "unidad LIG-* '$unit_id' sin rutas en STATE; se omite verificación de alcance."
      exit 0
    fi
  else
    # Unit declared but spec absent and not a light unit. Only a REAL block when
    # work is actually in flight (changes vs base); sealing Hito-0 with a declared
    # next-unit but no committed work yet is legitimate → fail-safe warn.
    if git rev-parse --verify origin/main >/dev/null 2>&1 && [[ -n "$(git diff --name-only origin/main...HEAD 2>/dev/null; git diff --name-only origin/main 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
      [[ "$MODE" == check ]] && violation "la unidad '$unit_id' no tiene spec (se esperaba specs/${unit_id}.md) y hay cambios sin alcance declarado." || { warn "spec de '$unit_id' ausente con cambios; se omite verificación de alcance."; exit 0; }
    else
      [[ "$MODE" == check ]] || warn "spec de '$unit_id' ausente sin cambios en vuelo; se omite verificación de alcance."
      exit 0
    fi
  fi
fi

# --- Parse authorized paths from "## 4. Archivos autorizados" ----------------
# For a Tier 3 light unit (LIG-*) the paths were already read from STATE above
# (lig_mode=1) and re-reading a non-existent spec would be wrong; skip to diff.
if [[ "${lig_mode:-0}" != 1 ]]; then
  # Authorized section runs to the next "## " heading. Only bullet lines whose
  # content is path-like (contains '/' or '.') become entries; prose is ignored.
  section="$(awk '/^## 4\. Archivos autorizados/{f=1;next} /^## /{f=0} f' "$spec_file")"
  if [[ -z "$section" ]]; then
    [[ "$MODE" == check ]] && violation "la spec de '$unit_id' no tiene sección '## 4. Archivos autorizados'." || { warn "sin sección de archivos autorizados; se omite verificación de alcance."; exit 0; }
  fi
  mapfile -t authorized < <(printf '%s\n' "$section" \
    | grep -E '^[[:space:]]*-' \
    | sed -E 's/^[[:space:]]*-[[:space:]]*//' \
    | sed -E 's/^(Editables|Protegidos|Rutas|Ampliación)[[:space:]]*:[[:space:]]*//I' \
    | tr ',' '\n' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' \
    | grep -E '[./]' \
    | grep -vE '^(nada|ninguno|adicional|si|no)$' \
    | sort -u)
  # The unit's own spec, STATE and learning are always authorized bookkeeping files.
  authorized+=("specs/${unit_id}.md" "STATE.md" "docs/learning.md")
  if [[ "${#authorized[@]}" -eq 0 ]]; then
    [[ "$MODE" == check ]] && violation "no se pudieron extraer rutas autorizadas de la spec de '$unit_id'." || { warn "sin rutas autorizadas extraíbles; se omite verificación de alcance."; exit 0; }
  fi
fi

# --- Diff against authorized base (origin/main); skip if no base -------------
base="origin/main"
git rev-parse --verify "$base" >/dev/null 2>&1 || { warn "no hay base '$base'; se omite verificación de alcance."; exit 0; }
# Tracked changes (committed + unstaged/staged) AND untracked new files: a new
# file outside scope is as much a violation as an edit. --exclude-standard honors
# .gitignore so build artifacts/node_modules don't trip the lock.
mapfile -t changed < <(git diff --name-only "$base"...HEAD 2>/dev/null; git diff --name-only "$base" 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
mapfile -t changed < <(printf '%s\n' "${changed[@]}" | grep -v '^$' | sort -u)
[[ "${#changed[@]}" -eq 0 ]] && { [[ "$MODE" == check ]] || warn "sin cambios contra $base."; exit 0; }

is_authorized() {
  local path="$1" pat
  for pat in "${authorized[@]}"; do
    [[ "$path" == "$pat" ]] && return 0
    # shellcheck disable=SC2053
    [[ "$path" == $pat ]] && return 0
  done
  return 1
}
for path in "${changed[@]}"; do
  is_authorized "$path" || violation "la unidad '$unit_id' modificó '$path', fuera de 'Archivos autorizados'. Ampliar la spec antes de commitear."
done

# --- Per-criterion evidence for closed units --------------------------------
# A spec with state "Cerrada" that declares CA-* criteria must carry, per CA, an
# evidence line with a command + real result (no pending/placeholder).
unit_status="$(grep -iE '^>?[[:space:]]*Estado:' "$spec_file" | head -1)"
if printf '%s' "$unit_status" | grep -qi 'cerrada'; then
  mapfile -t criteria < <(grep -oE 'CA-[0-9]+' "$spec_file" | sort -uV)
  if [[ "${#criteria[@]}" -gt 0 ]]; then
    for ca in "${criteria[@]}"; do
      ev="$(grep -E "^- .*\\b${ca}\\b" "$spec_file" | grep -vE '\[pendiente|\[a completar|HITO0_PENDING' | head -1)"
      [[ -n "$ev" ]] || evidence_missing "$ca en '$unit_id' no tiene evidencia real (comando + resultado) antes de cerrar."
    done
  fi
fi

# --- Trazabilidad (Seed 010): SPEC:<id> tags map to specs/<id>.md ------------
# Non-blocking: a trace to a missing spec warns; it never blocks the gate.
trace_line="$(grep -iE '^>?[[:space:]]*Trazabilidad:' "$spec_file" | head -1)"
if [[ -n "$trace_line" ]]; then
  mapfile -t trace_ids < <(printf '%s\n' "$trace_line" | grep -oE 'SPEC:[A-Za-z0-9._-]+' | sed -E 's/^SPEC://' | sort -u)
  for tid in "${trace_ids[@]}"; do
    if [[ ! -f "specs/${tid}.md" ]]; then
      warn "trazabilidad SPEC:$tid apunta a specs/${tid}.md inexistente (documenta, no bloquea)."
    fi
  done
fi

[[ "$MODE" == check ]] && printf 'Alcance verificado para %s: %d rutas contra %s.\n' "$unit_id" "${#changed[@]}" "$base"
exit 0
