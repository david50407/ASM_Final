
INCLUDE Irvine32.inc
.data
consoleHandle    DWORD ?
xyInit COORD <0,0> ; 起始座標
xyBound COORD <42,4> ; 一個頁面最大的邊界
xyPos COORD <0,0> ; 現在的游標位置
; 102502012 - 102502042

.code
main PROC

; Get the Console standard output handle:
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov consoleHandle,eax
	
; 設定回到起始位置
INITIAL:
	mov ax,xyInit.x
	mov xyPos.x,ax
	mov ax,xyInit.y
	mov xyPos.y,ax
START:
	call ClrScr
	INVOKE SetConsoleCursorPosition, consoleHandle, xyPos
	call ReadChar
	.IF ax == 1177h ;UP
		sub xyPos.y,1
	.ENDIF
	.IF ax == 1F73h ;DOWN
		add xyPos.y,1
	.ENDIF
	.IF ax == 1e61h ;LEFT
		sub xyPos.x,1
	.ENDIF
	.IF ax == 2064h ;RIGHT
		add xyPos.x,1
	.ENDIF
	.IF ax == 011Bh ;ESC
		jmp END_FUNC
	.ENDIF
	
	; 檢查作完上下左右後有沒有超過限制邊界
	.IF xyPos.x == -1 ;x lowerbound
		inc xyPos.x
		jmp START ; 跳去設定初始
	.ENDIF
	mov ax,xyBound.x ; 註：比較不能用雙定址，故將其中一個轉成 register
	.IF xyPos.x == ax ;x upperbound
		dec xyPos.x
		jmp START
	.ENDIF
	
	.IF xyPos.y == -1 ;y lowerbound
		inc xyPos.y
		jmp START
	.ENDIF
	mov ax,xyBound.y
	.IF xyPos.y == ax ;y upperbound
		dec xyPos.y
		jmp START
	.ENDIF
	
	jmp START
END_FUNC:
	exit
main ENDP

END main