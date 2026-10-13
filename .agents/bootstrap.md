# Protocolo de Inicialización: Hito 0

Actúas como facilitador de arquitectura. Hito 0 define el propósito y las reglas del nuevo proyecto antes del desarrollo de producción. La plantilla no elige tecnología ni dominio por el usuario.

## Principios

1. Pregunta como máximo dos cosas por turno y usa lenguaje claro.
2. Recoge decisiones confirmadas, supuestos, pendientes y elementos no aplicables por separado.
3. No inventes un stack, política, requisito ni comando para completar un documento. Cuando falte una decisión necesaria, presenta alternativas comprensibles y pregunta.
4. Consulta `STATE.md`, `AGENTS.md`, ADR 0000, ADR 0001, ADR 0003, ADR 0004, ADR 0005 y ADR 0006 antes de editar.
5. No instales dependencias sin autorización explícita o una decisión aceptada que lo autorice.
6. Mantén los ADR aceptados como historia inmutable; registra cambios posteriores en ADR nuevos con referencias explícitas.

## Fase 0: Protección de la plantilla

Determina el remoto canónico de Git normalizando HTTPS y SSH. Si el remoto corresponde a `Zer0x25/Hito-0`, explica que se recomienda crear un repositorio con “Use this template” y pregunta si quiere continuar en el molde maestro. Si no hay remoto, usa el nombre de carpeta como señal de advertencia, no como prueba concluyente. Una respuesta afirmativa permite continuar.

No comiences esta entrevista si la solicitud es revisar o mantener la plantilla Hito 0; en ese caso trabaja con la spec de mantenimiento activa.

## Fase 1: Integridad y fase

Lee `.agents/project-profile.conf`. Con `phase=seed`, ejecuta `scripts/verify.sh` antes de comenzar. Con `phase=initializing`, lee el checkpoint y retoma generación/verificación sin repetir la entrevista ni sobreescribir archivos personalizados. Con `phase=project`, comprueba STATE antes de cualquier acción: no reinicialices un proyecto sellado. Comprueba que estén presentes ADR 0000, ADR 0001 y la plantilla SDD neutral. No crees carpetas de aplicación antes de escoger el perfil.

## Fase 2: Entrevista adaptativa

### Modo de arranque: con Notion o desde cero

Antes de la entrevista, **verifica la capacidad de leer Notion en tu entorno** (no asumas que existe):

1. **Detecta:** ¿tienes alguna tool disponible para leer Notion? (Hermes: conector MCP de Notion; Antigravity: `agy mcp`; Codex/OpenCode: su config MCP). Cada harness gestiona sus propias tools; no hay un Notion universal.
2. **Si SÍ** → ofrece Modo A (enriquecido) normalmente.
3. **Si NO** → no falles: sugiere conectarse y ofrece tres salidas, en este orden:
   - *"Conectá Notion en tu entorno"* — indica cómo según el harness (Hermes: conector/connect OAuth; Antigravity: `agy mcp`; Codex/OpenCode: servidor MCP de Notion en su config). Luego reintenta Modo A.
   - *"Pegá el contexto de Notion a mano"* — el humano pega el markdown; `scripts/notion-context.sh` lo adopta tal cual (camino soportado, no un parche).
   - *"Arrancá en Modo B (desde cero)"* — entrevista estándar.

En cualquier caso, **el gate nunca depende de Notion**: si no hay capacidad de lectura, es el mismo fail-safe que ya existe (advierte, cae a entrevista). El molde sugiere y respeta; no impone un conector ni se acopla a un harness.

### Modo A — enriquecido (hay material en Notion y capacidad de leerlo)

El humano indica *"Inicia Hito-1 leyendo `<url o id de Notion>`"*. Lee la página contenedora y la database de decisiones vía las tools MCP de Notion (`GET_PAGE_MARKDOWN`; para la database, `NOTION_FETCH_DATA`/query) en tu sesión — las tools MCP no se invocan desde shell. Traslada cada decisión con su estado: `Confirmada` → aceptada en el repo; `Pendiente` → `HITO0_PENDING`. No inventes contenido ausente ni promociones pendientes. La entrevista se vuelve *validación*: presenta la propuesta de PRD/ADR/specs derivada de Notion y el humano confirma o corrige. Si Notion no responde o no está compartido, advierte y continúa con entrevista estándar (fail-safe).

### Modo B — desde cero (no hay material en Notion)

Entrevista estándar con el humano. Al sellar (Fase 4), crea la página contenedora y la database de decisiones en Notion con lo confirmado (vía MCP), para que Notion nazca poblado desde el repo. Si en el sellado tampoco hay capacidad de escribir en Notion, advierte y deja el repo como fuente; no bloquees el sellado.

