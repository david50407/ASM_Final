include \masm32\include\masm32rt.inc
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
include helper.inc

printInteger PROTO, x:WORD, y:WORD, value:DWORD
printString	 PROTO, x:WORD, y:WORD, string:DWORD
turn         PROTO
foodRevive   PROTO
revive       PROTO, mode:BYTE
; can not use wait as func name
waiting      PROTO
move         PROTO
paint        PROTO, x:BYTE, y:BYTE, route:DWORD
gameover     PROTO
initialize   PROTO

.data
gameWidth = 40
gameHeight = 23
map           SBYTE gameWidth * gameHeight * 2 dup(?)

food          BYTE ?, ?
speed         BYTE ?
over          BYTE ?
player        PLAYER <>, <>
playerCount   BYTE  ?

foodImage     BYTE "¡°", 0

restartMsg    BYTE "Play Again(Y/N)", 0
scoreMsg      BYTE "Score:", 0
lengthMsg     BYTE "Length:", 0
lifeMsg       BYTE "Life:", 0
pressEnter    BYTE "Press Enter", 0
idk           BYTE "¢i", 0
space         BYTE " ", 0
space2        BYTE "  ", 0
space13       BYTE "             ", 0
headP1Image   BYTE "¡·", 0
headP2Image   BYTE "¡ó", 0
bodyImage     BYTE "¡´", 0
waitMsg       BYTE "Wait:", 0
p1WinMsg      BYTE "1P wins", 0
p2WinMsg      BYTE "2P wins", 0
tieMsg        BYTE "Tie", 0

consoleHandle DWORD ?
threadID      DWORD ?

g             BYTE "lullldldlddldddddrdrrrrururuulll", 0
a             BYTE "luuuuuulluldldldldddrdrrruru", 0
m1            BYTE "drdddddd", 0
m2            BYTE "urdrdddddd", 0
m3            BYTE "rurdrddlddddrru", 0
e1            BYTE "rrrruuulluldlldlddddrdrrrrrur", 0
o             BYTE "ruruuruuuuluululllldldlddlddddrdrdrdrr", 0
v             BYTE "ddrddddrdrruuruuruuru", 0
e2            BYTE "rdrrruruululllldldlddddrdrrrrurr", 0
r1            BYTE "rddddddd", 0
r2            BYTE "rurrrdr", 0

menuState     BYTE ?
menuSelect    BYTE ?, ?
mainMenuMsg1  BYTE "1 Player Mode", 0
mainMenuMsg2  BYTE "2 Player Mode", 0
mainMenuMsg3  BYTE "Setting", 0
mainMenuMsg4  BYTE "Exit", 0
settingMsg1   BYTE "1 Player Head Style", 0
settingMsg2   BYTE "1 Player Body Color", 0
settingMsg3   BYTE "2 Player Head Style", 0
settingMsg4   BYTE "2 Player Body Color", 0
settingMsg5   BYTE "Back", 0
headImageCount = 5
headImage     BYTE "¡·", 0, "¡ó", 0, "¡À", 0, "¡ò", 0, "¢I", 0
colorCodeCount = 7
colorCode     BYTE 15, 9, 10, 11, 12, 13, 14
headStyle     BYTE 0, 1
colorStyle    BYTE 0, 0
menuHead      BYTE "¢~¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢¡", 0
menuBody      BYTE "¢x¡@¡@¡@¡@                                        ¡@¢x", 0
menuFoot      BYTE "¢¢¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢£", 0
pointer       BYTE "¡Ö", 0
optionCount   BYTE ?

.code
;------------------------------------------
map3D PROC USES eax ebx,
     x:BYTE, y:BYTE, z:BYTE
;x, y, z: index
;-----------------------------------------
    xor eax, eax
    xor ebx, ebx

    mov al, gameHeight
    mulb x
    mov bl, y
    movzx ebx, bl
    add eax, ebx
    mov bl, z
    .IF bl == 1
        add ax, gameWidth * gameHeight
    .ENDIF

    mov esi, OFFSET map
    add esi, eax
    ret
map3D ENDP

;------------------------------------------
setMap PROC USES eax esi,
    x:BYTE, y:BYTE, z:BYTE, value:SBYTE
;x, y, z: index
;value: in BYTE type!
;-----------------------------------------
    INVOKE map3D, x, y, z
    mov al, value
    mov SBYTE PTR [esi], al
    ret
setMap ENDP

;--------------------------------
getMap MACRO x:REQ, y:REQ, z:REQ
;x, y, z: index
;value: in BYTE type!
;return
; al: map[x][y][z]
;-----------------------------------------
    push esi
    xor eax, eax
    INVOKE map3D, x, y, z
    mov al, [esi]
    pop esi
ENDM

.data
formatInteger   BYTE "%d", 0

.code
moveCursor MACRO handle:REQ, x:REQ, y:REQ
    LOCAL position
    .data
    position COORD <>
    .code
    push eax
    mov ax, x
    mov position.x, ax
    mov ax, y
    mov position.y, ax
    INVOKE SetConsoleCursorPosition, handle, DWORD PTR [position]
    pop eax
