* Inicializa el SP y el PC
        ORG     $0
        DC.L    $8000           *Pila
        DC.L    INICIO          *PC
        ORG     $400

	*Buffers
BUS_RBA:DS.B 2002
BUS_RBB:DS.B 2002
BUS_TBA:DS.B 2002
BUS_TBB:DS.B 2002

	*Punteros
RBA_IN_PUNT: DC.L 0
RBA_FIN_PUNT:DC.L 0
RBA_EXT_PUNT:DC.L 0
RBA_INT_PUNT:DC.L 0
RBB_IN_PUNT: DC.L 0
RBB_FIN_PUNT:DC.L 0
RBB_EXT_PUNT:DC.L 0
RBB_INT_PUNT:DC.L 0
TBA_IN_PUNT: DC.L 0
TBA_FIN_PUNT:DC.L 0
TBA_EXT_PUNT:DC.L 0
TBA_INT_PUNT:DC.L 0
TBB_IN_PUNT: DC.L 0
TBB_FIN_PUNT:DC.L 0
TBB_EXT_PUNT:DC.L 0
TBB_INT_PUNT:DC.L 0


* Definicion de equivalencias

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2 escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
TBB     EQU     $effc17       * buffer trasmisión B
RBB     EQU     $effc17       * buffer recepción B
ACR     EQU     $effc09       * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)

*INIT
INIT:
	MOVE.L #BUS_RBA,RBA_IN_PUNT
	MOVE.L #BUS_RBA,RBA_EXT_PUNT
	MOVE.L #BUS_RBA,RBA_INT_PUNT
	MOVE.L #BUS_RBA,RBA_FIN_PUNT
	ADD.L  #$1999,RBA_FIN_PUNT
	MOVE.L #BUS_RBB,RBB_IN_PUNT
	MOVE.L #BUS_RBB,RBB_EXT_PUNT
	MOVE.L #BUS_RBB,RBB_INT_PUNT
	MOVE.L #BUS_RBB,RBB_FIN_PUNT
	ADD.L  #$1999,RBB_FIN_PUNT
	MOVE.L #BUS_TBA,TBA_IN_PUNT
	MOVE.L #BUS_TBA,TBA_EXT_PUNT
	MOVE.L #BUS_TBA,TBA_INT_PUNT
	MOVE.L #BUS_TBA,TBA_FIN_PUNT
	ADD.L  #$1999,TBA_FIN_PUNT
	MOVE.L #BUS_TBB,TBB_IN_PUNT
	MOVE.L #BUS_TBB,TBB_EXT_PUNT
	MOVE.L #BUS_TBB,TBB_INT_PUNT
	MOVE.L #BUS_TBB,TBB_FIN_PUNT
	ADD.L  #$1999,TBB_FIN_PUNT
	RTS

  *********************LEECAR**********************

  LEECAR:
    BTST    #0,D0
    BEQ LINEA_A

  LINEA_B:
     CMP #$00000001,D0
     BEQ REC_B
