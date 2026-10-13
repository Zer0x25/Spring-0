# ADR 0004: Producto, comportamientos y cierre verificable

- **Fecha:** 2026-10-06
- **Estado:** Aceptado por la petición del usuario de integrar PRD, BDD, DoD y controles de falta de progreso, con commit y push.
- **Aplica a:** Semilla y proyectos derivados.
- **Relacionado:** ADR 0001 y ADR 0003. Reemplaza en ADR 0003 la asignación del alcance al prompt maestro: el PRD pasa a ser su fuente; conserva delegación, sellado y continuidad.

## Contexto y alternativas

La semilla necesita una definición finita de producto y pruebas de sus comportamientos. Duplicar requisitos en PRD, prompt y specs aumenta contradicciones. Una autoaceptación sin evidencia externa al razonamiento del agente puede validar expectativas incorrectas y reintentar indefinidamente.

Se descarta crear documentos separados de BDD y DoD y obligar a usar Cucumber para todas las superficies. Se elige un PRD breve, escenarios dentro de specs y DoD común en AGENTS.

## Decisión

1. `PRD.md` contiene alcance, exclusiones, requisitos con IDs y evidencia final de entrega, confirmados por el usuario durante la entrevista antes de cerrar arquitectura. `PROMPT-MAESTRO.md` referencia el PRD y conserva invocación y delegación. El progreso vive en STATE, no en copias del PRD.
2. Las specs SDD relacionan requisito, escenario BDD y prueba. Los escenarios Dado/Cuando/Entonces expresan comportamientos relevantes, incluidos rechazos; cambios puramente técnicos usan verificaciones adecuadas sin Gherkin artificial. Cucumber no es una dependencia obligatoria.
3. AGENTS declara DoD común, adaptada al perfil en Hito 0. Cada spec agrega controles propios; el PRD define aceptación final del producto. Cerrar requiere evidencia y commits acordados, sin verificaciones obligatorias pendientes. El gate estructural no demuestra cumplimiento del producto.
4. La autoaceptación opera dentro de alcance y autoridad confirmados; no permite inventar comportamiento de negocio, debilitar pruebas, ampliar alcance o reducir DoD. Ambigüedades críticas requieren consulta. ADR nuevos se reservan para decisiones arquitectónicas significativas; los anteriores permanecen intactos. La numeración se rige por el [índice](README.md); 0002 sigue reservado para arquitectura de producto.
5. Una spec activa por unidad de trabajo. Cada intento de resolver un fallo registra hipótesis, acción y evidencia. La entrevista acuerda un umbral positivo de intentos consecutivos sin progreso, con referencia de tres; al alcanzarlo, se detienen los reintentos de ese problema, se conserva el checkpoint y se solicita una intervención concreta. Otra tarea solo avanza si es independiente y autorizada; no se abren specs para disfrazar el mismo bloqueo.
6. Progreso significa resolver un criterio, reducir de forma reproducible el fallo o eliminar una hipótesis con evidencia útil para una alternativa distinta. Repetir comandos, reformular documentos o modificar el criterio para pasar no cuenta. Evidencia nueva permite otro intento justificado; no autoriza reiniciar el contador por cambiar de sesión, compactar o renombrar la spec. La terminación técnica, falta de autorización y bloqueo se registran sin afirmar éxito ni cambiar por inferencia el estado de una goal del anfitrión.
7. Aprendizaje breve cuando exista un hallazgo; sin hallazgos se registra ese hecho sin inventarlos. Se preserva el checkpoint y la política acordada de compactación, sin ciclos repetidos de compactación/arranque sobre una misma spec cerrada. Al cumplir DoD se cierra; mejoras opcionales pasan a trabajo futuro confirmado.

## Consecuencias y verificación

La trazabilidad es `PRD → spec/escenario → prueba → evidencia`; el método continúa agnóstico. El costo documental depende del riesgo, sin formularios adicionales por cada técnica. Gate exige plantilla PRD en semilla y PRD en proyecto, con tests de rechazo y propagación de errores. Contenido, comportamiento del agente y calidad final requieren revisión y pruebas del proyecto; no quedan certificados por la presencia de archivos.
