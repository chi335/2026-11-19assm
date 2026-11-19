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
; 문제 요구사항: mWriteInt 매크로 정의
; Conditional Directives (IF, TYPE)를 사용하여 8, 16, 32비트 가변 크기 처리
; ---------------------------------------------------------
mWriteInt MACRO val
    push eax                    ; 기존 EAX 레지스터 값 보호

    IF (TYPE val EQ 1)
        ; 8비트 피연산자 (SBYTE / BYTE)인 경우 -> 32비트로 부호 확장
        movsx eax, val
    ELSEIF (TYPE val EQ 2)
        ; 16비트 피연산자 (SWORD / WORD)인 경우 -> 32비트로 부호 확장
        movsx eax, val
    ELSEIF (TYPE val EQ 4)
        ; 32비트 피연산자 (SDWORD / DWORD)인 경우 -> 바로 EAX에 복사
        mov eax, val
    ELSE
        ; 8, 16, 32비트 외의 크기가 전달되면 컴파일 에러 발생
        .ERR <mWriteInt: Argument must be 8-bit (BYTE), 16-bit (WORD), or 32-bit (DWORD).>
    ENDIF

    call WriteIntProc           ; EAX에 저장된 부호 있는 정수를 콘솔에 출력
    pop eax                     ; EAX 레지스터 값 복원
ENDM

.data
; 서로 다른 크기(8비트, 16비트, 32비트)의 부호 있는 테스트 변수
val8  SBYTE  -125               ; 8비트 (1 Byte)
val16 SWORD  -32000             ; 16비트 (2 Bytes)
val32 SDWORD -2100000000        ; 32비트 (4 Bytes)

lbl8  BYTE "8-bit  SBYTE  val8  (-125)        : ", 0
lbl16 BYTE "16-bit SWORD  val16 (-32000)      : ", 0
lbl32 BYTE "32-bit SDWORD val32 (-2100000000) : ", 0
crlf  BYTE 0Dh, 0Ah, 0

fmtInt BYTE "%d", 0

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
; EAX 레지스터의 부호 있는 정수를 10진수로 출력하는 프로시저
; ---------------------------------------------------------
WriteIntProc PROC
    LOCAL numBuf[32]:BYTE

    ; EAX에 들어있는 정수를 10진수 문자열로 포맷팅
    INVOKE wsprintfA, ADDR numBuf, ADDR fmtInt, eax
    ; 콘솔에 출력
    INVOKE PrintString, ADDR numBuf
    ret
WriteIntProc ENDP

; ---------------------------------------------------------
; 메인 테스트 프로시저
; ---------------------------------------------------------
main PROC
    ; 1. 8비트 정수 출력 테스트 (SBYTE)
    INVOKE PrintString, ADDR lbl8
    mWriteInt val8              ; movsx eax, val8 매크로 코드 생성
    INVOKE PrintString, ADDR crlf

    ; 2. 16비트 정수 출력 테스트 (SWORD)
    INVOKE PrintString, ADDR lbl16
    mWriteInt val16             ; movsx eax, val16 매크로 코드 생성
    INVOKE PrintString, ADDR crlf

    ; 3. 32비트 정수 출력 테스트 (SDWORD)
    INVOKE PrintString, ADDR lbl32
    mWriteInt val32             ; mov eax, val32 매크로 코드 생성
    INVOKE PrintString, ADDR crlf

    INVOKE ExitProcess, 0
main ENDP

END main