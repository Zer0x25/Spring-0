# Spec: Seed 015 — Higiene del molde (extraer capacidades de AGENTS + desacoplar el ritual de Hermes)

> Estado: Borrador — pendiente de aprobación del usuario
> Nivel: Tier 1 — toca archivos de política viva (AGENTS, README, bootstrap); no cambia comportamiento del gate, pero altera dónde vive la política. Se documenta por rigor de la propia gobernanza del molde.
> Requisitos: mantenimiento de semilla; higiene detectada en la auditoría del flujo (2026-10-12) y respaldada por el análisis de AGENTS.md (25.2K, 5 bloques de capacidades acumuladas).
> ADR aplicables: 0000–0006 (conservados). Sin ADR nuevo de proyecto: la higiene se registra en esta spec + docs vivos, conforme al mecanismo de ADR 0006. Espacio 0007+ libre para el derivado.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

## 1. Objetivo y alcance

- **Resultado observable:** dos higienas sin cambio de comportamiento. (1) AGENTS.md deja de acumular bloques de capacidades inline (Seeds 009/010/011/013/014); esos bloques se trasladan a `docs/flujo-capacidades.md` y AGENTS queda como protocolo estable con punteros cortos. (2) El ritual de cierre de sesión deja de nombrar `hermes sessions export` literalmente en los documentos vivos; se convierte en convención genérica («exportá la conversación del harness») y el comando concreto queda como ejemplo dentro del archivo de capacidades.
- **Incluye:** crear `docs/flujo-capacidades.md`; acortar AGENTS.md (§7 + §8 con punteros); README.md (bloque Seed 011 genérico); `.agents/bootstrap.md` (ritual de cierre genérico); nota en `docs/seed-upgrades.md`; esta spec.
- **Excluye:** cualquier cambio en `scripts/` (gate intacto byte a byte); tocar specs históricas (seed-011 incluida — su registro de que `hermes sessions export` fue verificado es evidencia histórica, no política viva); tocar `docs/harness-metrics.md` o `docs/agent-capabilities.md`; añadir `flujo-capacidades.md` a los requeridos del gate (un doc referenciado por enlace no debe endurecer el gate — eso sería sobreingeniería).
- **Pendientes críticos / supuestos aceptados:** el gate lee AGENTS/README/bootstrap de forma estructural (existencia + no vacío), no semántica; el piloto `sed`-borra el rango `## Estado inicial: semilla Hito 0` → `## Reglas de gobernanza`, por lo que ambos encabezados deben conservarse literalmente. El contenido trasladado no se pierde ni se resume: se mueve íntegro, con su redacción intacta.

## 2. Contratos e invariantes

- **Entrada:** AGENTS.md con 5 bloques de capacidades inline y referencias literales a `hermes sessions export` en AGENTS/README/bootstrap.
- **Salida:** AGENTS.md con sección de capacidades reducida a punteros; `docs/flujo-capacidades.md` con el contenido trasladado íntegro; convención de sesión genérica en los tres documentos vivos.
- **Invariantes:**
  - **Nada se pierde:** cada bloque trasladado conserva su redacción completa en `docs/flujo-capacidades.md` (no es un resumen; es una mudanza).
  - **AGENTS sigue siendo el resumen vivo:** conserva protocolo estable (tiers, DoD, ciclo de unidad, precedencia) y apunta al archivo de capacidades para el detalle acumulado. Su función no cambia; su tamaño sí.
  - **Neutralidad de harness:** ningún documento vivo nombra un CLI de host como requisito; los ejemplos concretos viven en el archivo de capacidades como ejemplos.
  - **Gate intacto:** `scripts/` no se toca; `verify-contract.sh` no crece (docs-only sin cambio de comportamiento).
  - **Fail-safe del gate inalterado:** el gate sigue verificando existencia/no-vacío, no contenido de AGENTS.
  - **Piloto intacto:** encabezados `## Estado inicial: semilla Hito 0` y `## Reglas de gobernanza` presentes y en orden.
  - **Historia intacta:** specs seed-001..014 byte a byte; `docs/harness-metrics.md` byte a byte.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: el gate sigue verde sin cambios de comportamiento
  Dado los documentos vivos reestructurados
  Cuando corre ./scripts/verify.sh
  Entonces sale 0 con el mismo conteo de contrato (97 passed, 0 failed)

Escenario BDD-2: el piloto conserva sus anclas
  Dado AGENTS.md reestructurado
  Cuando el piloto sed-borra el rango entre los encabezados de estado inicial y reglas
  Entonces los encabezados siguen presentes y el gate de semilla corre

