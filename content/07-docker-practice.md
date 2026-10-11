# 7. Docker 활용: 파일 연결과 결과 보존

> **실습 환경:** 호스트 Bash
> **준비:** 0장의 input·output 폴더

**학습 목표:** 컨테이너에서 만든 결과를 PC 폴더에 남길 수 있습니다.

## 문이 하나 더 생긴 같은 보관함 {#local-mount}
PC의 폴더를 컨테이너에서도 사용할 수 있게 연결하면, 같은 보관함에 다른 문이 생긴 것처럼 두 경로에서 파일을 봅니다. 파일을 자동으로 복사하는 방식이 아닙니다. 이 연결을 bind mount라고 합니다.

```text
PC의 output 폴더 ↔ 컨테이너의 /output
           연결된 같은 파일
```

## [실습] 따라 하기 · 결과를 PC에 남기기
**실습 환경: 호스트 Bash.** Windows는 WSL Ubuntu, macOS는 터미널입니다. course-linux 안이라면 exit로 나옵니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p output
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output,dst=/output" \
  alpine:3.21 sh -c 'wc -l /input/samples.tsv > /output/line-count.txt'
cat output/line-count.txt
```
**기대 결과:** 헤더를 포함한 4줄입니다. 표시 예시는 `4 /input/samples.tsv`입니다.

| 부분 | 뜻 |
|---|---|
| src=.../input | PC 쪽 입력 폴더 |
| dst=/input | 컨테이너에서 보는 입력 경로 |
| readonly | 입력을 바꾸지 않는 설정 |
| src=.../output | PC 쪽 결과 폴더 |
| dst=/output | 컨테이너가 결과를 쓰는 경로 |

`--user`는 PC 쪽 사용자 ID로 쓰는 설정입니다. 특히 Linux에서 결과가 root 소유가 되는 문제를 줄입니다. 지금은 모두 외우지 말고 입력·출력의 연결 경로를 읽는 데 집중하세요.

### 결과 파일은 누가, 어디에 만드나요?
**마운트는 폴더를 연결하고, 명령이 결과 파일을 만듭니다.** 연결했다고 결과가 자동으로 그곳에 저장되는 것은 아닙니다.

이번 명령의 `wc -l /input/samples.tsv`는 줄 수를 셉니다. `>`는 화면에 나올 결과를 파일에 저장합니다. `> /output/line-count.txt`라고 지정했으므로 컨테이너의 `/output`에 결과를 씁니다. 이 폴더가 내 컴퓨터의 `output`과 연결되어 있어서 내 컴퓨터에서도 같은 파일을 볼 수 있습니다.

| 컨테이너에서 저장한 경로 | 어디에 남나요? |
|---|---|
| 연결한 `/output/line-count.txt` | 내 컴퓨터의 `output/line-count.txt`에도 보입니다. |
| 연결하지 않은 `/tmp/line-count.txt` | 컨테이너 내부에만 남고 컨테이너를 삭제하면 사라집니다. |

이미지 안에 결과가 자동으로 추가되는 것도 아닙니다. 분석 도구가 별도의 출력 옵션을 사용한다면, 그 옵션에 연결한 출력 경로를 지정합니다. **“폴더 연결”과 “결과 저장 경로 지정”을 함께 확인하세요.**

컨테이너는 --rm으로 없어졌지만 line-count.txt는 PC 폴더에 남았습니다. Windows에서는 WSL Ubuntu 홈 폴더, macOS에서는 Mac 홈 폴더입니다.

## [실습] 반복 연습 · 결과 보관함 바꾸기
**20~25분 · 호스트 Bash.** 앞의 line-count.txt 생성이 성공한 다음 진행합니다.

### 바꿔 보기
결과를 output 대신 `output-review`에 저장하려고 합니다. PC에 새 폴더를 만듭니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p output-review
```
따라 하기 명령에서 **PC 쪽 출력 경로만** 바꿔 실행하세요. 컨테이너의 출력 경로 /output은 그대로 둡니다.
<details markdown="1"><summary>힌트 보기</summary>
출력 mount의 src를 $PWD/output-review로 바꿉니다. dst는 바꾸지 않습니다.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output-review,dst=/output" \
  alpine:3.21 sh -c 'wc -l /input/samples.tsv > /output/line-count.txt'
cat output-review/line-count.txt
```
4줄이라는 결과가 새 PC 폴더에 남습니다. 출력 파일이 이미 있으면 덮어씁니다.
</details>

### 고쳐 보기
다음 명령은 PC에 예제 파일이 있어도 실패합니다. 빠진 연결을 찾아 고치세요.
```bash
docker run --rm alpine:3.21 cat /input/samples.tsv
```
<details markdown="1"><summary>힌트 보기</summary>
PC의 input 폴더가 컨테이너의 /input에 자동으로 연결되지는 않습니다.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 cat /input/samples.tsv
```
4줄의 예제 내용이 보이면 성공입니다. 호스트의 작업 폴더에서 실행합니다.
</details>

### 설명하기
PC의 폴더 이름은 output-review인데 컨테이너에서는 왜 /output에 썼을까요? 컨테이너가 삭제된 뒤에도 결과가 남는 이유를 말하세요. Windows는 WSL Ubuntu의 폴더, macOS는 홈 폴더의 실제 결과도 확인합니다.

## 확인 질문
결과 파일은 이미지 안에 들어 있나요? 컨테이너를 삭제하면 위 결과도 사라지나요?
<details><summary>[답지] 해설 보기</summary>
결과는 연결한 PC 폴더에 있습니다. 컨테이너를 삭제해도 PC 폴더의 결과는 남습니다. 연결한 파일을 컨테이너에서 삭제하면 PC에서도 삭제될 수 있으므로 개인 실습 폴더만 사용합니다.
</details>

볼륨 비교, 읽기 전용 오류와 Dockerfile 만들기는 [선택 자료](deep-dive.html)입니다. 모두 지금 따라 할 필요는 없습니다.

문제가 생겼다면 [8장 Docker 오류 실습](08-troubleshooting.html#docker-trouble)에서 같은 증상을 찾아본다.

## 이 장의 정리

- 호스트 경로와 컨테이너 경로는 다를 수 있다.
- 연결한 PC 폴더의 결과는 컨테이너 삭제 후에도 남는다.
