# Protocolo Operativo para Agentes de Software

**Spring-0** proporciona un núcleo de **Spec-Driven Development (SDD)**, **Architecture Decision Records (ADR)**, **BDD**, **TDD** y **Quality Gates**, con alcance en PRD y cierre por DoD. La arquitectura concreta se define por proyecto en `docs/adr/0002-arquitectura-base.md` y se resume en `.agents/project-profile.conf`. Este repo es el molde que provee gobernanza a derivados; su construcción vive en Constructor-Padre.

## Estado inicial

Cuando el usuario pida iniciar un proyecto con `phase=seed`, lee `.agents/bootstrap.md`. Con `phase=initializing`, retoma el paso pendiente desde STATE y el bootstrap, preservando decisiones y archivos existentes; no reinicies la entrevista. Para revisar o mantener esta plantilla, no inicies la entrevista; sigue la unidad de mantenimiento aprobada según su nivel. Usa una spec salvo que la política confirmada autorice un registro ligero para una corrección Tier 3.

## Reglas de gobernanza

### 1. Fuente de contexto y decisiones

1. Consulta `STATE.md`, el perfil y los ADR aplicables al inicio del trabajo.
2. Los ADR aceptados son registros históricos inmutables. No los edites. Si una petición requiere cambiar una decisión, redacta un nuevo ADR que enlace y, cuando corresponda, reemplace el anterior; espera su aceptación antes de implementar el cambio arquitectónico. ADR 0003 permite aceptar decisiones dentro de una delegación confirmada en `PROMPT-MAESTRO.md`; fuera de ella, acepta el usuario.
3. Distingue decisiones confirmadas, supuestos, pendientes y elementos no aplicables. No presentes una inferencia como decisión aprobada.
4. ADR 0006 aclara la precedencia: los documentos del repo no están por encima de las instrucciones del anfitrión ni de nuevas instrucciones explícitas del usuario. Registra cambios autorizados de decisión antes de implementarlos; conserva los ADR históricos. Una contradicción material sin resolver requiere consulta.
5. Auditoría, lectura y diagnóstico sin cambios persistentes no requieren spec. Para un experimento temporal declara objetivo, límites, verificación y limpieza; no instala dependencias ni afecta servicios sin autoridad. Implementar sus resultados requiere la unidad correspondiente.

### 2. SDD y Agentic TDD

1. Antes de editar, clasifica la unidad y registra autoridad, alcance y criterios verificables según los niveles de esta sección y ADR 0005. Tier 2/1 requieren spec en `specs/*.md`; Tier 3 puede usar un registro ligero solo si esa modalidad está autorizada. Sin confirmación, usa spec.
2. Lee la spec o registro activo, la fuente del comportamiento esperado y los ADR relacionados antes de diseñar o modificar.
3. Crea primero contratos y pruebas adecuados al perfil del proyecto.
4. Ejecuta las pruebas antes de implementar y confirma que fallan por la condición esperada; luego implementa lo mínimo y vuelve a ejecutarlas.
5. Cada criterio de aceptación debe corresponder a una verificación observable. Elige pruebas unitarias, integración, extremo a extremo, estáticas u operativas según el cambio.
6. Si una prueba necesita estado previo, define preparación y restauración repetibles; usa los identificadores que entrega el fixture y no datos residuales o IDs supuestos.
7. En proyectos inicializados, vincula unidades con los requisitos del PRD o con una corrección técnica justificada. Puedes autoaceptarlas solo dentro de la delegación confirmada para su nivel, registrando autoridad y justificación; las que excedan el alcance requieren aprobación. Para documentación y ajustes de presentación sin cambios de comportamiento usa revisión de consistencia o visual y gate; no inventes una fase roja artificial.

#### Niveles por riesgo y efecto

