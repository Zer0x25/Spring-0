# ADR [Número]: [Título de la Decisión Arquitectónica]

> **Sobre la numeración:** en un derivado, `0002` queda reservado para la arquitectura base del producto y **`0007` en adelante** para sus ADR reales. Los ADR `0000–0006` de la semilla son **decisiones del molde** (gobernanza del flujo agéntico) y sirven de **ejemplo/guía**; no son plantillas a copiar para el proyecto. Cada ADR del proyecto usa su propio número libre y su propia decisión.

- **Fecha:** YYYY-MM-DD
- **Estado:** Propuesto | Aceptado | Reemplazado | Obsoleto
- **Aplica a:** [Proyecto, perfil, módulo o superficie a los que afecta]
- **Relacionado / reemplaza:** [ADR relacionado o reemplazado, si aplica]

---

## 1. Contexto y Problema
[Describe la necesidad y el problema que se resolverá. Indica los límites y las alternativas consideradas, si las hay.]

---

## 2. Decisión
[Detalla la decisión técnica adoptada de manera concisa y rigurosa.]

1. **[Punto principal de decisión 1]:** [Decisión y su alcance].
2. **[Punto principal de decisión 2]:** [Alternativa elegida y restricciones].
3. **[Punto principal de decisión 3]:** [Qué queda fuera de esta decisión].

---

## 3. Aplicabilidad y Reglas para Agentes
[A qué perfiles y trabajos aplica. No repitas reglas generales de AGENTS.md.]

- **Obligaciones:** [Qué debe cumplir la implementación].
- **Prohibiciones:** [Qué debe rechazar o evitar].

---

## 4. Consecuencias

### Positivas
- [Beneficio 1: Ej. Coherencia en toda la base de código]
- [Beneficio 2: Ej. Eliminación de alucinaciones en modelos de IA]

### Negativas / Trade-offs
- [Costo o limitación asumida: Ej. Mayor rigidez inicial al definir esquemas antes de codificar]

### Verificación / Migración
- [Cómo se comprobará la decisión y cómo se migrará o revertirá, si aplica]
