# Spec: Seed 009 — Gobernanza ejecutable (scope-lock y evidencia mecánica)

> Estado: Cerrada — implementada y verificada, cambios locales sin commit
> Nivel: Tier 1 — Riesgo alto; altera controles de cierre (gate y hook). Sin ADR de proyecto nuevo: ver «Numeración ADR».
> Requisitos: mantenimiento de semilla; cierra hallazgos de la auditoría de la V4.0.0.
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: ver «Numeración ADR».
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006 (históricos, inmutables). No crea ADR de proyecto: ver «Numeración ADR». No crea ni altera PRD: es mantenimiento de semilla.

### Numeración ADR y rol de las seeds (decisión de diseño del molde)

Los ADR 0000–0006 son decisiones **del molde** (gobernanza del flujo agéntico) y sirven de **ejemplo/guía**, no de plantillas a copiar. Los ADR del **proyecto derivado** (arquitectura, stack, dominio) nacen en Hito 1+ y usan el espacio **0007 en adelante**, libre. Esta unidad de mantenimiento del molde **no consume un número de ADR**: registra su cambio de gobernanza en la spec + AGENTS (política operativa vigente), conforme al mecanismo de ADR 0006, y deja el espacio 0007+ intacto para el proyecto. El molde no sangra números al derivado.

Las **seeds** (`specs/seed-00X-*.md`) son unidades de **mantenimiento del molde**: iteraciones que construyen la plantilla. Pertenecen al repo semilla. Un derivado las hereda como referencia/historial de gobernanza y **no genera seeds**: su trabajo son unidades de producto (Tier 2/1 con spec, Tier 3 con registro ligero). Un derivado puede absorber upgrades de semilla posteriores según `docs/seed-upgrades.md`, sin que ello consuma su espacio de ADR de producto.

## 1. Objetivo y alcance

- **Resultado observable:** el gate deja de confiar en que el agente respeta el scope y registra evidencia por convención. Verifica mecánicamente dos controles que hoy solo existen como regla de prompt: (1) todo cambio committeado entra en los "Archivos autorizados" de la unidad activa; (2) toda unidad cerrada tiene evidencia real por criterio antes de pasar el gate.
- **Incluye:** nuevo script `scripts/verify-scope.sh` (scope-lock) e integración al gate raíz en `phase=project`; lector de unidad activa desde STATE; verificación de evidencia por criterio CA dentro del verificador del proyecto; ampliación del contrato con casos negativos/adversarios; nota de alcance en el README.
- **Excluye:** integración Notion/Linear (V5); motor de políticas genérico; clasificación automática de tier; tocar el gate en `phase=seed` (el molde no corre producto); certificar cumplimiento de un agente independiente (límite conocido).
- **Principio de mutación:** lo blindado es el flujo de gobernanza (clasificar → especificar → verificar → cerrar con evidencia; una sola entrada de gate). Todo lo demás —rutas, documentos, scripts, ADRs futuros, stack del proyecto— muta y crece con el proyecto. El gate verifica la gobernanza, no la estructura del repo.
- **Pendientes críticos / supuestos aceptados:** se asume que en `phase=project` siempre existe STATE con una unidad activa declarada y una spec (o registro ligero) con sección "Archivos autorizados". El alcance de la unidad en curso se compara contra `origin/main` (base autorizada), no contra el último commit. Estos supuestos se validan con el contrato antes de cerrar.

## 2. Contratos e invariantes

