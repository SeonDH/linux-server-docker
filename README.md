# 리눅스 응용: 핵심 기초 복습과 Docker·Singularity
기존 바이오 리눅스 교육 이후 어려웠던 내용을 다시 이해하는 보충 교재다. 주제는 0~9장으로 유지하며 쉬운 비유·반복 실습·접힌 답지로 학습한다. CPU·메모리 실험은 별도 실습 페이지, 상세 진단은 번외 자료로 제공한다.

## 미리보기
```bash
python3 -m http.server 8765 --bind 127.0.0.1 --directory docs
```
브라우저에서 http://localhost:8765 를 연다.

## 편집과 빌드
본문은 content/*.md, 스타일과 동작은 assets/, 내려받을 실습 자료는 labs/에 있다. Ruby와 kramdown이 설치된 환경에서 ruby build.rb로 docs/를 갱신한다. 현재 Mac은 /usr/local/opt/ruby/bin/ruby build.rb를 사용한다. docs/는 생성한 정적 사이트이며 커밋·푸시·배포는 별도로 진행한다.

## 학습 자료
- guide: 실행 위치·경로·기존 교재 연결
- 0~9장: 기초 보충 학습
- practice-resources, practice-cpu-sharing, practice-memory, practice-storage-paths: 추가 자원 실습
- glossary, checklist: 수강생 참고
- deep-dive: 번외 상세 자료

## 실습과 검증
기본 실습은 Ubuntu 24.04 컨테이너와 Alpine 3.21, 자원 비교는 Python 3.12 Alpine 이미지를 사용한다. CPU 공유·메모리 부족 예제는 Intel Mac의 Docker Desktop에서 검증했다. Windows·Apple silicon에서의 실측값은 달라질 수 있다. Singularity/Apptainer는 이론으로 진행하고 별도 설치를 요구하지 않는다.

기존 교재: https://seondh.github.io/bio_linux/

## GitHub Pages
GitHub 저장소의 Settings → Pages에서 Deploy from a branch, main 브랜치의 /docs 폴더를 선택한다. 본문을 수정한 뒤 빌드하고 갱신된 docs/도 함께 커밋한다. 사이트는 저장소 경로 아래에서 동작하도록 상대 경로를 사용한다.
