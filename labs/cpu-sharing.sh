#!/usr/bin/env bash
set -eu
cpu_demo_dir="${1:-$HOME/linux-server-lab/cpu-sharing}"
mkdir -p "$cpu_demo_dir"
cpu_demo_dir="$(cd "$cpu_demo_dir" && pwd)"
cpu_demo_token="$$"
cpu_demo_names=""
cpu_demo_unlimited_A=""
cpu_demo_unlimited_B=""
cpu_demo_limited_A=""
cpu_demo_limited_B=""
cleanup() {
  for cpu_demo_name in $cpu_demo_names; do
    docker rm -f "$cpu_demo_name" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT INT TERM
cat > "$cpu_demo_dir/worker.py" <<'PYTHON'
import json, pathlib, sys, time
root=pathlib.Path('/data')
name=sys.argv[1]
(root/(name+'.ready')).write_text('ready')
deadline=time.monotonic()+30
while not (root/'go').exists():
    if time.monotonic()>deadline: raise SystemExit('start signal not found')
    time.sleep(0.02)
start=time.perf_counter()
value=0
for i in range(20000000):
    value=(value+i)%1000003
elapsed=time.perf_counter()-start
print(json.dumps({'worker':name,'seconds':round(elapsed,2),'check':value}), flush=True)
PYTHON
docker pull python:3.12-alpine
for cpu_demo_round in unlimited limited; do
  cpu_demo_round_dir="$cpu_demo_dir/$cpu_demo_round-$cpu_demo_token"
  mkdir -p "$cpu_demo_round_dir"
  for cpu_demo_worker in A B; do
    cpu_demo_name="course-share-$cpu_demo_token-$cpu_demo_round-$cpu_demo_worker"
    cpu_demo_names="$cpu_demo_names $cpu_demo_name"
    cpu_demo_limit=""
    if [ "$cpu_demo_round" = limited ] && [ "$cpu_demo_worker" = A ]; then
      cpu_demo_limit="--cpus=0.25"
    fi
    docker run -d --name "$cpu_demo_name" \
      --cpuset-cpus=0 --memory=128m \
      --user "$(id -u):$(id -g)" \
      --mount "type=bind,src=$cpu_demo_dir/worker.py,dst=/worker.py,readonly" \
      --mount "type=bind,src=$cpu_demo_round_dir,dst=/data" \
      $cpu_demo_limit \
      python:3.12-alpine timeout 90 python /worker.py "$cpu_demo_worker" >/dev/null
  done
  cpu_demo_tries=0
  until [ -f "$cpu_demo_round_dir/A.ready" ] && [ -f "$cpu_demo_round_dir/B.ready" ]; do
    cpu_demo_tries=$((cpu_demo_tries+1))
    if [ "$cpu_demo_tries" -gt 200 ]; then
      printf 'Workers not ready; check Docker Desktop and image.\n' >&2
      exit 1
    fi
    sleep 0.1
  done
  if [ "$cpu_demo_round" = unlimited ]; then
    printf '\n[1/2] CPU 사용 시간 제한 없음: A와 B가 CPU 하나를 나눠 사용합니다.\n'
  else
    printf '\n[2/2] 내 작업 A만 CPU 25%% 제한: B에는 CPU 시간 한도를 주지 않습니다.\n'
  fi
  printf '공통 조건: 같은 CPU 하나, 같은 계산량, 메모리 각각 128 MiB\n'
  printf '\n실제 Docker 설정 확인 (0 = CPU 시간 한도 없음):\n'
  for cpu_demo_worker in A B; do
    cpu_demo_name="course-share-$cpu_demo_token-$cpu_demo_round-$cpu_demo_worker"
    cpu_demo_nano="$(docker inspect "$cpu_demo_name" --format '{{.HostConfig.NanoCpus}}')"
    if [ "$cpu_demo_nano" = 0 ]; then
      printf '  작업 %s: CPU 시간 한도 없음 [NanoCPUs=0]\n' "$cpu_demo_worker"
    elif [ "$cpu_demo_nano" = 250000000 ]; then
      printf '  작업 %s: CPU 1개 분량의 25%%까지 [--cpus=0.25]\n' "$cpu_demo_worker"
    else
      printf '예상과 다른 CPU 설정: %s\n' "$cpu_demo_nano" >&2
      exit 1
    fi
  done
  printf '\n계산 시작... 완료될 때까지 기다려 주세요.\n'
  touch "$cpu_demo_round_dir/go"
  printf '%-10s %s\n' '작업' '완료 시간(초)'
  for cpu_demo_worker in A B; do
    cpu_demo_name="course-share-$cpu_demo_token-$cpu_demo_round-$cpu_demo_worker"
    cpu_demo_status="$(docker wait "$cpu_demo_name")"
    cpu_demo_result="$(docker logs "$cpu_demo_name")"
    if [ "$cpu_demo_status" != 0 ]; then
      printf 'Worker %s failed, exit=%s\n' "$cpu_demo_worker" "$cpu_demo_status" >&2
      printf '%s\n' "$cpu_demo_result" >&2
      exit 1
    fi
    cpu_demo_seconds="$(printf '%s\n' "$cpu_demo_result" | sed -n 's/.*"seconds": \([0-9.]*\).*/\1/p')"
    if [ -z "$cpu_demo_seconds" ]; then
      printf '완료 시간을 읽지 못했습니다: %s\n' "$cpu_demo_result" >&2
      exit 1
    fi
    printf '  %-8s %s초\n' "$cpu_demo_worker" "$cpu_demo_seconds"
    case "$cpu_demo_round-$cpu_demo_worker" in
      unlimited-A) cpu_demo_unlimited_A="$cpu_demo_seconds" ;;
      unlimited-B) cpu_demo_unlimited_B="$cpu_demo_seconds" ;;
      limited-A) cpu_demo_limited_A="$cpu_demo_seconds" ;;
      limited-B) cpu_demo_limited_B="$cpu_demo_seconds" ;;
    esac
  done
 done
printf '\n========== 두 실행 비교 ==========\n'
printf '                         내 작업 A       동료 역할 B\n'
printf 'CPU 시간 제한 없음       %s초          %s초\n' "$cpu_demo_unlimited_A" "$cpu_demo_unlimited_B"
printf 'A만 CPU 25%% 제한         %s초          %s초\n' "$cpu_demo_limited_A" "$cpu_demo_limited_B"
awk -v a0="$cpu_demo_unlimited_A" -v a1="$cpu_demo_limited_A" -v b0="$cpu_demo_unlimited_B" -v b1="$cpu_demo_limited_B" 'BEGIN {
  printf "\n관찰 결과: A 완료 시간은 %.2f초 → %.2f초, B는 %.2f초 → %.2f초입니다.\n", a0, a1, b0, b1;
  if (a1 > a0 && b1 < b0) print "A는 더 늦게, B는 더 일찍 끝났습니다. A의 제한으로 B가 계산할 여지가 늘어난 경향을 확인했습니다.";
  else print "이번 측정에서는 예상 경향이 모두 뚜렷하지 않습니다. 다른 PC 작업과 측정 변동을 확인하고 비교하세요.";
}'
printf '25%%는 CPU 한 개 분량의 한도입니다. PC 전체 CPU의 25%%라는 뜻은 아닙니다.\n'
printf '두 실행 모두 같은 CPU 하나에 배치했습니다. 제한 없음도 PC의 모든 CPU를 쓰는 설정은 아닙니다.\n'