| Nivel | Aplicación | Registro y controles propios |
|---|---|---|
| **Tier 3 — Ligero** | Corrección acotada que restaura comportamiento confirmado; textos, presentación o refactor interno sin cambiar contrato ni introducir riesgos de Tier 1. | Registro breve en STATE vinculado a la fuente vigente; regresión cuando cambia código de comportamiento, o comprobación visual/documental pertinente. Sin spec ni ADR nuevos. |
| **Tier 2 — Estándar** | Funcionalidad dentro del PRD y arquitectura aprobados, como endpoint, componente, filtro o integración sin riesgos de Tier 1. | Spec breve, contrato cuando aplique y escenarios BDD vinculados a pruebas del resultado, alternativas y rechazos pertinentes. |
| **Tier 1 — Riesgo alto** | Arquitectura, seguridad/permisos, pagos, concurrencia, migraciones delicadas y cambios a controles de gobernanza. Integraciones con datos sensibles, credenciales, costos o efectos difíciles de revertir; incluidos bugfixes en esos ámbitos. | Spec detallada con invariantes, riesgos y controles de integración, datos, seguridad u operación aplicables. ADR nuevo solo si introduce o cambia una decisión significativa. |

El número de líneas, la palabra «bugfix» o «corrección de tests» no determinan el nivel. Justifica la clasificación antes de editar; ante incertidumbre usa el nivel de mayor control pertinente y consulta ambigüedades críticas. Si aparecen riesgos o cambios de contrato, actualiza el registro y escala a spec antes de continuar; conserva el ID anterior como referencia. Cambiar de nivel no amplía autoridad ni reinicia el contador de falta de progreso.

Spec y ADR cumplen funciones distintas: el ADR no sustituye contratos y verificación. Actualiza PRD solo si cambia el alcance o la aceptación del producto y el usuario lo confirma. No impongas monorepo, DTO compartido, ORM, runner de tests o comandos de diagnóstico específicos: usa los del perfil. BDD puede vivir en nombres/comentarios de tests referenciados por ID o ruta desde la spec; las aserciones deben comprobarlo. No debilites tests ni cambies expectativas para conseguir verde; justifica una corrección de tests frente a la fuente del comportamiento confirmado.

#### Registro ligero Tier 3

Con modalidad y autoridad confirmadas, crea antes de editar un bloque en STATE; no hace falta otro archivo. Referencia la spec/contrato existente o la instrucción del usuario que confirma el resultado. No modifiques una spec cerrada para alojar la corrección. Si el comportamiento esperado no está claro, usa spec y consulta lo crítico; los tests existentes no resuelven por sí solos una ambigüedad de negocio.

```text
LIG-001 — [Descripción] — Tier 3: [justificación] — [estado]
Resultado/fuente: [problema → criterio; spec/contrato/instrucción vigente y requisito si aplica]
Alcance/autoridad: [rutas y límites; quién, fecha y petición/delegación]
Verificación/cierre: [verificación prevista → evidencia real, aprendizaje si útil, commit/local; siguiente paso y contador/bloqueo si existen]
```

Al terminar, conserva el registro y su evidencia. Otro defecto usa otro ID; no sobrescribas un cierre previo. Todas las unidades mantienen límites, DoD, gate y checkpoint. La delegación puede incluir ambas modalidades por alcance y riesgo. No extiendas una autorización antigua limitada a specs; el registro ligero requiere modalidad y autoridad confirmadas.

### 3. Límites de cambio

- Modifica solo los archivos autorizados en la spec o registro ligero activo.
- Si necesitas otro archivo, actualiza primero la spec o registro y registra el motivo antes de editarlo.
- No alteres módulos adyacentes, configuraciones globales ni archivos protegidos sin autorización explícita en la unidad aprobada.
- No instales ni actualices dependencias sin autorización explícita o una decisión aceptada que lo permita.
- Cambiar permisos, lógica del gate, CI de cierre o criterios de aceptación es Tier 1 cuando altera controles. Incluye esas rutas y la decisión en la unidad autorizada; no uses la autoaceptación para reducir controles. Una corrección de redacción que preserva la regla se clasifica por su efecto real.
- En Tier 1 acuerda revisión adicional según el riesgo: humana o separada para seguridad, datos y efectos irreversibles; pruebas adversarias para controles deterministas. Registra modalidad, responsable y evidencia en la spec. No presentes revisión propia como independiente; si la revisión acordada falta, el cierre queda pendiente.

### 4. Contratos, fallos y seguridad

