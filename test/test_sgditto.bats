#!/usr/bin/env bats

setup() {
    SGDITTO="$BATS_TEST_DIRNAME/../bin/sgditto"
}

# ── Character mode (default) ────────────────────────────────────

@test "char: single line is unchanged" {
    run bash -c 'echo "hello" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "$output" = "hello" ]
}

@test "char: two identical lines" {
    run bash -c 'printf "hello\nhello" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "hello" ]
    [ "${lines[1]}" = "     " ]
}

@test "char: common prefix replaced with spaces" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "/usr/local/bin/bash" ]
    [ "${lines[1]}" = "               dash" ]
}

@test "char: no common prefix" {
    run bash -c 'printf "abc\nxyz" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "abc" ]
    [ "${lines[1]}" = "xyz" ]
}

@test "char: three consecutive lines" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash\n/usr/local/sbin/zsh" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "/usr/local/bin/bash" ]
    [ "${lines[1]}" = "               dash" ]
    [ "${lines[2]}" = "           sbin/zsh" ]
}

@test "char: current line shorter than previous" {
    run bash -c 'printf "abcdef\nabc" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "abcdef" ]
    [ "${lines[1]}" = "   " ]
}

@test "char: current line longer than previous" {
    run bash -c 'printf "abc\nabcdef" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "abc" ]
    [ "${lines[1]}" = "   def" ]
}

@test "char: empty line after non-empty" {
    run bash -c 'printf "hello\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "hello" ]
    [ "${lines[1]}" = "" ]
}

@test "char: non-empty after empty" {
    result=$(printf "\nhello" | "$SGDITTO")
    expected=$(printf "\nhello")
    [ "$result" = "$expected" ]
}

@test "char: explicit -c flag works" {
    run bash -c 'printf "abc\nabd" | "$1" -c' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "  d" ]
}

# ── Small word mode (-w) ────────────────────────────────────────

@test "word: matching word prefix" {
    run bash -c 'printf "the quick brown fox\nthe quick red fox" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "the quick brown fox" ]
    [ "${lines[1]}" = "          red fox" ]
}

@test "word: path with slash separators" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "               dash" ]
}

@test "word: no matching words" {
    run bash -c 'printf "hello world\ngoodbye earth" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "goodbye earth" ]
}

@test "word: all words match" {
    run bash -c 'printf "foo bar\nfoo bar" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "       " ]
}

@test "word: word chars vs non-word treats differently than char mode" {
    # In char mode "foobar" vs "foobaz" matches prefix "fooba"
    # In word mode "foobar" is one token, doesn't match "foobaz"
    run bash -c 'printf "foobar\nfoobaz" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "foobaz" ]
}

@test "word: punctuation as separate tokens" {
    run bash -c 'printf "foo.bar\nfoo.baz" | "$1" -w' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    # tokens: foo . bar vs foo . baz → foo and . match, bar vs baz mismatch
    [ "${lines[1]}" = "    baz" ]
}

# ── Big word mode (-W) ──────────────────────────────────────────

@test "WORD: matching token prefix in log lines" {
    run bash -c 'printf "ERROR server1 connection timeout\nERROR server1 connection refused" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "ERROR server1 connection timeout" ]
    [ "${lines[1]}" = "                         refused" ]
}

@test "WORD: no matching tokens" {
    run bash -c 'printf "foo bar\nbaz qux" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "baz qux" ]
}

@test "WORD: all tokens match" {
    run bash -c 'printf "foo bar baz\nfoo bar baz" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "           " ]
}

@test "WORD: punctuation is part of token" {
    # In WORD mode, "foo.bar" is one token
    run bash -c 'printf "foo.bar baz\nfoo.bar qux" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "        qux" ]
}

@test "WORD: three lines chained" {
    run bash -c 'printf "ERROR server1 connection timeout\nERROR server1 connection refused\nERROR server2 disk full" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "ERROR server1 connection timeout" ]
    [ "${lines[1]}" = "                         refused" ]
    [ "${lines[2]}" = "      server2 disk full" ]
}

@test "WORD: curr has more tokens than prev" {
    run bash -c 'printf "a b\na b c" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    c" ]
}

@test "WORD: curr has fewer tokens than prev" {
    run bash -c 'printf "a b c\na b" | "$1" -W' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   " ]
}

# ── CLI options ─────────────────────────────────────────────────

@test "help flag shows usage" {
    run "$SGDITTO" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "version flag shows version" {
    run "$SGDITTO" -V
    [ "$status" -eq 0 ]
    [[ "$output" == *"0.1.0"* ]]
}

@test "invalid flag returns error" {
    run "$SGDITTO" -Z
    [ "$status" -eq 1 ]
    [[ "$output" == *"unknown option"* ]]
}

@test "reads from file argument" {
    tmpfile=$(mktemp)
    printf "abc\nabd" > "$tmpfile"
    run "$SGDITTO" "$tmpfile"
    rm -f "$tmpfile"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "abc" ]
    [ "${lines[1]}" = "  d" ]
}

@test "reads from multiple files" {
    tmp1=$(mktemp)
    tmp2=$(mktemp)
    printf "abc\n" > "$tmp1"
    printf "abd\n" > "$tmp2"
    run "$SGDITTO" "$tmp1" "$tmp2"
    rm -f "$tmp1" "$tmp2"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "abc" ]
    [ "${lines[1]}" = "  d" ]
}

# ── Edge cases ──────────────────────────────────────────────────

@test "empty input produces no output" {
    run bash -c 'printf "" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "single empty line" {
    run bash -c 'printf "\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "" ]
}

@test "two empty lines" {
    run bash -c 'printf "\n\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "" ]
    [ "${lines[1]}" = "" ]
}
