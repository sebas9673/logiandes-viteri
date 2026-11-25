## Resumen y alcance

LogiAndes es una empresa logística ficticia que opera en Ecuador, Perú y Colombia. Gestiona 40.000 envíos diarios en 18 centros de distribución. Durante Cyber Monday y Navidad, la demanda llega a triplicarse. Sus 650 vehículos reportan su ubicación cada 15 segundos, lo que genera aproximadamente 43 eventos GPS por segundo. La operación se apoya en un portal, una API de seguimiento utilizada por 120 clientes de comercio electrónico, una aplicación de conductores, un WMS Oracle local y una integración de facturación electrónica con el SRI.

Durante el último Black Friday, LogiAndes sufrió una interrupción de cuatro horas. Hoy no cuenta con una estrategia formal de recuperación ante desastres. Los despliegues son manuales y se usan credenciales compartidas. La modernización busca mantener disponible y ágil el seguimiento durante los picos, conservar los eventos de entrega confirmados y comprobar que la operación pueda recuperarse después de una falla. El diseño también busca reducir el trabajo manual de los despliegues e identificar quién realizó cada acceso auditable para respaldar el cumplimiento de la LOPDP.

El diseño debe ajustarse a un presupuesto cloud máximo de USD 8.000 mensuales, a la capacidad operativa de un equipo de seis personas en TI y al compromiso contractual de disponibilidad de la API. La arquitectura híbrida propuesta abarca el portal, la API, la aplicación de conductores, la recepción de eventos GPS y los flujos de entrega. El diseño debe conservar la integración con el WMS Oracle, que permanecerá local, y la facturación electrónica con el SRI.

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
- **Objetivo.** Mantener el SLO de seguimiento sin degradación a 3× la carga habitual. En la prueba, comprobar qué proporción de solicitudes cumple ambos criterios: respuesta 2xx y latencia.
- **Justificación breve.** La prueba de carga permite comprobar si las consultas y operaciones de envío mantienen los niveles de servicio propuestos durante esos picos.

### 3. Fiabilidad de escrituras

- **Origen o necesidad del negocio.** Una entrega confirmada por un conductor debe quedar registrada para que el seguimiento refleje lo ocurrido y se pueda verificar la entrega.
- **Clasificación.** Implícita
- **Métrica.** Porcentaje de eventos de entrega confirmados que se almacenan correctamente.
- **Objetivo.** ≥ 99,99 %, según el valor de referencia.
- **Justificación breve.** Si se pierde una confirmación, el seguimiento puede mostrar un estado incorrecto y se pierde evidencia de la entrega.

### 4. Recuperabilidad

- **Origen o necesidad del negocio.** La interrupción de cuatro horas en Black Friday y la ausencia de una estrategia formal de recuperación exigen limitar el tiempo fuera de servicio y la pérdida de registros de envíos.
- **Clasificación.** Implícita
- **Métrica.** Tiempo de recuperación y pérdida de datos medida en tiempo para la base transaccional.
- **Objetivo.** RTO ≤ 30 minutos y RPO ≤ 1 minuto para la base transaccional. Estos objetivos de diseño requieren justificación y validación.
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
- **Objetivo.** Máximo de USD 8.000 mensuales y objetivo de USD 6,50 por cada 1.000 envíos, como referencia de costo unitario.
- **Justificación breve.** El gasto mensual mide el cumplimiento del presupuesto y el costo unitario permite comparar meses con distintos volúmenes de envíos.

Con 40.000 envíos diarios durante 30 días, se proyectan 1.200.000 envíos. El costo de referencia de USD 6,50 por cada 1.000 envíos equivale a USD 7.800 para ese volumen, siempre que el indicador incluya todos los costos cloud pertinentes. Los picos pueden alterar la proyección al variar el volumen y el consumo de recursos.

## Objetivos de servicio y recuperación

### Tabla 2. Objetivos por servicio y almacén

Cada ficha corresponde a una fila de la Tabla 2 del PDF. Las ventanas son móviles. Los SLO y límites de recuperación marcados como propuestos requieren validación. Para un SLI basado en conteos, el presupuesto es `⌊(1 − objetivo) × total elegible⌋`, con el objetivo expresado como fracción. Una ventana sin observaciones elegibles queda sin evaluación. El caso confirma una disponibilidad contractual de la API del 99,9 %. Quedan por confirmar la fórmula, la ventana y las exclusiones contractuales para calcular su presupuesto.

#### Pedidos

- **Servicio/almacén.** Recepción de pedidos.
- **SLI (fórmula).** Solicitudes válidas de alta que reciben confirmación después de guardar el pedido de forma persistente ÷ total de solicitudes válidas de alta × 100.
- **SLO y ventana.** ≥ 99,9 % en 30 días (propuesto).
- **Presupuesto de error.** Hasta 0,1 % de las solicitudes válidas en 30 días, equivalente a 1 por cada 1.000.
- **RTO y RPO.** Aplican los objetivos de la base transaccional a los datos de pedidos. La recuperación del flujo completo también depende del WMS si su confirmación es obligatoria.

