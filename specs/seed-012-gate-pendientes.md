# Spec: Seed 012 — Alinear el gate con la política de HITO0_PENDING (V5.2)

> Estado: Cerrada — implementada y verificada, cambios locales sin commit
> Nivel: Tier 1 — Riesgo alto; cambia un control bloqueante del gate (`verify-structure.sh`).
> Requisitos: mantenimiento de semilla; cierra la fricción F-01 del `docs/harness-metrics.md` (evidencia real del derivado GYM-2026).
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: el cambio de gobernanza se registra en esta spec + AGENTS (política vigente), conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el proyecto derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006. Las seeds son mantenimiento del molde; los derivados no generan seeds.

## 1. Objetivo y alcance

- **Resultado observable:** el marcador `HITO0_PENDING` deja de ser tabú en los tres archivos sellados (PRD/PROMPT-MAESTRO/ADR-0002). Pasa de *fallo crítico* a *pendiente legítimo rastreado*: el gate cuenta los pendientes y advierte, sin bloquear; y los demás placeholders críticos (campos `[...]` sin resolver) siguen bloqueando igual. Se elimina el workaround que el derivado GYM-2026 tuvo que hacer.
- **Incluye:** cambio en `scripts/verify-structure.sh` (separar `HITO0_PENDING` del resto de placeholders; en `initializing` advierte; en `project` advierte y exige que los pendientes estén declarados en STATE); casos de contrato adversarios en `scripts/tests/verify-contract.sh`; nota en `docs/seed-upgrades.md`; cierre de F-01 en `docs/harness-metrics.md`; esta spec.
- **Excluye:** cambiar la política de `HITO0_PENDING` en el perfil (L17 ya lo acepta); tocar `verify-scope.sh` o `verify.sh` más allá de lo necesario; promover automáticamente pendientes; borrar marcadores; nuevos hooks.
- **Pendientes críticos / supuestos aceptados:** la fase ya está disponible como `$PHASE` en `verify-structure.sh` (L21); el perfil ya trata `HITO0_PENDING` como valor válido (L17) — el fix alinea los tres archivos con ese mismo criterio.

## 2. Contratos e invariantes

- **Entrada:** PRD/PROMPT-MAESTRO/ADR-0002 de un derivado, posiblemente con `HITO0_PENDING` en campos críticos sin resolver.
- **Salida:** el gate **no falla** por `HITO0_PENDING`; cuenta los pendientes y emite un aviso (cuántos y en qué archivos). Los demás placeholders (`[Nombre...]`, `[Quién...]`, etc.) siguen siendo fallo.
- **Invariantes:**
  - **`HITO0_PENDING` es dato, no violación.** El gate lo cuenta y advierte; nunca bloquea por él.
  - **Otros placeholders siguen bloqueando.** El cambio es quirúrgico: solo `HITO0_PENDING` sale de la lista de fallo. Un campo `[...]` genérico sin resolver sigue siendo error.
  - **Límite por fase al sellar:** en `phase=project`, si hay `HITO0_PENDING` en los tres archivos, el gate advierte Y exige que exista una sección de pendientes en STATE (los pendientes no pueden desaparecer sin quedar registrados). En `initializing` solo advierte. En `seed` no corre (no hay archivos sellados).
  - **Fail-safe:** lo no parseable advierte, no bloquea (extiende el principio de V4.1/V5).
  - **Sin secretos, sin red:** el cambio es local al script de estructura.
  - El gate raíz sigue siendo una sola entrada (`verify.sh`); no se añade skip.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: HITO0_PENDING en initializing advierte sin bloquear
  Dado un derivado en initializing con PRD que contiene HITO0_PENDING
  Cuando corre el gate
  Entonces advierte de los pendientes y sale 0

Escenario BDD-2: HITO0_PENDING en project advierte y exige registro en STATE
  Dado un derivado en project con HITO0_PENDING en PRD y una sección de pendientes en STATE
  Cuando corre el gate
  Entonces advierte del conteo y sale 0

Escenario BDD-3: HITO0_PENDING en project SIN registro en STATE bloquea
  Dado un derivado en project con HITO0_PENDING pero sin pendientes declarados en STATE
  Cuando corre el gate
  Entonces falla: los pendientes deben quedar registrados en STATE

