# [번외] 더 알고 싶을 때

이 페이지는 기본 수업을 마친 뒤 읽는 선택 자료입니다. 처음부터 따라 할 필요는 없습니다. 각 자료의 실행 위치와 준비 조건을 확인하세요.

<details markdown="1"><summary>01 CPU와 서버 자원 이해 · 자세한 설명</summary>

# 01 CPU와 서버 자원 이해

**실행 위치:** `course-linux` 컨테이너의 Bash. 컨테이너 내부 프로세스와 자원을 관찰합니다.

**목표:** CPU·메모리·디스크의 역할을 구분하고, 자신의 작업이 쓰는 자원을 확인합니다.

## 계산은 어디에서 실행되나요?
분석 프로그램을 실행하면 운영체제가 CPU 시간을 배분하고, 메모리에 작업 중 데이터를 올리며, 디스크에서 입력을 읽고 결과를 씁니다. 서버가 느릴 때에는 어떤 자원을 기다리는지 먼저 구분해야 합니다.

| 자원 | 하는 일 | 부족하거나 과도하게 쓰면 |
|---|---|---|
| CPU | 명령과 계산 실행 | 계산 대기·다른 작업과 경쟁 |
| 메모리 RAM | 실행 중 데이터를 보관 | swap 사용·작업 종료 가능 |
| 디스크·스토리지 | 입력·결과·로그를 지속 저장 | 저장 실패·읽기와 쓰기 지연 |
| 네트워크 | 다른 장치와 데이터 전송 | 다운로드·원격 접근 지연 |

CPU가 계산하는 책상 위 작업자를 뜻한다면, RAM은 작업 중 펼쳐 놓는 공간, 디스크는 자료를 보관하는 서랍에 해당합니다. 서랍이 크다고 책상이 넓어지는 것은 아닙니다. CPU 수를 늘려도 파일 읽기가 병목이면 실행 시간이 크게 줄지 않을 수 있습니다.

## 프로그램과 프로세스
프로그램은 실행할 코드와 파일이고, 프로세스는 프로그램을 실행한 작업입니다. 같은 프로그램을 두 번 실행하면 별도 프로세스가 생길 수 있습니다. 실제 작업의 관찰과 종료는 6장에서 실습합니다.

## CPU·코어·스레드 구분
- **CPU:** 계산을 수행하는 장치입니다. 서버에는 여러 CPU 소켓이 있을 수 있습니다.
- **코어:** CPU 안의 계산 단위입니다. 여러 코어는 여러 작업을 병렬로 처리할 수 있습니다.
- **논리 CPU:** 운영체제가 작업을 배분하는 실행 단위입니다. 하드웨어 스레딩 때문에 물리 코어보다 많을 수 있습니다.
- **프로그램의 스레드:** 프로그램 안의 실행 흐름입니다. 도구의 `--threads` 옵션은 사용하는 프로그램 스레드를 정하며, 모두가 항상 CPU를 사용하는 것은 아닙니다.

스레드를 두 배로 준다고 언제나 두 배 빨라지지는 않습니다. 병렬화 가능한 부분, 메모리 사용과 I/O, 다른 사용자와의 경쟁이 함께 영향을 줍니다. 도구별 옵션 이름과 권장 사용량을 확인하세요.

## 보이는 CPU 수와 사용할 수 있는 CPU는 다릅니다
**실행 위치: `course-linux` 컨테이너 안.**
```bash
cd "$HOME/linux-server-lab"
mkdir -p logs
lscpu
nproc
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p logs</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| <code>lscpu</code> | CPU의 구조와 코어·논리 CPU 등 정보를 보여줍니다. 보이는 전체 자원이 모두 내 할당량이라는 뜻은 아닙니다. |
| <code>nproc</code> | 현재 환경에서 사용 가능하다고 보고되는 CPU 수를 출력합니다. 내 CPU 시간 한도와 같다고 가정하지 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

출력은 컨테이너와 Docker Desktop 설정에 따라 달라집니다. 00장의 `--cpus=1`은 CPU 사용 시간의 한도이며, 컨테이너에서 CPU 한 개만 보이게 한다는 뜻은 아닙니다. 따라서 `lscpu` 결과를 보고 모든 코어를 사용해도 된다고 판단하지 않습니다. 컨테이너의 메모리 관찰값도 `--memory=512m` 제한과 반드시 같은 값으로 보이지는 않습니다.

실제 공유 서버에서는 관리자나 스케줄러가 할당한 CPU·메모리 범위를 지킵니다. 내 작업이 서버 전체를 사용할 권한을 가진 것은 아닙니다.

## 짧은 실습 · 자원 관찰 기록하기
**10분 · 실행 위치: `course-linux` 컨테이너.**
```bash
cd "$HOME/linux-server-lab"
printf 'CPU count: '; nproc
free -h
df -h .
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>printf &#x27;CPU count: &#x27;; nproc</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>free -h</code> | 메모리 상태를 봅니다. `-h`는 읽기 쉬운 단위이며, 컨테이너별 메모리 한도와는 다를 수 있습니다. |
| <code>df -h .</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

표에 “보이는 CPU 수 / 메모리 available / 작업 경로의 디스크 여유”를 적습니다. 이 값은 컨테이너가 보는 값입니다. 호스트 PC의 작업 관리자·활성 상태 보기와 비교하고 같거나 다른 이유를 이야기하세요. 자원을 고갈시키는 작업은 실행하지 않습니다.

## 확인 질문
파일 저장 중 `No space left on device`가 났다면 CPU를 늘리는 것이 해결책인가요? 메모리가 512 MB로 제한된 컨테이너에서 2 GB 데이터를 한 번에 올리는 작업은 적절할까요?

<details><summary>해설 보기</summary>
저장공간 문제는 대상 경로의 디스크 사용량 등을 확인해야 합니다. CPU 증가는 저장 용량을 늘리지 않습니다. 메모리 한도보다 큰 작업은 실패할 수 있으므로 작은 입력 검증, 분할 처리 또는 적절한 자원 할당을 검토합니다.
</details>

