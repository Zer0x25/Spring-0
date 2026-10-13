# Capacidades del flujo (detalle acumulado)

Este archivo reúne el detalle de las capacidades que el flujo agéntico fue acumulando. [AGENTS](../AGENTS.md) conserva el **protocolo estable** (niveles, límites de cambio, DoD, ciclo de unidad, precedencia) y apunta aquí para el detalle. Es una mudanza, no un resumen: cada bloque conserva su redacción.

El gate nunca lee este archivo; es documentación viva, no control. Convención neutral de harness: los comandos concretos de un host aparecen solo como **ejemplos**, nunca como requisito.

## Gobernanza ejecutable (Seed 009)

En `phase=project`, `scripts/verify-scope.sh` aplica dos controles mecánicos que sustituyen la regla de prompt. (1) *Scope-lock*: compara los cambios contra la base autorizada (`origin/main`, incluyendo archivos nuevos) con los «Archivos autorizados» de la unidad activa declarada en STATE; una ruta fuera de lista bloquea el commit. (2) *Evidencia*: una unidad en estado Cerrada debe tener, por criterio CA, una línea de evidencia con comando y resultado real. El gate gobierna el flujo, no la estructura: si la unidad, su sección de rutas o sus criterios no se pueden parsear, advierte y omite ese control — nunca bloquea por no entender. En `initializing` advierte sin bloquear; en `seed` no corre (el molde no tiene unidad de producto). Los ADR `0000–0006` son del molde (ejemplo/guía); los ADR del proyecto derivado usan `0002` (arquitectura) y `0007+`. Las seeds (`specs/seed-*.md`) son mantenimiento del molde; los derivados no generan seeds.

## Arranque con Notion (Seed 010)

El arranque de Hito 1 tiene dos modos, ambos con Notion como *contexto* (el por qué y las decisiones de negocio), nunca como fuente de verdad ejecutable ni dependencia del gate.

**Antes de ofrecer Modo A, verifica la capacidad de leer Notion en tu entorno** — no asumas que existe. Cada harness gestiona sus propias tools MCP (Hermes: conector MCP; Antigravity: `agy mcp`; Codex/OpenCode: su config MCP); no hay un Notion universal. Si tienes capacidad de lectura → ofrece Modo A. Si no → sugiere conectarse (según el harness) y ofrece tres salidas en orden: (1) conectar Notion y reintentar Modo A; (2) pegar el contexto de Notion a mano (`notion-context.sh` lo adopta tal cual); (3) arrancar en Modo B. La falta de capacidad de lectura es el mismo fail-safe que ya existe: advierte, cae a entrevista. El molde sugiere y respeta; no impone un conector ni se acopla a un harness.

- **Modo A — enriquecido:** el humano indica *"Inicia Hito-1 leyendo `<url o id de Notion>`"*. El agente lee la página contenedora y la database de decisiones vía las tools MCP de Notion (`GET_PAGE_MARKDOWN`, `NOTION_FETCH_DATA`/query) **en su sesión** — las tools MCP no se invocan desde shell. Traslada cada decisión con su estado: `Confirmada` → aceptada en el repo; `Pendiente` → `HITO0_PENDING`. No inventa contenido ausente ni promociona pendientes. Presenta la propuesta de PRD/ADR/specs para que el humano confirme o corrija.
- **Modo B — desde cero:** entrevista estándar con el humano. Al sellar, el agente crea la página contenedora y la database de decisiones en Notion con lo confirmado (vía MCP). Si tampoco hay capacidad de escritura en Notion al sellar, advierte y deja el repo como fuente; no bloquea el sellado.
- **Fail-safe de lectura:** si Notion no responde, no está compartido o el markdown no es parseable, el agente advierte y ofrece entrevista estándar; no bloquea el arranque. `scripts/notion-context.sh` materializa el contrato reproducible; la lectura real la hace el agente en su sesión.
- **Trazabilidad:** cada spec lleva `Contexto (Notion): <url>` y opcionalmente `Trazabilidad: SPEC:<id>` que mapea a `specs/<id>.md`. Un enlace a spec inexistente advierte, nunca bloquea (extiende el fail-safe de Seed 009).
- El gate raíz NO llama a Notion; `notion-context.sh` es herramienta de arranque, no de cierre.

