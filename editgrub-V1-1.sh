#!/bin/bash
# Grub editor, tested on Debian Jessie.
# Diego Martín Sánchez

# Funciones

img_existe()
{
    if [ -e $1 ]
    then
	echo 'Fichero existe. OK'
    else
	echo 'Error: La imagen '$1' no existe.'
	salir=1
    fi
}

img_typefile()
{
    if [ -f $1 ]
    then
	echo 'Es un fichero. OK'
    else
	echo 'Error: '$1' es un directorio, debe ser un fichero.'
	salir=1
    fi
}

ruta_absoluta()
{
    if [ $tiporuta = "/" ]
    then
	echo 'Ruta absoluta. OK'
    else
	echo 'Error: La ruta debe ser absoluta: '$1
	salir=1
    fi
}

img_formato()
{
    if [ $extension = "png" ]
    then
	echo 'Extension. OK'
    else
	echo 'Error: El formato de la imagen debe ser .png: '$1
	salir=1
    fi
}

img_fondo()
{
    if [ -z $background ]
    then
	insert_nueva_img $rutaimagen
    else
        reemplazar_img $rutaimagen
    fi
}

insert_nueva_img()
{
    # Escala la imagen para que tenga el tamaño necesario para que el grub la inserte de fondo
    convert -resize 640x $1 $1
    echo -e "GRUB_BACKGROUND=\"$1\"" >> /etc/default/grub
    echo "Imagen insertada."
    update-grub
}

reemplazar_img()
{
    # Elimina la antigua imagen, creando una copia de respaldo del fichero /etc/default/grub
    convert -resize 640x $1 $1
    sed -i"~" '/GRUB_BACKGROUND/d' /etc/default/grub
    echo -e "GRUB_BACKGROUND=\"$1\"" >> /etc/default/grub
    echo "Imagen insertada."
    update-grub
}

#Bucle que se ejecuta hasta que el usuario decide salir
salir="0"
while [ $salir -eq "0" ]
do
    # Muestra la cabecera del script
    clear
        echo $"                                                                                                                                                                                                                                   
 ______ _____ _____ _______ _____ _____  _    _ ____                                                                                                                                                                                          
|  ____|  __ \_   _|__   __/ ____|  __ \| |  | |  _ \                                                                                                                                                                                         
| |__  | |  | || |    | | | |  __| |__) | |  | | |_) |                                                                                                                                                                                        
|  __| | |  | || |    | | | | |_ |  _  /| |  | |  _ <                                                                                                                                                                                         
| |____| |__| || |_   | | | |__| | | \ \| |__| | |_) |                                                                                                                                                                                        
|______|_____/_____|  |_|  \_____|_|  \_\\_____/|____/                                                                                                                                                                                        
                                                                                                                                                                                                                                              
"

	# Expresión regular utilizada
	expresion="^[0-9]+$"

	# Muestra el menú principal
	echo -e "1. Cambiar la imagen de fondo del grub.\n2. Cambiar el tiempo de espera inicial.\n3. Cambiar la entrada marcada por defecto.\n4. Salir.\n"

	# Pide al usuario que elija una de las opciones del menú
	read -p "-- Elige una de las opciones del menú [1-4]: " opcion
	
	# Filtra la opción elegida y realiza la operación
	case $opcion
	in
	    "1")
		# Solicita al usuario la ruta de la imagen
		echo ""
		read -p "Introduce la ruta de la imagen [.png]: " -er rutaimagen

		# Comprueba que existe la imagen enviada por el usuario
		img_existe $rutaimagen

		# Comprueba que el fichero es regular, no es un directorio
		img_typefile $rutaimagen

		# Comprueba que la ruta sea absoluta
		tiporuta=$(echo ${rutaimagen:0:1})
		ruta_absoluta $tiporuta

		# Comprueba si el fichero es una imagen .png
		extension=$(echo ${rutaimagen##*.})
		img_formato $extension

		# Comprueba si hay alguna imagen de fondo ya establecida
		background=$(grep GRUB_BACKGROUND /etc/default/grub)
		img_fondo $background
		;;

	    "2")
		# Solicita al usuario que introduzca el tiempo de espera
		echo ""
		read -p "Introduce el tiempo de espera en segundos: " time
		# Comprueba que el tiempo introducido por el usuario es un número
		if [[ $time =~ $expresion ]]
		then
		    sed -i"~" '/GRUB_TIMEOUT/ cGRUB_TIMEOUT='"$time" /etc/default/grub
		    update-grub
		    read -p "Pulsa INTRO para continuar..."
		else
		    echo "Tiempo introducido no es un número entero: $time"
		    read -p "Pulsa INTRO para continuar..."
		fi
		;;
	    "3")
		# Guarda las entradas actuales en un fichero
		echo -e "\n--Entradas en el grub:"
		grep -e menuentry /boot/grub/grub.cfg | grep -oe "'.*'" > /var/tmp/entradas.txt
		# Muestra las entradas al usuario
		i="1"
		# Lee cada línea del fichero /var/tmp/entradas.txt
		while read entrada
		do
		    echo -e "\t$i. $entrada"
		    let i=$i+"1"
		done < /var/tmp/entradas.txt
		# Solicita al usuario que elija una entrada
		echo ""
		read -p "-- Elige una entrada del menú: " seleccion
		# Comprueba si el valor de la variable "seleccion" es un número
		if [[ $seleccion =~ $expresion ]]
		then
		    # Cuenta el número de entradas en el grub
		    numentradas=$(wc -l < /var/tmp/entradas.txt)
		    # Comprueba que la entrada seleccionada no sea mayor al numero de entradas disponibles
		    if [[ $seleccion -le $numentradas ]]
		    then
			let seleccion=$seleccion-"1"
			sed -i"~" '/GRUB_DEFAULT/ cGRUB_DEFAULT='"$seleccion" /etc/default/grub
			update-grub
			read -p "Pulsa INTRO para continuar..."
		    else
			echo "Entrada no disponible"
			read -p "Pulsa INTRO para continuar..."
		    fi
		else
		    echo "La entrada seleccionada no es un número entero: $seleccion"
		    read -p "Pulsa INTRO para continuar..."
		fi
		;;
	    "4")
		salir="1"
		;;
	    *)
		echo "Operación no permitida."
		read -p "Pulsa INTRO para continuar..."
		    ;;
	esac
done
