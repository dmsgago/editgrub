#!/bin/bash
# Script en GNU/LINUX.
# Diego Martín Sánchez, 1ASIR.- IES Gonzalo Nazareno

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
	    if [ -e $rutaimagen ]
	    then
		if [ -f $rutaimagen ]
		then
                    # Comprueba que la ruta sea absoluta
		    tiporuta=$(echo ${rutaimagen:0:1})
		    if [ $tiporuta = "/" ]
		    then
                        # Comprueba si el fichero es una imagen .png
			extension=$(echo ${rutaimagen##*.})
			if [ $extension = "png" ]
			then		        
                            # Comprueba si hay alguna imagen de fondo ya establecida
			    background=$(grep GRUB_BACKGROUND /etc/default/grub)
			    if [ -z $background ]
			    then
			        # Escala la imagen para que tenga el tamaño necesario para que el grub la inserte de fondo
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
			    read -p "Pulsa INTRO para continuar..."
			fi
		    else
			echo "La ruta debe ser absoluta: $rutaimagen"
			read -p "Pulsa INTRO para continuar..."
		    fi
		else
		    echo "$rutaimagen es un directorio, debe ser un fichero."
		    read -p "Pulsa INTRO para continuar..."
		fi
	    else
		echo "El fichero $rutaimagen no existe."
		read -p "Pulsa INTRO para continuar..."
	    fi
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
		    sed -i"~" '/GRUB_DEFAULT/ cGRUB_DEFAULT='"$seleccion" /etc/default/grub
		    update-grub
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
	"*")
	    # Opción no válida
	    ;;
    esac
done