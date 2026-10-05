#!/usr/bin/env bash
set -eu
cpu_demo_dir="${1:-$HOME/linux-server-lab/cpu-sharing}"
mkdir -p "$cpu_demo_dir"
cpu_demo_dir="$(cd "$cpu_demo_dir" && pwd)"
cpu_demo_token="$$"
cpu_demo_names=""
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
  touch "$cpu_demo_round_dir/go"
  printf '\nROUND: %s\n' "$cpu_demo_round"
  for cpu_demo_worker in A B; do
    cpu_demo_name="course-share-$cpu_demo_token-$cpu_demo_round-$cpu_demo_worker"
    cpu_demo_status="$(docker wait "$cpu_demo_name")"
    docker logs "$cpu_demo_name"
    if [ "$cpu_demo_status" != 0 ]; then
      printf 'Worker %s failed, exit=%s\n' "$cpu_demo_worker" "$cpu_demo_status" >&2
      exit 1
    fi
  done
 done
printf '\nCompare B between rounds; compare A between rounds.\n'
