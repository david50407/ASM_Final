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
map           SBYTE gameWidth * gameHeight * 2 dup(?)
head          BYTE ?, ?, ?, ?
tail          BYTE ?, ?, ?, ?
direct        SBYTE ?, ?, ?, ?
forbidDirect  SBYTE ?, ?, ?, ?
grow          BYTE ?, ?
food          BYTE ?, ?
speed         BYTE ?
life          BYTE ?, ?
earn          WORD ?, ?
over          BYTE ?
score         DWORD ?, ?
leng          WORD ?, ?
player        BYTE  ?

foodImage     BYTE "¡°", 0
initP1Snake   BYTE "¡´¡´¡´¡·", 0
initP2Snake   BYTE "¡´¡´¡´¡ó", 0

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
menuHead      BYTE "¢~¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢¡", 0
menuBody      BYTE "¢x¡@¡@¡@¡@                                        ¡@¢x", 0
menuFoot      BYTE "¢¢¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢£", 0
optionCount   BYTE ?

.code
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

	mov al, gameHeight
	mov bl, x
	mul bl
    mov bl, y
    movzx ebx, bl
	add eax, ebx
    mov bl, z
    .IF bl == 1
        add ax, gameWidth * gameHeight
    .ENDIF

	mov esi, OFFSET map
	add esi, eax
	mov SBYTE PTR [esi], value

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

	mov al, gameHeight
	mov bl, x
	mul bl
    mov bl, y
    movzx ebx, bl
	add eax, ebx
    mov bl, z
    .IF bl == 1
        add ax, gameWidth * gameHeight
    .ENDIF

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
printString PROC USES eax ecx edx,
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

turn PROC USES eax ebx edx
;turn the snake's direction
;--------------------------------
START_turn:

   call crt__getch

   .IF over
      jmp END_turn
   .ENDIF

   .IF player == 2
      .IF al == 'w'
         .IF forbidDirect[2] == 0 && forbidDirect[3] == -1
            jmp START_turn
         .ENDIF
         mov direct[2], 0
         mov direct[3], -1
      .ELSEIF al == 'd'
         .IF forbidDirect[2] == 1 && forbidDirect[3] == 0
            jmp START_turn
         .ENDIF
         mov direct[2], 1
         mov direct[3], 0
      .ELSEIF al == 's'
         .IF forbidDirect[2] == 0 && forbidDirect[3] == 1
            jmp START_turn
         .ENDIF
         mov direct[2], 0
         mov direct[3], 1
      .ELSEIF al == 'a'
         .IF forbidDirect[2] == -1 && forbidDirect[3] == 0
            jmp START_turn
         .ENDIF
         mov direct[2], -1
         mov direct[3], 0
      .ENDIF
   .ENDIF

   .IF al == -32
      call crt__getch
      .IF al == 72 ; white arrow up
         .IF forbidDirect[0] == 0 && forbidDirect[1] == -1
            jmp START_turn
         .ENDIF
         mov direct[0], 0
         mov direct[1], -1
      .ELSEIF al == 80 ; white arrow down
         .IF forbidDirect[0] == 0 && forbidDirect[1] == 1
            jmp START_turn
         .ENDIF
         mov direct[0], 0
         mov direct[1], 1
      .ELSEIF al == 75 ; white arrow left 
         .IF forbidDirect[0] == -1 && forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov direct[0], -1
         mov direct[1], 0
      .ELSEIF al == 77 ; white arrow right
         .IF forbidDirect[0] == 1 && forbidDirect[1] == 0
            jmp START_turn
         .ENDIF
         mov direct[0], 1
         mov direct[1], 0     
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
	setMap food, food + TYPE food, 0, -2
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
	mov al, 50
	mov speed, al
	mov al, 3
	mov life, al

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
    setMap i, j, 0, -1
    inc j
    loop L2
L1END:
    inc i
    loop L1
