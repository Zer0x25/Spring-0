#!/usr/bin/env bash
# Export the current mold to a NEW independent checkout; never initialize in place.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
fail() { printf 'DERIVATION ERROR: %s\n' "$1" >&2; exit 1; }
[[ $# -eq 1 && -n "$1" ]] || fail 'uso: scripts/prepare-derivative.sh /ruta/nuevo-proyecto'
destination="$(realpath -m -- "$1")"
[[ "$destination" != "$ROOT" && "$destination" != "$ROOT/"* ]] || fail 'el destino no puede ser el molde ni estar dentro de él.'
[[ "$ROOT" != "$destination/"* ]] || fail 'el destino no puede contener al molde.'
if [[ -e "$destination" ]]; then
  if [[ -f "$destination/.agents/mold-origin.conf" ]] \
    && grep -qx 'generator=Spring-0' "$destination/.agents/mold-origin.conf" \
    && grep -Eq '^phase=(seed|initializing|project)$' "$destination/.agents/project-profile.conf"; then
    printf 'Derivado ya preparado; se conservan todos los archivos: %s\n' "$destination"
    exit 0
  fi
  fail 'el destino ya existe; elige una ruta nueva. No se sobrescribe contenido.'
fi
grep -qx 'phase=mold' "$ROOT/.agents/project-profile.conf" || fail 'la fuente debe estar en phase=mold.'
[[ "$(git -C "$ROOT" rev-parse --show-toplevel)" == "$ROOT" ]] || fail 'la fuente debe ser un checkout independiente del molde.'
source_commit="$(git -C "$ROOT" rev-parse HEAD)"
parent="$(dirname "$destination")"
[[ -d "$parent" ]] || fail 'el directorio padre del destino debe existir.'
staging="$(mktemp -d "$parent/.spring-0-export.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
# Export tracked files from the WORKTREE, including local fixes but no ignored
# secrets/untracked user files. The generator is explicit for its first local use.
while IFS= read -r -d '' file; do
  [[ -e "$ROOT/$file" ]] || continue
  [[ -f "$ROOT/$file" && ! -L "$ROOT/$file" ]] || fail "archivo no regular: $file"
  mkdir -p "$staging/$(dirname "$file")"
  cp -p -- "$ROOT/$file" "$staging/$file"
done < <(git -C "$ROOT" ls-files -z)
cp -p "$ROOT/scripts/prepare-derivative.sh" "$staging/scripts/prepare-derivative.sh"
content_sha256="$(cd "$staging" && find . -type f -print0 | LC_ALL=C sort -z | xargs -0 sha256sum | sha256sum | cut -d ' ' -f 1)"
cat > "$staging/.agents/mold-origin.conf" <<ORIGIN
generator=Spring-0
source_commit=$source_commit
content_sha256=$content_sha256
# Huella del contenido exportado antes de personalizar; puede incluir cambios locales.
ORIGIN
sed -i 's/^phase=mold$/phase=seed/' "$staging/.agents/project-profile.conf"
cat > "$staging/STATE.md" <<'STATE'
# Estado del proyecto — semilla

- Fase: `seed`; producto, arquitectura y autoridad pendientes de entrevista.
- Procedencia: `.agents/mold-origin.conf` (commit de la copia fuente y huella del contenido).
- Sin unidades activas ni autorizaciones heredadas del constructor.
- Siguiente paso: escribir «Inicia Hito 0» y seguir `.agents/bootstrap.md`.
- Falta de progreso: contador 0; sin bloqueos.
STATE
(cd "$staging" && bash scripts/verify-structure.sh)
git -C "$staging" init --quiet
# -T prevents moving into an existing directory if the destination appeared meanwhile.
[[ ! -e "$destination" ]] || fail 'el destino apareció durante la preparación.'
mv -T --no-clobber -- "$staging" "$destination"
[[ ! -e "$staging" ]] || fail 'no se publicó el derivado; el destino apareció durante la preparación.'
printf 'Derivado preparado en seed, sin commits: %s\n' "$destination"
