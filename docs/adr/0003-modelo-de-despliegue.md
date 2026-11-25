# ADR-0003 Modelo de despliegue

## Estado

Propuesto para la Tarea 1.

## Fecha

2026-11-25

## Contexto

La integración con Oracle WMS debe conservarse en la instalación local. Los intercambios con la nube y terceros incluyen flujos que deben evaluarse en materia de protección de datos personales bajo la LOPDP.

## Alternativas

- Despliegue híbrido con la aplicación en AWS y Oracle WMS local. Conserva el WMS y requiere conectividad y reconciliación entre ambos entornos.
- Migración completa a nube, incluido el WMS. Requiere evaluar compatibilidad, migración de datos y continuidad de los centros de distribución.

## Decisión

Proponer el despliegue híbrido con entrada HTTPS mediante AWS ALB y Oracle WMS en la instalación local. Definir el protocolo y las características del enlace, incluida la decisión sobre enlace privado. La región AWS y la ubicación de recursos, copias y tratamiento de datos quedan pendientes.

## Consecuencias

- **Positivas.** Conserva la operación del WMS local durante la modernización y permite evaluar la capacidad de la aplicación en nube.
- **Negativas.** El enlace y el WMS pueden afectar la disponibilidad compuesta de pedidos. La residencia de datos y los flujos hacia proveedores y terceros requieren evaluación antes de seleccionar ubicaciones.

## Cumplimiento

- Documentar protocolo, datos intercambiados, confirmaciones y comportamiento ante pérdida del enlace. Probar la interrupción del WMS y medir qué etapas de pedidos pueden continuar y cómo se reconcilian.
- Inventariar datos personales y ubicaciones previstas de almacenamiento, respaldo y procesamiento. Registrar la evaluación de residencia, transferencias, obligaciones aplicables bajo la LOPDP y controles antes de aprobar región y ubicaciones.
- Validar la estimación de costos de la configuración seleccionada frente al presupuesto mensual.
