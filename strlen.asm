%include "asm_io.inc"

segment .bss 
	input resd 0

segment .data 
	string db "Hello", 0	
	print db "%d", 0

segment .text 
	global asm_main
	extern printf

asm_main:
	push ebp 
	mov ebp, esp
	sub esp, 4

	mov esi, string ;문자열의 주소를 넘김 
	xor eax, eax 
re: 
	cmp byte [esi], 0
	je end
	inc eax 
	inc esi 
	jmp re

end: 
	mov [input], eax 
	
	push dword [input] 
	push print 
	call printf
	add esp, 8 

	call print_nl

	mov esp, ebp 
	pop ebp 
	ret 
