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
RBA_IN_PUNT: DS.B 4
RBA_FIN_PUNT:DS.B 4
RBA_EXT_PUNT:DS.B 4
RBA_INT_PUNT:DS.B 4
RBB_IN_PUNT: DS.B 4
RBB_FIN_PUNT:DS.B 4
RBB_EXT_PUNT:DS.B 4
RBB_INT_PUNT:DS.B 4
TBA_IN_PUNT: DS.B 4
TBA_FIN_PUNT:DS.B 4
TBA_EXT_PUNT:DS.B 4
TBA_INT_PUNT:DS.B 4
TBB_IN_PUNT: DS.B 4
TBB_FIN_PUNT:DS.B 4
TBB_EXT_PUNT:DS.B 4
TBB_INT_PUNT:DS.B 4
*Copia IMR
IMR_COPIA:DS.B 2
*Flags de transmisión
FLAG_A:DS.B 1
FLAG_B:DS.B 1

BUFFER: DS.B 2100 * Buffer para lectura y escritura de caracteres
CONTL: DC.W 0 * Contador de l´ıneas
CONTC: DC.W 0 * Contador de caracteres
DIRLEC: DC.L 0 * Direcci´on de lectura para SCAN
DIRESC: DC.L 0 * Direcci´on de escritura para PRINT
TAME: DC.W 0 * Tamano de escritura para print
DESA: EQU 0 * Descriptor l´ınea A
DESB: EQU 1 * Descriptor l´ınea B
NLIN: EQU 1 * N´umero de l´ıneas a leer
TAML: EQU 2000 * Tama~no de l´ınea para SCAN
TAMB: EQU 1 * Tama~no de bloque para PRINT


* Definicion de equivalencias

MR1A  EQU  $effc01  * de modo A (escritura)
SRA   EQU  $effc03  * de estado A (lectura)
CRA   EQU  $effc05  * de control A (escritura)
TBA   EQU  $effc07  * buffer transmision A (escritura)
RBA   EQU  $effc07  * buffer recepcion A  (lectura)
ACR   EQU  $effc09  * de control auxiliar
IMR   EQU  $effc0B  * de mascara de interrupcion A (escritura)
MR1B  EQU  $effc11  * de modo B (escritura)
SRB   EQU  $effc13  * de estado B (lectura)
CRB   EQU  $effc15  * de control B (escritura)
TBB   EQU  $effc17  * buffer transmision B (escritura)
RBB   EQU  $effc17  * buffer recepcion B (lectura)
IVR   EQU  $effc19  * del vector de interrupci�n

*********************INIT**********************

INIT:



  *********************DECLARACIONES INIT**********************

  MOVE.B   #%00000011,MR1A      * 8 bits por carac. en A y solicita una int. por carac.
  MOVE.B   #%00000000,MR1A      * Eco desactivado en A
  MOVE.B   #%00000011,MR1B      * 8 bits por caract. en B y solicita una int. por carac.
  MOVE.B   #%00000000,MR1B      * Eco desactivado en B
  MOVE.B   #%11001100,SRA       * Velocidad = 38400 bps.
  MOVE.B   #%11001100,SRB       * Velocidad = 38400 bps.
  MOVE.B   #%00000000,ACR       * Selección del primer conjunto de velocidades.
  MOVE.B   #%00000101,CRA       * Transmision y recepcion activados en A.
  MOVE.B   #%00000101,CRB       * Transmision y recepcion activados en B.
  MOVE.B   #$40,IVR             * Vector de interrupción 40.
  MOVE.B   #%00100010,IMR      * Habilita las interrupciones de A y B
  MOVE.B   #%00100010,IMR_COPIA
  MOVE.B #0,FLAG_A             *Iniciamos los flags a 0
  MOVE.B #0,FLAG_B
  LEA      RTI,A1               * Dirección de la tabla de vectores
  MOVE.L   #$100,A2             * $100 es la dirección siguiente al V.I.
  MOVE.L   A1,(A2)              * Actualización de la dirección de la tabla de vectores

  *********************BUFFERS**********************
  LEA    BUS_RBA,A1
  MOVE.L A1,RBA_IN_PUNT
	MOVE.L A1,RBA_EXT_PUNT
	MOVE.L A1,RBA_INT_PUNT
	MOVE.L A1,RBA_FIN_PUNT
	ADD.L  #1999,RBA_FIN_PUNT
  LEA    BUS_RBB,A1
	MOVE.L A1,RBB_IN_PUNT
	MOVE.L A1,RBB_EXT_PUNT
	MOVE.L A1,RBB_INT_PUNT
	MOVE.L A1,RBB_FIN_PUNT
	ADD.L  #1999,RBB_FIN_PUNT
  LEA    BUS_TBA,A1
	MOVE.L A1,TBA_IN_PUNT
	MOVE.L A1,TBA_EXT_PUNT
	MOVE.L A1,TBA_INT_PUNT
	MOVE.L A1,TBA_FIN_PUNT
	ADD.L  #1999,TBA_FIN_PUNT
  LEA    BUS_TBB,A1
	MOVE.L A1,TBB_IN_PUNT
	MOVE.L A1,TBB_EXT_PUNT
	MOVE.L A1,TBB_INT_PUNT
	MOVE.L A1,TBB_FIN_PUNT
	ADD.L  #1999,TBB_FIN_PUNT

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
  ADD.L #1,D2
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
  CMP.L #$0001,D0  * Salto a la linea B
  BEQ PRINT_B
  CMP.L #0000,D0 * Salto a la linea A
  BEQ PRINT_A
