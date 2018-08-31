%define NL 10
%define CF_MASK 00000001h
%define PF_MASK 00000004h
%define AF_MASK 00000010h
%define ZF_MASK 00000040h
%define SF_MASK 00000080h
%define DF_MASK 00000400h
%define OF_MASK 00000800h

%ifdef ELF_TYPE
  %define _scanf   scanf
  %define _printf  printf
  %define _getchar getchar
  %define _putchar putchar
  %define _fputs   fputs
%endif

%ifdef OBJ_TYPE
segment .data public align=4 class=data use32
%else
segment .data
%endif

int_format    db  "%i", 0
string_format       db  "%s", 0
reg_format    db  "Register Dump # %d", NL
   db  "EAX = %.8X EBX = %.8X ECX = %.8X EDX = %.8X", NL
                    db  "ESI = %.8X EDI = %.8X EBP = %.8X ESP = %.8X", NL
                    db  "EIP = %.8X FLAGS = %.4X %s %s %s %s %s %s %s", NL
           db  0
carry_flag    db  "CF", 0
zero_flag    db  "ZF", 0
sign_flag    db  "SF", 0
parity_flag    db "PF", 0
overflow_flag    db "OF", 0
dir_flag    db "DF", 0
aux_carry_flag    db "AF", 0
unset_flag    db "  ", 0
mem_format1         db  "Memory Dump # %d Address = %.8X", NL, 0
mem_format2         db  "%.8X ", 0
mem_format3         db  "%.2X ", 0
stack_format        db  "Stack Dump # %d", NL
           db  "EBP = %.8X ESP = %.8X", NL, 0
stack_line_format   db  "%+4d  %.8X  %.8X", NL, 0
math_format1        db  "Math Coprocessor Dump # %d Control Word = %.4X"
                    db  " Status Word = %.4X", NL, 0
valid_st_format     db  "ST%d: %.10g", NL, 0
invalid_st_format   db  "ST%d: Invalid ST", NL, 0
empty_st_format     db  "ST%d: Empty", NL, 0

%ifdef OBJ_TYPE
segment text public align=1 class=code use32
%else
segment .text
%endif
global read_int, print_int, print_string, read_char
global  print_char, print_nl, sub_dump_regs, sub_dump_mem
        global  sub_dump_math, sub_dump_stack
        extern  _scanf, _printf, _getchar, _putchar, _fputs

read_int:
enter 4,0
pusha
pushf

lea eax, [ebp-4]
push eax
push dword int_format
call _scanf
pop ecx
pop ecx
popf
popa
mov eax, [ebp-4]
leave
ret

print_int:
enter 0,0
pusha
pushf

push eax
push dword int_format
call _printf
pop ecx
pop ecx

popf
popa
leave
ret

print_string:
enter 0,0
pusha
pushf

push eax
push    dword string_format
call _printf
pop ecx
pop ecx

popf
popa
leave
ret

read_char:
enter 4,0
pusha
pushf

call _getchar
mov [ebp-4], eax

popf
popa
mov eax, [ebp-4]
leave
ret

print_char:
enter 0,0
pusha
pushf

push eax
call _putchar
pop ecx

popf
popa
leave
ret


print_nl:
enter 0,0
pusha
pushf

push dword 10
call _putchar
pop ecx

popf
popa
leave
ret


sub_dump_regs:
enter   4,0
pusha
pushf
mov     eax, [esp]
mov [ebp-4], eax

test eax, CF_MASK
jz cf_off
mov eax, carry_flag
jmp short push_cf
cf_off:
mov eax, unset_flag
push_cf:
push eax

test dword [ebp-4], PF_MASK
jz pf_off
mov eax, parity_flag
jmp short push_pf
pf_off:
mov eax, unset_flag
push_pf:
push eax

test dword [ebp-4], AF_MASK
jz af_off
mov eax, aux_carry_flag
jmp short push_af
af_off:
mov eax, unset_flag
push_af:
push eax

test dword [ebp-4], ZF_MASK
jz zf_off
mov eax, zero_flag
jmp short push_zf
zf_off:
mov eax, unset_flag
push_zf:
push eax

