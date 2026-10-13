# Seed 007: Gobernanza proporcional al riesgo

- **Estado:** Implementada y verificada documentalmente; entrega mediante el commit de Seed 007 autorizado por el usuario el 2026-10-07.
- **Aceptación:** Usuario, 2026-10-07: «hazlo integralo», sobre la propuesta de tres niveles con registro ligero, controles de riesgo y gate de cierre.
- **Requisitos:** Mantenimiento de semilla; no hay PRD de producto ni inicio de Hito 1.
- **ADR aplicables:** 0001, 0003, 0004 y nuevo 0005 aceptado por esa instrucción.
- **Nivel:** Tier 1; cambia el protocolo de gobernanza. Verificación documental, sin fase roja artificial.

## Objetivo y límites

Reducir documentación en correcciones acotadas sin perder alcance autorizado, trazabilidad, evidencia, DoD ni continuidad. Tier 3 admite un registro breve en STATE vinculado al comportamiento confirmado; Tier 2 usa spec breve y Tier 1 spec detallada con ADR cuando hay decisión arquitectónica. Los niveles no cambian permisos ni comandos por iniciativa del agente.

No implementar clasificadores automáticos, comandos rápidos, nuevos runtimes, dependencias ni una app. No modificar ADR aceptados, scripts de gate, originales externos ni releases. Commit y push autorizados por el usuario el 2026-10-07: «commit and push»; esa autorización no incluye release nueva ni despliegue.

## Archivos autorizados

- `specs/seed-007-gobernanza-por-niveles.md`: alcance y evidencia de este mantenimiento.
- `docs/adr/0005-gobernanza-proporcional-al-riesgo.md`: decisión nueva; inmutable después de redactada como aceptada.
- `AGENTS.md`: fuente operativa única de niveles, registro ligero, DoD y ciclo.
- `.agents/bootstrap.md`: entrevista, confirmación de niveles y comandos; numeración de ADR.
- `.agents/master-prompt.template.md`: autoridad por nivel y continuidad por unidad.
- `specs/templates/feature.template.md`: clasificación y verificación de Tier 2/1.
- `README.md`: explicación y referencias para uso de la plantilla.
- `STATE.md`: progreso, evidencia y checkpoint.

## Criterios de aceptación y verificación

| ID | Resultado observable | Verificación |
|---|---|---|
| CA-1 | Tres niveles por riesgo/efecto; restricciones comunes y escalamiento ante incertidumbre | Revisar AGENTS y ADR 0005; escenarios D1–D4 |
| CA-2 | Tier 3 sin spec nueva, con ID, autoridad, fuente de comportamiento, rutas, criterio y evidencia antes del cierre | Revisar formato en AGENTS; D1, D5, D6 |
| CA-3 | Tier 2 conserva contrato aplicable y BDD comprobado; Tier 1 spec y ADR solo por decisión; PRD solo por cambio de producto | D2–D4, D7–D9 |
| CA-4 | Neutralidad de stack; chequeo rápido opcional para iterar y gate raíz obligatorio al cierre; sin reducir DoD | D10–D12; gate semilla |
| CA-5 | Entrevista y prompt confirman autoridad por nivel y comandos sin ampliar delegación preexistente | Revisión cruzada; D5, D13 |
| CA-6 | Continuidad y falta de progreso por unidad; aprendizaje útil; compactación según necesidad/política, sin contador nuevo por cambio de tier | D6, D14 |
| CA-7 | README, plantilla y STATE coherentes; ADR previos intactos y cambios limitados a rutas autorizadas | Enlaces locales, diff, hashes de ADR previos, fase y gate |

## Escenarios de revisión documental

Estas situaciones evalúan las instrucciones escritas; no son pruebas ejecutadas del comportamiento de un agente o app.

