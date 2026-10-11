# 9. Singularity와 Apptainer의 이해

> **학습 방식:** 이론과 명령 읽기 · 20~30분
> **준비:** 2장의 이미지·컨테이너 개념 · 설치 불필요

**학습 목표:** 연구 서버에서 Singularity 또는 Apptainer라는 이름을 만나도, “준비된 도구로 내 파일을 처리하는 컨테이너 도구”라고 이해합니다. 이 장의 명령은 읽기용입니다. 지금 터미널에서 실행하지 않습니다.

## 1. Docker를 배웠는데 왜 다른 도구가 나오나요?
2장에서 종이를 자르는 일을 떠올렸습니다. 작업 설명서만 있어서는 부족하고, 가위와 자도 필요했습니다. 이미지는 이 도구와 실행 환경을 준비한 작업 세트였습니다.

**Docker도, Singularity도, Apptainer도 준비된 도구로 작업하도록 돕는 컨테이너 도구입니다.** 새로운 종류의 분석을 배우는 것이 아니라, 준비된 분석 환경을 사용하는 다른 방법을 알아보는 것입니다.

```text
하고 싶은 일: 준비된 분석 프로그램으로 내 데이터 처리하기
    ├─ 개인 PC에서는 Docker Desktop으로 연습
    └─ 연구 서버에서는 서버가 제공하는 Apptainer 등을 사용
```

Docker도 연구 서버에서 사용할 수 있습니다. 실제로 어떤 도구를 사용할지는 서버 관리자가 제공하는 환경과 사용 규칙에 따릅니다.

## 2. 공용 연구실에 도구 세트를 가져온다고 생각해 보세요
내 책상에서는 내가 원하는 도구를 설치하고 사용할 수 있습니다. 하지만 여러 사람이 함께 쓰는 연구실에서는 규칙이 있습니다.

- 다른 사람의 서랍을 열거나 파일을 바꾸면 안 됩니다.
- 작업 자리를 혼자 다 차지하면 안 됩니다.
- 관리자가 허용한 도구와 방법으로 작업해야 합니다.

Apptainer는 이런 **여러 사용자가 함께 쓰는 연구 서버와 대규모 계산 환경**에서 사용하기 좋게 만들어졌습니다. 일반적인 실행에서는 내 사용자 계정의 권한으로 작업합니다. 컨테이너를 실행했다고 서버 관리자 권한이 생기지는 않습니다.

> **“준비된 도구를 가져와서, 내 권한으로, 연구실 규칙에 맞게 작업한다.”**

Docker의 일반적인 구성에서는 Docker 엔진이 컨테이너를 만들고 실행합니다. Apptainer는 Docker 같은 상시 실행 엔진 없이 이미지 파일을 지정해 프로그램을 실행할 수 있습니다. Docker에도 일반 사용자 권한으로 동작하는 방식이 있으므로 “Docker는 무조건 관리자만 사용한다”라고 이해하지는 마세요.

## 3. Singularity와 Apptainer는 왜 이름이 두 개인가요?
처음에는 **Singularity**라는 이름의 프로젝트에서 출발했습니다. 이후 프로젝트가 나뉘어 현재는 **Apptainer**와 **SingularityCE**가 각각 개발되고 있습니다. 공통 역사를 가진 별도 프로젝트입니다.

연구실에서 “Singularity로 실행하세요”라고 말하면, 실제로 설치된 도구가 무엇인지 확인하면 됩니다. 안내문에 `singularity` 또는 `apptainer`라는 명령 이름이 나올 수 있습니다.

이 교재의 예시는 `apptainer`로 통일합니다. 두 도구를 모두 설치하거나 이름의 역사를 외울 필요는 없습니다. **서버에서 제공하는 도구와 버전을 확인하는 것**이 중요합니다.

## 4. .sif 파일은 준비된 작업 세트예요
Apptainer에서는 프로그램과 실행 환경을 **`.sif`라는 이미지 파일**에 담아 사용할 수 있습니다.

```text
analysis.sif = 분석 도구가 준비된 이미지 파일
samples.tsv  = 내가 분석할 입력 파일
result.txt   = 분석해서 만든 결과 파일
```

