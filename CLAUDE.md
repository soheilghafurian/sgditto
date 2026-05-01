# sgditto

Bash+awk CLI tool that suppresses repeated leading content in consecutive lines.

## Project structure

- `bin/sgditto` — main script (bash wrapper + awk processing)
- `test/test_sgditto.bats` — 39 unit tests (requires bats-core)
- `Makefile` — install/uninstall/test targets
- `Formula/sgditto.rb` — Homebrew formula (head-only, no tagged release yet)
- `.github/workflows/` — CI and release workflows

## CLI

`sgditto [-s SEP] [-k [MODE]] [-h] [-V] [FILE...]`

- Default (no `-s`): character-by-character comparison
- `-s SEP`: split by separator chars (e.g. `-s ','` for CSV, `-s '/'` for paths)
- `-k [MODE]`: control separator visibility in blanked prefix
  - `n`/`none`: replace all separators with spaces (default without `-k`)
  - `l`/`last`: keep only the last separator in the blanked prefix
  - `a`/`all`: keep all separators (default when `-k` is given without MODE)

## Development

- Run tests: `make test` (requires bats-core)
- Install locally: `sudo make install`
- Homebrew: `brew tap soheilghafurian/sgditto https://github.com/soheilghafurian/sgditto && brew install --HEAD sgditto`
- Update after push: `brew uninstall sgditto && brew install --HEAD sgditto`

## Owner

GitHub: soheilghafurian
