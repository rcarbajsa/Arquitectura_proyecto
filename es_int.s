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
	ADD.L  #1999,RBA_FIN_PUNT
	MOVE.L #BUS_RBB,RBB_IN_PUNT
	MOVE.L #BUS_RBB,RBB_EXT_PUNT
	MOVE.L #BUS_RBB,RBB_INT_PUNT
	MOVE.L #BUS_RBB,RBB_FIN_PUNT
	ADD.L  #1999,RBB_FIN_PUNT
	MOVE.L #BUS_TBA,TBA_IN_PUNT
	MOVE.L #BUS_TBA,TBA_EXT_PUNT
	MOVE.L #BUS_TBA,TBA_INT_PUNT
	MOVE.L #BUS_TBA,TBA_FIN_PUNT
	ADD.L  #1999,TBA_FIN_PUNT
	MOVE.L #BUS_TBB,TBB_IN_PUNT
	MOVE.L #BUS_TBB,TBB_EXT_PUNT
	MOVE.L #BUS_TBB,TBB_INT_PUNT
	MOVE.L #BUS_TBB,TBB_FIN_PUNT
	ADD.L  #1999,TBB_FIN_PUNT
	RTS

  *********************LEECAR**********************

  LEECAR:
    LINK A6,#0 *Creación del marco de pila
    BTST    #0,D0
    BEQ LA_LINEA

LB_LINEA:
     CMP #$00000001,D0
     BEQ LB_REC
LB_TRANS:
     MOVE.L TBB_IN_PUNT,A2
     MOVE.L TBB_EXT_PUNT,A3
     MOVE.L TBB_INT_PUNT,A4
     MOVE.L TBB_FIN_PUNT,A5
     CMP  A3,A4    * E=I?
     BEQ VACIO     * E= I, entonces buffer vacio
     ADD.L #1,A5
     CMP A3,A5     * E = F+1?
     SUB.L #1,A5  *Se restablece F a sus posicion original
     BEQ TBB_RESET
     MOVE.B  (A3)+,D0
     MOVE.L  A3,TBB_EXT_PUNT
     BRA FIN_LEECAR
  TBB_RESET:
     ADD.L #1,A4
     MOVE.B (A2)+,D0
     MOVE.L A4,TBB_INT_PUNT
     MOVE.L A2,TBB_EXT_PUNT
     BRA FIN_LEECAR

LB_REC:
    MOVE.L RBB_IN_PUNT,A2
    MOVE.L RBB_EXT_PUNT,A3
    MOVE.L RBB_INT_PUNT,A4
    MOVE.L RBB_FIN_PUNT,A5
    CMP  A3,A4    * E=I?
    BEQ VACIO     * E= I, entonces buffer vacio
    ADD.L #1,A5
    CMP A3,A5     * E = F+1?
    SUB.L #1,A5  *Se restablece F a sus posicion original
    BEQ RBB_RESET
    MOVE.B  (A3)+,D0
    MOVE.L  A3,RBB_EXT_PUNT
    BRA FIN_LEECAR
RBB_RESET:
    ADD.L #1,A4
    MOVE.B (A2)+,D0
    MOVE.L A4,RBB_INT_PUNT
    MOVE.L A2,RBB_EXT_PUNT
    BRA FIN_LEECAR
LA_LINEA:
    CMP #$00000000,D0
    BEQ LA_REC

LA_TRANS:
    MOVE.L TBA_IN_PUNT,A2
    MOVE.L TBA_EXT_PUNT,A3
    MOVE.L TBA_INT_PUNT,A4
    MOVE.L TBA_FIN_PUNT,A5
    CMP  A3,A4    * E=I?
    BEQ VACIO     * E= I, entonces buffer vacio
    ADD.L #1,A5
    CMP A3,A5     * E = F+1?
    SUB.L #1,A5  *Se restablece F a sus posicion original
    BEQ TBA_RESET
    MOVE.B  (A3)+,D0
    MOVE.L  A3,TBA_EXT_PUNT
    BRA FIN_LEECAR