`.sif`는 사진 파일도, 분석 결과도 아닙니다. 앞에서 배운 **Docker 이미지처럼 준비된 도구와 실행 환경을 담은 것**입니다. 파일을 내려받거나 복사해 둔다고 분석이 자동으로 시작되지는 않습니다.

| 구분 | 쉽게 기억하기 |
|---|---|
| 이미지 파일 `.sif` | 준비된 작업 세트 |
| 컨테이너 실행 | 그 세트의 도구를 사용해 작업하기 |
| 입력 파일 | 자를 종이 |
| 결과 파일 | 잘라서 완성한 종이 |

기본 SIF 이미지는 읽기 전용으로 사용합니다. 결과를 이미지 안에 넣으려 하지 말고, 서버의 결과 폴더에 저장합니다.

### Docker에서 배운 것과 나란히 비교해 보세요
**SIF 파일은 Dockerfile이 아니라 Docker 이미지에 해당합니다.** Dockerfile은 준비 방법을 적은 설명서이고, SIF는 프로그램과 실행 환경을 이미 준비해 둔 작업 세트입니다.

| 하는 일 | Docker | Apptainer | 종이 자르기 비유 |
|---|---|---|---|
| 이미지를 만드는 방법 작성 | `Dockerfile` | 정의 파일 `.def` | 어떤 가위와 자를 준비할지 적은 설명서 |
| 프로그램과 실행 환경 준비 | Docker 이미지 | SIF 이미지 파일 `.sif` | 가위와 자를 준비한 작업 세트 |
| 이미지 내려받기 | `docker pull` | `apptainer pull` | 준비된 작업 세트를 가져오기 |
| 준비된 환경에서 명령 실행 | `docker run` | `apptainer exec` | 도구를 꺼내 실제 종이를 자르기 |
| 입력·출력 폴더 연결 | `--mount` | `--bind` | 종이와 완성품을 보관할 폴더 연결하기 |

```text
Dockerfile → 이미지 만들기 → Docker 이미지 → 컨테이너에서 작업 실행
.def 파일  → 이미지 만들기 → .sif 파일    → 컨테이너에서 작업 실행
```

두 설명서의 문법과 실행 옵션은 다릅니다. 위 표는 역할을 비교한 것이며, 명령을 그대로 바꿔 쓰면 된다는 뜻은 아닙니다. 이번에는 Dockerfile이나 `.def`를 직접 작성하지 않고, 이미 만들어진 이미지를 사용합니다.

Docker에서는 보통 **로컬 Docker 저장소에 있는 이미지 이름**을 지정합니다. 이 장의 Apptainer 예시에서는 **서버에 저장한 `.sif` 파일의 경로**를 지정합니다. 그래서 `alpine:3.21`과 `alpine.sif`는 같은 역할의 작업 세트를 가리키지만, 저장하고 부르는 방식이 다릅니다.

**Docker 이미지도 파일로 내보낼 수 있고, Apptainer도 이미지 저장소의 주소를 직접 사용할 수 있습니다.** 여기서는 처음 배우기 쉽게 가장 기본적인 사용 흐름을 비교합니다.

## 5. 명령 한 줄을 읽어 봅시다
**아래는 Apptainer가 설치된 Linux 환경에서 사용할 수 있는 예시입니다. 이번 수업에서는 실행하지 않고 뜻만 읽습니다.**

먼저 도구 세트를 준비하는 명령입니다.

```bash
apptainer pull alpine.sif docker://alpine:3.21
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>apptainer pull alpine.sif docker://alpine:3.21</code> | Docker Hub의 이미지를 가져와 alpine.sif라는 로컬 이미지 파일로 준비합니다. 도구를 내려받는 단계이며 아직 분석을 실행하지 않습니다. |
| `alpine:3.21` | 기본 도구를 갖춘 작은 Alpine Linux 이미지입니다. 3.21은 이미지의 태그입니다. |

</details>


| 부분 | 뜻 |
|---|---|
| `apptainer pull` | 사용할 이미지를 내려받아 준비합니다. |
| `alpine.sif` | 만들어 둘 로컬 이미지 파일의 이름입니다. |
| `docker://alpine:3.21` | Docker Hub의 Alpine 이미지를 가져와 SIF 파일로 준비합니다. |

