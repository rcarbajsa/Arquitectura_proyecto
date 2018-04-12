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
*Copia IMR
IMR_COPIA:DC.L 0

BUFFER: DS.B 2100 * Buffer para lectura y escritura de caracteres
CONTL: DC.W 0 * Contador de l´ıneas
CONTC: DC.W 0 * Contador de caracteres
DIRLEC: DC.L 0 * Direcci´on de lectura para SCAN
DIRESC: DC.L 0 * Direcci´on de escritura para PRINT
TAME: DC.W 0 * Tama~no de escritura para print
DESA: EQU 0 * Descriptor l´ınea A
DESB: EQU 1 * Descriptor l´ınea B
NLIN: EQU 10 * N´umero de l´ıneas a leer
TAML: EQU 30 * Tama~no de l´ınea para SCAN
TAMB: EQU 5 * Tama~no de bloque para PRINT


* Definicion de equivalencias

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2 escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
ACR     EQU     $effc09       * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)

MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2 escritura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB    EQU     $effc13       * de seleccion de reloj B (escritura)
CRB     EQU     $effc15       * de control B (escritura)
RBB     EQU     $effc17       * buffer recepcion B  (lectura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
IVR     EQU     $effc09       * de vector de interrupcion

*********************INIT**********************

INIT:

*********************BUFFERS**********************

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

  *********************DECLARACIONES INIT**********************

  MOVE.B #%00010000,CRA      * Reinicia el puntero MR1A
  MOVE.B #%00010000,CRB      * Reinicia el puntero MR1B
  MOVE.B #%00000011,MR1B     * 8 bits por caracter de modo B.
  MOVE.B #%00000011,MR1A     * 8 bits por caracter de modo A.
  MOVE.B #%00000000,MR2A     * Eco desactivado de modo A.
  MOVE.B #%00000000,MR2B     * Eco desactivado de modo B.
  MOVE.B #%11001100,CSRA     * Velocidad = 38400 bps.
  MOVE.B #%11001100,CSRB     * Velocidad = 38400 bps
  MOVE.B #%00000000,ACR
  MOVE.B #%00000101,CRA      * Transmision y recepcion activados A.
  MOVE.B #%00000101,CRB      * Transmision y recepcion activados B.
  MOVE.B #$040,IVR           * Vector de Interrrupcion nº 40
  MOVE.B #%00100010,IMR      * Habilita las interrupciones de A y B
  MOVE.L #RTI,$100           * Inicio de RTI en tabla de interrupciones
  RTS *Retorno

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
  CLR.L D0 *D1!=13, no es una linea, por tanto contador = 0
  BRA F_LINEA
L_RESET:
  MOVE.L A2,A3
  BRA L_BUCLE
F_LINEA:
  UNLK A6
  RTS



********************SCAN********************
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
  CLR.L D2  *Se libera el 2 registro de Direccion
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


********************PRINT********************

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
  MOVE.L #$ffffffff,D0 *Se retorna -1 en el registro D0
  BRA ERR_PRINT
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

  CMP #13,D1
  BEQ PRINT_FLAG
  CMP #$ffffffff,D0
  BEQ PR_FIN
  BRA PRINT_BUCLE

PRINT_FLAG:
  MOVE.B #1,D6
  BRA PRINT_BUCLE
PRINT_FFLAG:
  CMP #$0010,D0
  BEQ FLAGA
  BSET #4,IMR_COPIA * Pone el bit 4 de IMR a 1
  MOVE.B IMR_COPIA,IMR
  BRA PRINT_FIN
FLAGA:
  BSET #1,IMR_COPIA * Pone el bit 0 de IMR a 1
  MOVE.B IMR_COPIA,IMR
  BRA PRINT_FIN

PR_FIN:
  CMP #1,D6
  BEQ PRINT_FFLAG
PRINT_FIN:
  MOVE.L D4,D0 *Devolvemos el resultado en D0
  UNLK A6 *Se elimina el marco de pila
  RTS
ERR_PRINT:
  UNLK A6 *Se elimina el marco de pila
  RTS
*RTI
RTI:
  RTS

*Programa Principal
INICIO:
   BSR INIT
   MOVE.W #$0002,-(A7)
   MOVE.W #$0001,-(A7)
   MOVE.L #$800,-(A7)
   MOVE.L #$800,A4
   MOVE.B #$3,(A4)+
   MOVE.B #$0d,(A4)+
   MOVE.L #$00000001,D0
   MOVE.B #$70,D1
   BSR ESCCAR
   MOVE.B #$0d,D1
   BSR ESCCAR
   BSR PRINT
   BREAK
*INICIO: * Manejadores de excepciones
   MOVE.L #BUS_ERROR,8 * Bus error handler
   MOVE.L #ADDRESS_ER,12 * Address error handler
   MOVE.L #ILLEGAL_IN,16 * Illegal instruction handler
   MOVE.L #PRIV_VIOLT,32 * Privilege violation handler
   BSR INIT
   MOVE.W #$2000,SR * Permite interrupciones
   BUCPR: MOVE.W #0,CONTC * Inicializa contador de caracteres
   MOVE.W #NLIN,CONTL * Inicializa contador de L´ıneas
   MOVE.L #BUFFER,DIRLEC * Direcci´on de lectura = comienzo del buffer
   OTRAL: MOVE.W #TAML,-(A7) * Tama~no m´aximo de la l´ınea
   MOVE.W #DESA,-(A7) * Puerto A
   MOVE.L DIRLEC,-(A7) * Direcci´on de lectura
   ESPL: BSR SCAN
   CMP.L #0,D0
   BEQ ESPL * Si no se ha le´ıdo una l´ınea se intenta de nuevo
   ADD.L #8,A7 * Restablece la pila
   ADD.L D0,DIRLEC * Calcula la nueva direcci´on de lectura
   ADD.W D0,CONTC * Actualiza el n´umero de caracteres le´ıdos
   SUB.W #1,CONTL * Actualiza el n´umero de l´ıneas le´ıdas. Si no
   BNE OTRAL * se han le´ıdo todas las l´ıneas se vuelve a leer
   MOVE.L #BUFFER,DIRLEC * Direcci´on de lectura = comienzo del buffer
   OTRAE: MOVE.W #TAMB,TAME * Tama~no de escritura = Tama~no de bloque
   ESPE: MOVE.W TAME,-(A7) * Tama~no de escritura
   MOVE.W #DESB,-(A7) * Puerto B
   MOVE.L DIRLEC,-(A7) * Direcci´on de lectura
   BSR PRINT
   ADD.L #8,A7 * Restablece la pila
   ADD.L D0,DIRLEC * Calcula la nueva direcci´on del buffer
   SUB.W D0,CONTC * Actualiza el contador de caracteres
   BEQ SALIR * Si no quedan caracteres se acaba
   SUB.W D0,TAME * Actualiza el tama~no de escritura
   BNE ESPE * Si no se ha escrito todo el bloque se insiste
   CMP.W #TAMB,CONTC * Si el no de caracteres que quedan es menor que el
   * tama~no establecido se transmite ese n´umero
   BHI OTRAE * Siguiente bloque
   MOVE.W CONTC,TAME
   BRA ESPE * Siguiente bloque
SALIR: BRA BUCPR
FIN: BREAK
BUS_ERROR:
  BREAK * Bus error handler
  NOP
ADDRESS_ER:
  BREAK * Address error handler
  NOP
ILLEGAL_IN:
  BREAK * Illegal instruction handler
  NOP
PRIV_VIOLT:
  BREAK * Privilege violation handler
  NOP
