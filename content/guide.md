# 교재 사용과 실습 환경 안내
## 기존 교재와 연결
[바이오 리눅스 기존 교재](https://seondh.github.io/bio_linux/)의 단원 번호, [실습], [답지], [번외] 구분을 따라 보충 교재를 구성했다. 쉬운 비유와 반복 실습으로 앞서 어려웠던 내용을 다시 이해하는 데 집중한다.

| 보충 교재 | 기존 교재에서 다시 볼 곳 |
|---|---|
| 컴퓨터 자원·프로세스 | [12. 프로세스 관리](https://seondh.github.io/bio_linux/day3/chapter12/) |
| 경로·폴더 | [4. 디렉터리와 파일 명령어](https://seondh.github.io/bio_linux/day1/chapter4/) |
| 권한·소유권 | [11. 권한과 소유권](https://seondh.github.io/bio_linux/day3/chapter11/) |
| 파일·파이프·로그 | [9. 파일 내용 다루기](https://seondh.github.io/bio_linux/day2/chapter9/) |
| 셸 스크립트 | [10. 셸 스크립트](https://seondh.github.io/bio_linux/day2/chapter10/) |
| Docker·파일 연결 | [22. Docker](https://seondh.github.io/bio_linux/day5/chapter22/) |

## 어느 창에서 실행하나요?
| 창 | 하는 일 | 여는 방법 |
|---|---|---|
| 호스트 Bash | docker 명령으로 컨테이너 실행·관찰 | Windows의 WSL Ubuntu, macOS 터미널에서 bash |
| course-linux 내부 Bash | Linux 파일·권한·파이프·프로세스 실습 | 호스트에서 docker start -ai course-linux |
| Windows PowerShell | 0장의 WSL 설치와 확인 | 설치 준비에만 사용 |

course-linux에서 exit를 실행하면 호스트로 돌아간다. Docker Desktop이 켜져 있어도 현재 창이 어디인지 먼저 확인한다.

## 공통 예제와 경로
같은 samples.tsv를 계속 사용한다. 헤더 1줄과 자료 3줄로 총 4줄이며 count 합계는 60이다.

| 폴더 | 용도 |
|---|---|
| input | 원본 예제 |
| output | 결과 |
| logs | 오류와 진행 기록 |
| scratch | 작은 임시 실습 파일 |

호스트는 $HOME/linux-server-lab, course-linux 안에서는 /root/linux-server-lab을 사용한다. $HOME은 실행 환경마다 다르므로 같은 글자라도 같은 주소가 아닐 수 있다. 개인 작업 폴더만 연결한다.

## 명령과 결과를 읽는 방법
명령 블록은 복사해 실행한다. $ 같은 프롬프트 기호는 붙이지 않았다. 코드 블록 밖의 기대 결과와 비교한다. 오류 실습에서는 실패가 기대 결과일 수 있으며, 그 뒤 접힌 힌트와 답지를 확인한다. 줄 끝의 역슬래시는 다음 줄까지 같은 명령이라는 뜻이다.

## 내려받은 실습 스크립트 실행
CPU·메모리 실습 페이지의 내려받기 링크로 .sh 파일을 저장한다. Windows는 WSL Ubuntu에서 개인 실습 폴더를 열고 explorer.exe .를 실행한 뒤 그 창으로 파일을 옮길 수 있다. macOS는 저장한 폴더에서 터미널을 연다. bash 스크립트이름.sh로 실행하며 이름이 같은 파일을 내려받았다면 실제 저장 이름을 확인한다.

## 실습을 다시 시작할 때
0장의 course-linux는 docker run으로 다시 만들지 않고 docker start -ai로 들어간다. 설치한 도구와 PC 폴더의 파일을 확인한다. 샘플 생성 명령의 >는 기존 파일을 덮어쓰므로 원본·실제 분석 파일에 실행하지 않는다. 문제가 생긴 상태를 무작정 삭제하기보다 오류와 경로를 기록한다.

## 기본 학습과 추가 자료
0장에서 환경을 준비한 뒤 1~9장을 순서대로 읽는다. [실습] 페이지에서 CPU·메모리 사용을 비교하고, [번외]는 필요한 내용을 찾아 읽는다. 막히면 현재 실행 위치와 원문 오류를 기록하고 힌트·답지와 비교한다.
