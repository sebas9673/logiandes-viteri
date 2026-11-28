# Tarea 2 — Registro de implementación y evidencia

**Fecha de ejecución:** 27–28 noviembre 2026 (horas expresadas en UTC según salidas).  
**Ruta:** B — Proxmox VE 9.2.2 anidado en VMware Workstation.  
**Entorno IaC:** OpenTofu 1.13.10, bpg/proxmox 0.124.0.  
**Repositorio:** https://github.com/sebas9673/logiandes-viteri

## Infraestructura implementada

- `vmbr0` (acceso laboratorio, no Internet público): 192.168.204.0/24.
- `vmbr11` (App A): 10.0.11.0/24; App A 10.0.11.10:8080; LB 10.0.11.2; bastión 10.0.11.3.
- `vmbr12` (App B): 10.0.12.0/24; App B 10.0.12.10:8080; LB 10.0.12.2; bastión 10.0.12.3.
- `vmbr21`: 10.0.21.0/24 reservado para datos, sin invitado ni PostgreSQL.
- VMs: 210 (App A), 211 (App B), 212 (HAProxy), 213 (bastión); 1 vCPU, 1 GiB RAM, 6 GiB de disco cada una.

## Red y seguridad

- SSH por llave pública desde Windows al bastión, y ProxyJump a las aplicaciones.
- UFW App A: SSH 22 solo 10.0.11.3; HTTP 8080 solo 10.0.11.2; denegación entrante por defecto.
- UFW App B: SSH 22 solo 10.0.12.3; HTTP 8080 solo 10.0.12.2; denegación entrante por defecto.
- HAProxy 2.8 con roundrobin en puerto 80 hacia los puertos 8080, comprobación HTTP `GET /` cada 2 s, `fall 2`, `rise 2`.
- Pendiente verificar que el bastión limite SSH a una IP administradora `/32`, SSH root/contraseña denegados y ruta `/healthz` (la prueba usa `/`).

## Monitoreo y limitación del experimento

La fuente `docs/ha-evidence.csv` contiene 240 registros, entre **2026-11-28 02:10:31 y 02:15:18 UTC**. Totales: 238 respuestas HTTP 200, 2 errores, 52 respuestas APP_A y 186 APP_B. El éxito observado es 238/240 = **99,17 %**. Se observaron respuestas alternadas A/B tras activar UFW.

Separadamente, en Proxmox se registró un apagado de App A a las **01:05:19 UTC** y su reencendido a las **01:05:52 UTC**. No coinciden con la ventana del monitor; no se puede atribuir los 2 errores al apagado ni calcular con esas muestras el tiempo real de detección/reincorporación. Esto requiere una prueba sincronizada antes de afirmar el requisito completo.

## Reproducibilidad y seguridad del repositorio

Los recursos de red y cómputo se declararon con módulos `network` y `compute`, y se registraron en el estado remoto HTTP de GitLab. Sin embargo, para arrancar Ubuntu dentro de Proxmox virtualizado se ejecutó `qm set --kvm 0` y se convirtieron manualmente discos cuyo origen era una imagen QCOW2 etiquetada erróneamente `.raw`. HAProxy, servicios web y UFW se configuraron manualmente. El archivo `infra/envs/dev/cloud-init.yaml` incluido es solo un ejemplo de futura automatización, todavía no conectado al módulo de cómputo.

Faltan evidencias de `tofu fmt -check`, `tflint`, `gitleaks` sin hallazgos, prueba de bloqueo del estado y rechazo de autenticación SSH root/contraseña. El token personal de GitLab se reveló durante la sesión y debe rotarse antes de considerar cerrado el apartado de secretos.
