# Spec: Seed 014 — Robustez de base (Tier 3↔gate + decisiones transversales)

> Estado: Borrador — pendiente de aprobación del usuario
> Nivel: Tier 1 — Riesgo alto; corrige una contradicción entre política y gate mecánico, y altera la secuencia de preparación de unidades (añade decisiones de base obligatorias).
> Requisitos: mantenimiento de semilla; robustece la base antes de añadir complejidad, con evidencia de la auditoría del flujo (2026-10-12) y del derivado GYM-2026.
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: el cambio de gobernanza se registra en esta spec + AGENTS (política vigente), conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el proyecto derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006. Las seeds son mantenimiento del molde; los derivados no generan seeds.

## 1. Objetivo y alcance

- **Resultado observable:** dos robustecimientos de base. (1) El gate deja de contradecir la política de Tier 3: una unidad ligera `LIG-*` registrada en STATE (sin spec) ya no bloquea el commit; el gate lee sus rutas autorizadas del bloque de STATE. (2) Toda unidad que toque código de un dominio cierra antes, en el ADR base, tres decisiones transversales obligatorias — modelo de errores, contexto tenant/auth en backend y estrategia de tests — para que ningún módulo las improvise y haya que reescribir.
- **Incluye:** fix en `scripts/verify-scope.sh` (reconocer `LIG-*` y leer «Archivos autorizados» del bloque de STATE); casos de contrato en `scripts/tests/verify-contract.sh`; sección «Decisiones transversales obligatorias antes de tocar un dominio» en `AGENTS.md` (generaliza el protocolo de capa de Seed 013) y nota en `PROMPT-MAESTRO`; esta spec.
- **Excluye:** unificar la duplicación de tiers entre documentos (higiene, para una seed posterior); desacoplar el ritual de sesión de Hermes (higiene, posterior); tocar scope-lock, evidencia por CA o el gate único.
- **Pendientes críticos / supuestos aceptados:** las unidades `LIG-*` son Tier 3 y su registro ligero vive en STATE; sus rutas autorizadas se declaran en ese mismo bloque (el formato ya existe en AGENTS §2). La corrección debe respetar el fail-safe: lo no parseable advierte, no bloquea.

## 2. Contratos e invariantes

- **Entrada (fix Tier 3):** una unidad activa `LIG-*` en STATE sin spec en `specs/`, con cambios en vuelo y un bloque de registro ligero que declara rutas autorizadas.
- **Salida (fix Tier 3):** el gate verifica el alcance contra las rutas del bloque de STATE (no viola por falta de spec); una ruta fuera de la lista sigue bloqueando. Si el bloque de STATE no declara rutas o no es parseable → fail-safe (advierte, no bloquea), igual que el resto del gate.
- **Entrada (decisiones transversales):** una unidad que implementa código de un dominio (endpoints, persistencia, lógica de negocio) cuyo ADR base no declara errores/tenant-auth/estrategia de tests.
- **Salida (decisiones transversales):** antes de implementar, el agente cierra esas tres decisiones en el ADR base y las presenta al humano (propone/valida); la spec las referencia. Si ya están declaradas → ciclo normal.
- **Invariantes:**
  - **La política y el gate no pueden contradecirse.** Si AGENTS autoriza Tier 3 sin spec, el gate debe respetarlo; un gate que bloquea lo que la política permite es un bug, no un control.
  - **El fix es quirúrgico:** solo `LIG-*` (o unidades sin spec con registro en STATE) cambian de comportamiento; una unidad de negocio sin spec y sin registro en STATE **sigue siendo violación** (no se abre la puerta a commits sin alcance declarado).
  - **Fail-safe intacto:** lo no parseable en el bloque de STATE advierte y omite, nunca bloquea (extiende V4.1).
  - **Decisiones transversales son de base, no ceremonia:** se cierran una vez por dominio en el ADR base; los módulos siguientes las reutilizan. No se repite el ADR por módulo.
  - **Lógica de negocio y autorización SOLO en backend** (invariante de Seed 013, se reafirma).
  - **Sin tocar los pilares:** scope-lock, evidencia por CA, gate único sin switches, DoD.
  - El gate raíz sigue siendo una sola entrada (`verify.sh`); no se añade skip.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: unidad LIG-* con cambios en vuelo no bloquea por falta de spec
  Dado una unidad activa LIG-001 registrada en STATE con rutas autorizadas en su bloque
  Y cambios dentro de esas rutas
  Cuando corre el gate
  Entonces verifica el alcance contra las rutas de STATE y sale 0

Escenario BDD-2: unidad LIG-* con ruta fuera de la lista sigue bloqueando
  Dado una unidad activa LIG-001 con rutas autorizadas en STATE
  Y un cambio fuera de esas rutas
  Cuando corre el gate
  Entonces bloquea por SCOPE VIOLATION

