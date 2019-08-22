# fanControl
Control de temperatura para Raspberry pi con script Bin/Bash de Linux y el control de los GPIO de la Raspberry Pi para accionar dos ventiladores según las temperatura de la Raspberry pi en cada momento.

HARDWARE

Para este proyecto, se ha montado una Raspberry pi 3 Model B conectada a un Disco Duro HDD de 2Teras con alimentación propia. 
En la Raspberry pi se ha instaldo el sistema operativo OSMC cargado en un USB.
Todo ello se ha introducido en una caja de vinos a la que se le han realizado los taladros correspondientes para la entrada de cableado y expulsión de aire.

Se han instalado dos ventiladores de 5v DC y 0.2A cada uno.

El primero llamado FAN_RPI, de dimensiones 5 x 4 x 0,6 cm, se ha instalado en la Raspberry pi, colocado de manera que cuando se accione, introduzca aire al interior de la Raspberry pi. 
Para reducir el nivel de ruido, este ventilador se alimenta con 3.3V DC. (este método de alimentación de un ventilador de 5V DC mediante 3.3V DC, puede estropear o deteriorar el ventilador)

El segundo ventilador llamado FAN_BOX, de dimensiones 40mm x 10mm, se ha instalado en la caja de maera que cuando se accione se expulse el aire caliente de la caja.

SOFTWARE

Debido a los problemas encontrados para instalar y habilitar las librerías GPIO de python3, se ha desarrollado el script par Bin/Bash de linux.

<code>
  install
</code>