- **Entrada:** diff `git diff --name-only origin/main...HEAD` (o base configurada) + ruta de unidad activa parseada de STATE + lista "Archivos autorizados" de esa spec.
- **Salida:** exit 0 si todo cambio committeado está autorizado y toda unidad con cierre declarado tiene evidencia por criterio; exit 1 con mensaje `SCOPE VIOLATION: <ruta>` o `EVIDENCIA FALTANTE: <CA-id>` en caso contrario.
- **Invariantes:**
  - El gate raíz nunca ejecuta `git` fuera de un repo; si no hay remoto/base, omite scope-lock con advertencia explícita (no falla por falta de remoto).
  - Un archivo renombrado/borrado cuenta como cambio y debe estar autorizado.
  - `verify-scope.sh` no sustituye el gate: es un paso más invocado por `verify.sh`, propagando su exit code.
  - En `phase=seed` NO corre scope-lock (el molde no tiene unidad de producto). En `initializing` advierte pero no bloquea. En `project` bloquea.
  - Fallo seguro ante mutación: si la unidad activa, su sección «Archivos autorizados» o sus criterios no se pueden parsear, el verificador advierte y omite ese control —nunca bloquea por no entender—; bloquea solo ante violación de scope o evidencia ausente confirmadas. El gate gobierna el flujo, no congela la estructura.
  - La verificación de evidencia aplica solo a unidades que declaran criterios (CA); una unidad sin tabla de criterios (p. ej. registro ligero Tier 3) queda exenta.
  - La lista "Archivos autorizados" acepta rutas exactas y un único patrón acotado por línea (p. ej. `src/core/*.ts`); no evalúa expresiones arbitrarias.
  - La evidencia por criterio exige: identificador de criterio presente en la spec + una línea de evidencia con comando y resultado real (no placeholder) asociada a ese criterio.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: commit dentro del alcance pasa el gate
  Dado un proyecto en phase=project con unidad PILOT-001 y archivos autorizados declarados
  Cuando el diff solo toca rutas autorizadas
  Entonces ./scripts/verify.sh sale 0 y no emite SCOPE VIOLATION

Escenario BDD-2: commit fuera del alcance bloquea
  Dado el mismo proyecto
  Cuando el diff toca una ruta no listada en Archivos autorizados
  Entonces el gate falla con SCOPE VIOLATION nombrando la ruta exacta

Escenario BDD-3: unidad cerrada sin evidencia bloquea
  Dado una spec con criterios CA-1..CA-3 y estado Cerrada
  Cuando falta evidencia real de un criterio
  Entonces el gate falla con EVIDENCIA FALTANTE nombrando el CA

Escenario BDD-4: seed no bloquea por scope
  Dado phase=seed (molde)
  Cuando se ejecuta el gate
  Entonces no corre scope-lock ni falla por ausencia de remoto
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Mantenimiento semilla | BDD-1 | Contrato: fixture project, diff autorizado | gate exit 0 |
| CA-2 | Mantenimiento semilla | BDD-2 | Contrato: fixture con ruta no autorizada | exit 1, mensaje SCOPE VIOLATION |
| CA-3 | Mantenimiento semilla | BDD-3 | Contrato: spec Cerrada con CA sin evidencia | exit 1, mensaje EVIDENCIA FALTANTE |
| CA-4 | Mantenimiento semilla | BDD-4 | Contrato: fixture seed | sin scope-lock, exit 0 |
| CA-5 | Mantenimiento semilla | scope-lock en initializing advierte sin bloquear | Contrato: fixture initializing | exit 0 con advertencia |
| CA-6 | Mantenimiento semilla | cambio de gobernanza documentado en spec+AGENTS sin nuevo ADR; espacio 0007+ libre para el proyecto | Revisión cruzada ADR 0006, spec, AGENTS | política vigente única y explícita; 0000–0006 intactos |
| CA-7 | Mantenimiento semilla | gate raíz y CI invocan el mismo verificador de scope | Revisión verify.sh + hook + workflow | una sola entrada, exit propagado |

## 4. Archivos autorizados

