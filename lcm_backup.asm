extern printf
extern scanf

%include "asm_io.inc"

segment .data
format_msg db "%d %d lcm is %d",10, 0
msg db "input your two number :  ", 0
format_input db "%d %d", 0

segment .bss
input1 resd 1
input2 resd 1

segment .text
global asm_main

asm_main:
enter 0,0 
pusha 

push msg
call printf
add esp, 4

push input2
push input1
push format_input
call scanf
add esp, 12
mov eax, 0 ; return input 0 

push dword [input1] ;umm.. maybe i push address? 
push dword [input2]
call lcm
add esp, 8
popa
leave
ret 




;LCM FUNCTION
segment .data 

segment .bss
input1_1 resd 1
input2_2 resd 1 

segment .text
global lcm

;first set memory +12 after clear 
lcm: 
push ebp
mov ebp, esp
sub esp, 12; input1, input2 backup, mul sum ecx
mov eax, 0 
mov eax, [ebp+12]
mov [input1_1], eax
mov eax, 0
mov eax, [ebp+8]
mov [input2_2], eax
mov ecx, 2 ; divide (pi) 
mov dword [ebp-12], 1 ; choi!  

lcm_loop:
;sub esp, 4 ; tmp room 
;mov [ebp-4], [input1] ;backup

mov eax, 0
mov edx, 0 
cdq ;edx:eax
mov eax, [input1_1]
cmp eax, ecx
jl end_loop
idiv ecx 
cmp edx, 0 ;check edx 
je another_check; if edx == 0  
jmp setting_ecx ;if edx != 0

setting_ecx:
inc ecx 
jmp lcm_loop  
 
another_check:
mov [ebp-4], eax ;input1 
mov eax, 0
mov edx, 0
cdq
mov eax, [input2_2]
;cmp eax, ecx
;jl end_loop

idiv ecx 
cmp edx, 0
je ok_loop ;if edx == 0 
jmp setting_ecx ; if edx != 0

ok_loop: 
mov [ebp-8], eax ;input2
mov eax, 0
push ebx
mov ebx, [ebp-12]  
imul ebx, ecx 
mov [ebp-12], ebx 
pop ebx   
jmp setting_input

setting_input: ;input값을 다시 조정 
push eax 
mov eax, 0
mov eax, [ebp-4] 
mov [input1_1], eax
pop eax
push eax  
mov eax, 0
mov eax, [ebp-8] 
mov [input2_2], eax 
pop eax  
jmp lcm_loop 

end_loop:
mov ecx, [ebp-12]
mov eax, [input1_1]
imul ecx, eax
mov eax, [input2_2]
imul ecx, eax  
push ecx 
push dword [ebp+12]
push dword [ebp+8]
push format_msg
call printf
add esp, 16
add esp, 12 
leave
ret  




















