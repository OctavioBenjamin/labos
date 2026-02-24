# Instrucciones para Setup Inicial de un Equipo.
1. Iniciar la instalacion de Ubuntu 24.04
2. Crear el usuario **"laboratorio"** con password e indicar que no la pida al iniciar.
3. Una vez iniciado el sistema, instalar **git**
```sh
sudo apt install git
```
4. Clonar el repositorio
```sh
git clone https://github.com/octaviobenjamin/labos
```
5. Moverse a la carpeta
```sh
cd labos/
```
6. Iniciar el setup inicial del equipo. Pasando por parametro el nombre de usuario
```bash
sudo bash setup-inicial.sh [USUARIO]
```
> [!WARNING]
> En Caso de fallar infostat en la instalacion, volver a lanzar el script.
7. Configurar los usuarios. Va a pedir que ingrese la password a mano.
```sh
sudo bash add-admin.sh
```
8. Reiniciar con `reboot`

# Configuración de firewalls
1. Dirigirse a la carpeta labos/firewalls
2. Dentro hay un archivo que recibe una opción
```sh
sudo bash conexion.sh [on/off/status]
```
Luego de una primera ejecucución ya quedan establecidos los alias. 

`internet-on` - `internet-off` - `internet-status`

# Mantenimiento general
1. Clonar el repositorio
```sh
git clone https://github.com/octaviobenjamin/labos
```
2. Ejecutar el script correspondiente.
```sh
sudo bash mantenimiento-general.sh
```

## ✍️ Autores
* **Octavio Mendez** - [OctavioBenjamin](https://github.com/OctavioBenjamin)
* **Zoi Lypnik** - [ZoiLyp](https://github.com/ZoiLyp)