#### Rastreo

- **Servicio/almacén.** Consulta de seguimiento `GET /track`.
- **SLI (fórmula).** Solicitudes `GET /track` con respuesta HTTP 2xx en menos de 300 ms ÷ total de solicitudes al endpoint × 100.
- **SLO y ventana.** ≥ 99,9 % en 30 días, según la referencia del taller.
- **Presupuesto de error.** Hasta 0,1 % de las solicitudes en 30 días, equivalente a 1 por cada 1.000. Contar una sola vez cada solicitud que incumpla uno o ambos criterios.
- **RTO y RPO.** Véase la ficha de datos de rastreo.

#### Facturación

- **Servicio/almacén.** Encolamiento de solicitudes y autorización electrónica por el SRI.
- **SLI (fórmula).** Recepción = solicitudes válidas confirmadas tras persistirlas en la cola ÷ total de solicitudes válidas recibidas × 100. Autorización = comprobantes de la cohorte de solicitudes aceptadas que el SRI autoriza dentro del plazo acordado ÷ total de comprobantes de esa cohorte cuyo plazo ya venció × 100.
- **SLO y ventana.** Recepción ≥ 99,9 % en 30 días (propuesto). Para la autorización se propone una ventana de 30 días por fecha de vencimiento. El porcentaje objetivo y el plazo desde el encolamiento quedan pendientes de validación. Los comprobantes pendientes o rechazados al vencer el plazo se registran como incumplimientos.
- **Presupuesto de error.** Para la recepción, el margen es de hasta 0,1 % de las solicitudes válidas en 30 días. Cuando se valide el objetivo de autorización, aplicar la fórmula de conteos a los comprobantes cuyo plazo venció en la ventana.
- **RTO y RPO.** Para los comprobantes almacenados, aplican los objetivos de la ficha de documentos/objetos. Para restablecer el flujo, también hay que recuperar la cola persistente y reanudar el consumo.

#### Portal

- **Servicio/almacén.** Acceso a la vista principal del portal.
- **SLI (fórmula).** Minutos con una comprobación sintética exitosa de carga de la vista principal ÷ minutos de la ventana × 100. Se propone una comprobación por minuto y registrar como fallidos los minutos sin resultado.
- **SLO y ventana.** ≥ 99,9 % en 30 días (propuesto).
- **Presupuesto de error.** Hasta 43,2 minutos por cada ventana de 43.200 minutos (30 días). Con medición por minutos completos, se admiten hasta 43 minutos fallidos.
- **RTO y RPO.** Los objetivos de los almacenes aplican según los datos que consulta cada función del portal.

#### Base transaccional

- **Servicio/almacén.** Registros de pedidos y demás escrituras transaccionales.
- **SLI (fórmula).** En una prueba de recuperación, RTO observado = instante en que se reanudan y verifican las lecturas y escrituras − inicio de la interrupción. RPO observado = inicio de la interrupción − instante del último punto de recuperación consistente.
- **SLO y ventana.** Evaluar en cada ejercicio de recuperación. Queda por definir y validar la frecuencia de los ejercicios.
- **Presupuesto de error.** Se evalúa cada ejercicio contra ambos límites de recuperación.
- **RTO y RPO.** RTO ≤ 30 minutos y RPO ≤ 1 minuto, objetivos propuestos. El RTO limita cuánto puede detenerse el registro de pedidos. El RPO acota el intervalo de transacciones confirmadas que puede requerir reconciliación con el WMS o con los clientes.

#### Datos de rastreo

- **Servicio/almacén.** Posiciones GPS y eventos de entrega.
- **SLI (fórmula).** Eventos de entrega confirmados y almacenados correctamente ÷ total de eventos de entrega confirmados × 100.
- **SLO y ventana.** ≥ 99,99 %, según el valor de referencia. Ventana de 30 días propuesta, pendiente de validación.
- **Presupuesto de error.** Hasta 0,01 % de los eventos de entrega confirmados, equivalente a 1 por cada 10.000.
- **RTO y RPO.** RTO ≤ 30 minutos y RPO ≤ 1 minuto, objetivos propuestos. El RTO limita cuánto tiempo pueden quedar desactualizadas las consultas. El RPO limita el intervalo de telemetría y confirmaciones que habría que recuperar o reconciliar. La prueba debe verificar también el objetivo de fiabilidad de las confirmaciones.

#### Documentos/objetos

