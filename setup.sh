#!/bin/bash

        ##############################
        ### Control de temperatura ###
        ### mediante ventiladores  ###
        ###      INSTALADOR        ###
        ###       @panapunk        ###
        ##############################

# Nombre aplicación
APP_NAME="fanControl"

### eleminar archivo de servicio demonio
if [ $1 ] && [ $1 = "remove_daemon"]; then
    sudo update-rc.d -f $APP_NAME remove
    exit 0
fi

# Obtenemos la ruta del programa
if [ $1 ] && [ -d $1 ]; then
    MY_HOME=$1
else
    MY_HOME=$(echo "$HOME")
fi
printf "Mi home es: $MY_HOME \n"

## rutas para la app
RUTA_CONFIG="$MY_HOME/.$APP_NAME"

# para das para mostraar en isntalación
SLEEP_DEFAULT=2

# creamos la carpeta para los archivos necesarios
if [ ! -d $RUTA_CONFIG ]; then
    printf "Creamos la ruta para los archivos del programa: $RUTA_CONFIG \n"
    mkdir $RUTA_CONFIG
    sleep $SLEEP_DEFAULT
fi

# creamos archivos necesarios
printf "Creamos archivos de configuaración: \n"
# printf "Creamos el archivo de la ruta del usuario: $RUTA_CONFIG/MY_HOME \n"
# echo $MY_HOME > $RUTA_CONFIG/MY_HOME
printf "Creamos archivo: $RUTA_CONFIG/ESTADO \n"
echo 1 > $RUTA_CONFIG/ESTADO
printf "Creamos archivo: $RUTA_CONFIG/MODO \n"
echo 1 > $RUTA_CONFIG/MODO
printf "Creamos archivo: $RUTA_CONFIG/LOG \n"
echo "" > $RUTA_CONFIG/LOG
printf "Creamos archivo: $RUTA_CONFIG/PAUSE \n"
echo 60 > $RUTA_CONFIG/PAUSE
printf "Creamos archivo: $RUTA_CONFIG/PAUSE_LONG \n"
echo 300 > $RUTA_CONFIG/PAUSE_LONG
printf "Creamos archivo: $RUTA_CONFIG/PAUSE_SORT \n"
echo $SLEEP_DEFAULT > $RUTA_CONFIG/PAUSE_SORT
printf "Creamos archivo: $RUTA_CONFIG/TEMPERATURA_MIN \n"
echo 68 > $RUTA_CONFIG/TEMPERATURA_MIN
printf "Creamos archivo: $RUTA_CONFIG/TEMPERATURA_MAX \n"
echo 72 > $RUTA_CONFIG/TEMPERATURA_MAX
sleep $SLEEP_DEFAULT

# copiamos script fanControl
if [ -f "$APP_NAME.sh" ]; then
    printf "Copiamos script de control: $RUTA_CONFIG/$APP_NAME.sh \n"
    cp $APP_NAME.sh $RUTA_CONFIG/$APP_NAME.sh
fi

# copiamos demonio fanControl
if [ -f "$APP_NAME" ]; then

    cp $APP_NAME $APP_NAME"This"

    if [ -f $APP_NAME"This" ]; then
        sed -i "s|/root|$MY_HOME|g" $APP_NAME"This"
    fi
    printf "Copiamos demonio de control: /etc/init.d/$APP_NAME \n"
    sudo cp $APP_NAME"This" /etc/init.d/$APP_NAME

    printf "Damos permisos y añadimos demonio al inicio del sistema: /etc/init.d/$APP_NAME \n"
    # Hacemos el fichero ejecutable:
    sudo chmod 755 /etc/init.d/$APP_NAME
    # # activamos el arranque automático:
    sudo update-rc.d $APP_NAME defaults
    # # Comprobamos que todo se ejecuta correctamente:
    sudo /etc/init.d/$APP_NAME start

    ### eleminar archivo de servicio demonio
    #sudo update-rc.d -f $APP_NAME remove

    # Eliminar archivo $APP_NAME"This"
    rm -fr $APP_NAME"This"

fi

chmod +x -R $RUTA_CONFIG
sleep $SLEEP_DEFAULT

# Si se ha solicitado la limpieaza de los archivos de git
if [ $1 ]; then
    cd ..
    sudo rm -fr $APP_NAME
fi