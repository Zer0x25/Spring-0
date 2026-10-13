# Spec: Seed 016 — Índice canónico de ADR + corrección de precedencia (limpieza de base)

> Estado: Borrador — pendiente de aprobación del usuario
> Nivel: Tier 1 — toca los ADR del molde y crea el índice de precedencia; es composición de base, pero altera cómo se lee la historia de decisiones.
> Requisitos: auditoría de los ADR del molde (2026-10-12) previa a tocar nada; las correcciones son de redacción sobre contradicciones puntuales ya resueltas en política viva.
> ADR aplicables: 0000–0006 (conservados; se corrigen dos contradicciones puntuales de redacción en ADR 0000 conforme a la propia política de precedencia que este cambio aclara). Sin ADR nuevo: el índice es documentación de gobernanza, no una decisión nueva.
> Aceptación: usuario, por aprobación explícita de esta spec. No autoaceptada.

## 1. Objetivo y alcance

- **Resultado observable:** la base de ADR queda compuesta sin contradicciones ni frases muertas. (1) `docs/adr/README.md` se convierte en el índice canónico: precedencia vigente en un solo lugar (anfitrión/usuario → AGENTS → ADR como registro histórico), qué decide cada ADR y qué reemplaza, numeración (0000–0006 molde / 0002 y 0007+ derivado / seeds no consumen números) y lista de convenciones vivas no-ADR (Notion, sesión, capa, transversales). (2) ADR 0000 corrige sus dos contradicciones puntuales y apunta al índice. (3) ADR 0003/0004/0005 dejan de incrustar frases «siguiente número libre» que ya envejecieron, y apuntan al índice.
- **Incluye:** crear `docs/adr/README.md`; corregir ADR 0000 L28 y L42 + nota de cabecera; limpiar las frases muertas de ADR 0003 L17, ADR 0004 L19, ADR 0005 L21; nota en `docs/seed-upgrades.md`; esta spec.
- **Excluye:** reescribir el sentido de cualquier ADR (solo redacción/quirúrgico); tocar ADR 0001 y 0006 (tienen la política correcta y sirven de patrón); crear ADR nuevos para las capacidades V5.0–V5.5 (son convenciones vivas, no decisiones de arquitectura — duplicarlas sería sobreingeniería); unificar los campos de cabecera «Relacionado/Reemplaza» al formato de 0006 (queda diferido salvo que el usuario lo pida); tocar `scripts/` ni el gate.
- **Pendientes críticos / supuestos aceptados:** el gate lee los ADR solo de forma estructural (existencia, no contenido), así que editar redacción no mueve el gate. La inmutabilidad del registro ADR no se viola: el sentido de las decisiones no cambia, solo se corrigen contradicciones de letra contra la política viva y se retiran frases que ya no describen la realidad. El índice es documentación de gobernanza, no un ADR.

## 2. Contratos e invariantes

- **Entrada:** ADR 0000 con 2 contradicciones puntuales; ADR 0003/0004/0005 con frases «siguiente número libre» muertas; sin índice canónico de precedencia.
- **Salida:** `docs/adr/README.md` con precedencia, tabla de decisiones, numeración y convenciones vivas; ADR 0000 alineado a ADR 0006/0001 con puntero al índice; frases muertas reemplazadas por puntero al índice.
- **Invariantes:**
  - **El sentido de cada ADR no cambia:** las ediciones son de letra (contradicción → alineación) y de limpieza (frase muerta → puntero). No se reescribe una decisión.
  - **Precedencia vigente = la de ADR 0006:** los documentos del repo no prevalecen sobre instrucciones del anfitrión ni del usuario; AGENTS resume la política operativa vigente; el ADR es registro histórico. El índice declara esto una sola vez.
  - **Numeración canónica única:** 0000–0006 = molde (gobernanza); 0002 = arquitectura del derivado; 0007+ = decisiones reales del derivado; las seeds son mantenimiento del molde y NO consumen números de ADR. Se dice en un solo lugar (índice) y los ADR apuntan ahí.
  - **Sin ADR nuevo por capacidades:** Notion, trazabilidad, ritual de sesión, preparación de capa y decisiones transversales son convenciones vivas (AGENTS + `docs/flujo-capacidades.md`); el índice las nombra sin absorber su contenido.
  - **Historia preservada:** no se borra ninguna decisión; una corrección de letra se documenta en el índice para que la evolución sea visible.
  - **Gate intacto:** `scripts/` no se toca; el gate lee los ADR estructuralmente.

## 3. Comportamientos BDD y aceptación

```gherkin
Escenario BDD-1: no quedan contradicciones de precedencia en los ADR del molde
  Dado los ADR 0000–0006
  Cuando se busca lenguaje de prevalencia absoluta de los ADR sobre instrucciones
  Entonces ADR 0000 apunta al índice y a ADR 0006; ningún ADR afirma prevalencia sobre el anfitrión/usuario

Escenario BDD-2: no quedan frases «siguiente número libre» muertas
  Dado los ADR 0003/0004/0005
  Cuando se busca la numeración de ADR
  Entonces cada uno apunta al índice canónico en vez de citar un número que ya no describe el espacio

Escenario BDD-3: el índice existe y es la fuente única de precedencia y numeración
  Dado docs/adr/README.md
  Cuando se lee
  Entonces declara precedencia, tabla de decisiones, numeración y convenciones vivas no-ADR

Escenario BDD-4: el gate sigue verde (docs-only)
  Dado los cambios de redacción
  Cuando corre ./scripts/verify.sh
  Entonces sale 0 con el mismo conteo de contrato (97 passed, 0 failed)
```