## Aprendizaje auditable y ritual de cierre de sesión (Seed 011)

El molde institucionaliza tres mecanismos ligeros, todos de convención documentada, sin código en el gate. (1) *Formato canónico de aprendizaje*: cada derivado lleva `docs/learning.md` con el formato de `docs/templates/learning.md` (fecha, unidad, hallazgo, evidencia archivo:línea, aplicación futura, severidad, ¿toca el molde?). (2) *Auditoría del molde*: `docs/harness-metrics.md` vive en el **molde**, no en el derivado; el supervisor escribe ahí las fricciones observadas al auditar un derivado. (3) *Ritual de cierre de sesión*: antes de cerrar una sesión que dejó commits, exportá la conversación del harness a `docs/sessions/<fecha>-<titulo>.md` y commiteala junto a la unidad; enlazá el export en la spec con el campo opcional `Sesión:`. Es **opt-in y sin hook**: la ausencia de export no bloquea el gate (evidencia adicional, no requisito). El export se redacta por defecto; nunca guardes tokens/API keys en las sesiones. El gate NUNCA lee sesiones ni aprendizaje.

**Ejemplo concreto (Hermes):** el comando para el ritual de cierre es `hermes sessions export --format md --cwd <repo>`, que produce Markdown con frontmatter y conversación completa, con redacción por defecto. Es un ejemplo de harness, no un requisito: cualquier entorno con capacidad de exportar su conversación cumple la convención con su propio comando.

## Preparación de la siguiente unidad / capa (Seed 013)

El ciclo de una unidad (sección 8 de AGENTS) dice *qué* hacer; este protocolo dice *cómo preparar la siguiente* cuando toca una capa nueva, para no reescribirla después. Antes de implementar una unidad que toca una capa nueva (UI/frontend, offline, o un dominio con superficie de usuario):

1. **¿Existe un ADR de system design de esa capa?** (para frontend: `docs/templates/adr-frontend.md` como guía). Si la capa ya está cubierta por un ADR vigente → arrancá el ciclo normal, sin ceremonia de más.
2. **Si no existe → NO toques código de la capa todavía.** Escribí el ADR técnico de system design: separación UI/lógica, qué lógica SÍ vive en el cliente y de qué tipo (presentación/UX/estado/cache/validación optimista), rendimiento, y reutilización entre módulos. **La lógica de negocio y la autorización viven SOLO en el backend** (el cliente oculta por UX, nunca decide permisos ni muta estado financiero).
3. **Presentá el ADR al humano y esperá su validación** (propone/valida, como el Modo A). No auto-apruebes una decisión de arquitectura/UI.
4. **Recién entonces** implementá la UI siguiendo el ADR; la spec referencia el ADR en `Decisión de diseño previa:`.

El objetivo: que elegir el system design tarde no implique reescribir el frontend, y que todos los módulos (pagos, socios, clases) reutilicen un mismo patrón de frontend. Es secuencia documentada; el gate no cambia ni lee ADRs de frontend.

## Decisiones transversales obligatorias antes de tocar un dominio (Seed 014)

El protocolo de capa cubre *cómo* se ve una capa; este bloque cubre tres decisiones que atraviesan *todos* los módulos de un dominio y que, si cada uno las improvisa, obligan a reescribir. Antes de implementar código de un dominio (endpoints, persistencia, lógica de negocio), el ADR base de ese dominio debe declarar:

1. **Modelo de errores** — taxonomía (validación / authz / conflicto / no-encontrado / interno), forma del payload de fallo, y cómo se propaga al cliente. Un módulo no inventa su propia estructura de error.
2. **Contexto tenant/auth en backend** — cómo viaja la identidad del tenant/usuario (middleware, contexto de request), cómo se aplica la autorización, y la garantía de aislamiento entre tenants. **La autorización vive SOLO en el backend.**
3. **Estrategia de tests** — cómo se aíslan los tests de integración (transacciones/fixtures/DB de test), sin colisiones entre suites que corren contra el mismo recurso.

Se cierran **una vez por dominio** en el ADR base y se validan con el humano (como el paso 3 del protocolo de capa). Los módulos siguientes las reutilizan; no se repite el ADR por módulo. Si el ADR base ya las declara → arrancá el ciclo normal, sin ceremonia. Es secuencia documentada: el gate no lee ni valida ADRs de dominio.
