
.386
.model flat, stdcall
option casemap:none

ExitProcess PROTO, dwExitCode:DWORD
GetStdHandle PROTO, nStdHandle:DWORD
ReadConsoleA PROTO, hConsoleInput:DWORD, lpBuffer:DWORD, nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:DWORD, lpReserved:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD, lpBuffer:DWORD, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:DWORD, lpReserved:DWORD

STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11

.data
    msg1 BYTE "First number: ", 0
    msg2 BYTE "Second number: ", 0

    msgAX BYTE "AX (Addition) = ", 0
    msgBX BYTE "BX (Subtraction) = ", 0
    msgCX BYTE "CX (Multiplication) = ", 0
    msgDX BYTE "DX (Division) = ", 0
    msgError BYTE "Cannot divide by zero!", 13, 10, 0

    buffer BYTE 100 DUP(0)
    inputCount DWORD ?

    num1 SDWORD ?
    num2 SDWORD ?

    resultAX SDWORD ?
    resultBX SDWORD ?
    resultCX SDWORD ?
    resultDX SDWORD ?

    hInput DWORD ?
    hOutput DWORD ?

.code

; 문자열 출력 함수
PrintString PROC
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, edx
    mov ecx, 0

COUNT_LOOP:
    cmp BYTE PTR [ebx+ecx], 0
    je PRINT_NOW
    inc ecx
    jmp COUNT_LOOP

PRINT_NOW:
    INVOKE WriteConsoleA, hOutput, ebx, ecx, ADDR inputCount, 0

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
PrintString ENDP

; 숫자 입력 함수
ReadNumber PROC
    INVOKE ReadConsoleA, hInput, ADDR buffer, 100, ADDR inputCount, 0

    mov esi, OFFSET buffer
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx

    mov bl, 0

SKIP_SPACE:
    mov cl, [esi]
    cmp cl, ' '
    je NEXT_CHAR
    cmp cl, 9
    je NEXT_CHAR
    jmp CHECK_SIGN

NEXT_CHAR:
    inc esi
    jmp SKIP_SPACE

CHECK_SIGN:
    cmp cl, '-'
    jne READ_DIGITS
    mov bl, 1
    inc esi

READ_DIGITS:
    mov cl, [esi]
    cmp cl, '0'
    jb FINISH_NUMBER
    cmp cl, '9'
    ja FINISH_NUMBER

    imul eax, 10
    movzx edx, cl
    sub edx, '0'
    add eax, edx

    inc esi
    jmp READ_DIGITS

FINISH_NUMBER:
    cmp bl, 1
    jne NUMBER_DONE
    neg eax

NUMBER_DONE:
    ret
ReadNumber ENDP

main PROC

    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hInput, eax

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOutput, eax

    ; 첫 번째 숫자 입력
    mov edx, OFFSET msg1
    call PrintString
    call ReadNumber
    mov num1, eax

    ; 두 번째 숫자 입력
    mov edx, OFFSET msg2
    call PrintString
    call ReadNumber
    mov num2, eax

    ; AX = 덧셈
    mov eax, num1
    add eax, num2
    mov resultAX, eax

    ; BX = 뺄셈
    mov eax, num1
    sub eax, num2
    mov resultBX, eax

    ; CX = 곱셈
    mov eax, num1
    imul eax, num2
    mov resultCX, eax

    ; DX = 나눗셈
    cmp num2, 0
    je DIV_ZERO

    mov eax, num1
    cdq
    idiv num2
    mov resultDX, eax

    ; 결과 출력
    mov edx, OFFSET msgAX
    call PrintString
    mov eax, resultAX
    call PrintNumber

    mov edx, OFFSET msgBX
    call PrintString
    mov eax, resultBX
    call PrintNumber

    mov edx, OFFSET msgCX
    call PrintString
    mov eax, resultCX
    call PrintNumber

    mov edx, OFFSET msgDX
    call PrintString
    mov eax, resultDX
    call PrintNumber

    jmp PROGRAM_END

DIV_ZERO:
    mov edx, OFFSET msgError
    call PrintString

PROGRAM_END:
    INVOKE ExitProcess, 0

main ENDP

; 정수 출력 함수
PrintNumber PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, OFFSET buffer
    add esi, 99
    mov BYTE PTR [esi], 0

    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jge CONVERT

    neg eax
    push eax

    mov edx, OFFSET buffer
    mov BYTE PTR [esi-1], '-'
    dec esi

    pop eax

CONVERT:
    xor edx, edx
    div ebx

    add dl, '0'
    dec esi
    mov [esi], dl
    inc ecx

    test eax, eax
    jnz CONVERT

    cmp esi, OFFSET buffer
    jne OUTPUT_NUMBER

    ; 0도 정상 출력

OUTPUT_NUMBER:
    INVOKE WriteConsoleA, hOutput, esi, ecx, ADDR inputCount, 0

    ; 줄바꿈
    mov BYTE PTR buffer, 13
    mov BYTE PTR buffer+1, 10

    INVOKE WriteConsoleA, hOutput, ADDR buffer, 2, ADDR inputCount, 0

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
PrintNumber ENDP

END main
