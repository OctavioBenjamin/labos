# Setup basico para laboratorio

# NUEVOS PASOS

1. Entrar a admin
2. Darle permisos sudo a laboratorio
	```sh
	sudo bash sudo-add.sh
	```
3. Iniciar laboratorio
4. Instalar git si hace falta
	```sh
	sudo apt install git
	```
5. Descargar infostat en descargas
6. Clonar el repo
	```sh
	git clone https://github.com/octaviobenjamin/laboratorio-setup
	```
7. Ejectuar el nuevo script
	```sh
	sudo bash nuevo-instalador.sh
	```
8. Volver a admin y sacarle permisos sudo a laboratorio
	```sh
	sudo bash sudo-remove.sh
	```

### Recordar
1. Descargar infostat y Dejarlo en la carpeta Descargas
2. Nombrarlo como infostatinstaller_esp.exe
3. Con Alt + Ctrl + F3 (F2, F4... depende el caso) se puede cambiar entre admin y laboratorio con mas facilidad.

### Mantenimiento general
```sh
sudo sh mantenimiento-general.sh 
```
