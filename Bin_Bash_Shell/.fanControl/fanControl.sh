#!/bin/bash

        ##############################
        ### Control de temperatura ###
        ### mediante ventiladores  ###
        ###       @panapunk        ###
        ##############################

# Nombre aplicación
APP_NAME="fanControl"
# Obtenemos la ruta del programa
MY_HOME="/home/osmc"
# printf "Mi home es: $MY_HOME \n"

## rutas para la app
RUTA_CONFIG="$MY_HOME/.$APP_NAME"

## Functiones archivos
RESULT=0
# Create dir
setDir() {
  RESULT="No se ha recibido la variable ruta - setDir() \n"
  if [ $1 ]; then
    # fichero existe y es un directorio
    if [ ! -d $1 ]; then
      printf "setDir parámetro: $1 \n"
      printf "Creamos la ruta: $1 \n"
      mkdir $1
      # sleep 1
    fi
    if [ -d $1 ]; then
      RESULT=$1
    fi
  fi
}
# create file
setFile() {
  RESULT="No se ha recibido la variable ruta - setFile() \n"
  if [ $1 ]; then
    RESULT="No se ha recibido la variable valor - setFile() para dar valor a $1 \n"
    if [ $2 ]; then
      printf "setFile parámetro: $RUTA_CONFIG/$1 \n"
      printf "Creamos el archivo: $RUTA_CONFIG/$1 con valor $2 \n"
      echo $2 > $RUTA_CONFIG/$1
    fi
  fi
}
# Get valor file
getValorFile() {
  RESULT="No se ha recibido la variable nombre Archivo - getValorFile() \n"
  if [ $1 ]; then
    RESULT="No existe el fichero $1 - getValorFile() \n"
    if [ -f $RUTA_CONFIG/$1 ]; then
      RESULT=$(cat $RUTA_CONFIG/$1)
    else
      if [ $2 ]; then
        setFile $1 $2
      else
        setFile $1 1
      fi
    fi
  fi
}

# /**
# * Cabecera de variables
# */
setDir $RUTA_CONFIG

## Archivos de configuración
VALOR=1
getConfigValor() {
  RESULT="No se ha recibido la variable archivo - getConfigValor() \n"
  if [ $1 ]; then
    if [ $2 ]; then
      getValorFile $1 $2
    else
      getValorFile $1
    fi
    VALOR=$RESULT
  fi
}
getConfigValor ESTADO 1
printf "el ESTADO es: $VALOR \n"
getConfigValor MODO 1
printf "el MODO es: $VALOR \n"
getConfigValor LOG
printf "el LOG es: $VALOR \n"
getConfigValor PAUSE 10
printf "el PAUSE es: $VALOR \n"
TEMPERATURA_MIN=60
getConfigValor "TEMPERATURA_MIN" $TEMPERATURA_MIN
printf "el TEMPERATURA_MIN es: $VALOR \n"
TEMPERATURA_MAX=70
getConfigValor "TEMPERATURA_MAX" $TEMPERATURA_MAX
printf "el TEMPERATURA_MAX es: $VALOR \n"

# setFile PAUSE 300
# exit 0

ARCHIVO_LOG="$MY_HOME/LOG"

# RUTA base acceso a GPIO
BASE_GPIO_PATH="/sys/class/gpio"

# Asignamos variables a los estados
ON="0"
OFF="1"

# Asignamos variables a los GPIO que usaremos
# GPIO de salida
FAN_RPI=18
FAN_RPI_NOMBRE="Ventilador RPI"
FAN_RPI_TIMES=0
FAN_RPI_LAST_TEMP=0
FAN_RPI_LAST_DATE=0
FAN_BOX=13
FAN_BOX_NOMBRE="Ventilador BOX"
FAN_BOX_TIMES=0
FAN_BOX_LAST_TEMP=0
FAN_BOX_LAST_DATE=0
# GPIO de entrada
TEST_GPIO=17

# Variables para obtención de valores PWM
FACTOR_MULT_PWM=10
PWM_MAX=1000
PWM_MIN=0
# /**
# * FIN - Cabecera de variables
# */

# /**
# * Cabecera de Funciones
# */
ERROR_FUNCTION=''
setErrorNumberPin() {
  ERROR_FUNCTION='Error en función $1, no se ha recibido número de pin'
}
# Función HABILITAR pin, si no ha sido habilitado
exportPin() {
  if [ $1 ]; then
    if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
      echo "$1" > $BASE_GPIO_PATH/export
    fi
  else
    setErrorNumberPin 'exportPin()'
  fi
}
# Función DESHABILITAR pin, si no ha sido deshabilitado
unexportPin() {
  if [ $1 ]; then
    if [ -e $BASE_GPIO_PATH/gpio$1 ]; then
      echo "$1" > $BASE_GPIO_PATH/unexport
    fi
  else
    setErrorNumberPin 'unexportPin()'
  fi
}

