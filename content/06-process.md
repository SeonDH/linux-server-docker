# 6. 프로세스와 자원 관리

> **실습 환경:** Linux 명령은 컨테이너, 별도 Docker 실습은 호스트
> **준비:** 0장 완료

**학습 목표:** 프로그램 파일과 실행 중인 작업을 구분하고, 내 작업의 CPU·메모리 사용량과 한도를 확인합니다. 필요한 작업만 종료합니다.

## 주문서와 진행 중인 작업
셸 스크립트는 할 일을 적은 주문서처럼 생각하세요. 실행 중인 작업이 프로세스입니다. 같은 주문서로 두 번 시작하면 별도 작업 두 개가 생길 수 있습니다.

PID는 프로세스의 번호입니다. 작업을 종료하기 전에 내 작업의 번호와 명령을 확인합니다.

## [실습] 따라 하기 · 기다리는 작업을 찾아 종료하기
**실습 환경: course-linux 컨테이너.** 호스트에 있다면 `docker start -ai course-linux`로 들어옵니다. 아래 블록을 같은 터미널에서 순서대로 실행합니다.
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

## [실습] docker stats로 컨테이너 사용량 보기 {#docker-stats}

**실습 환경: 호스트 Bash의 새 터미널 창.** `course-linux`에 접속한 기존 창은 그대로 두고, 두 번째 창을 엽니다. Windows는 새 WSL Ubuntu 창, macOS는 새 터미널 창에서 Bash를 사용합니다. 기존 창에서 `exit`하면 `course-linux`가 정지하므로 관찰할 때는 접속을 유지합니다.

`top`이 컨테이너 안의 프로그램을 보는 화면이라면, `docker stats`는 Docker에서 **컨테이너별 CPU·메모리 사용량을 보는 화면**입니다.

### 1. 한 번만 확인하기

```bash
docker ps --filter name=course-linux
docker stats --no-stream course-linux
```

`--no-stream`은 현재 값을 한 번 출력하고 끝낸다는 뜻입니다. 컨테이너를 멈추는 옵션은 아닙니다. 먼저 `docker ps`에 실행 중인 대상이 있는지 확인합니다.

다음 숫자는 **읽는 방법을 설명하기 위한 예시**이며 PC의 정답 값이 아닙니다.

```text
NAME           CPU %     MEM USAGE / LIMIT     MEM %
course-linux   0.12%     35MiB / 512MiB         6.84%
```

| 항목 | 쉽게 읽으면 | 예시에서 알 수 있는 것 |
|---|---|---|
| NAME | 관찰하는 작업 공간의 이름 | course-linux |
| CPU % | 지금 얼마나 계산하는지 | 기다리는 상태라면 낮을 수 있음 |
| MEM USAGE / LIMIT | 지금 사용하는 메모리 / 허용 한도 | 사용 약 35MiB, 한도 512MiB |
| MEM % | 표시된 한도 대비 메모리 사용 비율 | 예시는 약 6.84% |
| NET I/O | 네트워크로 주고받은 데이터량 | 현재 전송 속도와 구분 |
| BLOCK I/O | 블록 장치에서 읽고 쓴 데이터량 | 디스크 전체 용량·여유와 구분 |
| PIDS | 컨테이너의 프로세스·스레드 수 | 실제 작업의 흐름이 얼마나 있는지 |

처음에는 **NAME, CPU %, MEM USAGE / LIMIT**만 찾아도 충분합니다. 디스크가 얼마나 남았는지는 `docker stats` 대신 저장할 경로의 `df -h`로 확인합니다.

### 2. 계속 관찰하기

```bash
docker stats course-linux
```

화면이 반복해서 갱신됩니다. **Ctrl+C는 stats 관찰만 끝내며 컨테이너를 종료하지 않습니다.** 한 번의 값보다 작업 중 변화를 봅니다.

대상을 지정하지 않은 `docker stats`는 기본적으로 실행 중인 여러 컨테이너를 보여줍니다. 처음에는 이름을 지정해 내 실습 대상만 확인합니다.

### 3. free -h와 숫자가 다른 이유

0장에서 `course-linux`는 `--memory=512m`으로 만들었습니다. 그런데 컨테이너 안의 `free -h`에는 7.7Gi처럼 더 큰 메모리가 보일 수 있습니다.

- `free -h`: 컨테이너가 보는 Linux 실행 환경의 메모리 상태입니다. 컨테이너별 제한을 그대로 표시하지 않을 수 있습니다.
- `docker stats`: 특정 컨테이너의 사용량과 메모리 한도를 확인합니다.
- 작업 관리자·활성 상태 보기: PC 전체와 Docker 실행 환경의 사용량도 포함합니다.

건물 전체 책상 공간과 내 작업에 허용된 책상 공간이 다른 것처럼 **전체 값과 내 한도를 구분**합니다. `512m`을 지정했다고 항상 512MiB를 사용하거나 미리 전부 차지하는 것은 아닙니다.

`docker stats`의 Linux 메모리 사용량은 일부 캐시를 제외해 표시하므로 다른 화면의 값과 정확히 일치하지 않을 수 있습니다.

### 4. CPU 100%는 PC 전체를 다 쓴다는 뜻인가요?

Linux 컨테이너의 `docker stats`는 CPU 한 개를 바쁘게 쓰면 대략 100%로 표시할 수 있습니다. 여러 CPU를 사용하면 100%를 넘을 수도 있습니다. Windows 작업 관리자의 PC 전체 CPU 비율과 바로 비교하지 않습니다. 한도 설정과 실제 CPU 사용률도 서로 다른 값입니다.

실제 숫자를 바꾸어 관찰하려면 [CPU 한도를 0.25에서 0.5로 바꾸는 실습](practice-resources.html)을 이어서 진행합니다. [CPU 공유 실습](practice-cpu-sharing.html)에서는 내 제한이 다른 작업의 완료 시간에 주는 영향을 확인합니다.

### 5. 값이 이상하면 먼저 확인하기

| 상황 | 먼저 볼 것 |
|---|---|
| 대상이 목록에 없음 | 컨테이너 이름, 실행·정지 상태 |
| CPU가 거의 0% | 기다리는 작업인지, 작업이 이미 끝났는지 |
| 메모리 한도가 예상과 다름 | 컨테이너를 처음 만들 때 지정한 한도 |
| 작업은 실패했는데 사용량은 낮음 | 지금 값 대신 실패 로그·종료 코드·OOMKilled |

정지한 컨테이너의 현재 값으로 실패 직전 사용량을 알 수는 없습니다. [8장 자원 문제 진단](08-troubleshooting.html#resource-trouble)에서 상태와 로그를 함께 확인합니다.

참고: [docker stats 공식 안내](https://docs.docker.com/reference/cli/docker/container/stats/).

## 공유 서버에서 지킬 세 가지
1. 작은 입력으로 먼저 성공하는지 확인합니다.
2. 관리자에게 할당받은 CPU·메모리 범위에서 실행합니다.
3. 내 작업과 파일만 확인하고 정리합니다.

많은 작업을 한꺼번에 시작하면 다른 사용자도 느려질 수 있습니다. CPU가 많이 보인다고 전부 사용해도 되는 것은 아닙니다. 긴 작업은 기관에서 안내한 실행 방식과 스케줄러를 사용합니다.

## [실습] 반복 연습 · 내 작업 두 개 구분하기
**실습 환경: course-linux 컨테이너.** 호스트에서 Docker 관찰을 마쳤다면 `docker start -ai course-linux`로 다시 들어옵니다. 이미 컨테이너 안이라면 그대로 진행합니다.

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
