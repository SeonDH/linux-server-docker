# [실습] 저장 위치에 따른 공간 부족 - 15분

> **실습 환경:** 호스트 Bash에서 시작하고, 이 실습 전용 컨테이너 안에서 관찰
> **준비:** Docker Desktop 실행, alpine:3.21 이미지, 5장의 df·du 개념

**학습 목표:** 같은 크기의 결과라도 저장하는 경로에 따라 실패하거나 성공할 수 있음을 확인합니다.

## 작은 서랍은 가득 차도 큰 창고에는 자리가 있어요

같은 컨테이너에 크기가 다른 저장공간 두 개를 연결합니다. 둘 중 하나가 가득 차도 다른 쪽에 자동으로 저장되지 않습니다.

| 연결한 경로 | 최대 크기 | 비유 | 12MiB 파일 쓰기 |
|---|---|---|---|
| /small | 8MiB | 작은 기본 서랍 | 공간이 부족해 실패 |
| /large | 32MiB | 별도로 연결한 큰 창고 | 저장 성공 |

MiB는 파일 크기를 나타내는 단위입니다. 이번에는 **12가 8보다 크고 32보다 작다**는 점만 생각하세요.

### 실제 NAS와 이 실습의 차이

실제 서버의 루트 디스크나 NAS를 채우는 대신, **RAM 기반 임시 파일시스템인 tmpfs**로 작은 공간을 재현합니다. `--tmpfs`가 컨테이너 안의 지정한 주소에 임시 저장공간을 연결합니다. macOS·Windows에서도 Docker Desktop의 Linux 컨테이너로 진행합니다.

- `/small`은 실제 루트 파일시스템 `/`가 아닙니다. 작은 저장공간을 비유한 실습 경로입니다.
- `/large`는 실제 NAS가 아닙니다. NAS 접속·성능·네트워크 오류를 재현하는 실습도 아닙니다.
- 두 공간의 데이터는 컨테이너 메모리 사용에 포함되고, 컨테이너가 정지하면 사라집니다. 중요한 결과를 보관하는 용도로 쓰지 않습니다.
- 실제 PC 디스크의 파티션이나 서버 설정은 변경하지 않습니다.

**PC 폴더를 bind mount로 두 곳에 연결하는 것만으로 각각 8MiB·32MiB 한도가 생기지는 않습니다.** 같은 파일시스템의 두 폴더라면 여유 공간도 공유할 수 있습니다. 실제 NAS의 전체 용량과 사용자별 quota는 별도 설정입니다.

## 1. 크기가 다른 두 공간 준비하기

**호스트 Bash**에서 실행합니다. `course-linux` 안이라면 `exit`로 나옵니다. 새 실습은 `course-linux`와 별개의 컨테이너입니다.

```bash
docker run --rm -it --name course-storage-demo \
  --cpus=0.25 --memory=128m --memory-swap=128m \
  --network=none \
  --tmpfs /small:rw,size=8m \
  --tmpfs /large:rw,size=32m \
  alpine:3.21 timeout 1200 sh
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --rm -it --name course-storage-demo  --cpus=0.25 --memory=128m --memory-swap=128m  --network=none  --tmpfs /small:rw,size=8m  --tmpfs /large:rw,size=32m  alpine:3.21 timeout 1200 sh</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `-it` | 키보드 입력과 터미널 화면을 연결합니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `--cpus` | CPU 한 개 기준의 시간 한도입니다. 0.25는 25%, 1은 CPU 하나 분량이며 전용 CPU 예약이 아닙니다. |
| `--memory` | 컨테이너 RAM 사용 한도입니다. m은 MiB 단위이고, 실제 사용량이 항상 한도만큼인 것은 아닙니다. |
| `--memory-swap` | RAM과 스왑을 합한 한도입니다. --memory와 같은 값이면 컨테이너의 스왑 사용을 막습니다. |
| `--network=none` | 외부 네트워크 연결을 사용하지 않도록 합니다. |
| `--tmpfs /경로:rw,size=...` | RAM 기반 임시 공간을 지정한 경로에 연결합니다. rw는 읽기·쓰기, size는 최대 크기입니다. 정지하면 파일이 사라집니다. |
| `timeout 초 명령` | 지정한 시간이 지나면 명령에 종료를 요청합니다. 무한 계산 예제를 계속 돌리지 않기 위한 장치입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>


이제 **실습 컨테이너 안의 sh**입니다. `--tmpfs` 두 줄이 이번에 연결한 작은 공간과 큰 공간입니다. `--memory`는 컨테이너 전체 RAM 한도이며 각 저장공간의 크기와 구분합니다. 데이터 최대 합계 40MiB보다 여유 있는 128MiB로 설정했습니다. 20분 뒤 자동 종료되므로 시간이 지나 연결이 끊기면 처음부터 다시 시작합니다.

컨테이너 이름이 이미 사용 중이라는 오류가 나오면 [8장 이름 충돌 사례](08-troubleshooting.html#docker-trouble)처럼 기존 대상이 이 실습인지 먼저 확인하세요.

## 2. 경로별 크기 확인하기

계속 **실습 컨테이너 안**에서 실행합니다.

```bash
df -h /small /large
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>df -h /small /large</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |

