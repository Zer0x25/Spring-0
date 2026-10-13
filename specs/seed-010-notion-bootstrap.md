# Spec: Seed 010 — Arranque de Hito 1 con contexto de Notion (dos modos)

> Estado: Cerrada — implementada y verificada, cambios locales sin commit
> Nivel: Tier 1 — Riesgo alto; altera el bootstrap/entrevista y añade una dependencia externa (Notion) al flujo de inicialización.
> Requisitos: mantenimiento de semilla; implementa la hoja de ruta V5 acordada (Notion como contexto).
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: el cambio de gobernanza se registra en esta spec + AGENTS (política vigente), conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el proyecto derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006. Las seeds son mantenimiento del molde; los derivados no generan seeds.

## 1. Objetivo y alcance

- **Resultado observable:** el arranque de Hito 1 puede alimentarse del contexto ya existente en Notion (Modo A, enriquecido) o generar ese contexto desde cero (Modo B), en ambos casos trasladando decisiones con su estado (confirmada/pendiente) y dejando trazabilidad mecánica entre Notion y las specs del repo. El gate no depende de Notion.
- **Incluye:** sección "Arranque con Notion" en `AGENTS.md` y `bootstrap.md`; campo `Contexto (Notion)` en la plantilla de spec; lectura de la página contenedora + database de decisiones vía MCP; **gate de capacidad** (verificar que el entorno puede leer Notion antes de ofrecer Modo A, con sugerencia de conexión por harness y tres salidas); política de estado confirmada/pendiente → `HITO0_PENDING`; campo `Trazabilidad` con mapeo mecánico a IDs de spec; script de lectura `scripts/notion-context.sh` (solo lectura, opt-in); creación de la página/database en Modo B.
- **Excluye:** integración Linear (descartada por decisión del usuario: no aporta gobernanza en la versión actual, duplica STATE); escritura automática en Notion al cerrar unidades; sincronización bidireccional o webhooks; gate leyendo Notion para validar cierres; migración del proyecto GYM existente (ese es un derivado concreto, no el molde).
- **Pendientes críticos / supuestos aceptados:** el conector Notion está disponible vía MCP (OAuth activo); un derivado que use Modo A debe compartir su página/database con la integración. El alcance de lectura por defecto es la página contenedora completa declarada por el humano.

## 2. Contratos e invariantes

- **Entrada (Modo A):** URL/ID de la página contenedora de Notion → lectura vía MCP (`GET_PAGE_MARKDOWN` + `query` a database de decisiones) → markdown de contexto.
- **Entrada (Modo B):** entrevista estándar con el humano → al sellar, creación de página contenedora + database de decisiones en Notion vía MCP.
- **Salida:** propuesta de PRD/ADR/spec que el humano aprueba; campo `Contexto (Notion): <url>` en cada spec; campo `Trazabilidad` con tags `SPEC:<id>` por criterio.
- **Invariantes:**
  - **Notion nunca es fuente de verdad ejecutable.** El repo lo es; Notion aporta el por qué y las decisiones de negocio.
  - **Estado se respeta:** una decisión `Confirmada` en Notion entra al repo como aceptada; una `Pendiente` entra como `HITO0_PENDING`. El agente no promociona pendientes ni inventa contenido ausente.
  - **Fail-safe de lectura:** si Notion no responde, no está compartido, o el markdown no es parseable, el agente advierte y ofrece entrevista estándar; no bloquea el arranque.
  - **Gate de capacidad (entorno sin Notion):** cada harness gestiona sus propias tools MCP (Hermes: conector; Antigravity: `agy mcp`; Codex/OpenCode: config MCP); no hay Notion universal. Antes de ofrecer Modo A, el bootstrap verifica si el entorno puede leer Notion. Si no puede, sugiere conectarse (según el harness) y ofrece tres salidas en orden: conectar y reintentar; pegar el contexto a mano (`notion-context.sh` lo adopta); arrancar en Modo B. La falta de capacidad es el mismo fail-safe de lectura: advierte y cae a entrevista. El molde sugiere y respeta; no impone un conector ni se acopla a un harness.
  - **Fail-safe de escritura (Modo B):** si al sellar tampoco hay capacidad de escribir en Notion, advierte y deja el repo como fuente; no bloquea el sellado.
  - **Fail-safe de trazabilidad:** un tag `Trazabilidad` mal formado o una spec inexistente advierten; nunca bloquean el gate (extiende el principio de V4.1).
  - **Sin secretos:** las URLs/IDs de Notion no son credenciales; no se guardan tokens en el repo.
  - El gate raíz NO ejecuta `notion-context.sh`; es herramienta de arranque, no de cierre.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: Modo A traslada decisiones con estado
  Dado un derivado cuyo humano indica "Inicia Hito-1 leyendo <url Notion>" con decisiones Confirmadas y Pendientes
  Cuando el agente propone PRD y specs
  Entonces las confirmadas quedan aceptadas y las pendientes como HITO0_PENDING, sin inventar contenido

