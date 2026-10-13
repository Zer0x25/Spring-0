# Catálogo opcional de stacks por despliegue

Este catálogo ayuda a recomendar durante Hito 0. Sus perfiles son puntos de partida para aplicaciones web o API; otras superficies y tecnologías pueden usar `custom`. La decisión final pertenece al ADR de arquitectura del proyecto.

Revisión de fuentes: **2026-10-06**. En cada entrevista consulta documentación oficial actual antes de fijar versiones, soporte, compatibilidad, límites o costos. Registra fuentes y fecha en ADR 0002; si no puedes consultarlas, declara la comprobación pendiente. Prefiere versiones estables con soporte activo, verifica su compatibilidad mutua y fija versiones y lockfile al generar el proyecto. Una tecnología reciente o popular no prueba por sí sola su ajuste.

## Cómo recomendar

1. Conoce primero propósito, superficies y flujos, requisitos de datos, integraciones y experiencia del equipo.
2. Pregunta destino de despliegue y restricciones operativas: presupuesto total, región, capacidad disponible, carga estimada y quién mantendrá la infraestructura. Reparte las preguntas en turnos de hasta dos elementos.
3. Evalúa SSR/SEO, procesos largos, binarios nativos, tiempo real, consistencia, aislamiento de datos y requisitos de privacidad cuando apliquen. Identifica las condiciones que descartan un perfil.
4. Presenta un perfil recomendado y una alternativa relevante, con razones ligadas a requisitos, esfuerzo operativo, costos a comprobar y compromisos. Si el usuario ya decidió, valida el ajuste de su elección. Si aún no eligió destino, compara destinos antes de recomendar el stack definitivo.
5. Para una web CRUD sin requisitos de servicios independientes, propone una aplicación modular y el menor número de unidades desplegables que cubra sus flujos. Añade caché, colas, servicios separados u orquestación cuando una necesidad los justifique.
6. Confirma el stack completo antes de compilar: runtime, interfaz, backend, contratos/validación, acceso a datos y migraciones, autenticación si aplica, pruebas, despliegue y CI. Un perfil no resuelve automáticamente estas decisiones.

## Comparación inicial

| ID | Destino | Base de referencia para web/API | Criterio para elegir |
|---|---|---|---|
| `vps-compose` | VPS Linux | TypeScript, Node LTS, Fastify, React + Vite si hay SPA, SQLite o PostgreSQL según alcance, Docker Compose y Caddy | Control del servidor y de procesos; equipo capaz de operarlo |
| `cloudflare-workers` | Cloudflare Workers | TypeScript, Hono, Workers + Static Assets, React + Vite si hay SPA; D1 cuando encaje la persistencia SQL | App compatible con el runtime Workers y sus servicios administrados |
| `gcp-cloud-run` | Google Cloud Run | TypeScript, Node LTS, Fastify en contenedor, React + Vite si hay SPA; PostgreSQL administrado cuando se requiera | Contenedores con escalado administrado y estado externo |
| `custom` | Destino acordado | Tecnologías elegidas por requisitos y experiencia del equipo | Otra superficie, stack existente o condiciones que descarten las bases anteriores |

La base TypeScript reduce la diversidad de lenguajes en una web con equipo familiarizado con ese ecosistema; es una recomendación de este catálogo. Python, Go, Java, .NET y otros stacks tienen la misma validez si encajan mejor. Para una API omite React/Vite; para un sitio estático omite backend y base de datos cuando no se necesiten. Si hay SSR/SEO, compara un framework adecuado, su soporte en el destino y el costo de su adaptador; no conviertas una SPA en elección automática.

## Elección de persistencia: SQLite y PostgreSQL

Primero determina si hacen falta datos duraderos. Si no, registra `not_applicable` y omite este bloque. Si se necesitan, compara SQLite y PostgreSQL cuando sean pertinentes, o explica otra opción justificada por los requisitos. No repitas elecciones ya confirmadas.