En ambos modos, cada spec del derivado llevará `Contexto (Notion): <url>` y opcionalmente `Trazabilidad: SPEC:<id>`. Notion es contexto, nunca fuente de verdad ejecutable; el gate no depende de Notion.

Mantén un registro provisional de decisiones con estado `confirmada`, `pendiente`, `supuesto` o `no_aplica`. Pregunta en grupos de hasta dos elementos, adaptándote a lo ya respondido. Cubre lo pertinente de estas áreas:

- Nombre, problema, resultado esperado y qué queda fuera.
- Actores, flujos principales, entidades o datos y sus relaciones.
- Invariantes, fallos intolerables, permisos, privacidad, retención o auditoría, si aplican.
- Superficies de la aplicación: por ejemplo API, navegador, móvil, CLI, biblioteca, proceso batch o infraestructura; pueden combinarse o ser otras.
- Lenguaje, runtime, framework, persistencia, integraciones y dependencias preferidas o prohibidas. Si el usuario no tiene preferencia, explica las opciones antes de recomendar una.
- Despliegue, operación, restricciones de red/costo, rendimiento, disponibilidad, pruebas y mantenimiento, en la medida que el producto lo necesite.

### Meta de entrega y autonomía

Define una primera entrega finita: capacidades incluidas, exclusiones, flujos completos, requisitos de calidad y evidencia que demostrará cada resultado. Aclara si la entrega termina en ejecución local, staging o producción; un despliegue requiere autorización propia. No uses «app completa» como criterio sin concretarlo.

Acuerda la delegación conforme a ADR 0003, 0005 y 0006: autoaceptación de specs dentro del alcance, uso/aceptación de registros ligeros Tier 3, decisiones técnicas que puede aceptar en ADR nuevos, autorización acotada de dependencias y commits por unidad verificada. Confirma una política de commits por alcance y nivel de riesgo que incluya expresamente specs y registros ligeros, o conserva los límites que prefiera el usuario. No amplíes permisos anteriores por cambiar de formato. Acuerda la revisión adicional de Tier 1 según AGENTS y regístrala en el prompt. Presenta como flujo recomendado autonomía dentro de límites, commits locales autorizados y continuidad por unidad; registra la respuesta confirmada. No conviertas permiso de commit en permiso de push, merge o despliegue. Las decisiones materiales fuera de la delegación se consultan.

Usa `.agents/prd.template.md` para preparar un PRD breve con requisitos identificados y evidencia final; confirma ejemplos de comportamiento críticos y calidad aplicable, sin inventar negocio. Acuerda la DoD del perfil referenciando AGENTS y un umbral positivo de intentos sin progreso (referencia: tres), sin confundirlo con el número total de iteraciones de desarrollo. Usa `.agents/master-prompt.template.md` para invocación y delegación, referenciando el PRD sin duplicar su alcance. El prompt maestro será el registro de la entrevista y el punto de inicio de Hito 1; STATE llevará el avance. Usa STATE como continuidad básica; consulta `docs/agent-capabilities.md` solo si se necesitan capacidades opcionales del anfitrión.

### Gobernanza y verificación proporcional

Explica los niveles de AGENTS: Tier 3 admite un registro breve en STATE para correcciones acotadas; Tier 2 usa spec breve para funcionalidad dentro del PRD; Tier 1 requiere spec detallada por riesgo y ADR solo por decisión arquitectónica. Confirma si el agente puede clasificar y aceptar unidades de cada nivel dentro de los límites acordados; si no se autoriza el registro ligero, usa spec. No deduzcas el nivel del tamaño del cambio ni de su etiqueta. No amplíes automáticamente permisos de un proyecto existente por adoptar esta plantilla.

Acuerda los comandos reales del gate y, si resulta útil, un chequeo rápido con cobertura explícita para iterar. El cierre de cualquier nivel conserva `./scripts/verify.sh` y los controles obligatorios de la DoD; no generes `npm run check:quick` ni herramientas que el stack no tenga. Define aprendizaje útil por unidad y compactación por necesidad de contexto o entre unidades según preferencia; conserva siempre el checkpoint y contador de falta de progreso. Mantén hasta dos preguntas por turno y registra respuestas en el prompt, sin duplicar allí la tabla de AGENTS.

### Selección guiada del stack

Tras conocer propósito, superficies y flujos, lee `.agents/stack-presets.md`. Usa sus perfiles VPS, Cloudflare y Cloud Run como referencias opcionales y conserva la opción `custom` para otro destino o stack. Pregunta primero el destino de despliegue y las restricciones operativas, con hasta dos preguntas por turno. Si el destino está pendiente, compara alternativas según producto, experiencia del equipo y presupuesto total antes de cerrar la arquitectura.

