# ADR 0003: Autonomía delegada y continuidad entre specs

- **Fecha:** 2026-10-06
- **Estado:** Aceptado por instrucción explícita del usuario sobre prompt maestro, autoaceptación, specs probadas y commiteadas, aprendizaje y compactación.
- **Aplica a:** Semilla y proyectos derivados que confirmen la delegación en Hito 0.
- **Relacionado:** ADR 0000 y ADR 0001. Aclara quién puede aceptar specs y decisiones dentro de una delegación; conserva su inmutabilidad. El número 0002 sigue reservado para arquitectura de producto.

## Contexto

El sellado de Hito 0 prepara la arquitectura, pero falta un contrato persistente para iniciar Hito 1 y continuar hacia una entrega completa sin depender del historial del chat. La autonomía debe permitir avanzar sin convertir decisiones del agente en autorización ilimitada.

## Decisión

1. La entrevista acuerda alcance de entrega, exclusiones, criterios finales, límites de autonomía, permisos de dependencias y política de commits. Tras confirmación genera `PROMPT-MAESTRO.md` como registro de inicio, personaliza `AGENTS.md` y crea `docs/learning.md`. El molde conserva solamente la plantilla del prompt.
2. Hito 0 queda sellado con el gate de inicialización superado; Hito 1 queda preparado. El usuario inicia la primera interacción invocando el prompt maestro. No se crea una goal por el solo hecho de generar archivos: la invocación incluye la solicitud explícita de crear o retomar la meta, si el entorno lo admite.
3. Con delegación confirmada, el agente puede redactar y autoaceptar specs que cubran criterios de la meta y decisiones técnicas dentro de límites documentados. Registra quién acepta, fuente de autoridad y justificación. Sin delegación, solicita aprobación. Un spec no autoriza por sí mismo cambiar arquitectura ni instalar dependencias.
4. Cambios de alcance de producto, stack, modelo de seguridad, costos, compromisos externos o ADR fuera de la delegación requieren confirmación humana. Registra decisiones arquitectónicas significativas en ADR nuevos; no crea un ADR por cada detalle ni modifica los aceptados. La numeración de ADR se rige por el [índice](README.md); los ADR del molde llegan hasta 0006 y el espacio 0007+ es del proyecto derivado.
5. Cada spec incluye implementación, verificaciones, actualización de estado y aprendizaje y, cuando esté autorizado, commit acotado con Conventional Commits. Revisa cambios preexistentes; no incorpora trabajo ajeno, no hace push, merge o despliegue por permiso de commit. El commit requerido pendiente impide declarar la spec cerrada.
6. Antes de compactar, guarda evidencia, pendientes y siguiente paso en el repositorio. El aprendizaje usa `docs/learning.md`; `/learn` puede complementarlo solo si existe en el entorno y su alcance está autorizado. `/compact` se invoca mediante la interfaz o herramienta disponible; si es manual se entrega el checkpoint al usuario. No se simulan comandos de chat con shell ni se afirma haberlos ejecutado sin evidencia.
7. La meta se completa solo cuando todos los criterios finales tienen evidencia satisfactoria y los commits requeridos están hechos. El gate de inicialización no certifica la app completa. Ante bloqueos conserva estado y solicita la información o autorización concreta que falta.

## Consecuencias

- Permite autonomía acotada y reanudación desde archivos después de compactar o cambiar de sesión.
- Requiere mantener sincronizados prompt de alcance, instrucciones operativas y estado. El progreso vive en STATE; el prompt no duplica el registro de tareas.
- Los comandos de sesión y las goals dependen del agente anfitrión. La continuidad documental funciona sin ellos.

## Verificación

Gate de semilla exige la plantilla del prompt y referencias operativas; gate de proyecto exige prompt y aprendizaje además de arquitectura y verificador. La comprobación estructural no valida su contenido ni la calidad final; las specs y el gate de proyecto aportan esa evidencia.
