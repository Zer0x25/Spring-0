# ADR técnico de system design de frontend — plantilla (Seed 013, V5.3)

> Guía reutilizable del contenido mínimo que debe tener el ADR de system design de frontend **antes de tocar UI** de una unidad. El agente lo escribe y lo presenta al humano (propone/valida); no se auto-aprueba. Se escribe una vez y los módulos siguientes (pagos, socios, clases…) lo siguen.
>
> Regla de oro: la lógica de negocio y la autorización viven SOLO en el backend. Este ADR define la lógica de *presentación/UX* del cliente, nunca reglas de negocio.

# ADR 00XX: System design de frontend — [módulo o plataforma]

> **Estado:** Propuesto | Aceptado por [humano, fecha]
> **Requiere:** el ADR de arquitectura base del derivado (separación apps/web, apps/api, contracts)
> **Habilita:** la implementación de UI de las unidades que referencia

## 1. Contexto y alcance

- **Qué superficie cubre:** [p. ej. panel de recepción, portal de socio, admin]
- **Qué módulos reutilizarán este diseño:** [pagos, socios, clases, …]
- **Restricciones del ADR base que se respetan:** autorización y reglas de negocio solo en backend; los contratos HTTP en `packages/contracts` se validan en el servidor.

## 2. Separación UI / lógica (obligatorio, explícito)

- **Lógica de negocio → SOLO backend.** Ninguna regla de negocio vive en un componente del cliente. [Listar las reglas relevantes al alcance y confirmar que están en la API.]
- **Autorización → SOLO backend.** El frontend oculta/deshabilita por UX, pero NUNCA decide permisos; el servidor re-valida siempre (los IDs del cliente no autorizan nada).
- **Lógica de presentación/UX → SÍ en el cliente, de este tipo:**
  - estado de vista (cargando, error, vacío, éxito),
  - navegación y guards de rol como UX (el back los re-valida),
  - validación de formularios como feedback inmediato (el back es la autoridad),
  - cache/estado de datos del servidor (p. ej. librería de data-fetching o estado local; decidir y justificar).
- **Qué NO se permite en el cliente:** decidir permisos, calcular totales/montos autoritativos, mutar estado financiero, confiar en datos sin re-validación del servidor.

## 3. Decisiones de diseño (cada una con alternativa descartada)

- **Estado / data-fetching:** [p. ej. estado local + fetch vs. librería de cache de servidor] — alternativa descartada y por qué.
- **Estructura de componentes:** [p. ej. componentes de presentación puros vs. contenedores con lógica de datos] — por qué.
- **Rendimiento:** [qué se mide, qué se optimiza ahora, qué se difiere — code-splitting, memoización, listas virtualizadas; sin optimización prematura].
- **Accesibilidad y formularios:** [enfoque de validación en cliente como UX; labels, foco, errores].

## 4. Rendimiento (explícito, sin sobreoptimizar)

- **Qué se mide:** [p. ej. tiempo de carga inicial del panel, tiempo de respuesta de listados grandes]
- **Qué se hace ahora:** [presupuesto concreto]
- **Qué se difiere a backlog:** [lista; no optimizar sin medición]

## 5. Verificación y contrato con el backend

- Cada pantalla se prueba contra los contratos de `packages/contracts` (tipos compartidos, sin divergencia front/back).
- Toda acción que toque datos/negocio pasa por la API; el front no es fuente de verdad.
- Criterio de aceptación de la UI: flujo end-to-end contra la API real (no datos mockeados) antes de cerrar la unidad.

## 6. Consecuencias

- **Positivas:** un solo patrón de frontend reutilizado por todos los módulos; sin reescritura al añadir pantallas.
- **Negativas / costos:** [p. ej. más disciplina para no filtrar lógica al cliente; costo de la librería de estado elegida].
- **Reversión:** [cómo cambiaría el enfoque si el piloto lo exige; costo estimado].
