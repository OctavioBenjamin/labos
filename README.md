# Instrucciones para Setup Inicial de un Equipo.
1. Iniciar la instacion de Ubuntu 24.04
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
6. Iniciar el setup inicial del equipo.
```bash
sudo bash setup-inicial.sh
```
> [!WARNING]
> En Caso de fallar infostat en la instalacion, volver a lanzar el script.
7. Configurar los usuarios. Va a pedir que ingrese la password a mano.
```sh
sudo bash add-admin.sh
```
8. Reiniciar con `reboot`
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
* **Zoi Lypnik** - [ZoiLip](https://github.com/ZoiLyp)