ENDM
;--------------------------------
printInteger PROC USES eax ecx edx,
  x:WORD, y:WORD, value:DWORD
; x, y: position
; value: the integer to be displayed
;
; display a integer value on the (x, y)
;--------------------------------
    moveCursor consoleHandle, x, y
    INVOKE crt_printf, ADDR formatInteger, value
    ret
printInteger ENDP

;--------------------------------
printString PROC USES eax ecx edx,
  x:WORD, y:WORD, string:DWORD
; x, y: position
; string: The OFFSET of the string
;
; display a string on the (x, y)
;--------------------------------
    moveCursor consoleHandle, x, y
    INVOKE crt_printf, string
    ret
printString ENDP

;--------------------------------
printMapItem PROC USES eax ebx,
  x:WORD, y:WORD, string:DWORD
; x, y: position
; string: The OFFSET of the string
;
; display a string on the (x, y)
;--------------------------------
  mov ax, x
  imul ax, 2
  mov bx, y
  add bx, 1
  INVOKE printString, ax, bx, string
  ret
printMapItem ENDP

turn PROC USES eax ebx edx
;turn the snake's direction
;--------------------------------
START_turn:

   call crt__getch

   .IF over
      jmp END_turn
   .ENDIF

   .IF playerCount == 2
      .IF al == 'w'
         .IF player[SIZEOF PLAYER].forbidDirect[0] == 0 && player[SIZEOF PLAYER].forbidDirect[1] == -1
            jmp START_turn
         .ENDIF
         mov player[SIZEOF PLAYER].direct[0], 0
         mov player[SIZEOF PLAYER].direct[1], -1
      .ELSEIF al == 'd'
         .IF player[SIZEOF PLAYER].forbidDirect[0] == 1 && player[SIZEOF PLAYER].forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov player[SIZEOF PLAYER].direct[0], 1
         mov player[SIZEOF PLAYER].direct[1], 0
      .ELSEIF al == 's'
         .IF player[SIZEOF PLAYER].forbidDirect[0] == 0 && player[SIZEOF PLAYER].forbidDirect[1] == 1
            jmp START_turn
         .ENDIF
         mov player[SIZEOF PLAYER].direct[0], 0
         mov player[SIZEOF PLAYER].direct[1], 1
      .ELSEIF al == 'a'
         .IF player[SIZEOF PLAYER].forbidDirect[0] == -1 && player[SIZEOF PLAYER].forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov player[SIZEOF PLAYER].direct[0], -1
         mov player[SIZEOF PLAYER].direct[1], 0
      .ENDIF
   .ENDIF

   .IF al == -32
      call crt__getch
      .IF al == 72 ; white arrow up
         .IF player[0].forbidDirect[0] == 0 && player[0].forbidDirect[1] == -1
            jmp START_turn
         .ENDIF
         mov player[0].direct[0], 0
         mov player[0].direct[1], -1
      .ELSEIF al == 80 ; white arrow down
         .IF player[0].forbidDirect[0] == 0 && player[0].forbidDirect[1] == 1
            jmp START_turn
         .ENDIF
         mov player[0].direct[0], 0
         mov player[0].direct[1], 1
      .ELSEIF al == 75 ; white arrow left 
         .IF player[0].forbidDirect[0] == -1 && player[0].forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov player[0].direct[0], -1
         mov player[0].direct[1], 0
      .ELSEIF al == 77 ; white arrow right
         .IF player[0].forbidDirect[0] == 1 && player[0].forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov player[0].direct[0], 1
         mov player[0].direct[1], 0     
      .ENDIF
   .ENDIF
   jmp START_turn
END_turn:
   ret
turn ENDP

;--------------------------------
foodRevive PROC USES eax ebx ecx edx,

	LOCAL flag:BYTE
    LOCAL i:BYTE
    LOCAL j:BYTE
;as title
;-------------------------------
	mov flag, 0

    mov i, 0
L1:
    .IF i == 40
        jmp LOUT
    .ENDIF
    mov j, 0
L2:
    .IF j == 23
        jmp L1END
    .ENDIF
    getMap i, j, 0
    .IF al == -1
        mov flag, 1
        jmp LOUT
    .ENDIF
    inc j
    loop L2
L1END:
    inc i
    loop L1

LOUT:
	.IF flag == 0
		mov food, 100
		jmp LEND
	.ENDIF

CHECK_POS:
    mov edx, 0
    INVOKE crt_rand
    mov ebx, gameWidth
	xor edx, edx
    div ebx
    mov food, dl
    mov edx, 0
    INVOKE crt_rand
    mov ebx, gameHeight
	xor edx, edx
    div ebx
    mov food + TYPE food, dl
	getMap food, food + TYPE food, 0

	.IF al == -1
		jmp SET_FOOD
	.ENDIF
	jmp CHECK_POS