TBA_RESET:
    ADD.L #1,A4
    MOVE.B (A2)+,D0
    MOVE.L A4,TBA_INT_PUNT
    MOVE.L A2,TBA_EXT_PUNT
    BRA FIN_LEECAR
LA_REC:
    MOVE.L RBA_IN_PUNT,A2
    MOVE.L RBA_EXT_PUNT,A3
    MOVE.L RBA_INT_PUNT,A4
    MOVE.L RBA_FIN_PUNT,A5
    CMP  A3,A4    * E=I?
    BEQ VACIO     * E= I, entonces buffer vacio
    ADD.L #1,A5
    CMP A3,A5     * E = F+1?
    SUB.L #1,A5  *Se restablece F a sus posicion original
    BEQ RBA_RESET
    MOVE.B  (A3)+,D0
    MOVE.L  A3,RBA_EXT_PUNT
    BRA FIN_LEECAR

RBA_RESET:
    ADD.L #1,A4
    MOVE.B (A2)+,D0
    MOVE.L A4,RBA_INT_PUNT
    MOVE.L A2,RBA_EXT_PUNT
    BRA FIN_LEECAR

  VACIO:
    MOVE.L #$ffffffff,D0
  FIN_LEECAR:
    UNLK A6 *Destrucción del marco de pila
    RTS

********************ESCCAR********************
ESCCAR:
    LINK A6,#0 *Creación del marco de pila
    BTST #0,D0
    BEQ EA_LINEA
EB_LINEA:

    CMP #$00000001,D0
    BEQ ESC_REC_B
ESC_TRANS_B:
    MOVE.L TBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
    MOVE.L TBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
    MOVE.L TBB_INT_PUNT,A4 *Se mete el puntero I en A4
    MOVE.L TBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
    SUB.L #1,A3  *Se le resta 1 a E
    CMP.L A3,A4 * I=E-1?
    ADD.L #1,A3  *Se restablece el valor de E
    BEQ LLENO
    ADD.L #1,A5   *Se le añade 1 al puntero de fin
    CMP.L A4,A5   *Se comparan los punteros I y F+1
    SUB.L #1,A5   *Se restablece el valor del puntero FIn
    BEQ  TBB_AUX      *Está en la posicion auxiliar

TBB_NO_AUX:
    CMP.L A3,A4  *Se comparan I y E
    BGE TBB_MAYOR
    ADD.L #1,A4
    MOVE.B  D1,(A4)            *Push del registro D1 en el buffer
    MOVE.L  A4,TBB_INT_PUNT    *Guarda la nueva direcion del puntero
    BRA FIN_ESCCAR

TBB_MAYOR:
    MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
    MOVE.L  A4,TBB_INT_PUNT           *Guarda la nueva direcion del puntero
    BRA FIN_ESCCAR

TBB_AUX:
    CMP.L A3,A2  * E=P?
    BEQ   LLENO
    MOVE.L  TBB_IN_PUNT,A4
    MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
    MOVE.L  A4,TBB_INT_PUNT  *Se Inicializa I con el valor de Principio
    BRA FIN_ESCCAR

ESC_REC_B:
  MOVE.L RBB_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L RBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  MOVE.L RBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L RBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
  SUB.L #1,A3  *Se le resta 1 a E
  CMP.L A3,A4 * I=E-1?
  ADD.L #1,A3  *Se restablece el valor de E
  BEQ LLENO
  ADD.L #1,A5   *Se le añade 1 al puntero de fin
  CMP.L A4,A5   *Se comparan los punteros I y F+1
  SUB.L #1,A5   *Se restablece el valor del puntero FIn
  BEQ  RBB_AUX      *Está en la posicion auxiliar

RBB_NO_AUX:
  CMP.L A3,A4  *Se comparan I y E
  BGE RBB_MAYOR
  ADD.L #1,A4
  MOVE.B  D1,(A4)            *Push del registro D1 en el buffer
  MOVE.L  A4,RBB_INT_PUNT    *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

RBB_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

RBB_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  RBB_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,RBB_INT_PUNT  *Se Inicializa I con el valor de Principio
  BRA FIN_ESCCAR

EA_LINEA:
  CMP #$00000000,D0
  BEQ EA_REC

