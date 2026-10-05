# 3. 경로와 파일 권한

> **실습 환경:** course-linux 컨테이너
> **준비:** 0장의 예제 파일

**학습 목표:** 파일을 찾으려면 현재 위치와 경로를 확인합니다. 실행하려면 필요한 권한도 확인합니다.

## 경로는 파일의 주소입니다
주소를 처음부터 쓰면 절대 경로, 지금 있는 곳을 기준으로 쓰면 상대 경로입니다. `pwd`는 “나는 지금 어디에 있지?”, `ls`는 “여기 무엇이 있지?”를 확인합니다.

## [실습] 따라 하기 · 위치를 바꿔 같은 파일 읽기
**실습 환경:** course-linux 컨테이너. 호스트에서 `docker start -ai course-linux`로 들어옵니다.
```bash
cd "$HOME/linux-server-lab"
pwd
ls
cat input/samples.tsv
cd output
cat input/samples.tsv
cat ../input/samples.tsv
cd ..
```
output 안에서 `input/samples.tsv`를 읽으면 실패합니다. 현재 위치에 input 폴더가 없기 때문입니다. `..`는 한 단계 위입니다. `../input/samples.tsv`는 성공합니다.

## PATH는 데이터 파일의 주소와 다릅니다
PATH는 컴퓨터가 **명령 프로그램을 찾는 폴더 목록**입니다. `wc` 명령의 위치를 찾는 것과 samples.tsv 위치를 찾는 것은 다른 일입니다.
```bash
command -v wc
```

## 권한은 파일을 사용할 수 있는 허가입니다
`r`은 읽기, `w`는 쓰기, `x`는 실행입니다. 파일 소유자·그룹·다른 사용자마다 허가가 다를 수 있습니다. 디렉터리의 x는 그 경로에 들어가거나 통과하는 권한입니다.

## [실습] 따라 하기 · 내 스크립트의 실행 권한
```bash
printf '#!/bin/sh\necho hello\n' > scratch/hello.sh
chmod u-x scratch/hello.sh
ls -l scratch/hello.sh
./scratch/hello.sh
chmod u+x scratch/hello.sh
./scratch/hello.sh
```
처음 직접 실행은 Permission denied, 권한을 준 뒤에는 hello가 기대됩니다. `u+x`는 소유자에게 실행 허가를 추가한다는 뜻입니다. 같은 실습 파일은 덮어씁니다.

0장의 컨테이너는 root 사용자입니다. 실제 서버의 일반 사용자는 읽기·쓰기에 제한이 더 있습니다. 읽기 권한 오류의 일반 사용자 실습은 [선택 자료](deep-dive.html)에 있습니다.

## [실습] 반복 연습 · 다른 이름과 위치에서도 파일 찾기
**15~20분 · course-linux 컨테이너.** 같은 터미널에서 진행합니다.

### 바꿔 보기
먼저 예제 복사본을 만듭니다. 원본은 그대로 두고 복사본 이름만 달라집니다. 같은 복사본이 있으면 다시 덮어씁니다.
```bash
cd "$HOME/linux-server-lab"
cp input/samples.tsv input/practice.tsv
cd output
```
현재 위치를 바꾸지 않고 `practice.tsv`를 읽어보세요.
<details markdown="1"><summary>힌트 보기</summary>
pwd로 위치를 확인하세요. input은 현재 output의 한 단계 위에 있습니다. ..를 사용합니다.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
cat ../input/practice.tsv
```
예제 4줄이 보이면 성공입니다.
</details>

### 고쳐 보기
작업 폴더로 돌아온 뒤 실행 권한을 없앱니다.
```bash
cd "$HOME/linux-server-lab"
chmod u-x scratch/hello.sh
./scratch/hello.sh
```
오류를 읽고 필요한 권한만 고쳐 hello를 출력하세요. 3장의 따라 하기에서 hello.sh를 먼저 만들어야 합니다.
<details markdown="1"><summary>힌트 보기</summary>
ls -l로 확인합니다. 소유자의 실행 권한을 추가하면 됩니다.
</details>
<details markdown="1"><summary>[답지] 해설 보기</summary>
```bash
chmod u+x scratch/hello.sh
./scratch/hello.sh
```
hello가 기대됩니다. 모두에게 모든 권한을 주는 chmod 777은 필요하지 않습니다.
</details>

### 설명하기
파일이 없다는 오류와 실행 허가가 없다는 오류는 무엇이 다른가요? 각각 먼저 확인할 명령을 하나씩 말하세요.

## 확인 질문
파일이 없다는 오류를 만나면 무엇부터 볼까요? 권한 오류에 무조건 chmod 777을 실행해도 될까요?
<details><summary>[답지] 해설 보기</summary>
pwd로 현재 위치, ls로 파일 이름과 경로를 봅니다. 권한은 필요한 대상에 필요한 만큼만 부여합니다. 다른 사용자 파일이나 공용 폴더의 권한을 함부로 바꾸지 않습니다.
</details>

복습: [기존 교재의 권한](https://seondh.github.io/bio_linux/day3/chapter11/).

## [실습] 공백이 있는 경로 - 5분
**실습 환경: course-linux 컨테이너.** 폴더 이름에 공백이 있으면 따옴표로 묶어 한 경로임을 알려 준다.
```bash
cd "$HOME/linux-server-lab"
mkdir -p "scratch/space demo"
printf 'hello\n' > "scratch/space demo/note.txt"
cat "scratch/space demo/note.txt"
```
hello가 기대 결과다. 마지막 경로에서 따옴표를 빼면 shell이 여러 인자로 나눌 수 있다. 변수로 경로를 사용할 때도 `"$HOME"`, `"$PWD"`처럼 묶는 습관을 익힌다.

## 이 장의 정리

- 파일을 못 찾으면 현재 위치와 경로를 먼저 확인한다.
- 권한은 필요한 대상에 필요한 만큼만 부여한다.