**Docker 이미지를 가져올 수 있지만, 이 명령을 실행하는 데 Docker Desktop이 필요한 것은 아닙니다.** Apptainer가 이미지 저장소에서 데이터를 가져옵니다. 모든 Docker 작업이 그대로 호환되는 것은 아닙니다.

이제 준비된 도구로 인사를 출력합니다.

```bash
apptainer exec alpine.sif echo hello
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>apptainer exec alpine.sif echo hello</code> | 지정한 SIF 이미지의 환경에서 뒤의 명령을 실행합니다. `--bind`는 서버 폴더:컨테이너 경로 순서이며 `:ro`는 읽기 전용입니다. 이 장에서는 실행하지 않고 읽습니다. |
| `echo 글자` | 컨테이너 안에서 지정한 글자를 출력합니다. >가 있으면 그 출력을 파일에 저장합니다. |

</details>


왼쪽부터 **“Apptainer로 → 이 이미지의 환경에서 → echo hello를 실행한다”**라고 읽으세요.

| Docker에서 배운 명령 | Apptainer에서 읽어 볼 명령 |
|---|---|
| `docker run --rm alpine:3.21 echo hello` | `apptainer exec alpine.sif echo hello` |

둘 다 결과는 `hello`입니다. Docker는 이미지 이름을, 이 Apptainer 예시는 로컬 `.sif` 파일을 지정합니다. 실행 방식과 옵션이 모두 같다는 뜻은 아닙니다.

## 6. 내 파일과 결과 폴더는 어떻게 연결하나요?
7장에서 Docker의 `--mount`로 폴더를 연결했습니다. Apptainer에서도 폴더를 연결할 수 있습니다. 다음 예시는 입력 파일의 줄 수를 세고 서버의 출력 폴더에 저장합니다.

**읽기용 예시 · 서버에 input/output 폴더, 입력 파일과 alpine.sif가 준비되어 있다고 가정합니다.**

```bash
apptainer exec \
  --bind "$PWD/input:/input:ro" \
  --bind "$PWD/output:/output" \
  alpine.sif sh -c 'wc -l /input/samples.tsv > /output/line-count.txt'
