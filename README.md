# Spring-0 — Semilla agnóstica para proyectos guiados por agentes

> **Spring-0** es el molde de gobernanza agéntica (antes Hito-0), migrado a repo fresco sin historial. Su construcción vive en [Constructor-Padre](https://github.com/Zer0x25/Constructor-Padre); este repo es el molde que provee gobernanza a los derivados. Versión funcional: **V5.6** (estado migrado desde Hito-0 `0e683dd`).

Plantilla para acordar producto, arquitectura, autoridad y evidencia antes de desarrollar. No impone stack ni dominio. El núcleo es PRD, specs proporcionadas al riesgo, ADR históricos y un gate reproducible.

## Crear un proyecto

1. En GitHub usa **Use this template**, clona el repositorio y ábrelo con tu agente.
2. Activa el hook: `./scripts/install-hooks.sh`.
3. Escribe `Inicia Hito 0`.

La entrevista adapta hasta dos preguntas por turno al contexto ya disponible. Distingue decisiones, supuestos y pendientes; omite áreas irrelevantes. El bootstrap comprueba el remoto para advertir si se intenta inicializar el molde maestro; es un control procedimental del agente, no un bloqueo de Git.

El usuario confirma PRD, arquitectura, DoD y delegación. El agente genera los artefactos y pasa de `seed` a `initializing`. Si se interrumpe, STATE y el bootstrap conservan el siguiente paso. Después de un gate satisfactorio se archiva el bootstrap, pasa a `project` y verifica el sellado. Hito 1 se inicia con:

> Lee y ejecuta PROMPT-MAESTRO.md para iniciar Hito 1; crea o retoma la goal de entrega definida allí y sigue el ciclo por unidades de AGENTS.md.

## Fuentes de verdad

| Archivo | Responsabilidad |
|---|---|
| PRD.md, generado | Alcance, exclusiones y aceptación final |
| AGENTS.md | Reglas operativas vigentes y DoD |
| docs/adr/ | Decisiones históricas; arquitectura del producto en 0002 |
| PROMPT-MAESTRO.md, generado | Invocación y autoridad confirmada |
| specs/ o registro ligero en STATE | Contrato, criterios y evidencia de una unidad |
| STATE.md | Meta, trabajo activo, pendientes y checkpoint |
| docs/learning.md, generado | Hallazgos útiles con evidencia |

Los ADR aceptados se conservan. [ADR 0006](docs/adr/0006-gobernanza-verificable.md) aclara precedencia y operación: nuevas instrucciones autorizadas pueden cambiar decisiones mediante registro nuevo, respetando las reglas del anfitrión. Los documentos históricos no tienen autoridad superior al usuario.

**ADR del molde vs. del proyecto:** los ADR `0000–0006` son decisiones **del molde** (gobernanza del flujo agéntico) y sirven de **ejemplo/guía**. Los ADR del **proyecto derivado** nacen en Hito 1+: `0002` (arquitectura base) y `0007+` (decisiones reales de producto). Las **seeds** (`specs/seed-*.md`) son unidades de **mantenimiento del molde**; los derivados las heredan como referencia y no generan seeds.

**Gobernanza ejecutable (Seed 009, V4.1):** en `phase=project` el gate aplica scope-lock mecánico (cambios fuera de «Archivos autorizados» de la unidad activa bloquean el commit) y evidencia por criterio en unidades Cerradas. Fallo seguro ante lo no parseable: advierte y omite, nunca bloquea por no entender.

**Arranque con Notion (Seed 010, V5):** el arranque de Hito 1 tiene dos modos. **Modo A (enriquecido):** el agente lee la página contenedora y la database de decisiones de Notion del proyecto y propone PRD/ADR/specs trasladando cada decisión con su estado (`Confirmada` → aceptada, `Pendiente` → `HITO0_PENDING`). **Modo B (desde cero):** entrevista estándar; al sellar, el agente crea la página y database en Notion con lo confirmado. Notion es *contexto* (el por qué), nunca fuente de verdad ejecutable; el gate no depende de Notion. Cada spec lleva `Contexto (Notion): <url>` y `Trazabilidad: SPEC:<id>`.

**Aprendizaje auditable (Seed 011, V5.1):** el molde institucionaliza tres mecanismos ligeros, sin código en el gate. (1) *Formato canónico de aprendizaje*: cada derivado lleva `docs/learning.md` (fecha, unidad, hallazgo, evidencia archivo:línea, aplicación futura, severidad). (2) *Auditoría del molde*: `docs/harness-metrics.md` vive en el molde; el supervisor registra ahí las fricciones al auditar un derivado. (3) *Ritual de cierre de sesión*: antes de cerrar una sesión con commits, exportá la conversación del harness a `docs/sessions/` y commiteala junto a la unidad. Es opt-in y sin hook; el gate nunca lee sesiones ni aprendizaje.

## Trabajo proporcional al riesgo

| Nivel | Uso | Registro |
|---|---|---|
| Tier 3 | Corrección de comportamiento confirmado, texto, presentación o refactor sin riesgo elevado | Registro compacto en STATE, si está autorizado |
| Tier 2 | Funcionalidad dentro del PRD y arquitectura, sin riesgos de Tier 1 | Spec breve con pruebas pertinentes |
| Tier 1 | Arquitectura, seguridad, datos delicados, pagos, concurrencia o cambios de controles | Spec detallada y revisión adicional acordada; ADR si cambia una decisión significativa |

Las integraciones se evalúan por datos, credenciales, costos, efectos y reversibilidad. Lecturas y auditorías sin cambios persistentes no requieren spec; un experimento temporal declara límites y limpieza. La fuente operativa de clasificación está en [AGENTS](AGENTS.md).

La delegación puede autorizar commits por alcance y riesgo para specs y registros ligeros conjuntamente. No amplía autorizaciones antiguas limitadas a una modalidad, ni concede push, merge o despliegue. Cerrar exige evidencia, DoD y gate completo; un chequeo rápido solo ayuda a iterar.

Las pruebas comprueban resultados, alternativas y rechazos relevantes. BDD puede vivir en tests referenciados por la spec; no requiere Cucumber. Documentación y presentación usan revisión pertinente, sin fase roja artificial. No se debilitan expectativas para conseguir verde.

STATE conserva trabajo activo y cierres recientes. Al superar diez cierres se archiva historia enlazada, sin perder IDs ni contadores. El umbral confirmado de intentos sin progreso conduce a checkpoint e intervención concreta; no reinicia por cambiar de sesión. Las [capacidades opcionales del anfitrión](docs/agent-capabilities.md) complementan la continuidad documental.

## Verificación

```sh
./scripts/verify.sh
```

Es el mismo comando para cierre local, hook y CI. Ejecuta:

- Integridad de documentos esenciales no vacíos y perfil explícito; detección acotada de placeholders críticos en documentos aceptados.
- Sintaxis de scripts Bash y pruebas del contrato del gate.
- En `seed`, piloto temporal con interrupción, recuperación, sellado, funcionalidad, corrección y reanudación.
- En `initializing` y `project`, `scripts/verify-project.sh`, generado para el runtime elegido y con errores propagados.

`verify-structure.sh` es interno y no sustituye el cierre. El piloto usa decisiones simuladas y una CLI Bash; no prueba una entrevista real ni todos los stacks. Un gate verde no certifica por sí solo la semántica del PRD, autoridad real de documentos ni aceptación final del producto. E2E, seguridad, build y operación se acuerdan por proyecto en AGENTS y su verificador. CI debe preparar el runtime correspondiente.

Los campos críticos pendientes usan `HITO0_PENDING` hasta resolverlos. La detección no rechaza enlaces Markdown ordinarios y permite placeholders en plantillas reutilizables de specs.

## Referencias opcionales

- [Catálogo de stacks](.agents/stack-presets.md): VPS, Cloudflare, Cloud Run y personalizado. Justificar componentes y verificar documentación actual antes de fijar versiones, compatibilidad o costos.
- Persistencia: primero decidir si hace falta. Si no, omitirla; si hace falta, comparar SQLite/PostgreSQL cuando correspondan u otra alternativa justificada.
- [Perfil offline-first](docs/architecture-profiles/full-stack-offline-first.md): referencia propuesta para escritura offline y sincronización. No implementada ni certificada por esta semilla; no impone monorepo ni dominio de asistencia.
Guía de actualización de derivados: comparar versiones, preservar personalizaciones, confirmar adopción y probar en copia (convención; el catálogo histórico de upgrades vive en el Constructor-Padre).

## Archivos del molde

- `.agents/bootstrap.md`, plantillas de PRD/prompt y perfil: inicialización.
- `specs/templates/feature.template.md`: plantilla adaptable; el derivado genera `feature.md`.
- `docs/adr/0000–0006`: historia de gobernanza; 0002 reservado al producto.
- `specs/seed-*.md`: alcance y evidencia de mantenimiento.
- `scripts/verify.sh`, `verify-structure.sh`, `tests/`: cierre y regresiones.
- `.github/workflows/verify.yml`, `.githooks/pre-commit`: invocan el gate.

La semilla sigue siendo el molde. Para conocer evidencia y pendientes actuales, consulta [STATE](STATE.md).
