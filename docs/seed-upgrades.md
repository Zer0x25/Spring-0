# Adoptar una actualización de Hito 0

La versión base se identifica por el commit de semilla registrado en STATE del derivado. La actualización se hace por unidad autorizada; no copiar AGENTS, PRD ni el prompt por encima de personalizaciones.

1. Registrar base instalada, revisión destino, Git limpio o cambios preexistentes y copia/worktree de evaluación. Si se desconoce la base, comparar archivos y declarar esa incertidumbre.
2. Comparar base/destino. Separar scripts comunes de decisiones de producto, permisos y comandos propios. Confirmar adopción, cambios de contrato y rutas; usar Tier 1 para cambios de controles. No ampliar delegaciones antiguas.
3. Incorporar nuevos ADR de semilla preservando los históricos. Si el número ya está ocupado por un ADR del producto, asignar otro libre y adaptar referencias, lista de integridad y fixtures en la misma unidad; no sobrescribirlo. Mantener una referencia entre el ADR original de semilla y el número local.
4. Integrar manualmente reglas vigentes en AGENTS y bootstrap, conservando PRD, arquitectura, DoD, permisos y comandos reales. La política conjunta de commits solo se activa con confirmación expresa; una autorización anterior limitada a specs sigue limitada.
5. Actualizar scripts comunes y CI conjuntamente. Conservar verify-project.sh y su cobertura; preparar runtime en CI antes del gate. Ejecutar ./scripts/verify.sh en la copia, comprobar una prueba de producto que falle y recuperar el verde. Nunca sustituir suites reales por stubs para migrar.
6. Revisar diff y aceptación; registrar evidencia y versión adoptada en STATE, con commit según permiso. Si falla, conservar checkpoint y revertir solo cambios de la migración o descartar la copia; no borrar trabajo del proyecto.

## Cambios de Seed 008

- Gate único: integridad, sintaxis, contrato y verificador de producto. El piloto temporal corre en semilla. `verify-structure.sh` es interno; no sustituye el cierre.
- Se requieren documentos no vacíos, incluidos AGENTS, STATE, ADR 0005/0006 y las referencias de capacidades/migración. No se valida automáticamente la verdad de la aceptación.
- En documentos aceptados PRD/prompt/ADR base se rechazan campos conocidos sin completar y el marcador `HITO0_PENDING`. Usar ese marcador en cualquier campo crítico que falte durante preparación; retirarlo solo al resolverlo. La plantilla reutilizable de specs puede conservar placeholders.
- `phase=initializing` identifica inicialización sin sellar. Para un proyecto ya terminado conservar `phase=project`. Para inicialización incompleta recuperar bootstrap desde la versión adoptada (o `.done`), conservar decisiones y fijar `initializing` hasta validar y sellar.
- La semilla requiere GitHub Actions; un derivado puede usar otra CI manteniendo el mismo gate y su preparación de runtime.

## Cambios de Seed 011

- Aprendizaje auditable: `docs/templates/learning.md` (formato canónico), `docs/harness-metrics.md` (auditorías del molde, vive en el molde) y ritual de cierre de sesión (`hermes sessions export --format md --cwd <repo>` → `docs/sessions/` → commit). Todo convención documentada; el gate no cambia y nunca lee sesiones ni aprendizaje. El ritual es opt-in y sin hook: la ausencia de export no bloquea el cierre.

## Cambios de Seed 012

- `HITO0_PENDING` deja de ser placeholder crítico bloqueante en PRD/PROMPT-MAESTRO/ADR-0002: el gate lo cuenta y advierte por fase (initializing advierte; project advierte + exige que los pendientes queden registrados en STATE, o falla; seed no corre). Los demás placeholders `[...]` siguen bloqueando. Cierra la fricción F-01; elimina el workaround de redactar los archivos sellados sin el marcador.

## Cambios de Seed 013

