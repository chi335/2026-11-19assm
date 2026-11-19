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
; 시뮬레이션 설정
TOTAL_STEPS  EQU 20             ; 교수가 이동할 총 걸음 수

profX        SDWORD 0           ; 교수의 현재 X 좌표 (초기 위치 0)
profY        SDWORD 0           ; 교수의 현재 Y 좌표 (초기 위치 0)

dropStep     DWORD ?            ; 핸드폰을 떨어뜨릴 정해진 걸음 (난수)
phoneX       SDWORD ?           ; 분실된 핸드폰의 X 좌표
phoneY       SDWORD ?           ; 분실된 핸드폰의 Y 좌표
isDropped    DWORD 0            ; 핸드폰 분실 여부 플래그 (0: 안떨어뜨림, 1: 떨어뜨림)

randSeed     DWORD ?            ; 난수 생성용 시드

; 출력 메시지 포맷
msgTitle    BYTE "=== Professor's Drunkard's Walk Simulation ===", 0Dh, 0Ah, 0
msgStart    BYTE "Professor starts walking from (0, 0)...", 0Dh, 0Ah, 0Dh, 0Ah, 0
fmtStep     BYTE "Step %2d: Professor moved to (%3d, %3d)", 0
fmtDrop     BYTE " <--- [PHONE DROPPED HERE!]", 0Dh, 0Ah, 0
fmtNormal   BYTE 0Dh, 0Ah, 0
msgSummary  BYTE 0Dh, 0Ah, "=== Simulation Summary ===", 0Dh, 0Ah
            BYTE "The professor lost his phone at Step %d!", 0Dh, 0Ah
            BYTE "Lost Phone Coordinates: (X = %d, Y = %d)", 0Dh, 0Ah, 0

buffer      BYTE 256 DUP(0)

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
    and eax, 07FFFh           ; 0 ~ 32767 범위 추출
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

    ; 1. 난수 시드 초기화 및 시작 문구 출력
    call Randomize
    INVOKE PrintString, ADDR msgTitle
    INVOKE PrintString, ADDR msgStart

    ; 2. 핸드폰을 떨어뜨릴 무작위 걸음 수 결정 (1 ~ TOTAL_STEPS)
    mov ecx, TOTAL_STEPS
    call RandomRange           ; EAX = 0 ~ (TOTAL_STEPS - 1)
    inc eax                    ; EAX = 1 ~ TOTAL_STEPS
    mov dropStep, eax

    ; 3. Drunkard's Walk 시뮬레이션 루프
    mov currentStep, 1

WalkLoop:
    ; 4방향 무작위 이동 결정 (0: Up, 1: Right, 2: Down, 3: Left)
    mov ecx, 4
    call RandomRange           ; EAX = 0, 1, 2, 3

    cmp eax, 0
    je MoveUp
    cmp eax, 1
    je MoveRight
    cmp eax, 2
    je MoveDown
    jmp MoveLeft

MoveUp:
    inc profY
    jmp CheckDrop
MoveRight:
    inc profX
    jmp CheckDrop
MoveDown:
    dec profY
    jmp CheckDrop
MoveLeft:
    dec profX

CheckDrop:
    ; 현재 걸음 수가 핸드폰을 떨어뜨리는 시점인지 확인
    mov eax, currentStep
    cmp eax, dropStep
    jne StepOutput

    ; 핸드폰 위치 기록
    mov eax, profX
    mov phoneX, eax
    mov eax, profY
    mov phoneY, eax
    mov isDropped, 1

StepOutput:
    ; 현재 위치 출력
    INVOKE wsprintfA, ADDR buffer, ADDR fmtStep, currentStep, profX, profY
    INVOKE PrintString, ADDR buffer

    ; 이번 걸음에 핸드폰을 떨어뜨렸다면 특별 메시지 표시
    mov eax, currentStep
    cmp eax, dropStep
    jne PrintNewline
    INVOKE PrintString, ADDR fmtDrop
    jmp ContinueLoop

PrintNewline:
    INVOKE PrintString, ADDR fmtNormal

ContinueLoop:
    inc currentStep
    cmp currentStep, TOTAL_STEPS
    jbe WalkLoop

    ; 4. 시뮬레이션 최종 요약 정보 출력
    INVOKE wsprintfA, ADDR buffer, ADDR msgSummary, dropStep, phoneX, phoneY
    INVOKE PrintString, ADDR buffer

    INVOKE ExitProcess, 0
main ENDP

END main