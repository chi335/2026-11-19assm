# 📘 Chapter 10. Structures and Macros (구조체와 매크로)

어셈블리 언어에서 복합 데이터 타입을 정의하는 **구조체(Structure)** 및 **공용체(Union)**, 그리고 소스 코드를 효율적으로 재사용하고 자동화하기 위한 **매크로(Macro)**, **조건부 어셈블리(Conditional Assembly)**, **반복 블록(Repeat Blocks)** 지시자를 다룹니다.

---

## 📑 목차 (Table of Contents)
- [1. 구조체 및 공용체 (Structures & Unions)](#1-구조체-및-공용체-structures--unions)
  - [1.1 구조체 (Structures)](#11-구조체-structures)
  - [1.2 공용체 (Unions)](#12-공용체-unions)
- [2. 매크로 (Macros)](#2-매크로-macros)
  - [2.1 매크로의 개요 및 정의](#21-매크로의-개요-및-정의)
  - [2.2 주요 매크로 기능](#22-주요-매크로-기능)
- [3. 조건부 어셈블리 지시자 (Conditional-Assembly Directives)](#3-조건부-어셈블리-지시자-conditional-assembly-directives)
- [4. 반복 블록 정의 (Defining Repeat Blocks)](#4-반복-블록-정의-defining-repeat-blocks)
- [5. 요약 및 핵심 정리](#5-요약-및-핵심-정리)

---

## 1. 구조체 및 공용체 (Structures & Unions)

### 1.1 구조체 (Structures)
* **개념**: 서로 연관된 여러 변수(필드)들을 하나의 단위로 묶어 다루는 데이터 템플릿입니다. 각 필드는 서로 다른 데이터 타입을 가질 수 있습니다.
* **정의 방법 (`STRUCT` / `ENDS`)**:
  ```assembly
  Employee STRUCT
      IdNum        BYTE  "000000000"
      LastName     BYTE  30 DUP(0)
      Years        WORD  0
      SalaryHistory DWORD 0,0,0,0
  Employee ENDS
  ```
* **메모리 정렬 (`ALIGN`)**: CPU의 메모리 I/O 성능을 최적화하기 위해 데이터 타입 크기에 맞춰 필드 주소를 정렬합니다. (예: `DWORD`는 4바이트 경계에 정렬)
* **변수 선언 및 접근**:
  * `<>` 또는 `<초기화값>`을 이용해 구조체 변수를 선언합니다.
  * 멤버 연산자 점(`.`)을 사용하여 특정 필드에 접근합니다.
  ```assembly
  .data
  point1 COORD <5, 10>  ; X=5, Y=10으로 초기화

  .code
  mov ax, point1.X
  ```

### 1.2 공용체 (Unions)
* **개념**: 여러 필드가 **동일한 메모리 공간을 공유(Overlap)**하는 데이터 타입입니다.
* **특징**:
  * 모든 변수 필드가 동일한 시작 주소를 가집니다.
  * 구조체와 달리 **단 하나의 초기화값만 허용**됩니다.
  * 동일한 메모리 위치를 바이트(`BYTE`), 워드(`WORD`), 더블워드(`DWORD`) 등 다양한 크기로 해석할 때 유용합니다.

[맨 위로 이동](#-chapter-10-structures-and-macros-구조체와-매크로)

---

## 2. 매크로 (Macros)

### 2.1 매크로의 개요 및 정의
* **개념**: 어셈블리 언어 명령문들의 이름 있는 블록입니다.
* **동작 방식 (Macro Expansion)**: 함수 호출 방식과 달리, 어셈블러 전처리기(preprocessor)가 매크로가 호출된 자리에 **해당 어셈블리 코드를 직접 복사/확장**합니다.
* **정의 구문 (`MACRO` / `ENDM`)**:
  ```assembly
  mWriteln MACRO text
      mWrite text
      call Crlf
  ENDM
  ```

### 2.2 주요 매크로 기능
* **지역 라벨 (`LOCAL`)**: 매크로를 여러 번 호출할 때 발생할 수 있는 라벨 중복 충돌을 방지하기 위해 매크로 내부 라벨을 `LOCAL` 지시자로 선언합니다.
* **중첩 매크로 (Nested Macros)**: 매크로 내부에서 또 다른 매크로를 호출할 수 있습니다.
* **매크로 라이브러리 (`Macros.inc`)**: 자주 쓰이는 I/O 작업을 단순화해주는 사전 정의 매크로 집합입니다.
  * 예: `mWrite` (문자열 출력), `mGotoxy` (커서 위치 이동), `mReadString` (입력 받기) 등.

[맨 위로 이동](#-chapter-10-structures-and-macros-구조체와-매크로)

---

## 3. 조건부 어셈블리 지시자 (Conditional-Assembly Directives)

어셈블 시점의 조건식 평가 결과에 따라 특정 코드 블록을 어셈블리 출력 결과에 **포함시키거나 제외**하는 지시자입니다.

| 지시자 | 설명 |
| :--- | :--- |
| **`IF expression`** | 조건식이 참(non-zero)일 때 코드 어셈블 |
| **`IFB <arg>`** | 인자(argument)가 비어있을(blank) 때 코드 어셈블 |
| **`IFNB <arg>`** | 인자가 비어있지 않을 때 코드 어셈블 |
| **`IFIDN / IFIDNI`** | 두 인자가 동일한지 비교 (대소문자 구별 / 무시) |
| **`IFDIF / IFDIFI`** | 두 인자가 서로 다른지 비교 (대소문자 구별 / 무시) |

* **특수 연산자 (Special Operators)**:
  * `&` (Text Substitution): 매크로 매개변수와 다른 텍스트를 결합할 때 사용.
  * `<>` (Literal Text): 특수문자나 공백이 포함된 텍스트를 하나의 인수로 전달.
  * `!` (Literal Character): 특수문자 자체를 일반 문자로 처리.
  * `%` (Expansion Operator): 상수 표현식을 계산된 텍스트 리터럴로 변환.

[맨 위로 이동](#-chapter-10-structures-and-macros-구조체와-매크로)

---

## 4. 반복 블록 정의 (Defining Repeat Blocks)

어셈블 시점에 코드를 일정한 규칙에 따라 **반복해서 자동 생성**해주는 루핑 지시자들입니다.

1. **`WHILE` 지시자**: 상수 조건식이 참인 동안 코드 블록을 반복 생성 (예: 상수 데이터 테이블 생성).
2. **`REPEAT` 지시자**: 지정한 횟수(Unsigned integer)만큼 코드 블록을 반복 생성.
3. **`FOR` 지시자**: 쉼표(`,`)로 구분된 기호/인자 리스트를 순회하며 반복 실행.
4. **`FORC` 지시자**: 전달된 문자열의 **각 문자(Character)**를 하나씩 순회하며 반복 실행.

[맨 위로 이동](#-chapter-10-structures-and-macros-구조체와-매크로)

---

## 5. 요약 및 핵심 정리

* ⚙️ **구조체 (`STRUCT`)**: 여러 타입을 그룹화한 사용자 정의 데이터 템플릿 (점 연산자로 접근).
* ⚙️ **공용체 (`UNION`)**: 동일한 메모리 영역을 공유하는 필드 모음.
* ⚙️ **매크로 (`MACRO`)**: 전처리 단계에서 코드 블록을 치환/확장하여 생산성을 높임.
* ⚙️ **조건부 어셈블리 (`IF`)**: 빌드 시점에 특정 코드 포함 여부를 결정.
* ⚙️ **반복 블록 (`WHILE`, `REPEAT`, `FOR`, `FORC`)**: 반복되는 코드를 어셈블러가 자동 생성하게 만듦.