</details>


`Size`에서 `/small`은 약 8M, `/large`는 약 32M인지 봅니다. `Mounted on`은 이 공간을 어느 주소에서 사용하는지 보여줍니다.

```text
Filesystem   Size   Used   Available   Mounted on
tmpfs        8M     ...    ...         /small
tmpfs        32M    ...    ...         /large
```

위 표는 읽는 부분을 설명한 예시입니다. 실제 표시 형식과 숫자는 환경에 따라 다를 수 있습니다. 한 공간의 여유가 다른 공간에 자동으로 합쳐지지 않는다는 점이 중요합니다.

## 3. 작은 공간에 12MiB 쓰기: 예상된 실패

```bash
dd if=/dev/zero of=/small/result.bin bs=1M count=12
echo "$?"
df -h /small /large
wc -c /small/result.bin
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>dd if=/dev/zero of=/small/result.bin bs=1M count=12</code> | 예제 데이터를 파일로 씁니다. `if=/dev/zero`는 0으로 채운 입력, `of=`는 출력 파일, `bs=`는 한 번에 쓸 크기, `count=`는 반복 횟수입니다. `bs=1M count=12`는 12MiB 쓰기 시도입니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| <code>df -h /small /large</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>wc -c /small/result.bin</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |

</details>


| 명령의 부분 | 뜻 |
|---|---|
| dd | 정해진 크기의 데이터를 쓰는 도구 |
| if=/dev/zero | 분석 데이터 대신 0으로 채운 예제 입력 |
| of=/small/result.bin | 결과를 저장할 경로 |
| bs=1M count=12 | 1MiB씩 12번, 총 12MiB 쓰기 시도 |

**예상 결과:** `No space left on device`와 0이 아닌 종료 상태. `/small`은 가득 차고 `/large`는 여유가 있습니다.

`result.bin` 파일이 생겨도 12MiB 전체가 저장된 것은 아닙니다. 보통 약 8MiB까지만 저장된 불완전한 결과가 남습니다. **파일 존재, 종료 상태, 실제 크기를 함께 확인**합니다. 뒤의 명령으로 넘어가도 괜찮습니다. 이 실패가 실습의 목적입니다.

## 4. 저장 경로만 바꾸기: 예상된 성공

```bash
dd if=/dev/zero of=/large/result.bin bs=1M count=12
echo "$?"
wc -c /large/result.bin
df -h /small /large
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>dd if=/dev/zero of=/large/result.bin bs=1M count=12</code> | 예제 데이터를 파일로 씁니다. `if=/dev/zero`는 0으로 채운 입력, `of=`는 출력 파일, `bs=`는 한 번에 쓸 크기, `count=`는 반복 횟수입니다. `bs=1M count=12`는 12MiB 쓰기 시도입니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| <code>wc -c /large/result.bin</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |
| <code>df -h /small /large</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |

</details>


**예상 결과:** 종료 상태 0, 파일 크기 **12582912바이트**, 즉 12MiB. `/small`이 계속 가득 차 있어도 `/large`에 쓰는 작업은 성공합니다.

