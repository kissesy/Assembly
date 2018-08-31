extern printf
extern scanf 

%include "asm_io.inc"

segment .data 
msg db "input your number :  ", 0
format_scanf db "%d", 0

segment .bss
input resd 1

segment .text
global asm_main

asm_main:
enter 0,0
pusha

push msg
call printf
add esp, 4 
push input
push format_scanf
call scanf 
add esp, 4

push dword  [input]
call bin 
add esp, 4 
popa
leave
ret 

;십진수를 바이너리로 보여줌 
segment .data 
bin_array times 100 dd 0 
bin_print db "%d ", 0
segment .bss

segment .text 
global bin 

bin: 
push ebp,
mov ebp, esp
sub esp, 12 

push eax 
mov eax, [ebp+8] ;input value 
mov [ebp-4], eax ;이제 사용할 값  
pop eax
mov ebx, 2
mov dword [ebp-8], 0 ; ecx값 임시로 저장  

while_loop: 
mov ecx, [ebp-8] 
mov eax, 0
mov edx, 0
mov eax, [ebp-4] 
cdq 
idiv ebx ;idiv를 쓰면 ecx값이 바뀌는 거 같던뎀
mov [ebp-4], eax 
mov ecx, [ebp-8]  
mov [bin_array+ecx], edx
;add ecx, 4 
;mov [ebp-8], ecx
cmp eax, 0 ;eax가 0이 될 시 
je print_bin
add ecx, 4
mov [ebp-8], ecx
jmp while_loop   

print_bin: 
mov [ebp-8], ecx
push dword [bin_array+ecx]
push bin_print 
call printf
add esp, 8 
mov ecx, [ebp-8]
sub ecx, 4 
cmp ecx, 0 
jl end_loop
jmp print_bin 

end_loop:
add esp, 12
pop ebp 
leave
ret 
 