Escenario BDD-2: Modo B genera el contexto en Notion
  Dado un derivado sin material previo en Notion
  Cuando el humano completa la entrevista y se sella Hito 0
  Entonces el agente crea la página contenedora y la database de decisiones con lo confirmado

Escenario BDD-3: lectura de Notion falla sin romper el arranque
  Dado Modo A con Notion caído o no compartido
  Cuando el agente intenta leer el contexto
  Entonces advierte y ofrece entrevista estándar, sin bloquear

Escenario BDD-4: trazabilidad mapea sin condicionar
  Dado una spec con "Trazabilidad: SPEC:MVP-CUT-01"
  Cuando la spec MVP-CUT-01 no existe aún
  Entonces el gate advierte del enlace roto pero no falla

Escenario BDD-5: entorno sin Notion no rompe el arranque
  Dado un agente cuyo entorno no tiene tools de Notion disponibles
  Cuando intenta ofrecer el Modo A
  Entonces sugiere conectarse (según el harness) y ofrece pegar a mano o Modo B, sin bloquear
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Mantenimiento semilla | BDD-1 | Fixture: markdown de Notion con confirmadas/pendientes | PRD propuesto respeta estados |
| CA-2 | Mantenimiento semilla | BDD-2 | Fixture: entrevista sellada | página+database creadas con lo confirmado |
| CA-3 | Mantenimiento semilla | BDD-3 | Fixture: MCP Notion sin respuesta | advierte, ofrece entrevista, exit 0 |
| CA-4 | Mantenimiento semilla | BDD-4 | Fixture: trazabilidad a spec inexistente | advierte, no bloquea |
| CA-5 | Mantenimiento semilla | campo `Contexto (Notion)` en plantilla de spec | Revisión de plantilla | campo presente y documentado |
| CA-6 | Mantenimiento semilla | gate no depende de Notion | Revisión verify.sh | sin llamada a Notion en el gate |
| CA-7 | Mantenimiento semilla | ADR 0000–0006 intactos; espacio 0007+ libre | Revisión cruzada | política vigente única; 0000–0006 intactos |
| CA-8 | Mantenimiento semilla | gate de capacidad: entorno sin Notion sugiere conexión y ofrece 3 salidas sin bloquear | Fixture: bootstrap sin tools de Notion | advierte, ofrece conectar/pegar/Modo B; no bloquea |

## 4. Archivos autorizados

