# 1. What is the purpose of the STRUCT directive? 

(1. STRUCT 지시어의 목적은 무엇인가요?)

---

## 💡 답

`STRUCT` 지시어는 어셈블리 언어(Assembly Language)에서 **서로 관련 있는 여러 변수(필드)들을 하나로 묶어 사용자 정의 데이터 타입(구조체)으로 정의할 때 사용**됩니다. (C/C++ 언어의 `struct` 키워드와 동일한 역할을 수행합니다.)

---

## 📝 상세 풀이

1. **데이터의 구조화 (Data Grouping)**
   - 서로 다른 데이터 타입을 가지는 여러 변수들을 하나의 대표 이름 아래 그룹화합니다.
2. **메모리 오프셋(Offset) 자동 관리**
   - 각 필드의 상대적 메모리 위치(오프셋)를 어셈블러가 자동으로 계산해 줍니다.
   - `구조체변수.필드명` 형태로 안전하게 메모리에 접근할 수 있습니다.
3. **코드 가독성 및 재사용성 (Readability & Reusability)**
   - 데이터 레이아웃을 템플릿 형태로 미리 정의하여 가독성을 높이고, 동일한 구조의 인스턴스를 쉽게 재사용할 수 있습니다.

---

## 💻 어셈블리 코드 예시

```assembly
; ============================================
; MASM (Microsoft Macro Assembler) STRUCT 예제
; ============================================

; 1. STRUCT 정의 (구조체 템플릿 생성)
Student STRUCT
    stdID   DWORD   ?   ; 학번 (4 바이트)
    age     WORD    ?   ; 나이 (2 바이트)
    score   BYTE    ?   ; 점수 (1 바이트)
Student ENDS

.data
    ; 2. 구조체 변수 선언 및 초기화
    student1 Student <20260001, 20, 95>

.code
main PROC
    ; 3. 구조체 필드 접근
    mov eax, student1.stdID   ; student1의 학번을 EAX 레지스터에 저장
    mov cx, student1.age      ; student1의 나이를 CX 레지스터에 저장
    mov bl, student1.score    ; student1의 점수를 BL 레지스터에 저장

    ret
main ENDP
```


---

# 2. Assume that the following structure has been defined:

```assembly
RentalInvoice STRUCT
    invoiceNum BYTE 5 DUP(' ')
    dailyPrice WORD ?
    daysRented WORD ?
RentalInvoice ENDS
```

State whether or not each of the following declarations is valid:

* **a.** `rentals RentalInvoice <>`
* **b.** `RentalInvoice rentals <>`
* **c.** `march RentalInvoice <'12345',10,0>`
* **d.** `RentalInvoice <,10,0>`
* **e.** `current RentalInvoice <,15,0,0>`

(2. 다음 구조체가 정의되어 있다고 가정합니다. 아래의 각 선언문이 유효한지[Valid] 유효하지 않은지[Invalid] 기술하세요.)

---

## 💡 답

* **a.** `rentals RentalInvoice <>` ➜ **Valid (유효함)**
* **b.** `RentalInvoice rentals <>` ➜ **Invalid (유효하지 않음)**
* **c.** `march RentalInvoice <'12345',10,0>` ➜ **Valid (유효함)**
* **d.** `RentalInvoice <,10,0>` ➜ **Invalid (유효하지 않음)**
* **e.** `current RentalInvoice <,15,0,0>` ➜ **Invalid (유효하지 않음)**

---

## 📝 상세 풀이

**[구조체 정의 분석]**
* `invoiceNum`: 5바이트 문자열/배열 (1번째 필드)
* `dailyPrice`: WORD 타입 / 2바이트 (2번째 필드)
* `daysRented`: WORD 타입 / 2바이트 (3번째 필드)
* **총 필드 개수: 3개**

---

### 항목별 상세 설명

* **a. `rentals RentalInvoice <>`** ➜ **Valid**
  - **이유:** `[변수명] [구조체타입] <초기화값>` 문법을 정확히 따르고 있습니다. `<>`는 구조체 정의 시 지정된 기본값을 그대로 사용하겠다는 의미입니다.

* **b. `RentalInvoice rentals <>`** ➜ **Invalid**
  - **이유:** 문법 순서가 틀렸습니다. 어셈블리(MASM)에서는 C/C++ 방식(`타입 변수명`)이 아닌 **`변수명 타입`** 순서로 선언해야 합니다.

* **c. `march RentalInvoice <'12345',10,0>`** ➜ **Valid**
  - **이유:** 3개의 필드 순서대로 `'12345'`(5바이트 문자열), `10`(WORD), `0`(WORD) 값이 올바르게 매칭되었습니다.

* **d. `RentalInvoice <,10,0>`** ➜ **Invalid**
  - **이유:** 구조체 변수 이름(Identifier)이 누락되었습니다. 데이터 세그먼트에서 인스턴스를 선언할 때는 변수명이 반드시 필요합니다.

* **e. `current RentalInvoice <,15,0,0>`** ➜ **Invalid**
  - **이유:** 초기화 값의 개수가 초과되었습니다. `RentalInvoice` 구조체 필드는 총 3개인데, `<, 15, 0, 0>`으로 4개의 값을 전달했기 때문에 컴파일 에러가 발생합니다.

 
  ---


# 3. (True/False): A macro cannot contain data definitions.

(3. [참/거짓]: 매크로는 데이터 정의를 포함할 수 없다.)

---

## 💡 답

**False (거짓)**

---

## 📝 상세 풀이

1. **매크로 내 데이터 정의 가능**
   - 어셈블리 언어에서 매크로(Macro) 내부에는 실행 명령어뿐만 아니라 `BYTE`, `DWORD`, `DB` 등과 같은 **데이터 정의(변수 선언 및 초기화)를 포함할 수 있습니다.**

2. **매크로 확장(Expansion) 원리**
   - 매크로가 호출되면 어셈블러는 매크로 내부에 정의된 코드와 데이터 레이아웃을 호출 위치에 그대로 텍스트 치환(Expansion)하여 대입합니다.

3. **주의사항 (`LOCAL` 지시어 사용)**
   - 매크로 내부에서 데이터 라벨(변수명)을 정의하고 그 매크로를 여러 번 호출하면 라벨 이름 중복(Redefinition) 에러가 발생할 수 있습니다.
   - 따라서 매크로 안에서 데이터를 정의할 때는 보통 **`LOCAL` 지시어**를 함께 사용하여 호출될 때마다 유일한 라벨 이름을 생성하도록 작성합니다.

```assembly
; 예시: 데이터 정의를 포함하는 매크로
MyMacro MACRO msgText
    LOCAL msg           ; 라벨 중복 방지
    .data
        msg BYTE msgText, 0
    .code
        mov edx, OFFSET msg
        call WriteString
ENDM
```

---

# 4. What is the purpose of the LOCAL directive?

(4. LOCAL 지시어의 목적은 무엇인가요?)

---

## 💡 답

`LOCAL` 지시어는 **매크로(Macro) 내부에서 사용되는 라벨(Label)이나 변수명을 호출할 때마다 고유(Unique)한 이름으로 생성하도록 하여, 매크로를 여러 번 사용할 때 발생하는 '라벨 중복 정의 오류(Duplicate Symbol Error)'를 방지하는 목적**으로 사용됩니다.

