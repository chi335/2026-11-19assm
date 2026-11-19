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
; 문제 요구사항: mMove32 매크로 정의
; 파라미터: dest (목적지 32비트 메모리), src (원본 32비트 메모리)
; ---------------------------------------------------------
mMove32 MACRO dest, src
    push eax            ; 1. EAX 레지스터 값 보존
    mov eax, src        ; 2. 원본 메모리(src)의 32비트 값을 EAX로 이동
    mov dest, eax       ; 3. EAX 값을 목적지 메모리(dest)로 이동
    pop eax             ; 4. EAX 레지스터 값 복원
ENDM

.data
; 32비트(DWORD) 피연산자 메모리 변수 정의
valSource DWORD 12345678h   ; 원본 메모리 데이터 (0x12345678)
valDest   DWORD 00000000h   ; 목적지 메모리 데이터 (초기값 0)

msgBefore BYTE "Before mMove32: valDest = 0x%08X", 0Dh, 0Ah, 0
msgAfter  BYTE "After  mMove32: valDest = 0x%08X", 0Dh, 0Ah, 0

buffer    BYTE 128 DUP(0)

.code

; ---------------------------------------------------------
; 문자열 출력 보조 프로시저
; ---------------------------------------------------------
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

; ---------------------------------------------------------
; 메인 테스트 프로시저
; ---------------------------------------------------------
main PROC
    ; 1. mMove32 실행 전 valDest 값 출력
    INVOKE wsprintfA, ADDR buffer, ADDR msgBefore, valDest
    INVOKE PrintString, ADDR buffer

    ; 2. mMove32 매크로 실행 (valSource -> valDest)
    mMove32 valDest, valSource

    ; 3. mMove32 실행 후 valDest 값 출력 (valSource의 값으로 복사되었는지 확인)
    INVOKE wsprintfA, ADDR buffer, ADDR msgAfter, valDest
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main