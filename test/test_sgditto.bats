#!/usr/bin/env bats

setup() {
    SGDITTO="$BATS_TEST_DIRNAME/../bin/sgditto"
}

# ── Character mode (default, no -s) ─────────────────────────────

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

# ── Separator mode: comma ───────────────────────────────────────

@test "sep comma: matching prefix tokens" {
    run bash -c 'printf "John,Smith,42,NY\nJohn,Smith,35,CA" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "John,Smith,42,NY" ]
    [ "${lines[1]}" = "           35,CA" ]
}

@test "sep comma: no matching tokens" {
    run bash -c 'printf "a,b,c\nx,y,z" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "x,y,z" ]
}

@test "sep comma: all tokens match" {
    run bash -c 'printf "a,b,c\na,b,c" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "     " ]
}

@test "sep comma: curr has more tokens" {
    run bash -c 'printf "a,b\na,b,c" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   ,c" ]
}

@test "sep comma: curr has fewer tokens" {
    run bash -c 'printf "a,b,c\na,b" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   " ]
}

@test "sep comma: three lines chained" {
    run bash -c 'printf "a,b,c\na,b,d\na,x,y" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "a,b,c" ]
    [ "${lines[1]}" = "    d" ]
    [ "${lines[2]}" = "  x,y" ]
}

@test "sep comma: empty tokens (consecutive separators)" {
    run bash -c 'printf "a,,b\na,,c" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   c" ]
}

@test "sep comma: leading separator" {
    run bash -c 'printf ",a,b\n,a,c" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   c" ]
}

# ── Separator mode: slash (paths) ──────────────────────────────

@test "sep slash: path prefix" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash" | "$1" -s "/"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "               dash" ]
}

@test "sep slash: diverging paths" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/sbin/zsh" | "$1" -s "/"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "           sbin/zsh" ]
}

# ── Separator mode: tab (TSV) ──────────────────────────────────

@test "sep tab: matching columns" {
    result=$(printf "name\tcity\tage\nname\tcity\tscore" | "$SGDITTO" -s $'\t')
    expected=$(printf "name\tcity\tage\n          score")
    [ "$result" = "$expected" ]
}

# ── Separator mode: multiple separators ─────────────────────────

@test "sep multi: colon and pipe" {
    run bash -c 'printf "a:b|c\na:b|d" | "$1" -s ":|"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    d" ]
}

@test "sep multi: comma and semicolon" {
    run bash -c 'printf "a,b;c\na,b;d" | "$1" -s ",;"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    d" ]
}

@test "sep multi: different seps at same position still match" {
    # prev uses , but curr uses ; at same position — both are separators
    run bash -c 'printf "a,b\na;c" | "$1" -s ",;"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "  c" ]
}

# ── Keep-sep mode: all (-k / -k all / -k a) ───────────────────

@test "keep-sep all: commas preserved" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    ,     ,35" ]
}

@test "keep-sep all: slashes preserved" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash" | "$1" -s "/" -k' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "/   /     /   /dash" ]
}

@test "keep-sep all: tabs preserved" {
    result=$(printf "name\tcity\tage\nname\tcity\tscore" | "$SGDITTO" -s $'\t' -k)
    expected=$(printf "name\tcity\tage\n    \t    \tscore")
    [ "$result" = "$expected" ]
}

@test "keep-sep all: all tokens match" {
    run bash -c 'printf "a,b,c\na,b,c" | "$1" -s "," -k' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = " , , " ]
}

@test "keep-sep all: no match prints line as-is" {
    run bash -c 'printf "a,b\nx,y" | "$1" -s "," -k' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "x,y" ]
}

@test "keep-sep all: explicit 'all' same as bare -k" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k all' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    ,     ,35" ]
}

@test "keep-sep all: shortcut 'a' same as bare -k" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k a' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "    ,     ,35" ]
}

# ── Keep-sep mode: last (-k last / -k l) ──────────────────────

@test "keep-sep last: only last comma kept" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "          ,35" ]
}

@test "keep-sep last: only last slash kept" {
    run bash -c 'printf "/usr/local/bin/bash\n/usr/local/bin/dash" | "$1" -s "/" -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "              /dash" ]
}

