# Aprendizaje — [Nombre del proyecto]

> Formato canónico de aprendizaje del molde Hito-0 (Seed 011, V5.1).
> Un aprendizaje por unidad observada. El derivado registra aquí las fricciones y descubrimientos reales que surgen al usar el flujo gobernado. El molde aprende de sus derivados a través de estas entradas.

## [AAAA-MM-DD] — Unidad: [ID o nombre de la unidad]

- **Hallazgo:** [qué se observó, en una o dos frases]
- **Evidencia:** [archivo:línea + cita textual breve, o comando + salida]
- **Aplicación futura:** [qué hacer distinto la próxima vez; si justifica tocar el molde, dilo]
- **Severidad:** baja | media | alta — [una línea de por qué]
- **¿Toca el molde?:** sí | no — [si sí, referencia la fricción para una seed futura]

### Ejemplo de referencia (del derivado GYM-2026, ya observado)

#### 2026-10-11 — Unidad: Hito 0 (bootstrap Modo A)

- **Hallazgo:** el arranque en Modo A (enriquecido desde Notion) permite trasladar 55 decisiones sin entrevista de descubrimiento; la entrevista se reduce a validación.
- **Evidencia:** página contenedora `3f529b8ebe2981fab0c2fa583efcdf15` + database de decisiones leídas vía MCP.
- **Aplicación futura:** ofrecer Modo A como ruta por defecto en derivados con material previo en Notion; mapear `Confirmada → aceptada`, `Pendiente/Derivada → HITO0_PENDING`, `Diferida → futuro explícito`.
- **Severidad:** baja — es una fortaleza del flujo, no una fricción.
- **¿Toca el molde?:** no.

#### 2026-10-11 — Unidad: Hito 0 (bootstrap Modo A)

- **Hallazgo (limitación del molde):** el gate `verify-structure.sh` exige que PRD/PROMPT-MAESTRO/ADR-0002 no contengan la cadena `HITO0_PENDING`, pero la política del bootstrap dice usar `HITO0_PENDING` para campos críticos sin resolver. Contradicción gate↔política.
- **Evidencia:** `scripts/verify-structure.sh` líneas 48-52; los pendientes se registraron en STATE.md y specs, evitando el marcador literal en archivos gateados.
- **Aplicación futura:** al inicializar proyectos con pendientes críticos, concentrar los `HITO0_PENDING` en STATE.md y specs, no en archivos que el gate escanea; o actualizar el gate del molde para permitir marcadores de pendiente en archivos aprobados.
- **Severidad:** media — fuerza un workaround en cada derivado con pendientes reales.
- **¿Toca el molde?:** sí — candidata a seed futura (alinear gate↔política de HITO0_PENDING).
