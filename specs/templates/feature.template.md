# Spec: [Resultado verificable]

> Estado: Borrador | Aprobada | Implementada | Cerrada
> Base de alcance: [SHA completo de inicio de esta unidad]
> Nivel: Tier 2 — Estándar | Tier 1 — Riesgo alto | Tier 3 con spec si no se autoriza registro ligero; justificación: [efecto, contrato y riesgo]
> Requisitos: [IDs de PRD.md o mantenimiento de semilla]
> ADR aplicables: [Rutas o ninguno]
> Contexto (Notion): [URL o ID de la página de origen; vacío si no aplica]
> Trazabilidad: [SPEC:<id> por criterio que vincule con la database de decisiones de Notion; opcional]
> Sesión: [ruta del export de sesión en docs/sessions/ que dio origen a esta unidad; opcional — ritual de cierre de Seed 011]
> Decisión de diseño previa: [ADR técnico de system design de la capa si esta unidad toca una capa nueva (UI/frontend, offline); "ninguna" si la capa ya está cubierta — ver Seed 013]
> Aceptación: [Quién, fecha y autoridad; delegación y justificación si autoaceptada]

**Sobre el contexto de Notion:** `Contexto (Notion)` enlaza el *por qué* (decisiones de negocio, research) sin duplicarlo. Notion nunca es fuente de verdad ejecutable — el repo lo es; el gate no depende de Notion. `Trazabilidad` usa tags `SPEC:<id>` (ej. `SPEC:MVP-CUT-01`) que mapean a `specs/<id>.md`; un enlace a spec inexistente advierte, nunca bloquea (fail-safe).

Usa esta plantilla para Tier 2/1 según AGENTS y ADR 0005, o como alternativa si no se autoriza el registro ligero. En Tier 2 conserva secciones breves y pertinentes; Tier 1 detalla invariantes, riesgos y verificación. Tier 3 puede usar el registro ligero en STATE si está autorizado; no necesita generar esta spec. Un cambio de decisión significativa requiere además ADR, no sustituir la spec por él. No crees ni actualices PRD por cada tarea.

## 1. Objetivo y alcance

- **Resultado observable:** [Problema y capacidad que se entrega]
- **Incluye / excluye:** [Límites concretos]
- **Pendientes críticos / supuestos aceptados:** [Resolver los críticos antes de implementar]

## 2. Contratos e invariantes

[Entradas, salidas, datos y validaciones conforme al stack aceptado. Garantías, estados prohibidos y respuesta esperada.]

Añade solo controles pertinentes: permisos y alcance de datos; estados, atomicidad y concurrencia; integraciones y resiliencia; interfaz y accesibilidad; fixtures y restauración; migración, reversión y operación. No repitas decisiones del ADR ni rellenes secciones irrelevantes.

## 3. Comportamientos BDD y aceptación

Documenta ejemplos de negocio relevantes con Dado/Cuando/Entonces, incluyendo alternativas y rechazos según el riesgo. Pueden expresarse en nombres/comentarios de tests si los referencias por ruta/ID en la tabla y sus aserciones comprueban los resultados; no copies su texto completo aquí. No generes un escenario por cada detalle técnico ni exijas una librería BDD. Consulta ambigüedades críticas al usuario antes de autoaceptar.

```gherkin
Escenario BDD-1: [Comportamiento del requisito REQ-1]
  Dado [Estado inicial reproducible]
  Cuando [Acción]
  Entonces [Resultado observable]
  Y [Invariante que se conserva, si aplica]
```

| ID | Requisito PRD | Escenario / criterio | Prueba o verificación | Resultado esperado |
|---|---|---|---|---|
| CA-1 | REQ-1 | BDD-1 | [Prueba adecuada a la capa] | [Resultado concreto] |

Para cambios técnicos sin comportamiento de usuario, elimina el ejemplo Gherkin y usa criterios técnicos verificables. No copies los mismos escenarios a PRD y prompt. En mutaciones comprueba datos persistidos; en permisos cubre autorización y rechazo; en UI espera estados explícitos y evita pruebas que pasen si falta el control.

## 4. Archivos autorizados

- **Editables:** [Rutas exactas o patrón acotado; incluir spec, STATE y aprendizaje si se actualizan]
- **Protegidos:** [Rutas o límites]

Registra el SHA completo de `git rev-parse HEAD` al iniciar la unidad, antes de sus cambios. La base debe ser ancestro de HEAD y se conserva durante toda la unidad; cambiarla requiere una decisión autorizada que explique el trabajo previo. La base permite varias unidades consecutivas sin push. La revisión acumulada de la rama se hace aparte con `git diff origin/main...HEAD`; no amplíes las rutas de la unidad para incluir trabajo anterior.

Actualiza la spec antes de ampliar archivos; no cambia por sí misma arquitectura ni permisos de dependencias.

## 5. Verificación y DoD

- **DoD común:** AGENTS.md; añade aquí únicamente condiciones propias.
- **Comandos y suites de cierre:** [Exactos; `./scripts/verify.sh` y controles obligatorios de la DoD; TDD para comportamiento, revisión pertinente para documentación/presentación]
- **Chequeo rápido de iteración:** [Comando y cobertura confirmados / ninguno; no sustituye el cierre]
- **Revisión Tier 1:** [Modalidad acordada, responsable y evidencia; si no aplica, motivo. No confundir revisión propia con independiente]
- **Condiciones adicionales:** [Controles específicos o ninguno]

## 6. Cierre y continuidad

- **Evidencia:** [Una declaración por CA; verificaciones requeridas pendientes impiden cierre]

Para cerrar, añade por criterio una línea con el formato `- Evidencia CA-1: verificacion=comando o revisión concreta; resultado=pass; artefacto=ruta/relativa; sha256=huella`. Calcula la huella con `sha256sum ruta/relativa` después de verificar el resultado. Usa un script cuando el comando contenga `;`, delimitador del registro. El artefacto debe existir dentro del repo y representar lo probado (código, documento, informe u otra salida pertinente). El gate comprueba declaración y contenido vigente; no prueba la ejecución ni sustituye los controles de la DoD. Una mención del CA o una frase «pendiente» no es evidencia. No añadas declaraciones para verificaciones pendientes.

- **Aprendizaje:** [Hallazgo con evidencia en docs/learning.md o sin hallazgos nuevos; semilla puede registrarlo aquí]
- **Commit:** [Política, mensaje y resultado; requerido pendiente impide cierre]
- **Checkpoint en STATE:** [Cobertura del PRD, siguiente paso y bloqueos con contador/hipótesis si existen]
- **Continuidad:** checkpoint según AGENTS; capacidades opcionales en docs/agent-capabilities.md.