- **Editables:**
  - `scripts/verify-scope.sh` (crear)
  - `scripts/verify.sh` (integrar el paso de scope en project)
  - `scripts/tests/verify-contract.sh` (casos negativos/adversarios)
  - `docs/adr/0000-template.md` (aclarar que 0000–0006 son ejemplos/guía, no plantillas a copiar)
  - `README.md` (aclarar rol de ejemplo de los ADR del molde + nota de scope)
  - `AGENTS.md` (nota de scope en Quality Gate + política vigente de numeración)
  - `specs/seed-009-gobernanza-ejecutable.md` (crear, esta spec)
  - `STATE.md`, `docs/seed-upgrades.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables), `AGENTS.md` salvo la nota mínima de scope en la sección Quality Gate, `.github/workflows/verify.yml` salvo que se requiera ajuste de runtime (no previsto), configuración Git, dependencias.
- Ampliación de rutas antes de editar: si hace falta tocar `AGENTS.md` más allá de la nota mínima, se amplía esta lista aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de proyecto. Esta unidad es mantenimiento de semilla sin código de producto: su ciclo rojo/verde ocurre a nivel de contrato (casos nuevos de `verify-contract.sh` fallan primero → implementar `verify-scope.sh` → verde); no aplica TDD de producto.
- **Comandos y suites de cierre:** `bash scripts/tests/verify-contract.sh` (debe incluir los nuevos casos y todos los previos), `./scripts/verify.sh` (exit 0), `bash -n` de todo script nuevo/modificado, `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `bash -n scripts/verify-scope.sh && bash scripts/tests/verify-contract.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** revisión adicional — contraste del diff contra CA-1..CA-7 y pruebas adversarias reproducibles (diff fuera de scope, CA sin evidencia, seed sin remoto). No se presenta como revisión independiente.
- **Condiciones adicionales:** los ADR 0000–0006 quedan byte a byte intactos; el contrato previo (76 casos) sigue pasando.

## 6. Cierre y continuidad

### Evidencia — 2026-10-10

- **Rojo del contrato:** `bash scripts/tests/verify-contract.sh` tras añadir los casos Seed 009 y el `verify-scope.sh` inicial: 74 passed, 10 failed. Los fallos expusieron bugs reales: (a) el parseo de «Unidad activa» se comía la línea completa cuando STATE tenía texto adicional; (b) la etiqueta `Editables:` quedaba pegada a la primera ruta autorizada; (c) archivos nuevos (*untracked*) fuera de scope no entraban en el diff; (d) el scope-lock bloqueaba fixtures de `phase=project` previos sin unidad declarada.
- **Verde del contrato:** 84 passed, 0 failed — 76 previos intactos + 8 nuevos (CA-1..CA-7 y fail-safe). `bash -n scripts/verify-scope.sh` sin error.
- **Gate raíz:** `./scripts/verify.sh`, salida 0. Integridad documental `seed`, contrato 84/0, piloto completo. Dos `SCOPE WARNING` esperados en el piloto de `initializing` (unidad `PILOT-INIT` sin spec, sin cambios en vuelo) que confirman el fail-safe sin bloquear.
- **Controles verificados por fixture determinista:** cambio autorizado pasa (`Alcance verificado`); cambio fuera de scope bloquea (`SCOPE VIOLATION`, incluye archivo nuevo untracked); unidad Cerrada sin evidencia bloquea (`EVIDENCIA FALTANTE`); `seed` omite scope-lock; `initializing` advierte sin bloquear; unidad no parseable falla seguro (advierte, exit 0); sin base remota omite sin bloquear.
- **ADR 0000–0006:** intactos byte a byte; no se creó ADR de proyecto (espacio 0007+ libre). Documentado en ADR-template, README, AGENTS.

### Aprendizaje

El rojo del contrato destapó que un scope-lock basado solo en `git diff` ignora archivos nuevos — hay que sumar `git ls-files --others`. Y que un gate de gobernanza debe fallar seguro ante lo no parseable, o congela la estructura del repo que dice gobernar el flujo. Aplicación futura: al añadir controles mecánicos al gate, probar primero contra los fixtures previos para no romper estados legítimos ya tolerados.

### Commit

Pendiente de política de commits confirmada por el usuario para esta unidad (sin autorización, cambios locales).
