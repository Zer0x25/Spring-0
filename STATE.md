# Estado del Proyecto: Semilla Spring-0

- Fase: `mold`; molde de gobernanza agéntica que se gobierna a sí mismo como padre (no es un derivado). Sin stack ni producto seleccionado; no corre scope-lock ni verificador de producto.
- Versión funcional: **V5.6** — estado migrado 1:1 desde Hito-0 (`0e683dd`, tag `v5.6.0`) a este repo fresco sin historial, el 2026-10-12.
- Construcción: gobernada desde [Constructor-Padre](https://github.com/Zer0x25/Constructor-Padre); este repo es el molde que provee gobernanza a derivados, no se construye a sí mismo.
- Base del molde: specs históricas conservadas en el Constructor-Padre (unidades de construcción del molde); este repo expone solo el molde a derivados.
- Historia conservada: [Seeds 001–007](docs/history/seed-001-007.md). Sus permisos de publicación no se reutilizan para esta unidad.

## Entrega de D-008/D-009 (2026-10-14)

- Usuario autorizó «commit and push» de los cambios acumulados; la autoridad de publicación se registra separada de los criterios técnicos ya cerrados.
- El commit de entrega incluye este checkpoint; su SHA se obtiene del historial Git, sin crear un commit adicional para registrar su propio hash.
- Verificación de entrega: contrato 139/139 y distribución con exportación, recuperación, sellado y cierre de spec/LIG. CI y hashes remotos se comprueban tras el push.
- Siguiente mejora propuesta: piloto real de un derivado con entrevista y autoridad confirmada; después revisar aceptación/revisión y reglas de arquitectura por perfil. No hay unidad de producto activa.

## Construcción vigente — D-009 (2026-10-14)

- Autoridad: usuario «hazlo» en Constructor-Padre; criterios, alcance y cambio de política registrados en D-009.
- Resultado: cierre con evidencia explícita/huella antes de diff; base por unidad; controles omitidos visibles; pendientes por ID con críticos bloqueantes y diferibles registrados.
- Verificación: `../scripts/verify-distribution.sh` exit 0; contrato 139/139 en molde y semilla; piloto con recuperación, cierre de spec/LIG y dos unidades sin actualizar origin/main verde.
- Estado: D-009 cerrada localmente; cambios sin commit/push, sin unidad de producto activa. Contador 0, sin bloqueo.
- Siguiente paso: nueva unidad cuando se solicite; adopción en derivados anteriores requiere migración explícita, detallada en D-009 del padre. CI remota no ejecutada.

## Construcción previa — D-008 (2026-10-14)

- Autoridad: usuario «hazlo» en Constructor-Padre; alcance y criterios registrados en D-008.
- Resultado: exportación segura a `seed` con procedencia y STATE limpio; alcance compatible con la plantilla real, protegidos prevalentes y selección del LIG activo.
- Verificación: `../scripts/verify-distribution.sh` exit 0; contrato 111/111 y piloto con plantilla real/base Git temporal, dos recuperaciones y alcance confirmado en Tier 2/Tier 3. Exportación segura/repetición/limpieza verificadas.
- Estado: D-008 cerrada localmente, cambios sin commit/push; no hay unidad de producto activa. Contador 0, sin bloqueo.
- Siguiente paso: nueva unidad de construcción cuando se solicite; CI remota no ejecutada. Evidencia y límites en D-008 del padre.

## Antecedente histórico — Seed 016 (V5.6) — Índice canónico de ADR + limpieza de base

- Meta: componer la base de ADR sin contradicciones ni frases muertas. Índice canónico de precedencia/numeración + corrección quirúrgica de ADR 0000 + limpieza de frases muertas en 0003/0004/0005.
- Unidad de construcción: Seed 016 (V5.6), Tier 1; autoridad del usuario «hazlo», 2026-10-12. Spec conservada en el Constructor-Padre.
- Decisión de diseño: `docs/adr/README.md` = fuente única de precedencia (anfitrión/usuario → AGENTS → ADR histórico), numeración (0000–0006 molde / 0002 y 0007+ derivado / seeds no consumen números) y tabla de decisiones; lista las convenciones vivas (Notion, trazabilidad, sesión, capa, transversales, LIG-*) como NO-ADR. ADR 0000 corrige 2 contradicciones puntuales (prevalencia absoluta → apunta a 0006; DomainError universal → ejemplo de perfil TypeScript, 0001) + nota de cabecera al índice. ADR 0003/0004/0005: frases «siguiente número libre» → puntero al índice. ADR 0001/0006 intactos. Docs-only sin cambio de comportamiento → verde, sin fase roja artificial. Sin ADR nuevo: el índice es documentación de gobernanza.
- Estado: cerrada; CA-1–CA-6 verificados. Cambios locales sin commit (sin política de commits autorizada).
- Evidencia: `./scripts/verify.sh` exit 0, contrato 97/97 (scripts intactos byte a byte); grep de precedencia y frases muertas con resultados esperados (solo el índice como cláusula de supremacía); ADR 0001/0006 intactos byte a byte.
- Nota de supervisión: GYM-2026 permanece en V5.0 por diseño — no se le empujan los fixes del molde; las fricciones se aprenden sobre su base congelada.
- Commit: pendiente de autorización del usuario. Probable release V5.6 (commit + tag v5.6.0 + release) tras autorización.
- Siguiente paso: definir próxima unidad. F-02 (revisiones humanas sin mecanismo de cierre) sigue como observación. Sin unidad activa.
- Falta de progreso: contador 0, sin bloqueo.

## Cobertura y límites

La inicialización real de un proyecto de usuario sigue pendiente. El piloto temporal usa decisiones simuladas, no certifica entrevista ni stacks alternativos. El perfil offline-first continúa propuesto y sin implementación. Una aplicación completa requiere PRD y evidencia propios.
