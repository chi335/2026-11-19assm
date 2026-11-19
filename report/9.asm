.386
.model flat, stdcall
option casemap:none

; ---------------------------------------------------------
; 윈도우 시스템 라이브러리 링크
; ---------------------------------------------------------
includelib kernel32.lib
includelib user32.lib

; ---------------------------------------------------------
; API 프로토타입 선언
; ---------------------------------------------------------
GetStdHandle  PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess   PROTO stdcall :DWORD
wsprintfA     PROTO C       :PTR BYTE, :PTR BYTE, :VARARG

; ---------------------------------------------------------
; 문제 요구사항: mShiftDoublewords 매크로 정의
; (모든 라벨을 LOCAL로 지정하여 중복 정의 에러 해결)
; ---------------------------------------------------------
mShiftDoublewords MACRO arrayName, direction, numberOfBits
    LOCAL DoShiftLeft, DoShiftRight, ShiftLeftLoop, ShiftLeftDone, ShiftRightLoop, ShiftRightDone, ExitMacro

    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, OFFSET arrayName
    mov bl, BYTE PTR [numberOfBits]    ; 시프트 비트 수 보관

    ; 방향 판단 ('L' / 'l' -> 왼쪽, 'R' / 'r' -> 오른쪽)
    mov al, direction
    cmp al, 'L'
    je DoShiftLeft
    cmp al, 'l'
    je DoShiftLeft
    cmp al, 'R'
    je DoShiftRight
    cmp al, 'r'
    je DoShiftRight
    jmp ExitMacro

; ---------------------------------------------------------
; 1. 왼쪽 시프트 처리 (SHLD 사용)
; ---------------------------------------------------------
DoShiftLeft:
    mov edx, LENGTHOF arrayName
    dec edx                            ; EDX = N - 1

ShiftLeftLoop:
    cmp edx, 0
    jle ShiftLeftDone
    mov eax, [esi + edx*4 - 4]         ; 하위 DWORD (array[i-1])의 비트를 가져옴
    mov cl, bl                         ; CL = Shift Count
    shld dword ptr [esi + edx*4], eax, cl
    dec edx
    jmp ShiftLeftLoop

ShiftLeftDone:
    mov cl, bl
    shl dword ptr [esi], cl            ; 가장 최하위 DWORD (array[0]) 시프트
    jmp ExitMacro

; ---------------------------------------------------------
; 2. 오른쪽 시프트 처리 (SHRD 사용)
; ---------------------------------------------------------
DoShiftRight:
    xor edx, edx                       ; EDX = 0

ShiftRightLoop:
    mov eax, edx
    inc eax
    cmp eax, LENGTHOF arrayName
    jge ShiftRightDone
    mov eax, [esi + edx*4 + 4]         ; 상위 DWORD (array[i+1])의 비트를 가져옴
    mov cl, bl                         ; CL = Shift Count
    shrd dword ptr [esi + edx*4], eax, cl
    inc edx
    jmp ShiftRightLoop

ShiftRightDone:
    mov cl, bl
    shr dword ptr [esi + edx*4], cl    ; 가장 최상위 DWORD (array[N-1]) 시프트

ExitMacro:
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
ENDM

.data
myArray DWORD 12345678h, 9ABCDEF0h, 13579ACEh
shiftBits BYTE 4

lblOriginal BYTE "1. Original Array (32-bit hex values):", 0Dh, 0Ah, 0
lblShiftL   BYTE 0Dh, 0Ah, "2. After Shift Left  (L) by 4 bits:", 0Dh, 0Ah, 0
lblShiftR   BYTE 0Dh, 0Ah, "3. After Shift Right (R) back by 4 bits:", 0Dh, 0Ah, 0

fmtElem     BYTE "   myArray[%d] = 0x%08X", 0Dh, 0Ah, 0
buffer      BYTE 256 DUP(0)

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

DisplayArray PROC
    LOCAL i:DWORD
    mov i, 0

DisplayLoop:
    mov eax, i
    mov edx, [myArray + eax*4]

    INVOKE wsprintfA, ADDR buffer, ADDR fmtElem, i, edx
    INVOKE PrintString, ADDR buffer

    inc i
    mov eax, i
    cmp eax, LENGTHOF myArray
    jb DisplayLoop

    ret
DisplayArray ENDP

main PROC
    ; 1. 원본 출력
    INVOKE PrintString, ADDR lblOriginal
    call DisplayArray

    ; 2. 왼쪽 시프트 매크로 호출
    mShiftDoublewords myArray, 'L', shiftBits
    INVOKE PrintString, ADDR lblShiftL
    call DisplayArray

    ; 3. 오른쪽 시프트 매크로 호출
    mShiftDoublewords myArray, 'R', shiftBits
    INVOKE PrintString, ADDR lblShiftR
    call DisplayArray

    INVOKE ExitProcess, 0
main ENDP

END main