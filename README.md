# sgditto

`sgditto` turns a list of paths (e.g. the output of `find .`) into an
indentation-based file tree. Pipe the result into vim, run
`:set foldmethod=indent`, and use vim's normal folding commands to
fold and navigate the tree like an outline.

```
find . | sgditto
```

`sgditto` is a single POSIX `sh` script that uses only `sh` and `awk`
— both are already present on any Linux or macOS machine, so there's
nothing to build or install beyond copying the file onto your `PATH`.

## Install

### Linux and macOS

1. Clone this repo (or just download the `sgditto` file).
2. Put `sgditto` on your `PATH` and make it executable — either
   system-wide or just for your user.

   System-wide (requires `sudo`):
   ```
   sudo cp sgditto /usr/local/bin/sgditto
   sudo chmod +x /usr/local/bin/sgditto
   ```

   Just for your user (no `sudo` needed):
   ```
   mkdir -p ~/.local/bin
   cp sgditto ~/.local/bin/sgditto
   chmod +x ~/.local/bin/sgditto
   ```
   If you use the user-local option, make sure `~/.local/bin` is on
   your `PATH` — add this to your `~/.bashrc` or `~/.zshrc` if it
   isn't already there, then restart your shell:
   ```
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. Confirm it's recognized:
   ```
   sgditto -h
   ```

## Usage

```
find . | sgditto
```

Then in vim:
```
:set foldmethod=indent
```

See `sgditto -h` for all options (custom indent string, custom repeat
count, custom separator, gron mode) and a full list of examples.

## Formats

- **Input: path list** — a flat, separator-delimited list of full
  paths, one per line, exactly the shape `find` produces.
- **Output: indent tree** — one path component per line, with depth
  encoded purely as leading whitespace (no `tree`-style connector
  characters), which is what makes it foldable in vim.

### Using it with gron

[gron](https://github.com/tomnomnom/gron) is another common source of
input: it turns JSON into lines of `path = value;`, e.g.
`json.config.indent = " ";`. Pipe it straight into `sgditto -g -s .` —
no preprocessing needed:

```
gron file.json | sgditto -g -s .
```

`-g` tells `sgditto` to split each line on the first `" = "`, use only
the part before it to build the tree, and keep everything else
(the value, `{}`/`[]` container markers, all of it) on that node's
printed line, unchanged. Without `-g`, a value's text can itself
contain the separator (e.g. `"1.0"`) and gets misread as extra path
components — `-g` is what avoids that. Array indices like
`authors[0]` are attached to their key without a separator, so they
show up as siblings of the key they index into rather than nested
under it — that's expected.

### Reversing it: tree back to paths

`sgditto paths` is the reverse of `sgditto` (or, spelled out,
`sgditto tree`): it reads an indent tree and reconstructs the path
list it came from. Give it the same `-i`/`-n`/`-s`/`-g` that were
used to build the tree — it reads indentation back out using those,
it doesn't guess:

```
find . | sgditto > tree.txt
sgditto paths < tree.txt
```

Options must match on both sides, so a round trip looks like:

```
find . | sgditto -n 4 | sgditto paths -n 4
```

This also works with `-g`, reconstructing the exact original `gron`
output:

```
gron file.json | sgditto -g -s . | sgditto paths -g -s .
```

## Development

Test fixtures live in `tests/data/`, expected output snapshots in
`tests/expected/`. `tests/verify.sh` runs `sgditto` against every
fixture and reports PASS/FAIL against its snapshot;
`tests/generate_report.sh` concatenates every fixture's input/output
into `tests/report.md` for visual inspection.
