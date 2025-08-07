CUADRO_MAC MACRO REN,COL,S1,COLOR,BUCLE ;X,Y,TAMA,COLOR,BUCLE
local CARGAR_DATOS,DIBUJA
PUSH DX    
PUSH CX
    mov AL,SIZE1;iINVOCTOPUS
    MOV BUCLE,AL

    CARGAR_DATOS: 
    MOV AX, COL                         
    MOV X,AX 
    MOV AX, REN
    MOV Y, AX
    
    mov ch,0
    MOV Cl, SIZE1 ;size2
DIBUJA:
    PUNTO_FIGURAS X,Y,COLOR      ; dibuja pixel en (X,Y)
    inc Y          ; X 
    LOOP DIBUJA

    ; Mover X para la siguiente l?nea vertical
    INC COL    ; PARA BAJAR EN Y

    DEC BUCLE       ; decrementamos contador
    CMP BUCLE, 0
    JNE CARGAR_DATOS                           ;PRIMERA MACRO
    POP CX
    POP DX
ENDM   

DIBUJAR_JUGADOR MACRO
                        ;Convertir posici?n X (columna) a p?xeles
    MOV AL,POSICIONX
    MOV BL,16          
    MUL BL
    MOV COLINICI, AX
                        ;Convertir posici?n Y (fila) a p?xeles 
    XOR AX,AX  
    MOV AL,POSICIONY
    MOV BL,8           
    MUL BL
    MOV RENINICI, AX
    
    ; Dibujar la nave
    MOV AX,RENINICI
    MOV BX,COLINICI
    MOV SIZE1, 02
    MOV COLOR, 04H
    MOV CONTAUX, 0
    CALL DNAVE
ENDM

DIBUJAR_INVADERS MACRO
    LOCAL CICLO, SIGUIENTE, PROCESAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, 0
    MOV CX, 50

CICLO:
    CMP INVADERSVIDA[SI], 0
    JNE PROCESAR
    JMP SIGUIENTE

PROCESAR:
    CALL CARGA_INVADERS

SIGUIENTE:
    INC SI
    LOOP CICLO   ; En TASM es mejor mantener LOOP aqu?.

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
ENDM

CHECAR_COLISION MACRO
    LOCAL CICLO,CHECARINVADER,SIGUIENTE,SIGUIENTEINVADER,COLISION,CONTINUAR,CICLO1
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH DX
    
    MOV SI,0           
    MOV CX,5         
    
CICLO1:
    CMP BALABANDERA[SI],0
    JNE ACA
    JMP SIGUIENTE
    
ACA:    
    MOV DI,0           
    PUSH CX
    MOV CX, 50          ; 50 invasores
    
CHECARINVADER:
    CMP INVADERSVIDA[DI],0
    JE SIGUIENTEINVADER
    
    ; Verificar si la bala golpea al invasor
    MOV AL,BALAPOSICIONX[SI]
    CMP AL,INVADERSX[DI]
    JNE SIGUIENTEINVADER
    
    MOV AL,BALAPOSICIONY[SI]
    CMP AL,INVADERSY[DI]
    JNE SIGUIENTEINVADER  
                                ;COLISION
    JMP COLISION
    
SIGUIENTEINVADER:
    INC DI
    LOOP CHECARINVADER
    JMP CONTINUAR
    
COLISION:
    MOV BALABANDERA[SI],0
    MOV INVADERSVIDA[DI],0
    
    ;CAMBIAR MARCADOR
    MOV AL,INVADERTIPO[DI]
    MARCADOR AL
    
CONTINUAR:
    POP CX
        
SIGUIENTE:
    INC SI
    LOOP CICLO
    JMP FIN
    
CICLO: 
    JMP CICLO1

FIN: 
    POP DX
    POP CX
    POP DI
    POP SI
    POP BX
    POP AX
ENDM


COLISION_PERSONAJE MACRO
    LOCAL CICLO,CHECAR,SIGUIENTE,COLISION
    PUSH AX
    PUSH BX
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH DX
    
    MOV SI,0           
    MOV CX,10         
    
CICLO:
    CMP BALAINVADERBANDERA[SI],0
    JE SIGUIENTE
    
    MOV AL,BALAINVADERPOSICIONX[SI]
    MOV BL,16
    MUL BL
    MOV DX,AX                   
    
    MOV AL,POSICIONX
    MOV BL,16
    MUL BL                     
    
    CMP DX,AX
    JL SIGUIENTE                
    ADD AX,32                   
    CMP DX,AX
    JG SIGUIENTE               
    
    MOV AL,BALAINVADERPOSICIONY[SI]
    MOV BL,8
    MUL BL
    MOV DX,AX                   
    
    MOV AL,POSICIONY
    MOV BL,8
    MUL BL                      
    
    CMP DX,AX
    JL SIGUIENTE                
    ADD AX,16                  
    CMP DX,AX
    JG SIGUIENTE  
    