Recomienda un perfil y una alternativa pertinente, explicando ajuste, límites, esfuerzo operativo y costos que deben verificarse. No presentes «moderno» o «ampliamente usado» como justificación suficiente. Consulta fuentes oficiales actuales antes de fijar versiones, compatibilidad, límites o precios; registra fecha y fuentes o deja la comprobación pendiente. Prefiere componentes estables con soporte activo y adapta la base a los conocimientos del equipo.

Selecciona cada componente por una necesidad: frontend solo si hay navegador, persistencia solo si hay datos duraderos, caché o colas solo si un flujo las requiere. En Cloudflare distingue Workers + Static Assets de la variante Pages, comprueba el ajuste de D1 y la consistencia eventual de KV. En Cloud Run verifica estado externo y contrato del contenedor; en VPS dimensionamiento y recuperación de datos. Sigue las condiciones de operación y verificación del catálogo.

Registra provisionalmente perfil base, variantes, componentes incluidos y descartados con sus razones, incompatibilidades y decisiones pendientes. La recomendación se convierte en arquitectura aceptada tras la confirmación de la Fase 3.

### Elección de base de datos

Cuando el PRD requiera escritura offline y sincronización entre dispositivos, consulta `docs/architecture-profiles/full-stack-offline-first.md` como perfil opcional propuesto. Pregunta duración máxima offline y operaciones permitidas, luego pérdida local admisible y conflictos relevantes, conservando hasta dos preguntas por turno. Si solo se necesita lectura offline, considera caché antes de proponer un motor completo. Confirma selección y compatibilidad con el despliegue; registra variantes y garantías pendientes de pruebas en ADR 0002 y specs. No copies el modelo de asistencia ni generes un monorepo por defecto.

Pregunta primero si se necesitan datos duraderos. Si no, registra `persistence=not_applicable` y omite la comparación. Si se necesitan, compara **SQLite y PostgreSQL** cuando sean alternativas pertinentes, o explica la opción adecuada al tipo de datos y despliegue. Evalúa escritores concurrentes, número de instancias, consultas, crecimiento, durabilidad, presupuesto y mantenimiento; no decidas solo por cantidad de usuarios ni asumas PostgreSQL por el perfil VPS. Sigue la comparación y las condiciones de despliegue en `.agents/stack-presets.md`.

Mantén hasta dos preguntas por turno. Confirma la elección antes de generar el acceso a datos y registra motor, modalidad de almacenamiento, razones y alternativa descartada en ADR 0002 y el resumen de persistencia del perfil. No añadas una base por defecto ni repitas una decisión ya confirmada.

No trates esta lista como formulario obligatorio. Marca lo irrelevante como `no_aplica`. Si hay una decisión crítica pendiente, no la aceptes en el ADR ni construyas sobre ella.

## Fase 3: Confirmación y constitución

Antes de crear artefactos, presenta un resumen breve con decisiones confirmadas, supuestos, asuntos pendientes y trade-offs. Incluye meta, criterios finales y límites de delegación. Confirma primero el PRD propuesto, la DoD y el umbral de falta de progreso; luego pide confirmar las decisiones arquitectónicas y la delegación del prompt maestro. Mantén hasta dos preguntas por turno. No cierres con alcance, aceptación o autoridad críticos pendientes. Tras confirmación, registra en STATE la inicialización pendiente y su primer paso. Usa `HITO0_PENDING` para cualquier campo crítico aún sin resolver; no lo retires sin resolverlo. Genera de forma repetible: antes de crear cada archivo, comprueba si existe y conserva personalizaciones. Procede así:

1. Guarda `PRD.md` aprobado desde su plantilla, incluyendo fuente de confirmación, requisitos de entrega y exclusiones. Crea `docs/adr/0002-arquitectura-base.md` usando `docs/adr/0000-template.md`. Describe problema, alternativas relevantes, stack elegido, límites, estructura adecuada a las superficies, riesgos, consecuencias y verificación. Incluye perfil base o `custom`, variantes, componentes justificados, versiones compatibles, fuentes con fecha y responsabilidades operativas. Declara los pendientes sin resolverlos por inferencia.
2. Actualiza `.agents/project-profile.conf` con `phase=initializing` y los campos `application_kind`, `surfaces`, `language`, `runtime`, `framework`, `persistence` y `ci_platform`. Completa además `deployment_target` y `stack_preset` como metadatos informativos del destino y perfil elegidos; estos dos campos no agregan requisitos al gate actual. Cada valor debe reflejar una decisión o indicar `not_applicable`; no guardes secretos.
3. Genera `specs/templates/feature.md` desde `specs/templates/feature.template.md` para Tier 2/1, añadiendo solo las secciones que corresponden al perfil y vocabulario acordados. Tier 3 usa el formato de AGENTS en STATE cuando se autorice; no requiere otra plantilla.
4. Genera el andamiaje mínimo de la aplicación en la estructura que corresponda. Incluye pruebas de humo y los artefactos de build o configuración que haya acordado el usuario. No generes `package.json`, `tsconfig.json`, DTOs Zod, controladores HTTP ni `src/core/errors.ts` salvo que el perfil y las decisiones los requieran.
5. Crea `scripts/verify-project.sh` ejecutable con comandos exactos del perfil y configura la CI elegida para preparar ese runtime y ejecutar `./scripts/verify.sh`. Registra en AGENTS los controles obligatorios del cierre y el chequeo rápido opcional confirmado con su cobertura; no crees un selector por tier que permita omitir el gate. Los pasos requeridos deben propagar errores; no uses `|| true` para ocultar fallos.
6. Si la arquitectura usa variables de entorno, documenta nombres ficticios en `.env.example` y explica la validación elegida. Nunca escribas credenciales reales.
7. Actualiza `.gitignore` con exclusiones apropiadas al perfil, conservando las exclusiones comunes de secretos y sistema.
8. Genera los artefactos de despliegue y el runbook acordados según el perfil: configuración de contenedores, proxy, bindings, recursos externos, migraciones y recuperación cuando apliquen. Define comandos locales reproducibles y comprobaciones remotas por separado. No crees recursos de nube ni despliegues como efecto automático de escoger un perfil.

