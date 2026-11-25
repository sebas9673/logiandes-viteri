# ADR-0002 Estrategia de recuperación

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

La aplicación y el trabajador son únicos. RDS PostgreSQL opera en una sola zona y carece de réplica de espera. Una interrupción puede detener pedidos, escrituras o autorizaciones. El caso carece de una estrategia formal de recuperación.

## Alternativas

- Respaldar y restaurar la base, recuperar la aplicación y el trabajador y reanudar el procesamiento. El tiempo depende del respaldo recuperable y de los pasos de restauración y verificación.
- Incorporar instancias redundantes y una réplica de espera para los datos transaccionales. Reduce la dependencia de reconstruir componentes tras un fallo y añade costo y operación.

## Decisión

Proponer respaldo y restauración para la línea base Single-AZ, con recuperación de la aplicación y el trabajador y reanudación desde la cola persistente. Quedan pendientes la configuración y evidencia de respaldos y los ejercicios de recuperación. Abordar redundancia de aplicación en la Tarea 2 y replicación de datos en la Tarea 3.

## Consecuencias

- **Positivas.** Permite definir y ensayar un procedimiento de recuperación para la línea base.
- **Negativas.** La interrupción puede durar hasta que la restauración y las verificaciones terminen. Los objetivos transaccionales de RTO ≤ 30 minutos y RPO ≤ 1 minuto todavía carecen de evidencia en Single-AZ.

## Cumplimiento

- Documentar política y configuración de respaldo y ejecutar una restauración que verifique lecturas, escrituras y consistencia de pedidos.
- Registrar el tiempo desde el fallo hasta la recuperación verificada y la antigüedad del último punto consistente. Comparar con los objetivos y registrar cualquier brecha.
- Probar la reanudación del trabajador con mensajes pendientes y verificar que los reprocesos no dupliquen comprobantes.