- Usa el mecanismo de contratos y errores definido por el stack elegido. Los códigos de error estables y el mapeo semántico al transporte aplican cuando el perfil los requiera.
- Valida entradas en los límites de confianza definidos por la arquitectura; no confíes en restricciones de interfaz para autorizar acciones.
- Si existen roles, tenants o ámbitos de datos, aplica denegación segura en la capa autoritativa que controla el acceso y prueba los casos permitidos, denegados y sin alcance asignado.
- Nunca incluyas secretos reales en código, specs, logs, fixtures, documentación ni repositorio. Documenta solo nombres y valores ficticios.
- Para integraciones externas, define cuando aplique timeout, reintentos, idempotencia, aislamiento de fallos y diagnóstico.

### 5. Especificación de datos y estado

Cuando la funcionalidad maneje datos persistentes, documenta según corresponda las relaciones, invariantes, estados y transiciones, concurrencia, atomicidad, auditoría, retención, migración y reversión. Las operaciones mutantes deben verificarse mediante el estado persistido, no solo por el código de respuesta.

### 6. Commits

Si el usuario autoriza o solicita crear commits, sigue Conventional Commits con un tipo y descripción concretos, por ejemplo `feat: agregar exportación` o `fix(auth): rechazar sesión expirada`. La política confirmada en el prompt maestro puede autorizar commits de unidades verificadas por alcance y riesgo, incluyendo expresamente specs y registros ligeros en una misma autorización. Antes de commitear revisa Git, añade solo archivos o cambios del alcance y comprueba el diff staged; no incluyas cambios ajenos ni uses `git add .` indiscriminadamente. Sin autorización, no hagas commits. El permiso de commit no concede push, merge ni despliegue.

### 7. Quality Gate

Toda entrega debe ejecutar `./scripts/verify.sh` y reportar el resultado. El comando delega según la fase y los comandos declarados por el perfil; no presupongas npm, un lenguaje ni una clase de pruebas determinada. Los pasos requeridos deben propagar errores y no ocultarlos con `|| true`.

El gate raíz ejecuta integridad documental, sintaxis Bash y contrato de fases; en semilla añade el piloto temporal. En `initializing` y `project` ejecuta además `scripts/verify-project.sh`. La fase `initializing` no declara sellado; `scripts/verify-structure.sh` es interno y no sustituye el cierre. La CI invoca el mismo gate; declara por separado si sus pruebas E2E, seguridad, build u otras verificaciones forman parte del gate completo.

**Gobernanza ejecutable (Seed 009):** en `phase=project`, `scripts/verify-scope.sh` aplica dos controles mecánicos que sustituyen la regla de prompt. (1) *Scope-lock*: compara los cambios contra la base autorizada (`origin/main`, incluyendo archivos nuevos) con los «Archivos autorizados» de la unidad activa declarada en STATE; una ruta fuera de lista bloquea el commit. (2) *Evidencia*: una unidad en estado Cerrada debe tener, por criterio CA, una línea de evidencia con comando y resultado real. El gate gobierna el flujo, no la estructura: si la unidad, su sección de rutas o sus criterios no se pueden parsear, advierte y omite ese control — nunca bloquea por no entender. En `initializing` advierte sin bloquear; en `seed` no corre (el molde no tiene unidad de producto). Los ADR `0000–0006` son del molde (ejemplo/guía); los ADR del proyecto derivado usan `0002` (arquitectura) y `0007+`. La evolución del molde se gobierna en Constructor-Padre; los derivados no la tocan.

**Capacidades acumuladas del flujo:** las capacidades que el flujo fue sumando —gobernanza ejecutable (Seed 009), arranque con Notion y sus dos modos (Seed 010), aprendizaje auditable y ritual de cierre de sesión (Seed 011), preparación de capa/system design (Seed 013) y decisiones transversales por dominio (Seed 014)— están detalladas en [`docs/flujo-capacidades.md`](docs/flujo-capacidades.md). Los puntos que el protocolo necesita recordar siempre:

- **Arranque con Notion (Seed 010):** Hito 1 tiene dos modos (A enriquecido leyendo Notion como contexto / B entrevista desde cero); antes de ofrecer Modo A verifica la capacidad de lectura de Notion en tu entorno (cada harness gestiona sus propias tools MCP; no hay Notion universal); sin capacidad, las salidas son conectar, pegar el contexto a mano (`notion-context.sh` lo adopta) o Modo B. Notion es contexto, nunca fuente ejecutable; el gate no depende de Notion. Cada spec lleva `Contexto (Notion): <url>` y opcionalmente `Trazabilidad: SPEC:<id>` (enlace a spec inexistente advierte, nunca bloquea).
- **Ritual de cierre de sesión (Seed 011):** antes de cerrar una sesión que dejó commits, exportá la conversación del harness a `docs/sessions/<fecha>-<titulo>.md` y commiteala junto a la unidad (campo opcional `Sesión:` en la spec). Es opt-in y sin hook: la ausencia de export no bloquea el gate. Export redactado por defecto; nunca guardes tokens/API keys en las sesiones. El gate nunca lee sesiones ni aprendizaje.
- **Preparación de capa (Seed 013):** si la unidad toca una capa nueva (UI/frontend, offline) sin decisión de diseño previa, escribí el ADR de system design, validalo con el humano y recién implementá; la lógica de negocio y autorización viven SOLO en backend.
- **Decisiones transversales (Seed 014):** antes de tocar código de un dominio, el ADR base declara modelo de errores, contexto tenant/auth y estrategia de tests; una vez por dominio, reutilizadas por los módulos siguientes.

Un chequeo rápido opcional, confirmado con comandos y cobertura reales del perfil, sirve para iterar. Su resultado no sustituye el gate raíz ni los controles obligatorios de la DoD al cerrar cualquier nivel. El agente no omite suites ni reduce el gate por reclasificar una tarea.

### 8. Desarrollo y continuidad de sesión

En Hito 1, al invocar `PROMPT-MAESTRO.md`, inicia o retoma la meta solicitada mediante las capacidades disponibles y registra su estado en STATE. PRD define alcance y aceptación final; el prompt referencia esa meta y define invocación y autoridad; AGENTS contiene reglas y DoD; ADR decisiones; specs contratos y escenarios; STATE progreso y registros ligeros; `docs/learning.md` aprendizaje. No dupliques esos registros.

Por cada unidad (spec o registro ligero Tier 3 autorizado):

1. Clasifica, justifica y acepta según la delegación del nivel. Tier 3 usa el formato de la sección 2 si está autorizado; en otro caso, y para Tier 2/1, redacta spec, incluyendo rutas de la spec, STATE y aprendizaje y AGENTS si necesita ajustes. Define contratos y escenarios BDD Dado/Cuando/Entonces para comportamientos relevantes, incluyendo alternativas y rechazos. Vincula requisito del PRD o corrección justificada, escenario/criterio y prueba. Para cambios puramente técnicos usa verificaciones adecuadas; no exijas Cucumber ni Gherkin artificial. Las ambigüedades de negocio críticas se consultan, sin resolverlas por autoaceptación.
2. Ejecuta contratos/pruebas, implementación y gate; corrige fallos antes del cierre. No avances como si una verificación requerida hubiera pasado cuando está pendiente.
3. Registra comandos/resultados en la spec o cierre ligero y en `docs/learning.md` una entrada breve con ID de unidad, hallazgo, evidencia y aplicación futura si existe un aprendizaje útil; si no, registra «sin hallazgos nuevos» en el cierre, sin inventarlos. En mantenimiento de semilla el aprendizaje puede quedar en la spec. No guardes secretos ni conviertas una observación en regla arquitectónica sin ADR.
4. Actualiza STATE con cobertura de la meta, unidad actual/siguiente, pendientes, pruebas y checkpoint. En Tier 3 el mismo bloque puede servir de registro y checkpoint, sin duplicarlo. Ajusta AGENTS a comandos o estructura reales solo si está autorizado; conserva gobernanza y evita añadir el historial de sesiones.
5. Crea el commit del alcance verificado cuando la política confirmada lo requiera y autorice, incluyendo spec si aplica y registros. Si un commit requerido falla o falta su autorización, registra cierre pendiente; si no es requerido, registra los cambios locales sin afirmar que fueron commiteados. Tras éxito informa el hash; el checkpoint puede referirse al commit de la unidad por su ID para evitar un segundo commit solo para registrar su propio hash.
6. Conserva un checkpoint antes de cambiar de sesión o compactar y reanuda desde los archivos. Las capacidades opcionales del anfitrión están en `docs/agent-capabilities.md`; no son pasos obligatorios por unidad ni autorizan memorias globales.

