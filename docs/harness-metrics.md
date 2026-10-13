# Harness Metrics — Auditorías del molde Hito-0

> Registro de auditorías del supervisor (rol del usuario/MIA sobre el molde). Vive en el **molde**, no en los derivados: el derivado no carga con ninguna métrica. El supervisor escribe aquí cuando audita un derivado, con fricciones y señales de que el flujo funciona, cada una con evidencia archivo:línea.
>
> Convención: una auditoría por derivado/fecha. Las fricciones marcadas "candidata a seed" alimentan la hoja de ruta V5.x. El gate NUNCA lee este archivo; es aprendizaje del supervisor, no control.

## [AAAA-MM-DD] — Auditoría: [nombre del derivado] ([fase, HEAD])

### Fricciones observadas

#### [F-01] [título corto de la fricción]

- **Qué pasa:** [descripción del problema en el flujo gobernado]
- **Evidencia:** [archivo:línea + cita textual breve]
- **Severidad:** baja | media | alta
- **Candidata a seed:** sí | no — [si sí, referencia la seed futura]

### Señales de que el flujo funciona

- [qué partes del flujo aportan valor real, con evidencia]

### Recomendación

- [qué fricciones justifican tocar el molde y cuáles son ruido]

---

## 2026-10-11 — Auditoría: GYM-2026 (phase=project, HEAD 81203c0)

### Fricciones observadas

#### [F-01] Contradicción gate↔política de HITO0_PENDING

- **Qué pasa:** el gate `verify-structure.sh` prohíbe la cadena `HITO0_PENDING` en PRD/PROMPT-MAESTRO/ADR-0002, pero la política del bootstrap manda usarla para campos críticos sin resolver. El derivado tuvo que redactar esos archivos sin el marcador y concentrar los pendientes en STATE.md y specs.
- **Evidencia:** `scripts/verify-structure.sh` líneas 48-52; `docs/learning.md` del derivado (entrada 2026-10-11); STATE.md del derivado (pendientes en STATE, no en archivos gateados).
- **Severidad:** media — workaround en cada derivado con pendientes reales.
- **Candidata a seed:** sí — alinear el gate con la política de HITO0_PENDING (permitir el marcador en archivos aprobados durante initializing/project).
- **Estado: CERRADA (Seed 012, V5.2, 2026-10-12).** El gate ahora cuenta los `HITO0_PENDING` y advierte por fase (initializing advierte; project advierte + exige registro en STATE o falla; seed no corre); los demás placeholders siguen bloqueando. El workaround ya no es necesario. Evidencia del cierre: contrato 94/94, gate raíz exit 0 (spec conservada en el Constructor-Padre).

#### [F-02] Unidades "pendiente de revisión humana" sin mecanismo de cierre explícito

- **Qué pasa:** varias unidades quedan implementadas y verificadas pero "pendiente de revisión humana del usuario antes de cerrar/sellar". No hay un paso mecánico ni un recordatorio en el gate que fuerce o facilite esa revisión; queda a disciplina del agente y del humano.
- **Evidencia:** STATE.md del derivado — unidad 001 ("Revisión Tier 1: pendiente de revisión humana del usuario antes de sellar") y unidad 002 ("pendiente de revisión humana del usuario antes de cerrar").
- **Severidad:** baja — el flujo lo cubre por política, pero podría formalizarse.
- **Candidata a seed:** no por ahora — observar si se acumulan unidades sin revisar.

### Señales de que el flujo funciona

- Modo A de Notion (V5) trasladó 55 decisiones y redujo la entrevista a validación. Evidencia: STATE.md del derivado, `docs/learning.md`.
- Gate del derivado verde tras dos unidades Tier 1 reales con evidencia por criterio CA. Evidencia: `./scripts/verify.sh` salida 0, tests del monorepo en verde.

### Recomendación

- F-01 **cerrada** (Seed 012, V5.2): el gate alineado con la política de HITO0_PENDING — cuenta y advierte por fase, no bloquea; los demás placeholders siguen bloqueando. F-02 es observación, no acción todavía.

---

## 2026-10-12 — Auditoría: GYM-2026 (phase=project, HEAD 6df3928) — flujo detenido en la UI

### Fricciones observadas

#### [F-03] Sin protocolo de preparación de capa: el flujo se detuvo al pasar al frontend

