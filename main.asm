INCLUDE Irvine32.inc
printInteger PROTO, x:WORD, y:WORD, value:DWORD
printString	 PROTO, x:WORD, y:WORD, string:DWORD
.data
consoleHandle DWORD ?
msg BYTE "sadfasdf16565", 0
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
	INVOKE SetConsoleCursorPosition, consoleHandle, pos
	mov eax, value
	call WriteDec
	ret
printInteger ENDP

;--------------------------------
printString PROC USES edx,
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
	INVOKE SetConsoleCursorPosition, consoleHandle, pos
	mov edx, string
	call WriteString
	ret
printString ENDP

start@0 PROC

	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle, eax

	; Test function code	
	INVOKE printInteger, 5, 5, 126
	INVOKE printString, 15, 15, OFFSET msg


	exit
start@0 ENDP
END start@0