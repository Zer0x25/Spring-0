# ADR 0001: Núcleo de gobernanza neutral y perfiles de aplicación

- **Fecha:** 2026-10-06
- **Estado:** Aceptado por instrucción explícita del usuario: «haz la mejora».
- **Afecta a:** Hito 0, el protocolo de inicialización, las instrucciones de agentes, las plantillas SDD y el quality gate.
- **Aclara:** `docs/adr/0000-adopcion-gobernanza-agentica.md`.
- **Reemplaza:** Las prescripciones de stack, transporte y rutas de código de ADR 0000 cuando se interpreten como requisitos universales de la plantilla. ADR 0000 permanece intacto como registro histórico de adopción.

---

## 1. Contexto y Problema

Hito 0 se presenta como plantilla agnóstica para distintos proyectos, pero sus reglas y scaffolding asumían TypeScript, Node.js, Zod, HTTP, `src/core`, controladores, repositorios y comandos npm. Esas decisiones pueden ser apropiadas para un perfil de aplicación y ajenas a otros.

La experiencia de Medidores muestra que las reglas de calidad más útiles dependen del sistema: autorización y aislamiento de datos, ciclos de vida, integración resiliente, pruebas E2E y observabilidad se formalizaron cuando el proyecto encontró esas necesidades. La plantilla debe preservar el método que permitió fijarlas, sin hacer universales las tecnologías ni las reglas de ese dominio.

## 2. Decisión

1. **Núcleo neutral:** SDD, ADR append-only, alcance explícito, TDD adecuado a los criterios, secretos y verificación reproducible son principios comunes. No se exige lenguaje, runtime, framework, formato de contrato, transporte ni árbol de fuentes.
2. **Perfil elegido en Hito 0:** La entrevista registra el tipo y superficies de aplicación, stack y restricciones, junto con el método de verificación. Una decisión desconocida permanece pendiente o se registra como supuesto; no se inventa para completar el scaffold.
3. **Reglas condicionales:** Permisos, datos persistentes, contratos API, interfaz, integraciones, migraciones, observabilidad y requisitos operacionales se incorporan a la arquitectura y a cada spec cuando apliquen.
4. **Registro arquitectónico:** Este ADR ocupa `0001`; la arquitectura específica de cada aplicación se genera como `docs/adr/0002-arquitectura-base.md`. Los ADR aceptados no se editan. Un cambio se registra en un nuevo ADR que referencia o reemplaza decisiones anteriores.
5. **Verificación por fase:** `.agents/project-profile.conf` es el marcador explícito de fase y perfil. `scripts/verify.sh` valida la estructura de la semilla o delega a la verificación generada para el proyecto. No deduce el stack por la presencia de un archivo como `package.json`.
6. **Ejemplos tecnológicos:** El código de errores TypeScript y otros ejemplos se mantienen bajo un perfil opcional, fuera del scaffold neutral.

## 3. Reglas para Agentes de IA

- Antes de proponer arquitectura, consultar `STATE.md`, los ADR aplicables y la especificación activa.
- Distinguir principios comunes de reglas específicas del perfil; no copiar una decisión tecnológica de ejemplo sin que el usuario la haya elegido.
- No elevar supuestos o preferencias del agente a decisiones aceptadas. Enumerar alternativas y preguntar cuando una elección sea necesaria para avanzar.
- Mantener las specs neutrales en tecnología y hacer explícitas las secciones condicionales aplicables al alcance.
- Si una implementación requiere ampliar el alcance autorizado, actualizar primero la spec.

## 4. Consecuencias

### Positivas

- La plantilla se adapta a proyectos con distintas superficies y tecnologías.
- Los controles específicos se incorporan cuando hay una necesidad concreta y una decisión registrada.
- El gate distingue integridad de la semilla de calidad del proyecto generado.

### Negativas / Trade-offs

- La entrevista requiere más juicio contextual y el bootstrap puede generar scaffolding diferente según el perfil.
- Mantener el perfil y sus comandos de CI requiere una actualización explícita al modificar la arquitectura.