# función para configurar dirección del pin (Default - Salida)
GPIO_ENTRADA='in'
GPIO_SALIDA='out'
setPinFunction() {
  if [ $1 ]; then
    exportPin $1
    if [ $2 ] && [ $2 -eq $GPIO_ENTRADA ]; then
      echo $GPIO_ENTRADA > $BASE_GPIO_PATH/gpio$1/direction
    else
      echo $GPIO_SALIDA > $BASE_GPIO_PATH/gpio$1/direction
    fi
  else
    setErrorNumberPin 'setPinFunction()'
  fi
}

# función para configurar dirección del pin como salida
setOutput() {
  if [ $1 ]; then
    setPinFunction $1
  else
    setErrorNumberPin 'setOutput()'
  fi
  # echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# función para configurar dirección del pin como entrada
setInput() {
  if [ $1 ]; then
    setPinFunction $1 'in'
  else
    setErrorNumberPin 'setInput()'
  fi
  # echo "in" > $BASE_GPIO_PATH/gpio$1/direction
}

DIRECTION_GPIO=''
VALUE_GPIO=''
# ESTADO_GPIO=''
getPinStatus() {
  if [ $1 ]; then
    DIRECTION_GPIO=''
    VALUE_GPIO=''
    # ESTADO_GPIO=''
    if [ -e $BASE_GPIO_PATH/gpio$1 ]; then
      DIRECTION_GPIO=$(cat $BASE_GPIO_PATH/gpio$1/direction)
      VALUE_GPIO=$(cat $BASE_GPIO_PATH/gpio$1/value)
      # ESTADO_GPIO=$VALUE_GPIO
    fi
  else
    setErrorNumberPin 'getPinStatus()'
  fi
}

# Función para la asignación de valor a pin (de entrada)
setValorPin() {
  if [ $1 ]; then
    getPinStatus $1
    if [ $DIRECTION_GPIO = $GPIO_SALIDA ]; then
      getConfigValor MODO
      if [ ! $VALUE_GPIO -eq $2 ] && [ $VALOR -eq 1 ]; then
          echo $2 > $BASE_GPIO_PATH/gpio$1/value
      fi
    else
      ERROR_FUNCTION='Error en función setValorPin(), pin configurado como Tipo entrada'
    fi
    if [ $3 ]; then
        printf "Estado GPIO $1 => $VALUE_GPIO \n"
        # printf "Estado GPIO $1 => $VALUE_GPIO \n" >> $ARCHIVO_LOG
    fi
  else
    setErrorNumberPin 'setValorPin()'
  fi
}

# Encender pin salida
setPinOn() {
  if [ $1 ]; then
    setValorPin $1 $ON
  else
    setErrorNumberPin 'setPinOn()'
  fi
}
# Apagar pin salida
setPinOff() {
  if [ $1 ]; then
    setValorPin $1 $OFF
  else
    setErrorNumberPin 'setPinOff()'
  fi
}
# trap shutdown SIGINT
# /**
# * FIN - Cabecera de Funciones
# */


# Función para apagar todos los pines (ventiladores)
apagarTodo() {
  setPinOff $FAN_RPI
  setPinOff $FAN_BOX
}

# Ctrl-C handler for clean shutdown
# Se apagan los pines y se cierra el programa
shutdown() {
  # Se preparan TODOS los pines para usar
  exportPin $FAN_RPI
  exportPin $FAN_BOX
  # Se configuran las pines como salida
  setOutput $FAN_RPI
  setOutput $FAN_BOX
  # Se apagan TODOS los PINES
  apagarTodo

  ESTADO=0
  # echo "" > $ARCHIVO_LOG
  exit 0
}

## Apagamos si recibimos la orden
if [ $1 -eq 0 ]; then
  RESTO=2
  while [ $RESTO -gt 0 ]; do
    clear
    printf "Apagamos el programa \n"
    printf "Esperamos: $RESTO \n"
    RESTO=$(($RESTO - 1))
    sleep 1
  done
  shutdown
fi

## PAUSE
CONTADOR=0
CONTADOR_SEC=0
TOTAL=0

inicializarApp() {
  # Se preparan TODOS los pines para usar
  exportPin $FAN_RPI
  exportPin $FAN_BOX

  # Se configuran las pines como salida
  setOutput $FAN_RPI
  setOutput $FAN_BOX

  # Se apagan TODOS los PINES
  apagarTodo

  printf "Iniciamos pin $FAN_RPI y $FAN_BOX \n"
  setValorPin $FAN_RPI $ON "1"
  setValorPin $FAN_BOX $ON "1"
  #Pause
  getConfigValor PAUSE
  PAUSE=3
  while [ $PAUSE -gt 1 ]; do
    clear
    printf "Inicializamos el programa \n"
    printf "Iniciamos pin $FAN_RPI y $FAN_BOX \n"
    printf "Esperamos: $PAUSE \n"
    PAUSE=$(($PAUSE - 1))
    sleep 1
  done
  printf "Apagamos pin $FAN_RPI y $FAN_BOX \n"
  setValorPin $FAN_RPI $OFF "1"
  setValorPin $FAN_BOX $OFF "1"
  while [ $PAUSE -gt 0 ]; do
    clear
    printf "Inicializamos el programa \n"
    printf "Apagamos pin $FAN_RPI y $FAN_BOX \n"
    printf "Esperamos: $PAUSE \n"
    PAUSE=$(($PAUSE - 1))
    sleep 1
  done
}
inicializarApp

# LOOP
FAN_ACTIVO=''
getConfigValor ESTADO
ESTADO=$VALOR
while [ $ESTADO = 1 ]; do

  # clear
  CONTADOR=$(($CONTADOR+1))
  TEMPERATURA_OBTENIDA=$(cat /sys/class/thermal/thermal_zone0/temp)
  TEMPERATURA=$(($TEMPERATURA_OBTENIDA/1000))
  getConfigValor TEMPERATURA_MIN
  TEMPERATURA_MIN=$VALOR
  getConfigValor TEMPERATURA_MAX
  TEMPERATURA_MAX=$VALOR

  FECHA=`date`
  MES=`date | awk '{print $2}'`
  YEAR=`date | awk '{print $6}'`
  # archivoNombre=$mes"_"$year".log"

  # Variable temperature control
  if [ $TEMPERATURA -ge $TEMPERATURA_MIN ] && [ $TEMPERATURA -le $TEMPERATURA_MAX ]; then

    # Calculamos el valor que le daremos al PWM
    VAR_PWM=`expr $TEMPERATURA \* $FACTOR_MULT_PWM`
    VAR_PWM=$(($TEMPERATURA*$FACTOR_MULT_PWM))

    # Ventilador RPI => ON
    setValorPin $FAN_RPI $ON "1"
    # Ventilador BOX => OFF
    setValorPin $FAN_BOX $OFF

    FAN_RPI_TIMES=$(($FAN_RPI_TIMES + 1))
    FAN_RPI_LAST_TEMP=$TEMPERATURA
    FAN_RPI_LAST_DATE=$FECHA

    # Comandos a ejecutar
    FAN_ACTIVO=$FAN_RPI_NOMBRE
    setFile PAUSE 300
    
  # Maximum fan RPM
  elif [ $TEMPERATURA -ge $TEMPERATURA_MAX ]; then

    # Valor PWM Máximo
    VAR_PWM=$PWM_MAX
    
    # Ventilador RPI => ON
    setValorPin $FAN_RPI $ON "1"
    FAN_RPI_TIMES=$(($FAN_RPI_TIMES + 1))
    FAN_RPI_LAST_TEMP=$TEMPERATURA
    FAN_RPI_LAST_DATE=$FECHA
    # Ventilador BOX => ON
    setValorPin $FAN_BOX $ON "1"
    FAN_BOX_TIMES=$(($FAN_BOX_TIMES + 1))
    FAN_BOX_LAST_TEMP=$TEMPERATURA
    FAN_BOX_LAST_DATE=$FECHA

    # Comandos a ejecutar
    FAN_ACTIVO="$FAN_RPI_NOMBRE - $FAN_BOX_NOMBRE"
    setFile PAUSE 120

  # Switch off the fan
  else

    # Valor PWM Mínimo
    VAR_PWM=$PWM_MIN
    
    # Ventilador RPI => OF
    setValorPin $FAN_RPI $OFF "1"

    # Ventilador BOX => OF
    setValorPin $FAN_BOX $OFF "1"

    # Comandos a ejecutar
    FAN_ACTIVO="NINGUNO"
    setFile PAUSE 60

  fi
  
  # printf "$FAN_ACTIVO activado. \n"
  # printf "$FAN_ACTIVO activado. \n" >> $ARCHIVO_LOG

  #Pause 60 seconds
  getConfigValor PAUSE
  TOTAL=$VALOR
  while [ $VALOR -gt 0 ]; do

    TEMPERATURA_OBTENIDA=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMPERATURA=$(($TEMPERATURA_OBTENIDA/1000))
    CONTADOR_SEC=$(($CONTADOR_SEC + 1))
    FECHA=`date`

    clear
    printf "Ejecuciones: $CONTADOR \n"
    #Show the temperature
    printf "Temperatura: $TEMPERATURA ºC ($TEMPERATURA_OBTENIDA) - Min: $TEMPERATURA_MIN - Max: $TEMPERATURA_MAX \n"
    # VENTILADORES - FAN
    printf "Ventilador/es activado/s: $FAN_ACTIVO \n"
    printf "Fan RPI Times: $FAN_RPI_TIMES - Last Temp: $FAN_RPI_LAST_TEMP - $FAN_RPI_LAST_DATE \n"
    printf "Fan BOX Times: $FAN_BOX_TIMES - Last Temp: $FAN_BOX_LAST_TEMP - $FAN_BOX_LAST_DATE \n"
    #Segundos transcurridos
    printf "Fecha Now: $FECHA \n"
    printf "Segundos desde inicio: $CONTADOR_SEC \n"
    printf "Esperamos: $VALOR - Total($TOTAL) \n"
    VALOR=$(($VALOR - 1))
    sleep 1

  done

  getConfigValor ESTADO
  ESTADO=$VALOR
done
shutdown
