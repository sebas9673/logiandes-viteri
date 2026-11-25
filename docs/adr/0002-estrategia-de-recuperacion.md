# ADR-0002 Estrategia de recuperación

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

La línea base propone una instancia de aplicación, un trabajador y PostgreSQL en RDS Single-AZ sin réplica de espera. Una falla puede detener los pedidos, las escrituras o las autorizaciones. LogiAndes todavía no cuenta con una estrategia formal de recuperación.

## Alternativas

- Respaldar y restaurar la base, recuperar la aplicación y el trabajador y reanudar el procesamiento. El tiempo de recuperación depende de la disponibilidad del respaldo y de cuánto duren la restauración y las verificaciones.
- Incorporar instancias redundantes y una réplica de espera para los datos transaccionales. Reduce la necesidad de reconstruir componentes después de una falla. También aumenta el costo y el trabajo operativo.

## Decisión

La estrategia inicial propone restaurar la base Single-AZ desde un respaldo, recuperar la aplicación y el trabajador, y reanudar el consumo de la cola persistente. Queda por configurar los respaldos, documentar la evidencia y ejecutar los ejercicios de recuperación. La Tarea 2 aborda la redundancia de la aplicación y la Tarea 3, la replicación de datos.

## Consecuencias

- **Positivas.** Permite definir y ensayar un procedimiento de recuperación para la línea base.
- **Negativas.** La interrupción puede durar hasta que la restauración y las verificaciones terminen. Para la base Single-AZ propuesta, falta demostrar que se cumplen los objetivos transaccionales de RTO y RPO. Las pruebas permitirán determinar si hace falta mejorar la infraestructura.

## Cumplimiento

- Documentar política y configuración de respaldo y ejecutar una restauración que verifique lecturas, escrituras y consistencia de pedidos.
- Registrar el tiempo desde el fallo hasta la recuperación verificada y la antigüedad del último punto consistente. Comparar con los objetivos y registrar cualquier brecha.
- Probar la reanudación del trabajador con mensajes pendientes y verificar que los reprocesos no dupliquen comprobantes.