SET_FOOD:
	INVOKE setMap, food, food + TYPE food, 0, -2
	INVOKE printMapItem, food, food + TYPE food, ADDR foodImage
LEND:
	ret
foodRevive ENDP

;--------------------------------
initialize PROC USES eax ebx ecx

    LOCAL _st:SYSTEMTIME
    LOCAL i:BYTE
    LOCAL j:BYTE
;initialize the snake game
;--------------------------------
	mov speed, 50

	; initilize map array
    mov i, 0
   
L1:
    .IF i == 40
        jmp LOUT
    .ENDIF
    mov j, 0
L2:
    .IF j == 23
        jmp L1END
    .ENDIF
    INVOKE setMap, i, j, 0, -1
    inc j
    loop L2
L1END:
    inc i
    loop L1

LOUT:
    mov over, 0

	INVOKE setMap, 18, 9, 0, 19
	INVOKE setMap, 18, 9, 1, 9
	INVOKE setMap, 19, 9, 0, 20
	INVOKE setMap, 19, 9, 1, 9
	INVOKE setMap, 20, 9, 0, 21
	INVOKE setMap, 20, 9, 1, 9
	INVOKE setMap, 21, 9, 0, 100
    mov player[0].life, 3
    mov player[0].earn, 1
    mov player[0].score, 0
    mov player[0].grow, 0
    mov player[0].leng, 4
    mov player[0].head[0], 21
    mov player[0].head[1], 9
    mov player[0].tail[0], 18
    mov player[0].tail[1], 9
    mov player[0].direct[0], 1
    mov player[0].direct[1], 0
    mov player[0].forbidDirect[0], -1
    mov player[0].forbidDirect[1], 0
    
    INVOKE lstrcpy, ADDR player[0].headImage, ADDR headImage
    mov player[0].color, 15

	INVOKE printString, 15, 0, ADDR scoreMsg
	mov eax, player[0].score
	INVOKE printInteger, 21, 0, eax
	INVOKE printString, 35, 0, ADDR lengthMsg
	movzx eax, player[0].leng
	INVOKE printInteger, 42, 0, eax
	INVOKE printString, 55, 0, ADDR lifeMsg
	movzx eax, player[0].life
	INVOKE printInteger, 60, 0, eax

    movzx eax, colorStyle
    movzx eax, colorCode[eax]
    INVOKE SetConsoleTextAttribute, consoleHandle, eax
    INVOKE printString, 36, 10, ADDR bodyImage
    INVOKE printString, 38, 10, ADDR bodyImage
    INVOKE printString, 40, 10, ADDR bodyImage
    INVOKE SetConsoleTextAttribute, consoleHandle, 7
    INVOKE printString, 42, 10, ADDR player[0].headImage

	.IF playerCount == 2

        INVOKE setMap, 18, 12, 0, 19
        INVOKE setMap, 18, 12, 1, 12
        INVOKE setMap, 19, 12, 0, 20
        INVOKE setMap, 19, 12, 1, 12
        INVOKE setMap, 20, 12, 0, 21
        INVOKE setMap, 20, 12, 1, 12
        INVOKE setMap, 21, 12, 0, 100
        mov player[SIZEOF PLAYER].earn, 1
        mov player[SIZEOF PLAYER].life, 3
        mov player[SIZEOF PLAYER].score, 0
        mov player[SIZEOF PLAYER].grow, 0
        mov player[SIZEOF PLAYER].leng, 4
        mov player[SIZEOF PLAYER].head[0], 21
        mov player[SIZEOF PLAYER].head[1], 12
        mov player[SIZEOF PLAYER].tail[0], 18
        mov player[SIZEOF PLAYER].tail[1], 12
        mov player[SIZEOF PLAYER].direct[0], 1
        mov player[SIZEOF PLAYER].direct[1], 0
        mov player[SIZEOF PLAYER].forbidDirect[0], -1
        mov player[SIZEOF PLAYER].forbidDirect[1], 0

        INVOKE lstrcpy, ADDR player[SIZEOF PLAYER].headImage, ADDR headImage[3]
        mov player[SIZEOF PLAYER].color, 15
        
        INVOKE printString, 15, 24, ADDR scoreMsg
	    mov eax, player[SIZEOF PLAYER].score
	    INVOKE printInteger, 21, 24, eax
	    INVOKE printString, 35, 24, ADDR lengthMsg
	    movzx eax, player[SIZEOF PLAYER].leng
	    INVOKE printInteger, 42, 24, eax
	    INVOKE printString, 55, 24, ADDR lifeMsg
	    movzx eax, player[SIZEOF PLAYER].life
	    INVOKE printInteger, 60, 24, eax
        movzx eax, colorStyle[1]
        movzx eax, colorCode[eax]
        INVOKE SetConsoleTextAttribute, consoleHandle, eax
        INVOKE printString, 36, 13, ADDR bodyImage
        INVOKE printString, 38, 13, ADDR bodyImage
        INVOKE printString, 40, 13, ADDR bodyImage
        INVOKE SetConsoleTextAttribute, consoleHandle, 7
        INVOKE printString, 42, 13, ADDR player[SIZEOF PLAYER].headImage

	.ENDIF

    INVOKE GetSystemTime, ADDR _st
    movzx  eax, SYSTEMTIME.wMilliseconds[_st]
    INVOKE crt_srand, eax

	INVOKE foodRevive

	ret