COLISION:
    MOV BALAINVADERBANDERA[SI],0
    DEC VIDAS
    
SIGUIENTE:
    INC SI
    LOOP CICLO
    
    POP DX
    POP CX
    POP DI
    POP SI
    POP BX
    POP AX
ENDM
; SACA EL CONTENIDO DE INVADER TIPO Y DEPENDIENDO DE EL LLAMA A INVADERS

suma MACRO VALOR1
    LOCAL OPERACION,CONVERTIR,COPIAR,FIN_SUMA,PROPAGAR_ACARREO
    MOV CX, 10
    LEA SI,RESULTADO
    LEA DI,RESULTADOAUX

COPIAR:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPIAR 
    
    CLC
    LEA SI,VALOR1+3
    LEA DI,RESULTADOAUX+9
    LEA BX,RESULTADO+9
    MOV CX,4
OPERACION:
    MOV AH,0
    MOV AL,[SI]
    ADC AL,[DI]
    AAA                     ;AJUSTA A BCD
    MOV [BX], AL
    DEC BX
    DEC SI
    DEC DI
    LOOP OPERACION
    
    MOV AL, AH
    CMP AL, 0
    JE FIN_SUMA

PROPAGAR_ACARREO:
    DEC BX               
    ADD BYTE PTR [BX], AL
    MOV AL, 0
    MOV AH, 0
    MOV AL, [BX]
    SUB AL, 30h
    CMP AL, 9
    JLE FIN_SUMA         

    SUB BYTE PTR [BX], 10
    INC AL               
    JMP PROPAGAR_ACARREO
FIN_SUMA:    
    
    LEA BX,RESULTADO+9
    MOV CX,10

CONVERTIR:
    OR BYTE PTR [BX], 30h   ;CONVIERTE ASCII
    DEC BX
    LOOP CONVERTIR 
ENDM


INCLUDE MACROS.LIB
.MODEL small
.STACK 
.data

filename  db 'PLAYERS.txt',0 
leido db 220 dup("$"),'$'
handle dw 0
ESPACIO DB ' '
SALTO    DB 0Dh, 0Ah        ;(PAL ENTER)
MENSAFE DB 'GURDAR$'
MENNWEGAME DB "PRESIONE F1 SI DESEA VOLVER A JUGAR$"
TITULO01 DB ' &&&&&&\  &&&&&&&\   &&&&&&\   &&&&&&\  &&&&&&&&\  $'                  
TITULO02 DB '&&  __&&\ &&  __&&\ &&  __&&\ &&  __&&\ &&  _____| $'                  
TITULO03 DB '&& /  \__|&& |  && |&& /  && |&& /  \__|&& |       $'                  
TITULO04 DB '\&&&&&&\  &&&&&&&  |&&&&&&&& |&& |      &&&&&\     $'                  
TITULO05 DB ' \____&&\ &&  ____/ &&  __&& |&& |      &&  __|    $'                  
TITULO06 DB '&&\   && |&& |      && |  && |&& |  &&\ && |       $'                  
TITULO07 DB '\&&&&&&  |&& |      && |  && |\&&&&&&  |&&&&&&&&\  $'                  
TITULO08 DB ' \______/ \__|      \__|  \__| \______/ \________| $'                                                                                  
TITULO09 DB '&&&&&&\ &&\   &&\ &&\    &&\  &&&&&&\  &&&&&&&\  &&&&&&&&\ &&&&&&&\   $'
TITULO10 DB '\_&&  _|&&&\  && |&& |   && |&&  __&&\ &&  __&&\ &&  _____|&&  __&&\  $'
TITULO11 DB '  && |  &&&&\ && |&& |   && |&& /  && |&& |  && |&& |      && |  && | $'
TITULO12 DB '  && |  && &&\&& |\&&\  &&  |&&&&&&&& |&& |  && |&&&&&\    &&&&&&&  | $'
TITULO13 DB '  && |  && \&&&& | \&&\&&  / &&  __&& |&& |  && |&&  __|   &&  __&&<  $'
TITULO14 DB '  && |  && |\&&& |  \&&&  /  && |  && |&& |  && |&& |      && |  && | $'
TITULO15 DB '&&&&&&\ && | \&& |   \&  /   && |  && |&&&&&&&  |&&&&&&&&\ && |  && | $'
TITULO16 DB '\______|\__|  \__|    \_/    \__|  \__|\_______/ \________|\__|  \__| $'
MENSG1   DB 'I N S E R T  C O I N$'
MENSG2   DB 'PRESIONE (ENTER)$'
TECLA    DB ?

MENSG3   DB 'PLAY$'
MENSG4   DB 'S P A C E    I N V A D E R S $'
MENSG5   DB '* TABLA DE PUNTOS POR ENEMIGO *$'
MENSG6   DB 'INGRESE SU APODO PARA GUARDAR SU SCORE:$'
MENSG7   DB 'POINTS$'
MENSG8   DB '----------------$'
INVADER1 DB '01'
INVADER2 DB '02'
INVADER3 DB '03'
ESPECIAL DB '04'
MAX      DB '100'
PRODUCTO DB 4 DUP(0)

