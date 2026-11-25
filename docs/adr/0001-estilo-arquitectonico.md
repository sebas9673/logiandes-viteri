# ADR-0001 Estilo arquitectónico

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

Un equipo de seis personas en TI debe operar los flujos de pedidos, seguimiento y entregas. La autorización de comprobantes depende del SRI y debe procesarse por separado para evitar que una falla del SRI bloquee los pedidos.

## Alternativas

- Monolito modular PHP/Laravel y un trabajador de facturación que se ejecuta por separado. Un código base y límites definidos entre módulos simplifican el despliegue y el diagnóstico.
- Microservicios por capacidad. Permitirían desplegar y escalar capacidades por separado, a costa de mantener más integraciones y despliegues y de diagnosticar fallos entre servicios.

## Decisión

Proponer un monolito modular PHP/Laravel en una instancia y un Laravel Queue Worker que se ejecuta en un proceso separado, lee los mensajes de Amazon SQS y consulta al SRI. El trabajador forma parte de la misma solución modular y comparte su ciclo de desarrollo.

## Consecuencias

- **Positivas.** El equipo mantiene menos unidades. El procesamiento de facturas queda fuera del flujo de pedidos.
- **Negativas.** Los módulos de la aplicación escalan como una unidad. La aplicación y el trabajador son puntos únicos de fallo. Guardar la solicitud en la cola confirma su recepción. El trabajador debe dar seguimiento al comprobante hasta recibir la respuesta de autorización del SRI.

## Cumplimiento

- Verificar que el modelo muestre una instancia de aplicación y un trabajador, con una cola persistente entre ambos y el SRI accesible desde el trabajador.
- Simular una caída del SRI y comprobar que se aceptan pedidos y se sirve la vista principal del portal. Restablecer el SRI y comprobar que el consumidor retoma los mensajes pendientes.
- Probar a 3× y registrar el SLI de seguimiento definido en el documento de arquitectura.
