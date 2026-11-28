# LogiAndes — Arquitectura de Soluciones en Nube (UDLA)

**Autor:** Ramiro Sebastián Viteri Tobar Subia  
**Repositorio del proyecto integrador:** [GitHub](https://github.com/sebas9673/logiandes-viteri)  
**Tarea 1:** Documento de arquitectura y evaluación Well-Architected.  
**Tarea 2:** Infraestructura base como código con alta disponibilidad — **Ruta B**, Proxmox VE 9.2.2 dentro de VMware Workstation.

## Estructura

- `docs/arquitectura.md`, `docs/revision-well-architected.md`, `docs/diagramas/`, `docs/adr/`: documentación y decisiones de la Tarea 1.
- `docs/ha-evidence.csv`: monitor HTTP real del laboratorio de Tarea 2 (240 solicitudes).
- `docs/registro-tarea2.md`: resultados verificados, limitaciones y pendientes del laboratorio.
- `docs/scripts/monitor-ha.sh`: código del monitor HTTP para futuras pruebas.
- `infra/modules/network/`: puentes privados `vmbr11`, `vmbr12`, `vmbr21`.
- `infra/modules/compute/`: módulo para cuatro VMs Ubuntu (2 apps, HAProxy y bastión).
- `infra/envs/dev/`: invocación de módulos, backend HTTP de GitLab y ejemplo de cloud-init.

## Entorno probado

La definición de OpenTofu 1.13.10, con el proveedor `bpg/proxmox` 0.124.0, desplegó cuatro VMs en el pool `logiandes` sobre un único nodo `pve`, con estado remoto configurado en GitLab. La red de acceso del laboratorio es `192.168.204.0/24`; no es una red pública de Internet.

| VM | ID | IP | Rol |
|---|---:|---|---|
| `logi-app-a` | 210 | `10.0.11.10` | HTTP de prueba, puerto 8080 |
| `logi-app-b` | 211 | `10.0.12.10` | HTTP de prueba, puerto 8080 |
| `logi-lb` | 212 | `192.168.204.20` | HAProxy 2.8, puerto 80 |
| `logi-bastion` | 213 | `192.168.204.21` | SSH, acceso a ambas redes de aplicación |

Las dos aplicaciones demostraron balanceo `roundrobin` y se activaron reglas UFW para SSH solo desde el bastión y HTTP solo desde HAProxy. Se comprobó el acceso SSH por llave mediante `ProxyJump`.

## Resultados y advertencias de reproducibilidad

El monitor registró **240 solicitudes, 238 HTTP 200 y 2 errores** entre **02:10:31 y 02:15:18 UTC del 28/11/2026**. Por separado, la detención de VM 210 ocurrió a las **01:05:19 UTC**, y su nuevo encendido a las **01:05:52 UTC**. Esas ventanas NO coinciden; el CSV no prueba el tiempo de detección ni permite atribuirle los dos errores al apagado. Véase `docs/registro-tarea2.md`.

**No se debe afirmar que este repositorio reconstruye toda la aplicación únicamente con `tofu apply`.** En el laboratorio se realizaron pasos manuales: se desactivó KVM por virtualización anidada (`qm set --kvm 0`), se corrigieron discos Ubuntu porque la imagen QCOW2 estaba etiquetada `.raw`, se instalaron servicios HTTP/HAProxy y se activó UFW. El archivo `cloud-init.yaml` incluido es un ejemplo aún no conectado al proveedor. Estos son límites pendientes de automatización.

**Seguridad:** no subas claves privadas, tokens o contraseñas. El token personal de GitLab compartido durante el laboratorio debe revocarse/rotarse. `backend.tf` no almacena credenciales.

## Validaciones por conservar

Se observó `tofu validate` correcto y un `tofu plan` sin cambios ni destrucciones de recursos previos durante el alta. Falta ejecutar y guardar `tofu fmt -check`, `tflint`, `gitleaks`, pruebas de SSH denegado y bloqueo concurrente del backend. También falta publicar/verificar la etiqueta `entregable-2`.

## Límites

Las dos apps están en redes privadas diferentes, pero comparten **el mismo host físico Proxmox y almacenamiento local**. Es tolerancia a pérdida de una instancia de aplicación, no alta disponibilidad ante caída del host. `vmbr21` es una reserva aislada para la futura etapa de datos, no hay PostgreSQL desplegado.
