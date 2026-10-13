# Spec: Seed 011 — Aprendizaje auditable del molde (formato canónico + sesiones)

> Estado: Cerrada — implementada y verificada, cambios locales sin commit
> Nivel: Tier 1 — Riesgo alto; altera el flujo de cierre (añade ritual) y cómo el molde aprende de sus derivados.
> Requisitos: mantenimiento de semilla; implementa la hoja de ruta V5.1 acordada (documentación y convención, cero código en el gate).
> ADR aplicables: 0001, 0003, 0004, 0005, 0006 (conservados). Sin ADR nuevo de proyecto: el cambio de gobernanza se registra en esta spec + AGENTS (política vigente), conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el proyecto derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

Usa esta plantilla según AGENTS y ADR 0005. Tier 1: detalla invariantes, riesgos y verificación. No modifica ADR 0000–0006. Las seeds son mantenimiento del molde; los derivados no generan seeds.

## 1. Objetivo y alcance

- **Resultado observable:** el molde institucionaliza tres mecanismos ligeros de aprendizaje auditable, todos de documentación y convención, sin código nuevo en el gate: (1) un formato canónico de aprendizaje que los derivados ya validaron; (2) un registro de auditoría del molde (`harness-metrics.md`) que captura fricciones reales; (3) un ritual de cierre de sesión que exporta la conversación agéntica como evidencia versionada.
- **Incluye:** `docs/templates/learning.md` (plantilla canónica); `docs/harness-metrics.md` (nuevo, formato de auditoría del molde); sección "Ritual de cierre de sesión" en `AGENTS.md` y `bootstrap.md`; campo `Sesión` opcional en la plantilla de spec; esta spec.
- **Excluye:** código nuevo en el gate; automatización del export de sesiones (es un comando manual al cierre, no un hook); métricas automáticas o telemetría; cualquier escritura automática del derivado hacia el molde; SQLite o base de datos de fricciones; tocar el gate raíz.
- **Pendientes críticos / supuestos aceptados:** `hermes sessions export --format md` está disponible en el entorno del usuario (verificado); el export se redacta por defecto (verificado: sin secretos en claro); el derivado commitea las sesiones junto a la unidad.

## 2. Contratos e invariantes

- **Entrada (formato canónico):** un aprendizaje observado en un derivado → entrada en `docs/learning.md` del derivado con campos canónicos.
- **Entrada (harness-metrics):** una auditoría del molde sobre un derivado → informe de fricciones con evidencia archivo:línea, guardado en el **molde**, no en el derivado.
- **Entrada (ritual de sesión):** una sesión agéntica con commits → export a `docs/sessions/<fecha>-<titulo>.md` → commiteado.
- **Salida:** trazabilidad cualitativa real (el por qué de las decisiones, los callejones sin salida) sobreviviente al cambio de sesión; el molde aprende de sus derivados sin que estos carguen con procesos extra.
- **Invariantes:**
  - **El repo es la fuente de verdad.** Las sesiones exportadas se commitean junto a la unidad; el aprendizaje vive en el repo, versionado con git.
  - **harness-metrics es opt-in y vive en el molde.** El derivado no carga con ninguna métrica; solo el supervisor (rol del usuario/MIA sobre el molde) escribe auditorías, y solo cuando audita un derivado.
  - **El gate NO cambia.** El ritual de cierre y el formato canónico son convención documentada, no controles del gate. El gate nunca lee sesiones ni métricas.
  - **Fail-safe:** si el export de sesión falla o no está disponible, el cierre de unidad procede igual (es evidencia adicional, no requisito del gate). Igual que Notion: ausencia advierte, no bloquea.
  - **Sin secretos:** el export se redacta por defecto; nunca se guardan tokens/API keys en las sesiones exportadas.
  - **Cero ceremonia automática:** ningún hook nuevo, ningún worker, ninguna sincronización. El ritual es un comando manual al cierre.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: formato canónico de aprendizaje
  Dado un derivado que observa una fricción del molde
  Cuando la registra en docs/learning.md
  Entonces sigue el formato canónico (fecha, unidad, hallazgo, evidencia archivo:línea, aplicación futura, severidad)

Escenario BDD-2: auditoría del molde guardada en el molde
  Dado el supervisor auditando un derivado
  Cuando encuentra fricciones con evidencia
  Entonces las registra en docs/harness-metrics.md del molde, no en el derivado

Escenario BDD-3: ritual de cierre de sesión
  Dado una sesión agéntica con commits sobre un derivado
  Cuando la sesión termina
  Entonces se exporta a docs/sessions/ y se commitea junto a la unidad; el gate no la exige