```

<details markdown="1"><summary>명령 한 줄씩 해석하기</summary>

| 명령 또는 부분 | 하는 일 |
|---|---|
| <code>apptainer exec  --bind &quot;$PWD/input:/input:ro&quot;  --bind &quot;$PWD/output:/output&quot;  alpine.sif sh -c &#x27;wc -l /input/samples.tsv &gt; /output/line-count.txt&#x27;</code> | 지정한 SIF 이미지의 환경에서 뒤의 명령을 실행합니다. `--bind`는 서버 폴더:컨테이너 경로 순서이며 `:ro`는 읽기 전용입니다. 이 장에서는 실행하지 않고 읽습니다. |
| `sh -c / bash -c` | 해당 셸이 따옴표 안의 명령을 해석합니다. 컨테이너 명령 뒤의 >가 컨테이너 내부에서 처리되도록 할 수 있습니다. |
| `> 경로` | 표준 출력을 파일에 저장합니다. 파일을 만들거나 덮어쓰지만 상위 폴더까지 만들지는 않습니다. |
| `$PWD` | 현재 작업 폴더의 절대 경로입니다. |
| `wc -l` | 입력 파일이나 전달받은 입력의 줄 수를 셉니다. 예제는 헤더를 포함해 4줄입니다. |

</details>


| 부분 | 뜻 |
|---|---|
| `$PWD/input:/input:ro` | 서버의 현재 폴더 안 input을 컨테이너의 /input에 읽기 전용으로 연결합니다. |
| `$PWD/output:/output` | 서버의 output을 컨테이너의 /output에 연결합니다. |
| `alpine.sif` | 사용할 도구 세트입니다. |
| `sh -c '...'` | 이미지 안의 셸에서 따옴표 안 명령을 실행합니다. |
| `wc -l /input/samples.tsv` | 입력 파일의 줄 수를 셉니다. |
| `> /output/line-count.txt` | 화면에 나올 결과를 연결한 출력 폴더의 파일에 저장합니다. |

```text
서버의 input/samples.tsv    → 컨테이너의 /input/samples.tsv
서버의 output/line-count.txt ← 컨테이너의 /output/line-count.txt
```

**폴더 연결은 저장 경로를 이어 주고, 프로그램과 `>`가 실제 결과 파일을 만듭니다.** Docker 실습과 같은 생각입니다. Apptainer는 홈 폴더 등 일부 경로를 기본 연결하기도 하지만, 실제 연결 범위는 서버 설정에 따라 다릅니다. 여기서는 입력·출력 위치를 분명히 보려고 직접 지정했습니다.

## 7. 컨테이너를 사용해도 서버 자원은 함께 씁니다
도구 세트를 가져왔다고 연구실 책상이 새로 생기지는 않습니다. Apptainer도 실제 서버의 CPU·메모리·디스크를 사용합니다.

- 이미지 파일과 다운로드 캐시도 저장공간을 차지합니다.
- 결과와 임시 파일이 어느 디스크에 저장되는지 확인합니다.
- CPU·메모리는 서버에서 허용하거나 할당받은 범위로 사용합니다.
- 작업 제출 시스템이 있는 서버에서는 그 시스템으로 자원을 신청합니다.

**Apptainer가 자동으로 자원을 제한하거나 다른 사용자에게 영향을 전혀 주지 않게 해 주는 것은 아닙니다.** 앞에서 배운 경로·권한·자원 확인은 그대로 필요합니다.

## 8. 이번에는 왜 설치 실습을 하지 않나요?
Apptainer와 SingularityCE를 실행하려면 Linux 환경과 해당 도구 설치가 필요합니다. Windows는 WSL2, macOS는 Linux 가상 머신 등의 추가 준비가 필요합니다. **Docker Desktop을 설치한 것과 Apptainer를 설치한 것은 별개입니다.**

이번에는 환경을 더 설치하기보다, 연구 서버에서 안내를 받았을 때 이해할 수 있도록 개념과 명령의 흐름만 확인합니다.

## [읽기 활동] 세 가지를 찾아보세요
앞의 파일 처리 명령에서 **사용한 이미지, 입력 파일, 결과 저장 위치**를 찾아보세요. 명령을 외우거나 실행할 필요는 없습니다.

<details markdown="1"><summary>[답지] 해설 보기</summary>

- 이미지: `alpine.sif`
- 입력: 컨테이너에서는 `/input/samples.tsv`, 서버에서는 현재 폴더의 `input/samples.tsv`
- 결과: 컨테이너에서는 `/output/line-count.txt`, 서버에서는 현재 폴더의 `output/line-count.txt`

</details>

## 자주 헷갈리는 질문

**Apptainer가 Docker보다 무조건 더 좋은가요?**
사용 목적과 서버 환경에 맞춰 선택합니다. 이번 개인 PC 실습은 Docker Desktop을 사용하고, 연구 서버에서는 제공되는 도구를 사용합니다.

**SIF 파일을 받으면 분석도 끝난 건가요?**
도구만 준비된 상태입니다. 입력 파일과 실행할 명령을 지정해야 실제 작업이 시작됩니다.

**컨테이너니까 남의 파일도 열 수 있나요?**
내 사용자에게 허용된 파일만 사용할 수 있습니다. 컨테이너는 서버의 접근 권한을 없애 주지 않습니다.

## 이 장의 정리

- Docker와 Apptainer는 모두 준비된 도구와 실행 환경으로 작업하도록 돕는다.
- SIF는 이미지 파일이고, `exec`는 그 환경에서 명령을 실행하는 것이다.
- 결과를 저장할 폴더를 연결하고, 그 경로에 결과를 쓴다.
- 연구 서버의 권한과 자원 사용 규칙을 지킨다.

참고: [Apptainer 시작 안내](https://apptainer.org/docs/user/latest/quick_start.html), [명령 실행](https://apptainer.org/docs/user/latest/cli/apptainer_exec.html), [파일 연결](https://apptainer.org/docs/user/latest/bind_paths_and_mounts.html), [Docker 이미지 사용](https://apptainer.org/docs/user/latest/docker_and_oci.html).
