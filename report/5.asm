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
ReadConsoleA  PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess   PROTO stdcall :DWORD
wsprintfA     PROTO C       :PTR BYTE, :PTR BYTE, :VARARG

; ---------------------------------------------------------
; 문제 요구사항: mReadInt 매크로 정의
; Conditional Directives (IF, TYPE)를 이용한 16비트 / 32비트 조건부 컴파일
; ---------------------------------------------------------
mReadInt MACRO resultVar
    push eax                  ; 기존 EAX 레지스터 보존
    call ReadIntProc          ; 키보드 입력을 받아 EAX 레지스터에 32비트 정수로 반환

    IF (TYPE resultVar EQ 2)
        ; 16비트 피연산자 (WORD / SWORD)인 경우
        mov resultVar, ax
    ELSEIF (TYPE resultVar EQ 4)
        ; 32비트 피연산자 (DWORD / SDWORD)인 경우
        mov resultVar, eax
    ELSE
        ; 그 외 크기의 변수가 입력되었을 경우 컴파일 에러 발생
        .ERR <mReadInt: Argument must be a 16-bit (WORD) or 32-bit (DWORD) variable.>
    ENDIF

    pop eax                   ; EAX 레지스터 복원
ENDM

.data
; 크기가 서로 다른 테스트용 부호 있는 정수 변수
num16 SWORD  ?                ; 16비트 정수 변수 (WORD, 2 Bytes)
num32 SDWORD ?                ; 32비트 정수 변수 (DWORD, 4 Bytes)

prompt16 BYTE "Enter a 16-bit signed integer (-32768 ~ 32767): ", 0
prompt32 BYTE "Enter a 32-bit signed integer (-2147483648 ~ 2147483647): ", 0

out16    BYTE "You entered 16-bit value: %d", 0Dh, 0Ah, 0
out32    BYTE "You entered 32-bit value: %d", 0Dh, 0Ah, 0

buffer   BYTE 128 DUP(0)

.code

; ---------------------------------------------------------
; 콘솔에서 문자열을 읽고 부호 있는 정수로 변환하여 EAX로 반환하는 함수
; ---------------------------------------------------------
ReadIntProc PROC
    LOCAL hStdIn:DWORD
    LOCAL bytesRead:DWORD
    LOCAL inputBuffer[64]:BYTE

    ; 1. 표준 입력 핸들 가져오기
    INVOKE GetStdHandle, -10
    mov hStdIn, eax

    ; 2. 콘솔에서 한 줄 입력받기
    INVOKE ReadConsoleA, hStdIn, ADDR inputBuffer, 63, ADDR bytesRead, 0

    ; 3. 문자열 ➜ 정수 변환 (atoi 로직)
    lea esi, inputBuffer
    xor eax, eax              ; 결과 축적용 EAX = 0
    xor ecx, ecx              ; 부호 플래그 (0: 양수, 1: 음수)

SkipSpace:
    mov bl, [esi]
    cmp bl, ' '
    jne CheckMinus
    inc esi
    jmp SkipSpace

CheckMinus:
    cmp bl, '-'
    jne CheckPlus
    mov ecx, 1                ; 음수 플래그 설정
    inc esi
    jmp ParseDigits
CheckPlus:
    cmp bl, '+'
    jne ParseDigits
    inc esi

ParseDigits:
    mov bl, [esi]
    cmp bl, '0'
    jb Done
    cmp bl, '9'
    ja Done

    sub bl, '0'
    movzx edx, bl
    imul eax, 10
    add eax, edx
    inc esi
    jmp ParseDigits

Done:
    cmp ecx, 1
    jne ReturnEAX
    neg eax                   ; 음수인 경우 부정(NEG) 연산 수행

ReturnEAX:
    ret
ReadIntProc ENDP

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
    ; --- 1. 16비트 정수 입력 테스트 ---
    INVOKE PrintString, ADDR prompt16
    mReadInt num16             ; 16비트 변수 전달 (AX 값이 num16에 저장됨)

    movsx eax, num16           ; 16비트 값을 32비트 EAX로 부호 확장
    INVOKE wsprintfA, ADDR buffer, ADDR out16, eax
    INVOKE PrintString, ADDR buffer

    ; --- 2. 32비트 정수 입력 테스트 ---
    INVOKE PrintString, ADDR prompt32
    mReadInt num32             ; 32비트 변수 전달 (EAX 값이 num32에 저장됨)

    INVOKE wsprintfA, ADDR buffer, ADDR out32, num32
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main