Escenario BDD-4: ausencia de sesión no bloquea
  Dado un cierre de unidad sin export de sesión
  Cuando corre el gate
  Entonces el gate pasa igual (la sesión es evidencia adicional, no requisito)
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Mantenimiento semilla | BDD-1 | Revisión de plantilla `docs/templates/learning.md` | formato canónico presente y documentado |
| CA-2 | Mantenimiento semilla | BDD-2 | Revisión de `docs/harness-metrics.md` | formato de auditoría del molde, guardado en el molde |
| CA-3 | Mantenimiento semilla | BDD-3 | Revisión de AGENTS/bootstrap | ritual de cierre documentado con comando real |
| CA-4 | Mantenimiento semilla | BDD-4 | Revisión verify.sh | gate no referencia sesiones ni learning (no depende de ellas) |
| CA-5 | Mantenimiento semilla | ADR 0000–0006 intactos; espacio 0007+ libre | Revisión cruzada | política vigente única; 0000–0006 intactos |

## 4. Archivos autorizados

- **Editables:**
  - `docs/templates/learning.md` (crear; formato canónico)
  - `docs/harness-metrics.md` (crear; registro de auditoría del molde, con las 2 fricciones reales ya observadas como primeras entradas)
  - `AGENTS.md` (sección "Ritual de cierre de sesión" + nota de aprendizaje auditable)
  - `.agents/bootstrap.md` (nota al cierre: exportar sesión antes de cerrar; opt-in)
  - `specs/templates/feature.template.md` (campo opcional `Sesión:` para enlazar el export)
  - `README.md` (rol de las sesiones y el aprendizaje: evidencia versionada)
  - `specs/seed-011-aprendizaje-auditable.md` (crear, esta spec)
  - `STATE.md`, `docs/seed-upgrades.md` (nota de alcance)
- **Protegidos:** ADR 0000–0006 (inmutables), el gate raíz (`verify.sh`, `verify-scope.sh`, `verify-structure.sh`) — no se modifica su lógica; `.githooks/pre-commit` (sin nuevo hook de red).
- Ampliación de rutas antes de editar: si hace falta tocar el gate, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es mantenimiento de semilla sin código de producto: su ciclo rojo/verde ocurre a nivel de contrato; no aplica TDD de producto.
- **Comandos y suites de cierre:** `./scripts/verify.sh` (exit 0; sin cambios de comportamiento esperado), `bash scripts/tests/verify-contract.sh` (90/90 previos siguen pasando), `git diff --check` (exit 0).
- **Chequeo rápido de iteración:** `./scripts/verify.sh` (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-5; verificar que el gate raíz NO adquiere dependencia de sesiones/aprendizaje y que el ritual es opt-in sin hook nuevo. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; contrato previo (90 casos) sigue pasando.

## 6. Cierre y continuidad

### Evidencia — 2026-10-12

- **Contrato:** `bash scripts/tests/verify-contract.sh` → **90 passed, 0 failed** (sin cambios de comportamiento; Seed 011 es documentación y convención, no toca el gate). `git diff --check` salida 0.
- **Gate raíz:** `./scripts/verify.sh`, salida 0. Contrato 90/0, piloto completo. ADR 0000–0006 intactos byte a byte; sin ADR de proyecto nuevo (espacio 0007+ libre).
- **CA-4 verificado:** `scripts/verify.sh` (gate raíz) no referencia sesiones ni aprendizaje. Las dos coincidencias de `docs/learning.md` en `verify-scope.sh` (línea 78, ruta autorizada) y `verify-structure.sh` (línea 44, documento no vacío) son controles estructurales previos — el gate sabe que el archivo existe, nunca lee su contenido ni sesiones. No se añadió dependencia.
- **Piezas entregadas:** `docs/templates/learning.md` (formato canónico con 2 ejemplos reales del derivado GYM-2026); `docs/harness-metrics.md` (auditoría del molde con F-01 contradicción gate↔HITO0_PENDING y F-02 revisiones humanas, ambas con evidencia archivo:línea); ritual de cierre de sesión documentado en AGENTS/bootstrap/README; campo opcional `Sesión:` en la plantilla de spec.
- **Hallazgo de plataforma (verificado):** `hermes sessions export --format md` produce Markdown con frontmatter y conversación completa, con redacción por defecto (probe real: sin secretos en claro). Export de prueba eliminado tras verificar.

### Aprendizaje

Distinguir "el gate referencia un archivo" de "el gate depende de su contenido": `verify-structure.sh` y `verify-scope.sh` ya mencionaban `docs/learning.md` como control estructural (existe / es editable), lo que un grep laxo confunde con dependencia semántica. La prueba correcta de CA-4 fue sobre `verify.sh` y sobre el *contenido*, no sobre la mención del nombre. Aplicación futura: al verificar "el gate no depende de X", buscad dependencia de contenido, no la cadena del nombre.

### Commit

Pendiente de política de commits confirmada por el usuario para esta unidad.
