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
