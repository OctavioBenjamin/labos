## Servidor

### Usuarios
- **informatica:** Es el usuario del departamento de informatica, con permisos de super usuario. Sirve para realizar mantenimiento y trabajo sobre todos los equipos.
    - Grupos: sudoers y psico
- **controlador:** Es el usuario destinado al personal de tecnologia educativo, esta programado para desplegar un menu intectativo y realizar ciertas acciones de forma limitada sobre los equipos, como las opciones de energia y las opciones de firewall.
    - Grupos: psico

### Grupos
- **psico:** es un grupo que se creo con el fin de que los usuarios *informatica* y *controlador* puedan interactuar y realizar tareas sobre algunos directorios.

## Equipos
Cuando hablamos de *equipos* nos referimos unicamente a las computadoras destinadas a examenes/clases.
### Usuarios
- **admin:** es el usuario para realizar tareas sobre cada equipo. El servidor se conecta mediante este usuario. La password solo pertenece al departamento de informatica. 
    - Grupos: sudoers
- **laboratorio:** es el usuario que utilizan los alumnos. No tiene permisos de administrador. Es el principal afectado cuando se activa el firewall del equipo. No tiene grupos.
