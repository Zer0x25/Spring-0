# ADR 0006: Gobernanza verificable y proporcional en operación

- Fecha: 2026-10-09.
- Estado: aceptado por el usuario al indicar «aplica las mejoras» sobre la auditoría y sus propuestas concretas.
- Relacionados: ADR 0000, 0001, 0003, 0004 y 0005; implementación en Seed 008.
- Reemplaza parcialmente: precedencia conversacional de ADR 0000; fases de ADR 0001; separación obligatoria de permisos de commit y clasificación indiscriminada de integraciones de ADR 0005. Conserva ADR históricos, aceptación de producto, DoD y autorización explícita.

## Contexto

La auditoría reprodujo gates verdes con ADR vigente ausente, suite rota y documentos esenciales de proyecto ausentes. La inicialización carecía de fase intermedia y la entrevista imponía decisiones irrelevantes. La forma del registro añadía permisos y trabajo sin cambiar el riesgo real.

## Decisión

1. Los documentos del repo no prevalecen sobre instrucciones del anfitrión ni sobre nuevas instrucciones explícitas del usuario. Una nueva decisión autorizada se registra antes de implementarse; los ADR anteriores quedan intactos. AGENTS resume la política operativa vigente; ante contradicción material no resuelta se consulta, sin atribuir autoridad superior a un documento histórico.
2. El gate raíz reúne integridad, sintaxis y pruebas del contrato de gobernanza, y ejecuta el verificador del proyecto en initializing/project. Un validador interno separa estructura de orquestación; no sirve para cerrar unidades por sí solo. La CI invoca el mismo gate. La validación documental reconoce límites: contenido no vacío y campos pendientes no equivalen a aceptación semántica.
3. La transición explícita es seed → initializing → project. En initializing se conserva el bootstrap y se registra el paso pendiente; no se declara Hito 0 terminado. Solo después de verificar se sella y archiva. La recuperación conserva archivos ya personalizados, no repite decisiones ni pisa trabajo existente.
4. Lectura, auditoría y diagnóstico sin cambios persistentes no necesitan spec. Experimentos temporales declaran objetivo, límites y limpieza; implementar sus resultados exige la unidad correspondiente. Cambios a permisos, gates, CI de cierre y criterios de aceptación son sensibles y usan Tier 1 cuando alteran controles, no por un mero ajuste de texto.
5. Tier 1 acuerda el mecanismo de revisión adicional según el riesgo: humana o separada cuando afecte seguridad, datos o efectos irreversibles; verificaciones adversarias para controles deterministas. Una autoevaluación no se describe como revisión independiente. Las integraciones se clasifican por datos, credenciales, efectos, costos y reversibilidad, no solo por ser externas.
6. Tier 3 mantiene fuente, autoridad, alcance, criterio y evidencia en un registro compacto. Nuevas delegaciones pueden autorizar commits de ambas modalidades conjuntamente por alcance y riesgo. Una autorización antigua limitada a specs no se amplía. Push, merge, dependencias y despliegue siguen teniendo límites propios.
7. La entrevista omite persistencia cuando no hay datos duraderos y usa preguntas pertinentes. Checkpoint es el mecanismo común de continuidad; capacidades del anfitrión son opcionales y se documentan aparte. STATE conserva actividad y cierres recientes; se archiva historia con enlaces estables sin borrar evidencia ni reiniciar contadores.
8. La adopción en derivados es explícita y preserva personalizaciones mediante comparación de versiones y prueba en copia. Un piloto temporal prueba transiciones y desarrollo mínimo; no sustituye una entrevista real ni certifica todos los stacks.

## Consecuencias

Aumenta cobertura ejecutable y reduce trámites. El nuevo validador puede rechazar derivados incompletos antes tolerados: se ofrece guía de migración. No se introduce un motor de políticas ni clasificación automática. La evidencia y límites se registran en Seed 008.