Escenario BDD-3: nada de `hermes` como requisito en documentos vivos
  Dado AGENTS.md, README.md y .agents/bootstrap.md
  Cuando se buscan referencias a comandos de host como obligación
  Entonces la convención es genérica; el comando concreto aparece solo como ejemplo en docs/flujo-capacidades.md

Escenario BDD-4: el contenido trasladado no se pierde
  Dado docs/flujo-capacidades.md
  Cuando se compara contra los bloques originales
  Entonces cada bloque (Seeds 009/010/011/013/014) está completo, con su redacción
```

| ID | Requisito | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Gate sin cambios | BDD-1 | `./scripts/verify.sh` | exit 0, contrato 97/0 |
| CA-2 | Piloto intacto | BDD-2 | piloto del gate + inspección de encabezados | anclas presentes |
| CA-3 | Neutralidad | BDD-3 | `grep -n 'hermes' AGENTS.md README.md .agents/bootstrap.md` | sin comando de host como obligación |
| CA-4 | Mudanza íntegra | BDD-4 | comparación bloque a bloque | contenido completo en flujo-capacidades.md |
| CA-5 | Gate no crece | — | `git diff --stat scripts/` | vacío (scripts intactos) |
| CA-6 | Historia intacta | — | `git diff --name-only` sobre specs/ y docs/harness-metrics.md | sin cambios |

## 4. Archivos autorizados

- **Editables:**
  - `AGENTS.md` (extraer bloques de capacidades; dejar punteros)
  - `README.md` (bloque Seed 011 genérico)
  - `.agents/bootstrap.md` (ritual de cierre genérico)
  - `docs/flujo-capacidades.md` (crear: capacidades trasladadas + ejemplo concreto de export)
  - `docs/seed-upgrades.md` (nota de la higiene)
  - `specs/seed-015-higiene-molde.md` (crear, esta spec)
  - `STATE.md` (registro de la unidad)
- **Protegidos:** todo `scripts/`; `specs/seed-001..014*.md`; `docs/harness-metrics.md`; `docs/agent-capabilities.md`; ADR 0000–0006.
- Ampliación de rutas antes de editar: si hace falta tocar otro documento vivo, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es higiene de semilla sin cambio de comportamiento → verificación en verde, sin fase roja artificial (AGENTS §2.7, regla de revisiones de documentación).
- **Comandos y suites de cierre:** `./scripts/verify.sh` (exit 0, contrato 97/97), `bash scripts/tests/verify-contract.sh` (97/0), `grep -n hermes AGENTS.md README.md .agents/bootstrap.md` (sin obligación), `git diff --stat scripts/` (vacío).
- **Chequeo rápido de iteración:** `bash scripts/tests/verify-contract.sh` + inspección visual de AGENTS (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-6; verificar que ningún bloque perdió redacción (mudanza, no resumen) y que el gate no cambió. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0000–0006 intactos byte a byte; specs históricas intactas.

## 6. Cierre y continuidad

- **Evidencia:** 2026-10-12. `./scripts/verify.sh` → exit 0, contrato **97 passed, 0 failed** (sin cambios de comportamiento; scripts intactos byte a byte). `grep -n hermes AGENTS.md README.md .agents/bootstrap.md` → sin coincidencias (neutralidad de harness). `git diff --stat scripts/` vacío. Specs seed-001..014 intactas (`git diff --name-only -- specs/` solo lista seed-015). Anclas del piloto presentes: `## Estado inicial: semilla Hito 0` (L5) y `## Reglas de gobernanza` (L9). AGENTS.md 25.2K → 20.8K; `docs/flujo-capacidades.md` creado (8.2K) con los bloques trasladados íntegros (Seeds 009/010/011/013/014).
- **Aprendizaje:** la extracción es mudanza, no resumen: verificar bloque a bloque que la redacción completa aterrizó en el archivo destino antes de borrar del origen. El gate lee AGENTS/README/bootstrap de forma estructural (existencia/no-vacío), así que una reestructuración del contenido no mueve el gate; el archivo de capacidades queda fuera de los requeridos por diseño (referenciado por enlace, no endurecido).
- **Commit:** pendiente de política de commits confirmada por el usuario para esta unidad.
- **Checkpoint en STATE:** siguiente unidad y primer paso tras aprobación.
- **Continuidad:** checkpoint según AGENTS; capacidades opcionales en docs/agent-capabilities.md.