Escenario BDD-4: otros placeholders siguen bloqueando
  Dado un derivado con PRD que contiene "[Nombre del producto]" (placeholder genérico)
  Cuando corre el gate
  Entonces falla igual que antes (el cambio no relaja los placeholders reales)
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Cerrar F-01 | BDD-1 | Fixture: initializing + HITO0_PENDING en PRD | advierte, exit 0 |
| CA-2 | Cerrar F-01 | BDD-2 | Fixture: project + HITO0_PENDING + pendientes en STATE | advierte conteo, exit 0 |
| CA-3 | Cerrar F-01 | BDD-3 | Fixture: project + HITO0_PENDING sin STATE | falla con mensaje claro |
| CA-4 | No relajar | BDD-4 | Fixture: placeholder genérico en PRD | sigue fallando |
| CA-5 | Mantenimiento semilla | ADR 0000–0006 intactos; contrato previo pasa | Revisión cruzada | política vigente única; contrato 90/90 base intacto |

## 4. Archivos autorizados

- **Editables:**
  - `scripts/verify-structure.sh` (separar `HITO0_PENDING` del patrón de placeholders; conteo + aviso; límite por fase vía `$PHASE`)
  - `scripts/tests/verify-contract.sh` (casos BDD-1..BDD-4)
  - `docs/seed-upgrades.md` (nota de la nueva política de pendientes)
  - `docs/harness-metrics.md` (cerrar F-01 con la evidencia del fix)
  - `specs/seed-012-gate-pendientes.md` (crear, esta spec)
  - `STATE.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables); `verify-scope.sh` y `verify.sh` salvo nota; `.githooks/pre-commit`.
- Ampliación de rutas antes de editar: si hace falta tocar `verify.sh`, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es mantenimiento de semilla sin código de producto: su ciclo rojo/verde ocurre a nivel de contrato. Es un control **bloqueante** modificado → merece rojo primero (el patrón de Seed 009).
- **Comandos y suites de cierre:** `bash scripts/tests/verify-contract.sh` (BDD-1..BDD-4 + todos los previos), `./scripts/verify.sh` (exit 0), `bash -n scripts/verify-structure.sh`, `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `bash -n scripts/verify-structure.sh && bash scripts/tests/verify-contract.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-5; verificar que el control modificado sigue siendo bloqueante donde debe (BDD-3/BDD-4) y que el fail-safe no se debilitó. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; contrato previo (90 casos) sigue pasando salvo los que esta unidad cambia a propósito.

## 6. Cierre y continuidad

### Evidencia — 2026-10-12

- **Contrato:** `bash scripts/tests/verify-contract.sh` → **94 passed, 0 failed** (90 previos intactos + 4 de Seed 012: BDD-1 advierte en initializing, BDD-2 project+STATE advierte, BDD-3 project sin STATE bloquea, BDD-4 placeholder genérico sigue fallando). Rojo confirmado pre-fix (BDD-1 bloqueaba); volteado a verde tras el cambio. `bash -n scripts/verify-structure.sh` sin error.
- **Gate raíz:** `./scripts/verify.sh`, salida 0. Contrato 94/0, piloto completo. `git diff --check` salida 0. ADR 0000–0006 intactos byte a byte; sin ADR de proyecto nuevo (espacio 0007+ libre).
- **Cambio quirúrgico:** en `verify-structure.sh`, `HITO0_PENDING` salió del patrón de placeholders críticos; ahora se cuenta y advierte por fase (initializing advierte; project advierte + exige registro en STATE o falla; seed no corre). Los demás placeholders `[...]` siguen bloqueando igual. `PENDING_TOTAL` inicializado en 0 (evita fallo con `set -u` en seed).
- **Fricción F-01 cerrada:** el workaround de GYM-2026 (redactar PRD sin el marcador) ya no es necesario; el Modo A de Notion traslada `Pendiente → HITO0_PENDING` y el gate ahora lo rastrea en vez de bloquearlo.

### Aprendizaje

Rojo primero rindió su señal: el RED de BDD-1 confirmó que el gate actual bloqueaba el marcador (era F-01 real, no hipotética), y el verde posterior verificó que el fix es quirúrgico — BDD-4 (placeholder genérico) siguió fallando durante todo el ciclo, prueba de que no se relajó el control. Un control bloqueante modificado merece rojo primero; un control no-bloqueante con fail-safe claro (Seed 010/011) puede implementarse directo en verde. Diferenciar los dos sigue siendo la guía.

### Commit

Pendiente de política de commits confirmada por el usuario para esta unidad.
