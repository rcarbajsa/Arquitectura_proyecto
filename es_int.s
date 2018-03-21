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
    BTST    #0,D0
    *BEQ LA_LINEA

  LB_LINEA:
     CMP #$00000001,D0
    * BEQ LB_REC

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
     CMP A2,A4  *I=P?
     BNE TBB_I_NO_P
     MOVE.B   (A2),D0
     MOVE.L  A2,TBB_EXT_PUNT
     BRA FIN_LEECAR
TBB_I_NO_P:
     MOVE.B  (A2)+,D0
     MOVE.L  A2,TBB_EXT_PUNT
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
    CMP A2,A4  *I=P?
    BNE RBB_I_NO_P
    MOVE.B   (A2),D0
    MOVE.L  A2,RBB_EXT_PUNT
    BRA FIN_LEECAR
RBB_I_NO_P:
    MOVE.B  (A2)+,D0
    MOVE.L  A2,RBB_EXT_PUNT
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
         MOVE.L  A3,TBB_EXT_PUNT
         BRA FIN_LEECAR
      TBA_RESET:
         CMP A2,A4  *I=P?
         BNE TBA_I_NO_P
         MOVE.B  (A2),D0
         MOVE.L  A2,TBA_EXT_PUNT
         BRA FIN_LEECAR
    TBA_I_NO_P:
         MOVE.B  (A2)+,D0
         MOVE.L  A2,TBA_EXT_PUNT
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
              CMP A2,A4  *I=P?
              BNE RBA_I_NO_P
              MOVE.B  (A2),D0
              MOVE.L  A2,RBA_EXT_PUNT
              BRA FIN_LEECAR
         RBA_I_NO_P:
              MOVE.B  (A2)+,D0
              MOVE.L  A2,RBA_EXT_PUNT
              BRA FIN_LEECAR


  VACIO:
    MOVE.L #$ffffffff,D0
  FIN_LEECAR:RTS

********************ESCCAR********************
ESCCAR:

    BTST #0,D0
    *BEQ EA_LINEA

EB_LINEA:

    CMP #$00000001,D0
    *BEQ ESC_REC_B

ESC_TRANS_B:
    MOVE.L  TBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
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
    RTS
TBB_MAYOR:
    MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
    MOVE.L  A4,TBB_INT_PUNT           *Guarda la nueva direcion del puntero
    RTS

TBB_AUX:
    CMP.L A3,A2  * E=P?
    BEQ   LLENO
    MOVE.L  TBB_IN_PUNT,A4
    MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
    MOVE.L  A4,TBB_INT_PUNT  *Se Inicializa I con el valor de Principio
    RTS



ESC_REC_B:
  MOVE.L RBB_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L RBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  MOVE.L RBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L  RBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
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
  RTS
RBB_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

RBB_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  RBB_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,RBB_INT_PUNT  *Se Inicializa I con el valor de Principio
  RTS

EA_LINEA:
  CMP #$00000000,D0
  BEQ EA_REC

EA_TRANS:  MOVE.L TBA_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L TBA_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  MOVE.L TBA_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L  TBA_IN_PUNT,A2 *Se mete el puntero de Principio al A2
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
  RTS
TBA_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

TBA_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  TBA_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,TBA_INT_PUNT  *Se Inicializa I con el valor de Principio
  RTS


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
  RTS
RBA_MAYOR:
  MOVE.B  D1,(A4)+           *Push del registro D1 en el buffer
  MOVE.L  A4,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

RBA_AUX:
  CMP.L A3,A2  * E=P?
  BEQ   LLENO
  MOVE.L  RBA_IN_PUNT,A4
  MOVE.B  D1,(A4)   *Push del registro D1 en el buffer
  MOVE.L  A4,RBA_INT_PUNT  *Se Inicializa I con el valor de Principio
  RTS
LLENO:
    MOVE.L #$ffffffff,D0
    RTS

********************LINEA********************

LINEA:
  BTST #0,D0
  *BEQ LINEA_A

LINEA_B:
  BTST #$00000001,D0
  *BEQ LINEAB_REC

LINEAB_TRANS:
  MOVE.L  TBB_IN_PUNT,A2 *Se mete el puntero de Principio al A2
  MOVE.L TBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
  MOVE.L TBB_INT_PUNT,A4 *Se mete el puntero I en A4
  MOVE.L TBB_FIN_PUNT,A5 *Se mete el puntero FIn en A5
  CLR.L D0 *Contador
TBB_BUCLE_LINEA:
  MOVE.L TBB_EXT_PUNT,A3 *Se mete el puntero de E al A3
  CMP A3,A5
  BEQ FIN_LINEA
  CLR.L D1
  ADD.B #1,D0
  MOVE.B (A3)+,D1
  MOVE.L A3,TBB_EXT_PUNT
  CMP #13,D1
  BEQ F_LINEA
  BRA TBB_BUCLE_LINEA
F_LINEA:RTS
FIN_LINEA:
  ADD.L #1,D0
  MOVE.B (A3),D1
  CMP #13,D1
  BEQ F_LINEA
  MOVE.L #0,D0
  RTS
LINEAB_REC:

LINEA_A:
  BTST #$00000000,D0
  BEQ LINEAA_REC

LINEAA_TRANS:
LINEAA_REC:
RTS


*PRINT
PRINT:RTS
+
*SCAN
SCAN:RTS

*RTI
RTI:RTS


*Pruebas

*Programa Principal
INICIO:
  BSR INIT
  MOVE.L #1,D1
  BSR ESCCAR
  MOVE.L #2,D1
  BSR ESCCAR
  MOVE.L #3,D1
  BSR ESCCAR
  MOVE.L #4,D1
  BSR ESCCAR
  BSR LINEA
  BREAK
