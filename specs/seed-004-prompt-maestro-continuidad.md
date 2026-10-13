# Spec: Seed 004 — Prompt maestro y continuidad de desarrollo

Estado: Aprobada por la petición del usuario de generar un prompt maestro desde la entrevista, desarrollar por specs probadas y commiteadas, aprender y compactar entre specs.

## Objetivo y límites

Conservar el sellado automático de Hito 0 y preparar Hito 1 mediante un prompt maestro Markdown confirmado. Delegar specs y ADR dentro de límites explícitos; registrar aprendizaje y continuidad en archivos. Mantener el molde en `phase=seed`, sin iniciar una app ni una goal de producto en esta sesión. No instalar dependencias ni ejecutar comandos de sesión inexistentes.

## Archivos editables autorizados

- `specs/seed-004-prompt-maestro-continuidad.md`
- `docs/adr/0003-autonomia-y-continuidad.md`
- `.agents/master-prompt.template.md`
- `.agents/bootstrap.md`
- `AGENTS.md`
- `specs/templates/feature.template.md`
- `README.md`
- `STATE.md`
- `scripts/verify.sh`
- `scripts/tests/verify-contract.sh`

## Consolidación Git autorizada

La petición de commits por spec se aplica al cierre de este mantenimiento. El checkout conserva cambios de Seeds 001–003 realizados en esta misma conversación y todavía no commiteados. Se revisan y consolidan junto con Seed 004 para que el commit contenga una semilla coherente. Es una consolidación del trabajo previo, no una ejecución de Hito 1; en proyectos derivados rige un commit por spec según delegación.

Rutas adicionales autorizadas exclusivamente para incluir los cambios previos ya aprobados, sin modificar ADR aceptados:

- `specs/seed-001-nucleo-agnostico-perfiles.md`
- `specs/seed-002-stacks-por-despliegue.md`
- `specs/seed-003-eleccion-base-datos.md`
- `.agents/project-profile.conf`
- `.agents/stack-presets.md`
- `.agents/examples/node-typescript-api/src/core/errors.ts`
- `docs/adr/0001-perfiles-y-aplicabilidad.md`
- `docs/adr/0000-template.md`
- `.env.example`
- `.gitignore`
- `.githooks/pre-commit`
- `.github/workflows/verify.yml`
- `scripts/install-hooks.sh`
- `src/core/errors.ts` (eliminación previamente autorizada)
- `src/core/.gitkeep` (eliminación previamente autorizada)
- `src/modules/.gitkeep` (eliminación previamente autorizada)
- `tests/modules/.gitkeep` (eliminación previamente autorizada)

## Criterios de aceptación

1. Entrevista define meta, alcance, exclusiones, aceptación final, autonomía, commits y continuidad; genera `PROMPT-MAESTRO.md` y `docs/learning.md` tras confirmación. El primer arranque de Hito 1 es explícito y el sellado mantiene AGENTS actualizado.
2. ADR nuevo permite autoaceptar specs y decisiones técnicas solo dentro de delegación confirmada. Cambios materiales se consultan; ADR aceptados permanecen inmutables y 0002 queda reservado para arquitectura de producto.
3. Ciclo por spec: contratos/pruebas, implementación, gate, aprendizaje, estado, commit acotado, checkpoint y compactación disponible. No se declara terminado con pruebas o commit requeridos pendientes; no se incluye trabajo ajeno.
4. `/learn` y `/compact` se usan solo si el entorno los ofrece y permite invocarlos. Hay aprendizaje local y reanudación por archivos como alternativa; no se promete ejecutar comandos de interfaz desde shell.
5. Gate exige referencias de semilla y artefactos de continuidad en proyectos. Pruebas del contrato fallan primero para artefactos ausentes y pasan tras implementación. Ejecutar suite, sintaxis Bash, gate y `git diff --check`.

## Verificación documental

Revisar: autoaprobación dentro/fuera de alcance; gate fallido; commit con cambios ajenos; aprendizaje sin slash command; compactación manual; reanudación de goal existente; cierre final con criterios pendientes. No equivale a ejecutar una entrevista ni entregar una app.

## Evidencia de cierre y aprendizaje

Implementada. Fase roja: suite con 9 comprobaciones anteriores correctas y 4 nuevas fallidas por aceptar ausencia de catálogo, plantilla del prompt, prompt generado y aprendizaje. Fase verde: 13 correctas, 0 fallidas. Sintaxis Bash y gate semilla: salida 0. La revisión staged detectó una línea vacía final en ADR 0001, aceptado e inmutable desde Seed 001; se conserva. Revisión de whitespace con solo ese criterio desactivado (`git -c core.whitespace=-blank-at-eof,blank-at-eol,space-before-tab diff --cached --check`): salida 0.

Revisión documental: delegación permite autoaceptar dentro del alcance y exige consulta fuera de él; gate/commit fallidos impiden cierre; staging excluye trabajo ajeno; aprendizaje funciona por archivos sin `/learn`; compactación manual conserva checkpoint; goal existente se retoma sin reemplazar otra; criterios finales pendientes impiden declarar app completa. No se ejecutó una entrevista ni se generó una app. El gate comprueba presencia de documentos, no su contenido.

Aprendizaje de esta sesión: una instrucción de slash command no demuestra capacidad de ejecutarlo. Las fuentes oficiales documentan `/compact` y goals; no se estableció `/learn` como comando universal. Se conserva aprendizaje local y modalidad manual como alternativas verificables. El checkpoint usa referencia a spec/commit para evitar el ciclo de intentar incluir el hash del propio commit en sus archivos.

Commit previsto: `feat(seed): incorporar prompt maestro y continuidad por specs`, consolidando Seeds 001–004. Checkpoint del molde en STATE; permanece `phase=seed`.
