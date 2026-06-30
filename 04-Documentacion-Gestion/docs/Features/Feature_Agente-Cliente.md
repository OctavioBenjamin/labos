# Agente Cliente — Monitoreo Pull-Based

## Problema
Zabbix u otras soluciones de monitoreo tradicionales requieren tener puertos abiertos 24/7 en los clientes o un agente siempre activo escuchando. Esto aumenta la superficie de ataque y el consumo de recursos en equipos que no necesitan monitoreo constante.

## Idea
Desarrollar un script liviano que se aloje en cada cliente (`/usr/local/bin/` o similar) y que:

- **No abra puertos** — El agente NO escucha conexiones entrantes.
- **Se active bajo demanda** — Vía ejecución remota por SSH desde el servidor. El servidor conecta por SSH al cliente, ejecuta el script, y este devuelve la información solicitada.
- **O genere logs periódicos** — Configurable vía cron en cada cliente para que cada N minutos ejecute el script y deje un log en `/var/log/labos/`. El servidor después recolecta esos logs cuando lo necesite (también por SSH).

## Información que podría reportar
- Estado de conectividad (latencia, paquetes perdidos)
- Espacio en disco
- Uso de RAM / swap
- Carga de CPU
- Temperatura (si el hardware lo soporta)
- Procesos activos del usuario `laboratorio`
- Último reinicio / uptime
- Versión del SO y paquetes clave instalados

## Formato de salida
JSON plano o pares `clave=valor` para facilitar el parseo desde el servidor.

## Próximos pasos
- Definir el output estándar del script
- Versión inicial en Bash
- Distribución vía Ansible
- Recolector del lado servidor que centralice los reportes
