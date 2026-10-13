# ADR 0000: Adopción de Gobernanza Agéntica, SDD, ADRs y Quality Gates

- **Fecha:** 2026-10-03
- **Estado:** Aceptado
- **Afecta a:** Todo el repositorio y ciclos de vida de desarrollo con agentes autónomos
- **Nota de gobernanza:** la *precedencia* de este ADR quedó aclarada por ADR 0006 (los documentos del repo no prevalecen sobre el anfitrión ni el usuario) y su *neutralidad de stack* por ADR 0001 (el código TypeScript es ejemplo de perfil, no requisito universal). Ver [índice de ADR](README.md). Las secciones siguientes conservan la letra de la adopción original; léanse con esas aclaraciones.

---

## 1. Contexto y Problema
El desarrollo de software asistido por Modelos de Lenguaje (LLMs) y agentes autónomos presenta desafíos únicos de degradación arquitectónica:
- En prompts no estructurados, los agentes alucinan dependencias, alteran patrones de código existentes y asumen decisiones de diseño sin registro histórico.
- Sin contratos de frontera estrictos, las interfaces entre módulos se vuelven inconsistentes y difíciles de probar.
- Sin barreras deterministas, el agente asume erróneamente que una tarea está terminada sin verificar tipos ni cobertura real de pruebas.

Para resolver este problema, es imprescindible adoptar una metodología de gobernanza formal antes de escribir cualquier línea de código de producción.

---

## 2. Decisión
Se adopta formalmente la metodología de **Gobernanza Agéntica** compuesta por cuatro pilares inmutables:

1. **Spec-Driven Development (SDD):**
   - Ningún desarrollo de código de producción puede comenzar sin un archivo de especificación cerrado en `specs/feat-*.md`.
   - El humano define el alcance, contratos Zod, invariantes y criterios de aceptación (DoD). El agente implementa exclusivamente dentro de esos límites.

2. **Architecture Decision Records (ADRs):**
   - Toda decisión arquitectónica, selección de stack o cambio de paradigma queda documentada de forma inmutable en `docs/adr/`.
   - Los ADRs son registro histórico; **no prevalecen sobre instrucciones del anfitrión ni del usuario** (aclarado por ADR 0006; ver [índice](README.md)).

3. **Agentic Test-Driven Development (Agentic TDD):**
   - El agente debe escribir primero la suite de pruebas unitarias/integración contra los criterios de aceptación (Fase Roja).
   - Solo cuando los tests fallan válidamente, el agente escribe la implementación mínima necesaria en los archivos autorizados (Fase Verde).

4. **Deterministic Quality Gates:**
   - La entrega de cualquier tarea está supeditada a la ejecución exitosa de scripts deterministas (`./scripts/verify.sh`) con código de salida `0`.

---

## 3. Reglas Inmutables para Agentes de IA
- **Contratos Cerrados:** No edites archivos fuera de la lista de archivos autorizados en la especificación activa.
- **Invariantes Negativas:** Si un requerimiento prohíbe un comportamiento (ej. saldo negativo o persistencia en texto plano), debes crear pruebas unitarias que verifiquen el rechazo de ese comportamiento.
- **Errores de Dominio:** prohibido el uso de errores genéricos sin código de dominio. En un perfil TypeScript, los errores heredan de un tipo base (ej. `DomainError` en `src/core/errors.ts`) con códigos de dominio tipados; en otro stack, el mecanismo equivalente que defina su arquitectura (ADR 0001: ejemplo de perfil, no requisito universal).
- **Convención de Commits:** Apegarse estrictamente a Conventional Commits (`feat`, `fix`, `test`, `refactor`, `chore`).

---

## 4. Consecuencias

### Positivas
- Se elimina la degradación arquitectónica y la deuda técnica provocada por alucinaciones.
- Módulos desacoplados, altamente testeables y con tipado estricto de extremo a extremo.
- Historial transparente y reproducible de decisiones mediante ADRs y commits semánticos.

### Negativas / Trade-offs
- Requiere un tiempo inicial de diseño para redactar especificaciones antes de codificar.
- Menor tolerancia a soluciones improvisadas o atajos en el código.