| Opción | Cuándo recomendarla | Qué comprobar |
|---|---|---|
| SQLite | Almacenamiento local de una app, normalmente una instancia, con escrituras que pueden ejecutarse por turnos y prioridad de operación sencilla | Solo un escritor simultáneo por archivo; duración de transacciones, contención, volumen persistente, backups y recuperación |
| PostgreSQL | Muchos escritores concurrentes, varias instancias que comparten datos, necesidades SQL específicas o una base administrada separada de la app | Conexiones/pools, recursos, operación o costo administrado, migraciones y recuperación |

La cantidad de usuarios y el tamaño del proyecto por sí solos no deciden el motor. Evalúa carga de escritura, consultas, invariantes, crecimiento previsto y capacidad operativa. No prometas que una migración entre motores será automática: dialectos, tipos y migraciones requieren revisión y pruebas.

- **VPS:** SQLite debe vivir en un volumen persistente accesible por la app, con estrategia de backup consistente; no compartas el archivo entre servidores por un filesystem de red. PostgreSQL requiere volumen propio o servicio externo.
- **Cloudflare:** presenta D1 como opción administrada con semántica SQL de SQLite, diferenciándola de un archivo SQLite local; ofrece PostgreSQL externo con una conexión compatible, por ejemplo Hyperdrive cuando encaje. Comprueba límites y driver de cada opción.
- **Cloud Run:** explica SQLite y PostgreSQL, señalando que un archivo SQLite en el filesystem efímero de la instancia no proporciona persistencia duradera compartida. Recomienda PostgreSQL externo para ese caso; una alternativa basada en SQLite necesita arquitectura de almacenamiento compatible y explícita antes de aceptarse.
- **Offline en navegador:** Dexie/IndexedDB es una decisión de almacenamiento local adicional; la elección de base del backend se resuelve por separado.

Tras confirmación, registra motor y modalidad en ADR 0002 y `persistence` del perfil. Genera solo el driver, esquemas, migraciones, verificaciones y operación correspondientes a esa elección.

