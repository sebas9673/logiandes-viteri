# Revisión Well-Architected preliminar

Para evaluar la arquitectura inicial de LogiAndes se consideran cinco aspectos: fiabilidad, seguridad, rendimiento, costos y operación.

La revisión identifica los principales riesgos de la propuesta, su impacto y las mejoras necesarias. Los riesgos se clasifican como altos (HRI) o medios (MRI) y se relacionan con las siguientes etapas del proyecto.

## Fiabilidad

| ID | Hallazgo | Clasificación justificada | Mejora | Tarea |
| --- | --- | --- | --- | --- |
| F-01 | Una instancia de aplicación atiende portal, pedidos y rastreo. | HRI. Su fallo interrumpe todos esos recorridos. | Incorporar redundancia y probar la pérdida de una instancia bajo tráfico. | Tarea 2 |
| F-02 | PostgreSQL en RDS Single-AZ carece de réplica de espera. | HRI. Un fallo puede detener las escrituras y prolongar la recuperación de pedidos. | Evaluar replicación y medir recuperación y pérdida de datos. | Tarea 3 |
| F-03 | El protocolo de integración con Oracle WMS local sigue por definir. El impacto en pedidos depende de cómo se diseñe esa integración. | HRI. Si el alta exige confirmación síncrona, una falla del WMS o del enlace podría impedir completar pedidos y sincronizar despachos. | Definir el contrato de integración y probar la pérdida del enlace y la reconciliación posterior. | Pendiente |

## Seguridad

| ID | Hallazgo | Clasificación justificada | Mejora | Tarea |
| --- | --- | --- | --- | --- |
| S-01 | En el caso actual se utilizan credenciales compartidas. | HRI. Impiden atribuir accesos a datos personales y dificultan investigar incidentes. | Asignar credenciales individuales, limitar privilegios y comprobar el registro del 100 % de los accesos auditables definidos. | Pendiente |

## Eficiencia del rendimiento

| ID | Hallazgo | Clasificación justificada | Mejora | Tarea |
| --- | --- | --- | --- | --- |
| P-01 | La línea base aún no se ha probado a 3× la carga habitual. | HRI. En temporada alta se puede incumplir el SLO de seguimiento de un servicio utilizado por 120 clientes. | Ejecutar la prueba a 3× y medir la proporción de `GET /track` con HTTP 2xx en menos de 300 ms, junto con p95, p99 y errores. | Pendiente |

## Optimización de costos

| ID | Hallazgo | Clasificación justificada | Mejora | Tarea |
| --- | --- | --- | --- | --- |
| C-01 | Falta validar la estimación mensual de la propuesta. | MRI. Los picos, el volumen de datos y el tráfico pueden elevar el gasto respecto de la proyección. | Estimar el costo total para carga habitual y pico. Contrastar con USD 8.000 mensuales y con la referencia de USD 6,50 por cada 1.000 envíos. | Pendiente |

## Excelencia operativa

| ID | Hallazgo | Clasificación justificada | Mejora | Tarea |
| --- | --- | --- | --- | --- |
| O-01 | Aún falta evidencia de la configuración de respaldos y de los ejercicios de restauración. | HRI. Se desconoce cuánto tardaría en recuperarse la operación y qué datos podrían perderse. | Documentar configuración y procedimientos. Ejecutar una restauración y registrar RTO/RPO observados y datos reconciliados. | Pendiente |
| O-02 | La propuesta usa un solo trabajador para consumir las solicitudes de facturación. | MRI. Si falla, se detienen las autorizaciones y se acumulan solicitudes mientras la cola retiene los mensajes. | Medir la antigüedad de los mensajes y probar la reanudación del consumo y la gestión de duplicados. | Pendiente |
