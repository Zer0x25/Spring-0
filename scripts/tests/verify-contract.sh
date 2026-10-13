#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT
PASS_COUNT=0
FAIL_COUNT=0

make_seed_fixture() {
  local dir="$1" file
  mkdir -p "$dir/.agents" "$dir/docs/adr" "$dir/specs/templates" "$dir/scripts/tests" "$dir/.githooks" "$dir/.github/workflows"
  for file in AGENTS.md README.md STATE.md .agents/bootstrap.md .agents/stack-presets.md \
    .agents/master-prompt.template.md .agents/prd.template.md docs/adr/0000-adopcion-gobernanza-agentica.md \
    docs/adr/0000-template.md docs/adr/0001-perfiles-y-aplicabilidad.md docs/adr/0003-autonomia-y-continuidad.md \
    docs/adr/0004-producto-comportamiento-y-cierre.md docs/adr/0005-gobernanza-proporcional-al-riesgo.md \
    docs/adr/0006-gobernanza-verificable.md specs/templates/feature.template.md .env.example \
    docs/agent-capabilities.md .github/workflows/verify.yml; do
    printf '# Fixture: %s\nContenido deliberado del contrato.\n' "$file" > "$dir/$file"
  done
  cp "$REPO_ROOT/scripts/verify.sh" "$dir/scripts/verify.sh"
  if [[ -f "$REPO_ROOT/scripts/verify-structure.sh" ]]; then
    cp "$REPO_ROOT/scripts/verify-structure.sh" "$dir/scripts/verify-structure.sh"
  fi
  cp "$REPO_ROOT/scripts/install-hooks.sh" "$dir/scripts/install-hooks.sh"
  cp "$REPO_ROOT/.githooks/pre-commit" "$dir/.githooks/pre-commit"
  # Stubs bound recursion; separate tests prove the root executes and propagates them.
  printf '#!/usr/bin/env bash\nprintf "CONTRACT_REACHED\\n"\n' > "$dir/scripts/tests/verify-contract.sh"
  printf '#!/usr/bin/env bash\nprintf "PILOT_REACHED\\n"\n' > "$dir/scripts/tests/bootstrap-pilot.sh"
  chmod +x "$dir/scripts/verify.sh"
  printf 'phase=seed\n' > "$dir/.agents/project-profile.conf"
}

make_project() {
  local dir="$1" file
  make_seed_fixture "$dir"
  printf 'phase=project\napplication_kind=cli\nsurfaces=terminal\nlanguage=bash\nruntime=bash\nframework=not_applicable\npersistence=not_applicable\nci_platform=not_applicable\n' > "$dir/.agents/project-profile.conf"
  for file in docs/adr/0002-arquitectura-base.md specs/templates/feature.md PROMPT-MAESTRO.md PRD.md docs/learning.md; do
    printf '# Fixture aprobada\nResultado y autoridad de prueba explícitos.\n' > "$dir/$file"
  done
  printf '#!/usr/bin/env bash\nprintf "PROJECT_GATE_REACHED\\n"\n' > "$dir/scripts/verify-project.sh"
  chmod +x "$dir/scripts/verify-project.sh"
  # Scope-lock wiring: the project gate delegates to verify-scope.sh (fail-safe by default).
  cp "$REPO_ROOT/scripts/verify-scope.sh" "$dir/scripts/verify-scope.sh" 2>/dev/null || true
}

# A project fixture with an active unit, its spec (authorized paths) and a git base,
# so the scope-lock and evidence controls can be exercised deterministically.
make_scoped_project() {
  local dir="$1"
  make_project "$dir"
  git -C "$dir" init --quiet
  git -C "$dir" config user.email contract@test
  git -C "$dir" config user.name contract
  printf 'Unidad activa: SCOPED-001. Siguiente: cerrar. Contador: 0.\n' > "$dir/STATE.md"
  cat > "$dir/specs/SCOPED-001.md" <<'SPEC'
# SCOPED-001 — unidad de contrato
> Estado: Cerrada
## 4. Archivos autorizados
- Editables: src/core/keep.ts, tests/keep.spec.ts, STATE.md
- Protegidos: nada adicional
## 5. Criterios
| CA-1 | comportamiento | tests/keep.spec.ts | verde |
- Evidencia CA-1: `bash tests/keep.spec.ts` → 0 passed.
SPEC
  mkdir -p "$dir/src/core" "$dir/tests"
  printf 'ok\n' > "$dir/src/core/keep.ts"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$dir/tests/keep.spec.ts"
  git -C "$dir" add -A >/dev/null 2>&1
  git -C "$dir" commit --quiet -m base >/dev/null 2>&1
  # Local base so scope-lock can diff without a network remote (fail-safe stays for real clones).
  git -C "$dir" update-ref refs/remotes/origin/main "$(git -C "$dir" rev-parse HEAD)"
}

