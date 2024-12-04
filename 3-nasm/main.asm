section .data
multxt:		db	"mul("
dotxt:		db	"do()"
donttxt:	db	"don't()"
newline:	db	10

section .bss
input:	resb	32 * 1024

section .text
global _start

; rdi = ptr to string
strlen:
	push	rbx
	mov 	rbx, rdi
	mov 	rax, 0
nextchr:
	cmp 	byte [rbx], 0
	je 		endloop
	inc 	rax
	inc		rbx
	jmp		nextchr
endloop:
	pop		rbx
	ret

; rdi = ptr to string
print:
	; save parameters
	push 	rcx
	push	rdx
	push	rsi
	push	rdi

	call 	strlen

	mov 	rdx, rax 
	pop 	rsi
	mov		rdi, 1
	mov 	rax, 1
	syscall
	
	; return ptr to input string and restore parameters
	mov 	rax, rsi
	mov 	rdi, rsi
	pop 	rsi
	pop		rdx
	pop		rcx
	ret

_start:
	mov		rdx, 32 * 1024
	mov 	rsi, input
	mov 	rdi, 0
	mov 	rax, 0
	syscall

	mov 	rdi, input
	call	print