PRINT_ERROR:
  MOVE.L #$ffffffff,D0 * Se retorna -1 en el registro D0
  BRA ERR_PRINT
PRINT_A:
  MOVE.W #$0010,D0  * Condicion de salto para el flag_a
  BRA PRINT_BUCLE

PRINT_B:
  MOVE.W #$0011,D0 * Condicion de salto para el flag_b
PRINT_BUCLE:
  CMP.L D4,D2 * Se comprueba que no hemos llegado al final del buffer
  BEQ PR_FIN
  ADD.L #1,D4 *Aumentamos Contador
  MOVE.B (A1)+,D1 *Se saca el elemento del buffer y se lleva D1
  BSR ESCCAR * Escribe el caracter en el buffer
  CMP.L #13,D1 * Se comprueba que no haya un retorno de carro en D1
  BEQ PRINT_FLAG
  CMP.L #$ffffffff,D0 * Si el buffer esta lleno acaba print
  BEQ PR_FIN
  BRA PRINT_BUCLE

PRINT_FLAG:
  MOVE.B #1,D6 * Habilitamos el flag
  BRA PRINT_BUCLE

PRINT_FFLAG:
  CMP.W #$0010,D0
  BEQ FLAGA
  BSET #4,IMR_COPIA * Pone el bit 4 de IMR a 1
  MOVE.B IMR_COPIA,IMR
  BRA PRINT_FIN

FLAGA:
  BSET #0,IMR_COPIA * Pone el bit 0 de IMR a 1
  MOVE.B IMR_COPIA,IMR
  BRA PRINT_FIN

PR_FIN:
  CMP.L #1,D6
  BEQ PRINT_FFLAG

PRINT_FIN:
  MOVE.L D4,D0 *Devolvemos el resultado en D0
  UNLK A6 *Se elimina el marco de pila
  RTS

ERR_PRINT:
  UNLK A6 *Se elimina el marco de pila
  RTS

********************RTI********************
RTI:
  *Salvaguardar los registros
  MOVE.L A1,-(A7)
  MOVE.L A2,-(A7)
  MOVE.L A3,-(A7)
  MOVE.L A4,-(A7)
  MOVE.L A5,-(A7)
  MOVE.L A6,-(A7)
  MOVE.L D0,-(A7)
  MOVE.L D1,-(A7)
  MOVE.L D2,-(A7)
  MOVE.L D3,-(A7)
  MOVE.L D4,-(A7)
  MOVE.L D6,-(A7)
  MOVE.B IMR_COPIA,D5
  AND.B IMR,D5
  BTST #0,D5    *Comprueba que este habilitada TxRDYA
  BNE TxRDYA
  BTST #1,D5    *Comprueba que este habilitada RxRDYA FFULLA
  BNE RxRDYA
  BTST #4,D5    *Comprueba que este habilitada TxRDYB
  BNE TxRDYB
  BTST #5,D5    *Comprueba que este habilitada RxRDYB FFULLB
  BNE RxRDYB

