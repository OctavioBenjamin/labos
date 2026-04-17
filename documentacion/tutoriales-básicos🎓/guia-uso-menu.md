# Guía de Uso: Menú de Gestión Centralizada 🛠️

El Menú de Gestión es la herramienta principal para controlar el laboratorio de forma masiva. Utiliza una interfaz visual simple en la terminal para que no sea necesario escribir comandos complejos.

## 🔑 Acceso al Menú

Para acceder al menú, primero debes conectarte al servidor mediante SSH. Si aún no tienes configurada tu conexión, sigue este tutorial:
👉 [Configurar Sesión SSH](./configurar-sesion-ssh.md)

Una vez conectado al servidor, el menú se puede iniciar con:
```bash
bash software/menu.sh
```
*(Nota: El usuario `controlador` suele tener este menú configurado para iniciar automáticamente al entrar).*

---

## 📋 Categorías del Menú

### 1. Firewall y Red 🌐
Desde aquí controlas qué pueden ver los alumnos en internet:
- **Activar Internet:** Abre el acceso total para el usuario `laboratorio`.
- **Desactivar Internet:** Restringe la navegación únicamente a los dominios permitidos (UNC) y la intranet.
- **Estado del Internet:** Muestra si el firewall está actualmente bloqueando o permitiendo el tráfico.

### 2. Energía ⚡
Permite gestionar el encendido y apagado de las máquinas:
- **Encender Aulas (WoL):** Envía un "paquete mágico" a través de la red para despertar a los equipos apagados.
- **Apagar Aulas:** Envía una orden de apagado seguro a todos los equipos encendidos.
- **Reiniciar Aulas:** (En desarrollo) Opción para reiniciar los equipos de forma remota.

### 3. Administración 📊
Herramientas de diagnóstico rápido:
- **Ver estado de equipos (Ping):** Escanea la red para mostrarte qué equipos están encendidos (✅ ONLINE) y cuáles apagados (❌ OFFLINE).

---

## 💡 Consejos de Uso
- **Navegación:** Usa las **flechas del teclado** para moverte, **TAB** para saltar entre botones (Aceptar/Cancelar) y **ENTER** para confirmar.
- **Paciencia:** Algunas acciones masivas (como apagar o escanear la red) pueden tardar unos segundos mientras se comunican con todos los equipos.
- **SSH:** Recuerda que para que las opciones de "Apagar" o "Firewall" funcionen, la conexión SSH entre el servidor y los equipos debe estar configurada correctamente.
