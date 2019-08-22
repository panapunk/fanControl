# fanControl
Control de temperatura para Raspberry pi con script Bin/Bash de Linux y el control de los GPIO de la Raspberry Pi para accionar dos ventiladores según las temperatura de la Raspberry pi en cada momento.

# HARDWARE

Para este proyecto, se ha montado una Raspberry pi 3 Model B conectada a un Disco Duro HDD de 2Teras con alimentación propia. 
En la Raspberry pi se ha instaldo el sistema operativo OSMC cargado en un USB.
Todo ello se ha introducido en una caja de vinos a la que se le han realizado los taladros correspondientes para la entrada de cableado y expulsión de aire.

Se han instalado dos ventiladores de 5v DC y 0.2A cada uno.

El primero llamado FAN_RPI, de dimensiones 5 x 4 x 0,6 cm, se ha instalado en la Raspberry pi, colocado de manera que cuando se accione, introduzca aire al interior de la Raspberry pi. 
Para reducir el nivel de ruido, este ventilador se alimenta con 3.3V DC. (este método de alimentación de un ventilador de 5V DC mediante 3.3V DC, puede estropear o deteriorar el ventilador)

El segundo ventilador llamado FAN_BOX, de dimensiones 40mm x 10mm, se ha instalado en la caja de maera que cuando se accione se expulse el aire caliente de la caja.

# SOFTWARE

Debido a los problemas encontrados para instalar y habilitar las librerías GPIO de python3, se ha desarrollado el script para Bin/Bash de linux.

De este modo, el script fanControl.sh se encarga de toda la lógica de control de temperatura y accionamiento de ventiladores según la configuración correspondiente.

Los archivos de configuración, sirven para modificar el comportamiento del script, en caso de querer variarlo. Los archivos de configuración serán:

- ESTADO => Si el valor de este archivo es 1, el script seguirá ejecutándose, en caso contrario, el script se detendrá.
- MODO => Si el valor de este archivo es 1, el script modificará los valores GPIO para enviar las órdenes de accionamiento, en caso contrario, únimente se simularán dichas órdenes.
- PAUSE => Define el tiempo de pausa por defecto entre envío de orden de accionamiento (encendido o apagado) y nueva toma de temperatura.
- TEMPERATURA_MIN => Define la temperatura mínima a la que se accionará al menos un ventilador.
- TEMPERATURA_MAX => Define la temperatura a la que se accionarán ambos ventiladores.
- LOG => Es la ruta del archivo donde se guardarán los registros.

La lógica del script es la siguiente:

En primer lugar se definen las funciones necesarias para preparar los pines GPIO en modo salida, así como las funciones que se ocupan de activar cada uno de los GPIO.

Después definimos los GPIO que usaremos para cada ventilador:

-- GPIO de salida
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
GPIO de entrada
TEST_GPIO=17

Se utilizarán los pines 18 para el ventilador de refrigeración de la Raspberry pi y el 13 para el ventilador de extracción de aire caliente de la caja.

Tras definir las funciones necesarias, se inicializan los pines, se accionan como encendidos, se espera un tiempo y se apagan.

Si el valor del archivo ESTADO es 1, se ejecutará un blucle while que se encarga de la lógica de toma de temperatura y accionamiento de los ventiladores.

- Si la temperatura se encuentra entre el valor mínimo y el valor máximo, se iniciará el GPIO 18 (ventilador de la Raspberry pi, y se apagará el ventilador de la caja).
- Si la temperatura es superior al valor máximo definido, se accionarán ambos pines 18 y 13 (ventilador de la Raspberry pi y ventilador de la caja).
- Si la temperatura es inferior a la temperatura mínima, se apagan ambos pines GPIO 18 y GPIO 13 y por tanto ambos ventiladores.

Tras cada comprobación, se obtiene el tiempo de pausa definido para cada caso y se espera dicho tiempo, pintando valores en pantalla.

# DEMONIO

Para que toda la funcionalidad se ejecute de manera automática, se ha desarrollado y configurado un demonio que se encarga de inicializar el script con cada reinicio del sistema, permitiendo para y volver a iniciar el script en cualquier momento.

Además, nos permitirá ver el estado de la ejecución del script mediante el acceso a la scrren creada.

Parando demonio:
<br><code>sudo /etc/init.d/fanControl stop</code>
Iniciando demonio:
<br><code>sudo /etc/init.d/fanControl start</code>


Visualizando el estodo de la ejecución:
<br><code>sudo screen -r fanControl</code>

ejemplo:
<code>
<br>  Ejecuciones: 1415
<br>  Temperatura: 66 ºC (66604) - Min: 68 - Max: 70
<br>  Ventilador/es activado/s: NINGUNO
<br>  Fan RPI Times: 195 - Last Temp: 70 - Thu Aug 22 11:55:00 CEST 2019
<br>  Fan BOX Times: 13 - Last Temp: 71 - Thu Aug 22 10:02:19 CEST 2019
<br>  Fecha Now: Thu Aug 22 12:05:31 CEST 2019
<br> Segundos desde inicio: 129317
<br> Esperamos: 44 - Total(60)
</code>



