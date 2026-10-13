# Spec: Seed 013 — Protocolo de preparación de capa (system design antes de UI)

> Estado: Cerrada — implementada y verificada, cambios locales sin commit
> Nivel: Tier 1 — Riesgo alto; altera la secuencia de desarrollo del derivado (inserta un paso obligatorio antes de tocar una capa nueva).
> Requisitos: mantenimiento de semilla; cierra la fricción F-03 del `docs/harness-metrics.md` (evidencia real del derivado GYM-2026: el flujo se detuvo al no saber cómo arrancar el frontend; la spec 003 pospuso la UI a "la pasada de diseño" sin unidad que la defina).
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: el cambio de gobernanza se registra en esta spec + AGENTS (política vigente), conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el proyecto derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006. Las seeds son mantenimiento del molde; los derivados no generan seeds.

## 1. Objetivo y alcance

- **Resultado observable:** el derivado ya no se detiene ni reescribe al pasar a una capa nueva (frontend, offline, un dominio con UI). Antes de tocar una capa nueva, el agente cierra su decisión de diseño en un **ADR técnico** y la confirma con el humano; recién entonces implementa. El system design de frontend (separación UI/lógica, qué lógica vive en el front y de qué tipo, rendimiento, reutilización entre módulos) es un ADR obligatorio antes de tocar UI.
- **Incluye:** sección "Preparación de la siguiente unidad / capa" en `AGENTS.md` y en el `PROMPT-MAESTRO` template; campo `Decisión de diseño previa:` en la plantilla de spec; guía de contenido mínimo del ADR de system design de frontend (en `docs/templates/` o dentro de la sección); esta spec.
- **Excluye:** tocar el gate (esto es guía/secuencia, no control mecánico); imponer un framework de UI concreto; decidir el ADR por el humano (el agente propone, el humano valida); aplicar nada a derivados ya congelados (GYM-2026 sigue en V5.0; el fix es para futuros derivados).
- **Pendientes críticos / supuestos aceptados:** el patrón "propone/humano valida" ya existe (Modo A de Notion, Seed 010); el ADR técnico ya es una pieza del flujo (AGENTS sección de niveles); solo se institucionaliza el *orden* — que ese ADR exista ANTES de tocar la capa.

## 2. Contratos e invariantes

- **Entrada:** una unidad del plan cuya implementación toca una capa nueva (UI/frontend, offline, o un dominio con superficie de usuario) sin decisión de diseño previa.
- **Salida:** un ADR técnico de system design de esa capa, propuesto al humano y validado, ANTES de cualquier código de la capa; la spec de la unidad referencia ese ADR en `Decisión de diseño previa:`.
- **Invariantes:**
  - **Ninguna capa nueva se implementa sobre una decisión implícita.** Si toca UI y no hay ADR de system design de frontend, el agente lo escribe y lo confirma primero.
  - **La lógica de negocio y la autorización viven solo en el backend** (ya decidido por ADR base del derivado, p. ej. GYM-2026 ADR-0002 L28/L43/L50). El ADR de frontend define la lógica de *presentación/UX* (estado, cache, validación optimista) y **nunca** traslada reglas de negocio ni autorización al cliente.
  - **El ADR es reutilizable entre módulos.** Su objetivo es que pagos, socios, clases no reescriban el patrón de frontend; se escribe una vez y los módulos lo siguen.
  - **Propone, no auto-aprueba.** El agente presenta el ADR de system design al humano y espera validación antes de implementar (igual que el Modo A). No se auto-acepta una decisión de arquitectura/UI.
  - **Fail-safe / sin bloqueo:** si la capa no introduce decisión nueva (ya hay ADR que la cubre), el agente arranca el ciclo normal. El protocolo no añade ceremonia donde no hace falta.
  - **Sin tocar el gate.** Es secuencia documentada, no control mecánico; el gate no cambia ni lee ADRs de frontend.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: unidad que toca UI sin ADR de frontend → se escribe el ADR primero
  Dado una unidad del plan que implementa frontend
  Y no existe ADR de system design de frontend
  Cuando el agente prepara la unidad
  Entonces escribe el ADR (separación UI/lógica, lógica de front, rendimiento, reutilización), lo presenta al humano y NO toca código de UI hasta validarlo

Escenario BDD-2: ADR validado habilita la implementación
  Dado el ADR de system design de frontend confirmado por el humano
  Cuando el agente implementa la UI de la unidad
  Entonces sigue el ADR y la spec referencia "Decisión de diseño previa: <ADR>"

Escenario BDD-3: capa sin decisión nueva arranca directo
  Dado una unidad que toca una capa ya cubierta por un ADR vigente
  Cuando el agente la prepara
  Entonces no añade ADR nuevo; arranca el ciclo normal

