# Spec: Seed 003 — Elección de SQLite o PostgreSQL en entrevista

Estado: Aprobada por la petición del usuario de ofrecer siempre SQLite y PostgreSQL según el alcance de la app.

## Objetivo

En el bloque de persistencia de toda entrevista, presentar SQLite y PostgreSQL, recomendar según alcance y operación y confirmar la elección antes del scaffold. Mantener la posibilidad de marcar persistencia como no aplicable. Extiende ADR 0001 sin modificar registros aceptados.

## Archivos editables autorizados

- `specs/seed-003-eleccion-base-datos.md`
- `.agents/bootstrap.md`
- `.agents/stack-presets.md`
- `README.md`
- `STATE.md`

## Criterios de aceptación

1. La entrevista presenta siempre ambas opciones en el bloque de persistencia y justifica una recomendación según escritores concurrentes, réplicas, consultas, durabilidad y operación. El número de usuarios no decide por sí solo.
2. VPS ofrece SQLite en volumen persistente o PostgreSQL. Cloudflare diferencia D1 de un archivo SQLite y señala PostgreSQL externo; Cloud Run no propone SQLite en el filesystem efímero como base duradera.
3. La elección se confirma y registra en ADR 0002 y el perfil antes de generar driver, migraciones, backups y pruebas. No se impone una base cuando no hace falta persistencia.
4. README y catálogo reflejan la misma regla. Las entrevistas mantienen hasta dos preguntas por turno.

## Verificación

Revisión documental con cuatro escenarios: app VPS de una instancia y escrituras moderadas; app con varias réplicas y escrituras concurrentes; despliegue Cloudflare/Cloud Run; app sin datos duraderos. Ejecutar `./scripts/verify.sh` y `git diff --check`. No cambia código ejecutable ni instala dependencias.

## Cierre

Revisión documental completada: VPS de una instancia permite recomendar SQLite tras comprobar contención y almacenamiento; varias réplicas/escritores favorecen PostgreSQL; Cloudflare y Cloud Run explican la modalidad y compatibilidad antes de elegir; sin datos duraderos se ofrecen ambas opciones y se registra `not_applicable`. No se ejecutaron entrevistas ni se generaron aplicaciones. Fuentes oficiales enlazadas en el catálogo. `./scripts/verify.sh` y `git diff --check`: salida 0.
