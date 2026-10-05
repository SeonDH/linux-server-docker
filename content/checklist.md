# 실무 체크리스트
## 실행 전
- 현재 사용자와 작업 디렉터리를 확인했나요?
- 입력·출력·임시·로그 경로의 실제 저장 장치를 확인했나요?
- 작은 입력에서 명령과 출력 내용이 검증됐나요?
- 도구의 스레드 수와 메모리 설정이 공유 환경에 맞나요?
- Docker 입력은 읽기 전용, 출력은 쓰기 가능하게 연결했나요?

## 문제가 생기면
| 메시지 | 첫 확인 |
|---|---|
| No such file or directory | pwd, 파일명, 컨테이너 mount |
| Permission denied | id, 파일·상위 폴더 권한, mount 읽기 전용 여부 |
| command not found | command -v, PATH, 실행 환경 |
| No space left on device | 대상 경로 df -h, df -i, quota |
| Cannot connect to Docker daemon | docker context show, docker version, 엔진 실행 상태 |
| 빈 결과 파일 | 종료 상태, stderr, 리다이렉션, 파이프 실패 |
| Killed / 137 | SIGKILL 원인, OOM 상태, 관리자 로그 |

## 작업 후
결과 내용과 소유권을 확인하고 실행 명령·이미지 버전을 기록합니다. 자신이 만든 임시 데이터와 실습 컨테이너만 정리합니다. 로그를 보존할지 결정하고 장기 작업은 운영 정책에 맞게 제출합니다.

## 관리자에게 전달할 내용
문제가 발생한 시각, 사용자, 작업 경로, 실행 명령, PID 또는 컨테이너 이름, 원문 오류, 확인한 자원 상태를 전달하세요. “안 돼요” 대신 재현 가능한 증거를 제공합니다.
