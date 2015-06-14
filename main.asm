include \masm32\include\masm32rt.inc
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib

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
map           BYTE gameWidth * gameHeight * 2 dup(?)
head          BYTE ?, ?
tail          BYTE ?, ?
direct        BYTE ?, ?
forbidDirect  BYTE ?, ?
grow          BYTE ?, ?
food          BYTE ?, ?
speed         WORD ?
life          WORD ?

earn          WORD ?
over          WORD ?
score         WORD ?
leng          WORD ?
player        BYTE  ?
tmp           WORD ?

foodImage     BYTE "��", 0
initSnake     BYTE "��������", 0

restartMsg    BYTE "Play Again(Y/N)", 0
scoreMsg      BYTE "Score:", 0
lengthMsg     BYTE "Length:", 0
lifeMsg       BYTE "Life:", 0
pressEnter    BYTE "Press Enter", 0
idk           BYTE "�i", 0
space         BYTE " ", 0
space2        BYTE "  ", 0
headP1Image   BYTE "��", 0
headP2Image   BYTE "��", 0

consoleHandle DWORD ?
threadID      DWORD ?

.code
;-----------------------------------------
;Note: 1DArrays in this program are in type of BYTE!
set1DArray MACRO arr:REQ, x:REQ, value:REQ
;arr: OFFSET of the array
;x: index
;value: in BYTE type!
;-----------------------------------------
	push esi
	push eax
	push ebx

	mov eax, 0
	mov ebx, TYPE BYTE
	mov al, x
	mul bl
	mov esi, arr
	add esi, eax

	mov BYTE PTR [esi], value

	pop ebx
	pop eax
	pop esi
ENDM

;------------------------------------------
setMap MACRO x:REQ, y:REQ, z:REQ, value:REQ
;x, y, z: index
;value: in BYTE type!
;-----------------------------------------
	push eax
	push ebx
	push esi
	mov eax, 0
	mov ebx, 0

	mov al, gameWidth
	mov bl, x
	mul bl
	add al, y
	mov bl, z
	inc bl
	mul bl

	mov esi, OFFSET map
	add esi, eax
	mov BYTE PTR [esi], value

	pop esi
	pop ebx
	pop eax
ENDM

;--------------------------------
getMap MACRO x:REQ, y:REQ, z:REQ
;x, y, z: index
;value: in BYTE type!
;return
;	al: map[x][y][z]
;-----------------------------------------
	push ebx
	push esi
	mov eax, 0
	mov ebx, 0

	mov al, gameWidth
	mov bl, x
	mul bl
	add al, y
	mov bl, z
	inc bl
	mul bl

	mov esi, OFFSET map
	add esi, eax
	mov eax, 0
	mov al, [esi]

	pop esi
	pop ebx
ENDM

.data
formatInteger   BYTE "%d", 0

.code
;--------------------------------
printInteger PROC USES eax,
	x:WORD, y:WORD, value:DWORD
	LOCAL pos:COORD
; x, y: position
; value: the integer to be displayed
;
; display a integer value on the (x, y)
;--------------------------------
	mov ax, x
	mov pos.x, ax
	mov ax, y
	mov pos.y, ax
	INVOKE SetConsoleCursorPosition, consoleHandle, DWORD PTR [pos]
    INVOKE crt_printf, ADDR formatInteger, value
	ret
printInteger ENDP

;--------------------------------
printString PROC USES ecx edx,
	x:WORD, y:WORD, string:DWORD
	LOCAL pos:COORD
; x, y: position
; string: The OFFSET of the string
;
; display a string on the (x, y)
;--------------------------------
	mov dx, x
	mov pos.x, dx
	mov dx, y
	mov pos.y, dx
	INVOKE SetConsoleCursorPosition, consoleHandle, DWORD PTR [pos]
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