test dword [ebp-4], SF_MASK
jz sf_off
mov eax, sign_flag
jmp short push_sf
sf_off:
mov eax, unset_flag
push_sf:
push eax

test dword [ebp-4], DF_MASK
jz df_off
mov eax, dir_flag
jmp short push_df
df_off:
mov eax, unset_flag
push_df:
push eax

test dword [ebp-4], OF_MASK
jz of_off
mov eax, overflow_flag
jmp short push_of
of_off:
mov eax, unset_flag
push_of:
push eax

push    dword [ebp-4]
mov eax, [ebp+4]
sub eax, 10
push eax
lea     eax, [ebp+12]
push    eax
push    dword [ebp]
        push    edi
        push    esi
push    edx
push ecx
push ebx
push dword [ebp-8]
push dword [ebp+8]
push dword reg_format
call _printf
add esp, 76
popf
popa
leave
ret     4

sub_dump_stack:
enter   0,0
pusha
pushf

lea     eax, [ebp+20]
push    eax
push    dword [ebp]
push dword [ebp+8]
push dword stack_format
call _printf
add esp, 16

mov ebx, [ebp]
mov eax, [ebp+16]
shl eax, 2
add ebx, eax
mov edx, [ebp+16]
mov ecx, edx
add ecx, [ebp+12]
inc ecx

stack_line_loop:
push edx
push ecx

push dword [ebx]
push ebx
mov eax, edx
sal eax, 2
push eax
push dword stack_line_format
call _printf
add esp, 16

pop ecx
pop edx

sub ebx, 4
dec edx
loop stack_line_loop

popf
popa
leave
ret     12


sub_dump_mem:
enter 0,0
pusha
pushf

push dword [ebp+12]
push dword [ebp+16]
push dword mem_format1
call _printf
add esp, 12 
mov esi, [ebp+12]
and esi, 0FFFFFFF0h
mov ecx, [ebp+8]
inc ecx
mem_outer_loop:
push ecx
push esi
push dword mem_format2
call _printf
add esp, 8

xor ebx, ebx
mem_hex_loop:
xor eax, eax
mov al, [esi + ebx]
push eax
push dword mem_format3
call _printf
add esp, 8
inc ebx
cmp ebx, 16
jl mem_hex_loop
mov eax, '"'
call print_char
xor ebx, ebx
mem_char_loop:
xor eax, eax
mov al, [esi+ebx]
cmp al, 32
jl non_printable
cmp al, 126
jg non_printable
jmp short mem_char_loop_continue
non_printable:
mov eax, '?'
mem_char_loop_continue:
call print_char

inc ebx
cmp ebx, 16
jl mem_char_loop

mov eax, '"'
call print_char
call print_nl

add esi, 16
pop ecx
loop mem_outer_loop

popf
popa
leave
ret 12

sub_dump_math:
enter 116,0
pusha
pushf

fsave [ebp-108]
mov eax, [ebp-104]
and eax, 0FFFFh
push eax
mov eax, [ebp-108]
and eax, 0FFFFh
push eax
push dword [ebp+8]
push dword math_format1
call _printf
add esp, 16

mov cx, [ebp-104]
shr cx, 11
and cx, 7
mov bx, [ebp-100]
shl     cl,1
ror bx, cl

mov edi, 0
lea esi, [ebp-80]
mov ecx, 8
tag_loop:
push ecx
mov ax, 3
and ax, bx
or ax, ax
je valid_st
cmp ax, 1
je zero_st
cmp ax, 2
je invalid_st
push edi
push dword empty_st_format
call _printf
add esp, 8
jmp short cont_tag_loop
zero_st:
fldz
jmp short print_real
valid_st:
fld tword [esi]
print_real:
fstp qword [ebp-116]
push dword [ebp-112]
push dword [ebp-116]
push edi
push dword valid_st_format
call _printf
add esp, 16
jmp short cont_tag_loop
invalid_st:
push edi
push dword invalid_st_format
call _printf
add esp, 8
cont_tag_loop:
ror bx, 2
inc edi
add esi, 10
pop ecx
loop    tag_loop

frstor [ebp-108]
popf
popa
leave
ret 4