Escenario BDD-4: la lógica de negocio no migra al front
  Dado el ADR de system design de frontend
  Cuando el agente redacta qué lógica vive en el cliente
  Entonces solo contempla lógica de presentación/UX; la de negocio y autorización queda en el backend
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Cerrar F-03 | BDD-1 | Revisión de AGENTS/PROMPT-MAESTRO | paso obligatorio "ADR de system design antes de UI" documentado |
| CA-2 | Cerrar F-03 | BDD-2 | Revisión de plantilla de spec | campo `Decisión de diseño previa:` presente |
| CA-3 | Cerrar F-03 | BDD-3 | Revisión de AGENTS | caso "capa ya cubierta → ciclo normal" documentado (sin ceremonia de más) |
| CA-4 | Cerrar F-03 | BDD-4 | Revisión de la guía del ADR de frontend | explícito: negocio/autorización solo en back |
| CA-5 | Mantenimiento semilla | ADR 0000–0006 intactos; gate sin cambios | Revisión cruzada | política vigente única; gate no toca ADRs de frontend |

## 4. Archivos autorizados

- **Editables:**
  - `AGENTS.md` (sección "Preparación de la siguiente unidad / capa": los 4 pasos + caso sin-decisión-nueva + fail-safe)
  - `.agents/master-prompt.template.md` (insertar el paso de preparación de capa entre "siguiente unidad" y el ciclo; referir a AGENTS)
  - `specs/templates/feature.template.md` (campo `Decisión de diseño previa:`)
  - `docs/templates/adr-frontend.md` (crear; guía de contenido mínimo del ADR de system design de frontend, reutilizable)
  - `docs/harness-metrics.md` (registrar F-03 y cerrarla con la evidencia del fix)
  - `specs/seed-013-preparacion-capa.md` (crear, esta spec)
  - `STATE.md`, `docs/seed-upgrades.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables); el gate raíz (`verify.sh`, `verify-scope.sh`, `verify-structure.sh`); `.githooks/pre-commit`.
- Ampliación de rutas antes de editar: si hace falta tocar el gate, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es mantenimiento de semilla sin código de producto: su ciclo rojo/verde ocurre a nivel de contrato; no aplica TDD de producto.
- **Comandos y suites de cierre:** `./scripts/verify.sh` (exit 0; sin cambios de comportamiento), `bash scripts/tests/verify-contract.sh` (94/94 previos siguen pasando), `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `./scripts/verify.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-5; verificar que el gate NO cambia y que el protocolo añade el paso sin ceremonia cuando no hay decisión nueva. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; contrato previo (94 casos) sigue pasando.

## 6. Cierre y continuidad

### Evidencia — 2026-10-12

- **Gate raíz:** `./scripts/verify.sh`, salida 0. Contrato 94/94 (sin cambios de comportamiento; Seed 013 es guía/secuencia, no toca el gate). `git diff --check` salida 0. ADR 0000–0006 intactos byte a byte; sin ADR de proyecto nuevo (espacio 0007+ libre).
- **CA-5 verificado:** el gate no cambia ni lee ADRs de frontend; `verify.sh` sin referencias nuevas.
- **Piezas entregadas:** sección «Preparación de la siguiente unidad / capa» en `AGENTS.md` (4 pasos + caso sin-decisión-nueva + fail-safe) y en `PROMPT-MAESTRO` (paso insertado en el ciclo); `docs/templates/adr-frontend.md` (guía reutilizable del ADR de system design de frontend, con la invariante «lógica de negocio y autorización SOLO en backend»); campo `Decisión de diseño previa:` en la plantilla de spec; F-03 registrada y cerrada en `docs/harness-metrics.md`.
- **Fricción F-03 cerrada:** el derivado ya no se detiene al pasar a una capa nueva; el system design de frontend se cierra en un ADR validado por el humano ANTES de tocar UI, y es reutilizable entre módulos. Nota de supervisión: GYM-2026 permanece en V5.0 por diseño; el fix es para futuros derivados.

### Aprendizaje

Escritura en archivos de instrucciones del agente (AGENTS.md, PROMPT-MAESTRO) está protegida y requiere aprobación explícita del usuario: el bloqueo por timeout no es un error, es la protección haciendo su trabajo — nadie debe editar las instrucciones del agente en silencio. Ante el bloqueo, la respuesta correcta es parar y pedir autorización, no buscar otra ruta. Además: al diagnosticar una fricción de secuencia, verificar primero qué YA decidió el derivado (el ADR-0002 de GYM-2026 ya blindaba separación UI/lógica) — el hueco real fue la *unidad* de system design ausente, no las reglas de separación.

### Commit

Pendiente de política de commits confirmada por el usuario para esta unidad.