- **Qué pasa:** el derivado llegó al borde de la UI sin saber cómo arrancarla. La spec 003 (pagos) excluyó explícitamente la UI para «la pasada de diseño», pero esa pasada nunca se planificó como unidad ni tiene un protocolo que la ordene. El agente quedó sin guía: backend o frontend, y ninguna. Elegir el system design tarde implica reescribir el frontend.
- **Evidencia:** `specs/003-planes-pagos-caja.md` L23 («UI (se hace después, en la pasada de diseño)»); el ciclo de AGENTS §8 dice «siguiente unidad» sin decir cómo prepararla; ADR-0002 del derivado YA blindó separación UI/lógica (L28/L43/L50) pero no hay unidad de system design de frontend en la secuencia.
- **Severidad:** media/alta — detuvo el proyecto real y puede costar una reescritura del frontend.
- **Candidata a seed:** sí — protocolo de preparación de capa (ADR de system design antes de tocar UI).
- **Estado: CERRADA (Seed 013, V5.3, 2026-10-12).** AGENTS y PROMPT-MAESTRO ganan la sección «Preparación de la siguiente unidad / capa»: si la unidad toca una capa nueva sin ADR de system design, el agente lo escribe, lo valida con el humano (propone/valida) y recién implementa; la lógica de negocio y autorización quedan SOLO en backend; el ADR es reutilizable entre módulos. Plantilla `docs/templates/adr-frontend.md` + campo `Decisión de diseño previa:` en la spec. Evidencia del cierre: contrato 94/94, gate raíz exit 0 (spec conservada en el Constructor-Padre).

### Señales de que el flujo funciona

- El ADR-0002 del derivado blindó por sí solo la separación UI/lógica y «autorización siempre en el servidor» (L28/L43/L50) — el patrón de ADR base funciona sin que el molde lo fuerce.
- La spec 003 es Tier 1 honesta: introduce dinero, separa registro/validación, declara concurrencia e idempotencia, y excluye lo que no toca (UI, sauna, reservas). El traslado Modo A produjo specs de calidad real.
- Gate del derivado en verde a través de 5 commits de producto (auth, UI, seed-dev, fixes) con evidencia end-to-end real contra Postgres.

### Recomendación

- F-03 **cerrada** (Seed 013, V5.3): protocolo de preparación de capa documentado; el gate no cambia. F-02 sigue como observación. Nota de supervisión: GYM-2026 permanece en V5.0 por diseño — no se le empujan los fixes del molde; las fricciones se aprenden sobre su base congelada.

#### [F-04] Contradicción Tier 3 ↔ gate: el gate bloquea lo que la política autoriza

- **Qué pasa:** la política (AGENTS §2, registro ligero Tier 3) autoriza unidades `LIG-*` en STATE sin spec, pero `verify-scope.sh` violaba cualquier unidad activa sin spec cuando había cambios en vuelo. Un agente que seguía la política no podía commitear. El contrato no cubría `LIG-*`, así que el bug pasó desapercibido.
- **Evidencia:** `scripts/verify-scope.sh` líneas 50-55 (antes del fix) — violación incondicional por falta de spec; la auditoría del flujo lo detectó y el contrato rojo lo confirmó (BDD-1 RED pre-fix).
- **Severidad:** alta — el gate contradice la política que debe hacer cumplir; cualquier unidad ligera real quedaba bloqueada.
- **Candidata a seed:** sí — reconocer `LIG-*` y verificar el alcance contra las rutas del bloque de STATE (fail-safe).
- **Estado: CERRADA (Seed 014, V5.4, 2026-10-12).** `verify-scope.sh` reconoce `LIG-*`: lee sus rutas de `Alcance/autoridad:` en STATE (partiendo por `,` y `;`, descartando autor/fecha) y verifica contra ellas; ruta fuera de la lista sigue siendo SCOPE VIOLATION; una unidad de negocio sin spec ni bloque LIG sigue siendo violación; bloque no parseable → fail-safe (advierte, no bloquea). Contrato 94→97 (BDD-1/2/3). Evidencia del cierre: contrato 97/97, gate raíz exit 0, ADR 0000–0006 intactos (spec conservada en el Constructor-Padre).

#### [F-05] Decisiones transversales no ordenadas antes de tocar un dominio

- **Qué pasa:** el protocolo de capa (Seed 013) cubre *cómo* se ve una capa, pero tres decisiones que atraviesan todos los módulos de un dominio —modelo de errores, contexto tenant/auth, estrategia de tests— quedaban a criterio de cada módulo. GYM-2026 ya pagó la improvisación: colisiones de TRUNCATE en tests de integración que obligaron a improvisar aislamiento.
- **Evidencia:** `docs/learning.md` del derivado (colisiones de TRUNCATE); ADR-0002 del derivado blindó separación UI/lógica y authz en backend pero no declaró modelo de errores ni estrategia de tests.
- **Severidad:** media/alta — improvisar por módulo obliga a reescribir.
- **Candidata a seed:** sí — declarar las tres transversales obligatorias en el ADR base antes de tocar un dominio.
- **Estado: CERRADA (Seed 014, V5.4, 2026-10-12).** AGENTS §7 gana «Decisiones transversales obligatorias antes de tocar un dominio» (una vez por dominio, validadas por el humano, reutilizadas por los módulos siguientes, sin ceremonia si ya están) y PROMPT-MAESTRO lo referencia. El gate no cambia ni lee ADRs de dominio. Evidencia del cierre: AGENTS.md, `.agents/master-prompt.template.md` (spec conservada en el Constructor-Padre).
