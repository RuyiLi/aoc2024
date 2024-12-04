; nasm reference 	http://home.myfairpoint.net/fbkotler/nasmdocc.html
; registers 			https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
; syscall opcodes https://filippo.io/linux-syscall-table/

section .data
donttxt:	db	"don't()"


section .bss
input:	resb	32 * 1024


section .text
global _start


; rdi = long to print
; noreturn
lngprint:
	push rax
	push rbx
	push rdx
	push rsi
	push rdi

	mov		rax, rdi
	mov		rdi, rsp
	mov		rbx, 10

	dec		rdi
	mov		rdx, 10									; newline
	mov		[rdi], dl
.nextdigit
	cmp		rax, 0
	je		.end
	
	dec		rdi
	mov 	rdx, 0
	div		rbx											; rax = rax // 10, rdx = rax % 10
	add		dl, "0"									; dl is byte of rdx
	mov 	[rdi], dl

	jmp .nextdigit
.end:
	mov 	rdx, rsp 
	sub		rdx, rdi
	mov 	rsi, rdi
	mov		rdi, 1
	mov 	rax, 1
	syscall
	
	pop 	rdi
	pop 	rsi
	pop 	rdx
	pop 	rbx
	pop 	rax

  ret


; rdi = ptr to string
; returns length of string
strlen:
	push	rbx
	mov 	rbx, rdi
	mov 	rax, 0
strlen_nextchr:
	cmp 	byte [rbx], 0
	je 		strlen_endloop
	inc 	rax
	inc		rbx
	jmp		strlen_nextchr
strlen_endloop:
	pop		rbx
	ret

; rdi = ptr to string
; returns ptr to input string
strprint:
	push	rdx
	push	rsi
	push	rdi

	call 	strlen
	mov 	rdx, rax 
	pop 	rsi
	mov		rdi, 1
	mov 	rax, 1
	syscall
	
	mov 	rax, rsi
	mov 	rdi, rsi
	pop 	rsi
	pop		rdx
	ret

; rdi = ptr to string
; rsi = char to end on
;	if successful, rdi is moved to the character after the end character
; otherwise, rdi is moved to the first invalid character
; returns the parsed number or -1
parsenum:
	push 	r9
	push 	rbx
	mov 	rbx, 0									; resultant number
.nextchr:
	cmp		byte [rdi], sil
	je 		.end

	cmp		byte [rdi], "0"
	jl		.badchr
	cmp 	byte [rdi], "9"
	jg		.badchr
	
	mov		rax, 10
	mul		rbx											; rax = rbx * 10
	mov		rbx, rax								; rbx = ^

	mov 	al, byte [rdi]					; 8 bits of rax
	sub 	al, "0"
	movzx	r9, al
	add		rbx, r9
	
	inc		rdi
	jmp 	.nextchr
.badchr:
	mov 	rax, -1
	pop 	rbx
	pop		r9
	ret
.end:
	mov		rax, rbx
	inc 	rdi
	pop 	rbx
	pop		r9
	ret

; program entry point
_start:
	mov		rdx, 32 * 1024
	mov 	rsi, input
	mov 	rdi, 0
	mov 	rax, 0
	syscall

puzzle1:
	mov		rbx, 0									; rbx holds the sum of the valid mul operations
	mov 	rcx, input							; rcx holds our current position in the string
.nextstate:
	cmp 	byte [rcx], 0						; check end of input
	je		.printresult

	cmp		dword [rcx], "mul("
	je 		.parsenums

	inc		rcx											; move onto next character
	jmp		.nextstate
.parsenums:
	add		rcx, 4									; move forward 4 characters -- the length of "mul("

	mov		rdi, rcx
	mov 	rsi, ","
	call 	parsenum
	mov		rcx, rdi

	cmp 	rax, -1
	je		.nextstate

	mov 	rdx, rax								; store the first number in rdx

	mov		rdi, rcx
	mov		rsi, ")"
	push 	rdx
	call	parsenum								; TODO figure out why parsenum clobbers rdx
	pop		rdx
	mov		rcx, rdi								; move ptr to location returned by parsenum

	cmp 	rax, -1
	je		.nextstate

	mul		rdx	
	add		rbx, rax
	jmp		.nextstate
.printresult:
	mov		rdi, rbx
	call	lngprint

puzzle2:												; most of this code is the same as the first part
	mov		rbx, 0									; rbx holds the sum of the enabled and valid mul operations
	mov 	rcx, input							; rcx holds our current position in the string
	mov		r8, 1										; r8 is a boolean of whether muls are enabled
.nextstate:
	cmp 	byte [rcx], 0						; check end of input
	je		.printresult

	cmp		r8, 1
	je		.mulenabled
	
	cmp		dword [rcx], "do()"
	jne		.incnext								; if muldisabled and we don't see do(), go to next character

	add		rcx, 4									; if we see do(), jump 4 and toggle rdi
	mov 	r8, 1
.mulenabled
	push	rcx
	mov		rdi, rcx
	mov		rsi, donttxt
	mov		rcx, 6
	repe	cmpsb
	pop 	rcx
	je		.disablemul

	cmp		dword [rcx], "mul("
	je 		.parsenums
.incnext
	inc		rcx											; move onto next character
	jmp		.nextstate
.disablemul
	mov		r8, 0
	jmp		.incnext
.parsenums:
	add		rcx, 4									; move forward 4 characters -- the length of "mul("

	mov		rdi, rcx
	mov 	rsi, ","
	call 	parsenum
	mov		rcx, rdi

	cmp 	rax, -1
	je		.nextstate

	mov 	rdx, rax								; store the first number in rdx

	mov		rdi, rcx
	mov		rsi, ")"
	push 	rdx
	call	parsenum								; TODO figure out why parsenum clobbers rdx
	pop		rdx
	mov		rcx, rdi								; move ptr to location returned by parsenum

	cmp 	rax, -1
	je		.nextstate

	mul		rdx	
	add		rbx, rax
	jmp		.nextstate
.printresult:
	mov		rdi, rbx
	call	lngprint
	