TRANS_B:
     MOVE.L TBB_INT_PUNT,A4
     MOVE.L TBB_EXT_PUNT,A3
     CMP  A3,A4
     BEQ VACIO
     MOVE.L TBB_FIN_PUNT,A5
     ADD.L #1,A5
     CMP A3,A5
     BEQ TBB_RESET
     MOVE.L  TBB_EXT_PUNT,A5
     MOVE.B  (A5)+,D0
     MOVE.L  A5,TBB_EXT_PUNT
     BRA FIN_LEECAR
  TBB_RESET:
     MOVE.L  TBB_EXT_PUNT,A5
     MOVE.L  A5,D0
     MOVE.L  TBB_IN_PUNT,A5
     MOVE.L  A5,TBB_EXT_PUNT
     BRA FIN_LEECAR

   REC_B:
     MOVE.L RBB_INT_PUNT,A4
     MOVE.L RBB_EXT_PUNT,A3
     CMP  A3,A4
     BEQ VACIO
     MOVE.L RBB_FIN_PUNT,A5
     ADD.L #1,A5
     CMP A3,A5
     BEQ RBB_RESET
     MOVE.L  RBB_EXT_PUNT,A5
     MOVE.B  (A5)+,D0
     MOVE.L  A5,RBB_EXT_PUNT
     BRA FIN_LEECAR
  RBB_RESET:
     MOVE.L  RBB_EXT_PUNT,A5
     MOVE.L  (A5)+,D0
     MOVE.L  RBB_IN_PUNT,A5
     MOVE.L  A5,RBB_EXT_PUNT
     BRA FIN_LEECAR

  LINEA_A:
    CMP #$00000000,D0
    BEQ REC_A

  TRANS_A:
    MOVE.L TBA_INT_PUNT,A4
    MOVE.L TBA_EXT_PUNT,A3
    CMP  A3,A4
    BEQ VACIO
    MOVE.L TBA_FIN_PUNT,A5
    ADD.L #1,A5
    CMP A3,A5
    BEQ TBA_RESET
    MOVE.L  TBA_EXT_PUNT,A5
    MOVE.B  (A5)+,D0
    MOVE.L  A5,TBA_EXT_PUNT
    BRA FIN_LEECAR
  TBA_RESET:
    MOVE.L  TBA_EXT_PUNT,A5
    MOVE.L  (A5)+,D0
    MOVE.L  TBA_IN_PUNT,A5
    MOVE.L  A5,TBA_EXT_PUNT
    BRA FIN_LEECAR

  REC_A:
    MOVE.L RBA_INT_PUNT,A4 *Puntero escritura
    MOVE.L RBA_EXT_PUNT,A3 *Puntero lectura
    CMP  A3,A4 *Si están en la misma posicion el puntero está vacío
    BEQ VACIO
    MOVE.L RBA_FIN_PUNT,A5 *Puntero fin
    ADD.L #1,A5
    CMP A3,A5
    BEQ RBA_RESET
    MOVE.L  RBA_EXT_PUNT,A5
    MOVE.B  (A5)+,D0
    MOVE.L  A5,RBA_EXT_PUNT
    BRA FIN_LEECAR
  RBA_RESET:
    MOVE.L  RBA_EXT_PUNT,A5
    MOVE.L  (A5)+,D0
    MOVE.L  RBA_IN_PUNT,A5 *Reseteamos el puntero de lectura
    MOVE.L  A5,RBA_EXT_PUNT
    BRA FIN_LEECAR


  VACIO:
    MOVE.L #$ffffffff,D0
  FIN_LEECAR:RTS

********************ESCCAR********************
ESCCAR:

    BTST #0,D0
    BEQ ELINEA_A

ELINEA_B:

    CMP #$00000001,D0
    BEQ EREC_B

ETRANS_B:
    MOVE.L TBB_INT_PUNT,A5 *Se mete el puntero I en A5
    MOVE.L TBB_FIN_PUNT,A4 *Se mete el puntero FIn en A4
    MOVE.L TBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
    MOVE.L  TBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
    ADD.L #1,A4   *Se le añade 1 al puntero de fin
    CMP.L A4,A5   *Se comparan los punteros I y F+1
    SUB.L #1,A4   *Se restablece el valor del puntero FIn
    BEQ  TBB_AUX      *Está en la posicion auxiliar
    CMPA.L A4,A5  *Se comprueba si F e I estan en la misma posicion
    BEQ    TBB_I_FIN  *Si I y Fin son iguales salta a la etiqueta de fin

TBB_I_NO_FIN:
        SUB.L #1,A3  *Se le resta a E una unidad
        CMP.L A5,A3  *Se mira si son iguales I y E-1
        ADD.L #1,A3  *Se restablece el valor de E
        BEQ    LLENO   *Si son iguales esta lleno

