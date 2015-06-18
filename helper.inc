mulb MACRO val:REQ
	push ebx
	xor ebx, ebx
	mov bl, val
	mul bl
	pop ebx
ENDM
	