| ID | Requisito | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | Sin contradicción | BDD-1 | `grep -rn 'prevalec' docs/adr/` | ADR 0000 sin prevalencia absoluta; apunta al índice/0006 |
| CA-2 | Sin frases muertas | BDD-2 | `grep -rn 'siguiente número libre\|siguiente libre' docs/adr/` | sin resultados en 0003/0004/0005 |
| CA-3 | Índice canónico | BDD-3 | existencia + lectura de `docs/adr/README.md` | precedencia/numeración/convenciones declaradas |
| CA-4 | Gate sin cambios | BDD-4 | `./scripts/verify.sh` | exit 0, contrato 97/0 |
| CA-5 | Sentido intacto | — | diff de ADR 0000 | solo L28/L42 + nota de cabecera; resto byte a byte |
| CA-6 | No-ADR de capacidades | — | revisión del índice | convenciones vivas nombradas, no absorbidas; sin ADR nuevo |

## 4. Archivos autorizados

- **Editables:**
  - `docs/adr/README.md` (crear: índice canónico de precedencia, decisiones, numeración, convenciones vivas)
  - `docs/adr/0000-adopcion-gobernanza-agentica.md` (corregir L28 y L42 + nota de cabecera que apunta al índice)
  - `docs/adr/0003-autonomia-y-continuidad.md` (L17: frase muerta → puntero al índice)
  - `docs/adr/0004-producto-comportamiento-y-cierre.md` (L19: frase muerta → puntero al índice)
  - `docs/adr/0005-gobernanza-proporcional-al-riesgo.md` (L21: frase muerta → puntero al índice)
  - `docs/seed-upgrades.md` (nota de la limpieza de base)
  - `specs/seed-016-indice-adr.md` (crear, esta spec)
  - `STATE.md` (registro de la unidad)
- **Protegidos:** ADR 0001 y ADR 0006 (intactos — política correcta, sirven de patrón); `scripts/`; `specs/seed-001..015*.md`; `docs/flujo-capacidades.md`; `AGENTS.md`.
- Ampliación de rutas antes de editar: si hace falta tocar otro ADR del molde, se amplía aquí y se registra el motivo antes de editar.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md sección 9 para unidades de producto. Esta unidad es limpieza de base sin cambio de comportamiento → verificación en verde, sin fase roja artificial (AGENTS §2.7, regla de revisiones de documentación).
- **Comandos y suites de cierre:** `./scripts/verify.sh` (exit 0, contrato 97/97), `grep -rn 'prevalec' docs/adr/`, `grep -rn 'siguiente número libre\|siguiente libre' docs/adr/`, `git diff --stat scripts/` (vacío).
- **Chequeo rápido de iteración:** `bash scripts/tests/verify-contract.sh` + lectura del índice (no sustituye el gate raíz).
- **Revisión Tier 1:** contraste del diff contra CA-1..CA-6; verificar que el sentido de cada ADR no cambió (solo letra/quirúrgico) y que el índice nombra sin absorber las convenciones vivas. No se presenta como revisión independiente.
- **Condiciones adicionales:** ADR 0001/0006 intactos byte a byte; scripts intactos byte a byte.

## 6. Cierre y continuidad

- **Evidencia:** 2026-10-12. `./scripts/verify.sh` → exit 0, contrato **97 passed, 0 failed** (docs-only; scripts intactos byte a byte). CA-1: `grep -rn prevalec docs/adr/` → las coincidencias son ADR 0006 (declara la política real: los docs del repo no prevalecen sobre anfitrión/usuario), ADR 0000 (apunta al índice/0006) y el índice (corolario + cláusula de supremacía); ninguna afirma prevalencia sobre el usuario. CA-2: `grep -rn 'siguiente número libre\|siguiente libre\|inicialmente 0006' docs/adr/` → solo el índice (cláusula de supremacía, por diseño). CA-5: ADR 0001 y 0006 intactos byte a byte (`git diff --stat` vacío). ADR 0000 con diff acotado a L6 (nota de cabecera), L28 (precedencia) y L42 (DomainError como ejemplo de perfil).
- **Aprendizaje:** auditar los ADR como base del molde (no solo por contradicción puntual) reveló tres capas de deuda: contradicciones de letra contra la política viva, frases «siguiente número libre» que envejecen mal al incrustarse en cada ADR, y la ausencia de un índice canónico de precedencia/numeración. Centralizar en `docs/adr/README.md` y apuntar desde los ADR evita que cada seed futura tenga que redescubrir el espacio de numeración.
- **Commit:** pendiente de política de commits confirmada por el usuario para esta unidad.
- **Checkpoint en STATE:** siguiente unidad y primer paso tras aprobación.
- **Continuidad:** checkpoint según AGENTS; capacidades opcionales en docs/agent-capabilities.md.
