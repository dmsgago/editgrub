#!/bin/bash
# Script en GNU/LINUX.
# Diego Martín Sánchez, 1ASIR.- IES Gonzalo Nazareno

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
	echo ""
	read -p "Introduce la ruta de la imagen [.png]: " -er rutaimagen

	# Comprueba que existe la imagen enviada por el usuario
	if [ -e $rutaimagen ]
	then
	    if [ -f $rutaimagen ]
	    then
		# Comprueba si el fichero es una imagen .png
		extension=$(echo ${rutaimagen##*.})
		if [ $extension = "png" ]
		then
		    # Comprueba si hay alguna imagen de fondo ya establecida
		    background=$(grep GRUB_BACKGROUND /etc/default/grub)
		    if [ -z $background ]
		    then
			convert -resize 640x $rutaimagen $rutaimagen
			echo -e "GRUB_BACKGROUND=\"$rutaimagen\"" >> /etc/default/grub
			echo "Imagen insertada."
			update-grub
		    else
                        # Elimina la antigua imagen, creando una copia de respaldo del fichero /etc/default/grub
			convert -resize 640x $rutaimagen $rutaimagen
			sed -i"~" '/GRUB_BACKGROUND/d' /etc/default/grub
			echo -e "GRUB_BACKGROUND=\"$rutaimagen\"" >> /etc/default/grub
			echo "Imagen insertada."
			update-grub
		    fi
		else
		    echo "El fichero $rutaimagen debe ser un fichero: .png"
		fi
	    else
		echo "$rutaimagen es un directorio, debe ser un fichero."
	    fi
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
