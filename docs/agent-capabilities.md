# Capacidades opcionales del anfitrión

La continuidad obligatoria usa STATE y la unidad activa. No depende de comandos especiales.

- Goals: solo crear/retomar por solicitud explícita o invocación acordada del prompt maestro y si hay herramienta disponible. No reemplazar otra meta ni inventar presupuestos. Sin herramienta, registrar la meta en STATE.
- Aprendizaje: registrar hallazgos útiles en docs/learning.md o en la spec de mantenimiento. `/learn` solo complementa ese registro si existe y está autorizado; no habilita memorias globales. Si modifica el repo, revisar y aplicar la política de commits antes de compactar.
- Compactación: por necesidad de contexto o política confirmada. `/compact` solo mediante una capacidad real; si es manual, entregar checkpoint e indicarlo. No simular comandos del chat en shell ni declarar ejecuciones inexistentes.
- Estados de goals: respetar las reglas de las herramientas del anfitrión. Una interrupción, checkpoint o bloqueo local no autoriza cambiar el estado de una goal por inferencia.

No se exige compactar por unidad ni repetir aprendizaje. Tras reanudar, leer STATE, unidad y decisiones aplicables; conservar el contador de falta de progreso.
