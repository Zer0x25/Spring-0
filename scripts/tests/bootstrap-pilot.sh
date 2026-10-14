#!/usr/bin/env bash
# Deterministic lifecycle rehearsal, not a real user interview or an agent evaluation.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PILOT_ROOT="$(mktemp -d)"
trap 'rm -rf "$PILOT_ROOT"' EXIT
for path in AGENTS.md README.md STATE.md .agents docs specs scripts .githooks .github .env.example; do
  cp -R "$REPO_ROOT/$path" "$PILOT_ROOT/$path"
done
cd "$PILOT_ROOT"
grep -qx 'phase=seed' .agents/project-profile.conf
bash scripts/verify-structure.sh >/dev/null
cat > .agents/project-profile.conf <<'PROFILE'
phase=initializing
application_kind=cli
surfaces=terminal
language=bash
runtime=bash
framework=not_applicable
persistence=not_applicable
ci_platform=not_applicable
PROFILE
cat > STATE.md <<'STATE'
# Piloto temporal — inicialización pendiente
Decisiones simuladas: CLI de saludo, ejecución local, sin persistencia ni dependencias.
Unidad activa: PILOT-INIT. Siguiente paso: crear PRD y verificador. Contador: 0.
Autoridad del experimento: Seed 008; no representa una entrevista con un usuario de producto.
STATE
if ./scripts/verify.sh > failure.log 2>&1; then
  printf 'FAIL: interrupted initialization accepted\n' >&2; exit 1
fi
grep -q 'docs/adr/0002-arquitectura-base.md' failure.log
[[ -f .agents/bootstrap.md && ! -e .agents/bootstrap.md.done ]]
grep -q 'PILOT-INIT' STATE.md
# Resume from files; do not restart decisions or overwrite the existing checkpoint.
cat > PRD.md <<'PRD'
# PRD — Saludo de ensayo
Estado: aprobado solo como fixture de Seed 008.
REQ-1: entrada Ana produce Hola, Ana.; sin argumento o con nombre vacío/solo espacios produce Hola, mundo.
Excluye persistencia, red y despliegue. Evidencia: bash tests/saludo.sh.
PRD
cat > docs/adr/0002-arquitectura-base.md <<'ADR'
# Arquitectura del ensayo
Estado: aceptado como fixture de Seed 008. Bash local sin dependencias.
Alternativa: runtime adicional descartado por no ser necesario para este ensayo.
Verificación: scripts/verify-project.sh. Reversión: eliminar el directorio temporal.
ADR
cat > PROMPT-MAESTRO.md <<'PROMPT'
# Delegación del ensayo
Fixture de Seed 008: seguir PRD y AGENTS, usar STATE para reanudar.
Solo cambios temporales de CLI y tests; commits de fixtures en Git temporal, sin efectos externos.
PROMPT
printf '# Aprendizaje\nEnsayo en curso; evidencia al cerrar.\n' > docs/learning.md
cp specs/templates/feature.template.md specs/templates/feature.md
mkdir -p tests
cat > scripts/verify-project.sh <<'GATE'
#!/usr/bin/env bash
set -euo pipefail
bash tests/saludo.sh
GATE
chmod +x scripts/verify-project.sh
# Smoke scaffold: Hito 0 can be sealed before implementing the product unit.
printf '#!/usr/bin/env bash\nset -euo pipefail\n[[ -s PRD.md && -s PROMPT-MAESTRO.md ]]\n' > tests/saludo.sh
./scripts/verify.sh > initialization.log
grep -q 'pendiente de sellado' initialization.log
[[ -f .agents/bootstrap.md ]]
# Rehearse interruption after archiving but before changing phase; recover from disk.
printf '\nSellado pendiente; si falta bootstrap, recuperar desde .done.\n' >> STATE.md
mv .agents/bootstrap.md .agents/bootstrap.md.done
if ./scripts/verify.sh > sealing-interrupted.log 2>&1; then exit 1; fi
grep -q 'bootstrap.md' sealing-interrupted.log
mv .agents/bootstrap.md.done .agents/bootstrap.md
./scripts/verify.sh > resumed-initialization.log
grep -q 'pendiente de sellado' resumed-initialization.log
# Seal only after success. Keep a pending checkpoint until the final gate passes.
mv .agents/bootstrap.md .agents/bootstrap.md.done
sed -i 's/^phase=initializing$/phase=project/' .agents/project-profile.conf
sed -i '/^## Estado inicial$/,/^## Reglas de gobernanza$/{ /^## Reglas de gobernanza$/!d; }' AGENTS.md
printf '\nHito 0 sellado; Hito 1 preparado. Siguiente: PILOT-001.\n' >> STATE.md
./scripts/verify.sh > seal.log

# Instantiate the real shipped spec, preserving its Markdown labels/sections.
sed -e 's/Borrador | Aprobada | Implementada | Cerrada/Aprobada/' \
  -e 's@\[Rutas exactas o patrón acotado; incluir spec, STATE y aprendizaje si se actualizan\]@saludo.sh, tests/saludo.sh@' \
  -e 's@\[Rutas o límites\]@ninguno@' \
  specs/templates/feature.template.md > specs/pilot-001.md
