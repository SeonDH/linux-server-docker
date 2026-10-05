#!/usr/bin/env bash
set -eu
lab_dir="${1:-$HOME/linux-server-lab}"
mkdir -p "$lab_dir"/{input,output,logs,scratch}
if [ -e "$lab_dir/input/samples.tsv" ]; then
  printf 'Existing samples.tsv preserved: %s\n' "$lab_dir"
else
  printf 'sample\tgroup\tcount\nS01\tA\t10\nS02\tB\t20\nS03\tA\t30\n' > "$lab_dir/input/samples.tsv"
fi
printf 'Lab directory: %s\n' "$lab_dir"
