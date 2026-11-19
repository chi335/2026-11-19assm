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

; =========================================================
; 문제 요구사항: 3-Operand 산술 매크로 정의
; =========================================================

; a. add3 dest, src1, src2  =>  dest = src1 + src2
add3 MACRO dest, src1, src2
    mov eax, src1
    add eax, src2
    mov dest, eax
ENDM

; b. sub3 dest, src1, src2  =>  dest = src1 - src2
sub3 MACRO dest, src1, src2
    mov eax, src1
    sub eax, src2
    mov dest, eax
ENDM

; c. mul3 dest, src1, src2  =>  dest = src1 * src2
mul3 MACRO dest, src1, src2
    mov eax, src1
    imul eax, src2
    mov dest, eax
ENDM

; d. div3 dest, src1, src2  =>  dest = src1 / src2
; (EDX 레지스터 보존)
div3 MACRO dest, src1, src2
    push edx
    mov eax, src1
    cdq
    idiv src2
    mov dest, eax
    pop edx
ENDM

.data
; 예약어 충돌을 방지하기 위해 변수명 변경 (valW, valY, valZ, valA, valB, valC, valD)
valW SDWORD 10
valY SDWORD 20
valZ SDWORD 3

valA SDWORD 100
valB SDWORD 40
valC SDWORD 5
valD SDWORD 10

; 임시 및 결과 저장 변수
temp1 SDWORD ?
temp2 SDWORD ?
res1  SDWORD ?
res2  SDWORD ?
res3  SDWORD ?
res4  SDWORD ?

; 출력 메시지
fmt1 BYTE "Expr 1: res1 = (w + y) * z   = (%d + %d) * %d = %d", 0Dh, 0Ah, 0
fmt2 BYTE "Expr 2: res2 = (a - b) / c   = (%d - %d) / %d = %d", 0Dh, 0Ah, 0
fmt3 BYTE "Expr 3: res3 = (a * b) - (c + d) = (%d * %d) - (%d + %d) = %d", 0Dh, 0Ah, 0
fmt4 BYTE "Expr 4: res4 = (a + b) / (c - d) = (%d + %d) / (%d - %d) = %d", 0Dh, 0Ah, 0

buffer BYTE 256 DUP(0)

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
    ; -----------------------------------------------------
    ; 표현식 1: res1 = (w + y) * z  => (10 + 20) * 3 = 90
    ; -----------------------------------------------------
    add3 temp1, valW, valY          ; temp1 = w + y
    mul3 res1, temp1, valZ          ; res1  = temp1 * z

    INVOKE wsprintfA, ADDR buffer, ADDR fmt1, valW, valY, valZ, res1
    INVOKE PrintString, ADDR buffer

    ; -----------------------------------------------------
    ; 표현식 2: res2 = (a - b) / c  => (100 - 40) / 5 = 12
    ; -----------------------------------------------------
    sub3 temp1, valA, valB          ; temp1 = a - b
    div3 res2, temp1, valC          ; res2  = temp1 / c

    INVOKE wsprintfA, ADDR buffer, ADDR fmt2, valA, valB, valC, res2
    INVOKE PrintString, ADDR buffer

    ; -----------------------------------------------------
    ; 표현식 3: res3 = (a * b) - (c + d) => (100 * 40) - (5 + 10) = 3985
    ; -----------------------------------------------------
    mul3 temp1, valA, valB          ; temp1 = a * b
    add3 temp2, valC, valD          ; temp2 = c + d
    sub3 res3, temp1, temp2         ; res3  = temp1 - temp2

    INVOKE wsprintfA, ADDR buffer, ADDR fmt3, valA, valB, valC, valD, res3
    INVOKE PrintString, ADDR buffer

    ; -----------------------------------------------------
    ; 표현식 4: res4 = (a + b) / (c - d) => (100 + 40) / (5 - 10) = -28
    ; -----------------------------------------------------
    add3 temp1, valA, valB          ; temp1 = a + b
    sub3 temp2, valC, valD          ; temp2 = c - d
    div3 res4, temp1, temp2         ; res4  = temp1 / temp2

    INVOKE wsprintfA, ADDR buffer, ADDR fmt4, valA, valB, valC, valD, res4
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main