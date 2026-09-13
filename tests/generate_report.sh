#!/usr/bin/env bash
# Runs sgditto against every raw test file in tests/data and concatenates
# each input/output pair into tests/report.md for visual inspection.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
data_dir="$script_dir/data"
report="$script_dir/report.md"

{
    echo "# sgditto test report"
    echo
    echo "Generated from the raw path lists in \`tests/data/\` by running"
    echo "\`tests/generate_report.sh\`. Each section shows the raw input"
    echo "(a path list, as \`find .\` would produce) and the tree sgditto"
    echo "builds from it."
} > "$report"

for data_file in "$data_dir"/*.txt; do
    name="$(basename "$data_file" .txt)"
    title="$(echo "${name#*_}" | tr '_' ' ')"
    {
        echo
        echo "## $title"
        echo
        echo "Input (\`tests/data/$(basename "$data_file")\`):"
        echo
        echo '```'
        cat "$data_file"
        echo '```'
        echo
        echo "Output:"
        echo
        echo '```'
        "$repo_root/sgditto" < "$data_file"
        echo '```'
    } >> "$report"
done

echo "Wrote $report"
