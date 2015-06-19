KEY_SPECL = -32
KEY_UP    =  72
KEY_DOWN  =  80
KEY_LEFT  =  75
KEY_RIGHT =  77
KEY_A     =  'a'
KEY_W     =  'w'
KEY_S     =  's'
KEY_D     =  'd'

mulb MACRO val:REQ
	push ebx
	xor ebx, ebx
	mov bl, val
	mul bl
	pop ebx
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