;--------------------------------
turn PROC USES eax ebx edx esi edi
;turn the snake's direction
;--------------------------------
START_turn:

   call crt__getch

   mov edi, OFFSET direct
   mov esi, OFFSET forbidDirect

   .IF player == 2
      
      ; do until player1 done.

   .ENDIF

   .IF ax == -32
      call crt__getch
      .IF ax == 72 ; white arrow up
         cmp BYTE PTR [esi], 0
         pushfd
         cmp BYTE PTR [esi+1], -1
         pushfd
         pop eax
         and eax, [esp]
         add esp, 4
         .IF eax & 64
            jmp START_turn
         .ENDIF
         mov BYTE PTR [edi], 0
         mov BYTE PTR [edi+1], -1
      .ELSEIF ax == 80 ; white arrow down
         cmp BYTE PTR [esi], 0
         pushfd
         cmp BYTE PTR [esi+1], 1
         pushfd
         pop eax
         and eax, [esp]
         add esp, 4
         .IF eax & 64
            jmp START_turn
         .ENDIF
         mov BYTE PTR [edi], 0
         mov BYTE PTR [edi+1], 1
      .ELSEIF ax == 75 ; white arrow left 
         cmp BYTE PTR [esi], -1
         pushfd
         cmp BYTE PTR [esi+1], 0
         pushfd
         pop eax
         and eax, [esp]
         add esp, 4
         .IF eax & 64
            jmp START_turn
         .ENDIF
         mov BYTE PTR [edi], -1
         mov BYTE PTR [edi+1], 0
      .ELSEIF ax == 77 ; white arrow right
         cmp BYTE PTR [esi], 1
         pushfd
         cmp BYTE PTR [esi+1], 0
         pushfd
         pop eax
         and eax, [esp]
         add esp, 4
         .IF eax & 64
            jmp START_turn
         .ENDIF
         mov BYTE PTR [edi], 1
         mov BYTE PTR [edi+1], 0     
      .ENDIF
   .ENDIF
   jmp START_turn
END_turn:
   ret
turn ENDP

;--------------------------------
foodRevive PROC USES eax ebx ecx edx,

	LOCAL flag:BYTE
;as title
;-------------------------------
	mov flag, 0
	mov esi, OFFSET map
	mov eax, 0
	mov ecx, gameHeight * gameWidth
L1:
	mov al, BYTE PTR [esi]
	.IF al == -1
		mov flag, 1
	.ENDIF
	inc esi
	loop L1

	.IF flag == 0
		set1DArray OFFSET food, 0, 100
		jmp LEND
	.ENDIF

CHECK_POS:
    mov edx, 0
    INVOKE crt_rand
    mov ebx, gameWidth
    div ebx
	set1DArray OFFSET food, 0, dl
    mov edx, 0
    INVOKE crt_rand
    mov ebx, gameHeight
    div ebx
	set1DArray OFFSET food, 1, dl
	getMap food, food + TYPE food, 0

	.IF al == -1
		jmp SET_FOOD
	.ENDIF
	jmp CHECK_POS

SET_FOOD:
	setMap food, food + TYPE food, 0, -2
	INVOKE printMapItem, food, food + TYPE food, ADDR foodImage
LEND:
	ret
foodRevive ENDP

;--------------------------------
initialize PROC USES eax ebx ecx

    LOCAL _st:SYSTEMTIME
;initialize the snake game
;--------------------------------
	mov ax, 50
	mov speed, ax
	mov ax, 3
	mov life, ax

	mov esi, OFFSET map
	mov ecx, gameHeight * gameWidth * 2

	; initilize map array
L1:
	mov BYTE PTR [esi], -1
	inc esi
	loop L1
	
	setMap 18, 9, 0, 19
	setMap 18, 9, 1, 9
	setMap 19, 9, 0, 20
	setMap 19, 9, 1, 9
	setMap 20, 9, 0, 21
	setMap 20, 9, 1, 9
	setMap 21, 9, 0, 0
	mov earn, 1
	mov over, 0
	mov score, 0
	mov grow, 0
	mov leng, 4
	set1DArray OFFSET head, 0, 21
	set1DArray OFFSET head, 1, 9
	set1DArray OFFSET tail, 0, 21
	set1DArray OFFSET tail, 1, 9
	set1DArray OFFSET direct, 0, 1
	set1DArray OFFSET direct, 1, 0
	set1DArray OFFSET forbidDirect, 0, -1
	set1DArray OFFSET forbidDirect, 1, 0
	INVOKE printString, 15, 0, ADDR scoreMsg
	mov ax, score
	INVOKE printInteger, 21, 0, eax
	INVOKE printString, 35, 0, ADDR lengthMsg
	mov ax, leng
	INVOKE printInteger, 42, 0, eax
	INVOKE printString, 55, 0, ADDR lifeMsg
	mov ax, life
	INVOKE printInteger, 61, 0, eax
	INVOKE printString, 36, 10, ADDR initSnake

	.IF player == 2

		; todo:
		; until the basic snake done, lets do the 2 players

	.ENDIF

    INVOKE GetSystemTime, ADDR _st
    movzx  eax, SYSTEMTIME.wMilliseconds[_st]
    INVOKE crt_srand, eax

	INVOKE foodRevive

	ret
initialize ENDP

revive PROC USES eax ebx ecx edx,
    mode:BYTE
    LOCAL tmp1[2]:BYTE
    LOCAL tmp2[2]:BYTE
    
    .IF mode == 0
        mov leng, 4
        mov al, tail
        mov tmp1, al
        mov al, tail + TYPE tail
        mov tmp1 + TYPE tail, al

        mov ecx, 3