- Protocolo de preparación de capa: antes de implementar una unidad que toca una capa nueva (UI/frontend, offline, dominio con superficie de usuario) sin decisión de diseño previa, el agente escribe un ADR técnico de system design, lo valida con el humano (propone/valida) y recién implementa. La lógica de negocio y autorización quedan SOLO en backend; el ADR es reutilizable entre módulos. Guía en `docs/templates/adr-frontend.md`; campo `Decisión de diseño previa:` en la spec. Cierra la fricción F-03; el gate no cambia.

## Cambios de Seed 014 (V5.4) — Robustez de base

- **Fix Tier 3 ↔ gate:** `verify-scope.sh` reconoce unidades ligeras `LIG-*` (Tier 3, autorizadas por política a vivir en STATE sin spec). Lee sus rutas de `Alcance/autoridad:` en STATE (partiendo por `,` y `;`, descartando autor/fecha) y verifica el alcance contra ellas; una ruta fuera de la lista sigue siendo SCOPE VIOLATION; una unidad de negocio sin spec ni bloque LIG sigue siendo violación (no se abre la puerta a commits sin alcance); bloque de STATE no parseable → fail-safe (advierte, no bloquea). Cierra la fricción F-04. Contrato 94→97 (BDD-1/2/3).
- **Decisiones transversales obligatorias:** antes de tocar código de un dominio, el ADR base declara modelo de errores, contexto tenant/auth en backend y estrategia de tests. Se cierran una vez por dominio, se validan con el humano y los módulos siguientes las reutilizan (sin ceremonia si ya están). Documentado en AGENTS §7 + PROMPT-MAESTRO; el gate no cambia ni lee ADRs de dominio. Cierra la fricción F-05.

## Cambios de Seed 015 (V5.5) — Higiene del molde

- Extracción de capacidades: los bloques acumulados de AGENTS (Seeds 009/010/011/013/014) se trasladan íntegros a `docs/flujo-capacidades.md`; AGENTS queda como protocolo estable con punteros. El archivo de capacidades es referenciado por enlace, NO agregado a los requeridos del gate (no endurecer el gate por un doc referenciado).
- Neutralidad de harness: el ritual de cierre de sesión deja de nombrar `hermes sessions export` como obligación en los documentos vivos (AGENTS/README/bootstrap); la convención es genérica y el comando concreto queda como ejemplo en el archivo de capacidades. El registro histórico de Seed 011 (que documenta que el export fue verificado) se preserva intacto: es evidencia, no política viva.
- Sin cambios de comportamiento: `scripts/` intacto byte a byte; contrato 97/97; gate exit 0.

## Cambios de Seed 016 (V5.6) — Índice canónico de ADR + limpieza de base

- `docs/adr/README.md` pasa a ser la fuente única de precedencia (anfitrión/usuario → AGENTS → ADR histórico), numeración (0000–0006 molde / 0002 y 0007+ derivado / seeds no consumen números) y tabla de qué decide y qué reemplaza cada ADR. Lista las convenciones vivas (Notion, trazabilidad, sesión, capa, transversales, LIG-*) como NO-ADR — nombradas, no absorbidas.
- ADR 0000 corrige dos contradicciones puntuales contra la política viva: la prevalencia absoluta (ahora apunta a ADR 0006) y la regla `DomainError`/`errors.ts` como universal (ahora ejemplo de perfil TypeScript, ADR 0001). Nota de cabecera que remite al índice.
- ADR 0003/0004/0005 dejan de citar «siguiente número libre» (frases muertas) y apuntan al índice. ADR 0001 y 0006 intactos (patrón de política correcta).
- Docs-only: `scripts/` intacto byte a byte; contrato 97/97; gate exit 0.

## Tamaño de STATE

Mantener meta, unidad activa, bloqueos, siguiente paso y cierres recientes. Al superar diez cierres, mover los más antiguos íntegros a `docs/history/` con enlace desde STATE. No archivar trabajo activo, autorizaciones aún necesarias ni contadores pendientes. IDs y evidencia siguen siendo consultables; Git no reemplaza el enlace al historial.