initialize ENDP

;------------------------------------
revive PROC USES eax ebx ecx edx,
    mode:BYTE
    LOCAL tmp1[2]:BYTE
    LOCAL tmp2[2]:BYTE
;revive snake
;mode: revived player 0 ~ 1
;------------------------------------
    
    mov al, mode
    mov bl, SIZEOF PLAYER
    mul bl
    movzx ebx, ax

    mov player[ebx].leng, 4
    mov al, player[ebx].tail[0]
    mov tmp1[0], al
    mov al, player[ebx].tail[1]
    mov tmp1[1], al
    mov ecx, 3

L:
    mov al, tmp1[0]
    mov tmp2[0], al
    mov al, tmp1[1]
    mov tmp2[1], al
    getMap tmp2[0], tmp2[1], 0
    mov tmp1[0], al
    getMap tmp2[0], tmp2[1], 1
    mov tmp1[1], al
    loop L
    
    mov al, tmp1[0]
    mov player[ebx].head[0], al
    mov al, tmp1[1]
    mov player[ebx].head[1], al
    mov al, tmp1[0]
    sub al, tmp2[0]
    mov player[ebx].direct[0], al
    mov al, tmp1[1]
    sub al, tmp2[1]
    mov player[ebx].direct[1], al
    mov al, player[ebx].direct[0]
    neg al
    mov player[ebx].forbidDirect[0], al
    mov al, player[ebx].direct[1]
    neg al
    mov player[ebx].forbidDirect[1], al
        
    getMap tmp1[0], tmp1[1], 0
    .IF al != 100
        mov al, tmp1
        mov tmp2[0], al
        mov al, tmp1[1]
        mov tmp2[1], al
        getMap tmp2[0], tmp2[1], 0
        mov tmp1, al
        getMap tmp2[0], tmp2[1], 1
        mov tmp1[1], al

LWHITE:     
        getMap tmp1[0], tmp1[1], 0
        .IF al == 100
            jmp LOUT
        .ENDIF

        mov al, tmp1[0]
        mov tmp2[0], al
        mov al, tmp1[1]
        mov tmp2[1], al
        getMap tmp2[0], tmp2[1], 0
        mov tmp1[0], al
        getMap tmp2[0], tmp2[1], 1
        mov tmp1[1], al
        INVOKE setMap, tmp2[0], tmp2[1], 0, -1
        INVOKE printMapItem, tmp2[0], tmp2[1], ADDR space2
        jmp LWHITE

LOUT:       
        INVOKE setMap, tmp1[0], tmp1[1], 0, -1
        INVOKE printMapItem, tmp1[0], tmp1[1], ADDR space2
    .ENDIF
    INVOKE setMap, player[ebx].head[0], player[ebx].head[1], 0, 100

    INVOKE printMapItem, player[ebx].head[0], player[ebx].head[1], ADDR player[ebx].headImage

    .IF food == 100
        INVOKE foodRevive
    .ENDIF

    ret

revive ENDP


;--------------------------------
move PROC USES eax ebx ecx,

    LOCAL th[4]:BYTE
    LOCAL tmp[2]:BYTE