LOUT:
	
	setMap 18, 9, 0, 19
	setMap 18, 9, 1, 9
	setMap 19, 9, 0, 20
	setMap 19, 9, 1, 9
	setMap 20, 9, 0, 21
	setMap 20, 9, 1, 9
	setMap 21, 9, 0, 100
	mov earn, 1
	mov over, 0
	mov score, 0
	mov grow, 0
	mov leng, 4
    mov head, 21
    mov head + TYPE head, 9
    mov tail, 18
    mov tail + TYPE tail, 9
    mov direct, 1
    mov direct + TYPE direct, 0
    mov forbidDirect, -1
    mov forbidDirect + TYPE forbidDirect, 0
	INVOKE printString, 15, 0, ADDR scoreMsg
	mov eax, score
	INVOKE printInteger, 21, 0, eax
	INVOKE printString, 35, 0, ADDR lengthMsg
	movzx eax, leng
	INVOKE printInteger, 42, 0, eax
	INVOKE printString, 55, 0, ADDR lifeMsg
	movzx eax, life
	INVOKE printInteger, 60, 0, eax
	INVOKE printString, 36, 10, ADDR initP1Snake

	.IF player == 2

        mov score + TYPE score , 0
        setMap 18, 12, 0, 19
        setMap 18, 12, 1, 12
        setMap 19, 12, 0, 20
        setMap 19, 12, 1, 12
        setMap 20, 12, 0, 21
        setMap 20, 12, 1, 12
        setMap 21, 12, 0, 100
        mov head + 2 * TYPE head, 21
        mov head + 3 * TYPE head, 12
        mov tail + 2 * TYPE tail, 18
        mov tail + 3 * TYPE tail, 12
        mov direct + 2 * TYPE direct, 1
        mov direct + 3 * TYPE direct, 0
        mov forbidDirect + 2 * TYPE forbidDirect, -1
        mov forbidDirect + 3 * TYPE forbidDirect, 0
        mov grow + TYPE grow, 0
        mov leng + TYPE leng, 4
        mov earn + TYPE earn, 1
        mov life + TYPE life, 3
        INVOKE printString, 15, 24, ADDR scoreMsg
	    mov eax, score
	    INVOKE printInteger, 21, 24, eax
	    INVOKE printString, 35, 24, ADDR lengthMsg
	    movzx eax, leng + TYPE leng
	    INVOKE printInteger, 42, 24, eax
	    INVOKE printString, 55, 24, ADDR lifeMsg
	    movzx eax, life + TYPE life
	    INVOKE printInteger, 60, 24, eax
	    INVOKE printString, 36, 13, ADDR initP2Snake

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
        mov tmp1 + TYPE tmp1, al

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

LWHITE:     
            getMap tmp1, tmp1 + TYPE tmp1, 0
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

        mov leng + TYPE leng, 4
        mov al, tail + 2 * TYPE tail
        mov tmp1, al
        mov al, tail + 3 * TYPE tail
        mov tmp1 + TYPE tmp1, al

        mov ecx, 3
L2:
        mov al, tmp1
        mov tmp2, al
        mov al, tmp1 + TYPE tmp1
        mov tmp2 + TYPE tmp2, al
        getMap tmp2, tmp2 + TYPE tmp2, 0
        mov tmp1, al
        getMap tmp2, tmp2 + TYPE tmp2, 1
        mov tmp1 + TYPE tmp1, al
        loop L2

        mov al, tmp1
        mov head + 2 * TYPE head, al
        mov al, tmp1 + TYPE tmp1
        mov head + 3 * TYPE head, al
        mov al, tmp1
        sub al, tmp2
        mov direct + 2 * TYPE direct, al
        mov al, tmp1 + TYPE tmp1
        sub al, tmp2 + TYPE tmp2
        mov direct + 3 * TYPE direct, al
        mov al, direct + 2 * TYPE direct
        neg al
        mov forbidDirect + 2 * TYPE forbidDirect, al
        mov al, direct + 3 * TYPE direct
        neg al
        mov forbidDirect + 3 * TYPE forbidDirect, al

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