EA_TRANS:
  MOVE.L TBA_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L TBA_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  MOVE.L TBA_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L TBA_IN_PUNT,A2 *Se mete el puntero de Principio al A2
  SUB.L #1,A3  *Se le resta 1 a E
  CMP.L A3,A4 * I=E-1?
  ADD.L #1,A3  *Se restablece el valor de E
  BEQ LLENO
  ADD.L #1,A5   *Se le añade 1 al puntero de fin
  CMP.L A4,A5   *Se comparan los punteros I y F+1
  SUB.L #1,A5   *Se restablece el valor del puntero FIn
  BEQ  TBA_AUX      *Está en la posicion auxiliar

TBA_NO_AUX:
  CMP.L A3,A4  *Se comparan I y E
  BGE TBA_MAYOR
  ADD.L #1,A4
  MOVE.B  D1,(A4)            *Push del registro D1 en el buffer
  MOVE.L  A4,TBA_INT_PUNT    *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

TBA_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

TBA_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  TBA_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
  BRA FIN_ESCCAR

EA_REC:
  MOVE.L RBA_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L RBA_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  MOVE.L RBA_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L RBA_IN_PUNT,A2 *Se mete el puntero de Principio al A2
  SUB.L #1,A3  *Se le resta 1 a E
  CMP.L A3,A4 * I=E-1?
  ADD.L #1,A3  *Se restablece el valor de E
  BEQ LLENO
  ADD.L #1,A5   *Se le añade 1 al puntero de fin
  CMP.L A4,A5   *Se comparan los punteros I y F+1
  SUB.L #1,A5   *Se restablece el valor del puntero FIn
  BEQ  RBA_AUX      *Está en la posicion auxiliar

RBA_NO_AUX:
  CMP.L A3,A4  *Se comparan I y E
  BGE RBA_MAYOR
  ADD.L #1,A4
  MOVE.B  D1,(A4)            *Push del registro D1 en el buffer
  MOVE.L  A4,RBA_INT_PUNT    *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

RBA_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
  BRA FIN_ESCCAR

RBA_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  RBA_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,RBA_INT_PUNT  *Se Inicializa I con el valor de Principio
  BRA FIN_ESCCAR

LLENO:
    MOVE.L #$ffffffff,D0
    BRA FIN_ESCCAR
FIN_ESCCAR:
  UNLK A6
  RTS

********************LINEA********************

LINEA:
  LINK A6,#0
  BTST #0,D0
  BEQ LINEA_A

LINEA_B:
  CMP #$00000001,D0
  BEQ LINEAB_REC
LINEAB_TRANS:
  MOVE.L TBB_IN_PUNT,A2
  MOVE.L TBB_EXT_PUNT,A3 *Se mete el puntero de Principio al A2
  MOVE.L TBB_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L TBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  CLR.L D0 *Contador
  BRA L_BUCLE

LINEAB_REC:
  MOVE.L RBB_IN_PUNT,A2
  MOVE.L RBB_EXT_PUNT,A3 *Se mete el puntero de Principio al A2
  MOVE.L RBB_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L RBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  CLR.L D0 *Contador
  BRA L_BUCLE

LINEA_A:
  CMP #$00000000,D0
  BEQ LINEAA_REC

LINEAA_TRANS:
  MOVE.L TBA_IN_PUNT,A2
  MOVE.L TBA_EXT_PUNT,A3 *Se mete el puntero de Principio al A2
  MOVE.L TBA_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L TBA_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  CLR.L D0 *Contador
  BRA L_BUCLE

LINEAA_REC:
  MOVE.L RBA_IN_PUNT,A2
  MOVE.L RBA_EXT_PUNT,A3 *Se mete el puntero de Principio al A2
  MOVE.L RBA_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L RBA_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  CLR.L D0 *Contador
  BRA L_BUCLE

L_BUCLE:
   CLR.L D1
   ADD.L #1,D0 *Aumenta el contador
   MOVE.B (A3),D1 *POP de E
   CMP #13,D1 *D1=13?
   BEQ F_LINEA  *Si D1=13, SE acaba la linea
   CMP A3,A5 *E=F?
   BEQ FIN_LINEA *Si E=F, esta al final de la linea
   CMP A4,A3 *I=E?
   BEQ L_VACIO *Si I=E, vacio
   ADD.L #1,A3
   BRA L_BUCLE