---

## 📝 상세 풀이

1. **라벨 중복 정의 오류 방지**
   - 매크로 내부에 조건문이나 반복문을 위한 점프 라벨(예: `target:`) 또는 데이터 라벨이 포함되어 있을 때, 해당 매크로를 코드 내에서 2회 이상 호출하면 identical(동일한) 라벨이 여러 번 선언되어 컴파일 에러가 일어납니다.

2. **고유 라벨 자동 생성**
   - 매크로 시작 부분에 `LOCAL label1, label2` 형태로 지정하면, 어셈블러가 매크로를 확장(Expand)할 때마다 해당 라벨들을 `??0000`, `??0001`과 같이 유일한 식별자로 자동 변경해 줍니다.

3. **작성 시 유의사항**
   - `LOCAL` 지시어는 반드시 매크로 정의(`MACRO`) 바로 다음 줄, 즉 **실행 가능 코드나 데이터가 시작되기 전 첫 번째 줄**에 위치해야 합니다.

---

## 💻 어셈블리 코드 예시

```assembly
; LOCAL 지시어를 사용한 매크로 정의
AbsoluteVal MACRO reg
    LOCAL exit              ; exit 라벨을 LOCAL로 선언

    cmp reg, 0
    jge exit                ; reg >= 0 이면 exit로 점프
    neg reg                 ; reg가 음수이면 양수로 전환

exit:                       ; 매크로가 여러 번 호출되어도 매번 유일한 라벨로 변환됨
ENDM
```


---

# 5. Which directive displays a message on the console during the assembly step?

(5. 어셈블리 단계에서 콘솔에 메시지를 출력하는 지시어는 무엇인가요?)

---

## 💡 답

**`ECHO` 지시어** (또는 기존 어셈블러 방식인 **`%OUT` 지시어**)

---

## 📝 상세 풀이

1. **어셈블 시점(Assembly-time) 메시지 출력**
   - `ECHO` 지시어는 프로그램이 실제로 **실행될 때(Runtime)가 아닌, 어셈블러가 코드를 조립/컴파일하는 단계(Assemble-time)에서** 출력창(콘솔)에 문자열 메시지를 표시합니다.

2. **주요 활용 목적**
   - 매크로 확장 과정이나 빌드 진행 상황을 확인할 때
   - 조건부 어셈블리(`IF`, `IFDEF` 등) 조건에 따라 사용자에게 알림 또는 경고 메시지를 표시할 때
   - 디버깅용 어셈블 시점 메시지 출력할 때

3. **실행 시점(Runtime) 출력과의 차이점**
   - `WriteString`이나 `WriteConsole`과 같은 함수는 프로그램 **실행 중**에 사용자에게 메시지를 보여주지만, `ECHO`는 **소스 코드를 빌드하는 도중**에 개발자(어셈블러 화면)에게 메시지를 보여줍니다.

---

## 💻 어셈블리 코드 예시

```assembly
; 어셈블리(빌드) 중에 메시지가 출력됨
ECHO Compiling the Main Module...

IFDEF DEBUG_MODE
    ECHO [WARNING] Debug mode is currently enabled!
ENDIF
```

---

# 6. Which directive marks the end of a conditional block of statements?

(6. 조건부 블록의 끝을 나타내는 지시어는 무엇인가요?)

---

## 💡 답

**`ENDIF` 지시어**

---

## 📝 상세 풀이

1. **`ENDIF` 지시어의 역할**
   - `IF`, `IFDEF`, `IFNDEF` 등 조건부 어셈블리(Conditional Assembly) 지시어로 시작된 **조건문 블록의 종결**을 어셈블러에 알리는 지시어입니다.

2. **기본 구문 구조**
   - 모든 조건부 블록은 `IF` 계열 지시어로 시작하여 반드시 `ENDIF`로 닫아야 합니다.
   ```assembly
   IF 조건식
       ; 조건이 참일 때 포함될 코드
   ELSE
       ; 조건이 거짓일 때 포함될 코드
   ENDIF
   ```

3. **주의사항**
   - 조건부 블록 내에 `ENDIF`가 누락되거나 중첩(Nesting) 관계가 맞지 않으면 어셈블러 컴파일 에러가 발생합니다.

---

## 💻 어셈블리 코드 예시

```assembly
; DEBUG 라벨이 정의되어 있는지 확인하는 조건부 블록 예시
IFDEF DEBUG
    mov eax, 1      ; DEBUG 모드일 때 포함됨
ELSE
    mov eax, 0      ; Release 모드일 때 포함됨
ENDIF               ; 조건부 블록의 끝을 표시
```


---

# 7. List all the relational operators that can be used in constant boolean expressions

(7. 상수 불리언 표현식에 사용할 수 있는 모든 관계 연산자를 나열하세요.)

---

## 💡 답

어셈블리(MASM)의 상수 불리언 표현식(`IF` 지시어 등)에서 사용되는 기본 관계 연산자는 다음 **6가지**입니다.

1. **`EQ`** (Equal - 같다)
2. **`NE`** (Not Equal - 같지 않다)
3. **`LT`** (Less Than - 작다 / 미만)
4. **`LE`** (Less Than or Equal - 작거나 같다 / 이하)
5. **`GT`** (Greater Than - 크다 / 초과)
6. **`GE`** (Greater Than or Equal - 크거나 같다 / 이상)

*(참고: `.IF`, `.WHILE` 등 고수준 지시어 구문에서는 `==`, `!=`, `<`, `<=`, `>`, `>=` 기호 표기법도 함께 지원됩니다.)*

---

## 📝 상세 풀이

상수 불리언 표현식은 어셈블 시점(Assembly-time)에 계산되는 조건문으로, 연산자의 종류와 의미는 다음과 같습니다.

| 연산자 (Operator) | 기호 대응 | 의미 (Meaning) | 조건식 예시 |
| :---: | :---: | :--- | :--- |
| **EQ** | `==` | Equal (같음) | `IF count EQ 10` |
| **NE** | `!=` | Not Equal (같지 않음) | `IF val NE 0` |
| **LT** | `<` | Less Than (미만) | `IF bufferSize LT 256` |
| **LE** | `<=` | Less Than or Equal (이하) | `IF count LE 100` |
| **GT** | `>` | Greater Than (초과) | `IF total GT 50` |
| **GE** | `>=` | Greater Than or Equal (이상) | `IF limit GE 1000` |

---

## 💻 어셈블리 코드 예시

```assembly
BUFFER_SIZE = 512

; EQ 연산자 사용 예시
IF BUFFER_SIZE EQ 512
    ECHO Buffer size is correctly set to 512.
ENDIF

; GT 연산자 사용 예시
IF BUFFER_SIZE GT 256
    ECHO Buffer size exceeds 256 bytes.
ENDIF
```


---

# 8. What is the purpose of the & operator in a macro definition?

(8. 매크로 정의에서 & 연산자의 목적은 무엇인가요?)

---

## 💡 답