바뀐 것은 입력 크기나 CPU가 아니라 **저장하는 주소**입니다. 실제 분석에서는 실패한 불완전한 결과를 성공 결과처럼 복사해 쓰기보다, 오류 원인을 해결하고 작업을 다시 실행해 완전한 출력을 확인합니다.

## 5. 한 공간을 정리하면 다른 공간도 비워질까요?

작은 공간의 **이번 실습에서 만든 파일만** 지웁니다.

```bash
rm /small/result.bin
df -h /small /large
wc -c /large/result.bin
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>rm /small/result.bin</code> | 지정한 파일을 삭제합니다. `-i`가 있으면 삭제 전에 확인을 요청합니다. 이번 실습에서 만든 파일만 대상으로 합니다. |
| <code>df -h /small /large</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>wc -c /large/result.bin</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |

</details>


**예상 결과:** `/small`의 여유는 돌아오고, `/large`의 완전한 결과는 그대로 남습니다. 실제 서버에서도 어느 경로의 파일을 정리하는지 구분해야 합니다.

## 6. 교육 서버의 루트·NAS 사례로 연결하기

실제 서버에서는 예를 들어 다음처럼 공간이 나뉘어 있을 수 있습니다. **아래는 실습 PC의 실제 구성이라고 가정하지 않습니다.**

| 예시 경로 | 사용하는 공간 | 주의할 점 |
|---|---|---|
| /home/user/result | 별도 연결이 없다면 루트 쪽일 수 있음 | 실제 파일시스템 확인 |
| /data/user/result | NAS가 /data에 연결됐다면 그 저장공간 | 내 출력 경로를 이곳으로 지정 |
| /tmp | 별도 구성에 따라 루트·tmpfs 등 사용 | 임시 파일 경로도 확인 |
| Docker 이미지·로그 | 엔진의 저장 설정에 따른 위치 | 입력 폴더 연결과 별개 |

NAS에 입력만 두었는데 출력·임시 파일·Docker 데이터는 루트에 쌓일 수 있습니다. NAS가 넉넉하다는 이유로 모든 경로가 넉넉하다고 판단하지 않습니다.

**실제 Linux 서버에서 조사하는 명령의 형식**입니다. 설명용 경로를 실제 경로로 바꿉니다. 없는 경로를 그대로 실행하지 않습니다.

```text
df -h 실제출력폴더
df -h 실제임시폴더
du -sh 자신의작업폴더
docker system df
```

입출력·임시 경로는 프로그램 옵션으로 지정하고, NAS 연결 여부와 Docker 저장 설정은 관리자와 확인합니다. **출력을 NAS로 옮기는 것과 Docker 이미지·로그의 저장 위치를 옮기는 것은 서로 다른 조치**입니다.

## 7. 종료와 정리

**실습 컨테이너 안**에서 실행합니다.

```bash
exit
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>exit</code> | 현재 셸을 종료합니다. 주 작업이 셸인 course-linux에서는 컨테이너가 정지하고 호스트로 돌아갑니다. |

</details>


호스트로 돌아오며 이 컨테이너는 `--rm`으로 삭제됩니다. 두 임시 공간의 파일도 남지 않습니다. 기존 `course-linux`와 PC 실습 폴더는 별개입니다.

## 직접 확인할 질문

1. 작은 공간에서 실패했을 때 큰 공간의 여유도 없어졌나요?
2. 큰 공간에서 성공하도록 바꾼 것은 CPU인가요, 결과 경로인가요?
3. 실제 NAS에 입력을 두면 Docker 이미지와 로그도 자동으로 그쪽에 저장될까요?

<details markdown="1"><summary>[답지] 확인 결과</summary>

1. 두 공간은 별개이므로 `/large`에는 여유가 있었습니다.
2. 결과 경로를 `/small`에서 `/large`로 바꿨습니다.
3. 아닙니다. 이미지·로그는 Docker 엔진 설정에 따른 공간을 사용하므로 따로 확인합니다.

</details>

[5장 저장공간으로 돌아가기](05-storage.html) · [8장 공간 부족 진단](08-troubleshooting.html#resource-trouble)

참고: [Docker tmpfs 공식 안내](https://docs.docker.com/engine/storage/tmpfs/).
