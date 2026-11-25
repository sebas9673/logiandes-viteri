# ADR-0001 Estilo arquitectónico

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

La plataforma debe atender pedidos, seguimiento y entregas, con un equipo de seis personas en TI. La autorización de comprobantes depende del SRI y debe ejecutarse fuera del recorrido de pedidos.

## Alternativas

- Monolito modular PHP/Laravel y un trabajador de facturación que se ejecuta por separado. Un código base y límites definidos entre módulos simplifican el despliegue y el diagnóstico.
- Microservicios por capacidad. Permitirían desplegar y escalar capacidades por separado, con más integraciones, despliegues y diagnóstico distribuido.

## Decisión

Proponer un monolito modular PHP/Laravel en una instancia y un Laravel Queue Worker independiente en ejecución para consumir Amazon SQS y consultar al SRI. El trabajador forma parte de la misma solución modular y comparte su ciclo de desarrollo.

## Consecuencias

- **Positivas.** Menos unidades que mantener para el equipo y procesamiento de facturas fuera del recorrido de pedidos.
- **Negativas.** Los módulos de la aplicación escalan como una unidad. La aplicación y el trabajador son puntos únicos de fallo. La confirmación de encolamiento requiere seguimiento posterior de la autorización.

## Cumplimiento

- Verificar que el modelo muestre una instancia de aplicación y un trabajador, con una cola persistente entre ambos y el SRI accesible desde el trabajador.
- Simular una caída del SRI y comprobar que se aceptan pedidos y se sirve la vista principal del portal. Restablecer el SRI y comprobar que el consumidor retoma los mensajes pendientes.
- Probar a 3× y registrar el SLI de seguimiento definido en el documento de arquitectura.
