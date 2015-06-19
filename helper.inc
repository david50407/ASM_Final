KEY_SPECL = -32
KEY_UP    =  72
KEY_DOWN  =  80
KEY_LEFT  =  75
KEY_RIGHT =  77
KEY_A     = 'a'
KEY_W     = 'w'
KEY_S     = 's'
KEY_D     = 'd'
KEY_ENTER =  13

COLOR_BLACK    = 0
COLOR_BLUE     = 1
COLOR_GREEN    = 2
COLOR_VIRIDITY = 3
COLOR_RED      = 4
COLOR_PURPLE   = 5
COLOR_YELLOW   = 6
COLOR_WHITE    = 7
COLOR_BRIGHT_BLACK    = COLOR_BLACK    + 8
COLOR_BRIGHT_BLUE     = COLOR_BLUE     + 8
COLOR_BRIGHT_GREEN    = COLOR_GREEN    + 8
COLOR_BRIGHT_VIRIDITY = COLOR_VIRIDITY + 8
COLOR_BRIGHT_RED      = COLOR_RED      + 8
COLOR_BRIGHT_PURPLE   = COLOR_PURPLE   + 8
COLOR_BRIGHT_YELLOW   = COLOR_YELLOW   + 8
COLOR_BRIGHT_WHITE    = COLOR_WHITE    + 8

STYLE_PREVIEW_PADD = 2

mulb MACRO val:REQ
	push ebx
	xor ebx, ebx
	mov bl, val
	mul bl
	pop ebx
ENDM

optionListRolling MACRO val:REQ, len:REQ
	.IF val == -1
		mov val, len
		sub val, 1
	.ELSEIF val == len
		mov val, 0
	.ENDIF
ENDM

PLAYER STRUCT

    head         BYTE ?, ?
    tail         BYTE ?, ?
    direct       BYTE ?, ?
    forbidDirect BYTE ?, ?
    grow         BYTE ?
    life         BYTE ?
    leng         WORD ?
    earn         WORD ?
    score        DWORD ?
    headImage    BYTE "◎", 0
    bodyImage    BYTE "●", 0
    color        BYTE ?

PLAYER ENDS
