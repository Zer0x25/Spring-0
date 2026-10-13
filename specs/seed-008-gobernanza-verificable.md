# Seed 008 — Gobernanza verificable y proporcional

- Estado: cerrada; implementada y verificada, cambios locales sin commit.
- Nivel: Tier 1; cambia controles de cierre, precedencia e inicialización.
- Autoridad: usuario, 2026-10-09, «aplica las mejoras», sobre la auditoría de este chat. Autoriza la propuesta concreta y su ADR; no autoriza commits, push, instalaciones ni despliegue.
- Fuente: auditoría de 46c519b; mantenimiento de semilla, sin PRD de producto.
- ADR: 0001, 0003, 0004, 0005 y 0006 (aclaración de la propuesta aceptada).

## Alcance y rutas autorizadas

Modificar AGENTS.md, STATE.md, README.md, .agents/bootstrap.md, .agents/master-prompt.template.md, .agents/prd.template.md, .agents/stack-presets.md, specs/templates/feature.template.md, scripts/verify.sh, scripts/tests/verify-contract.sh y .github/workflows/verify.yml. Crear esta spec, docs/adr/0006-gobernanza-verificable.md, scripts/verify-structure.sh, scripts/tests/bootstrap-pilot.sh, docs/agent-capabilities.md, docs/seed-upgrades.md y docs/history/seed-001-007.md. El piloto solo escribe en un directorio temporal y lo elimina al terminar.

Ampliación de rutas antes de editar: .agents/prd.template.md requiere marcador explícito para rechazar una copia no personalizada, consistente con CA-2.

Protegidos: ADR aceptados 0000–0005, specs cerradas, configuración Git, secretos, dependencias, ejemplos y perfiles tecnológicos no implicados. No se inicializa el molde maestro ni se crean recursos externos.

## Criterios y contrato

| ID | Criterio observable | Verificación |
|---|---|---|
| CA-1 | Gate raíz y CI ejecutan la misma sintaxis, integridad y suite de contrato; fallos propagan salida | Contrato: suite rota, sintaxis inválida, verificador exit 7 y marcador de ejecución |
| CA-2 | Documentos esenciales no vacíos por fase, ADR 0005/0006 obligatorios; perfil inequívoco y placeholders críticos rechazados | Casos de ausencia, vacío, espacios, duplicados, fase desconocida y plantilla sin personalizar |
| CA-3 | Transición seed → initializing → project conserva bootstrap y checkpoint ante interrupción; sellado posterior a gate satisfactorio | Piloto temporal de fallo, recuperación, sellado y reanudación |
| CA-4 | Precedencia explícita, cambios de controles sensibles, diagnóstico sin spec y revisión Tier 1 acordada | Revisión documental cruzada AGENTS/ADR/bootstrap/plantillas |
| CA-5 | Registro ligero compacto; permisos por alcance/riesgo; omitir persistencia irrelevante; capacidades opcionales en una referencia | Revisión documental; no ampliar permisos existentes |
| CA-6 | Migración preserva personalizaciones; STATE activo separado de historial | Guía de adopción y archivo enlazado; historial conservado |
| CA-7 | Piloto ejecuta una CLI mínima con prueba roja/verde, corrección y reanudación desde evidencia | scripts/tests/bootstrap-pilot.sh; distinguir simulación determinista de entrevista real con usuario |

Invariantes: sin recursión del gate en tests; fixtures aislados; no aceptar evidencia ausente; no reducir pruebas del proyecto; no evaluar semántica de negocio por presencia de documentos. El verificador estructural es interno y no sustituye el gate raíz. Los placeholders se reconocen mediante marcadores explícitos y campos conocidos, no rechazando cualquier enlace Markdown. La plantilla de specs conserva campos reutilizables.

## Verificación y DoD

AGENTS sección 9. Primero ejecutar regresiones contra el gate anterior y registrar fallos esperados. Después ejecutar ./scripts/verify.sh, git diff --check, revisar alcance e integridad de ADR anteriores. Revisión adicional de esta unidad: contraste del diff con CA-1–CA-7 y pruebas adversarias reproducibles, sin presentarlo como revisión independiente. Para futuros proyectos, acordar revisión humana/separada según riesgo; ninguna delegación se amplía automáticamente.

## Evidencia y checkpoint

