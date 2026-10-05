#!/usr/bin/env bash
set -eu
memory_demo_token="$$"
memory_demo_names=""
cleanup() {
  for memory_demo_name in $memory_demo_names; do
    docker rm -f "$memory_demo_name" >/dev/null 2>&1 || true
  done
}
trap cleanup EXIT INT TERM
docker pull python:3.12-alpine
for memory_demo_limit in 32m 128m; do
  memory_demo_name="course-memory-$memory_demo_token-$memory_demo_limit"
  memory_demo_names="$memory_demo_names $memory_demo_name"
  printf '\nLIMIT: %s\n' "$memory_demo_limit"
  docker run -d --name "$memory_demo_name" \
    --cpus=0.25 --memory="$memory_demo_limit" --memory-swap="$memory_demo_limit" \
    python:3.12-alpine timeout 30 python -u -c \
    'import time; print("Requesting 64 MiB of memory", flush=True); data=bytearray(64*1024*1024); print("Allocation succeeded:", len(data), "bytes", flush=True); time.sleep(2)' >/dev/null
  memory_demo_exit="$(docker wait "$memory_demo_name")"
  docker logs "$memory_demo_name"
  printf 'Exit code: %s\n' "$memory_demo_exit"
  memory_demo_oom="$(docker inspect "$memory_demo_name" --format '{{.State.OOMKilled}}')"
  printf 'OOMKilled: %s\n' "$memory_demo_oom"
  if [ "$memory_demo_limit" = 32m ]; then
    if [ "$memory_demo_oom" != true ]; then
      printf 'Expected OOM was not observed; inspect environment and logs.\n' >&2
      exit 1
    fi
  elif [ "$memory_demo_exit" != 0 ] || [ "$memory_demo_oom" != false ]; then
    printf 'Expected successful allocation was not observed.\n' >&2
    exit 1
  fi
 done
