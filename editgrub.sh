#!/bin/bash

# Muestra la cabecera del script
echo $"
 ______ _____ _____ _______ _____ _____  _    _ ____  
|  ____|  __ \_   _|__   __/ ____|  __ \| |  | |  _ \ 
| |__  | |  | || |    | | | |  __| |__) | |  | | |_) |
|  __| | |  | || |    | | | | |_ |  _  /| |  | |  _ < 
| |____| |__| || |_   | | | |__| | | \ \| |__| | |_) |
|______|_____/_____|  |_|  \_____|_|  \_\\_____/|____/ 
                                                      
"

# Muestra el menú principal
echo -e "1. Cambiar la imagen de fondo del grub.\n2. Cambiar el tiempo de espera inicial.\n3. Cambiar la entrada marcada por defecto.\n"

# Pide al usuario que elija una de las opciones del menú
read -p "-- Elige una de las opciones del menú [1-3]: " opcion

# Filtra la opción elegida y realiza la operación
case $opcion
in
"1")
	# Solicita al usuario la ruta de la imagen
	read -p "\nIntroduce la ruta de la imagen: [.png]" rutaimagen

	# Comprueba que existe la imagen enviada por el usuario
	if [ -e $rutaimagen ]
		then
		# Operaciones
		echo "Operaciones."
	else
		echo "El fichero $rutaimagen no existe."
	fi
;;
"2")
	# Operación de la opción dos
;;
"3")
	# Operación de la opción tres
;;
"*")
	# Opción no válida
;;
esac
