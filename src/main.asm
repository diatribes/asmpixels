section .data

sdlErrorMessageFmt db "SDL Error: %s", 10, 0
createWindowTitle db "Blegh", 0

section .text

global _start
extern printf
extern SDL_Init
extern SDL_CreateWindow
extern SDL_CreateRenderer
extern SDL_PumpEvents
extern SDL_RenderClear
extern SDL_RenderPresent
extern SDL_SetRenderDrawColor
extern SDL_RenderSetLogicalSize
extern SDL_RenderDrawPoint
extern SDL_GetTicks
extern SDL_Delay	
extern SDL_DestroyRenderer
extern SDL_DestroyWindow
extern SDL_Quit
extern SDL_GetError

%define renderer r15
%define W 320
%define H 200
%define X r10
%define Y r11

_start:
    ; init
	mov rdi, 21
	call SDL_Init
	cmp rax, 0
	jl sdlError

    ; window
	mov rdi, createWindowTitle 
	mov rsi, 100
	mov rdx, 100
	mov rcx, 1280
	mov r8, 800
	mov r9, 4
	call SDL_CreateWindow
	cmp rax, 0
	je sdlError
	mov r12, rax

    ; renderer
	mov rdi, rax
	mov rsi, -1
	mov rdx, 1
	call SDL_CreateRenderer
	cmp rax, 0
	je sdlError
	mov renderer, rax

    ; renderer logical size
	mov rdi, rax
	mov rsi, W
	mov rdx, H
	call SDL_RenderSetLogicalSize

    ; black color
    mov rdi, renderer
	mov rsi, 0 
	mov rdx, 0
	mov rcx, 0 
	mov r8, 255
	call SDL_SetRenderDrawColor

    ; clear
	mov rdi, renderer
	call SDL_RenderClear

    ; red color
    mov rdi, renderer
	mov rsi, 200
	mov rdx, 0 
	mov rcx, 0 
	mov r8, 255
	call SDL_SetRenderDrawColor

loopMain:

    call SDL_PumpEvents

    ; present render target;
	mov rdi, renderer
	call SDL_RenderPresent
    ; clear
	mov rdi, renderer
	call SDL_RenderClear

    xor X, X
    jmp .loopX

.loopXInc:
    inc X

.loopX:
    xor Y, Y

    cmp X, W 
    jge loopMain
    jmp .loopY

.loopY:

    push X
    push Y
    call SDL_GetTicks
    pop Y
    pop X
    mov rbx, 100
    div rbx

    ; red color
    mov rdi, renderer
    mov rsi, X
    xor rsi, Y
    mul rsi
    mov rsi, 0
	mov rdx, rax
	mov rcx, Y
	mov r8, 255
	call SDL_SetRenderDrawColor

    ; draw pixel
    push X
    push Y
    mov rdi, renderer
	mov rsi, X
	mov rdx, Y
    call SDL_RenderDrawPoint
    pop Y
    pop X

    inc Y
    cmp Y, H
    jge .loopXInc

    jmp .loopY

done:
    ; free renderer 
	mov rdi, renderer
	call SDL_DestroyRenderer

    ; free window
	mov rdi, r12
	call SDL_DestroyWindow

    ; quit 
	call SDL_Quit
	mov rdi, 0
	jmp exit

sdlError:
	call SDL_GetError
	mov rsi, rax
	mov rdi, sdlErrorMessageFmt 
	call printf
	mov rdi, 42
	jmp exit

exit:
	mov rax, 60
	syscall
