# 6. 프로세스와 자원 관리

> **실습 환경:** Linux 명령은 컨테이너, 별도 Docker 실습은 호스트
> **준비:** 0장 완료

**학습 목표:** 프로그램 파일과 실행 중인 작업은 다릅니다. 내 작업을 찾아 확인하고 종료합니다.

## 주문서와 진행 중인 작업
셸 스크립트는 할 일을 적은 주문서처럼 생각하세요. 실행 중인 작업이 프로세스입니다. 같은 주문서로 두 번 시작하면 별도 작업 두 개가 생길 수 있습니다.

PID는 프로세스의 번호입니다. 작업을 종료하기 전에 내 작업의 번호와 명령을 확인합니다.

## [실습] 따라 하기 · 기다리는 작업을 찾아 종료하기
**실습 환경: course-linux 컨테이너.** 아래 블록을 같은 터미널에서 순서대로 실행합니다.
```bash
sleep 300 &
lab_pid=$!
echo "$lab_pid"
ps -p "$lab_pid" -o pid,command
kill -TERM "$lab_pid"
```
`sleep 300`은 300초 기다리는 작은 프로그램입니다. `&`는 뒤에서 실행하게 합니다. `$!`는 방금 시작한 백그라운드 작업의 PID입니다. 여기서는 그 번호를 lab_pid에 저장합니다. TERM은 종료 요청입니다.

다시 상태를 확인합니다.
```bash
ps -p "$lab_pid" -o pid,command
```
정상적으로 종료됐으면 해당 작업 행이 없습니다. 다른 사용자 작업을 종료하지 않습니다.

## 실행과 관찰을 구분하기
터미널에서 `top`을 실행하면 작업과 자원 상태를 볼 수 있습니다. q로 관찰 화면을 나옵니다.
```bash
top
```
관찰 화면을 닫는 것과 분석 작업을 종료하는 것은 다른 일입니다. Ctrl+C는 보통 현재 전경 작업을 중단하며, Ctrl+Z는 정지시킬 수 있습니다. 상세한 작업 제어는 [선택 자료](deep-dive.html)에서 다룹니다.

## 공유 서버에서 지킬 세 가지
1. 작은 입력으로 먼저 성공하는지 확인합니다.
2. 관리자에게 할당받은 CPU·메모리 범위에서 실행합니다.
3. 내 작업과 파일만 확인하고 정리합니다.

많은 작업을 한꺼번에 시작하면 다른 사용자도 느려질 수 있습니다. CPU가 많이 보인다고 전부 사용해도 되는 것은 아닙니다. 긴 작업은 기관에서 안내한 실행 방식과 스케줄러를 사용합니다.

## [실습] 반복 연습 · 내 작업 두 개 구분하기
**15~20분 · course-linux의 같은 터미널.**

### 바꿔 보기
기다리는 작업 두 개를 만들어 각 PID를 기록합니다. 아무 입력이 없어도 일정 시간이 지나면 스스로 끝납니다.
```bash
sleep 600 &
first_pid=$!
sleep 600 &
second_pid=$!
echo "first=$first_pid second=$second_pid"
ps -p "$first_pid","$second_pid" -o pid,command
```
첫 번째 작업만 종료하고 두 번째가 남아 있는지 확인하세요.
<details markdown="1"><summary>힌트 보기</summary>
TERM을 보낼 PID를 first_pid로 지정합니다. 다시 ps로 두 번호를 관찰하세요.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
kill -TERM "$first_pid"
ps -p "$first_pid","$second_pid" -o pid,command
```
정상 종료되면 첫 작업은 사라지고 두 번째 sleep이 남습니다. 변화가 바로 보이지 않으면 잠시 뒤 한 번 확인합니다.
</details>

### 고쳐 보기
다음은 셸 자신의 PID를 보고 있습니다. “남은 sleep을 확인했다”는 설명이 맞을까요? **이 번호에 kill을 보내지 않습니다.**
```bash
ps -p "$$" -o pid,command
```
남은 sleep을 보는 명령으로 고치세요.
<details markdown="1"><summary>힌트 보기</summary>
$$는 현재 셸의 PID, second_pid는 앞에서 저장한 두 번째 작업의 PID입니다.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
ps -p "$second_pid" -o pid,command
```
숫자만 보고 종료하지 말고 명령도 확인해야 합니다.
</details>

### 설명하기와 정리
짝에게 “같은 sleep인데 작업은 두 개이고 PID도 다르다”는 것을 설명합니다. 이 실습에서 만든 두 번째 작업을 정리합니다.
```bash
kill -TERM "$second_pid"
```
같은 터미널에서 기록한 PID에만 실행합니다. 시간이 지나 이미 끝났다면 다시 종료할 필요가 없습니다.

## [실습] Docker 자원 사용 비교
CPU·메모리 실험은 다음 실습 페이지에서 진행한다. 현재 실습 환경을 확인한 뒤 필요한 실험을 선택한다.

| 실습 | 관찰할 내용 | 시간 |
|---|---|---|
| [Docker CPU·메모리 관찰](practice-resources.html) | 한도와 사용량, stats·top·PC 화면의 차이 | 20분 |
| [CPU 공유와 자원 제한](practice-cpu-sharing.html) | 내 작업 제한 전후 A·B의 완료 시간 | 20분 |
| [메모리 부족과 오류 확인](practice-memory.html) | 같은 작업의 실패·성공, OOMKilled 확인 | 15분 |

### 자원 관찰 바로가기 {#docker-resources}
[CPU·메모리 관찰 실습으로 이동](practice-resources.html)

### CPU 공유 바로가기 {#cpu-sharing}
[두 작업의 CPU 공유 실습으로 이동](practice-cpu-sharing.html)

### 메모리 부족 바로가기 {#memory-limit-demo}
[메모리 부족 실습으로 이동](practice-memory.html)

## 확인 질문
kill 명령을 쓰기 전에 무엇을 확인할까요?
<details><summary>[답지] 해설 보기</summary>
PID와 명령을 확인해 자신의 실습 작업인지 봅니다. 종료가 필요한지도 판단합니다.
</details>

복습: [기존 프로세스 관리 교재](https://seondh.github.io/bio_linux/day3/chapter12/).

## 이 장의 정리

- PID와 명령을 확인한 뒤 자신의 작업만 정리한다.
- 자원 제한은 영향 완화에 도움이 되며 실제 필요한 자원도 확인한다.