`&` 연산자(치환 연산자, Substitution Operator)는 **매크로 매개변수가 다른 텍스트나 식별자(라벨, 변수명 등)와 접해 있을 때, 어셈블러가 이를 매개변수로 명확히 인식하여 실제 전달된 값으로 강제 치환 및 결합(Concatenation)하도록 만드는 목적**으로 사용됩니다.

---

## 📝 상세 풀이

1. **텍스트 결합 및 강제 치환 (Text Concatenation & Substitution)**
   - 전달받은 매크로 매개변수를 다른 문자열/식별자와 붙여서 새로운 변수명이나 라벨을 동적으로 생성할 때 사용합니다.
   - 예: `var_&suffix`에 `suffix` 값으로 `1`을 전달하면 `var_1`이라는 식별자로 치환됩니다.

2. **식별자 모호성 해결 (Ambiguity Resolution)**
   - 매개변수가 기존 단어의 일부처럼 보일 경우, 어셈블러는 이를 매개변수가 아닌 일반 텍스트나 별개의 식별자로 착각할 수 있습니다.
   - `&` 연산자를 매개변수 양옆이나 앞뒤에 붙여주면 어셈블러에게 **"이 부분은 매크로 매개변수이니 전달받은 인수(Argument) 값으로 바꾸라"**고 명시해 줍니다.

---

## 💻 어셈블리 코드 예시

```assembly
; 1. & 연산자를 사용한 변수 선언 매크로
MakeVar MACRO index
    var_&index DWORD ?   ; index가 5로 들어오면 'var_5 DWORD ?' 로 결합 및 치환됨
ENDM

; 2. & 연산자를 사용한 메시지 출력 매크로
PrintMessage MACRO text
    msg_&text BYTE "Error in &text", 0
ENDM

.data
    MakeVar 1            ; 생성 결과: var_1 DWORD ?
    MakeVar 2            ; 생성 결과: var_2 DWORD ?
    PrintMessage Main    ; 생성 결과: msg_Main BYTE "Error in Main", 0
```


---

# 9. What is the purpose of the ! operator in a macro definition?

(9. 매크로 정의에서 ! 연산자의 목적은 무엇인가요?)

---

## 💡 답

`!` 연산자(리터럴 문자 연산자, Literal-Character / Escape Operator)는 **매크로 내부에서 특별한 의미(구분자, 주석 시작 등)를 가지는 특수 문자를 고유 기능 없이 일반 문자 그대로 취급(이스케이프 처리)하도록 만드는 목적**으로 사용됩니다.

---

## 📝 상세 풀이

1. **특수 문자의 고유 기능 무효화 (Escape)**
   - 매크로 처리기(Macro Processor)에서 쉼표(`,`)는 인자 구분자, 세미콜론(`;`)은 주석 시작 기호로 사용됩니다.
   - 특수 문자 앞에 `!`를 붙이면(예: `!,`, `!;`) 어셈블러가 이를 명령어나 제어 기호로 해석하지 않고 일반 문자로 인식합니다.

2. **주요 활용 대상**
   - 세미콜론(`;`), 쉼표(`,`), 따옴표(`"`, `'`), 꺾쇠괄호(`<`, `>`), 백센트(`%`), 앰퍼샌드(`&`), 느낌표(`!`) 등 어셈블러의 문법 규칙에 영향을 주는 기호들을 문자열 그대로 전달할 때 사용됩니다.

---

## 💻 어셈블리 코드 예시

```assembly
; ! 연산자 사용 예제
ShowLiteral MACRO
    ; 세미콜론(;) 앞에 !를 붙여 주석 기호가 아닌 실제 문자 세미콜론으로 포함시킴
    BYTE "Hello!; World", 0
    
    ; 쉼표(,) 앞에 !를 붙여 인자 구분자가 아닌 일반 문자로 인식시킴
    BYTE "Item1!, Item2", 0
ENDM
```


---

# 10. What is the purpose of the % operator in a macro definition?

(10. 매크로 정의에서 % 연산자의 목적은 무엇인가요?)

---

## 💡 답

`%` 연산자(확장 연산자, Expansion Operator)는 **상수 표현식(Constant Expression)이나 심볼(Symbol)을 매크로에 전달하거나 처리하기 직전에, 어셈블러가 그 수식을 먼저 계산(평가)하여 최종 결괏값(텍스트)으로 치환하도록 강제하는 목적**으로 사용됩니다.

---

## 📝 상세 풀이

1. **상수 수식의 사전 계산 및 평가 (Evaluation)**
   - 매크로 인수로 수식(예: `10 + 20`)을 넘길 때, `%` 연산자를 사용하지 않으면 `10 + 20`이라는 수식 텍스트 자체가 전달됩니다.
   - 하지만 `%(10 + 20)` 형태로 `%`를 붙여서 넘기면 계산이 완료된 결과 텍스트인 `30`이 매크로로 전달됩니다.

2. **빌드 시점(`ECHO`) 메시지 출력 시 활용**
   - 어셈블 시점에 `ECHO` 지시어와 함께 사용하여 상수의 실제 계산된 값을 출력창에 디버깅용으로 표시할 때 자주 활용됩니다. (예: `ECHO %COUNT`)

---

## 💻 어셈블리 코드 예시

```assembly
BUFFER_SIZE = 1024 * 4

PrintValue MACRO val
    ECHO The size is: val
ENDM

.code
    ; 1. % 연산자를 안 쓴 경우
    PrintValue BUFFER_SIZE 
    ; 출력 결과 ➜ The size is: BUFFER_SIZE

    ; 2. % 연산자를 사용한 경우 (미리 계산하여 값으로 변환)
    PrintValue %BUFFER_SIZE 
    ; 출력 결과 ➜ The size is: 4096
```

---

# 1. Create a structure named SampleStruct containing two fields: field1, a single 16-bit WORD, and field2, an array of 20 32-bit DWORDs. The initial values of the fields may be left undefined.

(1. 단일 16비트 WORD인 field1과 20개의 32비트 DWORD 배열인 field2의 두 필드를 포함하는 SampleStruct라는 이름의 구조체를 생성하세요. 필드의 초기값은 미정의[undefined] 상태로 두어도 됩니다.)

---

## 💡 답

```assembly
SampleStruct STRUCT
    field1 WORD     ?
    field2 DWORD    20 DUP(?)
SampleStruct ENDS
```

---

## 📝 상세 풀이

1. **구조체 선언 기본 구조**
   - 어셈블리(MASM)에서 구조체는 `[구조체명] STRUCT`로 시작하여 `[구조체명] ENDS`로 마칩니다.

2. **`field1` 정의**
   - 16비트 정수 타입인 `WORD`를 사용하고, 초기값을 미정의 상태로 두기 위해 `?`를 지정했습니다.

3. **`field2` 정의**
   - 32비트 정수 타입인 `DWORD`를 사용하고, 20개의 원소를 가지는 배열을 만들기 위해 `20 DUP(?)` 구문을 사용했습니다.

---

## 💻 전체 코드 적용 예시

