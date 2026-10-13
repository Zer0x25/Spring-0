# Índice de decisiones — ADR del molde Hito 0

Este archivo es la **fuente única** de precedencia y numeración de los ADR. Los ADR son el registro histórico de las decisiones de gobernanza del flujo agéntico; este índice dice cómo se leen.

## Precedencia vigente

1. **Instrucciones del anfitrión y del usuario** están por encima de cualquier documento del repo (ADR 0006). Una nueva decisión autorizada se registra antes de implementarse.
2. **[AGENTS.md](../../AGENTS.md)** resume la **política operativa vigente** del flujo.
3. **Los ADR** son registro histórico de decisiones. Ante contradicción material no resuelta, se consulta; no se atribuye autoridad superior a un documento histórico.

Corolario: ningún ADR prevalece sobre instrucciones del anfitrión ni del usuario. La inmutabilidad de un ADR preserva su *registro*, no su *precedencia* sobre el humano.

## Numeración

| Rango | Dueño | Para qué |
|---|---|---|
| 0000–0006 | Molde | Decisiones de gobernanza del flujo agéntico (este repositorio) |
| 0002 | Proyecto derivado | Arquitectura base del producto (reservado) |
| 0007+ | Proyecto derivado | Decisiones reales de producto |
| — | — | La evolución del molde se gobierna en Constructor-Padre y NO consume números de ADR |

## Qué decide cada ADR

| ADR | Decide | Aclara / reemplaza |
|---|---|---|
| 0000 | Adopción de la gobernanza agéntica (SDD, ADR, TDD, gates) | Letra aclarada por 0001 (perfiles/neutralidad) y 0006 (precedencia) |
| 0001 | Núcleo neutral + perfiles; el stack no es universal | Reemplaza las prescripciones de stack de ADR 0000 |
| 0003 | Autonomía delegada y continuidad entre specs | — |
| 0004 | Producto, comportamientos y cierre verificable (PRD, BDD, DoD) | Reemplaza en 0003 la asignación del alcance al prompt (PRD es la fuente) |
| 0005 | Gobernanza proporcional al riesgo (Tiers 1/2/3) | Reemplaza parcialmente la spec-obligatoria de 0003/0004 para Tier 3 |
| 0006 | Gobernanza verificable, fases seed→initializing→project y **precedencia** | Reemplaza parcialmente la precedencia conversacional de 0000; fases de 0001 |

Los campos «Relacionado / Aclara / Reemplaza» de cada ADR se leen a la luz de esta tabla. Si un ADR cita un «siguiente número libre», prevalece esta tabla.

## Convenciones vivas (NO son ADR)

Estas capacidades son **convenciones operativas** del flujo; viven en [AGENTS](../../AGENTS.md) y [`docs/flujo-capacidades.md`](../flujo-capacidades.md), no en ADR. Se listan aquí para que se sepa que existen y no se confundan con decisiones de arquitectura:

- Arranque con Notion (dos modos, Notion como contexto) — Seed 010.
- Trazabilidad `SPEC:<id>` y `Contexto (Notion)` en specs — Seed 010.
- Aprendizaje auditable y ritual de cierre de sesión (opt-in) — Seed 011.
- Preparación de capa / system design antes de tocar UI — Seed 013.
- Decisiones transversales por dominio (errores, tenant/auth, tests) — Seed 014.
- Reconocimiento de unidades ligeras `LIG-*` en el gate — Seed 014.

Duplicar estas convenciones en ADR sería sobreingeniería: no son decisiones de arquitectura, son método operativo.