DIGITOS  DW 0
CadenaBuffer DB 10      
             DB 0       
APODO DB 11 DUP('$')        
          

TOP      DB 'J U G A D O R E S  R E C I E N T E S$'
SCORE    DB 'SCORE$'
TABLA01  DB '------------------------------$'
TABLA02  DB '|    APODO     |    SCORE    |$'
TABLa03  DB '-----------------------------|$'
TABLA04  DB '|              |             |$'
TABLA05  DB '|              |             |$'
TABLA06  DB '|              |             |$'
TABLA07  DB '|              |             |$'
TABLA08  DB '|              |             |$'
TABLA09  DB '|              |             |$'
TABLA10  DB '|              |             |$'
TABLA11  DB '|              |             |$'
TABLA12  DB '|              |             |$'
TABLA13  DB '|              |             |$'
TABLA14  DB '|              |             |$'
TABLA15  DB '|              |             |$'
TABLA16  DB '|              |             |$'
TABLA17  DB '|              |             |$'
TABLA18  DB '|              |             |$'
TABLA19  DB '|              |             |$'
TABLA20  DB '|              |             |$'
TABLA21  DB '|              |             |$'
TABLA22  DB '|              |             |$'
TABLA23  DB '|              |             |$'
TABLA24  DB '------------------------------$'

PUNTUACION DB 'S C O R E < 1 > $'
RESULTADO  DB '0000000000'
CONTEO DB 11 DUP('$')
RESULTADOAUX DB '0000000000'
PUNTOS100 DB '0100'
PUNTOS200 DB '0200'
PUNTOS300 DB '0300'
PUNTOS400 DB '0400'
PUNTOS1000 DB '1000'

MENSG9  DB 'Flechas: mover, Espacio: disparar, ESC: salir$'
POSICIONX DB 23 
POSICIONY DB 40

BALAPOSICIONX DB 5 DUP(0)
BALAPOSICIONY DB 5 DUP(0)
BALABANDERA DB 5 DUP(0)
DISPARO DB '|$'      

INVADERSX DB 50 DUP(0)
CONTENIDOSI DB 0
INVADERSY DB 50 DUP(0)
INVADERSVIDA DB 50 DUP(1)
INVADER DB '*$'
DESPLAZAMIENTO DB 1

INVADERTIPO DB 10 DUP(4)    
            DB 20 DUP(3)     
            DB 10 DUP(2)    
            DB 10 DUP(1)
            
BALAINVADERPOSICIONX DB 10 DUP(0)
BALAINVADERPOSICIONY DB 10 DUP(0)
BALAINVADERBANDERA   DB 10 DUP(0)
DISPAROINVADER  DB 'Z$'
CONTADORINVADER DW 0

RENINICI DW 0
COLINICI DW 0 
TAMA DW 0
GROSOR DB  0
CONTAUX DB 0 
SIZE1 DB 0 
BUCLE DB 0
COLOR DB 0
X DW ?
Y DW ?
RENINICI_ORIG DW ?  
COLINICI_ORIG DW ? 
RENINICI_ORIGINAL DW ?  
COLINICI_ORIGINAL DW ? 
CONTA DB 0
MENSG10 DB 'Vidas: $'
VIDAS   DB 5

MENSG11 DB 'G  A  M  E  R     O  V  E  R $'
MENSG12 DB 'DESEA GUARDAR SU PUNTUACION ?$'
MENSG13 DB 'SE GUARDO EXITOSAMENTE SU PROGRESO ...$'
MENSG14 DB 'USTED HA SALIDO EXITOSAMENTE$'
MENSG15 DB 'CLIC DERECHO PARA SALIR$'
MENSG16 DB 'PRESIONE EL BOTON,PARA GUARDAR SU SCORE$'
CorX DW 300
CorY DW 200
With DW 50
height DW 50
clic DB 0
estado DB 0
;----------------------------------------------------------------------------------------------------------------------------
.code
MAIN PROC 
    protocolo ;Protocolo
;----------------------------------------------------------------------------------------------------------------------------
;PONER TITULO DEL JUEGO
VENTANA1:
    ModoVideo 12h 
    Poner_Titulo

LEER1:    
    READKEY
    CMP TECLA,1Ch
        JE VENTANA2
    JMP LEER1

