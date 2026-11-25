## Resumen y alcance

LogiAndes es una empresa logística ficticia que opera en Ecuador, Perú y Colombia. Gestiona 40.000 envíos diarios en 18 centros de distribución y enfrenta picos de hasta tres veces la demanda habitual durante Cyber Monday y Navidad. Sus 650 vehículos reportan su ubicación cada 15 segundos, lo que genera aproximadamente 43 eventos GPS por segundo. La operación se apoya en un portal, una API de seguimiento utilizada por 120 clientes de comercio electrónico, una aplicación de conductores, un WMS Oracle local y una integración de facturación electrónica con el SRI.

Durante el último Black Friday, LogiAndes sufrió una interrupción de cuatro horas. Actualmente carece de una estrategia formal de recuperación ante desastres, realiza despliegues manuales y utiliza credenciales compartidas. La modernización busca mantener disponible y ágil el seguimiento durante los picos, conservar los eventos de entrega confirmados y establecer una recuperación verificable. También busca reducir el trabajo manual de los despliegues y hacer atribuibles los accesos auditables para respaldar el cumplimiento de la LOPDP.

El diseño debe ajustarse a un presupuesto cloud máximo de USD 8.000 mensuales, a la capacidad operativa de un equipo de seis personas en TI y al compromiso contractual de disponibilidad de la API. Se propone una arquitectura híbrida cuyo alcance abarca el portal, la API, la aplicación de conductores, la recepción de eventos GPS y los flujos de entrega. El diseño debe conservar la integración con el WMS Oracle, que permanecerá local, y la facturación electrónica con el SRI.

## Requisitos

Las características 1, 2 y 3 son prioritarias.

### 1. Disponibilidad y latencia

- **Origen o necesidad del negocio.** Los 120 clientes de comercio electrónico dependen de la API para consultar el estado de sus envíos y tienen un compromiso contractual de disponibilidad.
- **Clasificación.** Explícita
- **Métrica.** Disponibilidad de la API y, para el SLO de seguimiento, porcentaje de solicitudes `GET /track` con respuesta 2xx en menos de 300 ms sobre el total de solicitudes a ese endpoint.
- **Objetivo.** Disponibilidad contractual de la API del 99,9 %. Para el SLO de seguimiento, ≥ 99,9 % de solicitudes `GET /track` con respuesta 2xx en menos de 300 ms en una ventana de 30 días. El umbral de 300 ms proviene de la solución de referencia del taller.
- **Justificación breve.** Una respuesta tardía o fallida impide que el cliente consulte el estado del envío en ese momento.

### 2. Elasticidad

- **Origen o necesidad del negocio.** Cyber Monday y Navidad elevan la demanda hasta tres veces el nivel habitual, con más consultas y operaciones de envío que atender.
- **Clasificación.** Explícita
- **Métrica.** Latencias p95 y p99 y tasa de errores durante una prueba a 3× la carga habitual. Medir también el porcentaje de solicitudes `GET /track` con respuesta 2xx en menos de 300 ms durante la prueba.
- **Objetivo.** Mantener el SLO de seguimiento sin degradación a 3× la carga habitual. Evaluar el cumplimiento en la prueba con la proporción de solicitudes que satisfacen conjuntamente el criterio de respuesta 2xx y el de latencia.
- **Justificación breve.** La prueba de carga permite comprobar si las consultas y operaciones de envío mantienen los niveles de servicio propuestos durante esos picos.

### 3. Fiabilidad de escrituras

- **Origen o necesidad del negocio.** Una entrega confirmada por un conductor debe quedar registrada para que el seguimiento refleje lo ocurrido y se pueda verificar la entrega.
- **Clasificación.** Implícita
- **Métrica.** Porcentaje de eventos de entrega confirmados que se almacenan correctamente.
- **Objetivo.** ≥ 99,99 %, según la referencia del profesor.
- **Justificación breve.** Si se pierde una confirmación, el seguimiento puede mostrar un estado incorrecto y se pierde evidencia de la entrega.

### 4. Recuperabilidad

- **Origen o necesidad del negocio.** La interrupción de cuatro horas en Black Friday y la ausencia de una estrategia formal de recuperación exigen limitar el tiempo fuera de servicio y la pérdida de registros de envíos.
- **Clasificación.** Implícita
- **Métrica.** Tiempo de recuperación y pérdida de datos medida en tiempo para la base transaccional.
- **Objetivo.** RTO ≤ 30 minutos y RPO ≤ 1 minuto para la base transaccional, como objetivos propuestos sujetos a validación y justificación posterior.
- **Justificación breve.** Medir ambos objetivos permite evaluar cuánto se interrumpe la operación y cuántos registros recientes podrían requerir reconciliación.

### 5. Seguridad y privacidad

- **Origen o necesidad del negocio.** Los flujos de seguimiento y entrega incluyen datos personales sujetos a la LOPDP. Las credenciales compartidas dificultan atribuir los accesos a una persona.
- **Clasificación.** Explícita
- **Métrica.** Cobertura del cifrado de datos personales y porcentaje de accesos definidos como auditables que quedan registrados.
- **Objetivo.** Cifrar los datos personales en tránsito y en reposo y registrar el 100 % de los accesos definidos como auditables.
- **Justificación breve.** El cifrado protege los datos personales y el registro de accesos permite revisar quién accedió a ellos.

### 6. Eficiencia de costos

- **Origen o necesidad del negocio.** El presupuesto mensual de nube fija el límite de gasto. El costo por envío permite evaluar cómo cambia ese gasto al variar el volumen logístico.
- **Clasificación.** Explícita
- **Métrica.** Gasto cloud mensual y costo cloud por cada 1.000 envíos.
- **Objetivo.** Máximo de USD 8.000 mensuales y objetivo de USD 6,50 por cada 1.000 envíos, según la referencia del profesor para el costo unitario.
- **Justificación breve.** El gasto mensual mide el cumplimiento del presupuesto y el costo unitario permite comparar meses con distintos volúmenes de envíos.

A razón de 40.000 envíos diarios durante 30 días, se proyectan 1.200.000 envíos. El costo de referencia de USD 6,50 por cada 1.000 envíos equivale a USD 7.800 para ese volumen, siempre que el indicador incluya todos los costos cloud pertinentes. Los picos pueden alterar la proyección al variar el volumen y el consumo de recursos.

## Objetivos de servicio y recuperación

## Diagramas C4

## Revisión Well-Architected

## Decisiones arquitectónicas

## Conclusiones