TBB_CONTINUA:
        ADD.L #1,A4 *Se le añade 1 al puntero de fin
        CMP.L A4,A5 *Se comparan los punteros I y F+1
        SUB.L #1,A4 *Se restablece el valor del puntero FIn
        BEQ  TBB_AUX    *Está en la posicion auxiliar

TBB_NO_AUX:
      MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
      MOVE.L  A5,TBB_INT_PUNT           *Guarda la nueva direcion del puntero
      RTS

TBB_AUX:
        CMP.L A3,A2  *Se comprueba si E y P estan en la misma posicion
        BEQ   LLENO
        MOVE.B  D1,(A5)   *Push del registro D1 en el buffer
        MOVE.L  TBB_IN_PUNT,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
        RTS

TBB_NO_LLENO:
        MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
        MOVE.L  A5,TBB_INT_PUNT           *Guarda la nueva direcion del puntero
        RTS

TBB_I_FIN:
        MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
        MOVE.L  A5,TBB_INT_PUNT           *Guarda la nueva direcion del puntero
        RTS



EREC_B:
        MOVE.L RBB_INT_PUNT,A5 *Se mete el puntero I en A5
        MOVE.L RBB_FIN_PUNT,A4 *Se mete el puntero FIn en A4
        MOVE.L RBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
        MOVE.L RBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
        ADD.L #1,A4   *Se le añade 1 al puntero de fin
        CMP.L A4,A5   *Se comparan los punteros I y F+1
        SUB.L #1,A4   *Se restablece el valor del puntero FIn
        BEQ  RBB_AUX      *Está en la posicion auxiliar
        CMPA.L A4,A5  *Se comprueba si F e I estan en la misma posicion
        BEQ    RBB_I_FIN  *Si I y Fin son iguales salta a la etiqueta de fin

RBB_I_NO_FIN:
        SUB.L #1,A3  *Se le resta a E una unidad
        CMP.L A5,A3  *Se mira si son iguales I y E-1
        ADD.L #1,A3  *Se restablece el valor de E
        BEQ   LLENO   *Si son iguales esta lleno

RBB_CONTINUA:
        ADD.L #1,A4 *Se le añade 1 al puntero de fin
        CMP.L A4,A5 *Se comparan los punteros I y F+1
        SUB.L #1,A4 *Se restablece el valor del puntero FIn
        BEQ  RBB_AUX    *Está en la posicion auxiliar

RBB_NO_AUX:
      MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
      MOVE.L  A5,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
      RTS

RBB_AUX:
        CMP.L A3,A2  *Se comprueba si E y P estan en la misma posicion
        BEQ   LLENO
        MOVE.B  D1,(A5)   *Push del registro D1 en el buffer
        MOVE.L  RBB_IN_PUNT,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
        RTS

RBB_NO_LLENO:
        MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
        MOVE.L  A5,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
        RTS

RBB_I_FIN:
        MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
        MOVE.L  A5,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
        RTS



ELINEA_A:

    CMP #$00000000,D0
	  BEQ EREC_A

ETRANS_A:
    MOVE.L TBA_INT_PUNT,A5 *Se mete el puntero I en A5
    MOVE.L TBA_FIN_PUNT,A4 *Se mete el puntero FIn en A4
    MOVE.L TBA_EXT_PUNT,A3 *Se mete el puntero de E al A3
    MOVE.L  TBA_IN_PUNT,A2 *Se mete el puntero de Principio al A2
    ADD.L #1,A4   *Se le añade 1 al puntero de fin
    CMP.L A4,A5   *Se comparan los punteros I y F+1
    SUB.L #1,A4   *Se restablece el valor del puntero FIn
    BEQ  TBA_AUX      *Está en la posicion auxiliar
    CMPA.L A4,A5  *Se comprueba si F e I estan en la misma posicion
    BEQ    TBA_I_FIN  *Si I y Fin son iguales salta a la etiqueta de fin

TBA_I_NO_FIN:
    SUB.L #1,A3  *Se le resta a E una unidad
    CMP.L A5,A3  *Se mira si son iguales I y E-1
    ADD.L #1,A3  *Se restablece el valor de E
    BEQ   LLENO   *Si son iguales esta lleno

