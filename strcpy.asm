%include "asm_io.inc"

segment .bss 

segment .data 
	src db "hello my friend", 0
	dest times 100 db 0
	format db "%s", 0

segment .text 
	extern printf 
	global asm_main 

asm_main: 
	push ebp 
	mov esp, ebp 
	mov esi, src 
	mov edi, dest ;주소를 준거기에 잘 적용되지 않을까.... 

re: 
	cmp byte [esi], 0x00 
	je end 
	lodsb
	stosb
	jmp re 

end: 
	push dest 
	push format 
	call printf 
	add esp, 8 
	call print_nl

	mov esp, ebp 
	pop ebp 
	ret 
	
