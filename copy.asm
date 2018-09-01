global asm_copy, asm_find, asm_strlen, asm_strcpy

segment .text 
;void asm_copy(void* dest, const void* src, unsigned sz); 
; dest - 복사 될 것이 저장될 버퍼를 가리키는 포인터 
; src - 복사 될 버퍼를 가리키는 포인터 
; sz - 복사 할 바이트 수 

%define dest [ebp+8]
%define src [ebp+12]
%define sz [ebp+16] 

asm_copy: 
enter 0,0 
push esi
push edi 

mov esi, src  ;esi = 복사 될 버퍼의 주소 
mov edi, dest ;edi = 복사 된 것이 저장할 버퍼의 주소 
mov ecx, sz ; ecx = 복사 할 바이트 수 

cld  ;방향 플래그를 초기화 시킨다. 
rep movsb ; movsb를 ecx만큼 반복시킨다. (메모리 주소의 내용을 옮기넹) 
;원래lodsb로 esi에서 al로 옮기고 stosb로 al에서 edi로 옮긴다. 
pop edi 
pop esi 
leave 
ret 

;asm_find 함수 
;메모리에서 특정한 바이트를 검색한다. 
;void* ams_find(const void* src, char target, unsigned sz);
;인자 :
;src : 검색할 버퍼를 가리키는 포인터 
;target : 검색할 바이트 값 
;sz : 버퍼의 바이트 크기 
;리턴값 
;만일 target을 찾았다면 버퍼에서 첫 번째 target울 가리키는 포인터가 리턴된다. 
;그렇치 않으면 NULL이 리턴된다. 
; target은 바이트 값이지만 스택엔 더블워드의 형태로 푸시된다. 
; 따라서 바이트 값은 하위 8 비트에 저장된다. 
%define src [ebp+8]
%define target [ebp+12]
%define sz [ebp+16]

asm_find:
enter 0,0 
push edi 

mov eax, target ;al은 검색할 바이트 값을 보관
mov edi, src 
mov ecx, sz 
cld 

repne scasb ; ECX == 0 혹은 [ES:EDI] == AL 때 까지 검색 

je found_it ;Z 플래그가 세트되었다면 검색에 성공  
mov eax, 0  ; 찾지 못했다면 NULL 포인터를 리턴 
jmp short quit 

found_it: 
mov eax, edi 
dec eax ;찾았다면 (DI-1)을 리턴 

quit: 
pop edi 
leave 
ret 

;asm_strlen 함수 
;문자열의 크기를 리턴 
; unsigned asm_strlen(const char * ); 
; 인자 
; stc - 문자열을 가리키는 포인터 
; 리턴 값 : 문자열 에서의 char의 수 (마지막 0은 세지 않는다) eax로 리턴 

%define src [ebp+8]
asm_strlen: 
enter 0,0 
push edi 

mov edi, src ;edi = 문자열을 가리키는 포인터 
mov ecx, 0ffffffffh ;ecx 값으로 가능한 가장 큰 값 
xor al, al ; al = 0 
cld 

repnz scasb ;종료 0을 찾는다. 
; => 무조건 한 번은 실행한다는 건가 그래서 FFFFFFFE로 계산하는거네 
;
;repnz은 한 단계 더 실행되기 때문에 그 길이는 FFFFFFFE -ecx가 아닌 FFFFFFFF -ECX다 

mov eax, 0FFFFFFFEh
sub eax, ecx ;길이 = 0FFFFFFFEh - ecx 

pop edi 
leave 
ret 

;asm_strcpy 
; 문자열을 복사한다 
; void asm_strcpy(char* dest, const char * src)

%define dest [ebp+8]
%define src [ebp+12] 

asm_strcpy: 
enter 0,0 
push esi 
push edi 
mov edi, dest 
mov esi, src 
cld 

cpy_loop:
lodsb ;AL을 불러오고 & SI를 증가 
stosb ;AL을 저장하고 & DI를 증가 
or al, al ; 조건 플래그를 세트한다. 끝에 널문자 때문에 
jnz cpy_loop ; 만일 종료 0을 지나지 않았다면, 계속 진행

pop edi
pop esi
leave 
ret  
























































