# 8. 서버와 Docker 트러블슈팅

> **실습 환경:** 각 실습의 컨테이너·호스트 표시 확인
> **준비:** 0~7장 대표 실습

**학습 목표:** 오류를 한 번에 해결하려고 하지 않고 증거를 하나씩 확인합니다.

## 먼저 네 가지 질문
1. 나는 어디에서 실행했나요? 호스트인가요, 컨테이너인가요?
2. 현재 위치와 파일 이름이 맞나요?
3. 오류 메시지는 뭐라고 하나요?
4. 수정한 뒤 다시 실행하면 결과가 맞나요?

## [실습] A · 파일을 못 찾겠어요
**실습 환경: course-linux 컨테이너.**
```bash
cd "$HOME/linux-server-lab"
cat input/sample.tsv
ls input
```
실제 파일 이름을 찾아 첫 명령을 고치세요.
<details><summary>[답지] 해설 보기</summary>
이름은 samples.tsv입니다. cat input/samples.tsv로 다시 실행합니다. 오류를 보고 먼저 이름과 경로를 확인합니다.
</details>

## [실습] B · 파일은 있는데 실행이 안 돼요
3장의 hello.sh를 만들었다면 실행합니다.
```bash
chmod u-x scratch/hello.sh
./scratch/hello.sh
ls -l scratch/hello.sh
```
필요한 실행 권한을 다시 주고 hello가 나오는지 확인하세요.
<details><summary>[답지] 해설 보기</summary>
chmod u+x scratch/hello.sh 후 ./scratch/hello.sh를 실행합니다.
</details>

## [실습] C · 결과가 비었어요
```bash
cat input/missing.tsv > output/check.txt 2> logs/check.log
cat logs/check.log
```
원인을 읽고 실제 파일 경로로 명령을 고치세요. 수정 후 결과 내용을 확인합니다.

## 서버 문제는 어떤 정보로 도움을 요청할까요?
| 증상 | 먼저 확인할 것 |
|---|---|
| 파일이 없음 | 현재 위치·파일명·연결한 경로 |
| Permission denied | 사용자·대상 권한 |
| 공간 부족 | 저장하는 경로의 df -h |
| 작업이 오래 걸림 | 내 작업 상태·로그·자원 |
| Docker 연결 실패 | Docker Desktop 엔진 실행 여부 |

Killed나 종료 137만으로 메모리 부족이라고 단정하지 않습니다. 자세한 원인 확인은 선택 자료와 관리자 도움으로 이어갑니다.

## 말로 설명하는 마무리
짝에게 “어떤 오류였고 → 무엇을 확인했고 → 무엇을 바꿨고 → 결과가 어땠는지”를 말해 보세요. 명령을 외우는 것보다 이 순서를 설명할 수 있는 것이 중요합니다.

## [실습] 반복 활동 · 짝에게 문제 해결을 인계하기
**15분 · 새 명령보다 앞의 실습을 연결합니다.**

### 바꿔 보기
실습 A·B·C 중 하나를 선택하세요. 이미 해결한 예제의 파일 이름 또는 결과 파일 이름을 바꿔, 같은 원칙으로 다시 해결합니다. 개인 실습 폴더에서만 변경합니다.

### 고쳐 보기
짝은 정답 대신 다음 질문만 해 줍니다.
1. 어느 터미널인가요?
2. pwd와 ls로 무엇을 확인했나요?
3. 오류 메시지는 뭐라고 하나요?
4. 다시 실행한 결과는 무엇인가요?
<details markdown="1"><summary>막혔을 때 힌트</summary>
파일 없음은 이름·경로, Permission denied는 대상과 실행 권한, 빈 결과는 오류 로그부터 확인합니다. 명령을 무작정 늘리지 않습니다.
</details>

### 설명하기 · 도움 요청 메모
아래 양식을 종이나 메모장에 완성하세요.
```text
실행한 곳: 호스트 / 컨테이너
현재 경로:
실행한 명령:
원문 오류:
확인한 것:
바꾼 것:
재실행 결과:
```
짝이 이 기록을 보고 문제 상황을 이해할 수 있으면 성공입니다. 자세한 명령을 외우지 못해도 오류와 경로를 정확히 전달할 수 있습니다.

## [실습] Docker에서 자주 만나는 오류 {#docker-trouble}
**호스트 Bash**에서 진행한다. 각 사례는 약 5~10분이다. 필요한 사례부터 실습할 수 있다. Linux 실습에서 이어 왔다면 먼저 exit로 나온다.

