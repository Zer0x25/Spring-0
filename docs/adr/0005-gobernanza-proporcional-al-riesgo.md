# ADR 0005: Gobernanza proporcional al riesgo

- **Fecha:** 2026-10-07.
- **Estado:** Aceptado por el usuario: «hazlo integralo», tras recomendar los tres niveles con controles de riesgo, trazabilidad y gate de cierre.
- **Aplica a:** Semilla y proyectos derivados que confirmen la política en su prompt maestro. No amplía automáticamente delegaciones de proyectos existentes.
- **Relacionado:** ADR 0001, 0003 y 0004.
- **Reemplaza parcialmente:** La obligación de una spec nueva por cada unidad de trabajo de ADR 0003/0004 para correcciones Tier 3 autorizadas. El registro ligero cumple su función de alcance y evidencia. Conserva PRD como fuente de producto, autoridad, DoD, gates, ADR inmutables y control de falta de progreso.

## Contexto

Una corrección acotada no necesita el mismo trabajo documental que un cambio de permisos o concurrencia. Exigir documentos nuevos por cada ajuste aumenta trabajo repetido; eliminar toda trazabilidad permite cambios sin alcance ni evidencia. El nombre de la tarea o el número de líneas tampoco mide su riesgo.

## Decisión

1. **Clasificar antes de editar:** Registrar nivel y justificación por impacto, contratos, datos y riesgo. Tier 3 (ligero) restaura comportamiento confirmado o ajusta presentación dentro del alcance autorizado; Tier 2 (estándar) añade funcionalidad dentro del PRD; Tier 1 (riesgo alto) trata arquitectura, seguridad/permisos, pagos, concurrencia, migraciones delicadas e integraciones externas. Ante incertidumbre se usa el nivel de mayor control pertinente y se consulta cualquier ambigüedad crítica. AGENTS es la fuente operativa de criterios y formato.
2. **Tier 3:** No exige spec ni ADR nuevos. Antes de editar se crea en STATE un registro identificado y aprobado, con fuente del comportamiento confirmado, problema/resultado, rutas autorizadas, verificación y autoridad. Al cerrar se añaden evidencia, estado de commit y siguiente paso. Se referencia una spec existente sin modificarla ni reabrirla. Si no hay fuente clara o la corrección cambia el contrato, deja de ser Tier 3. Un requisito confirmado directamente por el usuario puede ser fuente; los tests existentes por sí solos no resuelven ambigüedades de negocio.
3. **Tier 2/1:** Usan spec breve/detallada respectivamente con criterios y verificaciones pertinentes. Los contratos siguen el stack elegido; BDD puede expresarse en tests si la spec los identifica y las aserciones prueban el comportamiento. Tier 1 añade ADR cuando introduce o cambia una decisión significativa; un ADR no sustituye a la spec. PRD se actualiza solo ante cambios de alcance o aceptación confirmados, no por cada tarea.
4. **Controles comunes:** Toda unidad tiene autorización, alcance, evidencia, DoD, gate y checkpoint. Dependencias, cambios materiales y commits siguen la delegación confirmada; permiso de commit por spec no se extiende a registros ligeros sin confirmación. Push, merge y despliegue conservan autorización propia. No se debilitan tests ni se corrigen expectativas sin una fuente de comportamiento válida.
5. **Verificación neutral:** Un chequeo rápido puede acordarse para iterar, con comandos reales y cobertura explícita. El cierre ejecuta `./scripts/verify.sh` y los controles obligatorios de la DoD acordada; el tier no permite omitirlos. La semilla no impone npm, DTO compartido, Prisma, Vitest ni un comando de diagnóstico específico. Cambios documentales o de presentación usan comprobaciones adecuadas sin TDD artificial; cambios de comportamiento usan pruebas de regresión/contrato.
6. **Continuidad por unidad:** Se mantiene una unidad activa, identificada por spec o registro ligero, con checkpoint en STATE. El aprendizaje útil va al registro local correspondiente; no se fabrica aprendizaje ni se exige compactar tras cada ajuste. La entrevista acuerda compactación por necesidad de contexto o entre unidades según preferencia. El umbral y contador de falta de progreso se conservan al reclasificar, compactar o cambiar de sesión.
7. **Adopción:** Bootstrap confirma niveles, límites por nivel, comandos de verificación, commits y continuidad; el prompt registra esa autoridad y referencia AGENTS sin duplicar la tabla. Los proyectos existentes requieren confirmar la adopción y actualizar sus instrucciones aplicables. La numeración de ADR se rige por el [índice](README.md); 0002 sigue reservado para arquitectura base de producto.

## Consecuencias y verificación

Reduce documentos nuevos en correcciones acotadas y mantiene trazabilidad por registros identificados. Requiere juicio de riesgo y un checkpoint breve incluso en Tier 3. Se descarta un clasificador automático y crear un comando de gate por tier en la semilla.

Seed 007 revisa escenarios y consistencia entre instrucciones, entrevista, prompt y plantilla. El gate semilla solo comprueba estructura: ni valida automáticamente la clasificación ni demuestra cumplimiento del protocolo por un agente. Una app derivada debe aportar sus pruebas reales y aceptación de producto.