- **D1:** Dado un texto incorrecto o defecto de presentación acotado, cuando se corrige con criterio confirmado, entonces Tier 3 registra fuente, rutas y evidencia adecuada sin spec ni test artificial nuevo.
- **D2:** Dado un filtro nuevo dentro del PRD, cuando se implementa, entonces Tier 2 tiene spec breve y pruebas del comportamiento; no exige DTO si no cruza un contrato.
- **D3:** Dado un bug de dos líneas que afecta permisos, pagos o concurrencia, cuando se clasifica, entonces Tier 1 exige controles pertinentes; no genera ADR si restaura la decisión vigente.
- **D4:** Dado un cambio de arquitectura, migración delicada o integración externa, entonces Tier 1 documenta riesgos y verificación; ADR nuevo si cambia una decisión, sin sustituir la spec.
- **D5:** Dado un contrato ambiguo o ausencia de autoridad para registro ligero, entonces no se infiere permiso; se usa spec y se consulta lo crítico.
- **D6:** Dado un registro Tier 3 cerrado, cuando aparece otro defecto, entonces se crea otro ID y se conserva la evidencia anterior sin reabrir o editar una spec cerrada.
- **D7:** Dado un test que falla, entonces no se eliminan aserciones ni se cambia el comportamiento esperado sin confirmar su fuente; no basta clasificar como «corrección de tests».
- **D8:** Dado un test con nombre BDD, entonces las aserciones deben comprobar resultados, alternativas y rechazos pertinentes; el nombre no es evidencia suficiente.
- **D9:** Dado un cambio fuera del PRD o de la delegación, entonces requiere aceptación del usuario aunque se clasifique como pequeño; solo cambia PRD si afecta alcance/aceptación.
- **D10:** Dado un proyecto sin npm, monorepo, Prisma o Vitest, entonces los niveles usan contratos y comandos reales del perfil sin exigir esas tecnologías.
- **D11:** Dado un chequeo rápido verde, entonces la unidad permanece pendiente hasta el gate raíz y los controles obligatorios acordados.
- **D12:** Dado un fallo del gate, entonces no se reduce nivel, DoD ni suite para cerrar.
- **D13:** Dada autorización de commit por spec, entonces no se asume permiso de commit para registros ligeros; la entrevista confirma por separado ese alcance y push sigue independiente.
- **D14:** Dado el umbral de intentos sin progreso, entonces se conserva contador/checkpoint y se solicita intervención concreta; reclasificar o compactar no reinicia el contador.

## Plan de verificación

Revisión cruzada de D1–D14, enlaces Markdown locales y alcance del diff; comparación de ADR aceptados previos con Git. Ejecutar `./scripts/verify.sh` y `git diff --check`. No hay modificación del despachador ni tests nuevos: este cambio es documental. El gate estructural no demuestra que un agente siga los niveles ni que una app derivada funcione.

## Cierre

### Evidencia de aceptación — 2026-10-07

- **CA-1–CA-3:** D1–D9 revisados contra AGENTS y ADR 0005: registro ligero identificado con autoridad y rutas antes de editar; spec breve/detallada según riesgo; correcciones sensibles en Tier 1; ADR por decisión y PRD por alcance; tests con aserciones y fuente confirmada. No se modifican specs cerradas para añadir correcciones.
- **CA-4–CA-6:** D10–D14 revisados contra AGENTS, bootstrap y prompt: stack neutral, chequeo rápido opcional, gate de cierre obligatorio, autoridad/commits separados por modalidad, continuidad por unidad y contador persistente. La plantilla también permite una spec Tier 3 cuando no se autoriza registro ligero; no se pierde la ruta de aprobación previa.
- **CA-7:** Revisión cruzada de README, plantilla y checkpoint. Inspección de enlaces locales, formato de los ocho archivos autorizados y fase: correcta. Comparación byte a byte de ADR previos con HEAD: idénticos. Diff limitado al alcance; no hay cambios de scripts, dependencias, app ni releases.
- `./scripts/verify.sh`: salida 0; comprobación estructural de semilla.
- `git diff --check`: salida 0; además se revisó formato de archivos nuevos no incluidos todavía en el diff de Git.
- **Límite de evidencia:** D1–D14 son revisión documental, sin ejecución de un agente ni app derivada. No se añadieron ni ejecutaron nuevas suites de pruebas; el despachador no cambió. La presencia de documentos no certifica el cumplimiento de la política durante desarrollo real.

### Aprendizaje y continuidad

La clasificación por nombre/tamaño de tarea puede ocultar riesgo. Un registro ligero debe conservar fuente, autoridad y alcance; reducir documentos no reduce la evidencia necesaria. Aplicación futura: confirmar modalidad y comandos en la entrevista, conservar la fuente operativa en AGENTS y registrar escalamiento sin reiniciar el contador.

STATE recoge el checkpoint y la validación derivada pendiente. Base local anterior: `295fd18` (Seed 006); el remoto antes de esta publicación estaba en `1bea0d4` (Seed 005). El push autorizado publica también el commit previo de Seed 006, revisado dentro del historial, sin reescribirlo.

- **Commit de referencia:** commit de esta spec, `feat(seed): integrar gobernanza proporcional al riesgo`, con las ocho rutas autorizadas y este checkpoint. Se referencia por ID Seed 007 para evitar otro commit solo para registrar su propio hash.
- **Publicación:** push autorizado a `origin/main`; comprobar igualdad entre HEAD y la referencia remota después de publicar e informar hash y resultado al usuario. Si falla, conservar el checkpoint e informar entrega Git pendiente sin declarar publicación satisfactoria.
- **Continuidad:** `/learn` y `/compact` no invocados; el registro local satisface el aprendizaje de este mantenimiento. Sin release nueva.