Checkpoint mínimo en STATE: meta y criterios pendientes, unidad terminada/activa con ID y nivel, referencia al commit o estado local, evidencia y bloqueos, siguiente unidad y primer paso. Si una goal sigue activa y la compactación es manual, registra ese punto de control; no marques la goal completa ni pausada por iniciativa propia.

STATE conserva meta, unidad activa, bloqueos y cierres recientes. Al superar diez cierres, mueve los anteriores íntegros a `docs/history/` y enlázalos, preservando IDs y evidencia. Nunca archives contadores activos ni autorizaciones aún necesarias.

Solo declara la app completa cuando cumple aceptación final del PRD y DoD. Un gate verde de Hito 0 únicamente acredita la inicialización.

### 9. Definition of Done (DoD)

Personaliza los comandos y controles aplicables al perfil durante Hito 0; la DoD no cambia por iniciativa del agente para obtener verde. No copies la lista común en cada spec o registro: referencia esta sección y añade solo condiciones propias.

Una unidad de cualquier nivel queda terminada cuando:

- Cumple los criterios aceptados, contratos e invariantes; los escenarios BDD pertinentes tienen pruebas con el resultado esperado.
- Pasan pruebas pertinentes y gate acordado; no hay verificaciones obligatorias pendientes ni cambios que debiliten expectativas para ocultar fallos.
- Se revisó el diff contra alcance y decisiones; controles de seguridad, datos, interfaz u operación aplicables están comprobados.
- Documentación afectada, evidencia de la spec o registro ligero, aprendizaje y checkpoint están actualizados; el commit requerido está realizado según autorización. Si no se requiere commit, declara explícitamente el estado local de los cambios.

La app queda terminada cuando todos los requisitos de la entrega del PRD tienen evidencia satisfactoria, pasan flujos integrados y verificaciones de calidad acordadas, y se entregan instrucciones reproducibles de ejecución/operación y commits requeridos. Un despliegue es condición de cierre solo si se acordó en el PRD y fue autorizado. Las mejoras opcionales van a trabajo futuro; no reabras una spec cerrada por perfeccionamiento sin un defecto o requisito concreto.

### 10. Falta de progreso y salida del ciclo

Mantén una unidad activa, identificada por spec o registro ligero y nivel. Cada intento sobre un fallo tiene hipótesis, acción y evidencia; actualiza el resumen del problema en STATE, sin acumular logs completos. Progreso es resolver un criterio, reducir reproduciblemente el fallo o descartar una hipótesis con evidencia útil para una alternativa distinta. Repetir comandos, renombrar registros/specs o reformular documentos sin evidencia no cuenta.

Usa el umbral positivo confirmado en el prompt (referencia de entrevista: tres intentos consecutivos sin progreso). Al alcanzarlo, detén los reintentos del mismo problema, conserva cambios/checkpoint e informa: resultado esperado y observado, hipótesis probadas, evidencia y dato, permiso o decisión concreta necesaria. No inventes una alternativa para reiniciar el contador. Otra tarea solo avanza si es independiente, autorizada y no disfraza el mismo bloqueo.

Compactar, cambiar de sesión, reclasificar o renombrar la unidad no reinicia el contador: consérvalo en STATE y actualízalo solo con progreso verificable o una intervención que habilite una hipótesis nueva. No declares éxito, reduzcas PRD/DoD, elimines pruebas ni amplíes permisos para escapar del bloqueo. Los cambios de alcance requieren aprobación. Los estados de una goal del anfitrión siguen las reglas de sus herramientas; esta política permite diagnosticar y escalar el problema, sin autorizar pausarla o marcarla bloqueada por inferencia.

Antes de cada reanudación comprueba el checkpoint para evitar repetir aprendizaje, compactación o arranque sobre una unidad ya cerrada. Al cumplir DoD, cierra y avanza; al cubrir el PRD, termina la meta.