```assembly
; 구조체 정의
SampleStruct STRUCT
    field1 WORD     ?
    field2 DWORD    20 DUP(?)
SampleStruct ENDS

.data
    ; 구조체 인스턴스(변수) 생성 예시
    mySample SampleStruct <>

.code
main PROC
    ; 구조체 필드 접근 예시
    mov ax, mySample.field1        ; field1 값 불러오기
    mov mySample.field2[0], 100    ; field2 첫 번째 배열 원소에 100 저장
    ret
main ENDP
```


---

# 2. Write a statement that retrieves the wHour field of a SYSTEMTIME structure.

(2. SYSTEMTIME 구조체의 wHour 필드 값을 가져오는(읽어오는) 어셈블리 명령문을 작성하세요.)

---

## 💡 답

```assembly
mov ax, sysTime.wHour
```
*(또는 32비트 레지스터로 읽어올 경우: `movzx eax, sysTime.wHour`)*

---

## 📝 상세 풀이

1. **`SYSTEMTIME` 구조체 구성**
   - Windows API의 `SYSTEMTIME` 구조체는 연, 월, 일, 시, 분, 초 등을 보유하고 있으며, 각 필드는 **16비트(WORD) 크기**로 정의되어 있습니다.
   ```assembly
   SYSTEMTIME STRUCT
       wYear         WORD ?
       wMonth        WORD ?
       wDayOfWeek    WORD ?
       wDay          WORD ?
       wHour         WORD ?   ; <--- 16비트 WORD 필드
       wMinute       WORD ?
       wSecond       WORD ?
       wMilliseconds WORD ?
   SYSTEMTIME ENDS
   ```

2. **레지스터 선택**
   - `wHour` 필드가 16비트(`WORD`) 타입이므로, 데이터 크기를 맞추기 위해 **16비트 레지스터인 `AX`**(또는 `BX`, `CX`, `DX`)를 사용하여 값을 가져옵니다.
   - 만약 32비트 레지스터(`EAX`)에 값을 넣고자 할 때는 부호 없는 확장 명령어인 **`MOVZX`**를 활용하는 것이 일반적입니다.

---

## 💻 전체 코드 적용 예시

```assembly
INCLUDE Irvine32.inc

.data
    sysTime SYSTEMTIME <>

.code
main PROC
    ; 현재 시스템 시간 가져오기 (Windows API 호출)
    INVOKE GetLocalTime, ADDR sysTime

    ; wHour 필드 값 레지스터로 추출
    mov ax, sysTime.wHour        ; AX 레지스터에 '시(Hour)' 저장
    
    ; 레지스터 값 확인
    movzx eax, sysTime.wHour     ; EAX에 0으로 채워서 확장 저장
    call WriteDec                ; 콘솔에 현재 '시' 출력

    exit
main ENDP
END main
```


---

# 3. Using the following Triangle structure, declare a structure variable and initialize its vertices to (0,0), (5, 0), and (7,6):

```assembly
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS
```

(3. 제공된 Triangle 구조체를 사용하여, 꼭짓점(vertices)을 각각 (0,0), (5,0), (7,6)으로 초기화하는 구조체 변수를 선언하세요.)

---

## 💡 답

```assembly
myTriangle Triangle <<0, 0>, <5, 0>, <7, 6>>
```

---

## 📝 상세 풀이

1. **중첩 구조체(Nested Structure) 초기화 방식**
   - `COORD` 구조체는 Windows API에 정의된 좌표 구조체로, `X`와 `Y` 2개의 필드(`WORD` 타입)로 구성되어 있습니다.
   - `Triangle` 구조체 내부에는 3개의 `COORD` 구조체(`Vertex1`, `Vertex2`, `Vertex3`)가 중첩 정의되어 있습니다.

2. **꺾쇠괄호(`< >`) 문법**
   - 어셈블리(MASM)에서 중첩된 구조체 변수를 초기화할 때는 외부 꺾쇠괄호 `< >` 안에 각 내부 구조체의 꺾쇠괄호 `<X, Y>`를 순서대로 나열합니다.
   - **`Vertex1`**: `<0, 0>` ➜ X=0, Y=0
   - **`Vertex2`**: `<5, 0>` ➜ X=5, Y=0
   - **`Vertex3`**: `<7, 6>` ➜ X=7, Y=6

---

## 💻 전체 코드 적용 예시

```assembly
INCLUDE Irvine32.inc

; COORD 구조체 (Irvine32.inc에 미포함 시 직접 정의)
; COORD STRUCT
;     X SWORD ?
;     Y SWORD ?
; COORD ENDS

Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS

.data
    ; 구조체 변수 선언 및 초기화
    myTriangle Triangle <<0, 0>, <5, 0>, <7, 6>>

.code
main PROC
    ; 접근 예시: Vertex3의 X, Y 좌표를 레지스터로 복사
    mov ax, myTriangle.Vertex3.X    ; AX = 7
    mov bx, myTriangle.Vertex3.Y    ; BX = 6

    exit
main ENDP
END main
```


---

# 4. Declare an array of Triangle structures. Write a loop that initializes Vertex1 of each triangle to random coordinates in the range (0...10, 0...10).

(4. Triangle 구조체 배열을 선언하세요. 그리고 각 삼각형의 Vertex1을 (0...10, 0...10) 범위의 난수(Random) 좌표로 초기화하는 루프(반복문)를 작성하세요.)

---

## 💡 답

```assembly
.data
    TRIANGLE_COUNT = 10
    triangles Triangle TRIANGLE_COUNT DUP(<>)

.code
    mov esi, OFFSET triangles
    mov ecx, TRIANGLE_COUNT

InitLoop:
    ; Vertex1.X 좌표 생성 (0 ~ 10)
    mov eax, 11               ; RandomRange의 상한값 (0~10 난수 생성)
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.X, ax

    ; Vertex1.Y 좌표 생성 (0 ~ 10)
    mov eax, 11
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.Y, ax

    add esi, SIZEOF Triangle   ; 다음 Triangle 구조체 위치로 이동 (12 바이트 증가)
    loop InitLoop
```

---

## 📝 상세 풀이

1. **구조체 배열 선언**
   - `triangles Triangle TRIANGLE_COUNT DUP(<>)` 구문을 사용하여 `Triangle` 구조체 10개짜리 배열을 선언하고 기본값으로 초기화합니다.

2. **난수 생성 범위 (`RandomRange`)**
   - Irvine32 라이브러리의 `RandomRange` 함수는 `EAX`에 $N$을 넣고 호출하면 **$0$부터 $N-1$까지**의 정수 난수를 반환합니다.
   - 문제에서 원하는 범위가 $0 \sim 10$이므로 `mov eax, 11`을 설정하고 호출합니다.

3. **구조체 배열의 오프셋 이동**
   - `Triangle` 구조체 1개의 크기는 `COORD` 3개 ($4 \text{ bytes} \times 3 = 12 \text{ bytes}$)로 총 **12바이트**입니다.
   - 따라서 반복문이 실행될 때마다 인덱스 포인터 레지스터인 `ESI`에 `SIZEOF Triangle` (12 바이트)을 더해 다음 구조체 요소로 이동합니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; COORD 및 Triangle 구조체 정의
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS

.data
    TRIANGLE_COUNT = 5
    triangles Triangle TRIANGLE_COUNT DUP(<>)

.code
main PROC
    call Randomize              ; 난수 생성기 초기화

    mov esi, OFFSET triangles   ; 배열 시작 주소
    mov ecx, TRIANGLE_COUNT     ; 루프 카운트

InitLoop:
    ; 1. Vertex1.X 난수 설정 (0~10)
    mov eax, 11
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.X, ax

    ; 2. Vertex1.Y 난수 설정 (0~10)
    mov eax, 11
    call RandomRange
    mov (Triangle PTR [esi]).Vertex1.Y, ax

    ; 3. 다음 Triangle 배열 항목으로 오프셋 이동
    add esi, SIZEOF Triangle
    loop InitLoop

    exit
main ENDP
END main
```

---

# 5. Write a macro named mPrintChar that displays a single character on the screen. It should have two parameters: this first specifies the character to be displayed and the second specifies how many times the character should be repeated. Here is a sample call: mPrintChar 'X',20

(5. 화면에 단일 문자를 출력하는 mPrintChar라는 이름의 매크로를 작성하세요. 이 매크로는 두 개의 매개변수를 가져야 합니다. 첫 번째는 출력할 문자이고, 두 번째는 문자를 반복할 횟수입니다. 호출 예시: mPrintChar 'X',20)

---

## 💡 답

```assembly
mPrintChar MACRO char, count
    LOCAL L1
    push eax
    push ecx

    mov al, char
    mov ecx, count

L1:
    call WriteChar
    loop L1

    pop ecx
    pop eax
ENDM
```

---

## 📝 상세 풀이

1. **매크로 매개변수 정의**
   - `mPrintChar MACRO char, count`: 출력할 문자(`char`)와 반복 횟수(`count`) 두 인자를 매개변수로 지정합니다.

2. **`LOCAL L1` 사용**
   - 매크로 내부에서 `L1` 루프 라벨을 사용하므로, 매크로가 여러 번 호출될 때 라벨 이름이 중복 정의(Duplicate Symbol)되는 에러를 막기 위해 `LOCAL` 지시어로 라벨을 선언합니다.

3. **레지스터 보존 (`PUSH` / `POP`)**
   - 매크로 내부에서 `EAX`와 `ECX` 레지스터를 변경하므로, 호출 전 상태를 안전하게 보호하기 위해 시작 시 `PUSH`하고 종료 시 역순으로 `POP`하여 레지스터 값을 복원합니다.

4. **문자 출력 루프**
   - `WriteChar`(Irvine32 라이브러리 함수)는 `AL` 레지스터에 있는 문자를 화면에 출력합니다.
   - `ECX`에 반복 횟수를 대입한 뒤 `LOOP` 문을 활용하여 지정된 횟수만큼 반복 출력합니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; mPrintChar 매크로 정의
mPrintChar MACRO char, count
    LOCAL L1
    push eax
    push ecx

    mov al, char
    mov ecx, count

L1:
    call WriteChar
    loop L1

    pop ecx
    pop eax
ENDM

.code
main PROC
    ; 'X' 문자를 20번 연속 출력
    mPrintChar 'X', 20

    call Crlf ; 줄바꿈

    ; '*' 문자를 10번 연속 출력
    mPrintChar '*', 10

    exit
main ENDP
END main
```

---

# 6. Write a macro named mGenRandom that generates a random integer between 0 and n - 1. Let n be the only parameter.

(6. 0과 n - 1 사이의 정수 난수를 생성하는 mGenRandom이라는 이름의 매크로를 작성하세요. 매개변수는 n 하나만 사용해야 합니다.)

---

## 💡 답

```assembly
mGenRandom MACRO n
    mov eax, n
    call RandomRange
ENDM
```

---

## 📝 상세 풀이

1. **`RandomRange` 동작 방식 (Irvine32 라이브러리)**
   - `RandomRange` 함수는 `EAX` 레지스터에 상한값 $N$을 전달받아 **$0$부터 $N - 1$까지** 범위의 32비트 임의의 정수(난수)를 생성합니다.

2. **매크로 처리 로직**
   - 인수로 전달받은 `n` 값을 `EAX` 레지스터에 복사한 후 `call RandomRange`를 실행합니다.
   - 매크로가 실행 완료되면 **생성된 난수 결괏값이 `EAX` 레지스터에 저장**되어 남게 됩니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; mGenRandom 매크로 정의
mGenRandom MACRO n
    mov eax, n
    call RandomRange
ENDM

.code
main PROC
    call Randomize          ; 난수 생성기 시드(Seed) 초기화

    ; 0 ~ 99 사이의 난수 생성 (n = 100)
    mGenRandom 100
    call WriteDec           ; EAX에 생성된 난수 콘솔 출력
    call Crlf               ; 줄바꿈

    ; 0 ~ 49 사이의 난수 생성 (n = 50)
    mGenRandom 50
    call WriteDec           ; EAX에 생성된 난수 콘솔 출력
    call Crlf

    exit
main ENDP
END main
```

---

# 7. Write a macro named mPromptInteger that displays a prompt and inputs an integer from the user. Pass it a string literal and the name of a doubleword variable. Sample call:
.data
minVal DWORD ?
.code
mPromptInteger "Enter the minimum value", minVal

(7. 프롬프트 메시지를 화면에 출력하고 사용자로부터 정수를 입력받는 mPromptInteger라는 이름의 매크로를 작성하세요. 매개변수로 문자열 리터럴과 더블워드(DWORD) 변수의 이름을 전달하세요. 호출 예시: mPromptInteger "Enter the minimum value", minVal)

---

## 💡 답

```assembly
mPromptInteger MACRO prompt, varName
    LOCAL promptStr
    .data
        promptStr BYTE prompt, 0
    .code
        push edx
        push eax

        mov edx, OFFSET promptStr
        call WriteString
        call ReadInt
        mov varName, eax

        pop eax
        pop edx
ENDM
```

---

## 📝 상세 풀이

1. **문자열 동적 선언 (`LOCAL` 및 `.data`)**
   - 문자열 리터럴(`prompt`)을 전달받아 메모리에 저장하기 위해 매크로 내부에서 `.data` 세그먼트를 엽니다.
   - 매크로가 여러 번 호출되더라도 문자열 변수명이 충돌하지 않도록 **`LOCAL promptStr`** 지시어로 독립된 라벨을 선언합니다.

2. **프롬프트 출력 및 정수 입력**
   - `WriteString`을 호출하기 위해 생성된 프롬프트 문자열의 오프셋 주소를 `EDX` 레지스터에 탑재합니다.
   - Irvine32 라이브러리의 **`ReadInt`** 프로시저를 호출하여 사용자 입력 정수를 `EAX` 레지스터로 읽어옵니다.

3. **결과 저장 및 레지스터 보존**
   - `EAX`에 저장된 입력값을 매개변수로 전달받은 `varName` 변수에 복사합니다.
   - 매크로 실행 중 사용된 `EDX`와 `EAX` 레지스터의 기존 상태를 유지하기 위해 `PUSH` / `POP`을 수행합니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; mPromptInteger 매크로 정의
mPromptInteger MACRO prompt, varName
    LOCAL promptStr
    .data
        promptStr BYTE prompt, 0
    .code
        push edx
        push eax

        mov edx, OFFSET promptStr
        call WriteString
        call ReadInt
        mov varName, eax

        pop eax
        pop edx
ENDM

.data
    minVal DWORD ?
    maxVal DWORD ?

.code
main PROC
    ; 사용자로부터 입력받아 minVal에 저장
    mPromptInteger "Enter the minimum value: ", minVal

    ; 사용자로부터 입력받아 maxVal에 저장
    mPromptInteger "Enter the maximum value: ", maxVal

    call Crlf

    ; 입력받은 minVal 값 확인 출력
    mov eax, minVal
    call WriteInt
    call Crlf

    exit
main ENDP
END main
```


