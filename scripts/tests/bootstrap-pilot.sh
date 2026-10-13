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
Solo cambios temporales de CLI y tests. Sin commits ni efectos externos.
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
sed -i '/^## Estado inicial: semilla Hito 0$/,/^## Reglas de gobernanza$/{ /^## Reglas de gobernanza$/!d; }' AGENTS.md
printf '\nHito 0 sellado; Hito 1 preparado. Siguiente: PILOT-001.\n' >> STATE.md
./scripts/verify.sh > seal.log

cat > specs/pilot-001.md <<'SPEC'
# PILOT-001 — saludo, Tier 2
Autoridad: ensayo Seed 008. Fuente REQ-1. Rutas: saludo.sh, tests/saludo.sh, STATE y esta spec.
Dado Ana, al ejecutar saludo.sh, entonces imprime Hola, Ana.
Sin argumento imprime Hola, mundo. Verificar con tests/saludo.sh y gate raíz.
SPEC
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
printf '\nCierre: pruebas y gate verdes; cambios temporales, sin commit.\n' >> specs/pilot-001.md
# A missed edge case of the original PRD creates a new lightweight record.
cat >> STATE.md <<'STATE'

PILOT-001 terminada: REQ-1 comprobado con tests/saludo.sh y gate raíz.
LIG-PILOT-001 — Tier 3 — en curso
Resultado/fuente: entrada de espacios debe usar mundo; corrección confirmada por el contrato del ensayo Seed 008.
Alcance/autoridad: saludo.sh, tests/saludo.sh, STATE; experimento temporal autorizado, sin efectos externos.
Verificación/cierre: agregar caso de espacios, rojo/verde y gate. Siguiente: restaurar comportamiento. Contador: 0.
STATE
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
printf '\nLIG-PILOT-001 terminada; rojo WHITESPACE_NAME y gate verde; sin commit. Siguiente: ninguna.\n' >> STATE.md
printf '\nSeed 008: reanudar desde STATE conserva decisiones y distingue inicialización de producto; evidencia en gates y pruebas del ensayo.\n' >> docs/learning.md
# A fresh shell verifies the persisted checkpoint and final behavior.
bash -c 'set -euo pipefail; grep -q "LIG-PILOT-001 terminada" STATE.md; [[ -f .agents/bootstrap.md.done && ! -e .agents/bootstrap.md ]]; [[ "$(bash saludo.sh "   ")" == "Hola, mundo." ]]'
printf 'bootstrap pilot: interrupción/recuperación, sellado, Tier 2 rojo/verde, Tier 3 rojo/verde y reanudación correctos.\n'
printf 'Límite: decisiones simuladas; 2 interrupciones inducidas, 0 consultas reales, sin certificación de entrevista ni otros stacks.\n'
