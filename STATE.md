# Estado del Proyecto: Semilla Spring-0

- Fase: `seed`; molde de gobernanza agéntica (antes Hito-0), sin stack ni producto seleccionado.
- Versión funcional: **V5.6** — estado migrado 1:1 desde Hito-0 (`0e683dd`, tag `v5.6.0`) a este repo fresco sin historial, el 2026-10-12.
- Construcción: gobernada desde [Constructor-Padre](https://github.com/Zer0x25/Constructor-Padre); este repo es el molde que provee gobernanza a derivados, no se construye a sí mismo.
- Base revisada: `46c519b` (Seed 007).
- Historia conservada: [Seeds 001–007](docs/history/seed-001-007.md). Sus permisos de publicación no se reutilizan para esta unidad.

## Última unidad — Seed 016 (V5.6) — Índice canónico de ADR + limpieza de base

- Meta: componer la base de ADR sin contradicciones ni frases muertas. Índice canónico de precedencia/numeración + corrección quirúrgica de ADR 0000 + limpieza de frases muertas en 0003/0004/0005.
- Unidad: [Seed 016](specs/seed-016-indice-adr.md), Tier 1 (toca los ADR del molde); autoridad del usuario «hazlo», 2026-10-12.
- Decisión de diseño: `docs/adr/README.md` = fuente única de precedencia (anfitrión/usuario → AGENTS → ADR histórico), numeración (0000–0006 molde / 0002 y 0007+ derivado / seeds no consumen números) y tabla de decisiones; lista las convenciones vivas (Notion, trazabilidad, sesión, capa, transversales, LIG-*) como NO-ADR. ADR 0000 corrige 2 contradicciones puntuales (prevalencia absoluta → apunta a 0006; DomainError universal → ejemplo de perfil TypeScript, 0001) + nota de cabecera al índice. ADR 0003/0004/0005: frases «siguiente número libre» → puntero al índice. ADR 0001/0006 intactos. Docs-only sin cambio de comportamiento → verde, sin fase roja artificial. Sin ADR nuevo: el índice es documentación de gobernanza.
- Estado: cerrada; CA-1–CA-6 verificados. Cambios locales sin commit (sin política de commits autorizada).
- Evidencia: `./scripts/verify.sh` exit 0, contrato 97/97 (scripts intactos byte a byte); grep de precedencia y frases muertas con resultados esperados (solo el índice como cláusula de supremacía); ADR 0001/0006 intactos byte a byte.
- Nota de supervisión: GYM-2026 permanece en V5.0 por diseño — no se le empujan los fixes del molde; las fricciones se aprenden sobre su base congelada.
- Commit: pendiente de autorización del usuario. Probable release V5.6 (commit + tag v5.6.0 + release) tras autorización.
- Siguiente paso: definir próxima unidad. F-02 (revisiones humanas sin mecanismo de cierre) sigue como observación. Sin unidad activa.
- Falta de progreso: contador 0, sin bloqueo.

## Cobertura y límites

La inicialización real de un proyecto de usuario sigue pendiente. El piloto temporal usa decisiones simuladas, no certifica entrevista ni stacks alternativos. El perfil offline-first continúa propuesto y sin implementación. Una aplicación completa requiere PRD y evidencia propios.
