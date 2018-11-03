;일단 필요한 함수 strlen, strcpy구현

%include "asm_io.inc"

segment .bss 

segment .data
	format1 db "%s", 0
	format2 db "%d", 0 
	print1 db "input your key(0~25) : ", 0
	print_en db "~~~~~~~~~Encrypto!~~~~~~~~", 0 
	print_cr db "~~~~~~~~~Crypto~~~~~~~~~", 0
	print_key db "key number is %d :  ", 0

segment .txt 
	global asm_main
	global strlen_s		
	global strcpy 
	global crypto
	global encrypto
	extern printf 
	extern scanf 
	extern gets
	extern strlen 
	
asm_main: 
	push ebp 
	mov ebp, esp 
	sub esp, 80 ;buffer
	sub esp, 8 ;문자열의 길이, key value  

	lea eax, [ebp-80]
	push eax 
	call gets
	add esp, 4 

	lea eax, [ebp-80]
	push eax 
	push format1
	call printf
	add esp, 8

	call print_nl
	
	lea eax, [ebp-80] 
	push eax ;string push! 
	call strlen_s ;c library 호출 	
	;call strlen_s ;strlen 호출  
	add esp, 4

	mov [ebp-84], eax ;plain의 문자열 길이 변수 
	;dump_regs 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input key 
	push print1	
	push format1
	call printf 
	add esp, 8

	lea eax, [ebp-88] ;key value 
	push eax
	push format2
	call scanf 
	add esp, 8

	;xor edx, edx 
	;mov edx, [ebp-84] 
	;dump_regs 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lea eax, [ebp-80] 	;buffer ebp+16
	push eax 
	push dword [ebp-84] ;length ebp+12
	push dword [ebp-88] ;key	ebp+8
	call crypto ;암호화 진행 함수  
	add esp, 12

	push print_cr
	push format1 
	call printf 
	add esp, 8 
	call print_nl 

	lea eax, [ebp-80]
	push eax
	push format1 
	call printf 
	add esp, 8 
	call print_nl 

;;;;;;;;;;;;;복호화 진행 함수;;;;;;;;;;;;;;;;[ebp-80]을 복호화 
	push print_en 
	push format1 
	call printf 
	add esp, 8 
	call print_nl 

	lea eax, [ebp-80] 
	push eax 
	call encrypto ;복호화진행 함수 
	add esp, 4 

	add esp, 88
	leave
	ret

strlen_s: ;문자열의 길이를 반환하는 함수 널문자는 배제 +8 
	push ebp 
	mov ebp, esp
	mov esi, [ebp+8] ;버퍼의 주소를 땀 
	;mov esi, eax  ;간접연산 
	xor ecx, ecx 
	jmp strlen_start_len 
	
strlen_start_len: 
	lodsb 
	cmp al, 0x0 ;널까지하고 앞에 개행을 널로 바꿔주자 
	je strlen_end 
	inc ecx 
	;add esi, 1
	jmp strlen_start_len

strlen_end: 
	mov eax, ecx ;return string length 
	pop ebp 
	ret 

strcpy: ;문자열을 카피해주는 함수 널문자 포함 [ebp+8]dest, [ebp+12]src 
	push ebp 
	mov ebp, esp
	mov esi, [ebp+12] 
	mov edi, [ebp+8]

strcpy_start:
	cmp byte [esi], 0x00
	je end 
	lodsb 
	stosb 
	jmp strcpy_start 

end: ;마지막에 null문자 삽입
	mov byte [edi], 0x0
	pop ebp 
	ret 

crypto: 
	push ebp 
	mov ebp, esp 
	xor ecx, ecx 
	mov esi, [ebp+16] 
	mov edi, [ebp+16]
	mov ecx, [ebp+12]
	xor eax, eax 
	xor ebx, ebx 

crypto_starting:  ;[ebp+8]key [ebp+12]length [ebp+16]buffer
	;xor eax, eax
	lodsb ;al = [esi], esi+=1
	cmp eax, 0x20
	je crypto_set_space
	mov ebx, [ebp+8] ;key
	sub eax, 0x41 ; byte esi로 안해도 되는가 
	add eax, ebx
	mov ebx, 26 
	;dump_regs 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	CDQ 
	idiv ebx ;edx에는 나머지가 들어감
	;dump_regs 1
	add edx, 0x41 
	;dump_regs 1
	mov al, dl 
	stosb
	loop crypto_starting  

crypto_end:
	leave 
	ret 
	
crypto_set_space:
	dec ecx
	stosb
	jmp crypto_starting

encrypto: 
	push ebp 
	mov ebp, esp
	sub esp, 80	;key값 대로 복호화를 진행된 buffer 항상 strcpy로 값을 넣는다. 
	sub esp, 12 ;순서대로 key, len, i
	mov dword  [ebp-84], 0 ; key
	mov dword [ebp-88], 0 ; len 
	mov dword [ebp-92], 0 ; i 
	xor eax, eax 
	xor ebx, ebx 
	xor edx, edx	
	mov eax, [ebp+8] 
	push eax 
	call strlen ;기존 문자열의 길이 eax에 들어감
	add esp, 4 
	mov [ebp-88], eax 
	
encrypto_start_1_for:
	xor ecx, ecx 	
	cmp dword  [ebp-84], 26 ;key값이 26일때 ㅑ
	je encrypto_end 
	lea eax, [ebp-80] ;dest
	mov ebx, [ebp+8]  ;src  
	push ebx 
	push eax 
	call strcpy ;문자열 카피 
	add esp, 8 
	lea esi, [ebp-80]  ;같은 곳을 지목하게 하자 
	lea edi, [ebp-80]

encrypto_start_2_for:  ;ecx는 키의 길이 
	cmp ecx, [ebp-88]	;eax에는 길이가 들어감	
	je print_encrypto
	xor eax, eax 
	lodsb ; al = [esi], add esi, 1
	cmp eax, 0x20 
	je set_space
	;;;;;;;;;;;;;;;;;;;본격적으로 복호화 
	sub eax, 0x41 
	sub eax, [ebp-84] 
	add eax, 26 
	mov ebx, 26 
	CDQ	
	idiv ebx 
	add dl, 0x41 
	mov al, dl 
	stosb 
	inc ecx 
	jmp encrypto_start_2_for

encrypto_end:
	mov esp, 92
	leave 
	ret 

set_space: 
	stosb 
	inc ecx 
	jmp encrypto_start_2_for

print_encrypto:  
	push dword [ebp-84]
	push print_key	
	call printf 
	add esp, 8 

	push eax
	lea eax, [ebp-80] 
	push eax 
	push format1
	call printf 
	add esp, 8
	pop eax 
	call print_nl
	push eax 
	xor eax, eax 
	mov eax, [ebp-84], 
	inc eax 
	mov [ebp-84], eax 
	pop eax 
	xor ecx, ecx 
	jmp encrypto_start_1_for