assert_gate() {
  local expected="$1" dir="$2" label="$3" contains="${4:-}" output actual
  if output="$(cd "$dir" && bash scripts/verify.sh 2>&1)"; then actual=0; else actual=$?; fi
  if [[ "$actual" -eq "$expected" && "$output" == *"$contains"* ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL: %s (expected %s and %s, got %s)\n%s\n' "$label" "$expected" "$contains" "$actual" "$output"
  fi
}

seed="$TEMP_ROOT/seed"
make_seed_fixture "$seed"
assert_gate 0 "$seed" 'neutral seed without package.json'
assert_gate 0 "$seed" 'root runs contract tests' CONTRACT_REACHED
assert_gate 0 "$seed" 'root runs pilot' PILOT_REACHED
for file in .agents/stack-presets.md .agents/master-prompt.template.md .agents/prd.template.md \
  docs/adr/0001-perfiles-y-aplicabilidad.md docs/adr/0005-gobernanza-proporcional-al-riesgo.md \
  docs/adr/0006-gobernanza-verificable.md; do
  dir="$TEMP_ROOT/missing-seed-$(basename "$file")"
  make_seed_fixture "$dir"
  rm "$dir/$file"
  assert_gate 1 "$dir" "missing seed $file" "$file"
done
for value in '' '   '; do
  dir="$TEMP_ROOT/empty-seed"
  make_seed_fixture "$dir"
  printf '%s\n' "$value" > "$dir/AGENTS.md"
  assert_gate 1 "$dir" 'empty/whitespace governance' AGENTS.md
done
for phase in unknown 'seed=project'; do
  printf 'phase=%s\n' "$phase" > "$seed/.agents/project-profile.conf"
  assert_gate 1 "$seed" 'invalid phase' phase
done

# --- phase=mold: the mold governs itself as father, not as a derived product ---
make_mold() {
  local dir="$1"
  make_seed_fixture "$dir"
  printf 'phase=mold\n' > "$dir/.agents/project-profile.conf"
}
mold="$TEMP_ROOT/mold"
make_mold "$mold"
# mold requires the mold files (not product files): verify-project.sh must NOT exist.
assert_gate 0 "$mold" 'mold passes without product verifier' 'Integridad documental: mold'
rm "$mold/scripts/verify-project.sh" 2>/dev/null || true
assert_gate 0 "$mold" 'mold does not run product verifier' 'Integridad documental: mold'
# mold runs the contract tests but NOT the pilot (pilot is the seed lifecycle rehearsal).
assert_gate 0 "$mold" 'mold runs contract tests' CONTRACT_REACHED
# mold must NOT require any product metadata key; a bare phase=mold profile is complete.
printf 'phase=mold\n' > "$mold/.agents/project-profile.conf"
assert_gate 0 "$mold" 'mold needs no product keys' 'Integridad documental: mold'
# mold must NOT run scope-lock (the mold is not a product unit under lock).
make_mold "$mold"
cp "$REPO_ROOT/scripts/verify-scope.sh" "$mold/scripts/verify-scope.sh" 2>/dev/null || true
printf '#!/usr/bin/env bash\nexit 9\n' > "$mold/scripts/verify-scope.sh"
chmod +x "$mold/scripts/verify-scope.sh"
assert_gate 0 "$mold" 'mold skips scope-lock' 'Integridad documental: mold'
# a missing mold governance file still blocks (mold is not a free pass).
make_mold "$mold"
rm "$mold/docs/adr/0006-gobernanza-verificable.md"
assert_gate 1 "$mold" 'mold missing governance file blocks' 'docs/adr/0006-gobernanza-verificable.md'

printf 'phase=seed\nphase=seed\n' > "$seed/.agents/project-profile.conf"
assert_gate 1 "$seed" 'duplicate phase' phase
rm "$seed/.agents/project-profile.conf"
assert_gate 1 "$seed" 'missing profile' project-profile.conf
make_seed_fixture "$seed"
printf '#!/usr/bin/env bash\nexit 42\n' > "$seed/scripts/tests/verify-contract.sh"
assert_gate 42 "$seed" 'propagate contract failure'
make_seed_fixture "$seed"
printf '#!/usr/bin/env bash\nexit 43\n' > "$seed/scripts/tests/bootstrap-pilot.sh"
assert_gate 43 "$seed" 'propagate pilot failure'
make_seed_fixture "$seed"
printf '#!/usr/bin/env bash\nif\n' > "$seed/scripts/install-hooks.sh"
assert_gate 2 "$seed" 'reject invalid shell syntax' install-hooks.sh

project="$TEMP_ROOT/project"
make_project "$project"
assert_gate 0 "$project" 'project without package.json' PROJECT_GATE_REACHED
assert_gate 0 "$project" 'project also runs contract tests' CONTRACT_REACHED
for file in AGENTS.md STATE.md PRD.md PROMPT-MAESTRO.md docs/learning.md docs/adr/0002-arquitectura-base.md specs/templates/feature.md; do
  dir="$TEMP_ROOT/project-$(basename "$file")"
  make_project "$dir"
  rm "$dir/$file"
  assert_gate 1 "$dir" "missing project $file" "$file"
  printf ' \t\n' > "$dir/$file"
  assert_gate 1 "$dir" "empty project $file" "$file"
done
for marker in 'HITO0_PENDING' '[Nombre del producto y primera entrega]' 'Borrador | Aprobado'; do
  make_project "$project"
  printf '# PRD\n%s\n' "$marker" > "$project/PRD.md"
  assert_gate 1 "$project" 'unresolved critical template' PRD.md
done
for entry in 'PROMPT-MAESTRO.md|[Modalidad, responsable]' 'PROMPT-MAESTRO.md|[Registro ligero en STATE autorizado]' 'docs/adr/0002-arquitectura-base.md|[Detalla la decisión técnica]'; do
  file="${entry%%|*}"
  marker="${entry#*|}"
  make_project "$project"
  printf '# Documento pendiente\n%s\n' "$marker" > "$project/$file"
  assert_gate 1 "$project" 'critical authority or architecture field unresolved' "$file"
done
make_project "$project"
printf '# PRD\n[Guía](docs/learning.md) y REQ-1: salida verificable.\n' > "$project/PRD.md"
assert_gate 0 "$project" 'ordinary markdown links are valid'
printf '# Plantilla\n[Resultado verificable]\n' > "$project/specs/templates/feature.md"
assert_gate 0 "$project" 'reusable spec placeholders allowed'
printf '#!/usr/bin/env bash\nexit 7\n' > "$project/scripts/verify-project.sh"
assert_gate 7 "$project" 'propagate project verifier failure'
rm "$project/scripts/verify-project.sh"
assert_gate 1 "$project" 'missing project verifier' verify-project.sh
make_project "$project"
chmod -x "$project/scripts/verify-project.sh"
assert_gate 1 "$project" 'non-executable verifier' verify-project.sh
for key in application_kind surfaces language runtime framework persistence ci_platform; do
  make_project "$project"
  sed -i "/^$key=/d" "$project/.agents/project-profile.conf"
  assert_gate 1 "$project" "missing $key" "$key"
  printf '%s=undecided\n' "$key" >> "$project/.agents/project-profile.conf"
  assert_gate 1 "$project" "undecided $key" "$key"
  sed -i "s/^$key=.*/$key=   /" "$project/.agents/project-profile.conf"
  assert_gate 1 "$project" "whitespace $key" "$key"
  printf '%s=duplicate\n' "$key" >> "$project/.agents/project-profile.conf"
  assert_gate 1 "$project" "duplicate $key" "$key"
done
make_project "$project"
sed -i 's/phase=project/phase=initializing/' "$project/.agents/project-profile.conf"
assert_gate 0 "$project" 'initializing runs project gate and stays pending' 'pendiente de sellado'
rm "$project/.agents/bootstrap.md"
assert_gate 1 "$project" 'initialization retains recovery entrypoint' bootstrap.md

# --- Seed 009: mechanical scope-lock and per-criterion evidence ---------------
# BDD-1: authorized change passes the gate.
scoped="$TEMP_ROOT/scoped-ok"
make_scoped_project "$scoped"
printf 'cambio autorizado\n' >> "$scoped/src/core/keep.ts"
assert_gate 0 "$scoped" 'scope-lock passes authorized change' 'Alcance verificado'

# BDD-2: change outside authorized files blocks the gate with SCOPE VIOLATION.
scoped="$TEMP_ROOT/scoped-violation"
make_scoped_project "$scoped"
printf 'fuera de alcance\n' > "$scoped/src/core/forbidden.ts"
assert_gate 1 "$scoped" 'scope-lock blocks unauthorized change' 'SCOPE VIOLATION'

# BDD-3: closed unit missing per-criterion evidence blocks with EVIDENCIA FALTANTE.
scoped="$TEMP_ROOT/scoped-no-evidence"
make_scoped_project "$scoped"
sed -i '/Evidencia CA-1/d' "$scoped/specs/SCOPED-001.md"
assert_gate 1 "$scoped" 'closed unit without evidence blocks' 'EVIDENCIA FALTANTE'

# BDD-4/CA-5: seed does not run scope-lock; initializing warns without blocking.
seed_scope="$TEMP_ROOT/seed-scope"
make_seed_fixture "$seed_scope"
printf 'phase=seed\n' > "$seed_scope/.agents/project-profile.conf"
assert_gate 0 "$seed_scope" 'seed skips scope-lock' 'Gate de semilla'
scoped="$TEMP_ROOT/scoped-init-warn"
make_scoped_project "$scoped"
sed -i 's/phase=project/phase=initializing/' "$scoped/.agents/project-profile.conf"
printf 'Unidad activa: SCOPED-001.\n' > "$scoped/STATE.md"
printf 'fuera de alcance\n' > "$scoped/src/core/forbidden.ts"
assert_gate 0 "$scoped" 'initializing warns without blocking on scope' 'pendiente de sellado'

# Fail-safe: unparseable unit/spec never blocks (gate governs flow, not structure).
scoped="$TEMP_ROOT/scoped-unparseable"
make_scoped_project "$scoped"
printf 'sin unidad declarada\n' > "$scoped/STATE.md"
assert_gate 0 "$scoped" 'unparseable unit fails safe (warns)'
scoped="$TEMP_ROOT/scoped-nosection"
make_scoped_project "$scoped"
sed -i '/## 4. Archivos autorizados/,/## 5/d' "$scoped/specs/SCOPED-001.md"
assert_gate 1 "$scoped" 'missing authorized-paths section in project blocks' 'Archivos autorizados'

# No base available (fresh clone, no remote): scope-lock omits with warning, no block.
scoped="$TEMP_ROOT/scoped-nobase"
make_scoped_project "$scoped"
git -C "$scoped" update-ref -d refs/remotes/origin/main
printf 'cualquier cambio\n' >> "$scoped/src/core/keep.ts"
assert_gate 0 "$scoped" 'no base omits scope-lock without blocking'

# --- Seed 010: Notion arranque (dos modos, fail-safe, trazabilidad) ----------
# notion-context.sh: sin argumentos falla con código de uso.
if bash "$REPO_ROOT/scripts/notion-context.sh" >/dev/null 2>&1; then
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: notion-context sin argumentos debe fallar\n'
else PASS_COUNT=$((PASS_COUNT + 1)); fi

# notion-context.sh: URL de Notion sin sesión de agente → fail-safe, payload válido, exit 0.
nc_dir="$TEMP_ROOT/notion-ctx"
mkdir -p "$nc_dir"
if out="$(cd "$nc_dir" && bash "$REPO_ROOT/scripts/notion-context.sh" "https://app.notion.com/p/abc123" ctx.md 2>&1)"; then
  if grep -q '[^[:space:]]' "$nc_dir/ctx.md" && [[ "$out" == *NOTION*WARNING* || "$out" == *diferida* ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: notion-context fail-safe no advirtió o payload vacío\n%s\n' "$out"; fi
else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: notion-context fail-safe debe salir 0\n%s\n' "$out"; fi

# notion-context.sh: markdown precocinado por el agente se adopta tal cual.
printf '# Contexto\nDecisiones confirmadas del proyecto.\n' > "$nc_dir/cooked.md"
(cd "$nc_dir" && bash "$REPO_ROOT/scripts/notion-context.sh" cooked.md adopted.md >/dev/null 2>&1)
if grep -q 'Decisiones confirmadas' "$nc_dir/adopted.md"; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: notion-context no adoptó markdown del agente\n'; fi

# Trazabilidad: tag SPEC:<id> a spec inexistente advierte, no bloquea el gate.
trace="$TEMP_ROOT/trace"
make_scoped_project "$trace"
sed -i 's/^> Estado: Cerrada/> Estado: Cerrada\n> Trazabilidad: SPEC:MVP-CUT-01/' "$trace/specs/SCOPED-001.md"
if out="$(cd "$trace" && bash scripts/verify-scope.sh 2>&1)"; then
  if [[ "$out" == *TRACE*WARNING* || "$out" == *Alcance*verificado* || "$out" == *MVP-CUT-01* ]]; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: trazabilidad a spec inexistente no advirtió\n%s\n' "$out"; fi
else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: trazabilidad a spec inexistente bloqueó el gate\n%s\n' "$out"; fi

# El gate raíz NO depende de Notion: verify.sh no invoca notion-context.
if grep -q 'notion-context' "$REPO_ROOT/scripts/verify.sh"; then
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: verify.sh no debe depender de Notion\n'
else PASS_COUNT=$((PASS_COUNT + 1)); fi

# Gate de capacidad (CA-8): cuando el entorno no puede leer Notion, la salida
# "pegar a mano" (notion-context.sh adoptando markdown) NO bloquea — exit 0 y
# el gate de semilla sigue en verde. Es el fail-safe que reemplaza al Modo A.
nc_dir2="$TEMP_ROOT/notion-nocap"
mkdir -p "$nc_dir2"
(cd "$nc_dir2" && bash "$REPO_ROOT/scripts/notion-context.sh" "sin-capacidad-de-lectura" out.md >/dev/null 2>&1)
rc=$?
if [[ $rc -eq 0 ]] && grep -q '[^[:space:]]' "$nc_dir2/out.md"; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: salida "pegar a mano" sin capacidad debe ser fail-safe exit 0 (rc=%s)\n' "$rc"; fi

# --- Seed 012: gate↔HITO0_PENDING ---------------------------------------------
# HITO0_PENDING is a legitimate pending marker, not a critical placeholder:
# count + warn by phase, never fail on it alone. Other placeholders keep failing.
# BDD-1: initializing + HITO0_PENDING → warns, exit 0.
pend="$TEMP_ROOT/pending"
make_project "$pend"
sed -i 's/^phase=project/phase=initializing/' "$pend/.agents/project-profile.conf"
printf 'Meta con campo critico HITO0_PENDING sin resolver.\n' >> "$pend/PRD.md"
if out="$(cd "$pend" && bash scripts/verify-structure.sh 2>&1)"; then
  if [[ "$out" == *HITO0_PENDING* ]]; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-1 no advirtio de HITO0_PENDING\n%s\n' "$out"; fi
else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-1 initializing+HITO0_PENDING debe salir 0\n%s\n' "$out"; fi

# BDD-2: project + HITO0_PENDING + pendientes en STATE → warns, exit 0.
pend2="$TEMP_ROOT/pending2"
make_project "$pend2"
printf 'Meta con campo critico HITO0_PENDING sin resolver.\n' >> "$pend2/PRD.md"
printf '## Pendientes criticos\n- HITO0_PENDING: resolver hosting.\n' >> "$pend2/STATE.md"
assert_gate 0 "$pend2" 'BDD-2 project+HITO0_PENDING+STATE advierte sin bloquear'

# BDD-3: project + HITO0_PENDING SIN registro en STATE → fails.
pend3="$TEMP_ROOT/pending3"
make_project "$pend3"
printf 'Meta con campo critico HITO0_PENDING sin resolver.\n' >> "$pend3/PRD.md"
assert_gate 1 "$pend3" 'BDD-3 project+HITO0_PENDING sin STATE bloquea'

# BDD-4: a generic placeholder must still fail after the fix.
gen="$TEMP_ROOT/genplaceholder"
make_project "$gen"
sed -i 's/^phase=project/phase=initializing/' "$gen/.agents/project-profile.conf"
printf 'Producto: [Nombre del producto y primera entrega].\n' >> "$gen/PRD.md"
assert_gate 1 "$gen" 'BDD-4 placeholder generico sigue bloqueando'

# --- Seed 014: Tier 3 ↔ gate (LIG-* sin spec) --------------------------------
# RED first: policy (AGENTS §2) authorizes Tier 3 light units LIG-* in STATE
# without a spec, but the current gate VIOLATES any active unit without a spec
# when work is in flight. The fix makes verify-scope.sh read the authorized
# paths from the STATE light-unit block for LIG-* (fail-safe), while a business
# unit with no spec AND no LIG block keeps being a violation.
# BDD-1: LIG-* with in-flight changes inside its authorized paths → exit 0.
lig="$TEMP_ROOT/lig"
make_scoped_project "$lig"
# Commit the spec removal into the BASE so it is not an in-flight change: the LIG
# unit replaces the spec-based record; the setup artifact must not count as work.
git -C "$lig" rm -q --cached specs/SCOPED-001.md >/dev/null 2>&1
rm -f "$lig/specs/SCOPED-001.md"
git -C "$lig" add -A >/dev/null 2>&1
git -C "$lig" commit --quiet -m "retirar spec base" >/dev/null 2>&1
git -C "$lig" update-ref refs/remotes/origin/main "$(git -C "$lig" rev-parse HEAD)"
cat >> "$lig/STATE.md" <<'ST'

LIG-001 — corrección acotada — Tier 3: restaura comportamiento confirmado — en curso
Alcance/autoridad: src/core/keep.ts; zer0x; 2026-10-12
ST
sed -i 's/^Unidad activa: SCOPED-001/Unidad activa: LIG-001/' "$lig/STATE.md"
printf 'cambio dentro de alcance\n' >> "$lig/src/core/keep.ts"
if out="$(cd "$lig" && bash scripts/verify-scope.sh 2>&1)"; then
  if [[ "$out" == *"Alcance verificado"* || "$out" == *"sin cambios"* ]]; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-1 LIG-* en vuelo no paso\n%s\n' "$out"; fi
else
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-1 LIG-* en vuelo debe salir 0\n%s\n' "$out"
fi

# BDD-2: LIG-* with a change OUTSIDE its authorized paths → SCOPE VIOLATION.
lig2="$TEMP_ROOT/lig2"
make_scoped_project "$lig2"
git -C "$lig2" rm -q --cached specs/SCOPED-001.md >/dev/null 2>&1
rm -f "$lig2/specs/SCOPED-001.md"
git -C "$lig2" add -A >/dev/null 2>&1
git -C "$lig2" commit --quiet -m "retirar spec base" >/dev/null 2>&1
git -C "$lig2" update-ref refs/remotes/origin/main "$(git -C "$lig2" rev-parse HEAD)"
cat >> "$lig2/STATE.md" <<'ST'

LIG-001 — corrección acotada — Tier 3: restaura comportamiento confirmado — en curso
Alcance/autoridad: src/core/keep.ts; zer0x; 2026-10-12
ST
sed -i 's/^Unidad activa: SCOPED-001/Unidad activa: LIG-001/' "$lig2/STATE.md"
printf 'cambio fuera de alcance\n' >> "$lig2/src/core/forbidden.ts"
if out="$(cd "$lig2" && bash scripts/verify-scope.sh 2>&1)"; then
  FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-2 LIG-* fuera de alcance debe bloquear\n%s\n' "$out"
else
  if [[ "$out" == *"SCOPE VIOLATION"* ]]; then PASS_COUNT=$((PASS_COUNT + 1)); else FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL: BDD-2 no bloqueo por SCOPE VIOLATION\n%s\n' "$out"; fi
fi

# BDD-3: business unit, no spec, no LIG block, changes in flight → violation.
lig3="$TEMP_ROOT/lig3"
make_scoped_project "$lig3"
git -C "$lig3" rm -q --cached specs/SCOPED-001.md >/dev/null 2>&1
rm -f "$lig3/specs/SCOPED-001.md"
git -C "$lig3" add -A >/dev/null 2>&1
git -C "$lig3" commit --quiet -m "retirar spec base" >/dev/null 2>&1
git -C "$lig3" update-ref refs/remotes/origin/main "$(git -C "$lig3" rev-parse HEAD)"
sed -i 's/^Unidad activa: SCOPED-001/Unidad activa: FEAT-999/' "$lig3/STATE.md"
printf 'cambio sin alcance\n' >> "$lig3/src/core/keep.ts"
assert_gate 1 "$lig3" 'BDD-3 unidad sin spec ni LIG sigue siendo violacion'

hook_repo="$TEMP_ROOT/hooks"
mkdir -p "$hook_repo/scripts" "$hook_repo/.githooks"
git -C "$hook_repo" init --quiet
cp "$REPO_ROOT/scripts/install-hooks.sh" "$hook_repo/scripts/"
cp "$REPO_ROOT/.githooks/pre-commit" "$hook_repo/.githooks/"
bash "$hook_repo/scripts/install-hooks.sh" >/dev/null
if [[ "$(git -C "$hook_repo" config --local --get core.hooksPath)" == .githooks ]]; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: hook installation\n'
fi
printf 'verify contract: %s passed, %s failed\n' "$PASS_COUNT" "$FAIL_COUNT"
[[ "$FAIL_COUNT" -eq 0 ]]
