
; Structures (ShowTime.asm)
; Windows API Version
; No Irvine32 library required

.386
.model flat, stdcall
option casemap:none

; Windows API declarations
GetStdHandle PROTO, nStdHandle:DWORD

SetConsoleCursorPosition PROTO, hConsoleOutput:DWORD, dwCursorPosition:DWORD

GetLocalTime PROTO, lpSystemTime:DWORD

WriteConsoleA PROTO, hConsoleOutput:DWORD, lpBuffer:DWORD, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:DWORD, lpReserved:DWORD

ReadConsoleA PROTO, hConsoleInput:DWORD, lpBuffer:DWORD, nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:DWORD, lpReserved:DWORD

ExitProcess PROTO, dwExitCode:DWORD

STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11

.data

    ; SYSTEMTIME structure
    sysTime STRUCT
        wYear WORD ?
        wMonth WORD ?
        wDayOfWeek WORD ?
        wDay WORD ?
        wHour WORD ?
        wMinute WORD ?
        wSecond WORD ?
        wMilliseconds WORD ?
    sysTime ENDS

    ; COORD structure
    XYPos STRUCT
        X WORD ?
        Y WORD ?
    XYPos ENDS

    currentTime sysTime <>
    position XYPos <10,5>

    consoleHandle DWORD ?
    inputHandle DWORD ?

    charsWritten DWORD ?
    charsRead DWORD ?

    buffer BYTE 10 DUP(0)

    colonStr BYTE ":",0
    message BYTE "Current System Time: ",0
    waitMsg BYTE 13,10,"Press any key to exit...",0

.code

; -----------------------------------
; Print string
; EDX = string address
; -----------------------------------
PrintString PROC

    pushad

    mov esi, edx
    xor ecx, ecx

PS_LOOP:
    cmp BYTE PTR [esi+ecx], 0
    je PS_DONE

    inc ecx
    jmp PS_LOOP

PS_DONE:
    INVOKE WriteConsoleA, consoleHandle, esi, ecx, ADDR charsWritten, 0

    popad
    ret

PrintString ENDP


; -----------------------------------
; Print two-digit number
; EAX = number
; -----------------------------------
PrintTwoDigits PROC

    pushad

    xor edx, edx
    mov ebx, 10
    div ebx

    ; Tens digit
    add al, '0'
    mov buffer, al

    ; Units digit
    add dl, '0'
    mov buffer+1, dl

    INVOKE WriteConsoleA, consoleHandle, ADDR buffer, 2, ADDR charsWritten, 0

    popad
    ret

PrintTwoDigits ENDP


; -----------------------------------
; MAIN PROGRAM
; -----------------------------------
main PROC

    ; Get standard output handle
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov consoleHandle, eax

    ; Get standard input handle
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov inputHandle, eax

    ; Set console cursor position (10,5)
    movzx eax, position.X
    movzx edx, position.Y
    shl edx, 16
    or eax, edx

    INVOKE SetConsoleCursorPosition, consoleHandle, eax

    ; Get local system time
    INVOKE GetLocalTime, ADDR currentTime

    ; Display title
    mov edx, OFFSET message
    call PrintString

    ; Display hour
    movzx eax, currentTime.wHour
    call PrintTwoDigits

    ; Display colon
    mov edx, OFFSET colonStr
    call PrintString

    ; Display minute
    movzx eax, currentTime.wMinute
    call PrintTwoDigits

    ; Display colon
    mov edx, OFFSET colonStr
    call PrintString

    ; Display second
    movzx eax, currentTime.wSecond
    call PrintTwoDigits

    ; Display wait message
    mov edx, OFFSET waitMsg
    call PrintString

    ; Wait for keyboard input
    INVOKE ReadConsoleA, inputHandle, ADDR buffer, 1, ADDR charsRead, 0

    ; Exit program
    INVOKE ExitProcess, 0

main ENDP

END main