@test "keep-sep last: shortcut 'l' works" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k l' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "          ,35" ]
}

@test "keep-sep last: single separator" {
    run bash -c 'printf "a,b\na,c" | "$1" -s "," -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = " ,c" ]
}

@test "keep-sep last: no match prints line as-is" {
    run bash -c 'printf "a,b\nx,y" | "$1" -s "," -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "x,y" ]
}

@test "keep-sep last: all tokens match" {
    run bash -c 'printf "a,b,c\na,b,c" | "$1" -s "," -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "   , " ]
}

@test "keep-sep last: three lines chained" {
    run bash -c 'printf "a,b,c\na,b,d\na,x,y" | "$1" -s "," -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "a,b,c" ]
    [ "${lines[1]}" = "   ,d" ]
    [ "${lines[2]}" = " ,x,y" ]
}

# ── Keep-sep mode: none (-k none / -k n) ──────────────────────

@test "keep-sep none: same as no -k flag" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k none' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "           35" ]
}

@test "keep-sep none: shortcut 'n' works" {
    run bash -c 'printf "John,Smith,42\nJohn,Smith,35" | "$1" -s "," -k n' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[1]}" = "           35" ]
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
    [[ "$output" == *"0.2.0"* ]]
}

@test "invalid flag returns error" {
    run "$SGDITTO" -Z
    [ "$status" -eq 1 ]
    [[ "$output" == *"unknown option"* ]]
}

@test "reads from file argument" {
    tmpfile=$(mktemp)
    printf "abc\nabd\n" > "$tmpfile"
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

@test "-s missing argument gives error" {
    run "$SGDITTO" -s
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires an argument"* ]]
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

@test "sep mode: empty input" {
    run bash -c 'printf "" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "sep mode: single line unchanged" {
    run bash -c 'printf "a,b,c" | "$1" -s ","' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "$output" = "a,b,c" ]
}

# ── Unicode / wide character alignment ────────────────────────────

@test "char: 3-byte emoji aligned correctly" {
    run bash -c 'printf "✅ abc\n✅ xyz\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ abc" ]
    [ "${lines[1]}" = "   xyz" ]
}

@test "char: 4-byte emoji aligned correctly" {
    run bash -c 'printf "🔴 abc\n🔴 xyz\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "🔴 abc" ]
    [ "${lines[1]}" = "   xyz" ]
}

@test "sep: 3-byte emoji prefix aligned" {
    run bash -c 'printf "✅ abc:def\n✅ abc:xyz\n" | "$1" -s ":"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ abc:def" ]
    [ "${lines[1]}" = "       xyz" ]
}

@test "sep: 4-byte emoji prefix aligned" {
    run bash -c 'printf "🔴 abc:def\n🔴 abc:xyz\n" | "$1" -s ":"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "🔴 abc:def" ]
    [ "${lines[1]}" = "       xyz" ]
}

@test "sep: mixed emoji lines stay independent" {
    run bash -c 'printf "✅ abc:def\n🔴 abc:xyz\n" | "$1" -s ":"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ abc:def" ]
    [ "${lines[1]}" = "🔴 abc:xyz" ]
}

@test "char: CJK wide characters aligned" {
    run bash -c 'printf "日本語abc\n日本語xyz\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "日本語abc" ]
    [ "${lines[1]}" = "      xyz" ]
}

@test "keep-sep all: emoji prefix with separators preserved" {
    run bash -c 'printf "✅ a:b:c\n✅ a:b:z\n" | "$1" -s ":" -k' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ a:b:c" ]
    [ "${lines[1]}" = "    : :z" ]
}

@test "keep-sep last: emoji prefix only last separator kept" {
    run bash -c 'printf "✅ a:b:c\n✅ a:b:z\n" | "$1" -s ":" -k last' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ a:b:c" ]
    [ "${lines[1]}" = "      :z" ]
}

@test "char: emoji entire line match" {
    run bash -c 'printf "✅ abc\n✅ abc\n" | "$1"' -- "$SGDITTO"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "✅ abc" ]
    [ "${lines[1]}" = "      " ]
}
