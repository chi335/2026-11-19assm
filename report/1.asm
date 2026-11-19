.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib
includelib user32.lib

GetStdHandle       PROTO stdcall :DWORD
ReadConsoleInputA  PROTO stdcall :DWORD, :PTR DWORD, :DWORD, :PTR DWORD
WriteConsoleA      PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess        PROTO stdcall :DWORD
wsprintfA          PROTO C       :PTR BYTE, :PTR BYTE, :VARARG

KEY_EVENT_RECORD STRUCT
    bKeyDown          DWORD ?
    wRepeatCount      WORD  ?
    wVirtualKeyCode   WORD  ?
    wVirtualScanCode  WORD  ?
    AsciiChar         BYTE  ?
    UnusedPad         BYTE  ?
    dwControlKeyState DWORD ?
KEY_EVENT_RECORD ENDS

INPUT_RECORD STRUCT
    EventType WORD ?
    wReserved WORD ?
    KeyEvent  KEY_EVENT_RECORD <>
INPUT_RECORD ENDS

; 문제 요구사항: mReadkey 매크로
mReadkey MACRO asciiVal, scanVal
    call ReadChar          
    mov asciiVal, al
    mov scanVal, ah
ENDM

.data
ascii BYTE ?
scan  BYTE ?

msgPrompt BYTE "Press any key...", 0Dh, 0Ah, 0
fmtAscii  BYTE "ASCII Code (Hex): 0x%02X", 0Dh, 0Ah, 0
fmtScan   BYTE "Scan Code  (Hex): 0x%02X", 0Dh, 0Ah, 0

buffer BYTE 128 DUP(0)

.code

PrintString PROC pMsg:DWORD
    LOCAL hOut:DWORD
    LOCAL bytesWritten:DWORD
    LOCAL len:DWORD

    INVOKE GetStdHandle, -11
    mov hOut, eax

    mov edi, pMsg
    xor ecx, ecx
    not ecx
    xor al, al
    repne scasb
    not ecx
    dec ecx
    mov len, ecx

    INVOKE WriteConsoleA, hOut, pMsg, len, ADDR bytesWritten, 0
    ret
PrintString ENDP

ReadChar PROC
    LOCAL hStdIn:DWORD
    LOCAL inRec:INPUT_RECORD
    LOCAL numRead:DWORD

    INVOKE GetStdHandle, -10
    mov hStdIn, eax

WaitKeyLoop:
    INVOKE ReadConsoleInputA, hStdIn, ADDR inRec, 1, ADDR numRead

    cmp inRec.EventType, 1
    jne WaitKeyLoop

    cmp inRec.KeyEvent.bKeyDown, 0
    je WaitKeyLoop

    mov al, inRec.KeyEvent.AsciiChar
    mov dx, inRec.KeyEvent.wVirtualScanCode
    mov ah, dl

    ret
ReadChar ENDP

main PROC
    INVOKE PrintString, ADDR msgPrompt

    mReadkey ascii, scan

    movzx eax, ascii
    INVOKE wsprintfA, ADDR buffer, ADDR fmtAscii, eax
    INVOKE PrintString, ADDR buffer

    movzx eax, scan
    INVOKE wsprintfA, ADDR buffer, ADDR fmtScan, eax
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main