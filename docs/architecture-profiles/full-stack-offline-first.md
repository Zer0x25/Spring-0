# Perfil opcional: full stack offline-first con PostgreSQL

- **Estado:** Propuesto; pendiente de validar mediante implementación y pruebas. No es un ADR aceptado ni una certificación de producción.
- **Revisión:** 2026-10-07.
- **ID:** `offline-first-postgres`; complementa un perfil de despliegue, no lo reemplaza.
- **Origen:** síntesis corregida de `Especificacion_Tecnica_Full-Stack_Offline-First_v2.0.md`, recibido del usuario. El original se conserva fuera del repo sin cambios; SHA-256 `98577a69639c881ae95cd703efca423f9ddfc58a1e69b5e79d37616e0a3b0bfd`.

## 1. Cuándo elegirlo

Para una aplicación de navegador que debe capturar cambios durante periodos sin red, conservar trabajo pendiente y sincronizar varios dispositivos. El PRD debe confirmar operaciones offline permitidas, duración máxima sin conexión, datos disponibles, conflictos y tolerancia a pérdida local.

Si basta consultar contenido offline, evaluar una caché de lectura. Para una app siempre conectada, omitir la cola y el protocolo. No activar este perfil por el solo hecho de elegir React o una PWA. Asistencia, empleados y marcajes son ejemplos de dominio del documento original; no son requisitos de otras aplicaciones.

La entrevista sigue ofreciendo SQLite y PostgreSQL. Este perfil propone PostgreSQL central por su contrato de concurrencia; si se elige otra base, crear y validar una variante explícita, no copiar SQL ni prometer equivalencia. Dexie/IndexedDB es almacenamiento adicional del navegador. El proyecto acepta arquitectura y variantes en sus ADR, con specs vinculadas al PRD.

## 2. Componentes y responsabilidades

| Capa | Referencia | Responsabilidad |
|---|---|---|
| Interfaz | React + TypeScript + Vite | Flujos y estado visible de sincronización |
| Persistencia local | Dexie / IndexedDB | Estado confirmado, intenciones pendientes y vista materializada |
| Assets PWA | vite-plugin-pwa / Workbox | Assets versionados y actualización compatible |
| Sincronización | Motor propio, HTTP push/pull | Cola, dependencias, cursores, reintentos y recuperación |
| Backend | Node LTS + Fastify + Zod | Autenticación, autorización y contratos tipados |
| Datos centrales | PostgreSQL + Drizzle/driver compatible | Dominio, cambios y recibos idempotentes transaccionales |
| Señales | SSE, opcional | Despertar pull; nunca sustituir la recuperación del estado |

TanStack Query es opcional para operaciones remotas; no duplicar el estado de dominio de Dexie ni persistir una segunda cola con reglas distintas. Router, formularios y UI se eligen por necesidades. UUID generados en cliente identifican entidades/mutaciones, no ordenan commits ni prueban identidad. Verificar versiones estables, compatibilidad y soporte en fuentes oficiales durante la entrevista.

Una app modular es suficiente como punto de partida. Monorepo y paquetes compartidos no son obligatorios; si hay contratos compartidos, no importar código de servidor al navegador. Elegir estructura en ADR según alcance.

## 3. Invariantes y autoridad

1. La escritura visible sincronizable y su intención pendiente se guardan en una única transacción Dexie.
2. PostgreSQL es autoridad durable; UI muestra una proyección del estado confirmado más intenciones locales, diferenciando «pendiente» de «confirmado».
3. Reintentos de una misma solicitud congelada no duplican efectos; clave, identidad, ámbito y payload permanecen asociados.
4. Ningún cambio puede hacerse visible por debajo de un cursor que ya se entregó para ese ámbito/generación.
5. Página y cursor se aplican en la misma transacción local; un fallo no avanza ninguno.
6. Borrados se propagan mediante tombstones; correcciones auditables preservan hechos originales cuando el dominio lo requiera.
7. Autorización del servidor se comprueba en bootstrap, push, pull y señales. Una edición local no concede permiso remoto.
8. Reiniciar o actualizar no borra pendientes sin confirmación remota o preservación independiente recuperable.

