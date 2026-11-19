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
GetTickCount  PROTO stdcall

.data
TOTAL_STEPS  EQU 30             ; 이동할 총 걸음 수

profX        SDWORD 0           ; 교수의 현재 X 좌표
profY        SDWORD 0           ; 교수의 현재 Y 좌표

; 방향 정의: 0=UP, 1=RIGHT, 2=DOWN, 3=LEFT
currentDir   DWORD 0            ; 기본 시작 방향 (0: UP)

randSeed     DWORD ?            ; 난수 생성용 시드

; Direction 이름 출력용 문자열 배열
dirNames     BYTE "UP   ", 0, "RIGHT", 0, "DOWN ", 0, "LEFT ", 0

msgTitle     BYTE "=== Drunkard's Walk with Probabilities Simulation ===", 0Dh, 0Ah, 0
msgStart     BYTE "Starting direction: UP (North)", 0Dh, 0Ah, 0Dh, 0Ah, 0
fmtStep      BYTE "Step %2d: Moved %s -> Position (%3d, %3d)", 0Dh, 0Ah, 0
msgSummary   BYTE 0Dh, 0Ah, "=== Simulation Summary ===", 0Dh, 0Ah
             BYTE "Initial Position : (  0,   0)", 0Dh, 0Ah
             BYTE "Final Position   : (%3d, %3d)", 0Dh, 0Ah, 0

buffer       BYTE 256 DUP(0)

.code

; ---------------------------------------------------------
; 난수 생성기 (Linear Congruential Generator)
; ---------------------------------------------------------
Randomize PROC
    INVOKE GetTickCount
    mov randSeed, eax
    ret
Randomize ENDP

; EAX = 0 ~ (range - 1) 범위의 난수 반환 (인자: ECX = range)
RandomRange PROC
    push edx
    mov eax, randSeed
    imul eax, eax, 214013
    add eax, 2531011
    mov randSeed, eax
    shr eax, 16
    and eax, 07FFFh
    xor edx, edx
    div ecx                   ; EDX = EAX % ECX
    mov eax, edx
    pop edx
    ret
RandomRange ENDP

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
    LOCAL currentStep:DWORD
    LOCAL pDirStr:DWORD

    call Randomize
    INVOKE PrintString, ADDR msgTitle
    INVOKE PrintString, ADDR msgStart

    mov currentStep, 1

WalkLoop:
    ; 1. 0 ~ 99 범위의 난수를 발생시켜 방향 전환 확률 결정
    mov ecx, 100
    call RandomRange           ; EAX = 0 ~ 99

    cmp eax, 50
    jb KeepSameDir             ; 0 ~ 49 (50% 확률): 이전 방향 유지
    cmp eax, 70
    jb TurnRight               ; 50 ~ 69 (20% 확률): 우회전 (+1)
    cmp eax, 90
    jb TurnLeft                ; 70 ~ 89 (20% 확률): 좌회전 (+3, 모듈로 4)
    jmp TurnReverse            ; 90 ~ 99 (10% 확률): 유턴 (+2)

KeepSameDir:
    jmp ApplyMove

TurnRight:
    mov eax, currentDir
    inc eax
    and eax, 3                 ; (currentDir + 1) % 4
    mov currentDir, eax
    jmp ApplyMove

TurnLeft:
    mov eax, currentDir
    add eax, 3
    and eax, 3                 ; (currentDir + 3) % 4
    mov currentDir, eax
    jmp ApplyMove

TurnReverse:
    mov eax, currentDir
    add eax, 2
    and eax, 3                 ; (currentDir + 2) % 4
    mov currentDir, eax

ApplyMove:
    ; 2. 결정된 방향(currentDir)에 맞춰 좌표 업데이트
    mov eax, currentDir
    cmp eax, 0
    je MoveUp
    cmp eax, 1
    je MoveRight
    cmp eax, 2
    je MoveDown
    jmp MoveLeft

MoveUp:
    inc profY
    jmp PrintProgress
MoveRight:
    inc profX
    jmp PrintProgress
MoveDown:
    dec profY
    jmp PrintProgress
MoveLeft:
    dec profX

PrintProgress:
    ; 현재 방향 이름 문자열 포인터 계산
    mov eax, currentDir
    imul eax, 6                ; 각 방향 문자열 길이 = 6 bytes
    add eax, OFFSET dirNames
    mov pDirStr, eax

    ; 진행 상황 출력
    INVOKE wsprintfA, ADDR buffer, ADDR fmtStep, currentStep, pDirStr, profX, profY
    INVOKE PrintString, ADDR buffer

    inc currentStep
    cmp currentStep, TOTAL_STEPS
    jbe WalkLoop

    ; 3. 시뮬레이션 최종 요약 출력 (시작 위치 대비 얼마나 멀어졌는지 확인)
    INVOKE wsprintfA, ADDR buffer, ADDR msgSummary, profX, profY
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main