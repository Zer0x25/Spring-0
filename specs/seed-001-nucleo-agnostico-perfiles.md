# Spec: Seed 001 — Núcleo agnóstico y perfiles de proyecto

> Estado: Aprobada por la instrucción del usuario «haz la mejora». Este cambio evoluciona la plantilla Hito 0; no inicializa una aplicación de negocio.

## 1. Objetivo y alcance

Fortalecer Hito 0 para que su núcleo de gobernanza no imponga dominio, lenguaje, runtime, framework, transporte, validador, estructura de carpetas ni proveedor de CI. Durante la entrevista, el usuario define las superficies de aplicación y el stack; el bootstrap genera los artefactos y verificaciones acordes a esas elecciones.

Se conserva el ADR aceptado `0000` como registro histórico. Un ADR nuevo aclara el alcance de sus principios de gobernanza y trata las decisiones tecnológicas allí ejemplificadas como dependientes del perfil. No se edita ni borra un ADR aceptado.

## 2. Archivos editables autorizados

- `specs/seed-001-nucleo-agnostico-perfiles.md`
- `AGENTS.md`
- `.agents/bootstrap.md`
- `.agents/project-profile.conf`
- `.agents/examples/node-typescript-api/src/core/errors.ts` (nuevo ejemplo opcional)
- `docs/adr/0001-perfiles-y-aplicabilidad.md` (nuevo)
- `docs/adr/0000-template.md`
- `README.md`
- `STATE.md`
- `.env.example`
- `.github/workflows/verify.yml`
- `.gitignore`
- `.githooks/pre-commit`
- `scripts/verify.sh`
- `scripts/install-hooks.sh` (nuevo)
- `scripts/tests/verify-contract.sh` (nuevo)
- `specs/templates/feature.template.md`
- `src/core/errors.ts` (eliminar tras moverlo al ejemplo opcional)
- `src/core/.gitkeep` (eliminar)
- `src/modules/.gitkeep` (eliminar)
- `tests/modules/.gitkeep` (eliminar)

No modificar otros archivos ni instalar dependencias.

## 3. Contrato de comportamiento

### CA-1 — Gobierno neutral

- Las reglas comunes cubren SDD, historial de ADR, alcance de cambios, TDD apropiado al proyecto, secretos y verificación reproducible.
- Ninguna regla común exige Zod, TypeScript, Node, HTTP, npm, controladores, repositorios, carpetas `src/` o errores de dominio de una clase concreta.
- Los ADR aceptados permanecen inmutables. Los cambios de decisión se documentan en un nuevo ADR que referencia el anterior y declara si lo reemplaza.
- Los ejemplos con tecnología se identifican como opcionales y pertenecientes a un perfil.

### CA-2 — Entrevista y perfil explícitos

- La entrevista sigue limitada a dos preguntas por turno, pero adapta las preguntas a respuestas incompletas y al tipo de aplicación.
- Puede registrar respuestas como confirmadas, pendientes, asumidas o no aplicables; el agente no convierte una suposición en una decisión aceptada.
- Antes de compilar, identifica problema, actores, flujos, datos/invariantes, superficies de aplicación, stack/restricciones, despliegue/operación y necesidades de seguridad/calidad cuando apliquen.
- Mantiene `.agents/project-profile.conf` como manifiesto no secreto con `phase`, tipo/superficies, stack y método de verificación.
- Las decisiones pendientes quedan explícitas en el ADR de arquitectura; el bootstrap no las inventa para completar un andamiaje.

### CA-3 — Artefactos generados por perfil

- El ADR de gobernanza de la plantilla queda en `docs/adr/0000`; el ADR de perfiles queda en `docs/adr/0001`; la arquitectura concreta de una aplicación inicializada se genera como `docs/adr/0002-arquitectura-base.md`.
- `specs/templates/feature.template.md` usa conceptos neutrales. Los bloques de contratos, permisos, persistencia, ciclo de vida, integraciones, interfaz, repetibilidad de pruebas y migraciones se marcan «cuando aplique».
- El bootstrap genera una plantilla de proyecto personalizada en `specs/templates/feature.md` y una verificación `scripts/verify-project.sh` que ejecuta los comandos acordes al perfil acordado.
- La CI se adapta al stack/plataforma seleccionados. El repo semilla no instala Node ni dependencias de aplicación.
- `src/core/errors.ts` es un ejemplo opcional Node/TypeScript, no un archivo ni requisito del núcleo de Hito 0.

### CA-4 — Fases de verificación explícitas

- `.agents/project-profile.conf` declara `phase=seed` o `phase=project`; `scripts/verify.sh` no infiere la fase por la presencia de `package.json`.
- En fase `seed`, el gate valida los documentos/artefactos requeridos para la semilla y devuelve código distinto de cero ante faltantes.
- En fase `project`, el gate exige y delega a `scripts/verify-project.sh`; informa un error claro si falta el manifiesto, la fase no es válida o no existe el verificador del proyecto.
- En fase `project`, cada campo requerido del perfil aparece exactamente una vez y tiene valor explícito; `not_applicable` permite señalar una dimensión irrelevante.
- Ninguna comprobación requerida oculta fallos con `|| true`.
- `scripts/tests/verify-contract.sh` prueba en directorios temporales: semilla válida, artefacto faltante, delegación de proyecto sin `package.json`, falta del verificador y fase inválida.

### CA-5 — Documentación y adopción

- README distingue lo que garantiza la semilla de lo que el bootstrap genera por perfil.
- `.env.example` no declara variables de Node, base de datos, JWT ni una política de validación específica.
- README indica cómo activar `.githooks`; `scripts/install-hooks.sh` configura `core.hooksPath` de forma local al clon.
- La instalación del hook se prueba en un repositorio Git temporal y no modifica la configuración local del repositorio maestro durante las pruebas.
- STATE deja claro que este cambio mejora la plantilla y que Hito 0 sigue pendiente de inicializar una aplicación.

## 4. Quality Gate de esta especificación

1. Ejecutar primero `bash scripts/tests/verify-contract.sh` y confirmar el fallo antes de implementar el nuevo contrato.
2. Ejecutar `bash -n` sobre los scripts Bash cambiados.
3. Ejecutar `./scripts/verify.sh` y confirmar salida 0 en la fase `seed`.
4. Revisar `git diff --check` y comprobar que solo cambiaron archivos autorizados.