---

# 8. Write a macro named mWriteAt that locates the cursor and writes a string literal to the console window. Suggestion: Invoke the mGotoxy and mWrite macros from the book’s macro library.

(8. 커서 위치를 이동한 후 문자열 리터럴을 콘솔 창에 출력하는 mWriteAt이라는 이름의 매크로를 작성하세요. 제안: 교재의 매크로 라이브러리에 있는 mGotoxy와 mWrite 매크로를 호출하여 구현하세요.)

---

## 💡 답

```assembly
mWriteAt MACRO X, Y, text
    mGotoxy X, Y
    mWrite text
ENDM
```

---

## 📝 상세 풀이

1. **매크로 중첩 호출 (Macro Composition)**
   - 교재(Irvine32 라이브러리)에서 미리 제공하는 **`mGotoxy`** 매크로와 **`mWrite`** 매크로를 내부에서 조합하여 가독성이 높고 재사용이 용이한 고수준 매크로를 정의합니다.

2. **매개변수 구성**
   - `X`: 열(Column) 위치 (0 ~ 79)
   - `Y`: 행(Row) 위치 (0 ~ 24)
   - `text`: 콘솔 화면 지정 위치에 출력할 문자열 리터럴

3. **내부 작동 과정**
   - **`mGotoxy X, Y`**: 커서의 위치를 지정된 좌표 (X, Y)로 이동시킵니다.
   - **`mWrite text`**: 해당 위치에서 전달받은 문자열 리터럴을 출력합니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc
INCLUDE Macros.inc      ; mGotoxy 및 mWrite 매크로가 정의된 헤더 파일

; mWriteAt 매크로 정의
mWriteAt MACRO X, Y, text
    mGotoxy X, Y
    mWrite text
ENDM

.code
main PROC
    call Clrscr         ; 화면 지우기

    ; (10, 5) 좌표에 메시지 출력
    mWriteAt 10, 5, "Hello World at (10, 5)"

    ; (20, 10) 좌표에 메시지 출력
    mWriteAt 20, 10, "Assembly Language Programming"

    mGotoxy 0, 15       ; 커서를 아래쪽으로 이동 후 종료 준비
    exit
main ENDP
END main
```

---

# 9. Show the expanded code produced by the following statement that invokes the mWriteString macro from Section 10.2.5: mWriteStr namePrompt

(9. Section 10.2.5의 mWriteString 매크로를 호출하는 mWriteStr namePrompt 명령문에 의해 생성되는 확장[Expanded] 코드를 보여주세요.)

---

## 💡 답

```assembly
push edx
mov edx, OFFSET namePrompt
call WriteString
pop edx
```

---

## 📝 상세 풀이

1. **`mWriteString` (또는 `mWriteStr`) 매크로의 원본 정의**
   - Irvine32 라이브러리의 `mWriteString` 매크로는 전달받은 매개변수(문자열 오프셋 주소)를 `EDX` 레지스터에 탑재하여 출력하도록 아래와 같이 정의되어 있습니다.
   ```assembly
   mWriteString MACRO buffer
       push edx
       mov edx, OFFSET buffer
       call WriteString
       pop edx
   ENDM
   ```

2. **매크로 확장(Macro Expansion) 과정**
   - 어셈블러가 소스 코드에서 `mWriteStr namePrompt` 호출문을 만나면, 매개변수 `buffer` 자리에 인수 `namePrompt`를 대입하여 코드를 텍스트 치환합니다.

3. **확장된 각 명령어의 역할**
   - **`push edx`**: 기존 `EDX` 레지스터의 값을 스택에 보존합니다.
   - **`mov edx, OFFSET namePrompt`**: 출력할 문자열 `namePrompt` 시작 주소를 `EDX`에 전송합니다.
   - **`call WriteString`**: `EDX`가 가리키는 Null 종료 문자열을 콘솔에 출력합니다.
   - **`pop edx`**: 스택에 보존했던 기존 `EDX` 레지스터 값을 복원합니다.

---

## 💻 소스 코드 및 확장 결과 비교

```assembly
; [사용자가 작성한 소스 코드]
mWriteStr namePrompt

; ============================================
; [어셈블러가 컴파일 시점에 확장 생성하는 코드]
; ============================================
1 push edx
1 mov edx, OFFSET namePrompt
1 call WriteString
1 pop edx
```

---

# 10. Show the expanded code produced by the following statement that invokes the mReadString macro from Section 10.2.5: mReadStr customerName

(10. Section 10.2.5의 mReadString 매크로를 호출하는 mReadStr customerName 명령문에 의해 생성되는 확장[Expanded] 코드를 보여주세요.)

---

## 💡 답

```assembly
push ecx
push edx
mov edx, OFFSET customerName
mov ecx, SIZEOF customerName
call ReadString
pop edx
pop ecx
```

---

## 📝 상세 풀이

1. **`mReadString` (또는 `mReadStr`) 매크로의 원본 정의**
   - Irvine32 라이브러리의 `mReadString` 매크로는 입력받을 버퍼의 위치(`OFFSET`)와 버퍼의 최대 크기(`SIZEOF`)를 레지스터에 설정하여 사용자 입력을 받도록 아래와 같이 정의되어 있습니다.
   ```assembly
   mReadString MACRO varName
       push ecx
       push edx
       mov edx, OFFSET varName
       mov ecx, SIZEOF varName
       call ReadString
       pop edx
       pop ecx
   ENDM
   ```

2. **매크로 확장(Macro Expansion) 과정**
   - 어셈블러가 소스 코드에서 `mReadStr customerName` 호출문을 만나면, 매개변수 `varName` 위치에 인수 `customerName`을 대입하여 텍스트를 치환 및 확장합니다.

3. **확장된 각 명령어의 역할**
   - **`push ecx`, `push edx`**: 사용될 레지스터의 기존 상태를 스택에 보존합니다.
   - **`mov edx, OFFSET customerName`**: 입력받은 문자열을 저장할 메모리 오프셋 주소를 `EDX`에 전송합니다.
   - **`mov ecx, SIZEOF customerName`**: 버퍼 오버플로우를 방지하기 위해 저장 가능한 최대 바이트 크기(`SIZEOF`)를 `ECX`에 설정합니다.
   - **`call ReadString`**: 키보드로부터 문자열을 입력받는 라이브러리 함수를 호출합니다.
   - **`pop edx`, `pop ecx`**: 스택에 보존했던 레지스터 값을 원래대로 복원합니다.

---

## 💻 소스 코드 및 확장 결과 비교

```assembly
; [사용자가 작성한 소스 코드]
mReadStr customerName

