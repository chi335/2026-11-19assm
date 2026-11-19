.386
.model flat, stdcall
option casemap:none

; ---------------------------------------------------------
; 윈도우 시스템 라이브러리 링크
; ---------------------------------------------------------
includelib kernel32.lib

; ---------------------------------------------------------
; API 프로토타입 선언
; ---------------------------------------------------------
GetStdHandle            PROTO stdcall :DWORD
SetConsoleTextAttribute PROTO stdcall :DWORD, :WORD
WriteConsoleA           PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess             PROTO stdcall :DWORD

; ---------------------------------------------------------
; 텍스트 색상 상수 정의 (Windows Console Color Attributes)
; ---------------------------------------------------------
color_red     EQU 0Ch    ; 밝은 빨강 (Light Red)
color_green   EQU 0Ah    ; 밝은 초록 (Light Green)
color_blue    EQU 09h    ; 밝은 파랑 (Light Blue)
color_yellow  EQU 0Eh    ; 노랑 (Yellow)
color_cyan    EQU 0Bh    ; 청록 (Cyan)
color_magenta EQU 0Dh    ; 자주 (Light Magenta)
color_white   EQU 0Fh    ; 밝은 흰색 (Bright White)
color_default EQU 07h    ; 기본 콘솔 색상 (연회색)

; ---------------------------------------------------------
; 문제 요구사항: mWritestringAttr 매크로 정의
; 파라미터: strName (문자열 변수 이름), color (색상 상수)
; ---------------------------------------------------------
mWritestringAttr MACRO strName, color
    push eax
    push edx

    ; 1. 표준 출력 핸들 구하기 (-11 = STD_OUTPUT_HANDLE)
    INVOKE GetStdHandle, -11
    mov edx, eax

    ; 2. 콘솔 텍스트 색상 변경
    INVOKE SetConsoleTextAttribute, edx, color

    ; 3. 문자열 출력 함수 호출
    INVOKE WriteStringProc, ADDR strName

    pop edx
    pop eax
ENDM

.data
; 테스트할 Null-terminated 문자열 선언 (마지막에 0 포함)
strRed     BYTE "1. This string is written in RED color!", 0Dh, 0Ah, 0
strGreen   BYTE "2. This string is written in GREEN color!", 0Dh, 0Ah, 0
strYellow  BYTE "3. This string is written in YELLOW color!", 0Dh, 0Ah, 0
strCyan    BYTE "4. This string is written in CYAN color!", 0Dh, 0Ah, 0
strMagenta BYTE "5. This string is written in MAGENTA color!", 0Dh, 0Ah, 0
strWhite   BYTE "6. This string is written in WHITE color!", 0Dh, 0Ah, 0

.code

; ---------------------------------------------------------
; Null-terminated 문자열을 콘솔에 출력하는 보조 프로시저
; ---------------------------------------------------------
WriteStringProc PROC pMsg:DWORD
    LOCAL hOut:DWORD
    LOCAL bytesWritten:DWORD
    LOCAL len:DWORD

    INVOKE GetStdHandle, -11
    mov hOut, eax

    ; 문자열 길이를 계산 (Null 문자 0을 만날 때까지)
    mov edi, pMsg
    xor ecx, ecx
    not ecx
    xor al, al
    repne scasb
    not ecx
    dec ecx
    mov len, ecx

    ; 콘솔 화면에 출력
    INVOKE WriteConsoleA, hOut, pMsg, len, ADDR bytesWritten, 0
    ret
WriteStringProc ENDP

; ---------------------------------------------------------
; 메인 테스트 프로시저
; ---------------------------------------------------------
main PROC
    ; 서로 다른 색상으로 문자열 출력 매크로 호출 테스트
    mWritestringAttr strRed, color_red
    mWritestringAttr strGreen, color_green
    mWritestringAttr strYellow, color_yellow
    mWritestringAttr strCyan, color_cyan
    mWritestringAttr strMagenta, color_magenta
    mWritestringAttr strWhite, color_white

    ; 출력이 끝난 후 콘솔 색상을 기본 상태로 원상복구
    INVOKE GetStdHandle, -11
    INVOKE SetConsoleTextAttribute, eax, color_default

    INVOKE ExitProcess, 0
main ENDP

END main