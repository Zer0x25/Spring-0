# Spec: Seed 006 — Perfil opcional full stack offline-first

Estado: Aprobada por la aceptación del usuario de la recomendación de incluir una referencia corregida y opcional.

## Objetivo y límites

Derivar una referencia autocontenida del documento `Especificacion_Tecnica_Full-Stack_Offline-First_v2.0.md`, conservando el original externo. Mantener gobernanza agnóstica y seleccionar el perfil solo ante necesidad confirmada en PRD. El perfil es propuesto y pendiente de validación mediante implementación; no es un ADR aceptado de aplicación ni una solución certificada para producción.

## Archivos editables autorizados

- `specs/seed-006-perfil-offline-first.md`
- `docs/architecture-profiles/full-stack-offline-first.md`
- `.agents/stack-presets.md`
- `.agents/bootstrap.md`
- `README.md`
- `STATE.md`

## Criterios de aceptación

| ID | Criterio | Verificación |
|---|---|---|
| CA-1 | Perfil opcional, propuesto, autocontenido; ejemplos de asistencia no son requisitos universales | Revisión de estado, activación y ejemplos |
| CA-2 | Cursor usa publicación transaccional por ámbito; explica intercalado de commits, snapshot y retención | Razonar transacciones A/B, rollback, páginas y cursor expirado |
| CA-3 | Idempotencia, historial, cola dependiente, overlay local y recuperación externa tienen contratos explícitos | Razonar duplicado simultáneo, payload diferente, edición pendiente y pérdida local |
| CA-4 | Autorización por ámbito, revocación offline, HTTPS LAN y componentes opcionales están definidos | Revisión de selección y fronteras |
| CA-5 | Entrevista/catálogo/README enlazan el perfil sin imponer PostgreSQL, monorepo o sincronización a toda app | Revisión de enlaces y oferta SQLite/PostgreSQL conservada |
| CA-6 | Original y ADR aceptados intactos; semilla permanece seed; no se instala ni despliega | Hash original, Git diff, perfil y gate |

## Verificación y cierre

Cambio exclusivamente documental: revisar consistencia, enlaces y escenarios, ejecutar `./scripts/verify.sh` y `git diff --check`. No añadir pruebas artificiales de red/verde ni afirmar haber ejecutado el protocolo. Las pruebas de concurrencia, fallos y seguridad enumeradas en el perfil son trabajo requerido de una aplicación que lo adopte.

## Evidencia de cierre y aprendizaje

Implementada y verificada documentalmente el 2026-10-07. Se derivó una referencia autocontenida y más breve, en lugar de copiar las 1.159 líneas de la propuesta original. Catálogo, entrevista y README la enlazan bajo activación condicional.

Revisión de escenarios: A bloquea cabecera y B espera; rollback revierte contador/feed/dominio/recibo; snapshot usa una vista consistente y un límite H; retención caducada exige resync. Duplicados simultáneos se resuelven mediante clave única transaccional y hash; intenciones locales permanecen como overlay; un paquete en la misma IndexedDB no autoriza borrarla. Se precisan ámbitos, revocación, cambio de cuenta, HTTPS LAN y componentes opcionales. Son contratos propuestos razonados, no pruebas ejecutadas de una implementación.

`./scripts/verify.sh` y `git diff --check`: salida 0. Enlaces locales del README/catálogo comprobados; SHA-256 del original coincide con el registrado antes de editar. Ningún ADR aceptado ni script fue modificado; el manifiesto continúa en seed. No se ejecutaron tests de aplicación ni se instalaron dependencias.

Aprendizaje: orden de asignación de una secuencia no equivale a publicación confirmada; un backup dentro de la base eliminada no es preservación independiente. La referencia debe explicitar pruebas y costos de concurrencia antes de aceptarse en un proyecto.

Cambios locales de Seed 006; el commit/push y una nueva release no forman parte de este cierre documental. No modifica los snapshots publicados.