- **Editables:**
  - `AGENTS.md` (sección "Arranque con Notion", dos modos + política de estado + trazabilidad)
  - `.agents/bootstrap.md` (fase de arranque: detectar modo A/B; Modo B crea Notion al sellar)
  - `specs/templates/feature.template.md` (campo `Contexto (Notion)` + `Trazabilidad`)
  - `scripts/notion-context.sh` (crear; solo lectura, opt-in)
  - `scripts/tests/verify-contract.sh` (casos BDD-1..BDD-4 con MCP simulado)
  - `scripts/verify.sh` (sin cambios de cierre; el gate no llama a Notion — se verifica, no se modifica su lógica salvo nota)
  - `README.md` (rol de Notion: contexto, no control)
  - `specs/seed-010-notion-bootstrap.md` (crear, esta spec)
  - `STATE.md`, `docs/seed-upgrades.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables), configuración Git, dependencias, `.githooks/pre-commit` (no añadir llamada de red al hook).
- Ampliación de rutas antes de editar: si hace falta tocar `verify.sh` más allá de una nota, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es mantenimiento de semilla sin código de producto: su ciclo rojo/verde ocurre a nivel de contrato; no aplica TDD de producto.
- **Comandos y suites de cierre:** `bash scripts/tests/verify-contract.sh` (incluye casos BDD-1..BDD-4 con MCP de Notion simulado + todos los previos), `./scripts/verify.sh` (exit 0), `bash -n` de `scripts/notion-context.sh`, `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `bash -n scripts/notion-context.sh && bash scripts/tests/verify-contract.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-7; verificar que el gate raíz no adquiere dependencia de red y que el fail-safe de lectura/trazabilidad advierte sin bloquear. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; contrato previo (84 casos) sigue pasando.

## 6. Cierre y continuidad

### Evidencia — 2026-10-10

- **Contrato:** `bash scripts/tests/verify-contract.sh` → **90 passed, 0 failed** (84 previos intactos + 6 de Seed 010, incluido el gate de capacidad CA-8). `bash -n` de `notion-context.sh` y `verify-scope.sh` sin error.
- **Gate raíz:** `./scripts/verify.sh`, salida 0. Contrato 90/0, piloto completo. `git diff --check` salida 0. ADR 0000–0006 intactos byte a byte; sin ADR de proyecto nuevo (espacio 0007+ libre).
- **Hallazgo de plataforma (real):** las tools MCP de Notion (`GET_PAGE_MARKDOWN`, etc.) solo son invocables **dentro de una sesión del agente Hermes**; el CLI `hermes tools` solo lista/habilita tools, no las invoca. Verificado además que cada harness gestiona sus propias tools MCP (Antigravity: `agy mcp`; Codex/OpenCode: config propia) — **no hay un Notion universal**. Por eso el bootstrap incluye un **gate de capacidad**: verifica si el entorno puede leer Notion antes de ofrecer Modo A; si no, sugiere conectarse (según harness) y ofrece pegar a mano (`notion-context.sh` lo adopta) o Modo B. Por eso `notion-context.sh` es un contrato reproducible: valida argumentos, adopta markdown precocinado por el agente y materializa el fail-safe; la lectura real de Notion la hace el agente vía MCP en su sesión. No se finge una lectura desde shell.
- **Lectura real demostrada en vivo:** se leyó la página contenedora completa del proyecto GYM (`GET_PAGE_MARKDOWN`) y la database de decisiones (`NOTION_FETCH_DATA`, `fetch_type=databases`) vía el conector MCP de Hermes, confirmando que el Modo A puede correr hoy en un entorno con capacidad.
- **Controles verificados por fixture determinista:** `notion-context.sh` sin argumentos falla con código de uso; con URL de Notion y sin sesión advierte y entrega payload válido (exit 0, fail-safe); adopta markdown del agente tal cual; salida "pegar a mano" sin capacidad de lectura es fail-safe exit 0 (CA-8); tag `Trazabilidad: SPEC:<id>` a spec inexistente advierte y NO bloquea el gate; `verify.sh` no referencia `notion-context` (el gate no depende de Notion).

### Aprendizaje

Un control de gobernanza nuevo debe probarse primero contra los fixtures previos: el fail-safe de trazabilidad se implementó en `verify-scope.sh` **antes** de correr el contrato, por eso no hubo rojo — a diferencia de Seed 009, donde el rojo destapó 4 bugs. Lección: cuando el comportamiento esperado ya está claro y es no-bloqueante, escribir el control con su fail-safe desde el inicio evita el rojo; cuando el control toca parseo de entradas, el rojo sigue siendo la red de seguridad. Aplicación futura: distinguir controles bloqueantes (merecen rojo primero) de controles documentales/no-bloqueantes (se implementan con fail-safe y se verifican en verde).

### Commit

Pendiente de política de commits confirmada por el usuario para esta unidad (sin autorización, cambios locales).
