# 0. 사전 준비: Docker Desktop 설치

> **실습 환경:** 운영체제에 맞는 설치 안내
> **준비:** 인터넷 연결 및 설치 가능한 개인 PC

**사전 과제 · 수업 시간 외 · 목표:** Docker Desktop을 설치하고, 개인 PC의 폴더를 연결한 Linux 실습 환경에 들어갑니다.

## 사전 과제는 설치를 위한 안내입니다
아래 명령의 모든 옵션을 지금 이해하거나 외우지 않아도 됩니다. Windows 또는 Mac에 해당하는 부분만 따라 하고 설치 확인을 마치세요. 개념과 파일 연결은 수업에서 쉬운 설명으로 다시 다룹니다. 어려우면 오류 메시지를 기록해 교육 담당자에게 문의하세요.

## 먼저: Docker Desktop과 docker 명령
Docker Desktop은 PC에서 컨테이너를 실행할 엔진과 Linux 환경, 관리 화면 등을 제공하는 앱입니다. 터미널의 `docker`는 그 엔진에 실행 요청을 보내는 명령줄 프로그램입니다. 따라서 명령이 설치되어 있어도 Docker Desktop의 엔진이 실행되어 있어야 실습할 수 있습니다. 자세한 관계는 [2장](02-docker.html)에서 설명합니다.

## 1. 이번 실습의 구조
교육용 서버를 빌리지 않고 개인 PC에서 Linux 컨테이너를 실행합니다. Docker Desktop이 Linux 실행 환경을 제공하고, 우리는 그 안에서 리눅스 명령을 실습합니다.

| 구분 | Windows | Mac |
|---|---|---|
| Docker 설치 | Docker Desktop + WSL 2 backend | Docker Desktop |
| 호스트 명령 터미널 | WSL Ubuntu의 Bash | 터미널 앱에서 Bash |
| 1·3·4·5·6장 Linux 실습 | Ubuntu 컨테이너의 Bash | Ubuntu 컨테이너의 Bash |
| 입력·결과 저장 | WSL Ubuntu 홈의 실습 폴더 | Mac 홈의 실습 폴더 |

**호스트 터미널**은 Docker를 실행하는 터미널, **컨테이너 터미널**은 Linux 명령을 실습하는 터미널입니다. Windows에서는 PowerShell을 설치 준비에만 쓰고, 이후 실습 명령은 Ubuntu에서 실행합니다. macOS에서는 터미널 앱을 사용합니다.

이 장의 설치와 최초 다운로드는 수업 전에 완료하세요. Docker Desktop 지원 운영체제와 설치 조건은 바뀔 수 있으므로 아래 공식 안내를 기준으로 확인합니다. 원활한 교육을 위한 권장 사양은 메모리 8 GB 이상, 여유 저장공간 10 GB 이상이며 설치·다운로드에는 인터넷이 필요합니다.

## 설치 전: Docker Desktop은 무료인가요?
**Docker Desktop은 사용 목적과 조직 조건에 따라 무료 또는 유료입니다.** Docker 공식 안내에는 개인 사용, 교육, 비상업적 오픈소스 프로젝트가 무료 대상으로 명시되어 있습니다. 따라서 이번처럼 교육 목적으로 사용하는 경우에는 해당 무료 범위를 확인하고 진행합니다.

| 사용 조건 | 공식 안내의 구분 |
|---|---|
| 개인 사용·교육·비상업적 오픈소스 | 무료 대상 |
| 직원 250명 미만 **그리고** 연 매출 1,000만 달러 미만인 소규모 기업 | 무료 대상 |
| 무료 범위를 넘는 기업의 업무 사용 | 유료 구독 필요 |
| 정부 기관 사용 | 유료 구독 필요 |