;PONE NOMBRE Y PUNTUACIONES     
VENTANA2:
    ModoVideo 12h

    POS_CUR 4,38
    escribe_cadena MENSG3
    POS_CUR 7,26
    escribe_cadena MENSG4
    POS_CUR 10,26
    escribe_cadena MENSG5
    
    MULTIPLICAR MAX,PRODUCTO,ESPECIAL,13,41,1
    MULTIPLICAR MAX,PRODUCTO,INVADER3,15,41,1 ;CEROS A EVITAR DE DERECHA A IZQUIERDA
    MULTIPLICAR MAX,PRODUCTO,INVADER2,17,41,1
    MULTIPLICAR MAX,PRODUCTO,INVADER1,19,41,1
   
    POS_CUR 13,48
    escribe_cadena MENSG7
    
    MOV SIZE1,3
     MOV RENINICI,290
     MOV COLINICI,211
    MOV COLOR, 0AH
    KRABBYINV  RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    POS_CUR 15,48
    escribe_cadena MENSG7
     MOV RENINICI,290
     MOV COLINICI,243
    MOV COLOR, 04H

    IJUGGER RENINICI,COLINICI,SIZE1,COLOR,BUCLE ;MANDALE BUCLE
    POS_CUR 17,48
    escribe_cadena MENSG7
    
    MOV COLOR,0CH
    MOV RENINICI,290
    MOV COLINICI,275
    INVOCTOPUS RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    POS_CUR 19,48
    escribe_cadena MENSG7
    MOV RENINICI,290
    MOV COLINICI,307
    MOV COLOR, 0DH
    NINVADER RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    POS_CUR 22,22
    escribe_cadena MENSG6
    
    POS_CUR 25,32
    escribe_cadena MENSG8
    
    POS_CUR 24,32
    LeerCadena CadenaBuffer
    
    LEA SI,CadenaBuffer+2 
    MOV CH,0    
    MOV CL,[CadenaBuffer+1]    
    LEA DI,APODO  
    CALL PROCESAR_CADENA
    
    POS_CUR 28,32
    escribe_cadena MENSG2
        
LEER2:
    READKEY
    CMP TECLA,1Ch
        JE VENTANA3
    JMP LEER2

;VENTANA DE JUGADORES RECIENTES    
VENTANA3: 
    ModoVideo 12h  
    
    AbrirArchivo filename,handle
    LeerArchivo handle,leido
    
    POS_CUR 3,24
    escribe_cadena TOP

    HacerTabla
    
    ;Imprimir el contenido de leidos
    ImprimirContenido leido 8,30,46    ;30=APODO, 46=SOCRE
    
LEER3:
    READKEY
    CMP TECLA,1Ch
        JE VENTANA4
    JMP LEER3

;VENTANA DE JEUGO
VENTANA4:
    ModoVideo 12h               ;640 x 480  
    INICIALIZAR
    
JUEGO:
    CMP VIDAS,0
    JNE SIGUIENTE
    JMP VENTANA5
       
SIGUIENTE:
    Limpiar_Pantalla
    Limpiar_Fragmento 24,0,28,79
    
    POS_CUR 0,32
    escribe_cadena MENSG9
    
    POS_CUR 2,32
    escribe_cadena PUNTUACION
    
    POS_CUR 3,34
    MOV BX,OFFSET RESULTADO
    MOV CX,10

IMPRIME:
   escribe_caracter [bx]    ; se puede mejorar
   INC BX
   LOOP IMPRIME 
    
    ACTUALIZAR_VIDAS
    ACTUALIZAR_BALA
    ACTUALIZAR_INVADERS
    ACTUALIZARBALA_INVADER
 
    DIBUJAR_JUGADOR
    DIBUJAR_BALA
    
    DIBUJAR_INVADERS
    
    DIBUJARINVADER_BALA
    
    INVADER_DISPARAR
    CHECAR_COLISION
    COLISION_PERSONAJE
    TECLA_PRESIONADA
   
    ; Pequena pausa
    MOV AH,86h
    MOV CX,0
    MOV DX,30000       ; ~30ms delay
    INT 15h 
    
    JMP JUEGO

;VENTANA DE GAME OVER
VENTANA5:
     ModoVideo 12h
     
     POS_CUR 10,26
     escribe_cadena MENSG11
      POS_CUR 13,33 
      escribe_cadena PUNTUACION
      POS_CUR 15,35
      
      
      
      
    MOV BX,OFFSET RESULTADO
    MOV CX,10

IMPRIMESCORE:
   escribe_caracter [bx]    ; se puede mejorar
   INC BX
   LOOP IMPRIMESCORE 
     
  
LEER5:
     READKEY
     CMP TECLA,1Ch
        JE VENTANA6
     JMP LEER5

;VENTANA DE DECISION 
VENTANA6:
     ModoVideo 12h
    
     POS_CUR 5,25       
     escribe_cadena MENSG12
     
     POS_CUR 21,27       
     escribe_cadena MENSG15
     
     POS_CUR 24,21       
     escribe_cadena MENSG16
     
     InicializarMouse
     CMP AX,0                ;VE SI ENCONTRO EL DRIVER
     JNE SIGUE
     JMP ESPERA

SIGUE:
     MostrarMouse
     PosicionMouse 400,300
     
     ;LOGICA DEL BOTON
     MOV COLOR,02H
     MOV AX,With
     MOV SIZE1,AL
     MOV BUCLE,AL
     MOV RENINICI,304
     MOV COLINICI,208
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    POS_CUR 14,38       
    escribe_cadena MENSAFE
   