;--------------------------------
START_move:

    movzx eax, speed
    INVOKE Sleep, eax

    mov ax, 0
    mov al, player[0].head[0]
    add al, player[0].direct[0]
    add al, 40
    mov bl, 40
    div bl
    mov th[0], ah

    mov ax, 0
    mov al, player[0].head[1]
    add al, player[0].direct[1]
    add al, 23
    mov bl, 23
    div bl
    mov th[1], ah

    mov ax, 0
    mov al, player[SIZEOF PLAYER].head[0]
    add al, player[SIZEOF PLAYER].direct[0]
    add al, 40
    mov bl, 40
    div bl
    mov th[2], ah

    mov ax, 0
    mov al, player[SIZEOF PLAYER].head[1]
    add al, player[SIZEOF PLAYER].direct[1]
    add al, 23
    mov bl, 23
    div bl
    mov th[3], ah

    getMap th[0], th[1], 0
    mov bh, al
    getMap th[2], th[3], 0
    mov bl, al
    mov dh, th[2]
    mov dl, th[3]
    getMap th[0], th[1], 0

    .IF playerCount == 2 && ((bh != -1 && bh != -2 && bl != -1 && bl != -2) || (th[0] == dh && th[1] == dl))

        dec player[0].life
        dec player[SIZEOF PLAYER].life
        shr player[0].score, 1
        shr player[SIZEOF PLAYER].score, 1

        .IF player[0].life == 0 || player[SIZEOF PLAYER].life == 0
            jmp END_move
        .ENDIF

        INVOKE printString, 21, 0, OFFSET space13
        INVOKE printString, 21, 24, OFFSET space13
        mov eax, player[0].score
        INVOKE printInteger, 21, 0, eax
        mov eax, player[SIZEOF PLAYER].score
        INVOKE printInteger, 21, 24, eax
        INVOKE printString, 42, 0, OFFSET space13
        INVOKE printString, 42, 24, OFFSET space13
        INVOKE printInteger, 42, 0, 4
        INVOKE printInteger, 42, 24, 4
        movzx eax, player[0].life
        INVOKE printInteger, 60, 0, eax
        movzx eax, player[SIZEOF PLAYER].life
        INVOKE printInteger, 60, 24, eax
        INVOKE revive, 0
        INVOKE revive, 1
        call waiting
        jmp START_move

    .ELSEIF al != -1 && al != -2

        .IF playerCount == 2

            shr player[0].score, 1
            mov eax, player[0].score
            add player[SIZEOF PLAYER].score, eax
            dec player[0].life
            .IF player[0].life == 0
                jmp END_move
            .ENDIF

            INVOKE printString, 21, 0, OFFSET space13
            INVOKE printString, 21, 24, OFFSET space13
            mov eax, player[0].score
            INVOKE printInteger, 21, 0, eax
            mov eax, player[SIZEOF PLAYER].score
            INVOKE printInteger, 21, 24, eax
            INVOKE printString, 42, 0, OFFSET space13
            INVOKE printInteger, 42, 0, 4
            movzx eax, player[0].life
            INVOKE printInteger, 60, 0, eax
            INVOKE revive, 0
            call waiting
            jmp START_move

        .ELSE

            dec player[0].life
            .IF player[0].life == 0
                jmp END_move
            .ENDIF

            shr player[0].score, 1
            INVOKE printString, 21, 0, OFFSET space13
            mov eax, player[0].score
            INVOKE printInteger, 21, 0, eax
            INVOKE printString, 42, 0, OFFSET space13
            INVOKE printInteger, 42, 0, 4
            movzx eax, player[0].life
            INVOKE printInteger, 60, 0, eax
            INVOKE revive, 0
            call waiting
            jmp START_move

        .ENDIF

    .ELSEIF playerCount == 2 && bl != -1 && bl != -2

        shr player[SIZEOF PLAYER].score, 1
        mov eax, player[SIZEOF PLAYER].score
        add player[0].score, eax
        dec player[SIZEOF PLAYER].life

        .IF player[SIZEOF PLAYER].life == 0
            jmp END_move
        .ENDIF

        INVOKE printString, 21, 0, OFFSET space13
        INVOKE printString, 21, 24, OFFSET space13
        mov eax, player[0].score
        INVOKE printInteger, 21, 0, eax
        mov eax, player[SIZEOF PLAYER].score
        INVOKE printInteger, 21, 24, eax
        INVOKE printString, 42, 24, OFFSET space13
        INVOKE printInteger, 42, 24, 4
        movzx eax, player[SIZEOF PLAYER].life
        INVOKE printInteger, 60, 24, eax
        INVOKE revive, 1
        call waiting
        jmp START_move

    .ENDIF


    ; draw body
    mov ecx, 0
DRAW_BODY:
    .IF cl == playerCount
        jmp END_DRAW_BODY
    .ENDIF

    mov al, cl
    mov bl, SIZEOF PLAYER
    mul bl
    movzx ebx, ax

    movzx eax, player[ebx].color
    push ecx
    INVOKE SetConsoleTextAttribute, consoleHandle, eax
    pop ecx
    INVOKE printMapItem, player[ebx].head[0], player[ebx].head[1], ADDR bodyImage
    push ecx
    INVOKE SetConsoleTextAttribute, consoleHandle, 7
    pop ecx
    mov dl, th[ecx*2]
    INVOKE setMap, player[ebx].head[0], player[ebx].head[1], 0, dl
    mov dl, th[ecx*2+1]
    INVOKE setMap, player[ebx].head[0], player[ebx].head[1], 1, dl
    mov al, th[ecx*2]
    mov player[ebx].head[0], al
    mov al, th[ecx*2+1]
    mov player[ebx].head[1], al
    
    inc ecx
    jmp DRAW_BODY

END_DRAW_BODY:
    ; draw head
    mov ecx, 0
DRAW_HEAD:
    .IF cl == playerCount
        jmp END_DRAW_HEAD
    .ENDIF

    mov al, cl
    mov bl, SIZEOF PLAYER
    mul bl
    movzx ebx, ax

    INVOKE setMap, player[ebx].head[0], player[ebx].head[1], 0, 100
    INVOKE printMapItem, player[ebx].head[0], player[ebx].head[1], ADDR player[ebx].headImage
    mov al, player[ebx].direct[0]
    neg al
    mov player[ebx].forbidDirect[0], al
    mov al, player[ebx].direct[1]
    neg al
    mov player[ebx].forbidDirect[1], al

    inc ecx
    jmp DRAW_HEAD

