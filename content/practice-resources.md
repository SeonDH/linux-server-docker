# [실습] Docker CPU·메모리 관찰 - 20분

> **실습 환경:** 호스트 Bash. Windows는 WSL Ubuntu, macOS는 터미널에서 실행한다.
> **준비:** Docker Desktop 실행 및 0장 완료.

## Docker는 PC의 CPU와 메모리를 어떻게 쓰나요? {#docker-resources}
**관찰 실습 · 15~20분 · 호스트 Bash.** 컨테이너 안이라면 exit로 나옵니다.

컨테이너는 새 CPU나 메모리를 만드는 것이 아닙니다. PC의 자원을 사용합니다. Docker Desktop에서는 Linux 실행 환경을 거쳐 컨테이너가 동작합니다.

```text
내 PC의 CPU·메모리
       ↓
Docker Desktop의 Linux 환경
       ↓
각 컨테이너의 프로그램
```

### 먼저 구분하기: 한도와 실제 사용량
“책상을 최대 이만큼 쓸 수 있다”는 허가와 “지금 실제로 놓인 자료의 크기”는 다릅니다.

| 설정·수치 | 뜻 |
|---|---|
| --cpus=0.25 | CPU 한 개의 계산 시간 중 약 1/4까지 사용할 수 있는 한도 |
| --memory=128m | 컨테이너 메모리 한도 128 MiB |
| 실제 CPU 사용률 | 지금 얼마나 계산하고 있는지 |
| 실제 메모리 사용량 | 지금 작업이 사용하는 메모리 |

한도를 늘린다고 사용량이 저절로 늘지는 않습니다. 기다리는 sleep은 CPU를 거의 쓰지 않습니다. 기본적으로 별도 제한을 주지 않은 컨테이너는 실행 환경에서 허용되는 자원을 사용할 수 있습니다.

### 같은 작업을 세 화면에서 관찰하기
| 화면 | 확인할 것 | 범위 |
|---|---|---|
| 호스트의 docker stats | 컨테이너별 CPU·메모리 | 이번 실습의 기준 화면 |
| 컨테이너 안의 top | 그 안의 프로그램 | 프로그램별 활동 |
| 작업 관리자·활성 상태 보기 | Docker·Linux VM 관련 프로세스와 PC 전체 | 실행 환경과 다른 작업을 포함 |

Windows에서는 작업 관리자, Mac에서는 활성 상태 보기를 열어 CPU와 메모리 열을 봅니다. Linux VM 관련 프로세스 이름은 OS·Docker 버전에 따라 달라집니다. 컨테이너 이름이 PC의 프로세스 목록에 그대로 나타날 필요는 없습니다.

**세 화면의 숫자는 똑같을 필요가 없습니다.** 집 전체 전기 사용량과 방 하나의 전기 사용량처럼 보는 범위가 다릅니다. CPU의 100%를 세는 기준, 메모리 캐시·VM 자체 사용량과 측정 시점도 달라집니다. Docker stats는 CPU 한 개를 바쁘게 쓰면 대략 100%로 표시할 수 있어 여러 CPU를 쓰면 100%를 넘을 수도 있습니다. PC 전체 CPU 비율과 바로 비교하지 않습니다.

### 1. 따라 하기 · 작은 계산 작업의 CPU 보기
Alpine 이미지로 CPU 한 개의 약 1/4까지 사용하는 짧은 실습 작업을 시작합니다. **300초 뒤 자동 종료**하며 실제 분석 데이터는 쓰지 않습니다.
```bash
docker run -d --name course-cpu-watch \
  --cpus=0.25 --memory=128m \
  alpine:3.21 timeout 300 sh -c 'while :; do :; done'
docker stats course-cpu-watch
```
CPU %와 MEM USAGE / LIMIT를 봅니다. 실습 CPU 사용률은 조건에 따라 약 25% 부근으로 관찰될 수 있으며 정확히 같은 숫자가 보장되지는 않습니다. 메모리는 한도 128 MiB보다 훨씬 적게 사용할 수 있습니다. **Ctrl+C는 stats 관찰만 끝내며 컨테이너를 종료하지 않습니다.**

