# ADR-0003 Modelo de despliegue

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

Oracle WMS debe permanecer en la instalación local. Hay que revisar los intercambios de datos personales entre la instalación, la nube y terceros para identificar las obligaciones aplicables bajo la LOPDP.

## Alternativas

- Despliegue híbrido con la aplicación en AWS y Oracle WMS local. Conserva el WMS y requiere conectividad y reconciliación entre ambos entornos.
- Migración completa a la nube, incluido el WMS. Requiere evaluar compatibilidad, migración de datos y continuidad de los centros de distribución.

## Decisión

Se propone un despliegue híbrido con entrada HTTPS mediante AWS ALB y Oracle WMS en la instalación local. Queda por definir el protocolo y las características del enlace, incluida la decisión sobre un enlace privado. También quedan por definir la región AWS y las ubicaciones de los recursos, las copias y el tratamiento de datos.

## Consecuencias

- **Positivas.** Conserva la operación del WMS local durante la modernización y permite evaluar la capacidad de la aplicación en nube.
- **Negativas.** Según cómo se defina la integración, una falla del enlace o del WMS puede afectar la disponibilidad compuesta de pedidos. La residencia de datos y los flujos hacia proveedores y terceros requieren evaluación antes de seleccionar ubicaciones.

## Cumplimiento

- Documentar el protocolo, los datos intercambiados y las confirmaciones, así como el comportamiento ante una pérdida del enlace. Simular una interrupción del WMS para verificar qué etapas del flujo de pedidos pueden continuar y cómo se reconcilian los datos.
- Inventariar datos personales y ubicaciones previstas de almacenamiento, respaldo y procesamiento. Registrar la evaluación de residencia, transferencias, obligaciones aplicables bajo la LOPDP y controles antes de aprobar región y ubicaciones.
- Validar la estimación de costos de la configuración seleccionada frente al presupuesto mensual.