TxRDYA:
  MOVE.B FLAG_A,D3
  CMP #1,D3
  BNE SIGA
  MOVE.B #0,FLAG_A
  MOVE.B #10,TBA
  MOVE.L #2,D0
  BSR LINEA
  CMP #0,D0
  BEQ F_TxRDYA
  BRA FIN_RTI
SIGA:
  MOVE.L #2,D0  * Se mete un 2 en D0,para llamar al buffer TBA
  BSR LINEA
  CMP.L #0,D0   * Se comprueba si hay una linea dentro del buffer
  BEQ F_TxRDYA   * Hay una linea dentro del buffer interno
  MOVE.L #2,D0  * Se mete un 2 en D0,para llamar al buffer TBA
  BSR LEECAR
  CMP.L #$FFFFFFFF,D0 * Si es -1, el buffer esta vacio
  BEQ F_TxRDYA  * Si es -1, se deshabilitan las interrupciones
  CMP #13,D0    * Se comprueba si habia un 13
  BNE TA_CONT
  MOVE.B D0,TBA
  MOVE.B #1,FLAG_A
  BRA FIN_RTI
 TA_CONT:
  MOVE.B D0,TBA * Se mete el caracter del buffer de transmision en D1
  BRA FIN_RTI

F_TxRDYA:
  BCLR.B #0,IMR_COPIA * Se deshabilitan las interrupciones en TxRDYA
  MOVE.B IMR_COPIA,IMR
  CLR.L D0
  BRA FIN_RTI

TxRDYB:
  MOVE.B FLAG_B,D3
  CMP.B #1,D3
  BNE SIGB
  MOVE.B #0,FLAG_B
  MOVE.B #10,TBB
  MOVE.L #3,D0  *Se mete un 3 en D0, para llamar al buffer TBB
  BSR LINEA
  CMP.B #0,D0   * Se comprueba si hay una linea dentro del buffer
  BEQ F_TxRDYB   * Hay una linea dentro del buffer interno
  BRA FIN_RTI
SIGB:
  MOVE.L #3,D0  *Se mete un 3 en D0, para llamar al buffer TBB
  BSR LINEA
  CMP.L #0,D0   * Se comprueba si hay una linea dentro del buffer
  BEQ F_TxRDYB   * Hay una linea dentro del buffer interno
  MOVE.L #3,D0  *Se mete un 3 en D0, para llamar al buffer TBB
  BSR LEECAR
  CMP.B #13,D0    * Se comprueba si habia un 13
  BNE TB_CONT
  MOVE.B D0,TBB
  MOVE.B #1,FLAG_B
  BRA FIN_RTI
 TB_CONT:
  MOVE.B D0,TBB * Se mete el caracter del buffer de transmision en D1
  BRA FIN_RTI

F_TxRDYB:
  BCLR.B #4,IMR_COPIA * Se deshabilitan las interrupciones en TxRDYB
  MOVE.B IMR_COPIA,IMR
  CLR.L D0
  BRA FIN_RTI

RxRDYA:
  CLR.L D1
  MOVE.B RBA,D1
  MOVE.L #0,D0
  BSR ESCCAR
  BRA FIN_RTI

RxRDYB:
  CLR.L D1
  MOVE.B RBB,D1
  MOVE.L #1,D0
  BSR ESCCAR
  BRA FIN_RTI

FIN_RTI:
  ** Recuperamos los registros **
  MOVE.L (A7)+,D6
  MOVE.L (A7)+,D4
  MOVE.L (A7)+,D3
  MOVE.L (A7)+,D2
  MOVE.L (A7)+,D1
  MOVE.L (A7)+,D0
  MOVE.L (A7)+,A6
  MOVE.L (A7)+,A5
  MOVE.L (A7)+,A4
  MOVE.L (A7)+,A3
  MOVE.L (A7)+,A2
  MOVE.L (A7)+,A1
  RTE

