#!/usr/bin/env bash
# Runs sgditto against every raw test file in tests/data and checks its
# output against the corresponding snapshot in tests/expected. Exits
# non-zero if any fixture's output no longer matches its snapshot.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
data_dir="$script_dir/data"
expected_dir="$script_dir/expected"

fail=0

for data_file in "$data_dir"/*.txt; do
    name="$(basename "$data_file" .txt)"
    expected_file="$expected_dir/$name.txt"

    if [[ ! -f "$expected_file" ]]; then
        echo "MISSING expected/$name.txt (no snapshot to compare against)"
        fail=1
        continue
    fi

    if diff -u "$expected_file" <("$repo_root/sgditto" < "$data_file") > /tmp/sgditto_verify_diff.$$; then
        echo "PASS $name"
    else
        echo "FAIL $name"
        cat /tmp/sgditto_verify_diff.$$
        fail=1
    fi
    rm -f /tmp/sgditto_verify_diff.$$
done

exit "$fail"