같은 작업을 호스트의 작업 관리자·활성 상태 보기에서도 봅니다. 전체 PC CPU에서 변화가 작아 보여도 docker stats에서 컨테이너의 활동을 확인할 수 있습니다.

### 2. 바꿔 보기 · CPU 한도만 늘려 보기
300초가 지나기 전에 실행합니다. 이미 종료됐다면 방금 만든 실습 컨테이너를 정리한 뒤 따라 하기부터 다시 시작합니다.
```bash
docker update --cpus=0.5 course-cpu-watch
docker stats course-cpu-watch
```
CPU 한도가 1/4에서 1/2로 커졌습니다. 같은 계산 작업의 CPU 사용률이 높아지는 경향을 관찰합니다. 한도 자체가 사용량을 만드는 것이 아니라, 이 작업이 계속 계산하기 때문에 차이를 볼 수 있습니다. Ctrl+C로 관찰을 마칩니다.

### 3. 컨테이너 안의 top으로도 보기
컨테이너가 아직 실행 중일 때 호스트에서 실행합니다. -it는 대화형 관찰을 위한 옵션입니다.
```bash
docker exec -it course-cpu-watch top
```
q로 top을 나옵니다. Alpine의 top은 0장 Ubuntu에서 본 화면과 다를 수 있습니다. top의 CPU 비율은 표시 방식에 따라 docker stats와 다를 수 있으므로 동일한 숫자를 기대하지 않습니다.

### 4. 정리하기
이 실습에서 만든 컨테이너만 정리합니다. 300초 뒤 이미 종료됐어도 이름이 남아 있을 수 있습니다.
```bash
docker stop course-cpu-watch
docker rm course-cpu-watch
```
이름이 이미 사용 중이라는 오류는 이전 실습 대상인지 docker ps -a로 먼저 확인합니다.

### 메모리 한도와 사용량 비교 · 기다리는 작업 두 개
계산 부하 없이 64 MiB와 128 MiB 한도를 비교합니다.
```bash
docker run -d --name course-mem-small --memory=64m alpine:3.21 sleep 120
docker run -d --name course-mem-large --memory=128m alpine:3.21 sleep 120
docker stats --no-stream course-mem-small course-mem-large
```
LIMIT는 다르지만 두 sleep의 실제 USAGE는 비슷하게 작을 수 있습니다. 메모리 제한을 두 배로 주었다고 두 배를 사용하는 것은 아닙니다. 한 번의 snapshot에서 CPU가 0%처럼 보일 수 있으며 활동의 정확한 비교에는 연속 관찰을 사용합니다.
```bash
docker stop course-mem-small course-mem-large
docker rm course-mem-small course-mem-large
```
위 관찰은 **한도와 사용량 구분**을 배우는 실습입니다. 실제 메모리 요청이 한도를 넘는 상황은 [메모리 부족 실습](practice-memory.html)에서 작은 한도 안에서 별도로 확인합니다.

### 한도를 주었을 때와 주지 않았을 때
책상에서 일하는 사람에게 “이만큼만 사용하세요”라고 정하는 것과, 별도 한도를 정하지 않는 것은 다릅니다. **한도가 없다는 말은 항상 모든 자원을 쓴다는 뜻이 아닙니다.** 실제 사용량은 실행하는 프로그램에 따라 달라집니다.

| 항목 | 한도를 준 경우 | 컨테이너별 한도를 주지 않은 경우 |
|---|---|---|
| CPU | --cpus 값에 맞춰 계산 시간을 제한 | 실행 환경에서 허용되고 프로그램이 요구하는 CPU 시간을 사용 |
| 메모리 | --memory로 지정한 RAM 한도 안에서 사용 | 실행 환경에서 허용되는 메모리를 프로그램이 필요로 하는 만큼 사용 |
| 다른 사용자 영향 | 한도가 영향 완화에 도움을 주지만 합산 사용량도 고려 | 큰 작업이나 여러 작업이 다른 사용자와 자원을 더 많이 경쟁할 수 있음 |

Docker Desktop에서는 Linux VM·WSL 환경과 PC 자체의 한도도 있습니다. 실제 Linux 서버에서는 운영 정책과 상위 자원 제한이 적용될 수 있습니다. 컨테이너별 한도를 생략해도 이 경계가 없어지는 것은 아닙니다.