L_VACIO:
  CLR.L D0 *Se pone el contador a 0
  BRA F_LINEA
FIN_LINEA:
  MOVE.B (A3)+,D1 *POP del buffer
  CMP #13,D1 *D1=13?
  BEQ F_LINEA *Fin de la linea
  ADD.L #1,A5
  CMP A4,A5
  SUB.L #1,A5
  BNE L_RESET
  CLR.L D0 *D1!=13, no es una linea, por tanto contador=0
  BRA F_LINEA
L_RESET:
  MOVE.L A2,A3
  BRA L_BUCLE
F_LINEA:
  UNLK A6
  RTS



  *SCAN
  **recepcion
SCAN:
  LINK A6,#0  *Creación marco de pila
  MOVE.L   8(A6),A1 *DIR Buffer
  MOVE.W   12(A6),D0 *Descriptor
  MOVE.W   14(A6),D2 *Tamaño
  MOVE.W   D0,D4 *Guardamos el Descriptor
  CMP #$0001,D0
  BGT SCAN_ERROR
  CMP #0000,D0
  BLT SCAN_ERROR
  BSR LINEA
  MOVE.L D0,D3 *Número de caracteres que hay en la línea
  CMP D2,D3 *Si el número de caracteres que hay en la línea es mayor que el tamaño tiene que devolver un error
  BGT SCAN_TAMANO
  CLR.L D2
SCAN_BUCLE: *Leemos los N caracteres de la linea y los almacenamos en el buffer
  CMP D2,D3
  BEQ SC_FIN
  ADD.B #1,D2
  MOVE.W D4,D0
  BSR LEECAR
  MOVE.B D0,(A1)+ *Metemos el caracter en el buffer
  BRA SCAN_BUCLE
SCAN_ERROR:
  MOVE.L #$ffffffff,D0
  BRA SCAN_FIN
SCAN_TAMANO:
  MOVE.L #0,D0
  BRA SCAN_FIN
SC_FIN:
  MOVE.L D3,D0 *Devolvemos el resultado en D0
SCAN_FIN:
  UNLK A6
  RTS


*PRINT
**transmision
PRINT:
  LINK A6,#0  *Creación marco de pila
  MOVE.L   8(A6),A1 *DIR Buffer
  MOVE.W   12(A6),D0 *Descriptor
  MOVE.W   14(A6),D2 *Tamaño
  CLR.L D4 *Contador
  CMP #$0001,D0
  BEQ PRINT_B
  CMP #0000,D0
  BEQ PRINT_A
PRINT_ERROR:
  MOVE.L #$ffffffff,D0
  BRA PRINT_FIN
PRINT_A:
  MOVE.W #$0010,D0
  BRA PRINT_BUCLE
PRINT_B:
  MOVE.W #$0011,D0
PRINT_BUCLE:
  CMP D4,D2
  BEQ PR_FIN
  ADD.B #1,D4 *Aumentamos Contador
  MOVE.B (A1)+,D1
  BSR ESCCAR
  CMP #$ffffffff,D0
  BEQ PR_FIN
  BRA PRINT_BUCLE

PR_FIN:
  MOVE.L D4,D0 *Devolvemos el resultado en D0
PRINT_FIN:
  UNLK A6
  RTS
*RTI
RTI:RTS

*Pruebas

*Programa Principal
INICIO:
   BSR INIT
   MOVE.L #$0011,D0
   MOVE.L #$70,D1
   BSR ESCCAR
   MOVE.L #$65,D1
   BSR ESCCAR
   MOVE.L #$0001,D0
   MOVE.W #$0000,-(A7)
   MOVE.W #$0000,-(A7)
   MOVE.L #$00001388,-(A7)
   MOVE.L #$00001388,A4
   MOVE.B #$69,(A4)+
   MOVE.B #$6E,(A4)+
   BSR PRINT
   BREAK