L1:
        mov al, tmp1
        mov tmp2, al
        mov al, tmp1 + TYPE tmp1
        mov tmp2 + TYPE tmp2, al
        getMap tmp2, tmp2 + TYPE tmp2, 0
        mov tmp1, al
        getMap tmp2, tmp2 + TYPE tmp2, 1
        mov tmp1 + TYPE tmp1, al
        loop L1

        mov al, tmp1
        mov head, al
        mov al, tmp1 + TYPE tmp1
        mov head + TYPE head, al
        mov al, tmp1
        sub al, tmp2
        mov direct, al
        mov al, tmp1 + TYPE tmp1
        sub al, tmp2 + TYPE tmp2
        mov direct + TYPE direct, al
        mov al, direct
        neg al
        mov forbidDirect, al
        mov al, direct + TYPE direct
        neg al
        mov forbidDirect + TYPE forbidDirect, al
        
        getMap tmp1, tmp1 + TYPE tmp1, 0
        .IF al != 100
            mov al, tmp1
            mov tmp2, al
            mov al, tmp1 + TYPE tmp1
            mov tmp2 + TYPE tmp2, al
            getMap tmp2, tmp2 + TYPE tmp2, 0
            mov tmp1, al
            getMap tmp2, tmp2 + TYPE tmp2, 1
            mov tmp1 + TYPE tmp1, al

            getMap tmp1, tmp1 + TYPE tmp, 0
LWHITE:     
            .IF al == 100
                jmp LOUT
            .ENDIF

            mov al, tmp1
            mov tmp2, al
            mov al, tmp1 + TYPE tmp1
            mov tmp2 + TYPE tmp2, al
            getMap tmp2, tmp2 + TYPE tmp2, 0
            mov tmp1, al
            getMap tmp2, tmp2 + TYPE tmp2, 1
            mov tmp1 + TYPE tmp1, al
            setMap tmp2, tmp2 + TYPE tmp2, 0, -1
            INVOKE printMapItem, tmp2, tmp2 + TYPE tmp2, ADDR space2
            jmp LWHITE

LOUT:       
            setMap tmp1, tmp1 + TYPE tmp1, 0, -1
            INVOKE printMapItem, tmp1, tmp1 + TYPE tmp1, ADDR space2
        .ENDIF
        setMap head, head + TYPE head, 0, 100
        INVOKE printMapItem, head, head + TYPE head, ADDR headP1Image

    .ELSE

        ; 2P snake

    .ENDIF

    .IF food == 100
        INVOKE foodRevive
    .ENDIF

revive ENDP

move PROC

move ENDP

gameover PROC

gameover ENDP

testThread PROC
infloop:
	.IF over == 0
		INVOKE foodRevive
		INVOKE Sleep, 500
		jmp infloop
	.ENDIF

	ret
testThread ENDP

start@0 PROC
    
    LOCAL structCursorInfo:CONSOLE_CURSOR_INFO

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov consoleHandle, eax

    INVOKE GetConsoleCursorInfo, consoleHandle, ADDR structCursorInfo
    mov structCursorInfo.bVisible, FALSE
    INVOKE SetConsoleCursorInfo, consoleHandle, ADDR structCursorInfo

    ; INVOKE GetLastError

	; Test function code	
	; INVOKE printInteger, 5, 5, 5
	; INVOKE printString, 15, 15, ADDR testmsg
	; INVOKE turn

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
	mov ecx, 7
	mov edx, 17
L1:
	getMap dl, 15, 0
	mov al, dl
	mov bl, 2
	mul bl
	.IF al == 0
		INVOKE printString, dl, 16, ADDR idk
	.ELSEIF al == -2
		INVOKE printString, dl, 16, ADDR foodImage
	.ELSE
		INVOKE printString, dl, 16, ADDR space
	.ENDIF
	inc dl
	loop L1

	; create Thread here
	; INVOKE CreateThread, NULL, 0, ADDR turn, 0, THREAD_PRIORITY_NORMAL, NULL
	INVOKE CreateThread, NULL, 0, ADDR testThread, 0, THREAD_PRIORITY_NORMAL, NULL
	call crt__getch
	mov over, 1

	INVOKE move
    cls
	INVOKE gameover
	mov over, 1
	INVOKE printString, 34, 14, ADDR restartMsg
	call crt__getch
	.IF ax == 316Eh ; n
        INVOKE ExitProcess, 0
	.ELSEIF ax == 314Eh ; N
		INVOKE ExitProcess, 0
	.ENDIF

	jmp restart
start@0 ENDP
END start@0