수업에서 사용한 프로그램을 회사나 기관의 업무에 계속 사용하려면 해당 조직의 이용 조건과 정책을 별도로 확인하세요. 교육 목적이라는 설명을 모든 기관의 업무 사용에 적용하지 않습니다. Docker Desktop의 구독 조건과 Linux 서버에서 사용하는 Docker Engine의 오픈소스 라이선스는 구분합니다.

확인 기준: 2026-10-03, [Docker Desktop 공식 라이선스 안내](https://docs.docker.com/subscription-billing/desktop-license/). 설치 시에는 최신 약관을 확인합니다.

## 2. Windows 준비
### 2-1. WSL Ubuntu 설치 또는 확인
관리자 권한으로 **PowerShell**을 열고 실행합니다. 이미 Ubuntu를 사용하고 있다면 새로 설치하지 않고 상태를 확인합니다.
```powershell
wsl --version
wsl --list --verbose
```
WSL이나 Ubuntu가 없다면 설치합니다.
```powershell
wsl --install -d Ubuntu
```
재부팅 안내가 나오면 재부팅한 뒤 시작 메뉴의 Ubuntu를 열고 Linux 사용자 이름과 비밀번호를 만듭니다. 비밀번호 입력 중 글자가 표시되지 않는 것은 정상입니다. WSL 업데이트가 필요한 경우 다음을 실행합니다.
```powershell
wsl --update
wsl --list --verbose
```
Ubuntu의 VERSION 열이 `2`인지 확인합니다. `1`이면 다음처럼 변환합니다. 배포판 이름이 다르면 목록에 표시된 이름을 사용합니다.
```powershell
wsl --set-version Ubuntu 2
```
WSL 설치에는 가상화 기능과 시스템 설정 권한이 필요할 수 있습니다. 기관 PC에서 설치가 제한되면 교육 담당자에게 미리 문의하세요.

### 2-2. Docker Desktop 설치와 연결
[Windows 공식 설치 안내](https://docs.docker.com/desktop/setup/install/windows-install/)에서 PC 아키텍처와 지원 Windows 버전에 맞는 설치 파일을 받습니다. 설치 후 Docker Desktop을 실행하고 초기 설정을 마칩니다.

- Settings → General에서 **Use the WSL 2 based engine**을 확인합니다.
- Settings → Resources → WSL Integration에서 사용하는 **Ubuntu**의 통합을 켜고 적용합니다.
- 이 교재는 **Linux containers** 모드로 실습합니다.

[Docker의 WSL 안내](https://docs.docker.com/desktop/features/wsl/)를 함께 참고하세요. WSL Ubuntu 안에 별도의 Docker Engine을 추가로 설치할 필요는 없습니다.

이제 시작 메뉴에서 **Ubuntu**를 엽니다. 이후 `bash` 코드 블록은 이 창에서 실행합니다. `C:\...` 경로를 Bash 명령에 그대로 넣지 않습니다. 실습 폴더는 Windows의 `/mnt/c` 대신 WSL Ubuntu 홈에 만들어 Linux 권한과 파일 입출력을 학습합니다.

## 3. Mac 준비
### 3-1. CPU에 맞는 Docker Desktop 설치
Apple 메뉴 → 이 Mac에 관하여에서 칩을 확인합니다.

- M 계열 칩: **Apple silicon**용 설치 파일
- Intel 프로세서: **Intel chip**용 설치 파일

[Mac 공식 설치 안내](https://docs.docker.com/desktop/setup/install/mac-install/)에서 설치 파일을 내려받고 `Docker.app`을 Applications에 넣습니다. Docker 앱을 실행하고 초기 설정을 완료한 뒤 엔진이 시작될 때까지 기다립니다. 본 실습의 Ubuntu·Alpine 이미지는 아키텍처를 자동 선택하므로 `--platform` 옵션을 지정하지 않습니다.

### 3-2. 터미널 열기
응용 프로그램 → 유틸리티 → 터미널을 열고 Bash로 전환합니다. Mac 기본 셸이 zsh여도 아래 실습은 Bash에서 진행할 수 있습니다.
```bash
bash
```
Mac 터미널은 아직 Linux가 아닙니다. 공통 Linux 환경에는 뒤의 `docker run` 명령으로 들어갑니다.

## 4. 공통: Docker 실행 확인
**Windows: Ubuntu 창 / Mac: 터미널의 Bash**에서 실행합니다. Docker Desktop 앱을 계속 실행해 두세요.
```bash
docker version
docker run --rm hello-world
```
`docker version`에 Client와 Server 정보가 모두 나오고, 두 번째 명령에 `Hello from Docker!`가 나오면 연결 성공입니다. 첫 실행은 이미지를 다운로드합니다. 이 확인이 끝나면 교육생은 Docker 설치를 완료한 상태입니다.

## 5. 개인 PC에 실습 폴더 만들기
계속 **호스트 터미널**에서 실행합니다.
```bash
mkdir -p "$HOME/linux-server-lab"
cd "$HOME/linux-server-lab"
mkdir -p input output logs scratch
pwd
```
Windows에서는 이 폴더가 WSL Ubuntu의 홈에 있습니다. 필요하면 아래 명령으로 Windows 파일 탐색기를 열어 볼 수 있습니다.
```bash
explorer.exe .
```
위 명령은 Windows에서만 사용합니다. macOS는 Finder의 이동 → 홈에서 `linux-server-lab` 폴더를 확인하세요.

## 6. 공통 Linux 실습 컨테이너 만들기
**호스트 터미널**에서 실행합니다. 줄 끝의 `\`는 다음 줄까지 같은 명령이라는 뜻입니다. 블록 전체를 한 번에 복사하세요.
```bash
docker pull ubuntu:24.04
docker pull alpine:3.21
docker run -it --name course-linux \
  --cpus=1 --memory=512m \
  --mount "type=bind,src=$HOME/linux-server-lab,dst=/root/linux-server-lab" \
  --workdir /root/linux-server-lab \
  ubuntu:24.04 bash
```
이제 프롬프트가 `root@...` 형태로 바뀝니다. **컨테이너 안**으로 들어온 상태입니다. `--name`은 다시 접속할 컨테이너 이름, `-it`는 대화형 터미널, `--mount`는 PC 폴더 연결입니다. 자원 제한은 실습 컨테이너가 과도하게 자원을 사용하는 것을 줄입니다.

이 컨테이너는 개인 실습 환경입니다. 컨테이너 안의 root와 PC의 관리자 권한은 동일한 개념이 아니지만, 연결한 폴더의 파일은 실제로 변경되므로 개인 실습 폴더만 연결합니다. Linux 서버에서는 일반 사용자로 작업하는 방식과 권한을 따로 학습합니다.

### 6-1. 최초 한 번: 진단 도구 준비
아래는 **컨테이너 터미널**에서 실행합니다. 설치 중에는 네트워크가 필요합니다.
```bash
apt-get update
apt-get install -y procps util-linux
```
`ps`, `top`, `free`, `vmstat`, `findmnt`, `lsblk` 등 관찰 도구를 준비합니다. 컨테이너에서 관찰한 메모리·디스크 값은 PC 전체 또는 실제 교육용 서버의 값과 일치하지 않을 수 있습니다. 컨테이너에서는 실제 서버의 모든 블록 장치가 보이지 않을 수 있습니다.

### 6-2. 예제 데이터 만들기
계속 **컨테이너 터미널**에서 실행합니다. 이미 같은 예제 파일이 있다면 내용을 확인한 뒤 재작성 여부를 결정하세요. `>`는 기존 파일을 덮어씁니다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p input output logs scratch
printf 'sample\tgroup\tcount\nS01\tA\t10\nS02\tB\t20\nS03\tA\t30\n' > input/samples.tsv
cat input/samples.tsv
cat /etc/os-release
pwd
```
Ubuntu 정보와 `/root/linux-server-lab` 경로가 보이면 준비 완료입니다. PC의 `linux-server-lab/input` 폴더에서도 `samples.tsv`를 확인할 수 있습니다. 컨테이너 경로와 PC 경로는 다르지만 같은 파일이 연결되어 있습니다.

## 7. 나가기와 다시 들어가기
**컨테이너 터미널**에서 다음을 실행하면 컨테이너가 정지하고 호스트 터미널로 돌아갑니다.
```bash
exit
```
**호스트 터미널**에서 상태를 보고 다시 들어갑니다.
```bash
docker ps -a --filter name=course-linux
docker start -ai course-linux
```
정지·재시작해도 이 컨테이너에 설치한 도구는 남습니다. `docker run`을 다시 실행하면 같은 이름 충돌이 나므로 기존 환경에는 `docker start -ai`로 들어갑니다. 삭제 후 새로 만들면 컨테이너에 설치한 도구를 다시 준비해야 합니다. PC에 연결한 실습 파일은 컨테이너 삭제와 별개로 남습니다.

## 8. 장별로 어느 터미널을 쓰나요?
| 학습 내용 | 실행 위치 |
|---|---|
| 1·3·4·5·6장 자원·Linux 기초·저장공간 | `course-linux` 컨테이너의 Bash |
| 2·7장 Docker 개념·명령과 파일 연결 | `exit` 후 호스트 Bash |
| 8장 Linux 오류 실습 A·B·C | `course-linux` 컨테이너의 Bash |
| 8장의 Docker 오류 실습·6장의 별도 자원 실습 | 호스트 Bash |

Docker를 조작하는 명령은 호스트에서 실행합니다. 실습 컨테이너에는 Docker를 설치하거나 Docker 소켓을 연결하지 않습니다. 컨테이너 안에서 `docker: command not found`가 나면 `exit`로 돌아가 실행 위치를 확인하세요.

## 9. 자주 막히는 부분
| 증상 | 확인과 해결 |
|---|---|
| `docker: command not found` | 호스트인지 확인; macOS는 설치 후 터미널 재실행, Windows는 WSL Integration 확인 |
| Client만 나오거나 daemon 연결 실패 | Docker Desktop 실행 완료 여부, `docker context ls`의 현재 연결 확인 |
| WSL 가상화 오류 | Windows 가상화·WSL 설정을 공식 안내와 비교하고 사전 지원 요청 |
| `bind source path does not exist` | 호스트의 실습 폴더를 먼저 만들었는지 확인 |
| mount 접근 거부 | 개인 홈의 폴더인지 확인; Docker Desktop 파일 공유 설정 확인 |
| `container name ... is already in use` | 기존 실습 컨테이너인지 확인하고 `docker start -ai course-linux` 사용 |
| 이미지 다운로드 실패 | 인터넷·프록시 설정 확인; 수업 전에 담당자에게 문의 |
| 컨테이너에서 권한 실습이 예상과 다름 | root는 권한을 우회할 수 있음; 3장의 일반 사용자 권한 실습과 실제 서버 상황 비교 |

## 자원 실습을 선택한다면: 이미지 사전 다운로드
**호스트 Bash**에서 실행한다. CPU 공유·메모리 부족 실습에 필요한 작은 Python 환경을 준비한다. 기본 Linux·파일 연결 실습만 한다면 이 단계는 생략할 수 있다.
```bash
docker pull python:3.12-alpine
```

## 수업 전 완료 체크
- Docker Desktop을 설치하고 실행했다.
- 호스트 터미널에서 Client와 Server를 확인했다.
- `hello-world` 출력과 Ubuntu·Alpine 이미지 다운로드를 확인했다.
- `course-linux` 안에서 Ubuntu 정보와 예제 데이터를 확인했다.
- `exit`로 나왔다가 `docker start -ai course-linux`로 다시 들어갔다.

이제 컨테이너 안에서 [1장: CPU와 서버 자원](01-resources.html)을 시작하세요.