ESPERAR:
     EstadoMouse

     CMP BX,1
     JZ mousepresionado
     MOV estado,0
     JMP REVISAR

mousepresionado:
     CMP estado,0
     JNE REVISAR
     MOV estado,1
                             
     MOV AX,CX               ;VER SI EL CLIC FUE DENTRO DE LA FIGURA
     CMP AX,CorX
     JB REVISAR
     MOV AX,CorX
     ADD AX,With
     CMP CX,AX
     JA REVISAR

     MOV AX,Dx
     CMP AX,CorY
     JB REVISAR
     MOV AX,CorY
     ADD AX,height
     CMP DX,AX
     JA REVISAR

     INC clic
     CMP clic, 2
     JNE REVISAR
     JMP GUARDAR
    
REVISAR:
     CMP BX,2
     JE TRAMPOLIN
     JMP ESPERAR    

TRAMPOLIN:
     JMP ESPERA
     
GUARDAR:
     ModoVideo 12h
     
     LEA SI,RESULTADO
     LEA DI,CONTEO
     MOV CX,10

Salta:
     MOV AL,[SI]
     CMP AL,'0'
     JNE COPIAR        ; Si no es '0', empieza a copiar
     INC SI
     DEC CX
     CMP CX,0
     JE TODOS              ; Si todos son ceros, copia un '0'
     JMP Salta

COPIAR:
     CMP CX,0
     JE FINLA

CICLO:
     MOV AL,[SI]
     MOV [DI],AL
     INC SI
     INC DI
     DEC CX
     JNZ CICLO
     JMP FINLA

; Caso todos ceros: copiar un solo '0'
TODOS:
     MOV AL,'0'
     MOV [DI],AL
     INC DI
    
FINLA: 
     GUARDARSCORE APODO,CONTEO, handle

     POS_CUR 13,22       
     escribe_cadena MENSG13
     
LEER6:    
    READKEY
    CMP TECLA,1CH
    JNE LEER6
;-----------------------------------------------------------------------------------
ESPERA:

    ModoVideo 12h
    ;POS_CUR 13,28       
    ;escribe_cadena MENSG14
    
    CierreArchivo handle
    POS_CUR 10,22       
    escribe_cadena MENNWEGAME
    MostrarMouse
LEERFIN:   
    READKEY
    CMP TECLA,3BH
    JNE FINAL
    CALL RESETEAR_VARIABLES
    ;SUBRUTINA QUE RESTAURA LOS VALORES INICIALES
    JMP VENTANA1
   
FINAL:
    Limpiar_Pantalla   
    SALIR_DOS   
MAIN ENDP

;-----------------------------------------------------------------------------------      
PROCESAR_CADENA PROC
    PUSH CX
    PUSH SI
    PUSH DI
    
COPIAR_CADENA:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPIAR_CADENA

    MOV BYTE PTR [DI], '$'

    POP DI
    POP SI
    POP CX
    RET
PROCESAR_CADENA ENDP

