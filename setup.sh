#!/bin/bash

        ##############################
        ### Control de temperatura ###
        ### mediante ventiladores  ###
        ###      INSTALADOR        ###
        ###       @panapunk        ###
        ##############################

# Nombre aplicación
APP_NAME="fanControl"

# Obtenemos la ruta del programa
if [ $1 ] and [ -d $1 ]; then
    MY_HOME=$1
fi

MY_HOME="/home/osmc"
printf "Mi home es: $MY_HOME \n"