; ============================================
; [어셈블러가 컴파일 시점에 확장 생성하는 코드]
; ============================================
1 push ecx
1 push edx
1 mov edx, OFFSET customerName
1 mov ecx, SIZEOF customerName
1 call ReadString
1 pop edx
1 pop ecx
```


---

# 11. Write a macro named mDumpMemx that receives a single parameter, the name of a variable. Your macro must call the mDumpMem macro from the book’s library, passing it the variable’s offset, number of units, and unit size. Demonstrate a call to the mDumpMemx macro.

(11. 변수명이라는 단일 매개변수를 받는 mDumpMemx라는 이름의 매크로를 작성하세요. 이 매크로는 교재 라이브러리의 mDumpMem 매크로를 호출하며 변수의 오프셋[offset], 단위 개수[number of units], 단위 크기[unit size]를 전달해야 합니다. mDumpMemx 매크로의 호출 시연 코드를 작성하세요.)

---

## 💡 답

```assembly
mDumpMemx MACRO varName
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM
```

---

## 📝 상세 풀이

1. **`mDumpMem` 매크로의 인수 요구사항**
   - 교재(Irvine32) 라이브러리에 정의된 `mDumpMem` 매크로는 메모리 덤프를 위해 **주소(Offset)**, **원소 개수(Count)**, **원소 하나의 바이트 크기(Size)** 3개의 인수를 필요로 합니다.

2. **단일 매개변수를 통한 3가지 속성 자동 추출**
   - `OFFSET varName`: 변수의 시작 메모리 주소를 추출합니다.
   - `LENGTHOF varName`: 변수의 총 요소(단위) 개수를 추출합니다.
   - `TYPE varName`: 변수의 요소 하나당 바이트 크기를 추출합니다. (예: `BYTE`=1, `WORD`=2, `DWORD`=4)

3. **매크로 캡슐화 (Abstraction)**
   - 개발자가 오프셋, 개수, 크기를 매번 일일이 전달하지 않고, 변수 이름 하나(`varName`)만 전달하더라도 매크로 내부에서 연산자를 통해 필요한 정보를 자동으로 계산하여 `mDumpMem`을 호출해 줍니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc
INCLUDE Macros.inc          ; mDumpMem 매크로가 포함된 헤더 파일

; mDumpMemx 매크로 정의
mDumpMemx MACRO varName
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM

.data
    array1 DWORD 10h, 20h, 30h, 40h, 50h
    array2 WORD  1000h, 2000h, 3000h

.code
main PROC
    ; 1. DWORD 배열 메모리 덤프 호출
    mDumpMemx array1

    call Crlf

    ; 2. WORD 배열 메모리 덤프 호출
    mDumpMemx array2

    exit
main ENDP
END main
```

---

# 12. Show an example of a macro parameter having a default argument initializer

(12. 기본 인수 초기화자[default argument initializer]를 가진 매크로 매개변수의 예시를 보여주세요.)

---

## 💡 답

```assembly
; 매개변수 count와 char에 기본값을 지정한 매크로 정의
mPrintLine MACRO count:=<40>, char:=<'*'>
    LOCAL L1
    push eax
    push ecx

    mov al, char
    mov ecx, count

L1:
    call WriteChar
    loop L1
    call Crlf

    pop ecx
    pop eax
ENDM
```

---

## 📝 상세 풀이

1. **기본 인수 초기화 문법 (`:=<기본값>`)**
   - 어셈블리(MASM)에서 매크로 매개변수에 기본값을 부여할 때는 **`매개변수명:=<기본값>`** 구문을 사용합니다.
   - 매크로 호출 시 해당 인수를 생략하면 꺾쇠괄호 `< >` 안에 지정된 기본값이 자동으로 적용됩니다.

2. **호출 형태에 따른 작동 방식**
   - **`mPrintLine`**: 인수를 전달하지 않았으므로 기본값인 `40`번, `'*'` 문자가 출력됩니다.
   - **`mPrintLine 15`**: 첫 번째 인수인 `count`에 `15`가 전달되고, `char`는 생략되었으므로 기본값 `'*'`가 출력됩니다.
   - **`mPrintLine 20, '#'`**: 두 인수 모두 전달되었으므로 `20`번, `'#'` 문자가 출력됩니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; 기본 인수 초기화자를 포함하는 매크로 정의
mPrintLine MACRO count:=<40>, char:=<'*'>
    LOCAL L1
    push eax
    push ecx

    mov al, char
    mov ecx, count

L1:
    call WriteChar
    loop L1
    call Crlf

    pop ecx
    pop eax
ENDM

.code
main PROC
    ; 1. 인수 생략 ➜ 기본값 적용 ('*' 40개 출력)
    mPrintLine

    ; 2. 첫 번째 인수만 전달 ➜ count=15, char는 기본값 적용 ('*' 15개 출력)
    mPrintLine 15

    ; 3. 두 인수 모두 전달 ➜ 기본값 무시 ('#' 20개 출력)
    mPrintLine 20, '#'

    exit
main ENDP
END main
```

---

# 13. Write a short example that uses the IF, ELSE, and ENDIF directives.

(13. IF, ELSE, ENDIF 지시어를 사용하는 간단한 예제 코드를 작성하세요.)

---

## 💡 답

```assembly
DEBUG = 1       ; 디버그 모드 설정 상수 (1: 활성화, 0: 비활성화)

.code
IF DEBUG EQ 1
    mov eax, 1  ; DEBUG가 1일 때만 어셈블리(컴파일)에 포함됨
ELSE
    mov eax, 0  ; DEBUG가 1이 아닐 때만 어셈블리(컴파일)에 포함됨
ENDIF
```

---

## 📝 상세 풀이

1. **어셈블 시점(Assembly-Time) 조건부 실행**
   - `IF`, `ELSE`, `ENDIF` 지시어는 프로그램 **실행 중(Runtime)** 조건 검사(예: `CMP`, `JE` 등)가 아닌, **어셈블러가 코드를 컴파일하는 시점**에 조건에 부합하는 실행 코드 블록만 기계어로 변환합니다.

2. **조건절 구성**
   - **`IF [상수 조건식]`**: 해당 조건이 참(True)이면 다음 코드 블록을 포함시킵니다.
   - **`ELSE`**: 앞선 `IF` 조건이 거짓(False)일 경우 실행할 대체 코드 블록을 제공합니다.
   - **`ENDIF`**: 조건부 블록의 끝을 어셈블러에 알립니다.

3. **주요 활용 목적**
   - 디버그 모드(Debug)와 릴리즈 모드(Release) 빌드 구별
   - 다양한 운영체제 및 플랫폼 환경에 맞춘 차별화된 코드 빌드

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; 상수의 값을 1 또는 0으로 바꿔가며 테스트할 수 있습니다.
MODE_EXPERT = 0     

.code
main PROC
    IF MODE_EXPERT EQ 1
        mWrite "Expert Mode Enabled."
    ELSE
        mWrite "Standard Mode Enabled."
    ENDIF

    call Crlf
    exit
main ENDP
END main
```