## 4. Publicación transaccional y cursor seguro

`BIGINT IDENTITY`, `nextval`, reloj o `updated_at` no garantizan orden de confirmación. A puede reservar 100 y B 101, confirmar B primero y provocar que el cliente salte A. Los huecos y asignaciones de secuencias no son una prueba de publicación.

Como diseño inicial acotado, serializar las escrituras sincronizables por ámbito usando una fila transaccional de cabecera. Es una propuesta de diseño que debe probarse; no una garantía de rendimiento.

Esquema conceptual mínimo:

```text
sync_heads(scope_id PK, last_seq BIGINT)
sync_changes(scope_id, sync_seq BIGINT, mutation_id, operation,
             entity_type, entity_id, entity_version, payload JSONB,
             PK(scope_id, sync_seq))
processed_mutations(scope_id, actor_id, idempotency_key, request_hash,
                    response JSONB, PK(scope_id, actor_id, idempotency_key))
```

Para cada mutación de un único ámbito, en una transacción del servidor:

1. Validar identidad, pertenencia, protocolo y contrato; derivar ámbito del servidor.
2. Reservar la clave idempotente con unicidad transaccional, según sección 5.
3. Tomar `SELECT ... FOR UPDATE` sobre la cabecera **antes de bloquear/modificar entidades**. Mantenerla hasta commit o rollback.
4. Validar versión/invariantes y aplicar dominio. Incrementar `last_seq` con un `UPDATE` transaccional y asignar números a los cambios generados.
5. Insertar cambios con payload inmutable de esa versión, auditoría pertinente y resultado idempotente en la misma transacción. Confirmar; después puede emitirse SSE.

Todos los escritores (también jobs, importaciones y endpoints de dominio) siguen este orden. Preparar cabeceras con unicidad y tratar carreras de creación. No hacer llamadas de red dentro de estos locks. Si una operación abarca varios ámbitos, requiere diseño adicional con orden de locks e invariantes definido en ADR; no está cubierta por la referencia de un único ámbito.

B no puede publicar el siguiente número mientras A retiene la cabecera. Si A aborta, contador y filas retroceden juntos. Los lectores solo ven datos confirmados. Esto serializa escrituras por ámbito y puede limitar throughput; medirlo antes de aceptar. No sustituirlo por un contador en memoria, Redis, IDENTITY o un lock liberado antes del commit. Una alternativa de mayor escala necesita otra publicación ordenada y pruebas propias.

El cursor viaja como `{scopeId, generation, seq}` con `seq` decimal en string, ligado a identidad y conjunto autorizado. La generación cambia ante recreación/restauración que invalide el historial; un cursor de otra generación requiere resync. No comparar secuencias de ámbitos diferentes.

### Bootstrap, páginas y retención

- Obtener snapshot, generación y cabecera confirmada H dentro de una misma vista consistente, por ejemplo una transacción `REPEATABLE READ` sin escrituras. No usar `max(identity)` independiente.
- Si se pagina el snapshot, mantener una exportación/snapshot estable identificado, con expiración y límites; no abrir una vista nueva por página. Publicar snapshot y cursor solo al completar el bootstrap local, preservando intenciones.
- Pull entrega cambios inmutables `cursor < seq <= H`, ordenados, con H fijo durante la descarga. `nextCursor` corresponde a cambios realmente entregados/aplicados; nunca al último número reservado.
- No dividir por paginación un grupo de cambios que el dominio necesita aplicar atómicamente. Registrar agrupación por mutación, presupuesto máximo y rechazo/flujo alternativo si un grupo excede el límite.
- Aplicar estado confirmado, recalcular la vista local y guardar cursor en una sola transacción Dexie. Releer filas actuales del servidor no sustituye los payloads históricos del feed.
- Retención y leases de descarga impiden purgar páginas todavía servidas. Ante expiración o cursor anterior al mínimo retenido, devolver `RESYNC_REQUIRED`; no continuar silenciosamente.

## 5. Idempotencia y operaciones pendientes

Una búsqueda seguida de escritura no basta para resolver dos reintentos simultáneos. Reservar una clave única dentro de la misma transacción que aplica dominio y guarda respuesta. Un competidor espera el resultado o reintenta después de rollback; si el recibo está confirmado, recibe ese resultado sin ejecutar otra vez el efecto.