복습: [기존 교재의 서버 상태 보기](https://seondh.github.io/bio_linux/day3/chapter12/extra/server_status.html).


</details>

<details markdown="1"><summary>02 Docker와 컨테이너 이해 · 자세한 설명</summary>

# 02 Docker와 컨테이너 이해

**목표:** 셸 스크립트와 비교하여 Docker를 왜 쓰는지 설명하고, 이미지·컨테이너·볼륨을 구분합니다.

**실행 위치:** Windows는 WSL Ubuntu, Mac은 터미널의 **호스트 Bash**입니다. `course-linux` 컨테이너 안이라면 `exit`로 나옵니다. 이 장에서는 설명을 먼저 읽고, 마지막에 작은 실행만 해 봅니다.

## 1. 익숙한 파일에서 출발하기
` samples.tsv `에는 데이터가 있고, `count.sh`에는 실행할 명령이 있습니다. 파일을 보관하는 것과 그 파일을 읽어 작업을 수행하는 것은 다릅니다.

예를 들어 `count.sh`라는 셸 스크립트에 아래 내용을 적었다고 생각해 보세요. 지금 새 파일을 만들 필요는 없습니다.
```bash
#!/usr/bin/env bash
wc -l input/samples.tsv
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>#!/usr/bin/env bash</code> | 이 파일을 실행할 셸을 지정하는 첫 줄입니다. `/bin/sh`는 sh, `/usr/bin/env bash`는 PATH에서 찾은 Bash를 사용합니다. |
| <code>wc -l input/samples.tsv</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |
| `wc -l` | 입력 파일이나 전달받은 입력의 줄 수를 셉니다. 예제는 헤더를 포함해 4줄입니다. |

</details>

`bash count.sh`를 실행하면 Bash가 파일의 명령을 읽고 `wc`로 줄 수를 셉니다. **스크립트는 할 일을 적은 파일이고, 실행 중인 작업은 프로세스**입니다. 1장에서 배운 파일과 실행의 차이입니다.

## 2. 셸 스크립트를 전달했는데 왜 실행이 안 될까요?
이번에는 동료에게 아래 스크립트를 받았다고 생각해 보세요.
```bash
python3 analyze.py input/samples.tsv
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>python3 analyze.py input/samples.tsv</code> | Python으로 analyze.py 스크립트를 실행하고 입력 경로를 전달하는 설명용 예시입니다. 이 파일은 준비하지 않았으므로 그대로 실행하지 않습니다. |

</details>

내 PC에 Python이 없으면 시작할 수 없습니다. Python이 있어도 `analyze.py`가 필요한 라이브러리가 없거나 버전이 다르면 실패할 수 있습니다. 셸 스크립트를 전달하는 것만으로는 Python·라이브러리·분석 코드가 준비되지 않습니다.

**셸 스크립트는 “무엇을 실행할지”를 담습니다. Docker 이미지는 “무엇으로 실행할지”에 필요한 도구와 파일을 담을 수 있습니다.** 셸 스크립트로 설치를 자동화할 수도 있지만 설치 위치와 실행 환경은 여전히 확인해야 합니다.

## 3. Docker는 실행 환경을 준비하고 작업을 시작하는 도구입니다
도구와 필요한 라이브러리가 들어 있는 이미지를 받아 그 환경에서 명령을 실행하면, 각 PC에 도구를 하나씩 직접 설치하는 부담을 줄일 수 있습니다. 셸 스크립트는 컨테이너 안에서도 그대로 활용할 수 있습니다.

```text
셸 스크립트로 실행
명령이 적힌 파일 → 내 PC에 설치된 도구로 실행

Docker로 실행
도구가 준비된 이미지 → 컨테이너를 만들어 그 안에서 명령 실행
```
Docker는 CPU·메모리·디스크를 새로 만들어 주지는 않습니다. 1장에서 배운 PC의 자원을 사용합니다. 이미지가 같아도 입력, 명령, 옵션과 CPU 아키텍처 등에 따라 결과나 실행 가능 여부가 달라질 수 있습니다.

## 4. 이미지와 컨테이너를 아주 쉽게 이해하기
### 먼저: 도구가 준비된 작업 공간을 떠올려 보세요
텍스트 파일의 줄 수를 세려면 파일을 읽는 프로그램과 명령을 실행할 셸이 필요합니다. 분석이라면 Python과 라이브러리도 필요할 수 있습니다. 매번 새 PC에 이 도구들을 직접 설치하기보다, **도구와 필요한 파일이 준비된 원본을 받아 작업 공간을 만드는 것**이 Docker의 기본 흐름입니다.

### 이미지 = 도구와 필요한 파일이 준비된 원본
이미지는 프로그램을 실행하는 데 필요한 파일을 묶어 둔 것입니다. 예를 들어 `alpine:3.21` 이미지에는 작은 Linux 환경에서 쓰는 셸과 기본 도구가 있습니다. Python이 포함된 이미지라면 그 안의 Python을 사용할 수 있습니다.

**이미지는 아직 작업을 시작한 상태가 아닙니다.** 도구를 준비해 둔 것과 도구로 일을 하는 것은 다릅니다. 또한 이미지마다 들어 있는 도구가 다릅니다. Alpine 이미지를 받았다고 모든 분석 프로그램이 준비되는 것은 아닙니다.

### 컨테이너 = 이미지로 만든 개별 작업 공간
컨테이너는 이미지를 바탕으로 만든 작업 공간입니다. 그 안에서 프로그램을 실행하고 파일을 만들 수 있습니다. 실행된 프로그램은 1장에서 배운 프로세스이며, PC의 CPU와 메모리를 사용합니다.

하나의 이미지로 여러 컨테이너를 만들 수 있습니다. 같은 도구가 준비된 원본으로 작업 A와 작업 B를 따로 시작하는 것입니다.
```text
Alpine 이미지: 셸과 기본 도구가 준비된 원본
    ├─ 컨테이너 A: 파일의 줄 수를 세는 작업
    └─ 컨테이너 B: 다른 파일을 정렬하는 작업
```
두 컨테이너의 내부 작업 파일은 기본적으로 따로 있습니다. A 안에 파일을 만들었다고 B 안에도 자동으로 생기지 않습니다. 같은 PC 폴더나 볼륨을 둘 다 연결하면 그 연결한 파일은 공유할 수 있습니다.

### 실행·정지·삭제는 다릅니다
컨테이너는 “실행 중인 프로그램”과 완전히 같은 뜻은 아닙니다. 프로그램이 끝난 뒤 **정지한 컨테이너**가 남을 수 있습니다.

| 상태 | 쉽게 말하면 | 내부 파일 |
|---|---|---|
| 실행 | 작업 공간에서 프로그램이 일하고 있음 | 읽고 쓸 수 있음 |
| 정지 | 작업이 끝났지만 작업 공간은 보관 중 | 삭제하지 않았다면 남음 |
| 삭제 | 그 작업 공간을 없앰 | 별도로 저장하지 않은 내부 파일도 사라짐 |

컨테이너 하나를 삭제해도 원본 이미지는 그대로 남습니다. 필요하면 같은 이미지로 새 컨테이너를 만들 수 있습니다. 새 컨테이너가 이전 컨테이너의 작업 결과까지 복원해 주는 것은 아닙니다.

### 일반 파일·셸 스크립트와 비교하기
| 대상 | 무엇을 담나요? | 예시 |
|---|---|---|
| 데이터 파일 | 처리할 내용 | `samples.tsv` |
| 셸 스크립트 | 실행할 명령 | `count.sh` |
| 이미지 | 명령을 실행할 도구와 필요한 파일 | `alpine:3.21` |
| 컨테이너 | 이미지로 만든 개별 실행·작업 공간 | 파일을 세는 작업 A |

셸 스크립트는 “무엇을 할지”, 이미지는 “어떤 도구로 할지”를 준비합니다. 컨테이너는 그 도구로 실제 작업하는 공간입니다. 이미지는 단순한 `.sh` 파일이 아니며, 컨테이너는 폴더 하나만을 뜻하지 않습니다.

### Dockerfile은 셸 스크립트인가요?
Dockerfile은 **이미지를 만드는 방법을 적은 텍스트 파일**입니다. 예를 들어 어떤 기본 이미지를 쓰고 어떤 파일을 넣을지 적습니다. Docker가 그 설명을 읽어 이미지를 만듭니다. 일부 단계에서 셸 명령을 사용할 수 있지만 `bash Dockerfile`로 실행하는 셸 스크립트는 아닙니다.

```text
Dockerfile: 환경을 만드는 설명서
        ↓ docker build
이미지: 준비된 실행 환경
        ↓ docker run
컨테이너: 명령을 실행하는 개별 작업 환경
```
이번 장은 이미 준비된 이미지를 사용합니다. 직접 이미지를 만드는 실습은 필수가 아닙니다.

## 5. 볼륨과 파일 연결: 결과는 따로 보관하기
### 왜 별도의 보관 장소가 필요할까요?
컨테이너 안에서 `result.txt`를 만들었다고 생각해 보세요. 컨테이너를 **정지**하면 파일은 남을 수 있지만, 컨테이너를 **삭제**하면 그 안에만 둔 파일도 사라집니다.

결과를 계속 보관하려면 작업 공간 밖의 저장 장소를 연결합니다. 이번 수업에서 배우는 방식은 두 가지입니다.

### bind mount = 내 폴더를 작업 공간에 연결하기
“내 PC의 `output` 폴더를 컨테이너에서는 `/output`으로 사용하자”는 연결입니다. 컨테이너가 `/output/result.txt`에 쓰면 PC의 `output/result.txt`에서도 결과를 확인할 수 있습니다.

```text
PC의 output 폴더 ↔ 컨테이너의 /output 경로
              같은 파일을 두 곳에서 접근
```
파일을 자동 복사하는 기능이 아닙니다. 연결한 파일을 수정하면 PC에서도 바뀝니다. 입력은 읽기 전용으로 연결하면 원본이 바뀌는 것을 막을 수 있습니다.

### named volume = Docker가 관리하는 별도 보관함
볼륨은 Docker가 저장 위치를 관리하는 공간입니다. 예를 들어 `course-results`라는 이름의 볼륨을 만들고 컨테이너의 `/results`에 연결하면 그 위치에 쓴 파일을 보관할 수 있습니다. 같은 볼륨을 다른 컨테이너에 연결해서 이어 사용할 수도 있습니다.

이 교재의 named volume은 컨테이너를 삭제해도 별도로 남습니다. 볼륨 자체를 삭제하면 그 안의 데이터도 없어지므로 무엇이 들어 있는지 확인해야 합니다. Docker가 관리할 뿐, 디스크 공간을 쓰지 않는 것은 아닙니다.

| 질문 | 컨테이너 내부만 사용 | PC 폴더 연결 | named volume 연결 |
|---|---|---|---|
| 누가 위치를 정하나요? | 컨테이너 내부 경로 | 내가 지정한 PC 폴더 | Docker가 관리하는 위치 |
| 컨테이너를 삭제하면? | 내부 파일도 사라짐 | PC 폴더의 파일은 남음 | 별도 볼륨이 남음 |
| 이번 수업에서는? | 결과가 사라질 수 있음을 이해 | 입력·결과 파일 실습의 기본 방식 | 별도 보관함 비교 실습 |

**작업 공간과 결과 보관 장소를 구분하세요.** 컨테이너는 작업하는 곳이고, 오래 보관할 결과는 연결한 PC 폴더 또는 볼륨에 저장합니다.

## 6. Docker Desktop과 docker 명령은 어떤 관계인가요?
Docker Desktop은 Mac·Windows에서 Docker를 사용하기 쉽게 준비해 주는 앱입니다. 엔진과 명령줄 도구, 관리 화면 등을 제공합니다. 이번 수업에서는 앱을 켜 두고 터미널에서 명령을 실행합니다.

| 이름 | 쉬운 설명 |
|---|---|
| Docker CLI, 즉 `docker` 명령 | 엔진에게 “이 작업을 실행해 줘”라고 요청하는 도구 |
| Docker Engine | 요청을 받아 이미지·컨테이너를 관리하고 작업을 실행하는 엔진 |
| Docker Desktop | 개인 PC에서 엔진과 Linux 실행 환경, 관리 화면 등을 준비해 주는 앱 |
| Docker Hub | 준비된 이미지를 내려받거나 공유하는 서비스 |

```text
호스트 터미널의 docker 명령
        ↓ 요청
Docker Desktop의 Linux 환경에서 동작하는 엔진
        ↓ 실행
컨테이너 안의 프로그램
```
Linux 서버에서는 Docker Engine을 직접 사용할 수 있어 Desktop이 필수는 아닙니다. Mac·Windows에서 Linux 컨테이너는 Desktop이 제공하는 Linux 환경의 커널을 사용합니다. 컨테이너마다 완전한 가상 PC를 새로 설치하는 방식과는 다릅니다.

`docker` 명령이 있어도 엔진이 꺼져 있으면 실행할 수 없습니다. `docker version`의 Client는 요청하는 명령줄 도구, Server는 연결된 엔진입니다. 무료·유료 조건은 [사전 준비 장](setup.html)을 참고하세요.

## 7. 같은 명령을 PC와 컨테이너에서 실행하기
호스트에서 실행합니다. 작은 텍스트 한 줄을 출력하므로 파일 연결 없이 먼저 비교할 수 있습니다.
```bash
printf 'hello\n'
docker run --rm alpine:3.21 sh -c 'printf "hello\n"'
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>printf &#x27;hello\n&#x27;</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>docker run --rm alpine:3.21 sh -c &#x27;printf &quot;hello\n&quot;&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

둘 다 `hello`를 출력합니다. 첫 번째는 호스트의 셸에서, 두 번째는 Alpine 이미지로 만든 컨테이너에서 실행합니다.

두 번째 명령을 나누어 읽어 봅시다.

| 부분 | 뜻 |
|---|---|
| `docker run` | 새 컨테이너를 만들고 실행합니다. |
| `--rm` | 작업이 끝나면 그 컨테이너를 자동 삭제합니다. |
| `alpine:3.21` | 사용할 이미지와 태그입니다. |
| `sh -c '...'` | 컨테이너 안의 셸에게 따옴표 안 명령을 실행하게 합니다. |

여기서는 이미지에 셸이 준비되어 있기 때문에 `sh`를 사용할 수 있습니다. 모든 이미지에 Bash나 같은 도구가 들어 있다고 가정하지 않습니다. 셸 스크립트도 파일을 연결하거나 이미지에 포함해서 그 안에서 실행할 수 있습니다. Docker와 셸 스크립트는 함께 사용할 수 있습니다.

## 8. 준비·실행·정지를 직접 확인하기
```bash
docker image ls
docker run --name course-hello alpine:3.21 sh -c 'echo hello; cat /etc/os-release'
docker ps
docker ps -a
docker logs course-hello
docker rm course-hello
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker image ls</code> | 로컬 Docker 저장소에 있는 이미지 목록을 보여줍니다. |
| <code>docker run --name course-hello alpine:3.21 sh -c &#x27;echo hello; cat /etc/os-release&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker ps</code> | 컨테이너 목록을 봅니다. 기본은 실행 중인 대상, `-a`는 정지한 대상도 포함하며 `--filter name=...`는 이름으로 목록을 좁힙니다. |
| <code>docker ps -a</code> | 컨테이너 목록을 봅니다. 기본은 실행 중인 대상, `-a`는 정지한 대상도 포함하며 `--filter name=...`는 이름으로 목록을 좁힙니다. |
| <code>docker logs course-hello</code> | 지정한 컨테이너의 표준 출력·오류 로그를 봅니다. `--tail 50`은 마지막 50줄입니다. |
| <code>docker rm course-hello</code> | 지정한 컨테이너를 삭제합니다. 내부에만 저장한 파일도 없어지지만 이미지와 연결한 외부 폴더는 삭제하지 않습니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `/etc/os-release` | 컨테이너의 Linux 배포판과 버전 정보가 적힌 파일입니다. |
| `echo 글자` | 컨테이너 안에서 지정한 글자를 출력합니다. >가 있으면 그 출력을 파일에 저장합니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

첫 번째 목록은 이미지, `docker ps`는 실행 중인 컨테이너, `docker ps -a`는 정지한 컨테이너도 보여줍니다. `course-hello`는 출력 후 주 프로그램이 끝나 정지합니다. `docker logs`로 출력을 다시 보고, 마지막 명령으로 **이 실습에서 만든 정지 컨테이너만** 삭제합니다. 이미지는 여전히 남아 있습니다.

같은 이름이 이미 있다는 오류가 나면 이전 실습 컨테이너인지 확인하세요. 결과를 남겨야 하는 작업은 7장에서 배울 파일 연결을 먼저 정합니다.

## 용어를 한 문장씩 다시 보기
| 용어 | 한 문장 설명 |
|---|---|
| 이미지 | 도구와 필요한 파일이 준비된 실행 환경의 원본 |
| 컨테이너 | 이미지로 만든 개별 작업 공간 |
| 프로세스 | 그 공간 안에서 실제로 실행 중인 프로그램 |
| Dockerfile | 이미지를 어떻게 만들지 적은 설명서 |
| 태그 | 이미지 이름 뒤에 붙는 버전 등을 구분하는 표시, 예: `:3.21` |
| Docker Hub | 이미지를 내려받고 공유하는 곳 |
| bind mount | 내가 지정한 폴더를 컨테이너에 연결하는 방법 |
| named volume | 이름을 붙여 사용하는 Docker 관리 저장공간 |
| Docker CLI | 터미널에서 엔진에 요청을 보내는 `docker` 명령 |
| Docker Engine | 컨테이너 실행과 이미지 등을 관리하는 엔진 |
| Docker Desktop | PC에서 Docker를 쓰기 쉽게 준비해 주는 앱 |

태그는 구분하는 표시이며 내용이 영원히 고정된다는 뜻은 아닙니다. 정확한 환경 기록 방법은 후속 실습에서 다룹니다.

## 이해 확인
1. `.sh` 파일을 보내면 필요한 Python과 라이브러리도 같이 전달되나요?
2. 이미지를 내려받는 것과 컨테이너를 실행하는 것은 어떻게 다른가요?
3. 컨테이너를 삭제한 뒤에도 결과를 남기려면 어떻게 해야 하나요?
4. Docker Desktop을 켜 두고 터미널에서 `docker`를 쓰는 이유는 무엇인가요?

<details><summary>해설 보기</summary>
셸 스크립트는 명령을 담으며 필요한 도구와 파일은 따로 준비해야 합니다. 이미지는 실행 환경을 준비한 것이고 컨테이너는 그것으로 만든 개별 작업 환경입니다. 결과는 PC 폴더를 연결하거나 볼륨에 저장해 보존합니다. docker 명령은 실행을 요청하고 Desktop이 제공하는 엔진은 그 요청을 처리합니다.
</details>

참고: [Docker 공식 개념 설명](https://docs.docker.com/get-started/docker-overview/), [Docker의 파일 연결](https://docs.docker.com/engine/storage/bind-mounts/), [볼륨](https://docs.docker.com/engine/storage/volumes/).


</details>

<details markdown="1"><summary>03 경로와 권한 · 자세한 설명</summary>

# 03 경로와 권한

**실행 위치:** 00장에서 준비한 `course-linux` 컨테이너의 Bash. 호스트에서 `docker start -ai course-linux`로 들어오세요.

**목표:** 명령 실패를 경로, 사용자와 권한으로 나누어 설명합니다.

## 경로는 실행 위치에 따라 달라집니다
절대 경로는 `/`에서 시작합니다. 상대 경로는 현재 디렉터리에서 시작합니다. `PATH`는 실행 파일을 찾는 목록이며 데이터 파일의 위치를 자동으로 찾지는 않습니다.
```bash
cd "$HOME/linux-server-lab"
pwd
ls -l input/samples.tsv
command -v bash
printf '%s\n' "$PATH"
cd output
cat input/samples.tsv
cat ../input/samples.tsv
cd ..
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>pwd</code> | 현재 작업 중인 폴더의 절대 경로를 출력합니다. 파일을 찾기 전에 내 위치를 확인합니다. |
| <code>ls -l input/samples.tsv</code> | 파일이나 폴더를 확인합니다. `-l`은 권한·소유자 등 상세 정보, `-d`는 폴더 내부 대신 폴더 자체, `-h`는 크기를 읽기 쉬운 단위로 보여줍니다. |
| <code>command -v bash</code> | 해당 명령을 어디에서 찾았는지 보여줍니다. PATH의 프로그램 검색과 데이터 파일의 경로 찾기는 별개입니다. |
| <code>printf &#x27;%s\n&#x27; &quot;$PATH&quot;</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>cd output</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>cat input/samples.tsv</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>cat ../input/samples.tsv</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>cd ..</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |
| `$PATH` | 프로그램 이름을 찾을 폴더 목록입니다. |

</details>

첫 `cat`은 실패하고 두 번째는 성공합니다. 출력 파일의 부모 디렉터리도 미리 존재해야 합니다.

## 권한은 사용자와 대상별로 확인합니다
`r/w/x`는 읽기·쓰기·실행입니다. 디렉터리의 `x`는 경로를 통과하는 권한, `w`는 항목 생성·삭제와 관계가 있습니다. 파일이 읽기 가능해도 상위 디렉터리에 접근할 수 없으면 열 수 없습니다.
```bash
id
ls -ld . input output
printf '#!/usr/bin/env bash\nprintf "hello\\n"\n' > scratch/hello.sh
./scratch/hello.sh
bash scratch/hello.sh
chmod u+x scratch/hello.sh
./scratch/hello.sh
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>id</code> | 현재 사용자의 숫자 ID, 그룹 ID와 소속 그룹을 확인합니다. |
| <code>ls -ld . input output</code> | 파일이나 폴더를 확인합니다. `-l`은 권한·소유자 등 상세 정보, `-d`는 폴더 내부 대신 폴더 자체, `-h`는 크기를 읽기 쉬운 단위로 보여줍니다. |
| <code>printf &#x27;#!/usr/bin/env bash\nprintf &quot;hello\\n&quot;\n&#x27; &gt; scratch/hello.sh</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>./scratch/hello.sh</code> | 현재 폴더를 기준으로 스크립트를 직접 실행합니다. `./`가 경로를 지정하고, 파일에는 실행 권한이 필요합니다. |
| <code>bash scratch/hello.sh</code> | 뒤에 지정한 셸 스크립트 파일을 Bash로 실행합니다. 파일을 저장한 위치에서 실행해야 합니다. |
| <code>chmod u+x scratch/hello.sh</code> | 파일의 권한을 바꿉니다. `u-x`는 소유자의 실행 권한 제거, `u+x`는 추가입니다. `755`는 소유자 읽기·쓰기·실행과 나머지 읽기·실행, `600`은 소유자만 읽기·쓰기입니다. |
| <code>./scratch/hello.sh</code> | 현재 폴더를 기준으로 스크립트를 직접 실행합니다. `./`가 경로를 지정하고, 파일에는 실행 권한이 필요합니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |

</details>

직접 실행하려면 실행 권한이 필요합니다. `bash 파일`은 Bash가 파일을 읽는 방식입니다. `chmod 777` 대신 자신에게 필요한 권한만 추가합니다.

## 짧은 실습 · PATH와 데이터 경로 구분
**5분 · 컨테이너 안에서 실행합니다.**
```bash
command -v wc
wc -l "$HOME/linux-server-lab/input/samples.tsv"
(cd output && wc -l input/samples.tsv)
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>command -v wc</code> | 해당 명령을 어디에서 찾았는지 보여줍니다. PATH의 프로그램 검색과 데이터 파일의 경로 찾기는 별개입니다. |
| <code>wc -l &quot;$HOME/linux-server-lab/input/samples.tsv&quot;</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |
| <code>(cd output &amp;&amp; wc -l input/samples.tsv)</code> | 괄호 안의 별도 셸에서 폴더를 바꾸고 명령을 실행합니다. 괄호가 끝나면 바깥 셸의 현재 폴더는 바뀌지 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |
| `wc -l` | 입력 파일이나 전달받은 입력의 줄 수를 셉니다. 예제는 헤더를 포함해 4줄입니다. |

</details>

앞의 `wc`는 헤더를 포함해 4줄입니다. 마지막은 상대 경로가 달라 실패합니다. `command -v`는 프로그램 위치를 찾지만 데이터 파일까지 찾아 주지는 않습니다.

## 일반 사용자 권한으로 읽기 오류 확인: 선택 실습
00장의 컨테이너는 root라 읽기·쓰기 권한을 우회할 수 있습니다. 일반 사용자 상황을 확인하려면 **호스트 터미널**에서 다음 작은 일회성 컨테이너를 실행하세요. 실습용 사용자 파일은 컨테이너에만 생성됩니다.
```bash
docker run --rm alpine:3.21 sh -c 'mkdir /demo; chmod 755 /demo; printf "private\n" > /demo/private.txt; chmod 600 /demo/private.txt; su nobody -s /bin/sh -c "cat /demo/private.txt"'
echo "$?"
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --rm alpine:3.21 sh -c &#x27;mkdir /demo; chmod 755 /demo; printf &quot;private\n&quot; &gt; /demo/private.txt; chmod 600 /demo/private.txt; su nobody -s /bin/sh -c &quot;cat /demo/private.txt&quot;&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `su nobody -s /bin/sh -c ...` | 컨테이너의 일반 사용자 nobody로 바꿔 지정한 셸 명령을 실행합니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

`Permission denied`와 0이 아닌 종료 상태가 기대됩니다. root가 만든 소유자 전용 파일을 nobody 사용자가 읽으려 했기 때문입니다. 실습을 해결하려고 실제 PC 폴더에 `chmod 777`을 적용하지 않습니다.

## 확인 질문
1. `PATH`와 입력 데이터 경로는 어떻게 다른가요?
2. 프로그램은 찾는데 데이터 파일은 못 찾는 이유는 무엇인가요?
3. 파일 읽기 권한과 실행 권한은 언제 각각 필요한가요?

<details><summary>해설 보기</summary>
PATH는 프로그램 검색 경로입니다. 데이터의 상대 경로는 현재 디렉터리에 따라 달라집니다. Bash로 읽어 실행하는 경우와 파일을 직접 실행하는 경우의 권한 요구가 다릅니다.
</details>

참고: [Bash 파이프 공식 설명](https://www.gnu.org/software/bash/manual/html_node/Pipelines).

복습: [기존 교재의 권한과 소유권](https://seondh.github.io/bio_linux/day3/chapter11/).


</details>

<details markdown="1"><summary>04 파일 처리와 파이프라인 · 자세한 설명</summary>

# 04 파일 처리와 파이프라인

**목표:** 결과와 오류를 구분해서 저장하고 파이프 앞 단계의 실패를 확인합니다.
**실행 위치:** `course-linux` 컨테이너의 Bash. 작업 폴더로 이동합니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p output logs scratch
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p output logs scratch</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>


## 파일 I/O는 읽고 쓰는 작업입니다
입력 파일을 읽어 결과 파일에 쓰는 동안 디스크를 사용합니다. 작은 파일을 매우 자주 열거나 대용량 파일을 여러 번 읽으면 계산보다 I/O가 병목일 수 있습니다. 출력·로그·임시 파일도 저장 공간을 사용합니다.

## 표준 입력·출력·오류
| 통로 | 번호 | 연결 |
|---|---|---|
| 표준 입력 | 0 | 키보드 또는 파일 |
| 표준 출력 | 1 | 결과, `>` 또는 파이프 |
| 표준 오류 | 2 | 오류, `2>` |

```bash
cat input/missing.tsv > output/result.txt 2> logs/error.log
status=$?
printf 'exit=%s\n' "$status"
cat logs/error.log
wc -c output/result.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cat input/missing.tsv &gt; output/result.txt 2&gt; logs/error.log</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>status=$?</code> | 등호 왼쪽의 변수 이름에 오른쪽 값을 저장합니다. `$!`는 방금 시작한 백그라운드 작업의 PID, `$?`는 바로 앞 명령의 종료 상태입니다. |
| <code>printf &#x27;exit=%s\n&#x27; &quot;$status&quot;</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>cat logs/error.log</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>wc -c output/result.txt</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| 예상된 실패 예제 | 일부러 없는 파일·잘못된 경로·빠진 따옴표 등을 사용했습니다. 해당 사례의 오류와 해결 단계까지 확인합니다. |

</details>

리다이렉션은 명령 실행 전에 파일을 열어 `>`의 기존 내용을 지웁니다. 실패했는데도 빈 결과 파일이 생길 수 있습니다. `>>`는 이어 쓰기입니다. 입력 파일과 같은 파일로 출력하지 마세요.

## 파이프의 숨은 실패
```bash
set +o pipefail
cat input/missing.tsv 2> logs/pipeline.log | wc -l
echo "$?"
set -o pipefail
cat input/missing.tsv 2> logs/pipeline.log | wc -l
echo "$?"
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>set +o pipefail</code> | `-o pipefail`은 파이프 앞 단계의 실패도 종료 상태에 반영하고, `+o pipefail`은 그 설정을 해제합니다. `-e`는 처리되지 않은 실패 시 종료, `-u`는 정의되지 않은 변수 사용 시 오류를 내는 설정입니다. |
| <code>cat input/missing.tsv 2&gt; logs/pipeline.log &#124; wc -l</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| <code>set -o pipefail</code> | `-o pipefail`은 파이프 앞 단계의 실패도 종료 상태에 반영하고, `+o pipefail`은 그 설정을 해제합니다. `-e`는 처리되지 않은 실패 시 종료, `-u`는 정의되지 않은 변수 사용 시 오류를 내는 설정입니다. |
| <code>cat input/missing.tsv 2&gt; logs/pipeline.log &#124; wc -l</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `|` | 앞 명령의 표준 출력을 뒤 명령의 입력으로 전달합니다. 오류 메시지는 자동으로 전달되지 않습니다. |
| `wc -l` | 입력 파일이나 전달받은 입력의 줄 수를 셉니다. 예제는 헤더를 포함해 4줄입니다. |
| 예상된 실패 예제 | 일부러 없는 파일·잘못된 경로·빠진 따옴표 등을 사용했습니다. 해당 사례의 오류와 해결 단계까지 확인합니다. |

</details>

기본 상태는 마지막 명령의 성공만 보여줍니다. Bash의 `pipefail`은 앞 단계의 실패도 파이프 종료 상태에 반영합니다. `set -e` 하나만으로 모든 실패를 처리할 수 있다고 가정하지 않습니다.


## 짧은 실습 · 그룹별 개수 만들기
**10분.** 예제의 두 번째 열은 그룹입니다. 헤더를 제외하고 그룹 이름을 뽑아 정렬한 뒤 개수를 셉니다.
```bash
awk -F '\t' 'NR>1 {print $2}' input/samples.tsv | sort | uniq -c > output/group-count.txt
cat output/group-count.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>awk -F &#x27;\t&#x27; &#x27;NR&gt;1 {print $2}&#x27; input/samples.tsv &#124; sort &#124; uniq -c &gt; output/group-count.txt</code> | 탭으로 구분된 표를 처리합니다. `-F`는 구분자, `NR>1`은 헤더 이후 행, `$2`·`$3`은 두 번째·세 번째 열, `sum+=`는 합산, `END`는 모두 읽은 뒤 실행입니다. `sort`는 정렬, `uniq -c`는 연속된 같은 값의 개수를 셉니다. |
| <code>cat output/group-count.txt</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `|` | 앞 명령의 표준 출력을 뒤 명령의 입력으로 전달합니다. 오류 메시지는 자동으로 전달되지 않습니다. |

</details>

기대 결과는 A 2개, B 1개입니다. 각 명령을 따로 실행해 어느 단계에서 모양이 바뀌는지 확인합니다. `uniq`는 연속한 같은 줄을 묶으므로 먼저 정렬합니다.

## 짧은 실습 · 성공한 결과만 최종 파일로 저장하기
```bash
if awk -F '\t' 'NR>1 {sum+=$3} END {print sum}' input/samples.tsv > scratch/total.tmp 2> logs/total.log; then
  mv scratch/total.tmp output/total.txt
else
  printf '작업 실패: logs/total.log 확인\n' >&2
fi
cat output/total.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>if awk -F &#x27;\t&#x27; &#x27;NR&gt;1 {sum+=$3} END {print sum}&#x27; input/samples.tsv &gt; scratch/total.tmp 2&gt; logs/total.log; then</code> | 탭으로 구분된 표를 처리합니다. `-F`는 구분자, `NR>1`은 헤더 이후 행, `$2`·`$3`은 두 번째·세 번째 열, `sum+=`는 합산, `END`는 모두 읽은 뒤 실행입니다. `sort`는 정렬, `uniq -c`는 연속된 같은 값의 개수를 셉니다. |
| <code>mv scratch/total.tmp output/total.txt</code> | 첫 번째 파일을 두 번째 경로로 옮기거나 이름을 바꿉니다. 이 예제는 성공한 임시 결과를 최종 결과 파일로 옮깁니다. |
| <code>else</code> | `else`는 앞 조건이 실패했을 때 실행할 부분, `fi`는 if 조건문의 끝입니다. |
| <code>printf &#x27;작업 실패: logs/total.log 확인\n&#x27; &gt;&amp;2</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>fi</code> | `else`는 앞 조건이 실패했을 때 실행할 부분, `fi`는 if 조건문의 끝입니다. |
| <code>cat output/total.txt</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |

</details>

기대 합계는 60입니다. 작업 명령이 성공했을 때만 임시 결과를 최종 경로로 옮깁니다. 이 예제는 명령 실패에 대한 기본 패턴이며 데이터 내용의 타당성까지 자동 보장하지 않습니다. 기존 total.txt가 있다면 성공한 새 결과로 교체됩니다.

## 확인 질문
`wc -l`이 0을 출력했는데 파이프 앞의 `cat`은 실패할 수 있나요? `>`와 `>>`를 바꿔 쓰면 어떤 문제가 생길까요?
<details><summary>해설 보기</summary>
가능합니다. pipefail과 오류 로그를 확인합니다. >는 덮어쓰고 >>는 이어 쓰므로 재실행 때 기존 결과를 지우거나 중복으로 누적할 수 있습니다.
</details>

복습: [기존 교재의 셸 스크립트](https://seondh.github.io/bio_linux/day2/chapter10/).


</details>

<details markdown="1"><summary>05 서버 저장공간 이해와 관리 · 자세한 설명</summary>

# 05 서버 저장공간 이해와 관리

**실행 위치:** `course-linux` 컨테이너의 Bash. 아래 관찰은 컨테이너가 볼 수 있는 파일시스템 기준입니다. 실제 서버의 마운트 구조는 사례와 함께 비교합니다.

**목표:** 폴더 이름이 아닌 파일시스템을 기준으로 저장 위치를 확인합니다.

## 서버를 네 가지 자원으로 보기
CPU는 계산, 메모리는 실행 중 데이터, 디스크는 지속 저장, 네트워크는 다른 장치와의 전송을 맡습니다. 디스크가 크다고 메모리가 늘지는 않습니다. 원격 서버에서 실행한 명령은 원격 장치의 경로와 자원을 사용합니다.

## `/data`라는 이름만으로 별도 디스크가 되지 않습니다
마운트는 저장 장치를 디렉터리에 연결하는 것입니다. 별도 장치가 연결되지 않았다면 `/data`에 저장해도 루트 파일시스템을 사용할 수 있습니다. 홈 디렉터리 또한 별도 파일시스템인지 확인해야 합니다.
```bash
cd "$HOME/linux-server-lab"
df -h .
df -h / "$HOME"
du -sh input output logs scratch
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>df -h .</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>df -h / &quot;$HOME&quot;</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>du -sh input output logs scratch</code> | 지정한 폴더나 파일이 차지하는 공간을 봅니다. `-s`는 각 대상의 합계, `-h`는 읽기 쉬운 단위입니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

Linux에서는 다음으로 경로의 마운트 정보를 확인합니다.
```bash
findmnt -T "$HOME/linux-server-lab"
lsblk -f
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>findmnt -T &quot;$HOME/linux-server-lab&quot;</code> | `-T` 뒤 경로가 어느 파일시스템에 연결되어 있는지 확인합니다. 폴더 이름만으로 저장 장치를 판단하지 않습니다. |
| <code>lsblk -f</code> | 디스크 같은 블록 장치 목록을 보여줍니다. `-f`는 파일시스템 정보를 포함합니다. 컨테이너에서는 실제 서버의 장치가 모두 보이지 않을 수 있습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

`df`는 파일시스템 전체, `du`는 접근 가능한 파일의 사용량을 보여줍니다. 다른 사용자의 파일을 읽지 못하면 `du`가 전체를 설명하지 못합니다.

## 이번 교육에서는 마운트 개념만 이해합니다
마운트는 파일시스템을 특정 디렉터리에서 사용할 수 있도록 연결하는 것입니다. 예를 들어 별도 저장 장치를 `/data`에 연결하면 그 경로로 장치의 파일에 접근합니다. 연결하지 않고 `/data` 폴더만 만들면 기존 파일시스템의 공간을 사용합니다.

이번 수업에서는 PC 디스크의 파티션 변경이나 `mount`·`umount` 실습을 진행하지 않습니다. 서버의 별도 저장 장치 연결은 사례로 설명하고, `df`와 `findmnt`로 현재 경로의 저장 위치를 확인합니다. 컨테이너에서 보이는 마운트 정보는 실제 서버의 전체 디스크 구성을 보여주는 것은 아닙니다.

Docker의 bind mount는 기존 폴더를 컨테이너에 연결하는 기능입니다. [7장](07-docker-practice.html#local-mount)에서 PC와 컨테이너가 같은 파일을 보는 것만 실습합니다. 이것은 PC 디스크를 나누거나 새로운 저장 장치를 추가하는 작업과 다릅니다.

## 디스크 부족의 두 가지 형태
```bash
df -h .
df -i .
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>df -h .</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>df -i .</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |

</details>

용량이 남아도 작은 파일이 매우 많아 inode가 소진될 수 있습니다. 사용자 quota, 임시 경로, 읽기 전용 마운트도 별도로 확인합니다. `df`와 `du`가 크게 다르면 삭제됐지만 프로세스가 열고 있는 파일 등도 관리자와 조사합니다.

## 사례: 입력은 `/data`, Docker는 `/`
| 위치 | 실제 사용처 | 관찰 |
|---|---|---|
| `/data/user/input` | 별도 대용량 장치 | 여유 800 GB |
| `/home/user` | 루트 파일시스템 | 여유 1 GB |
| Docker 저장 영역 | 설정된 엔진 저장 장치 | 이미지·로그 누적 |
| `/tmp` | 환경에 따라 디스크 또는 메모리 | 임시 파일 누적 |

대용량 입력을 `/data`에 둬도 Docker 이미지와 로그가 자동으로 이동하지 않습니다. 경로별 파일시스템을 따로 확인해야 합니다.

## 작은 파일로 관찰하기
```bash
printf 'temporary example\n' > scratch/example.tmp
du -sh scratch
ls -lh scratch/example.tmp
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>printf &#x27;temporary example\n&#x27; &gt; scratch/example.tmp</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>du -sh scratch</code> | 지정한 폴더나 파일이 차지하는 공간을 봅니다. `-s`는 각 대상의 합계, `-h`는 읽기 쉬운 단위입니다. |
| <code>ls -lh scratch/example.tmp</code> | 파일이나 폴더를 확인합니다. `-l`은 권한·소유자 등 상세 정보, `-d`는 폴더 내부 대신 폴더 자체, `-h`는 크기를 읽기 쉬운 단위로 보여줍니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |

</details>

작업 전에 입력, 출력, 로그, 임시 파일 경로와 예상 크기를 기록합니다. 도구가 지원하면 임시 경로 옵션 또는 `TMPDIR`을 지정하되, 실제로 그 설정을 사용하는지도 확인합니다.

## Docker가 루트를 채우는 이유
```bash
docker info --format '{{.DockerRootDir}}'
docker system df
docker system df -v
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker info --format &#x27;{{.DockerRootDir}}&#x27;</code> | 현재 Docker 엔진의 정보를 조회합니다. DockerRootDir은 엔진의 데이터 경로이며 저장 방식에 따라 이미지가 다른 곳에 있을 수도 있습니다. |
| <code>docker system df</code> | 이미지·컨테이너·볼륨·빌드 캐시의 공간 사용을 보여줍니다. `-v`는 자세한 내역입니다. |
| <code>docker system df -v</code> | 이미지·컨테이너·볼륨·빌드 캐시의 공간 사용을 보여줍니다. `-v`는 자세한 내역입니다. |

</details>

Docker의 이미지, 쓰기 계층, 볼륨, 빌드 캐시, 로그는 저장 위치와 수명이 다릅니다. `docker system df`만으로 로그를 포함한 디스크 전체 사용량을 설명할 수 없습니다.

Linux Engine의 기존 저장 방식은 보통 `/var/lib/docker`를 사용합니다. 새 Engine 29 이상 설치의 containerd image store에서는 이미지와 스냅샷이 `/var/lib/containerd`에 있을 수 있습니다. **`data-root` 변경만으로 모든 데이터가 이동한다고 가정하지 않습니다.** Docker Desktop은 VM 디스크 위치를 설정 화면에서 확인합니다. 실제 서버의 저장 위치 변경은 관리자가 작업 중단과 이전 계획을 세워 수행합니다.

## 정리 전에 세 가지 확인
대상이 누구의 것인지, 다시 만들 수 있는지, 보존할 결과가 있는지 확인합니다. 공용 엔진에서 일괄 prune을 수강생이 실행하지 않습니다. `--rm`이어도 이미지와 명시적으로 만든 named volume은 남습니다.

참고: [Docker 저장 설정](https://docs.docker.com/engine/daemon/), [저장공간 정리](https://docs.docker.com/engine/manage-resources/pruning/).

## 확인 질문
“`/data` 폴더를 만들었으니 루트 공간을 쓰지 않는다”는 말의 문제를 설명하세요. 결과 200 GB를 저장하려면 어느 명령으로 대상 파일시스템의 여유를 확인할까요?

<details><summary>해설 보기</summary>
폴더 생성은 마운트가 아닙니다. Linux의 findmnt -T로 연결을 확인하고 df -h 대상경로로 여유 공간을 확인합니다. 예상 출력뿐 아니라 임시 파일과 quota도 고려합니다.
</details>

## 짧은 실습 · 입력·출력·로그의 사용량 비교
**10분 · 컨테이너 안.** 실제 디스크를 가득 채우지 않고 1 MiB 파일 하나로 관찰합니다.
```bash
cd "$HOME/linux-server-lab"
df -h .
du -sh input output logs scratch
dd if=/dev/zero of=scratch/storage-demo.bin bs=1024 count=1024
ls -lh scratch/storage-demo.bin
du -sh scratch
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>df -h .</code> | 지정한 경로가 사용하는 파일시스템의 상태를 봅니다. `-h`는 전체·사용·남은 용량, `-i`는 파일·폴더를 관리하는 inode의 전체·남은 개수를 보여줍니다. |
| <code>du -sh input output logs scratch</code> | 지정한 폴더나 파일이 차지하는 공간을 봅니다. `-s`는 각 대상의 합계, `-h`는 읽기 쉬운 단위입니다. |
| <code>dd if=/dev/zero of=scratch/storage-demo.bin bs=1024 count=1024</code> | 예제 데이터를 파일로 씁니다. `if=/dev/zero`는 0으로 채운 입력, `of=`는 출력 파일, `bs=`는 한 번에 쓸 크기, `count=`는 반복 횟수입니다. `bs=1M count=12`는 12MiB 쓰기 시도입니다. |
| <code>ls -lh scratch/storage-demo.bin</code> | 파일이나 폴더를 확인합니다. `-l`은 권한·소유자 등 상세 정보, `-d`는 폴더 내부 대신 폴더 자체, `-h`는 크기를 읽기 쉬운 단위로 보여줍니다. |
| <code>du -sh scratch</code> | 지정한 폴더나 파일이 차지하는 공간을 봅니다. `-s`는 각 대상의 합계, `-h`는 읽기 쉬운 단위입니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

이름이 같은 실습 파일이 있으면 덮어씁니다. 파일의 목적과 크기를 확인한 뒤 **방금 만든 파일만** 삭제합니다.
```bash
rm -i scratch/storage-demo.bin
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>rm -i scratch/storage-demo.bin</code> | 지정한 파일을 삭제합니다. `-i`가 있으면 삭제 전에 확인을 요청합니다. 이번 실습에서 만든 파일만 대상으로 합니다. |

</details>

질문에 y로 답하면 삭제됩니다. 다시 du를 확인하세요. 실제 서버에서는 공동 데이터나 Docker 저장 폴더를 직접 삭제하지 않습니다.

## 로그가 계속 늘어나는 경우
명령이 표준 출력에 많은 내용을 내면 Docker 로그도 쌓일 수 있습니다. 출력 폴더를 큰 디스크에 연결했다고 이미지·로그까지 이동한 것은 아닙니다. 로그 보관과 회전 설정은 별도로 확인합니다.

**호스트 Bash · 선택 관찰:**
```bash
docker run --name course-log-demo --log-driver=json-file --log-opt max-size=1m --log-opt max-file=2 alpine:3.21 sh -c 'echo first; echo second'
docker logs course-log-demo
docker inspect course-log-demo --format '{{json .HostConfig.LogConfig}}'
docker rm course-log-demo
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --name course-log-demo --log-driver=json-file --log-opt max-size=1m --log-opt max-file=2 alpine:3.21 sh -c &#x27;echo first; echo second&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker logs course-log-demo</code> | 지정한 컨테이너의 표준 출력·오류 로그를 봅니다. `--tail 50`은 마지막 50줄입니다. |
| <code>docker inspect course-log-demo --format &#x27;{{json .HostConfig.LogConfig}}&#x27;</code> | 컨테이너 설정·상태를 조회합니다. `--format`은 필요한 항목만 출력합니다. Mounts는 폴더 연결, ExitCode는 종료 상태, OOMKilled는 메모리 부족 종료 여부, HostConfig.Memory는 RAM 한도(바이트), NanoCpus는 CPU 시간 한도(1 CPU = 1000000000)입니다. |
| <code>docker rm course-log-demo</code> | 지정한 컨테이너를 삭제합니다. 내부에만 저장한 파일도 없어지지만 이미지와 연결한 외부 폴더는 삭제하지 않습니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `--log-driver / --log-opt` | 로그 저장 방식과 정책입니다. json-file은 파일 형식, max-size는 파일당 한도, max-file은 유지할 파일 수입니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

작은 출력만 만들어 로그 설정을 관찰합니다. 실제 큰 로그를 만들지는 않습니다. 새 컨테이너에 설정한 로그 정책이며 기존 컨테이너가 자동 변경되는 것은 아닙니다.

복습: [기존 Docker 교재](https://seondh.github.io/bio_linux/day5/chapter22/).


</details>

<details markdown="1"><summary>06 프로세스와 자원 관리 · 자세한 설명</summary>

# 06 프로세스와 자원 관리

**목표:** 자신의 작업만 찾아 관찰·종료하고 공유 서버의 자원 사용 습관을 익힙니다.
**실행 위치:** `course-linux` 컨테이너의 Bash.
```bash
cd "$HOME/linux-server-lab"
mkdir -p logs
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p logs</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>


## 프로그램과 프로세스
프로그램은 실행할 코드이고 프로세스는 실행 중인 인스턴스입니다. PID는 프로세스 번호, 부모 프로세스는 실행을 시작한 프로세스입니다. 터미널의 작업 번호와 PID는 서로 다릅니다.
```bash
sleep 300 > logs/sleep.log 2>&1 &
lab_pid=$!
printf '내 실습 PID=%s\n' "$lab_pid"
jobs -l
ps -p "$lab_pid" -o pid,ppid,stat,etime,command
kill -TERM "$lab_pid"
wait "$lab_pid"
echo "$?"
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>sleep 300 &gt; logs/sleep.log 2&gt;&amp;1 &amp;</code> | 지정한 초만큼 기다립니다. 계산 부하를 만드는 프로그램이 아니라, 실행·정지 상태를 연습하는 작은 대기 작업입니다. |
| <code>lab_pid=$!</code> | 등호 왼쪽의 변수 이름에 오른쪽 값을 저장합니다. `$!`는 방금 시작한 백그라운드 작업의 PID, `$?`는 바로 앞 명령의 종료 상태입니다. |
| <code>printf &#x27;내 실습 PID=%s\n&#x27; &quot;$lab_pid&quot;</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| <code>jobs -l</code> | 현재 셸에서 시작한 작업을 보여줍니다. `-l`은 PID도 표시합니다. |
| <code>ps -p &quot;$lab_pid&quot; -o pid,ppid,stat,etime,command</code> | 프로세스를 확인합니다. `-p` 뒤는 확인할 PID, `-o` 뒤는 표시할 항목입니다. pid는 번호, ppid는 부모 번호, stat는 상태, etime은 경과 시간, command는 실행 명령입니다. `$$`는 현재 셸의 PID입니다. |
| <code>kill -TERM &quot;$lab_pid&quot;</code> | `-TERM`으로 지정한 PID에 종료를 요청합니다. 저장해 둔 자신의 실습 PID와 명령을 확인한 뒤 실행합니다. |
| <code>wait &quot;$lab_pid&quot;</code> | 해당 백그라운드 작업이 끝날 때까지 기다리고 종료 상태를 전달합니다. TERM으로 종료한 작업은 0이 아닌 상태일 수 있습니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| `2>&1` | 표준 오류도 현재 표준 출력과 같은 곳으로 보냅니다. 로그 하나에 결과와 오류를 함께 남깁니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `&` | 작업을 백그라운드로 시작하고 다음 명령을 입력할 수 있게 합니다. |
| `sleep 초` | 지정한 시간 동안 기다리는 작업입니다. |

</details>

종료 신호로 끝났으므로 `wait`가 0이 아닌 값을 반환할 수 있습니다. 새 터미널의 `jobs`에는 이전 터미널의 작업 목록이 없습니다. 자신의 PID와 명령을 확인하고 TERM으로 정상 종료를 요청합니다. 종료되지 않는 이유를 조사한 뒤 KILL을 검토합니다.

## 멈춤·백그라운드·종료 구분
`Ctrl+C`는 전경 작업에 중단 신호를 보내고, `Ctrl+Z`는 일시 정지합니다. `bg`는 계속 실행, `fg`는 전경으로 복귀합니다. SSH 연결 종료 후에도 유지해야 하는 작업은 서버의 스케줄러 또는 승인된 실행 방식을 사용합니다.


## 짧은 실습 · 로그가 변하면 작업이 진행 중일까요?
**10분.** 5초 동안 매초 한 줄을 쓰는 작은 작업입니다.
```bash
(for step in 1 2 3 4 5; do printf 'step=%s\n' "$step"; sleep 1; done) > logs/progress.log 2>&1 &
progress_pid=$!
ps -p "$progress_pid" -o pid,ppid,stat,etime,command
tail -f logs/progress.log
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>(for step in 1 2 3 4 5; do printf &#x27;step=%s\n&#x27; &quot;$step&quot;; sleep 1; done) &gt; logs/progress.log 2&gt;&amp;1 &amp;</code> | 1부터 5까지 반복하며 진행 번호를 출력하고 매번 1초 기다립니다. 괄호는 별도 셸에서 실행하고, 전체 진행 내용을 로그로 남깁니다. |
| <code>progress_pid=$!</code> | 등호 왼쪽의 변수 이름에 오른쪽 값을 저장합니다. `$!`는 방금 시작한 백그라운드 작업의 PID, `$?`는 바로 앞 명령의 종료 상태입니다. |
| <code>ps -p &quot;$progress_pid&quot; -o pid,ppid,stat,etime,command</code> | 프로세스를 확인합니다. `-p` 뒤는 확인할 PID, `-o` 뒤는 표시할 항목입니다. pid는 번호, ppid는 부모 번호, stat는 상태, etime은 경과 시간, command는 실행 명령입니다. `$$`는 현재 셸의 PID입니다. |
| <code>tail -f logs/progress.log</code> | 파일의 마지막 부분을 봅니다. `-n 2`는 마지막 두 줄, `-f`는 새로 추가되는 내용을 계속 보여줍니다. `-f` 관찰은 Ctrl+C로 끝냅니다. |
| `2>&1` | 표준 오류도 현재 표준 출력과 같은 곳으로 보냅니다. 로그 하나에 결과와 오류를 함께 남깁니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `&` | 작업을 백그라운드로 시작하고 다음 명령을 입력할 수 있게 합니다. |
| `sleep 초` | 지정한 시간 동안 기다리는 작업입니다. |

</details>

마지막 줄을 확인한 뒤 Ctrl+C로 **tail 관찰만** 종료합니다. 이어서 같은 셸에서 실행합니다.
```bash
wait "$progress_pid"
echo "$?"
cat logs/progress.log
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>wait &quot;$progress_pid&quot;</code> | 해당 백그라운드 작업이 끝날 때까지 기다리고 종료 상태를 전달합니다. TERM으로 종료한 작업은 0이 아닌 상태일 수 있습니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| <code>cat logs/progress.log</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |

</details>

종료 상태 0과 5개 단계가 기대됩니다. 로그가 조용하다는 이유만으로 멈췄다고 단정하지 않습니다. 프로그램에 따라 출력이 버퍼에 모였다가 나타날 수 있습니다.

## CPU·메모리 관찰
```bash
top
free -h
vmstat 1 5
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>top</code> | 실행 중인 프로그램과 자원 상태를 계속 보여줍니다. q로 관찰을 종료합니다. 프로그램 자체를 종료하는 것은 아닙니다. |
| <code>free -h</code> | 메모리 상태를 봅니다. `-h`는 읽기 쉬운 단위이며, 컨테이너별 메모리 한도와는 다를 수 있습니다. |
| <code>vmstat 1 5</code> | 메모리·CPU·I/O 상태를 관찰합니다. `1 5`는 1초 간격으로 다섯 번 출력하라는 뜻입니다. |

</details>

`top`은 q로 종료합니다. CPU 사용률, 메모리 available, swap과 I/O 대기를 함께 봅니다. 컨테이너가 보는 정보와 실제 한도가 다를 수 있습니다.

## 짧은 실습 · Docker 자원 설정 확인
**호스트 Bash에서 실행합니다.** CPU를 바쁘게 만드는 대신 제한 설정만 관찰합니다.
```bash
docker run -d --name course-resource-demo --cpus=1 --memory=128m alpine:3.21 sleep 60
docker stats --no-stream course-resource-demo
docker inspect course-resource-demo --format 'NanoCPUs={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}'
docker stop course-resource-demo
docker rm course-resource-demo
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run -d --name course-resource-demo --cpus=1 --memory=128m alpine:3.21 sleep 60</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker stats --no-stream course-resource-demo</code> | 컨테이너별 CPU·메모리 사용량과 한도를 관찰합니다. `--no-stream`은 한 번만 출력합니다. 연속 관찰은 Ctrl+C로 마칩니다. |
| <code>docker inspect course-resource-demo --format &#x27;NanoCPUs={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}&#x27;</code> | 컨테이너 설정·상태를 조회합니다. `--format`은 필요한 항목만 출력합니다. Mounts는 폴더 연결, ExitCode는 종료 상태, OOMKilled는 메모리 부족 종료 여부, HostConfig.Memory는 RAM 한도(바이트), NanoCpus는 CPU 시간 한도(1 CPU = 1000000000)입니다. |
| <code>docker stop course-resource-demo</code> | 지정한 컨테이너의 주 작업에 종료를 요청하고 기다립니다. 종료되지 않으면 강제 종료할 수 있습니다. 컨테이너 자체를 삭제하지는 않습니다. |
| <code>docker rm course-resource-demo</code> | 지정한 컨테이너를 삭제합니다. 내부에만 저장한 파일도 없어지지만 이미지와 연결한 외부 폴더는 삭제하지 않습니다. |
| `-d` | 백그라운드로 실행합니다. 처음에는 작업 결과 대신 컨테이너 ID가 보입니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `--cpus` | CPU 한 개 기준의 시간 한도입니다. 0.25는 25%, 1은 CPU 하나 분량이며 전용 CPU 예약이 아닙니다. |
| `--memory` | 컨테이너 RAM 사용 한도입니다. m은 MiB 단위이고, 실제 사용량이 항상 한도만큼인 것은 아닙니다. |
| `sleep 초` | 지정한 시간 동안 기다리는 작업입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

NanoCPUs는 1000000000, Memory는 134217728 바이트가 기대됩니다. `sleep`은 대부분 CPU를 쓰지 않습니다. 제한은 예약된 전용 코어나 일정한 실제 사용량이라는 뜻이 아닙니다.

## 공유 서버에서 다른 사용자와 함께 작업하기
작은 데이터로 명령을 먼저 검증하고, 분석 도구의 스레드 옵션을 지정합니다. 사용할 수 있는 자원은 보이는 CPU 수가 아니라 관리자·스케줄러가 할당한 범위입니다. 자신의 PID와 명령을 확인한 뒤 TERM 신호로 정상 종료를 요청합니다. `kill -9`부터 실행하지 않습니다.

긴 작업은 기관의 스케줄러나 승인된 실행 방식을 사용합니다. 백그라운드 실행만으로 SSH 연결 종료 후 유지가 보장되지는 않습니다. nice는 CPU 우선순위이며 메모리 제한이 아닙니다.

## 확인 질문
컨테이너가 137로 종료하면 언제나 메모리 부족인가요? 다른 사용자의 프로세스를 종료하면 왜 안 되나요?
<details><summary>해설 보기</summary>
137은 통상 SIGKILL에 대응하지만 원인은 OOM 또는 외부 종료 등 여러 가지입니다. OOMKilled와 로그, 관리자 증거를 확인합니다. 다른 사용자의 작업은 영향을 평가할 수 없으므로 관리자와 협의합니다.
</details>

복습: [기존 프로세스 관리 교재](https://seondh.github.io/bio_linux/day3/chapter12/), [기존 ps 실습](https://seondh.github.io/bio_linux/day3/chapter12/training/ps.html).


</details>

<details markdown="1"><summary>07 Docker 실무 활용과 파일 연결 · 자세한 설명</summary>

# 07 Docker 실무 활용과 파일 연결

**실행 위치:** 호스트 Bash. Windows는 WSL Ubuntu, Mac은 터미널의 Bash입니다. `course-linux` 안에서 Docker를 실행하지 않습니다.

**목표:** 입력은 읽기 전용으로 연결하고 결과를 호스트에 남깁니다.

## 로컬 마운트 실습: 같은 파일을 두 경로에서 보기 {#local-mount}
Windows의 WSL Ubuntu 또는 Mac 터미널의 **호스트 Bash**에서 진행합니다. 00장의 `course-linux` 안에 있다면 먼저 `exit`로 나옵니다.

### 1. PC에서 파일 만들기
```bash
cd "$HOME/linux-server-lab"
mkdir -p mount-demo
printf 'created on host\n' > mount-demo/host.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p mount-demo</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| <code>printf &#x27;created on host\n&#x27; &gt; mount-demo/host.txt</code> | 지정한 형식으로 글자를 출력합니다. `\n`은 줄바꿈, `\t`는 탭, `%s`는 뒤에 전달한 값을 넣는 자리입니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

이 명령을 다시 실행하면 실습용 `host.txt`를 덮어씁니다.

### 2. 컨테이너에서 읽고, 새 파일 쓰기
```bash
docker run --rm \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$PWD/mount-demo,dst=/shared" \
  alpine:3.21 sh -c \
  'cat /shared/host.txt; printf "created in container\n" > /shared/container.txt'
cat mount-demo/container.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --rm  --user &quot;$(id -u):$(id -g)&quot;  --mount &quot;type=bind,src=$PWD/mount-demo,dst=/shared&quot;  alpine:3.21 sh -c  &#x27;cat /shared/host.txt; printf &quot;created in container\n&quot; &gt; /shared/container.txt&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>cat mount-demo/container.txt</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `--user "$(id -u):$(id -g)"` | 호스트의 사용자 번호와 그룹 번호로 실행합니다. id -u는 사용자 ID, id -g는 그룹 ID이며 $(...)는 명령 결과를 넣습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

기대 출력은 `created on host`, 이어서 `created in container`입니다. PC의 `mount-demo`와 컨테이너의 `/shared`는 연결된 파일을 봅니다. 복사본을 만들어 수정한 것이 아닙니다. `--rm`으로 컨테이너가 삭제되어도 PC 파일은 남습니다. 반대로 쓰기 가능한 연결 안의 파일을 삭제하면 PC에서도 삭제되므로 개인 실습 폴더만 연결합니다.

### 3. 연결 정보를 확인하기
```bash
docker run -d --name course-mount-view \
  --mount "type=bind,src=$PWD/mount-demo,dst=/shared,readonly" \
  alpine:3.21 sleep 300
docker inspect course-mount-view --format '{{json .Mounts}}'
docker exec course-mount-view cat /shared/container.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run -d --name course-mount-view  --mount &quot;type=bind,src=$PWD/mount-demo,dst=/shared,readonly&quot;  alpine:3.21 sleep 300</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker inspect course-mount-view --format &#x27;{{json .Mounts}}&#x27;</code> | 컨테이너 설정·상태를 조회합니다. `--format`은 필요한 항목만 출력합니다. Mounts는 폴더 연결, ExitCode는 종료 상태, OOMKilled는 메모리 부족 종료 여부, HostConfig.Memory는 RAM 한도(바이트), NanoCpus는 CPU 시간 한도(1 CPU = 1000000000)입니다. |
| <code>docker exec course-mount-view cat /shared/container.txt</code> | 현재 실행 중인 컨테이너 안에서 추가 명령을 실행합니다. 정지한 컨테이너에서는 실패합니다. |
| `-d` | 백그라운드로 실행합니다. 처음에는 작업 결과 대신 컨테이너 ID가 보입니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `sleep 초` | 지정한 시간 동안 기다리는 작업입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

Mounts의 `Type=bind`, `Source`, `Destination=/shared`, `RW=false`를 찾습니다. Source 표시는 Desktop·WSL의 경로 변환에 따라 다를 수 있습니다. 내용을 확인한 뒤 **방금 만든 실습 컨테이너만** 정리합니다.
```bash
docker stop course-mount-view
docker rm course-mount-view
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker stop course-mount-view</code> | 지정한 컨테이너의 주 작업에 종료를 요청하고 기다립니다. 종료되지 않으면 강제 종료할 수 있습니다. 컨테이너 자체를 삭제하지는 않습니다. |
| <code>docker rm course-mount-view</code> | 지정한 컨테이너를 삭제합니다. 내부에만 저장한 파일도 없어지지만 이미지와 연결한 외부 폴더는 삭제하지 않습니다. |

</details>

같은 이름 충돌이 나면 기존 실습 컨테이너가 남았는지 먼저 확인합니다. 작업 결과는 `mount-demo`에 계속 남습니다.

### 정리 질문
bind mount가 PC 디스크의 용량을 늘리는지, 컨테이너를 삭제한 뒤에도 연결 폴더의 파일이 남는지 설명하세요.

<details><summary>해설 보기</summary>
bind mount는 기존 저장 위치를 다른 경로에서 접근하게 합니다. 새 저장공간이 생기는 것은 아닙니다. 호스트 폴더의 결과는 컨테이너를 삭제해도 남습니다.
</details>

## 호스트와 컨테이너 경로
호스트의 `input`을 컨테이너의 `/input`, 호스트의 `output`을 `/output`에 연결합니다. 경로 이름이 같을 필요는 없습니다. `--mount`는 호스트 원본 폴더가 없으면 오류를 내므로 오타를 발견하기 좋습니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p output
docker run --rm --name course-count \
  --cpus=1 --memory=256m \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output,dst=/output" \
  alpine:3.21 sh -c \
  'awk -F "\t" "NR>1 {sum+=\$3; n++} END {print \"samples\t\" n; print \"total\t\" sum}" /input/samples.tsv > /output/summary.tsv'
cat output/summary.tsv
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p output</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| <code>docker run --rm --name course-count  --cpus=1 --memory=256m  --user &quot;$(id -u):$(id -g)&quot;  --mount &quot;type=bind,src=$PWD/input,dst=/input,readonly&quot;  --mount &quot;type=bind,src=$PWD/output,dst=/output&quot;  alpine:3.21 sh -c  &#x27;awk -F &quot;\t&quot; &quot;NR&gt;1 {sum+=\$3; n++} END {print \&quot;samples\t\&quot; n; print \&quot;total\t\&quot; sum}&quot; /input/samples.tsv &gt; /output/summary.tsv&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>cat output/summary.tsv</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `--cpus` | CPU 한 개 기준의 시간 한도입니다. 0.25는 25%, 1은 CPU 하나 분량이며 전용 CPU 예약이 아닙니다. |
| `--memory` | 컨테이너 RAM 사용 한도입니다. m은 MiB 단위이고, 실제 사용량이 항상 한도만큼인 것은 아닙니다. |
| `--user "$(id -u):$(id -g)"` | 호스트의 사용자 번호와 그룹 번호로 실행합니다. id -u는 사용자 ID, id -g는 그룹 ID이며 $(...)는 명령 결과를 넣습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

기대 결과는 `samples 3`, `total 60`이며 구분자는 탭입니다. 컨테이너가 삭제되어도 호스트 결과는 남습니다. `--user`는 Linux에서 root 소유 결과가 생기는 문제를 줄입니다. 호스트 출력 폴더에 해당 UID/GID가 쓸 수 있어야 합니다.

## 읽기 전용 입력 확인
```bash
docker run --rm \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  alpine:3.21 sh -c 'echo test > /input/new.txt'
echo "$?"
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --rm  --mount &quot;type=bind,src=$PWD/input,dst=/input,readonly&quot;  alpine:3.21 sh -c &#x27;echo test &gt; /input/new.txt&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `echo 글자` | 컨테이너 안에서 지정한 글자를 출력합니다. >가 있으면 그 출력을 파일에 저장합니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

읽기 전용 파일시스템 오류가 기대됩니다. 이것은 입력을 보호하기 위해 설정한 정상적인 제한입니다.

## 컨테이너 안에만 저장하면?
```bash
docker run --name course-local alpine:3.21 sh -c 'echo inside > /tmp/result.txt'
docker cp course-local:/tmp/result.txt output/copied.txt
cat output/copied.txt
docker rm course-local
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --name course-local alpine:3.21 sh -c &#x27;echo inside &gt; /tmp/result.txt&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker cp course-local:/tmp/result.txt output/copied.txt</code> | 컨테이너이름:내부경로의 파일을 호스트의 뒤쪽 경로로 복사합니다. 정지한 컨테이너도 삭제 전에는 회수할 수 있습니다. |
| <code>cat output/copied.txt</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>docker rm course-local</code> | 지정한 컨테이너를 삭제합니다. 내부에만 저장한 파일도 없어지지만 이미지와 연결한 외부 폴더는 삭제하지 않습니다. |
| `--name` | 바로 뒤의 이름을 컨테이너에 붙입니다. 같은 이름은 중복 사용할 수 없습니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `echo 글자` | 컨테이너 안에서 지정한 글자를 출력합니다. >가 있으면 그 출력을 파일에 저장합니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

정지 컨테이너의 파일도 삭제 전에는 복사할 수 있습니다. `--rm`으로 지우면 이 방법을 쓸 수 없으므로 결과 경로를 실행 전에 정합니다.

## volume 관찰: 선택 실습
```bash
docker volume create course-demo-volume
docker run --rm --mount type=volume,src=course-demo-volume,dst=/store alpine:3.21 sh -c 'echo persistent > /store/note.txt'
docker run --rm --mount type=volume,src=course-demo-volume,dst=/store alpine:3.21 cat /store/note.txt
docker volume inspect course-demo-volume
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker volume create course-demo-volume</code> | Docker가 관리하는 이름 있는 별도 저장공간을 만듭니다. |
| <code>docker run --rm --mount type=volume,src=course-demo-volume,dst=/store alpine:3.21 sh -c &#x27;echo persistent &gt; /store/note.txt&#x27;</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker run --rm --mount type=volume,src=course-demo-volume,dst=/store alpine:3.21 cat /store/note.txt</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>docker volume inspect course-demo-volume</code> | 지정한 볼륨의 설정과 저장 정보를 확인합니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `echo 글자` | 컨테이너 안에서 지정한 글자를 출력합니다. >가 있으면 그 출력을 파일에 저장합니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>

볼륨에는 결과가 남습니다. 이 실습에서 만든 보관함을 더 이상 쓰지 않는 것을 확인한 뒤 `docker volume rm course-demo-volume`으로 삭제합니다. 볼륨의 저장 위치 역시 대용량 스토리지로 자동 선택되지 않습니다.

## 실행 전후 체크
실행 전: 이미지 버전, 입력 경로, 출력 권한, 자원 제한. 실행 후: 종료 상태, 결과 내용, 소유권, 남은 컨테이너와 볼륨. 태그는 변경될 수 있으므로 실제 업무에서는 이미지 digest와 명령도 기록합니다.

참고: [Docker bind mounts](https://docs.docker.com/engine/storage/bind-mounts/), [volumes](https://docs.docker.com/engine/storage/volumes/).

## 짧은 실습 · 셸 스크립트를 이미지에 넣기
**15분 · 호스트 Bash.** 기존 교재의 Docker 배치 실습을 작은 텍스트 처리로 단순화했습니다. 분석 프로그램 대신 줄 수만 세어 환경과 파일 연결에 집중합니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p build-demo
cat > build-demo/count.sh <<'SCRIPT'
#!/bin/sh
set -eu
wc -l /input/samples.tsv > /output/line-count.txt
SCRIPT
cat > build-demo/Dockerfile <<'DOCKERFILE'
FROM alpine:3.21
COPY count.sh /usr/local/bin/count.sh
ENTRYPOINT ["sh", "/usr/local/bin/count.sh"]
DOCKERFILE
docker build -t course-count:1 build-demo
docker run --rm --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$PWD/input,dst=/input,readonly" \
  --mount "type=bind,src=$PWD/output,dst=/output" \
  course-count:1
cat output/line-count.txt
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>mkdir -p build-demo</code> | 뒤에 적힌 폴더들을 만듭니다. `-p`는 상위 폴더도 만들고, 이미 있는 폴더는 그대로 사용합니다. |
| <code>cat &gt; build-demo/count.sh &lt;&lt;&#x27;SCRIPT&#x27;</code> | 지정한 파일에 아래의 여러 줄을 저장합니다. `<<` 뒤의 종료 표시가 나올 때까지가 파일 내용입니다. 같은 파일은 덮어씁니다. |
| <code>#!/bin/sh</code> | 이 파일을 실행할 셸을 지정하는 첫 줄입니다. `/bin/sh`는 sh, `/usr/bin/env bash`는 PATH에서 찾은 Bash를 사용합니다. |
| <code>set -eu</code> | `-o pipefail`은 파이프 앞 단계의 실패도 종료 상태에 반영하고, `+o pipefail`은 그 설정을 해제합니다. `-e`는 처리되지 않은 실패 시 종료, `-u`는 정의되지 않은 변수 사용 시 오류를 내는 설정입니다. |
| <code>wc -l /input/samples.tsv &gt; /output/line-count.txt</code> | 파일이나 입력의 크기를 셉니다. `-l`은 줄 수, `-c`는 바이트 수입니다. 파일이 만들어졌는지뿐 아니라 내용·크기도 확인합니다. |
| <code>SCRIPT</code> | 여러 줄을 파일에 저장하는 입력의 끝을 표시합니다. 이 줄 자체는 저장할 파일 내용에 포함되지 않습니다. |
| <code>cat &gt; build-demo/Dockerfile &lt;&lt;&#x27;DOCKERFILE&#x27;</code> | 지정한 파일에 아래의 여러 줄을 저장합니다. `<<` 뒤의 종료 표시가 나올 때까지가 파일 내용입니다. 같은 파일은 덮어씁니다. |
| <code>FROM alpine:3.21</code> | 이 Docker 이미지를 만들 때 바탕으로 사용할 이미지를 지정합니다. |
| <code>COPY count.sh /usr/local/bin/count.sh</code> | 빌드 폴더의 파일을 이미지 내부의 지정한 경로에 넣습니다. |
| <code>ENTRYPOINT [&quot;sh&quot;, &quot;/usr/local/bin/count.sh&quot;]</code> | 컨테이너를 시작할 때 실행할 기본 프로그램과 인자를 지정합니다. |
| <code>DOCKERFILE</code> | 여러 줄을 파일에 저장하는 입력의 끝을 표시합니다. 이 줄 자체는 저장할 파일 내용에 포함되지 않습니다. |
| <code>docker build -t course-count:1 build-demo</code> | 뒤에 지정한 폴더의 Dockerfile로 이미지를 만듭니다. `-t course-count:1`은 만든 이미지에 붙일 이름과 태그입니다. |
| <code>docker run --rm --user &quot;$(id -u):$(id -g)&quot;  --mount &quot;type=bind,src=$PWD/input,dst=/input,readonly&quot;  --mount &quot;type=bind,src=$PWD/output,dst=/output&quot;  course-count:1</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| <code>cat output/line-count.txt</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `--user "$(id -u):$(id -g)"` | 호스트의 사용자 번호와 그룹 번호로 실행합니다. id -u는 사용자 ID, id -g는 그룹 ID이며 $(...)는 명령 결과를 넣습니다. |
| `--mount` | type=bind는 호스트 폴더 연결, src는 호스트 원본 경로, dst는 컨테이너 경로, readonly는 쓰기 금지입니다. type=volume은 Docker 관리 저장공간을 연결합니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `wc -l` | 입력 파일이나 전달받은 입력의 줄 수를 셉니다. 예제는 헤더를 포함해 4줄입니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |
| `course-count:1` | 이 선택 실습에서 직접 만든 이미지의 이름과 태그입니다. |

</details>

기대 결과는 헤더를 포함한 4줄입니다. count.sh는 할 일, Dockerfile은 환경 설명서, course-count:1은 만든 이미지, docker run으로 시작한 것은 컨테이너입니다. 입력 데이터는 이미지에 넣지 않고 실행할 때 연결했습니다. --rm으로 컨테이너가 없어져도 만든 이미지는 남습니다.

복습: [기존 Docker 배치 실습](https://seondh.github.io/bio_linux/day5/chapter22/training/batch_pipeline.html).


</details>

<details markdown="1"><summary>08 종합 트러블슈팅 · 자세한 설명</summary>

# 08 종합 트러블슈팅

**실행 위치:** 미션 A·B는 `course-linux` 컨테이너, Docker를 사용하는 미션 C·E는 호스트 Bash입니다. 실행 위치를 바꿀 때 `exit` 또는 `docker start -ai course-linux`를 사용하세요.

**목표:** 오류 메시지 → 관찰 → 원인 후보 → 수정 → 재검증을 수행합니다.

## 문제 해결 기록 양식
1. 실행한 명령과 현재 위치
2. 오류 문구와 종료 상태
3. 입력·출력 경로, 사용자, 실행 환경
4. 확인한 증거와 원인 후보
5. 수정한 한 가지와 재실행 결과

## 미션 A · 결과 파일은 있는데 내용이 없습니다
```bash
cd "$HOME/linux-server-lab"
cat input/sample.tsv > output/mission-a.txt 2> logs/mission-a.log
echo "$?"
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>cd &quot;$HOME/linux-server-lab&quot;</code> | 뒤의 경로로 현재 작업 위치를 옮깁니다. `$HOME`은 현재 환경의 홈, `..`는 한 단계 위 폴더입니다. |
| <code>cat input/sample.tsv &gt; output/mission-a.txt 2&gt; logs/mission-a.log</code> | 지정한 파일 내용을 읽어 출력합니다. `/`로 시작하면 절대 경로, `../`는 상위 폴더를 기준으로 찾습니다. |
| <code>echo &quot;$?&quot;</code> | 뒤의 글자나 변수 값을 출력합니다. `$?`는 바로 앞 명령의 종료 상태로, 보통 0은 성공·나머지는 실패입니다. |
| `2> 경로` | 오류 메시지를 해당 파일에 저장합니다. 같은 이름의 로그는 덮어씁니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$HOME` | 현재 셸 환경의 홈 폴더입니다. 호스트와 컨테이너에서 다른 경로일 수 있습니다. |

</details>

결과의 크기, 로그, 입력 파일 목록을 확인하고 실제 파일로 다시 실행하세요.
<details><summary>해설 보기</summary>
파일명은 samples.tsv입니다. 실패한 cat보다 먼저 리다이렉션이 빈 파일을 만듭니다. ls input과 로그로 오타를 확인한 후 명령을 수정합니다.
</details>

## 미션 B · 실행 권한이 없습니다
```bash
chmod u-x scratch/hello.sh
./scratch/hello.sh
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>chmod u-x scratch/hello.sh</code> | 파일의 권한을 바꿉니다. `u-x`는 소유자의 실행 권한 제거, `u+x`는 추가입니다. `755`는 소유자 읽기·쓰기·실행과 나머지 읽기·실행, `600`은 소유자만 읽기·쓰기입니다. |
| <code>./scratch/hello.sh</code> | 현재 폴더를 기준으로 스크립트를 직접 실행합니다. `./`가 경로를 지정하고, 파일에는 실행 권한이 필요합니다. |

</details>

자신의 스크립트에만 필요한 권한을 부여하고 직접 실행하세요.
<details><summary>해설 보기</summary>
ls -l로 소유자와 권한을 확인하고 chmod u+x scratch/hello.sh로 수정합니다. 03장의 스크립트가 없다면 먼저 그 실습을 진행합니다.
</details>

## 미션 C · 컨테이너가 호스트 파일을 못 찾습니다
```bash
docker run --rm alpine:3.21 cat /input/samples.tsv
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker run --rm alpine:3.21 cat /input/samples.tsv</code> | 이미지로 새 컨테이너(작업 자리)를 만들고 뒤의 프로그램을 실행합니다. |
| `--rm` | 작업이 끝나면 해당 컨테이너를 자동 삭제합니다. 이미지는 남습니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |
| `cat /경로/파일` | 컨테이너에서 보이는 주소의 파일을 읽습니다. 호스트의 파일이 자동으로 보이지는 않습니다. |

</details>

호스트에 파일이 있다는 사실만으로 컨테이너에서 보이지 않습니다. 읽기 전용 mount를 추가하고 결과를 확인하세요.
<details><summary>해설 보기</summary>
07장의 입력 mount를 추가합니다. docker run --rm --mount "type=bind,src=$PWD/input,dst=/input,readonly" alpine:3.21 cat /input/samples.tsv 를 작업 폴더에서 실행합니다.
</details>

## 미션 D · 디스크 부족: 사례 토론
제공 출력: `/` 99%, `/data` 12%, Docker Root Dir `/var/lib/docker`. 분석 입력은 `/data`에 있고 사용자가 이미지를 반복적으로 빌드했습니다.

어떤 증거를 추가로 수집할까요? 지금 삭제해도 되는 것은 무엇일까요?
<details><summary>해설 보기</summary>
각 경로의 df, docker system df -v, 엔진 저장 방식, 컨테이너 로그 설정을 확인합니다. 자신의 중지 컨테이너와 결과 보존 여부부터 검토합니다. 공용 이미지·볼륨은 소유자와 관리자 확인 없이 삭제하지 않습니다. 저장 위치 조정은 별도 관리 작업입니다.
</details>

## 미션 E · 메모리 부족일까요?
사례: 컨테이너 종료 코드 137. 다음 자료를 추가로 확인합니다.
```bash
docker inspect 컨테이너이름 --format '{{.State.ExitCode}} {{.State.OOMKilled}} {{.State.Error}}'
docker logs --tail 50 컨테이너이름
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>docker inspect 컨테이너이름 --format &#x27;{{.State.ExitCode}} {{.State.OOMKilled}} {{.State.Error}}&#x27;</code> | 컨테이너 설정·상태를 조회합니다. `--format`은 필요한 항목만 출력합니다. Mounts는 폴더 연결, ExitCode는 종료 상태, OOMKilled는 메모리 부족 종료 여부, HostConfig.Memory는 RAM 한도(바이트), NanoCpus는 CPU 시간 한도(1 CPU = 1000000000)입니다. |
| <code>docker logs --tail 50 컨테이너이름</code> | 지정한 컨테이너의 표준 출력·오류 로그를 봅니다. `--tail 50`은 마지막 50줄입니다. |

</details>

`컨테이너이름`은 실제 남아 있는 대상 이름으로 바꾸세요. `--rm`으로 이미 삭제했다면 inspect할 수 없으므로 재현 시 컨테이너를 남겨 진단합니다. 필요한 경우 관리자에게 호스트 로그 확인을 요청합니다.

## 마지막 설명 과제
짝에게 “큰 디스크가 있어도 루트가 가득 찰 수 있는 이유”와 “컨테이너 결과를 안전하게 남기는 방법”을 1분씩 설명하세요.

## 짧은 실습 · 오류 보고서를 완성하기
위 미션 하나를 골라 `logs/incident-note.txt`에 시각, 현재 경로, 실행 위치, 명령, 원문 오류, 종료 상태, 확인한 증거, 수정과 재실행 결과를 적습니다. 짝은 기록만 보고 같은 문제를 재현할 수 있는지 확인합니다.

평가 기준은 명령을 많이 쓰는 것이 아니라 “어떤 증거로 원인을 좁혔는가”를 설명하는 것입니다.


</details>