9. Genera `PROMPT-MAESTRO.md` desde la plantilla, sin placeholders críticos: registra la entrevista confirmada, referencia al PRD aprobado, autoridad por nivel, política de commits/continuidad, referencia a comandos de verificación en AGENTS, umbral de falta de progreso y fuente de aprobación. En ADR 0002 referencia esa delegación. No reutilices 0003, 0004, 0005 o 0006 para arquitectura: están ocupados por gobernanza; los ADR posteriores usan el siguiente número libre (inicialmente 0007).
10. Crea `docs/learning.md` con el formato mínimo «fecha, ID de unidad, hallazgo, evidencia, aplicación futura» y personaliza `AGENTS.md` con estructura, comandos, DoD del perfil y límites de delegación confirmados, conservando reglas comunes y niveles. No copies allí el catálogo ni el historial. Prepara en STATE una secuencia inicial de unidades vinculadas con la meta, nivel, pendientes y primer paso.

## Fase 4: Sellado y transición

*(Al cerrar esta fase o cualquier unidad, antes de dar la sesión por terminada — ver Seed 011.)*

### Ritual de cierre de sesión (opt-in)

Si la sesión dejó commits, antes de cerrarla: exportá la conversación del harness a `docs/sessions/<fecha>-<titulo>.md` y commiteala junto a la unidad. Enlazá el export en la spec con el campo opcional `Sesión:`. Es **opt-in**: si no exportás, el gate pasa igual (evidencia adicional, no requisito). El export se redacta por defecto; nunca guardes tokens/API keys. Cada aprendizaje del flujo va a `docs/learning.md` con el formato canónico.

Cuando estén creados el PRD, el ADR, el perfil, la plantilla personalizada, el prompt maestro, aprendizaje, el verificador y la CI:

1. Conserva `phase=initializing`, bootstrap y disparador de reanudación. Actualiza README con propósito y comandos reales; STATE indica paso pendiente, decisiones confirmadas, evidencia y contador. No repitas respuestas ni generes de nuevo archivos válidos.
2. Ejecuta `./scripts/verify.sh` con el entorno autorizado. Si falta runtime, permisos o falla el gate, registra el bloqueo y siguiente hipótesis; conserva bootstrap activo y no declares Hito 0 completado. Una salida 0 en `initializing` verifica artefactos y comandos, pero aún requiere sellado.
3. Después del éxito, registra «sellado pendiente» en STATE. Archiva `.agents/bootstrap.md` como `.agents/bootstrap.md.done` y cambia `phase=project`. Retira el disparador de inicio de AGENTS solo al sellar; conserva una referencia a STATE para reanudar si queda pendiente. Si se interrumpe entre esos pasos, recupera bootstrap desde `.done`, vuelve a `initializing` y continúa desde el checkpoint; no reinicies la entrevista.
4. Ejecuta de nuevo el gate tras los cambios de sellado. Con salida 0 registra «Hito 0 completado; Hito 1 preparado, pendiente de invocación». Si falla, conserva el checkpoint, restaura bootstrap activo y `initializing` y resuelve la causa. Un gate de inicialización no demuestra la entrega final del producto.
5. Informa decisiones, pendientes y comandos ejecutados. Aplica la política de commit confirmada; sin autorización no hagas commit. Entrega la instrucción: **«Lee y ejecuta PROMPT-MAESTRO.md para iniciar Hito 1; crea o retoma la goal de entrega definida allí y sigue el ciclo por unidades de AGENTS.md»**. No inicies producto hasta esa invocación.
