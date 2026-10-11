# 8. 서버와 Docker 트러블슈팅

> **실습 환경:** Linux 실습은 course-linux 컨테이너, Docker 실습은 호스트 Bash
> **준비:** 0장의 예제 파일과 Docker Desktop

**학습 목표:** 오류 메시지와 상태를 확인하고, 원인에 맞는 한 가지를 고친 뒤 결과를 다시 확인합니다.

## 이 장을 사용하는 방법

짝 활동 없이 혼자 명령을 실행하고 결과를 확인합니다. 각 사례는 **증상 확인 → 확인 명령 → 원인 이해 → 수정 → 재실행** 순서입니다. 먼저 오류를 직접 보고, 확인 명령을 실행한 뒤 접힌 해결 방법을 펼치세요.

오류 메시지의 문장은 버전에 따라 조금 다를 수 있습니다. `No such file`, `Permission denied`, `not running`처럼 핵심 단어를 찾습니다. 명령 하나가 실패해도 다음 확인 단계로 진행합니다. 이 장 전체를 `set -e`가 켜진 스크립트로 한 번에 실행하지 않습니다.

| 찾아볼 상황 | 이동 |
|---|---|
| 파일·경로·실행 권한·PATH·빈 결과·파이프 | [Linux 오류 실습](#linux-trouble) |
| Docker 연결·이름·파일 연결·정지 상태·실패 로그 | [Docker 오류 실습](#docker-trouble) |
| 메모리 숫자·OOM·느린 작업·저장공간 부족 | [자원·서버 사례](#resource-trouble) |
| 여러 오류가 섞인 명령 고치기 | [종합 실습](#repair-mission) |

## 실습 전 준비와 실행 위치

Linux 실습은 **course-linux 안**에서 합니다. 호스트에서 아래 명령으로 들어갑니다. 이미 들어와 있다면 실행할 필요가 없습니다.

```bash
docker start -ai course-linux
```

**컨테이너 안**에서 아래 준비 명령을 실행합니다. 이 장에서 만드는 작은 파일은 `scratch/trouble-8` 안에 보관합니다. 반복 실습은 같은 이름의 실습 파일을 덮어쓸 수 있습니다.

```bash
cd "$HOME/linux-server-lab"
mkdir -p scratch/trouble-8 output logs
cat input/samples.tsv
```

헤더를 포함해 4줄이 보이면 준비됐습니다. 파일이 없다면 0장의 예제 데이터 만들기를 먼저 완료하세요. 오류를 재현하려고 실제 분석 파일의 이름이나 권한을 변경하지 않습니다.

Docker 실습으로 이동할 때는 `exit`로 호스트에 나옵니다. Windows는 WSL Ubuntu의 Bash, macOS는 터미널의 Bash를 사용합니다.

## [실습] Linux 파일·명령 오류 {#linux-trouble}

### A. 파일 이름을 한 글자 잘못 입력했어요

**실행 위치: course-linux 안.**

```bash
cd "$HOME/linux-server-lab"
cat input/sample.tsv
```

**예상 증상:** `No such file or directory`. 실제 예제는 `samples.tsv`인데 `sample.tsv`라고 입력했습니다.

**먼저 확인:** 오류 메시지에 적힌 파일 이름과 실제 목록을 비교합니다.

```bash
pwd
ls input
```

<details markdown="1"><summary>[해결] 실제 이름으로 다시 실행</summary>

```bash
cat input/samples.tsv
```

**해결 확인:** 예제 4줄이 보입니다. 파일이 없다는 오류가 나오면 프로그램 재설치보다 이름·현재 위치를 먼저 확인합니다.

</details>

### B. 파일은 있는데 다른 폴더에서는 못 찾아요

**실행 위치: course-linux 안.**

```bash
cd "$HOME/linux-server-lab/output"
cat input/samples.tsv
pwd
ls ..
```

**예상 증상:** 파일 없음. 현재 위치가 `output`이므로 `input/samples.tsv`는 `output/input/samples.tsv`를 뜻합니다.

<details markdown="1"><summary>[해결] 현재 위치에 맞는 경로 사용</summary>

```bash
cat ../input/samples.tsv
cd "$HOME/linux-server-lab"
cat input/samples.tsv
```

**해결 확인:** 두 명령 모두 같은 4줄을 보여줍니다. `..`는 한 단계 위 폴더입니다. 같은 글자의 상대 경로라도 현재 위치에 따라 다른 파일을 가리킵니다.

</details>

### C. 폴더 이름에 공백이 있으면 파일을 못 찾아요

**실행 위치: course-linux 안.**

```bash
cd "$HOME/linux-server-lab"
mkdir -p "scratch/trouble-8/space demo"
printf 'hello\n' > "scratch/trouble-8/space demo/note.txt"
cat scratch/trouble-8/space demo/note.txt
```

**예상 증상:** 두 경로에 대한 파일 없음 오류. 셸이 공백을 기준으로 경로를 둘로 나누어 읽었습니다.

<details markdown="1"><summary>[해결] 따옴표로 한 경로임을 표시</summary>

```bash
cat "scratch/trouble-8/space demo/note.txt"
```

**해결 확인:** `hello`. 파일 이름을 바꾸기 전에 공백과 따옴표를 확인합니다. `$HOME`, `$PWD`가 들어간 경로도 큰따옴표로 감싸는 습관을 들입니다.

</details>

### D. 스크립트 파일은 있는데 실행 권한이 없어요

**실행 위치: course-linux 안.** 이 사례는 3장의 파일이 없어도 진행할 수 있습니다.

```bash
cd "$HOME/linux-server-lab"
printf '#!/bin/sh\necho hello\n' > scratch/trouble-8/hello.sh
chmod u-x scratch/trouble-8/hello.sh
./scratch/trouble-8/hello.sh
ls -l scratch/trouble-8/hello.sh
```

**예상 증상:** `Permission denied`. 앞부분의 권한 표시에서 소유자의 `x`가 없는지 확인합니다. 이 실습은 root 컨테이너에서도 실행 권한 오류를 관찰합니다. 일반 사용자의 읽기·쓰기 권한 오류는 상황이 다를 수 있습니다.

<details markdown="1"><summary>[해결] 자신의 파일에 실행 권한 추가</summary>

```bash
chmod u+x scratch/trouble-8/hello.sh
./scratch/trouble-8/hello.sh
```

**해결 확인:** `hello`. `chmod 777`로 모든 사람에게 모든 권한을 주지 않습니다. 실제 공유 서버에서는 파일 소유자와 필요한 권한도 확인합니다.

</details>

### E. 실행 권한을 줬는데 command not found가 나와요

**실행 위치: course-linux 안.** D를 완료한 뒤 진행합니다.

```bash
cd "$HOME/linux-server-lab/scratch/trouble-8"
hello.sh
pwd
ls -l hello.sh
printf '%s\n' "$PATH"
```

**예상 증상:** `command not found`. 셸은 명령 이름을 `PATH`에 있는 폴더에서 찾습니다. 현재 폴더가 자동으로 검색 대상에 포함되는 것은 아닙니다.

<details markdown="1"><summary>[해결] 실행할 파일의 경로 표시</summary>

```bash
./hello.sh
cd "$HOME/linux-server-lab"
```

**해결 확인:** `hello`. `./`는 현재 폴더를 뜻합니다. 개인 파일을 실행하려고 공용 서버의 PATH 설정을 무작정 바꾸지 않습니다.

</details>

### F. 결과 파일이 생겼는데 내용이 비어 있어요

**실행 위치: course-linux 안.**

```bash
cd "$HOME/linux-server-lab"
cat input/missing.tsv > output/trouble-8-result.txt 2> logs/trouble-8-error.log
echo "$?"
wc -c output/trouble-8-result.txt
cat logs/trouble-8-error.log
```

**예상 증상:** 종료 상태가 0이 아니고, 결과는 0바이트이며, 로그에는 파일 없음 오류가 있습니다. 셸이 출력 파일을 먼저 만들 수 있으므로 파일 생성만으로 성공을 판단하지 않습니다.

<details markdown="1"><summary>[해결] 입력 경로 수정 후 내용까지 확인</summary>

```bash
cat input/samples.tsv > output/trouble-8-result.txt 2> logs/trouble-8-error.log
echo "$?"
wc -l output/trouble-8-result.txt
cat output/trouble-8-result.txt
cat logs/trouble-8-error.log
```

**해결 확인:** 종료 상태 0, 결과 4줄, 오류 로그는 비어 있습니다. `$?`는 바로 앞 명령의 상태이므로 확인하려는 명령 직후에 읽습니다.

</details>

### G. 파이프 결과가 0이면 정상적으로 분석된 걸까요?

**실행 위치: course-linux 안의 Bash.** 비교를 위해 이 셸에서 먼저 기본 동작을 설정합니다.

```bash
cd "$HOME/linux-server-lab"
set +o pipefail
cat input/missing.tsv 2> logs/trouble-8-pipe.log | wc -l
echo "$?"
cat logs/trouble-8-pipe.log
```

**예상 증상:** 줄 수는 0이고 종료 상태도 0일 수 있지만, 로그에는 입력 오류가 있습니다. 마지막 `wc`는 입력을 받지 못해도 0줄을 세고 정상 종료할 수 있습니다.

<details markdown="1"><summary>[해결] 실패 확인 방법과 실제 입력을 함께 수정</summary>

```bash
set -o pipefail
cat input/missing.tsv 2> logs/trouble-8-pipe.log | wc -l
echo "$?"
cat input/samples.tsv 2> logs/trouble-8-pipe.log | wc -l
echo "$?"
set +o pipefail
```

**해결 확인:** 없는 파일에서는 종료 상태가 0이 아니고, 실제 파일에서는 4줄과 종료 상태 0입니다. 마지막 명령은 이 비교에서 바꾼 설정을 되돌립니다. 업무 스크립트는 오류 처리 목적에 맞게 `pipefail`을 사용합니다.

</details>

### H. 출력 폴더가 없어서 저장이 안 돼요

**실행 위치: course-linux 안.** `not-created-8`이라는 폴더가 아직 없다면 진행합니다. 이미 있다면 다른 새 폴더 이름을 사용하세요.

```bash
cd "$HOME/linux-server-lab"
cat input/samples.tsv > scratch/trouble-8/not-created-8/result.txt
ls -ld scratch/trouble-8/not-created-8
```

**예상 증상:** 출력 경로에 대한 파일 없음 오류. 입력은 정상이어도 출력의 부모 폴더가 없으면 파일을 만들 수 없습니다.

<details markdown="1"><summary>[해결] 출력 폴더를 먼저 준비</summary>

```bash
mkdir -p scratch/trouble-8/not-created-8
cat input/samples.tsv > scratch/trouble-8/not-created-8/result.txt
wc -l scratch/trouble-8/not-created-8/result.txt
```

**해결 확인:** 4줄. 오류 메시지의 대상이 입력인지 출력인지 구분합니다.

</details>

## [실습] Docker에서 자주 만나는 오류 {#docker-trouble}

**실행 위치: 호스트 Bash.** 컨테이너 안이라면 `exit`로 나옵니다. 각 사례는 약 5~10분이며 필요한 것부터 진행할 수 있습니다.

```bash
cd "$HOME/linux-server-lab"
mkdir -p output logs scratch/trouble-8
ls input/samples.tsv
docker version
```

이 장의 `course-…-demo` 컨테이너는 직접 만든 실습 대상만 정리합니다. 다른 사용자의 컨테이너나 `course-linux`를 삭제하지 않습니다.

### 1. 컨테이너 안에서 docker 명령을 찾지 못해요

**증상:** `docker: command not found`. 0장의 Ubuntu 컨테이너에는 Docker CLI를 설치하지 않았습니다.

**확인:** 현재 프롬프트와 실행 위치를 확인합니다. 컨테이너 안이라면 `exit` 후 호스트에서 실행합니다.

```bash
docker version
```

**해결 확인:** Client와 Server 정보가 모두 나옵니다. 현재 실습에서는 Docker를 조작하는 명령은 호스트, Linux 명령은 `course-linux` 안에서 실행합니다.

### 2. Docker 명령은 있는데 엔진 연결이 실패해요

**증상:** `Cannot connect to the Docker daemon` 또는 Server 정보 확인 실패. 오류를 만들려고 앱을 일부러 종료할 필요는 없습니다.

```bash
docker version
docker context ls
```

**확인:** Client만 정상인지, Docker Desktop이 실행 중인지, 별표가 붙은 현재 context가 의도한 연결인지 봅니다.

**대응:** Docker Desktop 엔진이 시작될 때까지 기다린 뒤 다시 확인합니다. 실제 서버에서는 관리자에게 안내받은 엔진·접속 환경을 확인합니다. 다른 context로 무작정 바꾸거나 Docker를 다시 설치하기 전에 연결 상태부터 확인합니다.

### 3. 같은 컨테이너 이름이 이미 사용 중이에요

```bash
docker run --name course-name-demo alpine:3.21 echo hello
docker run --name course-name-demo alpine:3.21 echo again
```

**예상 증상:** 첫 실행은 `hello` 뒤 종료하고, 두 번째는 이름 충돌로 실패합니다. 정지한 컨테이너도 이름을 가지고 있습니다.

```bash
docker ps -a --filter name=course-name-demo
docker logs course-name-demo
```

<details markdown="1"><summary>[해결] 기존 실습 대상 확인 후 정리</summary>

```bash
docker rm course-name-demo
```

**해결 확인:** 이름 충돌의 원인이었던 실습 컨테이너가 목록에서 사라집니다. `course-linux`를 다시 사용하려는 상황이라면 삭제 대신 `docker start -ai course-linux`로 들어갑니다.

</details>

### 4. PC에 있는 입력 파일이 컨테이너에서는 안 보여요

```bash
cd "$HOME/linux-server-lab"
ls input/samples.tsv
docker run --rm alpine:3.21 cat /input/samples.tsv
```

**예상 증상:** 호스트의 파일은 있지만 컨테이너에서는 파일 없음. 호스트 폴더는 자동으로 연결되지 않습니다.

<details markdown="1"><summary>[해결] 입력 폴더 연결</summary>

```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 cat /input/samples.tsv
```

**해결 확인:** 예제 4줄. `src`는 호스트 경로, `dst`는 컨테이너 경로입니다.

</details>

### 5. bind source path does not exist가 나와요

```bash
cd "$HOME/linux-server-lab"
docker run --rm \
  --mount "type=bind,src=$PWD/inputs,dst=/input,readonly" \
  alpine:3.21 ls /input
ls -ld input inputs
```

**예상 증상:** `inputs` 폴더가 없다면 연결 단계에서 실패합니다. 실제 준비한 이름은 `input`입니다. `--mount`는 기본적으로 존재하지 않는 연결 원본을 자동 생성하지 않습니다.

<details markdown="1"><summary>[해결] 연결 원본의 이름 수정</summary>

```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 ls /input
```

**해결 확인:** `samples.tsv`. 실제 입력 경로를 틀렸는데 빈 폴더를 새로 만들면 파일을 못 찾는 다른 오류로 이어질 수 있습니다. 먼저 원본이 있는 위치를 확인합니다.

</details>

### 6. 연결한 입력 폴더에 쓰기가 안 돼요

```bash
cd "$HOME/linux-server-lab"
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 sh -c 'echo test > /input/new.txt'
```

**예상 증상:** `Read-only file system`. `readonly`로 원본 입력을 보호한 결과입니다. `chmod`로 읽기 전용 연결을 쓰기 가능하게 바꿀 수는 없습니다.

<details markdown="1"><summary>[해결] 결과를 쓰기 가능한 출력 연결에 저장</summary>

```bash
mkdir -p output
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output,dst=/output" \
  alpine:3.21 sh -c 'wc -l /input/samples.tsv > /output/trouble-8-count.txt'
cat output/trouble-8-count.txt
```

**해결 확인:** 4줄이라는 결과가 PC 출력 폴더에 남습니다. 입력의 보호 설정은 유지합니다.

</details>

### 7. 결과를 만들었는데 PC에서는 찾을 수 없어요

```bash
cd "$HOME/linux-server-lab"
mkdir -p output
docker run --name course-result-demo alpine:3.21 \
  sh -c 'mkdir -p /output; echo inside > /output/result.txt'
```

**증상:** 작업은 성공했지만 PC 출력 폴더에는 결과가 없습니다. 이 명령의 `/output`은 컨테이너 내부이고 호스트에 연결하지 않았습니다.

```bash
docker inspect course-result-demo --format '{{json .Mounts}}'
```

이 사례는 연결이 없어 `[]`가 기대됩니다.

<details markdown="1"><summary>[해결] 삭제 전 결과 회수</summary>

```bash
docker cp course-result-demo:/output/result.txt output/trouble-8-recovered.txt
cat output/trouble-8-recovered.txt
docker rm course-result-demo
```

**해결 확인:** `inside`. 같은 회수 파일이 있으면 덮어쓸 수 있습니다. 다음 실행부터는 7장처럼 출력을 미리 연결합니다. `--rm`으로 이미 삭제된 컨테이너에서 결과를 회수할 수는 없습니다.

</details>

### 8. 컨테이너가 실행하자마자 끝났어요

```bash
docker run --name course-exit-demo alpine:3.21 echo done
docker inspect course-exit-demo --format 'status={{.State.Status}} exit={{.State.ExitCode}}'
docker logs course-exit-demo
docker rm course-exit-demo
```

**관찰:** `exited`, 종료 코드 0, 로그 `done`. 할 일을 마치고 정상 종료했습니다. 컨테이너가 종료됐다는 사실만으로 실패라고 판단하지 않습니다.

### 9. 정지한 컨테이너에 docker exec로 들어갈 수 없어요

`docker exec`는 **현재 실행 중인 컨테이너에서 추가 명령을 실행**합니다. 다음 짧은 대기 작업이 끝난 뒤 비교합니다.

```bash
docker run -d --name course-state-demo alpine:3.21 sleep 3
docker wait course-state-demo
docker exec course-state-demo echo hello
docker ps -a --filter name=course-state-demo
```

**예상 증상:** `not running`. `docker wait`는 정지가 될 때까지 기다렸다가 종료 코드를 보여줍니다.

<details markdown="1"><summary>[해결] 상태 확인 후 다시 시작</summary>

```bash
docker start course-state-demo
docker wait course-state-demo
docker rm course-state-demo
```

같은 `sleep 3` 작업이 다시 실행되고 종료 코드 0이 기대됩니다. 실습 Ubuntu 환경을 다시 여는 명령은 `docker start -ai course-linux`입니다. 시작 명령, 실행 중 추가 명령, 정지 상태를 구분합니다.

</details>

### 10. Mac에 있는 프로그램이 컨테이너에는 없어요

```bash
docker run --rm alpine:3.21 bash -c 'echo hello'
```

**예상 증상:** `bash` 실행 파일을 찾지 못합니다. 기본 Alpine 이미지에는 `sh`가 있지만 Bash는 기본 설치되어 있지 않습니다. Mac에 설치한 프로그램이 이미지에 자동으로 들어가지는 않습니다.

<details markdown="1"><summary>[해결] 이미지에 있는 셸로 작은 명령 실행</summary>

```bash
docker run --rm alpine:3.21 sh -c 'echo hello'
```

**해결 확인:** `hello`. 이 작은 명령은 `sh`로도 실행할 수 있습니다. 실제 분석 스크립트가 Bash나 특정 Python 라이브러리를 요구한다면 그 도구를 포함한 이미지를 선택하거나 이미지 준비 방법을 확인합니다. 셸 이름만 바꾸면 모든 스크립트가 호환되는 것은 아닙니다.

</details>

### 11. 컨테이너가 실패했는데 화면에는 이유가 없어요

```bash
docker run -d --name course-error-demo alpine:3.21 \
  sh -c 'cat /missing.tsv'
docker wait course-error-demo
docker inspect course-error-demo --format 'exit={{.State.ExitCode}}'
docker logs course-error-demo
```

**관찰:** `-d`는 백그라운드 실행이라 처음에는 컨테이너 ID만 보입니다. 종료 코드는 0이 아니고 로그에는 파일 없음 오류가 있습니다.

<details markdown="1"><summary>[해결] 실패 원인 확인 후 올바른 입력으로 재실행</summary>

```bash
cd "$HOME/linux-server-lab"
docker rm course-error-demo
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 cat /input/samples.tsv
```

**해결 확인:** 4줄. 종료 상태와 로그를 함께 확인한 뒤 원인인 입력 경로를 고칩니다. 실패한 컨테이너를 이유 확인 없이 반복 실행하지 않습니다.

</details>

## 자원·서버 문제를 구분하는 연습 {#resource-trouble}

이 절은 상태 관찰과 가상 사례입니다. PC 메모리나 실제 디스크를 고갈시키지 않습니다.

### 1. free에는 7.7Gi인데 내 메모리 한도는 512MiB래요

**컨테이너 안**에서 확인합니다.

```bash
free -h
```

**호스트 Bash의 다른 창**에서 확인합니다.

```bash
docker stats --no-stream course-linux
docker inspect course-linux --format 'memory={{.HostConfig.Memory}}'
```

**원인:** `free`는 컨테이너가 보는 Linux 실행 환경의 메모리를 표시할 수 있어 컨테이너별 한도와 다릅니다. 0장처럼 만들었다면 `docker stats`의 LIMIT은 512MiB, 설정값은 536870912바이트가 기대됩니다. `free`의 전체 값은 PC마다 다릅니다.

**대응:** 프로그램이 사용할 수 있는 컨테이너 한도는 `stats`와 실행 설정으로 확인합니다. 7.7Gi가 보인다고 분석에 그만큼 요청하지 않습니다. [자원 관찰 실습](practice-resources.html)에서 화면별 차이를 비교합니다.

### 2. Killed나 종료 코드 137이 나오면 무조건 메모리 부족인가요?

**확인할 증거:** 종료 코드, OOMKilled, 오류 로그, 지정한 메모리 한도입니다. 137은 강제 종료 신호와 관련되지만 이것만으로 메모리 부족을 확정하지 않습니다.

**호스트 Bash에서 실제 남아 있는 실패 컨테이너를 조사하는 형식**입니다. `대상컨테이너`는 설명용 자리이므로 그대로 실행하지 말고 실제 이름으로 바꾸세요.

```text
docker inspect 대상컨테이너 --format 'exit={{.State.ExitCode}} oom={{.State.OOMKilled}}'
docker logs 대상컨테이너
docker stats --no-stream 대상컨테이너
```

정지한 컨테이너의 `stats`만으로 실패 직전 메모리 사용량을 알 수는 없습니다. `--rm`으로 이미 삭제됐다면 해당 컨테이너를 조사할 수도 없습니다. 중요한 작업은 실행 설정과 로그를 별도로 남깁니다.

**실제로 비교하려면:** [메모리 부족 실습](practice-memory.html)의 작은 64MiB 작업을 32MiB와 128MiB 한도에서 실행합니다. 전체 PC 메모리를 고갈시키지 않고 실패·성공을 비교합니다.

**대응:** 필요한 메모리와 할당 범위를 확인합니다. 작은 입력, 분할 처리, 동시 실행 수 조절을 고려하고 임의로 서버 전체 메모리를 요청하지 않습니다.

### 3. 느린 작업은 CPU를 늘리면 해결되나요?

**호스트 Bash**에서 이번 실습 컨테이너를 관찰합니다.

```bash
docker stats --no-stream course-linux
docker top course-linux
```

`docker top`은 실행 중인 컨테이너에서만 사용할 수 있습니다. 현재 내 작업이 실행 중인지 먼저 확인합니다. 별도 작업의 로그와 자원은 그 컨테이너 이름으로 확인합니다.

| 관찰 | 생각할 원인 | 다음 확인 |
|---|---|---|
| CPU가 한도 부근에서 계속 바쁨 | 계산량 또는 CPU 시간 제한 | 도구 스레드 설정·할당된 CPU |
| CPU가 낮고 로그도 변하지 않음 | 대기·입력 문제 등 여러 가능성 | 프로세스 상태·원문 로그·입력 경로 |
| 메모리 사용이 한도에 가까움 | 자료량 또는 여러 작업의 합 | 입력 크기·동시 실행 수·메모리 한도 |
| 파일 읽기·쓰기가 오래 걸림 | 큰 파일·저장장치·공유 I/O 경쟁 | 입출력 경로·작은 입력에서 재현 |

한 번의 숫자로 원인을 확정하지 않습니다. 멈춘 것처럼 보인다는 이유만으로 다른 사람의 작업을 종료하거나 내 작업에 CPU를 전부 할당하지 않습니다. [CPU 공유 실습](practice-cpu-sharing.html)에서 제한과 완료 시간의 관계를 관찰합니다.

### 4. /data는 넉넉한데 No space left on device가 나와요

다음은 **가상 서버 사례**입니다. 출력값을 만들기 위해 실제 디스크를 채우지 않습니다.

| 공간 | 상태 |
|---|---|
| 루트 파일시스템 `/` | 99% 사용 |
| 별도 대용량 저장공간 `/data` | 20% 사용 |
| 분석 입력 | `/data/user/input`에 있음 |
| 임시 파일·Docker 데이터·로그 | 루트 쪽에 쌓일 수 있음 |

**실제 Linux 서버에서 확인할 명령의 예시**입니다. `/data`나 아래 작업 폴더가 없는 개인 실습 PC에서는 그대로 실행하지 않습니다.

```text
df -h / /data
df -h 실제출력폴더
du -sh 자신의작업폴더
docker system df
```

**원인 후보:** 입력만 큰 스토리지에 두고 결과·임시 파일·이미지·로그는 루트 쪽을 사용했을 수 있습니다. Docker 데이터의 위치는 엔진 설정에 따라 달라집니다. PC 폴더를 연결했다고 이미지 저장 위치까지 옮겨지는 것은 아닙니다.

**대응:** 오류가 가리키는 저장 위치, 내가 만든 파일의 용도, 보존할 결과를 먼저 확인합니다. 서버의 Docker 저장 위치나 로그 정책 변경은 관리자와 협의합니다. 다른 사용자와 공용 이미지를 포함하는 전체 정리 명령을 무작정 실행하지 않습니다.

**직접 관찰하려면:** [작은 공간과 큰 공간의 실패·성공 비교](practice-storage-paths.html)에서 같은 크기의 파일을 두 경로에 씁니다. 실제 NAS 대신 크기가 제한된 임시 공간으로 저장 위치의 차이를 재현합니다.

**공간이 남아 있는데 계속 실패하면:** 파일 개수 한도인 inode, 사용자 quota, 읽기 전용 연결 여부도 확인합니다. 상세 진단은 [저장공간 추가 자료](deep-dive.html)에서 읽습니다.

## [실습] 혼자 해결하는 종합 미션 {#repair-mission}

답지를 먼저 펼치지 않고 **실패 확인, 원인 찾기, 한 가지 수정, 결과 확인**을 직접 진행합니다. 짝에게 설명하는 단계는 없습니다.

### 미션 1. 이름·출력 폴더·결과 확인

**실행 위치: course-linux 안.** 처음 진행할 때 아래 출력 폴더가 없다면 두 가지 문제가 섞여 있습니다. 반복 시에는 새로운 출력 폴더 이름을 사용하세요.

```bash
cd "$HOME/linux-server-lab"
cat input/sample.tsv > scratch/trouble-8/mission-new/result.txt
```

**완료 기준:** 출력 폴더에 예제 4줄을 저장하고 직접 확인합니다. 오류 메시지가 출력 경로를 먼저 가리킬 수 있습니다. 하나를 고친 뒤 다시 실행해 남은 오류를 확인하세요.

<details markdown="1"><summary>[답지] 출력 폴더와 입력 이름 수정</summary>

```bash
mkdir -p scratch/trouble-8/mission-new
cat input/samples.tsv > scratch/trouble-8/mission-new/result.txt
wc -l scratch/trouble-8/mission-new/result.txt
cat scratch/trouble-8/mission-new/result.txt
```

</details>

### 미션 2. 연결한 주소와 명령의 주소가 달라요

**실행 위치: 호스트 Bash.** `course-linux` 안이라면 `exit`로 나옵니다.

```bash
cd "$HOME/linux-server-lab"
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/data,readonly" \
  alpine:3.21 cat /input/samples.tsv
```

**완료 기준:** 컨테이너에서 예제 4줄을 출력합니다. PC의 원본 파일은 변경하지 않습니다.

<details markdown="1"><summary>[답지] 연결된 컨테이너 경로로 수정</summary>

```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/data,readonly" \
  alpine:3.21 cat /data/samples.tsv
```

`dst=/data`에 연결했으므로 명령도 `/data/samples.tsv`를 읽습니다. `dst`를 `/input`으로 바꾸어 명령에 맞춰도 해결할 수 있습니다.

</details>

### 미션 3. 결과는 성공했는데 지정한 폴더에 없어요

**실행 위치: 호스트 Bash.** 다음 명령이 실제로 어디에 결과를 남기는지 확인한 뒤 수정합니다.

```bash
cd "$HOME/linux-server-lab"
mkdir -p output scratch/trouble-8/result-box
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/scratch/trouble-8/result-box,dst=/output" \
  alpine:3.21 sh -c 'wc -l /input/samples.tsv > /output/mission-count.txt'
```

**완료 기준:** 기존 결과의 실제 위치를 찾고, 연결 원본을 고쳐 `output/mission-count.txt`에 다시 저장합니다. 컨테이너의 출력 주소는 `/output`으로 유지합니다.

<details markdown="1"><summary>[답지] 호스트 출력 연결을 수정</summary>

```bash
cat scratch/trouble-8/result-box/mission-count.txt
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output,dst=/output" \
  alpine:3.21 sh -c 'wc -l /input/samples.tsv > /output/mission-count.txt'
cat output/mission-count.txt
```

**해결 확인:** 두 위치에서 각각 4줄이라는 결과를 확인합니다. `src`는 PC의 주소, `dst`는 컨테이너 안의 주소입니다.

</details>

## 해결 기록과 도움 요청

혼자 해결한 사례 하나를 아래 형식으로 기록합니다. 설명을 발표할 필요는 없습니다. 해결되지 않았을 때 같은 기록을 관리자에게 전달하면 재현에 도움이 됩니다.

```text
실행한 곳: 호스트 / 컨테이너
현재 경로:
실행한 명령:
원문 오류:
확인한 상태·로그:
바꾼 한 가지:
재실행 결과:
남은 문제:
```

## 이 장의 정리

- 파일 오류는 이름·현재 경로·입출력 경로부터 확인합니다.
- 컨테이너는 실행 상태, 연결한 폴더, 로그와 종료 코드를 함께 확인합니다.
- 화면의 전체 자원과 내 작업에 허용된 한도를 구분합니다.
- 한 가지씩 수정하고 출력 내용까지 확인합니다.

참고: [Docker 파일 연결](https://docs.docker.com/engine/storage/bind-mounts/), [docker exec](https://docs.docker.com/reference/cli/docker/container/exec/), [Docker 자원 제한](https://docs.docker.com/engine/containers/resource_constraints/).