LWHITE2:     
            getMap tmp1, tmp1 + TYPE tmp1, 0
            .IF al == 100
                jmp LOUT2
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
            jmp LWHITE2

LOUT2:       
            setMap tmp1, tmp1 + TYPE tmp1, 0, -1
            INVOKE printMapItem, tmp1, tmp1 + TYPE tmp1, ADDR space2
        .ENDIF
        setMap head + 2 * TYPE head, head + 3 * TYPE head, 0, 100
        INVOKE printMapItem, head + 2 * TYPE head, head + 3 * TYPE head, ADDR headP2Image

    .ENDIF

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
   mov al, head[0]
   add al, direct[0]
   add al, 40
   mov bl, 40
   div bl
   mov th[0], ah

   mov ax, 0
   mov al, head[1]
   add al, direct[1]
   add al, 23
   mov bl, 23
   div bl
   mov th[1], ah

   mov ax, 0
   mov al, head[2]
   add al, direct[2]
   add al, 40
   mov bl, 40
   div bl
   mov th[2], ah
 
   mov ax, 0
   mov al, head[3]
   add al, direct[3]
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
 
   .IF player == 2 && ((bh != -1 && bh != -2 && bl != -1 && bl != -2) || (th[0] == dh && th[1] == dl))
      dec life
      dec life[1]
      shr score, 1
      shr score[4], 1
      .IF life == 0 || life[1] == 0
         jmp END_move
      .ENDIF
      INVOKE printString, 21, 0, OFFSET space13
      INVOKE printString, 21, 24, OFFSET space13
      mov eax, score
      INVOKE printInteger, 21, 0, eax
      mov eax, score[4]
      INVOKE printInteger, 21, 24, eax
      INVOKE printString, 42, 0, OFFSET space13
      INVOKE printString, 42, 24, OFFSET space13
      INVOKE printInteger, 42, 0, 4
      INVOKE printInteger, 42, 24, 4
      movzx eax, life
      INVOKE printInteger, 60, 0, eax
      movzx eax, life[1]
      INVOKE printInteger, 60, 24, eax
      INVOKE revive, 0
      INVOKE revive, 1
      call waiting
      jmp START_move
   .ELSEIF al != -1 && al != -2
      .IF player == 2
         shr score, 1
         mov eax, score
         add score[4], eax
         dec life
         .IF life == 0
            jmp END_move
         .ENDIF
         INVOKE printString, 21, 0, OFFSET space13
         INVOKE printString, 21, 24, OFFSET space13
         mov eax, score
         INVOKE printInteger, 21, 0, eax
         mov eax, score[4]
         INVOKE printInteger, 21, 24, eax
         INVOKE printString, 42, 0, OFFSET space13
         INVOKE printInteger, 42, 0, 4
         movzx eax, life
         INVOKE printInteger, 60, 0, eax
         INVOKE revive, 0
         call waiting
         jmp START_move
      .ELSE
         dec life
         .IF life == 0
            jmp END_move
         .ENDIF
         shr score, 1
         INVOKE printString, 21, 0, OFFSET space13
         mov eax, score
         INVOKE printInteger, 21, 0, eax
         INVOKE printString, 42, 0, OFFSET space13
         INVOKE printInteger, 42, 0, 4
         movzx eax, life
         INVOKE printInteger, 60, 0, eax
         INVOKE revive, 0
         call waiting
         jmp START_move
      .ENDIF
   .ELSEIF player == 2 && bl != -1 && bl != -2
      shr score[4], 1
      mov eax, score[4]
      add score, eax
      dec life[1]
      .IF life[1] == 0
         jmp END_move
      .ENDIF
      INVOKE printString, 21, 0, OFFSET space13
      INVOKE printString, 21, 24, OFFSET space13
      mov eax, score
      INVOKE printInteger, 21, 0, eax
      mov eax, score[4]
      INVOKE printInteger, 21, 24, eax
      INVOKE printString, 42, 24, OFFSET space13
      INVOKE printInteger, 42, 24, 4
      movzx eax, life[1]
      INVOKE printInteger, 60, 24, eax
      INVOKE revive, 1
      call waiting
      jmp START_move
   .ENDIF

   INVOKE printMapItem, head[0], head[1], ADDR bodyImage
   mov dl, th[0]
   setMap head[0], head[1], 0, dl
   mov dl, th[1]
   setMap head[0], head[1], 1, dl
   mov al, th[0]
   mov head[0], al
   mov al, th[1]
   mov head[1], al
   .IF player == 2

       INVOKE printMapItem, head[2], head[3], ADDR bodyImage
       mov dl, th[2]
       setMap head[2], head[3], 0, dl
       mov dl, th[3]
       setMap head[2], head[3], 1, dl
       mov al, th[2]
       mov head[2], al
       mov al, th[3]
       mov head[3], al

   .ENDIF

   setMap head[0], head[1], 0, 100
   INVOKE printMapItem, head[0], head[1], ADDR headP1Image
   mov al, direct[0]
   neg al
   mov forbidDirect[0], al
   mov al, direct[1]
   neg al
   mov forbidDirect[1], al
   .IF player == 2

       setMap head[2], head[3], 0, 100
       INVOKE printMapItem, head[2], head[3], ADDR headP2Image
       mov al, direct[2]
       neg al
       mov forbidDirect[2], al
       mov al, direct[3]
       neg al
       mov forbidDirect[3], al

   .ENDIF

   .IF grow
      dec grow
      inc leng
      movzx eax, leng
      INVOKE printInteger, 42, 0, eax
   .ELSE
      INVOKE printMapItem, tail[0], tail[1], ADDR space2
      mov al, tail[0]
      mov tmp[0], al
      mov al, tail[1]
      mov tmp[1], al
      getMap tmp[0], tmp[1], 0
      mov tail[0], al
      getMap tmp[0], tmp[1], 1
      mov tail[1], al
      setMap tmp[0], tmp[1], 0, -1
   .ENDIF
   .IF grow[1]
        
      dec grow[1]
      inc leng + TYPE leng
      movzx eax, leng + TYPE leng
      INVOKE printInteger, 42, 24, eax

   .ELSEIF player == 2

      INVOKE printMapItem, tail[2], tail[3], ADDR space2
      mov al, tail[2]
      mov tmp[0], al
      mov al, tail[3]
      mov tmp[1], al
      getMap tmp[0], tmp[1], 0
      mov tail[2], al
      getMap tmp[0], tmp[1], 1
      mov tail[3], al
      setMap tmp[0], tmp[1], 0, -1

   .ENDIF

   mov ah, food[0]
   mov al, food[1]
   .IF head[0] == ah && head[1] == al
      add grow, 3
      movzx eax, earn
      add score, eax
      inc earn
      mov eax, score
      INVOKE printInteger, 21, 0, eax
      INVOKE foodRevive
   .ENDIF

   .IF player == 2 && head[2] == ah && head[3] == al
        
      add grow[1], 3
      movzx eax, earn + TYPE earn
      add score + TYPE score, eax
      inc earn + TYPE earn
      mov eax, score + TYPE score
      INVOKE printInteger, 21, 24, eax
      INVOKE foodRevive

   .ENDIF

   jmp START_move

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
    mov head, al
    mov al, y
    mov head + TYPE head, al

    mov al, 2
    mov dl, head
    mul dl
    mov xx, al
    INVOKE printString, xx, head + TYPE head, ADDR headP1Image

    mov esi, route
