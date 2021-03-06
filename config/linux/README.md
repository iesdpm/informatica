﻿# Configuración de equipos con GNU/Linux basado en Debian

Para configurar los equipos con sistema operativo Linux basado en Debian (Ubuntu, LinuxMint, ...) ejecutamos un script que hace lo siguiente:

1. Crea el perfil de usuario **alumno** si no existe, con privilegios de administrador (sudoer).
2. Añade nuevos repositorios de paquetes al sistema.
3. Instala paquetes indicados desde los repositorios configurados en el sistema.
4. Descarga e instala directaente ficheros DEB.
5. Descarga y ejecuta instaladores o scripts de instalación de paquetes.
6. Programa el apagado del sistema a las 15:00 todos los días (al terminar las clases).
7. Actualiza el sistema completo.

> Los repositorios de paquetes, los paquetes a instalar y los scripts de instalación se configuran en el fichero [install.conf](install.conf).

## Requisitos

* Distribución basada en Debian.

## Ejecución del script

Ejecutar el siguiente comando desde la BASH:

```bash
wget -qO- https://raw.githubusercontent.com/iesdpm/informatica/master/config/linux/config-computer.sh | sudo bash
```