DNAVE PROC  
    MOV COLOR,04H
   ; ESTOS NO SE TOCAN     
   MOV RENINICI_ORIG,AX    ; Guardar coordenada Y original
   MOV COLINICI_ORIG,BX    ; Guardar coordenada X original

    ;DIBUJA DOS CUADROS (PUNTA)
    MOV AH,0 
    MOV AL,SIZE1
    MOV BL,6
    MUL BL 
    ADD RENINICI,AX    ; Calcular desplazamiento para el casco
    MOV CX,2
    MOV BUCLE,0

    DIBPUNTA:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    LOOP DIBPUNTA

    ;DIBUJAR CASCO PRINCIPAL
    ; Restaurar y ajustar coordenadas
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV AL,SIZE1
    MOV BL, 5
    MUL BL
    ADD RENINICI,AX
     
     
     MOV AL,SIZE1
     MOV BL, 2
     MUL BL
     ADD COLINICI,AX
    
    MOV CX,12
    MOV CONTAUX,0
    
    DIBCASC:
   CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE

    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX ; DEZPLASAMIENTO AL SIGUIENTE
    SUB COLINICI,AX  ;LOS 3 INCREMENTOS DE COLI

    INC CONTAUX

    CMP CONTAUX,3 
    JNE NORMAL
    SUB CONTAUX,3
    ADD COLINICI,AX ; PARA QUE PASE AL SIGUIENTE RENGLON 


    MOV AL, SIZE1       
    MOV BL, 3       
    MUL BL          
    SUB RENINICI,AX ; SE RESTA SIZE1 *3
    NORMAL:


    LOOP DIBCASC

    ;DIBUJAR BASE PRINCIPAL
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX 
        
    ;DATOS DE DIBUJO
    MOV AH,0
    MOV AL, SIZE1
    MOV BL,4  
    MUL BL
    ADD RENINICI,AX
    
    MOV AH,0
    MOV AL, SIZE1
    MOV BL,6  
    MUL BL
    ADD COLINICI,AX
    MOV CX,5
    
 
    DIB_PBASE:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX ; INVREMENTAMOS X
    SUB COLINICI,AX ;RESTAMOS LOS 3  
    LOOP DIB_PBASE
    
    
    
        ;BASE COMPLETA CON CAMBIOS DE COLOR
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX 
    
    ;CARGA DATOS
    MOV COLOR,04H
    MOV AH,0
    MOV AL, SIZE1
    MOV BL,2  
    MUL BL
    ADD RENINICI,AX

    MOV AH,0
    MOV AL, SIZE1
    MOV BL,7  
    MUL BL
    ADD COLINICI,AX
    MOV CX,63
    MOV DX,0 ; BX COMO BANDERA CAMBIOS

    DIB_BASECOMPLET: 
    ;PUSH DX
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    DEC CX
    ;POP DX
    INC DX
    CMP DX,18
    JNE C1
    MOV COLOR,04H
    C1:
    CMP DX,45
    JNE CONT
    MOV COLOR,04H 
    CONT:
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX ; DEZPLASAMIENTO AL SIGUIENTE
    SUB COLINICI,AX  ;LOS 3 INCREMENTOS DE COLI

    INC CONTAUX

    CMP CONTAUX,9 
    JNE NORM
    SUB CONTAUX,9
    ADD COLINICI,AX ; PARA QUE PASE AL SIGUIENTE RENGLON 
    MOV AL, SIZE1       
    MOV BL, 9 ; LOS CUADORS DE ESPLASAMIENTO      
    MUL BL          
    SUB RENINICI,AX ; SE RESTA SIZE1 *3
    NORM:
    CMP CX,0
    JE CONT1

    JMP DIB_BASECOMPLET
    ;POSTES 
       ;REESTABLECER VALORES: 
    CONT1:


    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX 
    
    MOV COLOR, 0FH ;ROJO
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,4
    
    MUL BL 
    ADD COLINICI,AX
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,2
    
    MUL BL
    
    ADD RENINICI,AX
    
    MOV DX,0
    MOV CX,3
    
    DIBUJAR_POST1:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    
    
    CMP DX,2 
    JNE NOR
    MOV COLOR,04H
    NOR:
    
    LOOP DIBUJAR_POST1
    

    ;POSTE IZQUIERDO COMPLETO
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV COLOR, 0FH ;ROJO

    MOV AH,0
    MOV AL,SIZE1
    MOV BL,7
    MUL BL 
    ADD COLINICI,AX
    
    MOV DX,0
    MOV CX,9 
    
    POST_IZQ:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    
    CMP DX,2 
    JNE NORIZQ
    MOV COLOR,04H
    NORIZQ:
    
    LOOP POST_IZQ
      
    
    MOV COLOR, 04H ;ROJO
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX
    MOV BL,5
    
    MUL BL 
    SUB COLINICI,AX
    
    MOV DX,0
    MOV CX,4 
    
    COMPIZQ:  
    
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    
    LOOP COMPIZQ


    ;POSTE DERECHO
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV COLOR, 0FH ;ROJO
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,4
    
    MUL BL 
    ADD COLINICI,AX
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,0AH
    
    MUL BL
    
    ADD RENINICI,AX
    
    MOV DX,0
    MOV CX,3
    
    DIBUJAR_POST2:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    
    
    CMP DX,2 
    JNE NOR2
    MOV COLOR,04H
    NOR2:
    
    LOOP DIBUJAR_POST2

    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV COLOR, 0FH ;ROJO

    MOV AH,0
    MOV AL,SIZE1
    MOV BL,7
    MUL BL 
    ADD COLINICI,AX
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,0CH
    
    MUL BL
    
    ADD RENINICI,AX
    MOV DX,0
    MOV CX,9 
    
    POST_DER:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    
    CMP DX,2 
    JNE NORDER
    MOV COLOR,04H
    NORDER:
    
    LOOP POST_DER
    
     
    MOV COLOR, 04H ;ROJO
    MOV AH,0
    MOV AL,SIZE1
    SUB RENINICI,AX
    MOV BL,5
    
    MUL BL 
    SUB COLINICI,AX
    
    MOV DX,0
    MOV CX,4 
    
    COMPDER:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    
    LOOP COMPDER


    ;COLA
    MOV COLOR,04H
    
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
        
       MOV AL,SIZE1
    MOV BL,6
    MUL BL 
    ADD RENINICI,AX ; SE CALCULA EL DEZPLAZAMIENTO PARA DIBUJAR EL CASO
    MOV AL,SIZE1
    MOV BL,14
    MUL BL 
    ADD COLINICI,AX ; SE CALCULA EL DEZPLAZAMIENTO PARA DIBUJAR EL CASO
    MOV CX,2
    
    DIBCOLA:
    
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    LOOP DIBCOLA

    ;MOTOR IZQUIERDO
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV COLOR,0FH
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,4 
    MUL BL
    ADD RENINICI,AX 
    
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,12 
    MUL BL
    ADD COLINICI,AX
    
    MOV CX,1
    MOV DX,0
    
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    ;MOTOR IZQ
    MOV AH,0
    MOV AL,SIZE1
    SUB RENINICI,AX
    
    MOV CX,4
    MOV DX,0 
    
    DIMOTIZQ:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE  
    INC DX
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX
    SUB COLINICI,AX
    
    CMP DX,2 ;ya hizo los 2 primeros
    JNE MOTIZQ
    MOV AH,0
    MOV AL,SIZE1
    ADD COLINICI,AX
    MOV BL,2
    MUL BL
    SUB RENINICI,AX
    MOTIZQ:
    LOOP DIMOTIZQ
    ;MOTOR DERECHO
     MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
    
    MOV COLOR,0FH
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,8 
    MUL BL
    ADD RENINICI,AX 
    
    MOV AH,0
    MOV AL,SIZE1
    MOV BL,12 
    MUL BL
    ADD COLINICI,AX
    
    MOV CX,1
    MOV DX,0
    
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    
    ;PEDAZO FALTANTE 
    
    MOV CX,4
    MOV DX,0 
    
    MOTDERE:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX
    SUB COLINICI,AX
    
    CMP DX,2
    
    JNE NODMODERE
    MOV AH,0
    MOV AL,SIZE1
    ADD COLINICI,AX
    MOV BL,2
    MUL BL
    
    SUB RENINICI,AX
   NODMODERE:
    LOOP MOTDERE
    ;CONPLENEBTOS
    
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
     
    MOV COLOR,01H
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX 
    ADD RENINICI,AX
    ADD RENINICI,AX 
    MOV BL,7 
    MUL BL
    ADD COLINICI,AX 
    MOV CX,3
    MOV DX,0
    PALTANAVE:
   CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
   MOV COLOR,01H
    INC DX
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX
    ADD RENINICI,AX
    ADD RENINICI,AX
    SUB COLINICI,AX
    CMP DX,1
    JNE CONTPALNAVE
    MOV COLOR,0FH
    CONTPALNAVE:
    LOOP PALTANAVE
    ;DISENIO MEDIO
    MOV AX,RENINICI_ORIG
    MOV BX,COLINICI_ORIG 
    MOV RENINICI,AX
    MOV COLINICI,BX
     
    MOV COLOR,01H
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX 
    ADD RENINICI,AX
    MOV BL,8 
    MUL BL
    ADD COLINICI,AX 
    MOV CX,2
    MOV DX,0
    PARMEDNAVE:
   CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    MOV AH,0
    MOV AL,SIZE1
    SUB COLINICI,AX
    MOV BL,8
    MUL BL
    ADD RENINICI,AX
    LOOP PARMEDNAVE
    
    ;PARTES FALTANTES
    MOV AH,0
    MOV AL,SIZE1
    
    MOV BL,13
    MUL BL
    SUB RENINICI,AX
    MOV COLOR,0FH
    MOV CX,5
    MOV DX,0
    
    PARTFALTANS:
    CUADRO_MAC RENINICI,COLINICI,SIZE1,COLOR,BUCLE
    INC DX
    MOV AH,0
    MOV AL,SIZE1
    SUB COLINICI,AX
    ADD RENINICI,AX
    CMP DX,3
    JNE FIRSTPAR
    MOV AH,0
    MOV AL,SIZE1
    ADD COLINICI,AX
    MOV BL,3
    MUL BL
    SUB RENINICI,AX
    FIRSTPAR:
    CMP DX,4
    JNE FINALPARTNAV
    MOV AH,0
    MOV AL,SIZE1
    ADD RENINICI,AX
    
    FINALPARTNAV:
    LOOP PARTFALTANS
    
    MOV COLOR,04
          RET
      DNAVE ENDP
      
