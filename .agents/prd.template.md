# PRD — [Nombre del producto y primera entrega]

> Estado: Borrador | Aprobado. Registrar fecha y confirmación del usuario. Este archivo será `PRD.md`, fuente del alcance de producto; no duplicarlo en el prompt maestro.

> HITO0_PENDING: retirar este marcador solo después de resolver y confirmar los campos críticos.

## Problema y resultado

[Quién tiene qué problema y qué resultado observable necesita.]

## Usuarios y flujos principales

[Actores, flujos completos y ejemplos de negocio necesarios para entenderlos. Confirmar ejemplos críticos; los escenarios detallados viven en specs.]

## Alcance de entrega

- **Incluye:** [Capacidades necesarias para esta entrega finita]
- **Excluye / futuro:** [Lo que queda fuera, sin incorporarlo automáticamente a la meta]
- **Destino de aceptación:** [Ejecución local, staging o producción; autorización de despliegue separada]
- **Restricciones:** [Datos, presupuesto, privacidad, plazos o compatibilidad pertinentes]

## Requisitos y aceptación final

| ID | Requisito / comportamiento observable | Evidencia y resultado esperado |
|---|---|---|
| REQ-1 | [Flujo funcional completo] | [Prueba/comprobación reproducible y resultado] |
| CAL-1 | [Requisito de calidad aplicable, con umbral concreto] | [Medición/comprobación y resultado] |

Todos los requisitos de esta entrega son obligatorios; lo opcional va a «futuro». Incluye fallos relevantes y requisitos de seguridad, accesibilidad, persistencia u operación solo cuando apliquen. No aceptes «rápido», «seguro» o «app completa» como criterios sin evidencia definida. AGENTS contiene la DoD común; esta tabla define la aceptación final del producto.

## Supuestos y decisiones pendientes

- **Supuestos aceptados:** [Lista o ninguno]
- **Pendientes críticos:** [Resolver antes de aceptar alcance/arquitectura]
- **No aplicables:** [Áreas omitidas y motivo]

La arquitectura vive en ADR; autoridad e invocación en el prompt; pruebas y escenarios en specs; cobertura y progreso en STATE. Cambios al alcance o criterios requieren confirmación registrada y nuevas decisiones cuando afecten arquitectura. No alteres criterios para declarar éxito sobre una implementación diferente.
