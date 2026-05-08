# Como seguir despues de instalar el equipo

Para este punto ya estan las computadoras instaladas fisicamente y tenemos 
- Nro de Puesto
- MAC
- IP (DHCP o Static)

## Guardar MACs
Mientras estuvimos instalando fuimos relevando MACs en la planilla de equipos de laboratorio. 
Esas MACs van a **datos/MACs.txt**

## Guardar IPs
A dia de hoy (mayo 2026) las IPs del laboratorio no estan fijas en el servidor DHCP.
Alternativas:
1. Escaneo de la red con nmap
2. Hay un script que hace barridos en la tabla ARP del servidor y compara la lista de MACs anterior. 
3. Rezar

De cualquier forma hay que llenar el inventario de IPs.

Vamos a guardar todas las IPs en **datos/IPs.txt**. Pero el mas importante es **ansible/hosts.ini**
En **ansible/hosts.ini** vamos a hacer nuestro inventario de IPs. El invesntario se separa en planta baja y planta alta siguiendo el siguiente formato por linea: `Puesto_[NUMERO] ansible_host=[IP]`

Con esto listo ya se puede pasar a realizar tareas con ansible.