- **Servicio/almacén.** Comprobantes electrónicos y otros documentos operativos almacenados.
- **SLI (fórmula).** En cada ejercicio, RTO observado = instante en que se verifica que los documentos recuperados pueden consultarse − inicio de la interrupción. RPO observado = inicio de la interrupción − instante del último punto de recuperación consistente de documentos y sus referencias.
- **SLO y ventana.** Evaluar en cada ejercicio de recuperación. Queda por definir y validar la frecuencia de los ejercicios.
- **Presupuesto de error.** Se evalúa cada ejercicio contra ambos límites de recuperación.
- **RTO y RPO.** RTO ≤ 4 horas y RPO ≤ 15 minutos, objetivos propuestos. El RTO limita el tiempo sin acceso a comprobantes y soportes operativos. El RPO acota el conjunto de documentos recientes que habría que recuperar y cotejar con su origen. Validar ambos límites con el flujo de facturación y los plazos aplicables.

### Dependencias para la disponibilidad compuesta

- **Pedidos.** Medir el recorrido que incluye la recepción y la escritura transaccional. Si el alta necesita confirmación síncrona del Oracle WMS local, tanto el WMS como la conectividad entre nube y centro local cuentan en la disponibilidad de pedidos. Si se confirma después, medir también la finalización del pedido y el retraso en la sincronización con el WMS.
- **Rastreo.** Medir el recorrido de la API hasta la lectura de datos. La recepción y persistencia de GPS y eventos de entrega afectan la vigencia de lo que devuelve la API. Una respuesta rápida puede contener datos desactualizados.
- **Facturación y portal.** El encolamiento depende de la cola persistente. La autorización depende además del consumidor, la conectividad con el SRI y la respuesta del SRI. Ante una caída del SRI, las solicitudes quedan pendientes y su procesamiento se reanuda al recuperarse la integración. Verificar que el incidente permita seguir recibiendo pedidos y usando la vista principal del portal. Medir aparte las funciones del portal que consultan pedidos o rastreo.
- **Comprobación.** Medir cada recorrido de extremo a extremo y correlacionar fallos de dependencias obligatorias con fallos observados por el usuario. Considerar fallos compartidos de conectividad y almacenamiento antes de estimar la disponibilidad a partir de componentes.

## Diagramas C4

### Nivel 1. Contexto

El cliente corporativo crea pedidos y consulta envíos, el conductor reporta GPS y confirma entregas, y el operador de despacho gestiona despachos y rutas. Los tres usan la plataforma LogiAndes. Sus integraciones incluyen Oracle WMS en la instalación local, el SRI para autorización tributaria, la pasarela de pagos para cobros y el proveedor de mapas para geocodificación y rutas. El protocolo de integración con el WMS queda pendiente.

### Nivel 2. Contenedores de la arquitectura inicial

La vista de contenedores describe el diseño propuesto para la Tarea 1.

- **Entrada y aplicación.** AWS ALB gestiona la entrada HTTPS y dirige las solicitudes a una sola instancia del monolito modular PHP/Laravel. La aplicación atiende el portal, pedidos, consultas de rastreo y recepción de GPS y entregas.
- **Datos.** Amazon RDS aloja PostgreSQL Single-AZ sin réplica de espera para pedidos y transacciones. Amazon DynamoDB almacena posiciones GPS y eventos de entrega. Amazon S3 con versionado guarda comprobantes y documentos operativos.
- **Facturación.** La aplicación persiste las solicitudes en Amazon SQS. Un único Laravel Queue Worker las consume, solicita autorización al SRI y guarda los resultados en S3. La recepción de pedidos y el uso general del portal deben continuar ante una caída del SRI. El encolamiento confirma la recepción para procesamiento y el SRI confirma la autorización después.
- **Observabilidad.** Amazon CloudWatch recoge registros y métricas de aplicación, seguridad e integración. ALB, RDS, DynamoDB, S3, SQS y CloudWatch son servicios gestionados.
- **Puntos únicos de fallo (SPOF).** Si falla la única instancia de aplicación, el portal y la API pueden quedar fuera de servicio. Una falla de la base Single-AZ puede detener las escrituras transaccionales. Si falla el único trabajador, se pueden acumular solicitudes en la cola y detener la emisión de comprobantes.

[Modelo Structurizr DSL](diagramas/workspace.dsl)

### Brechas por validar

Queda por validar la estimación de costos y comprobar los SLO, RTO y RPO. Para la base transaccional en RDS Single-AZ, falta demostrar un RTO ≤ 30 minutos y un RPO ≤ 1 minuto. La redundancia de aplicación se abordará en la Tarea 2 y la replicación de datos en la Tarea 3. Quedan pendientes las pruebas de restauración y reconciliación y la verificación del SLO de seguimiento bajo carga 3×.

## Revisión Well-Architected

## Decisiones arquitectónicas

## Conclusiones