CARGA_INVADERS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV SIZE1, 2

    ; Calcular posici?n X
    MOV AH, 0
    MOV AL, INVADERSX[SI]
    MOV BL, 16
    MUL BL
    MOV COLINICI, AX

    ; Calcular posici?n Y
    XOR AX, AX
    MOV AL, INVADERSY[SI]
    MOV BL, 8
    MUL BL
    MOV RENINICI, AX

    ; Determinar el tipo de invader usando SI
    MOV AL, INVADERTIPO[SI]

    CMP AL, 1
    JE CALL_TIPO1
    CMP AL, 2
    JE CALL_TIPO2
    CMP AL, 3
    JE CALL_TIPO3
    CMP AL, 4
    JE CALL_TIPO4
    JMP FIN_CARGA

CALL_TIPO1:
    CALL DIBUJAR_TIPO1
    JMP FIN_CARGA

CALL_TIPO2:
    CALL DIBUJAR_TIPO2
    JMP FIN_CARGA

CALL_TIPO3:
    CALL DIBUJAR_TIPO3
    JMP FIN_CARGA

CALL_TIPO4:
    CALL DIBUJAR_TIPO4

FIN_CARGA:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CARGA_INVADERS ENDP

; Procedimientos auxiliares
DIBUJAR_TIPO1 PROC
    MOV COLOR, 0DH
    NINVADER RENINICI, COLINICI, SIZE1, COLOR, BUCLE
    RET