Escenario BDD-3: unidad de negocio sin spec ni registro en STATE sigue siendo violación
  Dado una unidad activa FEAT-001 sin spec y sin bloque LIG-* en STATE
  Y cambios en vuelo
  Cuando corre el gate
  Entonces bloquea (no se abre la puerta a commits sin alcance declarado)

Escenario BDD-4: decisiones transversales obligatorias antes de tocar un dominio
  Dado una unidad que implementa código de un dominio cuyo ADR base no declara errores/tenant-auth/tests
  Cuando el agente la prepara
  Entonces cierra esas tres decisiones en el ADR base y las valida con el humano antes de implementar

Escenario BDD-5: ADR base ya cubre las transversales → ciclo normal
  Dado un dominio cuyas decisiones transversales ya están en el ADR base
  Cuando el agente implementa un módulo de ese dominio
  Entonces no repite el ADR; arranca el ciclo normal
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Robustez base | BDD-1 | Fixture: LIG-* en STATE con rutas, cambios dentro | verifica alcance, exit 0 |
| CA-2 | Robustez base | BDD-2 | Fixture: LIG-* con ruta fuera de lista | SCOPE VIOLATION |
| CA-3 | No relajar | BDD-3 | Fixture: unidad sin spec ni LIG en STATE, con cambios | sigue siendo violación |
| CA-4 | Robustez base | BDD-4 | Revisión de AGENTS/PROMPT-MAESTRO | 3 transversales obligatorias documentadas |
| CA-5 | Sin ceremonia | BDD-5 | Revisión de AGENTS | caso "ya cubierto → ciclo normal" documentado |
| CA-6 | Mantenimiento semilla | ADR 0000–0006 intactos; contrato previo pasa | Revisión cruzada | política vigente única; base intacta |

## 4. Archivos autorizados

- **Editables:**
  - `scripts/verify-scope.sh` (reconocer `LIG-*` sin spec; leer rutas autorizadas del bloque de STATE; fail-safe)
  - `scripts/tests/verify-contract.sh` (casos BDD-1..BDD-3)
  - `AGENTS.md` (sección «Decisiones transversales obligatorias antes de tocar un dominio», integrada con el protocolo de capa de Seed 013)
  - `.agents/master-prompt.template.md` (nota: cerrar transversales en ADR base antes de implementar un dominio)
  - `docs/harness-metrics.md` (registrar el bug Tier 3↔gate y las transversales; cerrarlos con evidencia)
  - `specs/seed-014-robustez-base.md` (crear, esta spec)
  - `STATE.md`, `docs/seed-upgrades.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables); `verify.sh` y `verify-structure.sh` salvo nota; `.githooks/pre-commit`.
- Ampliación de rutas antes de editar: si hace falta tocar `verify.sh`, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es mantenimiento de semilla: el fix del gate es un control bloqueante modificado → **rojo primero** (patrón Seed 009/012); la documentación de transversales se verifica en verde.
- **Comandos y suites de cierre:** `bash scripts/tests/verify-contract.sh` (BDD-1..BDD-3 + todos los previos), `./scripts/verify.sh` (exit 0), `bash -n scripts/verify-scope.sh`, `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `bash -n scripts/verify-scope.sh && bash scripts/tests/verify-contract.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-6; verificar que el fix del Tier 3 es quirúrgico (BDD-3 sigue siendo violación) y que el fail-safe no se debilitó. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; contrato previo (94 casos) sigue pasando salvo los que esta unidad cambia a propósito.

## 6. Cierre y continuidad

- **Evidencia:** 2026-10-12. Rojo confirmado primero: `verify-contract.sh` mostró RED en BDD-1 (gate actual violaba `LIG-*` sin spec). Tras el fix, `bash scripts/tests/verify-contract.sh` → **97 passed, 0 failed** (BDD-1/2/3 verdes, 94 previos intactos). `./scripts/verify.sh` → exit 0. `bash -n scripts/verify-scope.sh` OK. `git diff --check` OK. ADR 0000–0006 intactos byte a byte vs v5.2.0. Hallazgo del fix: el bloque LIG de STATE declara `Alcance/autoridad: ruta; autor; fecha` — el parseo parte por `,` y `;` y toma solo el primer token path-like por segmento (la ruta), descartando autor/fecha.
- **Aprendizaje:** el bug Tier 3↔gate pasó desapercibido porque el contrato no cubría `LIG-*`; el fix quirúrgico exige que el caso "unidad sin spec ni LIG" siga siendo violación (BDD-3) para no abrir la puerta a commits sin alcance. Las decisiones transversales (errores/tenant-auth/tests) quedaron documentadas en AGENTS.md; falta su aplicación en un derivado real para validar que no sean ceremonia.
- **Commit:** pendiente de política de commits confirmada por el usuario para esta unidad.
- **Checkpoint en STATE:** siguiente unidad y primer paso tras aprobación.
- **Continuidad:** checkpoint según AGENTS; capacidades opcionales en docs/agent-capabilities.md.