---

# 14. Write a statement using the IF directive that checks the value of the constant macro parameter Z; if Z is less than zero, display a message during assembly indicating that Z is invalid.

(14. IF 지시어를 사용하여 상수 매크로 매개변수 Z의 값을 확인하는 명령문을 작성하세요. Z가 0보다 작으면 어셈블리 과정 중에 Z가 유효하지 않음을 나타내는 메시지를 콘솔에 출력하세요.)

---

## 💡 답

```assembly
IF Z LT 0
    ECHO Error: Z is invalid (Z cannot be less than 0).
ENDIF
```

---

## 📝 상세 풀이

1. **상수 비교 연산자 (`LT`)**
   - 어셈블리 시점 조건문인 `IF` 지시어에서 미만(Less Than, $<$) 관계를 비교하기 위해 **`LT`** 연산자를 사용합니다. (`IF Z LT 0` ➜ $Z < 0$ 인지 검사)

2. **어셈블 시점 콘솔 메시지 출력 (`ECHO`)**
   - 5번 문제에서 살펴본 바와 같이, 프로그램 실행 중(Runtime)이 아닌 **어셈블(컴파일)하는 동안 출력창에 경고/에러 메시지를 뿌려주기 위해 `ECHO` 지시어**를 사용합니다.

3. **매크로 유효성 검사 (Macro Parameter Validation)**
   - 전달받은 매크로 인수가 범위에서 벗어나는 부적절한 값일 때 컴파일 과정에서 개발자에게 즉시 알려 경고를 발생시킬 때 유용하게 활용됩니다.

---

## 💻 매크로 내 전체 코드 적용 예시

```assembly
; 매개변수 Z를 받아 처리하는 예시 매크로
CheckZ MACRO Z
    IF Z LT 0
        ECHO [COMPILE ERROR] Z is invalid: Z value cannot be negative!
    ELSE
        ECHO [COMPILE SUCCESS] Z is valid.
    ENDIF
ENDM

.code
main PROC
    CheckZ -5      ; 빌드 시 에러 메시지 출력됨
    CheckZ 10      ; 빌드 시 성공 메시지 출력됨

    exit
main ENDP
END main
```

---

# 15. Write a short macro that demonstrates the use of the & operator when the macro parameter is embedded in a literal string.

(15. 매크로 매개변수가 문자열 리터럴 내부에 포함되었을 때 & 연산자의 활용을 보여주는 짧은 매크로를 작성하세요.)

---

## 💡 답

```assembly
mShowModuleError MACRO moduleName
    LOCAL msg
    .data
        msg BYTE "Error: Failed to load &moduleName module.", 0
    .code
        mov edx, OFFSET msg
        call WriteString
ENDM
```

---

## 📝 상세 풀이

1. **문자열 리터럴 내 치환 연산자 (`&`)**
   - 어셈블리(MASM) 매크로에서 큰따옴표(`" "`)로 둘러싸인 문자열 리터럴 내부에 매개변수 이름을 써두면 기본적으로 단순 문자열 텍스트 취급을 받습니다.
   - 이때 매개변수 이름 앞에 **`&` 연산자**를 붙여주면(예: `&moduleName`), 어셈블러가 이를 단순 텍스트가 아닌 **실제 전달된 인수(Argument)의 값으로 강제 치환**해 줍니다.

2. **동작 방식예시**
   - 만약 `mShowModuleError Graphics` 형태로 매크로를 호출하면, 문자열 내의 `&moduleName` 위치에 `Graphics`라는 텍스트가 대입되어 **`"Error: Failed to load Graphics module."`** 문자열이 완성됩니다.

---

## 💻 전체 실행 가능 코드 예시 (Irvine32)

```assembly
INCLUDE Irvine32.inc

; & 연산자를 포함하는 매크로 정의
mShowModuleError MACRO moduleName
    LOCAL msg
    .data
        msg BYTE "Error: Failed to load &moduleName module.", 0Dh, 0Ah, 0
    .code
        mov edx, OFFSET msg
        call WriteString
ENDM

.code
main PROC
    ; 매크로 호출 예시 1 ➜ "Error: Failed to load Audio module." 출력
    mShowModuleError Audio

    ; 매크로 호출 예시 2 ➜ "Error: Failed to load Network module." 출력
    mShowModuleError Network

    exit
main ENDP
END main
```

---

# 16. Assume the following mLocate macro definition:

```assembly
mLocate MACRO xval,yval
    IF xval LT 0
        EXITM
    ENDIF
    IF yval LT 0
        EXITM
    ENDIF
    mov bx,0
    mov ah,2
    mov dh,yval
    mov dl,xval
    int 10h
ENDM
```

Show the source code generated by the preprocessor when the macro is expanded by each of the following statements:

```assembly
.data
row BYTE 15
col BYTE 60
.code
mLocate -2,20
mLocate 10,20
mLocate col,row
```

(16. 제공된 mLocate 매크로 정의를 바탕으로, 각 호출문에 의해 전처리기[Preprocessor]가 생성하는 확장 소스 코드를 보여주세요.)

---

## 💡 답

### 1) `mLocate -2, 20` 호출 시 확장 코드
**(코드 생성 없음 / 빈 코드)**
> `-2 < 0` 조건이 참(True)이 되어 `EXITM` 지시어가 실행되므로 매크로 확장이 즉시 종료되고 아무런 코드도 생성되지 않습니다.

---

### 2) `mLocate 10, 20` 호출 시 확장 코드
```assembly
mov bx,0
mov ah,2
mov dh,20
mov dl,10
int 10h
```

---

### 3) `mLocate col, row` 호출 시 확장 코드
```assembly
mov bx,0
mov ah,2
mov dh,row
mov dl,col
int 10h
```

---

## 📝 상세 풀이

1. **`EXITM` (Exit Macro) 지시어의 특징**
   - `mLocate -2, 20` 호출에서는 `xval` 인수로 `-2`가 전달됩니다.
   - `IF -2 LT 0` 조건이 참(True)이 되면서 `EXITM`이 실행되어 어셈블러가 매크로 확장을 즉시 중단합니다. 이에 따라 어셈블리 소스 파일에는 어떠한 명령어도 추가되지 않습니다.

2. **이중 세미콜론(`;;`) 주석 제거 처리**
   - 매크로 내부의 `;;` 주석은 **매크로 전용 주석(Macro-level Comments)**으로, 매크로가 확장(Expand)될 때 최종 생성 코드에 포함되지 않고 완전히 삭제됩니다.

3. **심볼/변수 이름 인수 전달 (`col`, `row`)**
   - `mLocate col, row` 호출 시 `col`과 `row`는 변수 식별자(주소/오프셋)로 취급되어 어셈블 시점 조건문(`IF col LT 0`)에서 거짓(False)으로 평가됩니다.
   - 따라서 조건문을 통과하여 `xval`과 `yval` 자리에 변수 이름인 `col`과 `row`가 그대로 대입된 명령어가 생성됩니다.