El hash incluye el contrato canónico de la solicitud (acción, entidad, versión base, payload, protocolo y contexto). Misma clave con payload distinto se rechaza. Autorizar al actor actual antes de devolver un recibo; la clave no es un token de acceso. Usar restricciones adicionales de negocio para hechos que no pueden duplicarse.

Definir resultados terminales `APPLIED`, `ALREADY_APPLIED`, `CONFLICT`, `REJECTED`; los transitorios `RETRYABLE_ERROR` no se convierten en aceptación definitiva. Un resultado terminal conserva payload/versión canónica o un mecanismo inequívoco para obtenerlos. Efectos externos requieren outbox y deduplicación del receptor si se incorporan; no quedan cubiertos por la transacción SQL.

Retención de recibos debe cubrir máximo offline y reintento autorizado. Si una solicitud tiene antigüedad/generación fuera de ventana, no ejecutarla como nueva tras perder el recibo: detener y reconciliar o aplicar una deduplicación durable de negocio definida. No confiar solo en el reloj cliente para imponer la ventana.

### Estado confirmado e intenciones locales

- Conservar estado confirmado separado de intenciones pendientes; la UI materializa ambos. Un pull actualiza la base confirmada y vuelve a aplicar intenciones, no pisa el trabajo local.
- Una mutación transmitida congela clave y payload. Un ACK se registra atómicamente con estado confirmado y transición de cola; solo elimina lo confirmado, no ediciones creadas después.
- Para una misma entidad, ordenar dependencias y permitir una operación en vuelo. Una intención aún no enviada puede preparar su versión base desde el ACK previo antes de congelar la solicitud; una ya enviada no cambia durante un reintento.
- Conflicto/rechazo detiene dependientes, preserva intenciones y ofrece resolución de negocio explícita; no usa timestamps como ganador universal. Crear otra solicitud tras resolución no debe duplicar una anterior de resultado desconocido.
- Persistir estado en vuelo y recuperarlo tras crash con la misma clave. Serializar el motor entre pestañas y workers, mediante Web Locks cuando esté disponible o una alternativa transaccional validada; un booleano en una pestaña no basta.

## 6. Seguridad, permisos y offline

Definir un ámbito de sincronización estable y autorizado. Si los permisos por entidad producen subconjuntos, diseñar feed/proyección por destinatario o equivalentes y el tratamiento de cambios de membresía. No exponer payloads globales ni asumir que filtrar el mismo cursor soluciona nuevas concesiones de acceso.

Cambios de permisos pueden invalidar ámbito/generación de proyección y forzar bootstrap. Revocación significa detener push/pull no autorizados y limitar lo visible localmente según política acordada. La revocación remota inmediata no puede garantizarse mientras un dispositivo está desconectado; si se exige, restringir duración o acciones offline. Definir expiración de acceso local, cifrado/gestión de claves si aplica y datos mínimos necesarios.

Separar bases/colas por cuenta y contexto; no enviar pendientes de A después de iniciar sesión como B. Logout, retirada de dispositivo y borrado remoto tienen una política explícita para preservar o eliminar trabajo sin permitir acceso de otra cuenta. Revalidar permisos al reconectar, también para recibos y SSE.

On-premise/LAN necesita HTTPS con certificados confiables para los dispositivos. HTTP sobre una IP LAN no equivale a la excepción de desarrollo de localhost. Definir cookies/CORS/CSRF conforme a la topología, límites de lote y validación de contratos tipados, no aceptar `Record<string, unknown>` como único contrato de negocio.

## 7. Recuperación, compatibilidad y operación

Solicitar persistencia del navegador no elimina riesgo de cuota, expulsión o pérdida. Una tabla `recoveryStore` dentro de la misma base sirve para preparar recuperación, **no** como respaldo que sobreviva a eliminarla.

Antes de recrear IndexedDB:

1. Detener nuevas escrituras y aislar el motor.
2. Exportar pendientes con cuenta/ámbito/generación, claves congeladas, versión local/protocolo y checksum; proteger datos según clasificación. Checksum detecta corrupción, no autoriza importar.
3. Obtener confirmación remota inequívoca o verificar preservación independiente (archivo exportado recuperable o almacenamiento externo validado). Si falla, no borrar la base.
4. Reconstruir una nueva base/snapshot y reconciliar pendientes conservando claves y verificando recibos. No reinyectar ciegamente bajo otra cuenta, generación o versión.

Ante pérdida total previa, no prometer recuperación de datos que solo existían localmente. Si el PRD exige protección mayor, evaluar almacenamiento/dispositivo controlado y backups, sin prometer cero pérdida por usar un contenedor nativo.

`RESYNC_REQUIRED` conserva intenciones y recibos locales antes del bootstrap, recalcula vista y presenta conflictos. No sustituye una estrategia de idempotencia expirada. La API negocia protocolo/esquema y bloquea clientes incompatibles sin borrar pendientes. Probar migraciones desde versiones soportadas; una actualización del service worker no fuerza recarga destructiva.

Backoff con jitter para fallos transitorios; errores de permiso, validación o conflicto requieren acción específica. Pull usa límite H y presupuesto por ciclo para terminar con backlog continuo. Al liberar el lock reprograma trabajo pendiente; los disparadores (online, foreground, temporizador, nueva intención, SSE) convergen en un único motor. Background Sync y SSE son ayudas opcionales.

Registrar backlog/edad, conflictos, cursor, versión, reintentos y correlación sin secretos. Definir backups remotos probados, RPO/RTO, migraciones/reversión y responsable operativo. Separar tests locales del runtime y validación remota de certificados, infraestructura y recuperación.

## 8. Validación requerida antes de aceptar en una app

Convertir invariantes en criterios SDD/BDD y pruebas; mantener una spec activa y la DoD del proyecto. No generar todas las capas por copiar este perfil.

| Caso | Resultado exigido |
|---|---|
| A obtiene lock/cursor y tarda; B intenta publicar | B espera; ningún cambio aparece tarde por debajo del cursor entregado |
| Rollback después de asignar número y escribir dominio | Cabecera, dominio, feed y recibo retroceden juntos |
| Dos requests simultáneos con la misma clave / payload distinto | Un efecto y mismo recibo / rechazo por reutilización |
| Corte después de commit y antes del ACK | Reintento recupera resultado; no duplica el hecho |
| Dos ediciones locales y ACK/pull intercalados | Intención posterior se conserva; versiones y dependencias correctas |
| Crash durante aplicación local de página | Datos y cursor se recuperan juntos o no cambian |
| Snapshot paginado con escrituras concurrentes y grupos multirow | Vista/cursor coherentes; grupos no se aplican parcialmente |
| Cliente fuera de retención, nueva generación o protocolo incompatible | Resync/resolución explícita, sin borrar pendientes ni reaplicar a ciegas |
| Cuota llena, pestaña concurrente, migración/actualización interrumpida | Error visible, sin pérdida silenciosa ni dos motores activos |
| Fallo de exportación antes de borrar IndexedDB | Se conserva base; no se declara recuperación segura |
| Permisos revocados / cambio de cuenta | Sin fuga ni envío de cola ajena; política offline comprobada |
| SSE perdido, relojes ±24 h, backend reiniciado | Pull eventual correcto; reloj cliente no ordena el feed |
| Restauración de backup y LAN en dispositivos reales | Nueva generación cuando corresponda, datos restaurables y HTTPS válido |

## 9. Fuentes y límites de la referencia

Consultadas el 2026-10-07: [aislamiento PostgreSQL](https://www.postgresql.org/docs/current/transaction-iso.html), [bloqueos PostgreSQL](https://www.postgresql.org/docs/current/explicit-locking.html), [service workers y HTTPS](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers), [Web Locks](https://developer.mozilla.org/en-US/docs/Web/API/Web_Locks_API).

Las fuentes describen primitivas; no certifican este diseño completo. La serialización por cabecera, reconciliación de cola y políticas propuestas requieren implementación, pruebas de concurrencia y medición. Si el perfil se acepta en un proyecto, sus ADR fijan ámbito, contratos, alternativas, versiones, límites y evidencias.