*Programa Principal
******************** PRUEBAS ********************

****Se cosidera que todos los buffers estan vacios antes de llamar a las pruebas
*Llena el buffer
pr1:
 BPR1:
  CMP.L #2000,D4
  BEQ FIN_pr1
  ADD #1,D4
  MOVE.L #1,D1
  BSR ESCCAR
  BRA pr1
FIN_pr1:
  CLR.L D4
  CLR.L D1
  CLR.L D0
  RTS

  *Llena el buffer e intenta introducir otro caracter, en D0 = 0xFFFFFFF
pr2:
  BSR pr2
  ADD #1,D4
  BSR ESCCAR
  RTS

  * Lee todos los carcteres de un buffer lleno
pr3:
  BSR pr1
 BPR3:
  CMP.L #2000,D4
  BEQ FIN_pr3
  BSR LEECAR
  BRA BPR3
 FIN_pr3:
  CLR.L D0
  CLR.L D4
  RTS

  * Lee un caracter de un buffer vacio
pr4:
 BSR LEECAR
 RTS

 * Escribe 2000 caracteres, lee 1500 y escribe 500

 pr5:
  BSR pr1
  CLR.L D4
 BPR5:
  ADD.B #1,D4
  CMP.L #1500,D4
  BEQ BPR5_2
  BSR LEECAR
  BRA BPR5
BPR5_2:
    ADD.B #1,D3
    CMP.L #500,D3
    BEQ FIN_pr5
    MOVE.L #1,D1
    BSR ESCCAR
    BRA BPR5_2
FIN_pr5:
    CLR.L D1
    CLR.L D0
    CLR.L D4
    CLR.L D3
    RTS
* Introduce 500 (abcdefghijklmnopqrst 25 veces) caracteres en la Linea A,
*  (50 bytes por segundo) Se deben leer 1f5 caracteres

pr29:
  CLR.L D0
  CLR.L D4
Bpr29:
  CMP.L #500,D4
  BEQ FIN_pr29
  ADD.L #1,D4
  MOVE.B #$61,D0
  MOVE.B D0,RBA
  CLR.L D0
  BSR Bpr29
FIN_pr29:
  MOVE.B #$d,D0
  MOVE.B D0,RBA
  RTS

INICIO: * Manejadores de excepciones
  MOVE.L  #BUS_ERROR,8  * Bus error handler
  MOVE.L  #ADDRESS_ER,12 * Address error handler
  MOVE.L  #ILLEGAL_IN,16 * Illegal instruction handler
  MOVE.L  #PRIV_VIOLT,32 * Privilege violation handler

  BSR INIT
  MOVE.W #$2000,SR

BUCPR:
*  BSR pr29
  MOVE.W #0,CONTC
  MOVE.W #NLIN,CONTL
  MOVE.L #BUFFER,DIRLEC
OTRAL:
  MOVE.W #TAML,-(A7)
  MOVE.W #DESA,-(A7)
  MOVE.L DIRLEC,-(A7)
ESPL:
  BSR SCAN
  CMP.L #0,D0
  BEQ ESPL
  ADD.L #8,A7
  ADD.L D0,DIRLEC
  ADD.W D0,CONTC
  SUB.W #1,CONTL
  BNE OTRAL

  MOVE.L #BUFFER,DIRLEC
OTRAE:
  MOVE.W #TAMB,TAME
ESPE:
  MOVE.W TAME,-(A7)
  MOVE.W #DESA,-(A7)
  MOVE.L DIRLEC,-(A7)
  BSR PRINT
  ADD.L #8,A7
  ADD.L D0,DIRLEC
  SUB.W D0,CONTC
  BEQ SALIR
  SUB.W D0,TAME
  BNE ESPE
  CMP.W #TAMB,CONTC
  BHI OTRAE
  MOVE.W CONTC,TAME
  BRA ESPE
SALIR:BRA BUCPR
FIN:  BREAK
BUS_ERROR:
  BREAK
  NOP
ADDRESS_ER:
  BREAK
  NOP
ILLEGAL_IN:
  BREAK
  NOP
PRIV_VIOLT:
  BREAK
  NOP