### Evidencia — 2026-10-09

- Fase roja: `bash scripts/tests/verify-contract.sh` contra el gate previo: 38 pasaron, 35 fallaron. Los fallos mostraron ausencia de ejecución de suites, documentos vacíos/ausentes, `phase=seed=project` aceptado, espacios en perfil y fase intermedia inexistente; algunos casos exigieron también diagnóstico con ruta exacta. No todos eran comportamientos previamente aceptados: había diferencias deliberadas de mensaje.
- Primera fase verde: 73/73. Revisión adversaria adicional detectó tres campos críticos de autoridad/arquitectura sin completar que aún pasaban: 73 pasaron/3 fallaron. Se amplió la detección acotada y se conservaron los tres casos.
- CA-1/CA-2: `./scripts/verify.sh`, salida 0, **76 passed, 0 failed**. Sintaxis incluida para todos los scripts de gobernanza y verificador del proyecto. Se propagan códigos 42/43 de suites y 7 del verificador; se rechaza sintaxis inválida. CI y hook llaman al mismo gate; no se ejecutó GitHub Actions remoto.
- CA-3/CA-7: piloto temporal superado dentro del gate: inicialización incompleta rechazada, checkpoint conservado, interrupción después de archivar bootstrap recuperada, sellado posterior a verificación; CLI con rojo `MISSING_SALUDO`/verde, corrección de espacios con rojo `WHITESPACE_NAME`/verde, reanudación en shell nueva leyendo STATE y comportamiento final. Limpieza mediante trap; sin app ni dependencias instaladas en el molde.
- CA-4/CA-5: revisión cruzada AGENTS, ADR 0006, bootstrap, prompt y plantilla: precedencia clara; diagnóstico sin spec; modificaciones de controles Tier 1; revisión adicional por riesgo; registro de tres campos más cabecera; commits conjuntos solo si se autorizan expresamente; persistencia omitida si irrelevante. Capacidades opcionales concentradas en docs/agent-capabilities.md. ADR 0000–0005 comparados byte a byte con HEAD: intactos.
- CA-6: guía de actualización con base/destino, comparación en copia, colisiones de números ADR, personalizaciones, permisos y reversión. Historia de STATE conservada en docs/history/seed-001-007.md con enlaces relativos ajustados; snapshot activo reducido y sin reutilizar permisos antiguos.
- Revisión de 18 archivos del alcance: enlaces Markdown locales, whitespace de archivos nuevos/modificados y límites correctos; `git diff --check`, salida 0. No cambios de dependencias, configuración Git ni archivos protegidos.

### Límites y aprendizaje

El piloto ensaya un recorrido con decisiones simuladas: **dos interrupciones inducidas y cero consultas reales**. No mide duración ni fricción de una entrevista humana, no evalúa cumplimiento por un agente independiente y no certifica stacks alternativos ni el perfil offline-first. Esa validación real permanece como siguiente experimento de adopción, no como evidencia inventada de esta unidad.

Aprendizaje Seed 008: un gate estructural puede pasar con suite rota y documentos vacíos; separar estructura de orquestación permite probar fallos sin recursión. Las pruebas de contrato prueban señales observables y límites del verificador, no autoridad o calidad semántica de documentos. Aplicación futura: mantener entrada única, pruebas negativas y piloto aislado al cambiar controles.

Commit no requerido ni autorizado: cambios locales. STATE contiene cierre, límites y siguiente paso. Contador sin progreso: 0; sin bloqueo ni meta anfitrión creada. No se invocaron capacidades opcionales ni se escribieron memorias globales.


### Entrega Git y release — 2026-10-09

Autorización posterior al cierre técnico: usuario, «commit and push + realese tag v4?». Autoriza commit del alcance Seed 008, push a origin/main, tag anotado v4.0.0 y release de GitHub. La última release consultada es v2.0.0; v4.0.0 está libre. Esta entrega no reabre criterios técnicos ni modifica ADR aceptados. Referencia de commit: `feat(seed): reforzar gobernanza y validacion de Hito 0`. Verificar después del push igualdad de HEAD, main remoto y destino del tag; confirmar URL publicada. Si falla, conservar la entrega pendiente y no declarar publicación. Los resultados finales se informan en el chat para evitar un commit solo para registrar su propio hash.
