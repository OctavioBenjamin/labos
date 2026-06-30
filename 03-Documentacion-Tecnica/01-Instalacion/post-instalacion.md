# Como seguir después de instalar el equipo

Para este punto ya están las computadoras instaladas físicamente y tenemos 
- Nro de Puesto
- MAC
- IP (DHCP o Static)

## Guardar MACs
Mientras estuvimos instalando fuimos relevando MACs en la planilla de equipos de laboratorio. 
Esas MACs deben estar guardadas en el servidor dentro del archivo: **datos/MACs.txt**

En **02-Software-Admin/ansible/hosts.ini** vamos a hacer nuestro inventario de IPs. El inventario se separa en planta baja y planta alta siguiendo el siguiente formato por linea: `Puesto_[NUMERO] ansible_host=[IP]`

Con esto listo ya se puede pasar a realizar tareas con ansible.
