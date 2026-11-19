
; Drunkard's Walk - Windows API Version
; Visual Studio MASM 32-bit
; No Irvine32 library required

.386
.model flat, stdcall
option casemap:none

; Windows API
ExitProcess PROTO, dwExitCode:DWORD
GetStdHandle PROTO, nStdHandle:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD, lpBuffer:DWORD, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:DWORD, lpReserved:DWORD
GetTickCount PROTO

STD_OUTPUT_HANDLE EQU -11

WalkMax EQU 50
StartX EQU 25
StartY EQU 25

.data

    ; Console
    hOutput DWORD ?
    charsWritten DWORD ?

    ; Position
    currX DWORD StartX
    currY DWORD StartY

    ; Random seed
    randSeed DWORD ?

    ; Loop counter
    walkIndex DWORD 0

    ; Store 50 coordinates (X,Y)
    path WORD (WalkMax * 2) DUP(0)

    ; Output strings
    titleMsg BYTE "Drunkard's Walk Simulation",13,10,0
    startMsg BYTE "Starting position: ",0
    comma BYTE ", ",0
    newline BYTE 13,10,0

    ; Number conversion buffer
    numBuf BYTE 16 DUP(0)

.code

; -----------------------------------
; Print null-terminated string
; EDX = string address
; -----------------------------------
PrintString PROC

    pushad

    mov esi, edx
    xor ecx, ecx

PS_COUNT:
    cmp BYTE PTR [esi+ecx], 0
    je PS_OUTPUT
    inc ecx
    jmp PS_COUNT

PS_OUTPUT:
    INVOKE WriteConsoleA, hOutput, esi, ecx, ADDR charsWritten, 0

    popad
    ret

PrintString ENDP


; -----------------------------------
; Print signed integer
; EAX = number
; -----------------------------------
PrintNumber PROC

    pushad

    mov esi, OFFSET numBuf
    add esi, 15

    mov BYTE PTR [esi], 0
    mov ebx, 10
    xor ecx, ecx

    test eax, eax
    jns PN_CONVERT

    neg eax
    push eax

    dec esi
    mov BYTE PTR [esi], '-'

    pop eax

PN_CONVERT:
    xor edx, edx
    div ebx

    add dl, '0'
    dec esi
    mov BYTE PTR [esi], dl

    inc ecx

    test eax, eax
    jnz PN_CONVERT

    INVOKE WriteConsoleA, hOutput, esi, ecx, ADDR charsWritten, 0

    popad
    ret

PrintNumber ENDP


; -----------------------------------
; Generate random direction
; Returns EAX = 0,1,2,3
; -----------------------------------
RandomDirection PROC

    mov eax, randSeed

    ; Xorshift random generator
    mov edx, eax
    shl edx, 13
    xor eax, edx

    mov edx, eax
    shr edx, 17
    xor eax, edx

    mov edx, eax
    shl edx, 5
    xor eax, edx

    mov randSeed, eax

    and eax, 3

    ret

RandomDirection ENDP


; -----------------------------------
; Display current position
; -----------------------------------
DisplayPosition PROC

    mov eax, currX
    call PrintNumber

    mov edx, OFFSET comma
    call PrintString

    mov eax, currY
    call PrintNumber

    mov edx, OFFSET newline
    call PrintString

    ret

DisplayPosition ENDP


; ===================================
; MAIN PROGRAM
; ===================================

main PROC

    ; Get console output handle
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOutput, eax

    ; Initialize random seed
    INVOKE GetTickCount
    mov randSeed, eax

    ; Avoid zero seed
    cmp eax, 0
    jne SEED_OK
    mov randSeed, 12345

SEED_OK:

    ; Display title
    mov edx, OFFSET titleMsg
    call PrintString

    ; Starting position
    mov edx, OFFSET startMsg
    call PrintString

    call DisplayPosition

    ; Initialize position
    mov currX, StartX
    mov currY, StartY

    mov walkIndex, 0

WALK_LOOP:

    ; Check 50 movements
    cmp walkIndex, WalkMax
    jge WALK_FINISH

    ; Store current X coordinate
    mov eax, walkIndex
    shl eax, 2

    mov edi, eax

    mov ax, WORD PTR currX
    mov WORD PTR path[edi], ax

    ; Store current Y coordinate
    mov ax, WORD PTR currY
    mov WORD PTR path[edi+2], ax

    ; Display current position
    call DisplayPosition

    ; Choose random direction
    call RandomDirection

    cmp eax, 0
    je NORTH

    cmp eax, 1
    je SOUTH

    cmp eax, 2
    je WEST

    jmp EAST


NORTH:
    dec currY
    jmp NEXT_MOVE

SOUTH:
    inc currY
    jmp NEXT_MOVE

WEST:
    dec currX
    jmp NEXT_MOVE

EAST:
    inc currX


NEXT_MOVE:

    inc walkIndex
    jmp WALK_LOOP


WALK_FINISH:

    ; Exit program
    INVOKE ExitProcess, 0

main ENDP

END main
