// LogiAndes — modelo C4 inicial.
// Se trata de una PROPUESTA, no de una infraestructura implementada.
// Fuente del caso: consigna UDLA, Figura 1 y material de sesiones 1/2.
// Elementos AWS/PHP propuestos; sujetar a ADR-0001, ADR-0002, ADR-0003,
// validación de costos, residencia de datos y comprobación de SLI/SLO/RTO/RPO.

workspace "LogiAndes — arquitectura inicial" "Propuesta híbrida para el proyecto integrador UDLA" {
    !identifiers hierarchical

    model {
        cliente = person "Cliente corporativo" "Crea pedidos y consulta el estado de los envíos."
        conductor = person "Conductor" "Registra ubicaciones GPS y confirma entregas."
        operador = person "Operador de despacho" "Gestiona despachos y rutas."

        sri = softwareSystem "SRI — Facturación electrónica" "Servicio externo de emisión y autorización tributaria."
        pasarela = softwareSystem "Pasarela de pagos" "Proveedor externo de procesamiento de pagos."
        mapas = softwareSystem "Proveedor de mapas y geocodificación" "Servicio externo de mapas y rutas."
        wms = softwareSystem "Oracle WMS local" "Sistema de gestión de almacenes en la instalación local de LogiAndes."

        logiandes = softwareSystem "Plataforma logística LogiAndes" "Recepción de pedidos, rastreo, despachos y facturación." {
            tags "Plataforma"
            ingreso = container "Entrada HTTPS" "Balanceador gestionado que dirige el tráfico HTTPS a la instancia de aplicación." "AWS Application Load Balancer (propuesto)" {
                tags "Infraestructura,Gestionado"
            }
            aplicacion = container "Aplicación logística" "Monolito modular: portal, API de pedidos, seguimiento y recepción GPS/entregas; una instancia sin redundancia (SPOF)." "PHP / Laravel (propuesto)" {
                tags "Aplicacion,SPOF"
            }
            pedidos = container "Base transaccional" "Servicio gestionado que persiste pedidos y datos transaccionales en una sola zona, sin réplica de espera (SPOF)." "Amazon RDS PostgreSQL Single-AZ (propuesto)" {
                tags "Database,Gestionado,SPOF"
            }
            rastreo = container "Almacén de rastreo" "Almacena posiciones GPS y eventos de entrega." "Amazon DynamoDB (propuesto)" {
                tags "Database,Gestionado"
            }
            documentos = container "Documentos y objetos" "Guarda comprobantes electrónicos y documentos operativos." "Amazon S3 con versionado (propuesto)" {
                tags "Database,Gestionado"
            }
            cola = container "Cola de facturación" "Retiene de forma durable solicitudes de facturación mientras el SRI está lento o indisponible." "Amazon SQS (propuesto)" {
                tags "Cola,Gestionado"
            }
            worker = container "Procesador de facturación" "Consume la cola, solicita autorizaciones y guarda los resultados; un trabajador sin redundancia (SPOF)." "PHP / Laravel Queue Worker (propuesto)" {
                tags "Aplicacion,SPOF"
            }
            auditoria = container "Logs y auditoría" "Recopila registros de aplicación, seguridad e integración." "Amazon CloudWatch (propuesto)" {
                tags "Infraestructura,Gestionado"
            }
        }

        cliente -> logiandes.ingreso "Crea pedidos y consulta estados" "HTTPS"
        conductor -> logiandes.ingreso "Reporta ubicación y confirma entregas" "HTTPS (MQTT por validar)"
        operador -> logiandes.ingreso "Administra despachos" "HTTPS"
        logiandes.ingreso -> logiandes.aplicacion "Distribuye solicitudes" "HTTPS"

        logiandes.aplicacion -> logiandes.pedidos "Lee y escribe pedidos" "SQL/TLS"
        logiandes.aplicacion -> logiandes.rastreo "Registra ubicaciones y entregas" "HTTPS/SDK"
        logiandes.aplicacion -> logiandes.documentos "Guarda documentos operativos" "HTTPS/SDK"
        logiandes.aplicacion -> logiandes.cola "Encola facturas de manera durable" "HTTPS/SDK"
        logiandes.cola -> logiandes.worker "Entrega mensajes pendientes" "HTTPS/SDK"
        logiandes.worker -> sri "Solicita emisión y consulta autorizaciones de forma asíncrona" "HTTPS"
        logiandes.worker -> logiandes.documentos "Guarda comprobantes y resultados" "HTTPS/SDK"
        logiandes.aplicacion -> wms "Sincroniza información operativa de almacén" "Protocolo de WMS por definir; enlace privado propuesto"
        logiandes.aplicacion -> pasarela "Procesa cobros" "HTTPS"
        logiandes.aplicacion -> mapas "Consulta mapas, geocodificación y rutas" "HTTPS"
        logiandes.aplicacion -> logiandes.auditoria "Registra eventos y métricas" "HTTPS/SDK"
    }

    views {
        systemContext logiandes "LogiAndes_Contexto" {
            include *
            autoLayout tb
        }
        container logiandes "LogiAndes_Contenedores" {
            include *
            autoLayout tb
        }
        styles {
            element "Element" {
                shape roundedbox
                background #EEEEEE
                color #333333
                stroke #424242
            }
            element "Person" {
                shape roundedbox
                background #E0EEF4
                color #333333
                stroke #16749A
            }
            element "Software System" {
                background #EEEEEE
                color #333333
                stroke #424242
            }
            element "Plataforma" {
                background #8E1C32
                color #FFFFFF
                stroke #8E1C32
            }
            element "Aplicacion" {
                background #8E1C32
                color #FFFFFF
                stroke #8E1C32
            }
            element "Database" {
                shape cylinder
                background #E6F0E7
                color #333333
                stroke #547D61
            }
            element "Cola" {
                background #FFF0D9
                color #333333
                stroke #B87825
            }
            relationship "Relationship" {
                color #424242
                thickness 3
            }
        }
    }
}