### 1. 컨테이너 안에서 docker 명령이 없다고 나올 때
0장의 course-linux에는 Docker CLI를 설치하지 않았다. Docker 명령은 호스트에서 실행한다. 현재 창이 호스트인지 먼저 확인하고, 호스트에서 다음을 실행한다.
```bash
docker version
```
Client와 Server가 모두 나오면 연결된 상태다. Server 연결이 실패하면 Docker Desktop 엔진 실행 상태를 확인한다. 오류를 만들기 위해 엔진을 일부러 종료하지 않는다.

### 2. 같은 컨테이너 이름이 이미 사용 중일 때
```bash
docker run --name course-name-demo alpine:3.21 echo hello
docker run --name course-name-demo alpine:3.21 echo again
```
첫 실행은 hello 뒤 정지한다. 두 번째는 같은 이름 때문에 실패한다. “정지”와 “삭제”는 다르다.
<details markdown="1"><summary>힌트 보기</summary>
docker ps -a로 정지 컨테이너를 확인한다. 이 실습 이름인지 확인하고 그 대상만 정리한다.
</details>
<details markdown="1"><summary>[답지] 확인과 정리</summary>
```bash
docker ps -a --filter name=course-name-demo
docker logs course-name-demo
docker rm course-name-demo
```
이후 같은 이름으로 새 컨테이너를 만들 수 있다. 실제 서버의 다른 사용자 컨테이너를 삭제하지 않는다.
</details>

### 3. 입력 파일은 PC에 있는데 컨테이너에서는 없을 때
```bash
cd "$HOME/linux-server-lab"
docker run --rm alpine:3.21 cat /input/samples.tsv
```
호스트 폴더는 자동으로 연결되지 않는다. 7장에서 배운 입력 연결을 추가해 고친다.
<details markdown="1"><summary>[답지] 입력 폴더 연결</summary>
```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 cat /input/samples.tsv
```
예제 4줄이 기대 결과다.
</details>

### 4. 입력에 쓰기가 안 될 때: 보호 설정 확인
```bash
cd "$HOME/linux-server-lab"
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 sh -c 'echo test > /input/new.txt'
```
읽기 전용 연결 때문에 쓰기가 실패한다. 이 오류는 원본 입력을 보호한 결과다. 입력을 덮어쓰기보다 결과를 /output 같은 쓰기 가능한 연결에 저장한다.

### 5. 결과는 만들었는데 PC에서 찾을 수 없을 때
```bash
cd "$HOME/linux-server-lab"
mkdir -p output
docker run --name course-result-demo alpine:3.21 sh -c 'mkdir -p /output; echo inside > /output/result.txt'
```
이 명령의 /output은 컨테이너 내부다. PC 폴더를 연결한 적이 없으므로 PC output에 자동으로 생기지 않는다.
<details markdown="1"><summary>[답지] 삭제 전 결과 확인·회수</summary>
```bash
docker cp course-result-demo:/output/result.txt output/recovered-result.txt
cat output/recovered-result.txt
docker rm course-result-demo
```
inside가 기대 결과다. 같은 recovered-result.txt가 있으면 덮어쓸 수 있다. 이 사례는 정지한 컨테이너를 삭제하기 전 결과를 회수하는 방법이다. 다음 작업부터는 7장처럼 출력을 미리 연결한다. --rm으로 이미 삭제한 컨테이너에는 docker cp를 쓸 수 없다.
</details>

### 6. 실행하자마자 끝나면 실패일까요?
```bash
docker run --name course-exit-demo alpine:3.21 echo done
docker inspect course-exit-demo --format 'status={{.State.Status}} exit={{.State.ExitCode}}'
docker logs course-exit-demo
docker rm course-exit-demo
```
exited와 exit=0, 로그 done이 기대된다. 명령을 마치고 정상 종료한 것이다. 컨테이너를 계속 실행 상태로 유지하는 것이 모든 작업의 목적은 아니다.

### CPU·메모리 문제는 어디서 다시 볼까요?
- [자원 관찰](practice-resources.html): 한도와 실제 사용량 구분
- [CPU 공유](practice-cpu-sharing.html): 내 제한 전후 동료 역할의 완료 시간
- [메모리 부족](practice-memory.html): 종료 코드와 OOMKilled 비교

## 이 장의 정리

- 오류 → 증거 확인 → 한 가지 수정 → 재실행 순서로 진행한다.
- 모르는 문제는 실행 환경·경로·원문 오류를 기록해 도움을 요청한다.