#### 프로그램에 따라 얼마나 쓸까요?
아래는 **설명용 예상 경향**이며 모든 PC에서 같은 수치를 보장하는 표가 아닙니다.

| 프로그램 | CPU 한도 0.25 | 컨테이너 CPU 한도 없음 |
|---|---|---|
| 기다리는 sleep | 거의 계산하지 않아 사용률이 낮음 | 여전히 낮음 |
| 한 실행 흐름으로 계속 계산 | 충분히 실행하면 약 25% 부근으로 제한될 수 있음 | 가용 자원이 충분하면 CPU 한 개 기준 약 100%에 가까워질 수 있음 |
| 여러 실행 흐름으로 계산 | 총 CPU 시간 한도로 제약 | 프로그램이 병렬로 일하면 여러 CPU를 사용해 docker stats에서 100%를 넘을 수 있음 |

CPU 수와 PC 전체 사용률의 기준은 구분합니다. 제한을 제거했다고 항상 더 빨라지는 것도 아닙니다. 파일 읽기·쓰기나 메모리가 병목일 수 있습니다.

메모리도 마찬가지입니다. 20 MiB가 필요한 작업은 128 MiB 한도에서도, 한도 없이도 비슷한 양을 사용할 수 있습니다. 큰 작업이 RAM 한도를 넘으면 swap 설정에 따라 느려지거나 메모리 부족으로 종료될 수 있습니다. 한도 없이 실행한 큰 작업은 가용 자원을 많이 사용해 다른 작업에 영향을 줄 수 있습니다. 정확한 사용량은 로그와 docker stats로 확인합니다.

#### 작은 비교 실습 · 제한 없는 sleep과 제한한 sleep
**호스트 Bash에서 실행합니다.** 자원을 과도하게 쓰는 분석 대신 작은 대기 작업을 비교합니다. 300초 뒤 각각 끝납니다.
```bash
docker run -d --name course-with-limit \
  --cpus=0.25 --memory=64m alpine:3.21 sleep 120
docker run -d --name course-without-limit alpine:3.21 sleep 120
docker stats --no-stream course-with-limit course-without-limit
```
두 컨테이너의 실제 CPU·메모리 사용은 모두 작을 수 있습니다. 메모리 LIMIT는 제한한 컨테이너가 64 MiB, 제한하지 않은 컨테이너는 엔진이 보는 실행 환경의 메모리 범위로 표시될 수 있습니다. 컨테이너별 설정도 확인합니다.
```bash
docker inspect course-with-limit --format 'NanoCPUs={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}'
docker inspect course-without-limit --format 'NanoCPUs={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}'
```
제한한 경우는 250000000과 67108864, 제한하지 않은 경우는 0과 0이 기대됩니다. **여기서 0은 자원을 못 쓴다는 뜻이 아니라 컨테이너별 해당 한도를 지정하지 않았다는 뜻입니다.**

정리합니다.
```bash
docker stop course-with-limit course-without-limit
docker rm course-with-limit course-without-limit
```
기본 수업에서는 한도 없는 고부하 작업을 실제로 실행하지 않습니다. 계산량 변화는 앞의 제한된 CPU 실습으로 관찰하고, 제한 없는 대기 작업으로 “한도 없음 ≠ 항상 많이 사용”을 확인합니다.

### 고쳐 보기와 설명하기
“--memory=128m을 주었으니 항상 메모리 128 MiB를 쓴다”, “컨테이너 CPU가 50%니까 PC 전체도 50%여야 한다”는 말을 고쳐 보세요.
<details markdown="1"><summary>쉬운 해설</summary>
128 MiB는 한도이고 실제 사용량은 프로그램에 따라 다릅니다. CPU 비율도 컨테이너 화면과 PC 전체 화면의 기준이 달라 같을 필요가 없습니다. 개별 작업은 docker stats, 내부 프로그램은 top, PC 전체 영향은 작업 관리자·활성 상태 보기로 연결해 관찰합니다.
</details>

참고: [Docker 자원 제한](https://docs.docker.com/engine/containers/resource_constraints/), [docker stats](https://docs.docker.com/reference/cli/docker/container/stats/).



[6장으로 돌아가기](06-process.html)