Fuentes: [criterios de elección de SQLite](https://www.sqlite.org/whentouse.html), [Hyperdrive](https://developers.cloudflare.com/hyperdrive/), [D1](https://developers.cloudflare.com/d1/), [filesystem en Cloud Run](https://docs.cloud.google.com/run/docs/container-contract).

## Perfil `vps-compose`

**Base:** Linux con soporte activo, Docker Compose, Caddy como entrada HTTPS, backend Node LTS + TypeScript + Fastify. Para SPA, React + Vite produce archivos servidos por Caddy. Ofrece SQLite y PostgreSQL según la comparación de persistencia; SQLite usa almacenamiento local persistente y PostgreSQL puede operarse en el VPS o en un servicio administrado. Elegir driver o capa de acceso y herramienta de migración explícitamente.

**Componentes condicionales:** almacenamiento de objetos para archivos cuando el volumen o recuperación lo requiera; cola y proceso de trabajo para tareas que deban sobrevivir a reinicios; caché solo con una necesidad medida. Si se prefiere otro backend por conocimientos del equipo, registra la variante del perfil.

**Operación y límites:** dimensiona memoria para SO, proxy, app, base de datos y picos de concurrencia; establece límites efectivos de contenedores y pools. En un VPS pequeño evalúa separar la base de datos o simplificar componentes. Declara quién aplica parches, supervisa disco, gestiona secretos y responde a fallos. Si hay datos, exige volúmenes persistentes, backup fuera del servidor, retención y una restauración comprobable. Una instancia única no ofrece alta disponibilidad por sí sola.

**Artefactos a acordar:** Dockerfile, archivos Compose por entorno, configuración Caddy, migraciones si hay base de datos, runbook de arranque, salud, backups y reversión. Evita credenciales reales en estos archivos.

**Verificación:** comandos del lenguaje para tipos/lint/tests/build; validación de Compose y build de imagen si las herramientas están disponibles; prueba de humo de la app en contenedor con dependencias temporales. Para datos, prueba migraciones en una base aislada y restauración según el alcance acordado. El gate local no demuestra DNS, TLS ni salud del VPS remoto.

**Fuentes:** [Compose en producción](https://docs.docker.com/compose/how-tos/production/), [HTTPS automático de Caddy](https://caddyserver.com/docs/automatic-https), [Fastify](https://fastify.dev/docs/latest/), [Vite](https://vite.dev/guide/).

## Perfil `cloudflare-workers`

**Base:** TypeScript + Hono en Workers; Workers Static Assets para archivos de interfaz, con React + Vite si hay SPA. Usa bindings tipados para recursos y configura secretos según la plataforma. Comprueba APIs y dependencias en el runtime Workers: compatibilidad Node no equivale a disponer de un servidor Node completo ni de todos los binarios nativos.

**Persistencia y componentes condicionales:**

- D1 es candidato SQL basado en SQLite. Comprueba tamaño, consultas, transacciones, concurrencia y estrategia de lectura contra las invariantes del producto; no asumas equivalencia con PostgreSQL.
- KV sirve para datos de lectura frecuente que toleran consistencia eventual, por ejemplo configuración no crítica. No lo uses como autoridad para saldos, reservas, bloqueo distribuido ni revocación inmediata de permisos. No añadas KV si no hay un caso que lo requiera.
- Para caché de respuestas evalúa primero las herramientas de caché de Workers. Si eliges KV para caché, justifica el caso y tolerancia a datos desactualizados.
- Considera Durable Objects si necesitas coordinación por entidad o tiempo real; R2 para archivos; Queues para trabajo asíncrono. Valida el producto concreto y sus límites antes de aceptarlo.

**Variante Pages:** si el usuario prefiere Pages o mantiene un proyecto existente, puede elegir Pages para frontend y Workers para API, o Pages Functions cuando encaje. Usa `stack_preset=cloudflare-pages` y registra despliegues, bindings, rutas, CORS y autenticación entre orígenes cuando apliquen. Para proyectos nuevos presenta primero Workers + Static Assets, según la orientación actual de Cloudflare.

**Operación y límites:** confirma límites vigentes de ejecución y almacenamiento, modelo de datos, disponibilidad regional requerida y costo por uso. Define recursos separados entre desarrollo, pruebas y producción; una URL de preview no garantiza aislamiento de la base. Declara migración y recuperación de datos por separado de la reversión de código.

**Artefactos a acordar:** configuración Wrangler con fecha de compatibilidad verificada, bindings sin secretos, migraciones D1 si aplica, configuración de frontend/rutas y runbook de recursos por entorno.

**Verificación:** tipos/lint/build, pruebas en runtime compatible con Workers y pruebas locales de bindings/rutas. Si hay D1, ejecuta migraciones sobre una base local aislada y verifica las invariantes relevantes. Declara por separado las pruebas que necesiten recursos remotos; el gate local no certifica cuotas, permisos de cuenta ni producción.

**Fuentes:** [Static Assets](https://developers.cloudflare.com/workers/static-assets/), [Pages y Workers](https://developers.cloudflare.com/workers/static-assets/migration-guides/migrate-from-pages/), [D1](https://developers.cloudflare.com/d1/), [consistencia de KV](https://developers.cloudflare.com/kv/concepts/how-kv-works/), [Hono en Workers](https://developers.cloudflare.com/workers/framework-guides/web-apps/more-web-frameworks/hono/), [pruebas Workers](https://developers.cloudflare.com/workers/testing/).

## Perfil `gcp-cloud-run`

**Base:** servicio Node LTS + TypeScript + Fastify en una imagen de contenedor. Si hay SPA, React + Vite puede generar archivos servidos por la misma app; evalúa hosting estático separado cuando lo justifiquen distribución o operación. Si se necesita SQL relacional, considera Cloud SQL PostgreSQL o un PostgreSQL administrado ya disponible; verifica costo total y forma de conexión.

**Componentes condicionales:** Cloud Storage para archivos persistentes; Secret Manager para secretos según la configuración acordada; Cloud Run Jobs para batch que finaliza, o Cloud Tasks/Pub/Sub si hacen falta entregas asíncronas. Usa cuenta de servicio con los permisos definidos para cada integración. Cada servicio adicional debe responder a un requisito.

**Operación y límites:** el servicio escucha en `0.0.0.0` y el puerto proporcionado por `PORT`; Cloud Run termina TLS. El filesystem local de la instancia no es almacenamiento duradero. Diseña sesiones y datos compartidos fuera de la instancia cuando deban sobrevivir a reinicios o servir a varias réplicas. Ajusta concurrencia, memoria, timeout e instancias mínimas/máximas; evalúa arranque en frío según la latencia requerida. Dimensiona conexiones: pool por instancia × máximo de instancias debe caber en el presupuesto de la base junto con otros clientes. Declara región, acceso público o autenticado y recuperación de datos.

**Artefactos a acordar:** Dockerfile, configuración de servicio/revisión y cuenta de servicio, migraciones, procedimiento de despliegue y distribución/reversión de tráfico, runbook de datos y secretos. La herramienta de CI y registro de imágenes se eligen explícitamente; Cloud Run no obliga a usar una CI particular.

**Verificación:** tipos/lint/tests/build, build de imagen y prueba de humo con `PORT` y almacenamiento externo temporal si aplica. Ejecuta migraciones una vez como paso controlado, evitando que cada réplica las lance al arrancar. Las comprobaciones de IAM, conexión administrada, escalado y revisión remota requieren un entorno autorizado y quedan separadas del gate local.

**Fuentes:** [contrato de contenedor](https://docs.cloud.google.com/run/docs/container-contract), [conexión a Cloud SQL](https://docs.cloud.google.com/sql/docs/postgres/connect-run).

## Perfil adicional: operación offline y sincronización

Si el PRD exige capturar cambios sin conexión y reconciliar varios dispositivos, consulta el [perfil full stack offline-first](../docs/architecture-profiles/full-stack-offline-first.md) (`offline-first-postgres`). Es una referencia propuesta, pendiente de validación: no es arquitectura aceptada ni base automática para toda PWA. Si basta lectura offline, evalúa caché; si la app es siempre conectada, omite el motor.

Este perfil complementa el destino elegido; sus componentes deben ser compatibles con ese runtime. PostgreSQL central es una decisión de este perfil opcional; compara otro motor cuando sea pertinente y documenta su variante y pruebas propias. SSE, TanStack Query, monorepo y ejemplos de asistencia son opcionales o ilustrativos. En ADR 0002 registra la selección, variantes, duración offline, pérdida local admisible, ámbito, conflictos y garantías a probar; no añadas un campo obligatorio al manifiesto por esta referencia.

## Registro y generación

Tras confirmación del usuario, ADR 0002 debe incluir perfil base y variantes, motivos, alternativa descartada, dependencias/componentes seleccionados, fuentes con fecha, restricciones operativas y verificaciones exactas. Define contratos y errores conforme al stack aceptado. El catálogo permanece como referencia; no sustituyas decisiones posteriores del proyecto por sus recomendaciones.

Registra estos metadatos adicionales en `.agents/project-profile.conf`:

```ini
# Ejemplo para un proyecto que confirmó Cloudflare Workers:
deployment_target=cloudflare_workers
stack_preset=cloudflare-workers
```

Destinos sugeridos: `vps`, `cloudflare_workers`, `cloudflare_pages`, `gcp_cloud_run`, `custom` o `not_applicable`. Para un perfil propio usa `stack_preset=custom` y describe su composición en el ADR. El manifiesto resume decisiones; ADR 0002 contiene versiones, comandos y configuración acordados. Los nuevos campos son informativos: el gate actual no valida su contenido.

Antes de sellar, verifica que cada componente tenga una necesidad y que el scaffold, contratos, pruebas y CI correspondan al perfil confirmado. Registra qué se validó localmente, qué requiere instalación autorizada y qué se comprobará durante el despliegue.