END_DRAW_HEAD:
    ; grow
    mov ecx, 0
GROW:
    .IF cl == playerCount
        jmp END_GROW
    .ENDIF

    mov al, cl
    mov bl, SIZEOF PLAYER
    mul bl
    movzx ebx, ax

    .IF player[ebx].grow

        dec player[ebx].grow
        inc player[ebx].leng
        movzx eax, player[ebx].leng
        .IF cl == 0
            INVOKE printInteger, 42, 0, eax
        .ELSEIF cl == 1
            INVOKE printInteger, 42, 24, eax
        .ENDIF

    .ELSE

        INVOKE printMapItem, player[ebx].tail[0], player[ebx].tail[1], ADDR space2
        mov al, player[ebx].tail[0]
        mov tmp[0], al
        mov al, player[ebx].tail[1]
        mov tmp[1], al
        getMap tmp[0], tmp[1], 0
        mov player[ebx].tail[0], al
        getMap tmp[0], tmp[1], 1
        mov player[ebx].tail[1], al
        INVOKE setMap, tmp[0], tmp[1], 0, -1

    .ENDIF

    inc ecx
    jmp GROW

END_GROW:
    ; get food
    mov ecx, 0
GET_FOOD:
    .IF playerCount == cl
        jmp START_move
    .ENDIF

    mov al, cl
    mov bl, SIZEOF PLAYER
    mul bl
    movzx ebx, ax

    mov ah, food[0]
    mov al, food[1]
    .IF player[ebx].head[0] == ah && player[ebx].head[1] == al

        add player[ebx].grow, 3
        movzx eax, player[ebx].earn
        add player[ebx].score, eax
        inc player[ebx].earn
        mov eax, player[ebx].score
        INVOKE printInteger, 21, 0, eax
        INVOKE foodRevive

    .ENDIF

    inc ecx
    jmp GET_FOOD

END_move:
   ret
move ENDP

waiting PROC
    
    INVOKE printString, 0, 0, ADDR waitMsg
    INVOKE printInteger, 6, 0, 3
    INVOKE Sleep, 1000
    INVOKE printInteger, 6, 0, 2
    INVOKE Sleep, 1000
    INVOKE printInteger, 6, 0, 1
    INVOKE Sleep, 1000
    INVOKE printString, 0, 0, ADDR space2
    INVOKE printString, 2, 0, ADDR space2
    INVOKE printString, 4, 0, ADDR space2
    INVOKE printString, 6, 0, ADDR space2

    ret

waiting ENDP

paint PROC USES eax ebx ecx edx esi,
    x:BYTE, y:BYTE, route:DWORD
    LOCAL xx:BYTE
    
    mov al, x
    mov player[0].head[0], al
    mov al, y
    mov player[0].head[1], al

    mov al, 2
    mov dl, player[0].head[0]
    mul dl
    mov xx, al
    INVOKE printString, xx, player[0].head[1], ADDR headP1Image

    mov esi, route
LWHILE:
        mov al, [esi]
        .IF al == 0
            jmp LOUT
        .ENDIF
        
        INVOKE Sleep, 20
        mov al, 2
        mov dl, player[0].head[0]
        mul dl
        mov xx, al
        INVOKE printString, xx, player[0].head[1], ADDR bodyImage

        mov al, [esi]
        .IF al == 'u'
            dec player[0].head[1]
        .ELSEIF al == 'd'
            inc player[0].head[1]
        .ELSEIF al == 'l'
            dec player[0].head[0]
        .ELSEIF al == 'r'
            inc player[0].head[0]
        .ENDIF

        mov al, 2
        mov dl, player[0].head[0]
        mul dl
        mov xx, al
        INVOKE printString, xx, player[0].head[1], ADDR headP1Image

        inc esi

        jmp LWHILE

LOUT:
    INVOKE Sleep, 20
    mov al, 2
    mov dl, player[0].head[0]
    mul dl
    mov xx, al
    INVOKE printString, xx, player[0].head[1], ADDR bodyImage

    ret
paint ENDP

