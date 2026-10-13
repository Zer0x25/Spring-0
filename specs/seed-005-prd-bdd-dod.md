# Spec: Seed 005 — PRD, BDD, DoD y progreso verificable

Estado: Aprobada por la petición de integrar lo analizado y hacer commit y push.

## Objetivo y límites

Integrar PRD como fuente de alcance, BDD dentro de specs y DoD común en AGENTS. Mantener prompt maestro, delegación, sellado, commits y continuidad; añadir detección de repetición improductiva sin debilitar aceptación ni declarar éxito. No iniciar una app ni una goal, instalar dependencias o alterar ADR aceptados.

## Archivos editables autorizados

- `specs/seed-005-prd-bdd-dod.md`
- `docs/adr/0004-producto-comportamiento-y-cierre.md`
- `.agents/prd.template.md`
- `.agents/master-prompt.template.md`
- `.agents/bootstrap.md`
- `AGENTS.md`
- `specs/templates/feature.template.md`
- `README.md`
- `STATE.md`
- `scripts/verify.sh`
- `scripts/tests/verify-contract.sh`

## Criterios y verificación

| ID | Criterio | Evidencia |
|---|---|---|
| CA-1 | Entrevista confirma PRD finito antes de arquitectura/sellado; prompt referencia requisitos sin duplicarlos | Revisión de bootstrap, PRD y prompt |
| CA-2 | Specs vinculan requisitos, escenarios BDD y pruebas; detalles técnicos usan verificaciones adecuadas sin exigir Gherkin/Cucumber | Revisión de plantilla con flujo, rechazo y cambio técnico |
| CA-3 | DoD exige aceptación, verificaciones y registros/commits autorizados; cierre de app requiere criterios finales y flujos integrados del PRD | Revisión de AGENTS y caso con verificación pendiente |
| CA-4 | Umbral configurable de intentos sin progreso (referencia: 3), hipótesis y evidencia, registro y escalación concreta; no cambia scope/DoD para obtener verde | Revisión documental de repetición, nueva evidencia y bloqueos |
| CA-5 | Gate rechaza semilla sin plantilla PRD y proyecto sin PRD; propaga resultado del verificador | Tests rojos antes del gate nuevo y suite verde |
| CA-6 | Estado semilla permanece; docs sin duplicación innecesaria; ADR anteriores intactos; commit acotado y push autorizado | Git diff/status, sintaxis Bash, gate y confirmación de remoto |

## DoD de mantenimiento

Revisión documental, suite `bash scripts/tests/verify-contract.sh`, sintaxis Bash, `./scripts/verify.sh`, `git diff --check`; commit y push a `origin/main` sin force. Evidencia de aprendizaje en esta spec, sin introducir una app o un registro de producto ficticio. Las pruebas estructurales no certifican el comportamiento de un agente ni una aplicación derivada.

## Evidencia de cierre técnico y aprendizaje

Implementada y verificada. Fase roja: 14 comprobaciones correctas y dos fallidas, porque el gate aceptaba la ausencia de plantilla PRD y de PRD de proyecto. Fase verde: 16 correctas y cero fallidas; incluye propagación exacta de salida 7 del verificador del proyecto. Sintaxis Bash, gate semilla y revisión de whitespace: salida 0.

Revisión documental: un flujo de negocio relaciona requisito, escenario y prueba; un rechazo conserva invariantes; un cambio técnico omite Gherkin artificial; una verificación obligatoria pendiente impide cierre. Tres intentos sin progreso (si ese umbral se confirma) escalan el problema; nueva evidencia habilita una hipótesis distinta, mientras compactar no borra el contador. PRD, DoD y permisos no se debilitan para obtener verde. Los ADR aceptados anteriores no fueron modificados.

Aprendizaje: fuente única de alcance y ejemplos dentro de specs permiten añadir PRD/BDD/DoD sin multiplicar documentos de comportamiento o duplicar criterios. Una prueba estructural no demuestra que el agente cumpla la política: queda pendiente una validación real con un proyecto derivado. No se ejecutó una entrevista ni una app.

Cierre Git autorizado: commit `feat(seed): integrar PRD BDD DoD y control de progreso` y push a `origin/main`. Confirmar éxito mediante hash local y remoto iguales; ante error, conservar cierre Git pendiente y comunicarlo. No ejecutar force push.
