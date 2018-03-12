* Inicializa el SP y el PC
        ORG     $0
        DC.L    $8000           *Pila  
        DC.L    INICIO          *PC
        ORG     $400
	*Buffers

BUS_RBA:DS.B 2001
BUS_RBB:DS.B 2001
BUS_TBA:DS.B 2001
BUS_TBB:DS.B 2001 
	*Punteros
PUNT_IN_RBA: DS.B 4 
PUNT_FIN_RBA:DS.B 4 
PUNT_EXT_RBA:DS.B 4 
PUNT_INT_RBA:DS.B 4 
P_IN_RBB: DS.B 4
P_FIN_RBB:DS.B 4
P_EXT_RBB:DS.B 4
P_INT_RBB:DS.B 4
PU_IN_TBA: DS.B 4
PU_FIN_TBB:DS.B 4
PU_EXT_TBA:DS.B 4
PU_INT_TBA:DS.B 4
PUN_IN_TBB: DS.B 4 
PUN_FIN_TBB:DS.B 4
PUN_EXT_TBB:DS.B 4
PUN_INT_TBB:DS.B 4
	
        

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
	MOVE.L #BUS_RBA,PUNT_IN_RBA
	MOVE.L #BUS_RBA,PUNT_EXT_RBA
	MOVE.L #BUS_RBA,PUNT_INT_RBA
	MOVE.L #BUS_RBA,PUNT_FIN_RBA
	ADD.L  #$2000,PUNT_FIN_RBA
	MOVE.L #BUS_RBB,P_IN_RBB
	MOVE.L #BUS_RBB,P_EXT_RBB
	MOVE.L #BUS_RBB,P_INT_RBB
	MOVE.L #BUS_RBB,P_FIN_RBB
	ADD.L  #$2000,P_FIN_RBB
	MOVE.L #BUS_TBA,PU_IN_TBA
	MOVE.L #BUS_TBA,PU_EXT_TBA
	MOVE.L #BUS_TBA,PU_INT_TBA
	MOVE.L #BUS_TBA,PU_FIN_TBA
	ADD.L  #$2000,PU_FIN_TBA
	MOVE.L #BUS_TBB,PUN_IN_TBB
	MOVE.L #BUS_TBB,PUN_EXT_TBB
	MOVE.L #BUS_TBB,PUN_INT_TBB
	MOVE.L #BUS_TBB,PUN_FIN_TBB
	ADD.L  #$2000,PUN_FIN_TBB
	
*********************************************************************************************LEECAR**********************************************************************************************************
LEECAR:
	BTST 	#0,D0
	BEQ LINEA_A

LINEA_B:BTST    #1,D0
	BEQ REC_B
TRANS_B:MOVE.L 	#PUN_IN_TBB,A5
	ADD.L   #1,A5
	MOVE.L  A5,PUN_EXT_TBB
	MOVE.L  #PUN_EXT_TBB,D0
	MOVE.B  #0,PUN_EXT_TBB
REC_B:  MOVE.L 	#P_IN_RBB,A5
	ADD.L   #1,A5
	MOVE.L  A5,P_EXT_RBB
	MOVE.L  #P_EXT_RBB,D0
	MOVE.B  #0,P_EXT_RBB

LINEA_A:BTST   #1,D0
	BEQ REC_A
TRANS_A:MOVE.L 	#PU_IN_TBA,A5
	ADD.L   #1,A5
	MOVE.L  A5,PU_EXT_TBA
	MOVE.L  #PU_EXT_TBA,D0
	MOVE.B  #0,PU_EXT_TBA
REC_A:  MOVE.L 	#PUNT_IN_RBA,A5
	ADD.L   #1,A5
	MOVE.L  A5,PUNT_EXT_RBA
	MOVE.L  #PUNT_EXT_RBA,D0
	MOVE.B  #0,PUNT_EXT_RBA
	RTS





*******************************************************************************************ESCCAR************************************************************************************************************
ESCCAR:
	BTST 	#0,D0
	BEQ ELINEA_A

ELINEA_B:BTST    #1,D0
	BEQ EREC_B
ETRANS_B:MOVE.L	#PUN_IN_TBB,A5
	ADD.L   #1,A5
	MOVE.L  A5,PUN_EXT_TBB
	MOVE.L  #PUN_EXT_TBB,D0
EREC_B: MOVE.L 	#P_IN_RBB,A5
	ADD.L   #1,A5
	MOVE.L  A5,P_EXT_RBB
	MOVE.L  #P_EXT_RBB,D0

ELINEA_A:BTST   #1,D0
	BEQ EREC_A
ETRANS_A:MOVE.L	#PU_IN_TBA,A5
	ADD.L   #1,A5
	MOVE.L  A5,PU_EXT_TBA
	MOVE.L  #PU_EXT_TBA,D0
EREC_A: MOVE.L 	#PUNT_IN_RBA,A5
	ADD.L   #1,A5
	MOVE.L  A5,PUNT_EXT_RBA
	MOVE.L  #PUNT_EXT_RBA,D0
	RTS







*PRINT
PRINT:RTS

*LINEA
LINEA:RTS
*SCAN
SCAN:RTS
*RTI
RTI:RTS
*Programa Principal
INICIO: BSR INIT
	MOVE.L #$12,D0
	BSR LEECAR
	BREAK