gameover PROC USES eax

    ; TODO score = life * 100 did not implement yet

    INVOKE printString, 15, 0, ADDR scoreMsg
    mov eax, player[0].score
    INVOKE printInteger, 21, 0, eax
    INVOKE printString, 35, 0, ADDR lengthMsg
    movzx eax, player[0].leng
    INVOKE printInteger, 42, 0, eax
    INVOKE printString, 55, 0, ADDR lifeMsg
    movzx eax, player[0].life
    INVOKE printInteger, 60, 0, eax

    .IF playerCount == 2

        INVOKE printString, 15, 24, ADDR scoreMsg
        mov eax, player[SIZEOF PLAYER].score
        INVOKE printInteger, 21, 24, eax
        INVOKE printString, 35, 24, ADDR lengthMsg
        movzx eax, player[SIZEOF PLAYER].leng
        INVOKE printInteger, 42, 24, eax
        INVOKE printString, 55, 24, ADDR lifeMsg
        movzx eax, player[SIZEOF PLAYER].life
        INVOKE printInteger, 61, 24, eax

        mov eax, player[SIZEOF PLAYER].score
        .IF eax == player[0].score
            INVOKE printString, 38, 2, ADDR tieMsg
        .ELSEIF eax > player[0].score
            INVOKE printString, 36, 2, ADDR p2WinMsg
        .ELSE
            INVOKE printString, 36, 2, ADDR p1WinMsg
        .ENDIF

    .ENDIF

    INVOKE paint, 9, 2, ADDR g
    INVOKE paint, 18, 11, ADDR a
    INVOKE paint, 19, 4, ADDR m1
    INVOKE paint, 21, 5, ADDR m2
    INVOKE paint, 24, 5, ADDR m3
    INVOKE paint, 31, 8, ADDR e1
    INVOKE paint, 9, 22, ADDR o
    INVOKE paint, 14, 16, ADDR v
    INVOKE paint, 25, 19, ADDR e2
    INVOKE paint, 32, 16, ADDR r1
    INVOKE paint, 34, 17, ADDR r2

    ret

gameover ENDP

;-------------------------
getHeadImage PROC,
    select:BYTE
;return
;    eax: offset of the head image
;-------------------------
    movzx eax, select
    mov bl, 3
    mul bl 
    ret
getHeadImage ENDP

drawMenu PROC

    INVOKE printString, 13, 8, ADDR menuHead
    movzx ecx, optionCount
    mov ax, 9
L1:
    INVOKE printString, 13, ax, ADDR menuBody
    inc ax
    loop L1
    INVOKE printString, 13, ax, ADDR menuFoot

    .IF menuState == 0
    
        INVOKE printString, 35, 9, ADDR mainMenuMsg1
        INVOKE printString, 35, 10, ADDR mainMenuMsg2
        INVOKE printString, 35, 11, ADDR mainMenuMsg3
        INVOKE printString, 35, 12, ADDR mainMenuMsg4

        movzx ax, menuSelect
        add ax, 9
        INVOKE printString, 13, ax, ADDR menuBody

        INVOKE SetConsoleTextAttribute, consoleHandle, 12

        .IF menuSelect == 0
            INVOKE printString, 35, 9, ADDR mainMenuMsg1
        .ELSEIF menuSelect == 1
            INVOKE printString, 35, 10, ADDR mainMenuMsg2
        .ELSEIF menuSelect == 2
            INVOKE printString, 35, 11, ADDR mainMenuMsg3
        .ELSEIF menuSelect == 3
            INVOKE printString, 35, 12, ADDR mainMenuMsg4
        .ENDIF

        INVOKE SetConsoleTextAttribute, consoleHandle, 7

    .ELSEIF menuState == 1

        INVOKE printString, 25, 9, ADDR settingMsg1
        INVOKE printString, 25, 10, ADDR settingMsg2
        INVOKE printString, 25, 11, ADDR settingMsg3
        INVOKE printString, 25, 12, ADDR settingMsg4
        INVOKE printString, 50, 13, ADDR settingMsg5

        INVOKE getHeadImage, headStyle
        INVOKE printString, 51, 9, ADDR headImage[eax]
        
        INVOKE getHeadImage, headStyle[1]
        INVOKE printString, 51, 11, ADDR headImage[eax]

        movzx eax, colorStyle
        movzx eax, colorCode[eax]
        shl eax, 4
        INVOKE SetConsoleTextAttribute, consoleHandle, eax
        INVOKE printString, 51, 10, ADDR space2 
        INVOKE SetConsoleTextAttribute, consoleHandle, 7

        movzx eax, colorStyle[1]
        movzx eax, colorCode[eax]
        shl eax, 4
        INVOKE SetConsoleTextAttribute, consoleHandle, eax
        INVOKE printString, 51, 12, ADDR space2 
        INVOKE SetConsoleTextAttribute, consoleHandle, 7

        .IF menuSelect[1]  != 4

            INVOKE SetConsoleTextAttribute, consoleHandle, 12
            movzx eax, menuSelect[1]
            add eax, 9
            INVOKE printString, 48, ax,  ADDR pointer
            INVOKE SetConsoleTextAttribute, consoleHandle, 7

        .ELSE
            
            INVOKE SetConsoleTextAttribute, consoleHandle, 12
            INVOKE printString, 50, 13, ADDR settingMsg5
            INVOKE SetConsoleTextAttribute, consoleHandle, 7

        .ENDIF

    .ENDIF

    ret

drawMenu ENDP

menu PROC
    
    mov optionCount, 4
    mov menuState, 0
    mov menuSelect, 0
    mov menuSelect[1], 0
    