sed -i 's/Unidad activa: PILOT-INIT/Unidad activa: pilot-001/' STATE.md
# A local Git base makes this rehearsal exercise scope-lock, not its no-base fallback.
printf '*.log\n' > .gitignore
git init --quiet
git config user.email pilot@test
git config user.name pilot
git add -A
git -c core.hooksPath=/dev/null commit --quiet -m 'fixture: initialized project'
git update-ref refs/remotes/origin/main "$(git rev-parse HEAD)"
sed -i "s/\[SHA completo de inicio de esta unidad\]/$(git rev-parse HEAD)/" specs/pilot-001.md
cat > tests/saludo.sh <<'TEST'
#!/usr/bin/env bash
set -euo pipefail
[[ -f saludo.sh ]] || { printf 'MISSING_SALUDO\n' >&2; exit 1; }
[[ "$(bash saludo.sh Ana)" == 'Hola, Ana.' ]]
[[ "$(bash saludo.sh)" == 'Hola, mundo.' ]]
TEST
if bash tests/saludo.sh > red.log 2>&1; then exit 1; fi
grep -q MISSING_SALUDO red.log
cat > saludo.sh <<'APP'
#!/usr/bin/env bash
set -euo pipefail
printf 'Hola, %s.\n' "${1:-mundo}"
APP
./scripts/verify.sh > feature.log
sed -i 's/> Estado: Aprobada/> Estado: Cerrada/' specs/pilot-001.md
printf -- '- Evidencia CA-1: verificacion=bash tests/saludo.sh; resultado=pass; artefacto=saludo.sh; sha256=%s\n' \
  "$(sha256sum saludo.sh | cut -d ' ' -f 1)" >> specs/pilot-001.md
./scripts/verify.sh > close-feature.log
grep -q 'CONTROL cierre=verificado' close-feature.log
printf '\nCierre: pruebas y gate verdes; cambios temporales, sin commits en repositorios del usuario.\n' >> specs/pilot-001.md
grep -q 'Alcance verificado para pilot-001' feature.log
# Finish the fixture unit before moving to the next scope.
git add AGENTS.md STATE.md specs/pilot-001.md saludo.sh tests/saludo.sh
git -c core.hooksPath=/dev/null commit --quiet -m 'fixture: first unit'
# Keep origin/main unchanged: next unit must use its own start SHA.
# A missed edge case of the original PRD creates a new lightweight record.
sed -i 's/Unidad activa: pilot-001/Unidad activa: LIG-PILOT-001/' STATE.md
cat >> STATE.md <<'STATE'

PILOT-001 terminada: REQ-1 comprobado con tests/saludo.sh y gate raíz.
LIG-PILOT-001 — Tier 3 — en curso
Criterios: CA-1
Resultado/fuente: entrada de espacios debe usar mundo; corrección confirmada por el contrato del ensayo Seed 008.
Alcance/autoridad: saludo.sh, tests/saludo.sh, STATE; experimento temporal autorizado, sin efectos externos.
Verificación/cierre: agregar caso de espacios, rojo/verde y gate. Siguiente: restaurar comportamiento. Contador: 0.
STATE
printf 'Base de alcance: %s\n' "$(git rev-parse HEAD)" >> STATE.md
cat >> tests/saludo.sh <<'TEST'
[[ "$(bash saludo.sh '   ')" == 'Hola, mundo.' ]] || { printf 'WHITESPACE_NAME\n' >&2; exit 1; }
TEST
if bash tests/saludo.sh > correction-red.log 2>&1; then exit 1; fi
grep -q WHITESPACE_NAME correction-red.log
cat > saludo.sh <<'APP'
#!/usr/bin/env bash
set -euo pipefail
name="${1:-}"
if [[ ! "$name" =~ [^[:space:]] ]]; then name=mundo; fi
printf 'Hola, %s.\n' "$name"
APP
./scripts/verify.sh > correction.log
grep -q 'Alcance verificado para LIG-PILOT-001' correction.log
sed -i 's/LIG-PILOT-001 — Tier 3 — en curso/LIG-PILOT-001 — Tier 3 — cerrada/' STATE.md
printf -- '- Evidencia CA-1: verificacion=bash tests/saludo.sh; resultado=pass; artefacto=saludo.sh; sha256=%s\n' \
  "$(sha256sum saludo.sh | cut -d ' ' -f 1)" >> STATE.md
./scripts/verify.sh > close-correction.log
grep -q 'CONTROL cierre=verificado' close-correction.log
printf '\nLIG-PILOT-001 terminada; rojo WHITESPACE_NAME y gate verde; sin commits en repositorios del usuario. Siguiente: ninguna.\n' >> STATE.md
printf '\nSeed 008: reanudar desde STATE conserva decisiones y distingue inicialización de producto; evidencia en gates y pruebas del ensayo.\n' >> docs/learning.md
# A fresh shell verifies the persisted checkpoint and final behavior.
bash -c 'set -euo pipefail; grep -q "LIG-PILOT-001 terminada" STATE.md; [[ -f .agents/bootstrap.md.done && ! -e .agents/bootstrap.md ]]; [[ "$(bash saludo.sh "   ")" == "Hola, mundo." ]]'
printf 'bootstrap pilot: interrupción/recuperación, sellado, Tier 2 rojo/verde, Tier 3 rojo/verde y reanudación correctos.\n'
printf 'Límite: decisiones simuladas; 2 interrupciones inducidas, 0 consultas reales, sin certificación de entrevista ni otros stacks.\n'
