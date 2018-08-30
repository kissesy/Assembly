%include "asm_io.inc"
extern printf

segment .data 
format db "%d x %d = %d", 0
hello db "Hello this is a group of game", 0
;nl db "========== ", 0

segment .bss
input resd 0 ;합을 저장할 변수 

segment .text
global asm_main

asm_main:
enter 4,0 
pusha 

push hello
call printf 
add esp, 4
call print_nl 
mov eax, 1 ;i 
mov ebx, 1 ;j 

gugu_eax_loop:
mov ebx, 1 
cmp eax, 10
jg gugu_loop_end

gugu_ebx_loop: 
cmp ebx, 10
jg setting_eax

push eax
IMUL eax, ebx
mov [input], eax ; backup output 
pop eax 

mov [ebp-4], eax
push dword [input]
push ebx
push eax
push format 
call printf ;반환값이 eax에 쌓이넹 
mov eax, [ebp-4]
add esp, 16 
call print_nl

inc ebx 
jmp gugu_ebx_loop

setting_eax:
inc eax
call print_nl
jmp gugu_eax_loop

gugu_loop_end:
popa
leave
ret 