LWHILE:
    cls
    INVOKE drawMenu
    call crt__getch
    
    .IF al == -32

        call crt__getch

        .IF menuState == 0 ; main menu
        
            .IF al == 80
          
                inc menuSelect
                .IF menuSelect >= 4
                    mov menuSelect, 0
                .ENDIF

            .ELSEIF al == 72

                dec menuSelect
                .IF menuSelect == -1
                    mov menuSelect, 3
                .ENDIF

            .ENDIF

        .ELSEIF menuState == 1 ; setting menu
    
            .IF al == 80
          
                inc menuSelect[1]
                .IF menuSelect[1] >= 5
                    mov menuSelect[1], 0
                .ENDIF

            .ELSEIF al == 72

                dec menuSelect[1]
                .IF menuSelect[1] == -1
                    mov menuSelect[1], 4
                .ENDIF
                
            .ELSEIF al == 75 ; left

                .IF menuSelect[1] == 0

                    dec headStyle
                    .IF headStyle == -1
                        mov headStyle, headImageCount - 1
                    .ENDIF

                .ELSEIF menuSelect[1] == 1

                    dec colorStyle
                    .IF colorStyle == -1
                        mov colorStyle, colorCodeCount - 1
                    .ENDIF

                .ELSEIF menuSelect[1] == 2

                    dec headStyle[1]
                    .IF headStyle[1] == -1
                        mov headStyle[1], headImageCount - 1
                    .ENDIF

                .ELSEIF menuSelect[1] == 3

                    dec colorStyle[1]
                    .IF colorStyle[1] == -1
                        mov colorStyle[1], colorCodeCount - 1
                    .ENDIF

                .ENDIF

            .ELSEIF al == 77 ; right

                .IF menuSelect[1] == 0

                    inc headStyle
                    .IF headStyle == headImageCount
                        mov headStyle, 0
                    .ENDIF

                .ELSEIF menuSelect[1] == 1

                    inc colorStyle
                    .IF colorStyle == colorCodeCount
                        mov colorStyle, 0
                    .ENDIF

                .ELSEIF menuSelect[1] == 2

                    inc headStyle[1]
                    .IF headStyle[1] == headImageCount
                        mov headStyle[1], 0
                    .ENDIF

                .ELSEIF menuSelect[1] == 3

                    inc colorStyle[1]
                    .IF colorStyle[1] == colorCodeCount
                        mov colorStyle[1], 0
                    .ENDIF

                .ENDIF

            .ENDIF

        .ENDIF

    .ELSEIF al == 13

        .IF menuState == 0

            .IF menuSelect == 0
                    
                mov playerCount, 1
                jmp LOUT

            .ELSEIF menuSelect == 1

                mov playerCount, 2
                jmp LOUT

            .ELSEIF menuSelect == 2

                mov optionCount, 5
                mov menuState, 1

            .ELSEIF menuSelect == 3

                INVOKE ExitProcess, 0

            .ENDIF

        .ELSEIF menuState == 1

            .IF menuSelect[1] == 4 ; back to main menu

                cld
                INVOKE getHeadImage, headStyle
                mov esi, OFFSET headImage
                add esi, eax
                mov edi, OFFSET headP1Image
                mov ecx, 2          
                rep movsb

                cld
                INVOKE getHeadImage, headStyle[1]
                mov esi, OFFSET headImage
                add esi, eax
                mov edi, OFFSET headP2Image
                mov ecx, 2          
                rep movsb
                           
                mov optionCount, 4
                mov menuState, 0

            .ENDIF

        .ENDIF

    .ENDIF

    jmp LWHILE

LOUT:
    cls
    ret

menu ENDP

start@0 PROC
    
    LOCAL structCursorInfo:CONSOLE_CURSOR_INFO
    LOCAL xx:BYTE

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov consoleHandle, eax

    INVOKE GetConsoleCursorInfo, consoleHandle, ADDR structCursorInfo
    mov structCursorInfo.bVisible, FALSE
    INVOKE SetConsoleCursorInfo, consoleHandle, ADDR structCursorInfo


PMENU:
    INVOKE menu
restart:
    INVOKE initialize
    INVOKE printString, 35, 16, ADDR pressEnter
PENTER:
    call crt__getch
    .IF ax == 13
        jmp START
    .ENDIF
    jmp PENTER

START:
    mov edx, 17
L1:
    .IF dl == 23
        jmp LOUT
    .ENDIF

    mov al, 2
    mul dl 
    mov xx, al
    getMap dl, 15, 0
    .IF al == 0
        INVOKE printString, xx, 16, ADDR idk
    .ELSEIF al == -2
        INVOKE printString, xx, 16, ADDR foodImage
    .ELSE
        INVOKE printString, xx, 16, ADDR space2
    .ENDIF
    inc dl

    jmp L1

LOUT:
    INVOKE CreateThread, NULL, 0, ADDR turn, 0, THREAD_PRIORITY_NORMAL, NULL
    INVOKE move
    cls
    INVOKE gameover
    mov over, 1
    INVOKE keybd_event, VK_SPACE, 0, 0, 0
    INVOKE printString, 34, 14, ADDR restartMsg
    call crt__getch
    .IF al == 'n' || al == 'N'
        jmp PMENU
    .ENDIF
    cls
	jmp restart

start@0 ENDP
END start@0