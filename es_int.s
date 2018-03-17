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
	ADD.L  #$2000,RBA_FIN_PUNT
	MOVE.L #BUS_RBB,RBB_IN_PUNT
	MOVE.L #BUS_RBB,RBB_EXT_PUNT
	MOVE.L #BUS_RBB,RBB_INT_PUNT
	MOVE.L #BUS_RBB,RBB_FIN_PUNT
	ADD.L  #$2000,RBB_FIN_PUNT
	MOVE.L #BUS_TBA,TBA_IN_PUNT
	MOVE.L #BUS_TBA,TBA_EXT_PUNT
	MOVE.L #BUS_TBA,TBA_INT_PUNT
	MOVE.L #BUS_TBA,TBA_FIN_PUNT
	ADD.L  #$2000,TBA_FIN_PUNT
	MOVE.L #BUS_TBB,TBB_IN_PUNT
	MOVE.L #BUS_TBB,TBB_EXT_PUNT
	MOVE.L #BUS_TBB,TBB_INT_PUNT
	MOVE.L #BUS_TBB,TBB_FIN_PUNT
	ADD.L  #$2000,TBB_FIN_PUNT
	RTS

*********************LEECAR**********************

LEECAR:
  BTST    #0,D0
  BEQ LINEA_A

LINEA_B:
   CMP #$00000001,D0
   BEQ REC_B
TRANS_B:


  MOVE.L TBB_EXT_PUNT,A3
  MOVE.L TBB_INT_PUNT,A4
  CMP  A3,A4
  MOVE.L  TBB_EXT_PUNT,A5
  BEQ  VACIO
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  (A5)+,D0
  MOVE.L  A5,TBB_EXT_PUNT
  BRA FIN_LEECAR
REC_B:

  MOVE.L RBB_EXT_PUNT,A3
  MOVE.L RBB_INT_PUNT,A4
  CMP  A3,A4
  BEQ VACIO
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  RBB_EXT_PUNT,A5
  MOVE.L  (A5)+,D0
  MOVE.L A5,RBB_EXT_PUNT
  BRA FIN_LEECAR

LINEA_A:
  CMP #$00000000,D0
  BEQ REC_A
TRANS_A:

  MOVE.L TBA_EXT_PUNT,A3
  MOVE.L TBA_INT_PUNT,A4
  CMP  A3,A4
  BEQ VACIO
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  TBA_EXT_PUNT,A5
  MOVE.L  (A5)+,D0
  MOVE.L  A5,TBA_EXT_PUNT
  BRA FIN_LEECAR

REC_A:

  MOVE.L RBA_EXT_PUNT,A3
  MOVE.L RBA_INT_PUNT,A4
  CMP A3,A4
  BEQ VACIO
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L RBA_EXT_PUNT,A5
  MOVE.B (A5)+,D0
  MOVE.L A5,RBA_EXT_PUNT

  VACIO:
  MOVE.L #ffffffff,D0
  FIN_LEECAR:     RTS

********************ESCCAR********************
ESCCAR:

	BTST 	#0,D0
	BEQ ELINEA_A

ELINEA_B:

  BTST #1,D0
	BEQ EREC_B

ETRANS_B:
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  TBA_FIN_PUNT,A4     **Guarda en el registro A4 el puntero de fin de buffer
  MOVE.L	TBB_INT_PUNT,A5           *Guarda en el registro A5 el puntero de introduccion de dato
  CMP A4,A5
  BEQ VACIO
	MOVE.L  D1,(A5)+           *Push del registro D1 en el buffer
  MOVE.L  A5,TBB_INT_PUNT            *Guarda la nueva direcion del puntero

EREC_B:
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  RBB_FIN_PUNT,A4     **Guarda en el registro A4 el puntero de fin de buffer
  MOVE.L 	RBB_INT_PUNT,A5            *Guarda en el registro A5 el puntero de introduccion de dato
  CMP A4,A5
  BEQ VACIO
	MOVE.L  D1,(A5)+           *Push del registro D1 en el buffer
	MOVE.L  A5,RBB_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

ELINEA_A:

  BTST   #1,D0
	BEQ EREC_A

  ETRANS_A:
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  TBA_FIN_PUNT,A4     *Guarda en el registro A4 el puntero de fin de buffer
  MOVE.L	TBA_INT_PUNT,A5           *Guarda en el registro A5 el puntero de introduccion de dato
  CMP A4,A5
  BEQ VACIO
	MOVE.L  D1,(A5)+           *Push del registro D1 en el buffer
	MOVE.L  A5,TBA_INT_PUNT           *Guarda la nueva direcion del puntero
  RTS

  EREC_A:
  ADD.L #1,D0	* Aumenta en 1 el registro D0
  MOVE.L  RBA_FIN_PUNT,A4      *Guarda en el registro A4 el puntero de fin de buffer
  MOVE.L 	RBA_INT_PUNT,A5      *Guarda en el registro A5 el puntero de introduccion de dato
  CMP A4,A5
  BEQ VACIO
	MOVE.L  D1,(A5)+           *Push del registro D1 en el buffer
	MOVE.L  A5,RBA_INT_PUNT           *Guarda la nueva direcion del puntero
	RTS

VACIO_E:
  MOVE.L #ffffffff,D0
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
INICIO: BSR INIT
	MOVE.L #$00000000,D0
  MOVE.L #$0,D1
  BSR ESCCAR
	BSR LEECAR
  BSR LEECAR
	BSR LEECAR
  BSR LEECAR
	BSR LEECAR
  BSR LEECAR
	BSR LEECAR
  BSR LEECAR
	BSR LEECAR

	BREAK
