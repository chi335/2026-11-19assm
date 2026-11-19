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
; 문제 요구사항: mMult32 매크로 정의
; 파라미터: dest (결과 메모리), op1 (첫 번째 메모리), op2 (두 번째 메모리)
; ---------------------------------------------------------
mMult32 MACRO dest, op1, op2
    push eax            ; EAX 레지스터 값 보존
    mov eax, op1        ; 1. 첫 번째 피연산자(op1)를 EAX로 이동
    imul eax, op2       ; 2. EAX = EAX * op2 (32비트 곱셈 수행)
    mov dest, eax       ; 3. 곱셈 결과를 목적지 메모리(dest)에 저장
    pop eax             ; EAX 레지스터 값 복원
ENDM

.data
; 32비트(DWORD) 테스트 피연산자 메모리 변수
val1    DWORD 1234      ; 첫 번째 32비트 메모리값
val2    DWORD 5678      ; 두 번째 32비트 메모리값
product DWORD ?         ; 32비트 곱셈 결과를 저장할 변수

fmtMsg  BYTE "Multiplication Result: %d * %d = %d", 0Dh, 0Ah, 0
buffer  BYTE 128 DUP(0)

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
    ; mMult32 매크로 호출 (product = val1 * val2)
    mMult32 product, val1, val2

    ; 10진수 연산 결과 서식화 및 출력
    INVOKE wsprintfA, ADDR buffer, ADDR fmtMsg, val1, val2, product
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main