LWHILE:
        mov al, [esi]
        .IF al == 0
            jmp LOUT
        .ENDIF
        
        INVOKE Sleep, 20
        mov al, 2
        mov dl, head
        mul dl
        mov xx, al
        INVOKE printString, xx, head + TYPE head, ADDR bodyImage

        mov al, [esi]
        .IF al == 'u'
            dec head+TYPE head
        .ELSEIF al == 'd'
            inc head+TYPE head
        .ELSEIF al == 'l'
            dec head
        .ELSEIF al == 'r'
            inc head
        .ENDIF

        mov al, 2
        mov dl, head
        mul dl
        mov xx, al
        INVOKE printString, xx, head + TYPE head, ADDR headP1Image

        inc esi

        jmp LWHILE

LOUT:
    INVOKE Sleep, 20
    mov al, 2
    mov dl, head
    mul dl
    mov xx, al
    INVOKE printString, xx, head + TYPE head, ADDR bodyImage

    ret
paint ENDP

gameover PROC USES eax

    ; TODO score = life * 100 did not implement yet

    INVOKE printString, 15, 0, ADDR scoreMsg
    mov eax, score
    INVOKE printInteger, 21, 0, eax
    INVOKE printString, 35, 0, ADDR lengthMsg
    movzx eax, leng
    INVOKE printInteger, 42, 0, eax
    INVOKE printString, 55, 0, ADDR lifeMsg
    movzx eax, life
    INVOKE printInteger, 60, 0, eax

    .IF player == 2

        INVOKE printString, 15, 24, ADDR scoreMsg
        mov eax, score + TYPE score 
        INVOKE printInteger, 21, 24, eax
        INVOKE printString, 35, 24, ADDR lengthMsg
        movzx eax, leng + TYPE leng
        INVOKE printInteger, 42, 24, eax
        INVOKE printString, 55, 24, ADDR lifeMsg
        movzx eax, life + TYPE life
        INVOKE printInteger, 61, 24, eax

        mov eax, score + TYPE score
        .IF eax == score
            INVOKE printString, 38, 2, ADDR tieMsg
        .ELSEIF eax > score
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
        INVOKE SetConsoleTextAttribute, consoleHandle, 14

        .IF menuSelect == 0
            INVOKE printString, 35, 9, ADDR mainMenuMsg1
        .ELSEIF menuSelect == 1
            INVOKE printString, 35, 10, ADDR mainMenuMsg2
        .ELSEIF menuSelect == 2
            INVOKE printString, 35, 11, ADDR mainMenuMsg3
        .ELSEIF menuSelect == 3
            INVOKE printString, 35, 12, ADDR mainMenuMsg4
        .ENDIF

        INVOKE SetConsoleTextAttribute, consoleHandle, 15

    .ELSEIF menuState == 1

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
    .IF menuState == 0 ; main menu
        
        .IF al == 80
          
            inc menuSelect
            .IF menuSelect >= 4
                mov menuSelect, 0
            .ENDIF

        .ELSEIF al == 72

            dec menuSelect
            .IF menuSelect == -1
                mov menuSelect, 2
            .ENDIF

        .ELSEIF al == 13

            .IF menuSelect == 0
                    
                mov player, 1
                jmp LOUT

            .ELSEIF menuSelect == 1

                mov player, 2
                jmp LOUT

            .ELSEIF menuSelect == 2

                mov menuState, 1

            .ELSEIF menuSelect == 3

                INVOKE ExitProcess, 0

            .ENDIF

        .ENDIF

    .ELSEIF menuState == 1 ; setting menu
    
        .IF al == 80
          
            dec menuSelect[1]
            .IF menuSelect[1] == -1
                mov menuSelect[1], 2
            .ENDIF

        .ELSEIF al == 72

            inc menuSelect[1]
            .IF menuSelect[1] >= 5
                mov menuSelect[1], 0
            .ENDIF

        .ELSEIF al == 13

            .IF menuSelect == 4 ; back to main menu

                mov menuState, 0

            .ENDIF

        .ELSEIF al == 75 ; left

        .ELSEIF al == 77 ; right

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