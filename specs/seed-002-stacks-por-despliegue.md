# Spec: Seed 002 — Recomendaciones de stack por despliegue

> Estado: Aprobada por la solicitud del usuario de incorporar stacks recomendados en la entrevista según VPS, Cloudflare o Google Cloud Run.

## Objetivo

Guiar la entrevista con un catálogo opcional de arquitecturas de referencia. Elegir según producto, equipo, operación y destino de despliegue; mantener un perfil personalizado para otras tecnologías. Es una extensión del perfil descrito por ADR 0001, sin modificar decisiones aceptadas ni inicializar una aplicación.

## Archivos editables autorizados

- `specs/seed-002-stacks-por-despliegue.md`
- `.agents/stack-presets.md` (nuevo)
- `.agents/bootstrap.md`
- `.agents/project-profile.conf`
- `README.md`
- `STATE.md`

## Criterios de aceptación

1. La entrevista consulta el catálogo tras conocer el producto y pregunta destino de despliegue y restricciones, manteniendo el límite de dos preguntas por turno. Cuando el destino sea desconocido, recomienda alternativas con razones y solicita confirmación.
2. Cada perfil VPS, Cloudflare y Cloud Run documenta base, componentes condicionales, compatibilidad, operación y verificaciones. Incluye un perfil personalizado; las superficies sin navegador no reciben un frontend por defecto.
3. Las recomendaciones se justifican por ajuste, soporte estable, experiencia del equipo y mantenimiento. Se consultan fuentes oficiales actuales antes de fijar versiones, capacidades, límites o precios. No se presenta popularidad ni bajo costo como hecho sin evidencia.
4. Cloudflare distingue Workers + Static Assets y Pages, selecciona D1 y KV por necesidad y advierte la consistencia eventual de KV. Cloud Run exige estado persistente externo, contrato del contenedor y presupuesto de conexiones. VPS exige dimensionamiento, backups y restauración.
5. La elección aceptada y sus desviaciones quedan en ADR 0002. El manifiesto incorpora `deployment_target` y `stack_preset` como metadatos adicionales, sin cambiar el contrato obligatorio del gate.
6. El bootstrap genera solo artefactos y comandos acordados, registra instalación o comprobaciones pendientes y distingue validación local de despliegue real.

## Verificación

Cambio documental y metadatos de semilla; no agrega comportamiento ejecutable. Revisar los criterios con cinco escenarios de entrevista: VPS limitado con web CRUD; Cloudflare con reserva que necesita consistencia; Cloud Run con API sin frontend; equipo Python con destino VPS; destino aún desconocido. Confirmar que cada caso identifica límites y decisiones pendientes antes de compilar.

Ejecutar `./scripts/verify.sh` y `git diff --check`. Estas comprobaciones validan integridad y formato de la semilla; no certifican las aplicaciones futuras ni un despliegue.

## Evidencia de cierre

Revisión documental del protocolo y catálogo el 2026-10-06; escenarios razonados, sin ejecutar entrevistas con usuarios ni generar aplicaciones:

| Escenario | Regla comprobada en los documentos |
|---|---|
| Web CRUD en VPS limitado | Dimensionar SO/app/base y pools; evaluar base externa o simplificación; acordar backups y restauración antes de cerrar |
| Reservas en Cloudflare | KV no sirve como autoridad de reservas; evaluar SQL y coordinación según invariantes, con compatibilidad pendiente hasta comprobarla |
| API en Cloud Run | Omitir frontend; contenedor con `PORT`, estado externo y presupuesto de conexiones |
| Equipo Python y VPS | Seleccionar `custom` o variante explícita; respetar conocimientos del equipo y definir comandos adecuados al runtime confirmado |
| Destino desconocido | Comparar destinos y restricciones; mantener elección pendiente hasta confirmar arquitectura |

Fuentes oficiales enlazadas en el catálogo revisadas para las capacidades utilizadas. Gate estructural `./scripts/verify.sh` y `git diff --check`: salida 0. El manifiesto conserva `phase=seed`; las nuevas claves son informativas y no cambian la lógica del verificador.