TBA_CONTINUA:
    ADD.L #1,A4 *Se le añade 1 al puntero de fin
    CMP.L A4,A5 *Se comparan los punteros I y F+1
    SUB.L #1,A4 *Se restablece el valor del puntero FIn
    BEQ  TBA_AUX    *Está en la posicion auxiliar

TBA_NO_AUX:
  MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
  MOVE.L  A5,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

TBA_AUX:
    CMP.L A3,A2  *Se comprueba si E y P estan en la misma posicion
    BEQ   LLENO
    MOVE.B  D1,(A5)   *Push del registro D1 en el buffer
    MOVE.L  TBA_IN_PUNT,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
    RTS

TBA_NO_LLENO:
    MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
    MOVE.L  A5,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
    RTS

TBA_I_FIN:
    MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
    MOVE.L  A5,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
    RTS


EREC_A:
    MOVE.L RBA_INT_PUNT,A5 *Se mete el puntero I en A5
    MOVE.L RBA_FIN_PUNT,A4 *Se mete el puntero FIn en A4
    MOVE.L RBA_EXT_PUNT,A3 *Se mete el puntero de E al A3
    MOVE.L RBA_IN_PUNT,A2 *Se mete el puntero de Principio al A2
    ADD.L #1,A4   *Se le añade 1 al puntero de fin
    CMP.L A4,A5   *Se comparan los punteros I y F+1
    SUB.L #1,A4   *Se restablece el valor del puntero FIn
    BEQ  RBA_AUX      *Está en la posicion auxiliar
    CMPA.L A4,A5  *Se comprueba si F e I estan en la misma posicion
    BEQ    RBA_I_FIN  *Si I y Fin son iguales salta a la etiqueta de fin

RBA_I_NO_FIN:
    SUB.L #1,A3  *Se le resta a E una unidad
    CMP.L A5,A3  *Se mira si son iguales I y E-1
    ADD.L #1,A3  *Se restablece el valor de E
    BEQ  LLENO   *Si son iguales esta lleno

RBA_CONTINUA:
    ADD.L #1,A4 *Se le añade 1 al puntero de fin
    CMP.L A4,A5 *Se comparan los punteros I y F+1
    SUB.L #1,A4 *Se restablece el valor del puntero FIn
    BEQ  RBA_AUX    *Está en la posicion auxiliar

RBA_NO_AUX:
  MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
  MOVE.L  A5,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

RBA_AUX:
    CMP.L A3,A2  *Se comprueba si E y P estan en la misma posicion
    BEQ LLENO
    MOVE.B  D1,(A5)   *Push del registro D1 en el buffer
    MOVE.L  RBA_IN_PUNT,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
    RTS

RBA_NO_LLENO:
    MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
    MOVE.L  A5,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
    RTS

RBA_I_FIN:
    MOVE.B  D1,(A5)+           *Push del registro D1 en el buffer
    MOVE.L  A5,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
    RTS

LLENO:
    MOVE.L #$ffffffff,D0
    RTS

*PRINT
PRINT:RTS
*LINEA
LINEA:RTS
*SCAN
SCAN:RTS
*RTI
RTI:RTS


*Pruebas
PRUEBA:
  MOVE.L RBA_FIN_PUNT,A4
  *MOVE.L RBB_IN_PUNT,A4
  RTS

*Programa Principal
INICIO:
    BSR INIT
	  MOVE.L #$00000000,D0
    MOVE.L #1,D1
    BSR ESCCAR
    BSR LEECAR
    MOVE.L #$00000001,D0
    MOVE.L #2,D1
    BSR ESCCAR
    BSR LEECAR
    MOVE.L #$00000011,D0
    MOVE.L #3,D1
    BSR ESCCAR
    BSR LEECAR
    MOVE.L #$00000010,D0
    MOVE.L #4,D1
    BSR ESCCAR
    BSR LEECAR
    BREAK
