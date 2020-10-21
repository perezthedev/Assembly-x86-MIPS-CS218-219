;	boot section
mov ah, 0x0e
mov al, 65
int 0x10

mov cl, 25
alphabetLoop:
	inc al
	int 0x10	; call interrupt to print
	loop alphabetLoop

jmp $	; jmp to current address

times 510-($-$$) db 0	; times instruction repeats an action n number of times
db 0x55, 0xaa