DIBUJAR_TIPO1 ENDP

DIBUJAR_TIPO2 PROC
     MOV COLOR, 0CH
    
    INVOCTOPUS RENINICI, COLINICI, SIZE1, COLOR, BUCLE
   
    RET
DIBUJAR_TIPO2 ENDP

DIBUJAR_TIPO3 PROC
    MOV COLOR, 04H
    IJUGGER RENINICI, COLINICI, SIZE1, COLOR, BUCLE
    RET
DIBUJAR_TIPO3 ENDP

DIBUJAR_TIPO4 PROC
 MOV COLOR, 0AH
    KRABBYINV RENINICI, COLINICI, SIZE1, COLOR, BUCLE
   
    RET
DIBUJAR_TIPO4 ENDP

RESETEAR_VARIABLES PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Resetear coordenadas y dimensiones
    MOV CorX, 300
    MOV CorY, 200
    MOV With, 50
    MOV height, 50
    
    ; Resetear estados y banderas
    MOV clic, 0
    MOV estado, 0
    MOV RENINICI, 0
    MOV COLINICI, 0
    MOV TAMA, 0
    MOV GROSOR, 0
    MOV CONTAUX, 0
    MOV SIZE1, 0
    MOV BUCLE, 0
    MOV COLOR, 0
    
    ; Resetear contadores y vidas
    MOV CONTA, 0
    MOV VIDAS, 5
    MOV CONTADORINVADER, 0
    MOV CONTENIDOSI, 0
    MOV DESPLAZAMIENTO, 1
    MOV DIGITOS, 0
    MOV CadenaBuffer, 10
    
    ; Limpiar arrays de balas de invasores (10 elementos)
    MOV CX, 10
    MOV SI, 0
LIMPIAR_BALAS_INVADER:
    MOV BALAINVADERPOSICIONX[SI], 0
    MOV BALAINVADERPOSICIONY[SI], 0
    MOV BALAINVADERBANDERA[SI], 0
    INC SI
    LOOP LIMPIAR_BALAS_INVADER
    
    ; Limpiar arrays de balas del jugador (5 elementos)
    MOV CX, 5
    MOV SI, 0
LIMPIAR_BALAS_JUGADOR:
    MOV BALAPOSICIONX[SI], 0
    MOV BALAPOSICIONY[SI], 0
    MOV BALABANDERA[SI], 0
    INC SI
    LOOP LIMPIAR_BALAS_JUGADOR
    
    ; Limpiar arrays de invasores (50 elementos)
    MOV CX, 50
    MOV SI, 0
LIMPIAR_INVADERS_XY:
    MOV INVADERSX[SI], 0
    MOV INVADERSY[SI], 0
    INC SI
    LOOP LIMPIAR_INVADERS_XY
    
    ; Resetear vida de invasores a 1 (50 elementos)
    MOV CX, 50
    MOV SI, 0
RESETEAR_VIDA_INVADERS:
    MOV INVADERSVIDA[SI], 1
    INC SI
    LOOP RESETEAR_VIDA_INVADERS
    
    ; Limpiar strings de resultado
    MOV CX, 10
    MOV SI, 0
LIMPIAR_RESULTADO:
    MOV RESULTADO[SI], '0'
    MOV RESULTADOAUX[SI], '0'
    INC SI
    LOOP LIMPIAR_RESULTADO
    
    ; Limpiar contador con '$'
    MOV CX, 11
    MOV SI, 0
LIMPIAR_CONTEO:
    MOV CONTEO[SI], '$'
    INC SI
    LOOP LIMPIAR_CONTEO
    
    ; Limpiar buffer de lectura con '$'
    MOV CX, 220
    MOV SI, 0
LIMPIAR_LEIDO:
    MOV leido[SI], '$'
    INC SI
    LOOP LIMPIAR_LEIDO
    
    ; Resetear handle
    MOV handle, 0
    
    ; Limpiar producto
    MOV CX, 4
    MOV SI, 0
LIMPIAR_PRODUCTO:
    MOV PRODUCTO[SI], 0
    INC SI
    LOOP LIMPIAR_PRODUCTO
    
    ; Limpiar apodo con '$'
    MOV CX, 11
    MOV SI, 0
LIMPIAR_APODO:
    MOV APODO[SI], '$'
    INC SI
    LOOP LIMPIAR_APODO
    
    ; Restaurar registros
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    
    RET
RESETEAR_VARIABLES ENDP

      
END MAIN