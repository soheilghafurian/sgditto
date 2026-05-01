# sgditto

Suppress repeated leading content in consecutive lines by replacing matching prefixes with spaces, making differences easy to spot.

```
$ ls /usr/local/bin/ba*
/usr/local/bin/bash
/usr/local/bin/bashbug

$ ls /usr/local/bin/ba* | sgditto
/usr/local/bin/bash
               bashbug
```

## Installation

### Homebrew (macOS / Linux)

```bash
brew tap soheilghafurian/sgditto https://github.com/soheilghafurian/sgditto
brew install --HEAD sgditto
```

### From source (any platform)

```bash
git clone https://github.com/soheilghafurian/sgditto.git
cd sgditto
sudo make install
```

This installs to `/usr/local/bin`. Change the prefix with:

```bash
sudo make install PREFIX=/usr
```

### Direct download

```bash
curl -fsSL https://raw.githubusercontent.com/soheilghafurian/sgditto/main/bin/sgditto \
  -o /usr/local/bin/sgditto && chmod +x /usr/local/bin/sgditto
```

### Uninstall

```bash
sudo make uninstall          # if installed from source
brew uninstall sgditto       # if installed via Homebrew
```

## Usage

```
sgditto [-s SEP] [-k [MODE]] [-h] [-V] [FILE...]
```

| Option | Description |
|--------|-------------|
| `-s SEP` | Split lines by separator characters in SEP. Each character in SEP is an independent separator. Default: `''` (character-by-character comparison). |
| `-k`, `--keep-sep` `[MODE]` | Control which separators stay visible in the blanked prefix. MODE: `n`/`none` (replace all, default without `-k`), `l`/`last` (keep only the last separator), `a`/`all` (keep all separators). Bare `-k` defaults to `all`. |
| `-h`, `--help` | Show help |
| `-V`, `--version` | Show version |

Reads from stdin if no files are given. Use `-` for explicit stdin.

## How it works

### Default: character-by-character

With no `-s` option, each character position is compared with the line above. The longest matching prefix is replaced with spaces.

```
$ printf "config/settings/production.yml\nconfig/settings/staging.yml\nconfig/defaults.yml\n" | sgditto
config/settings/production.yml
                staging.yml
       defaults.yml
```

### Separator mode (`-s`)

With `-s`, lines are split into tokens by the given separator character(s). Matching leading tokens are replaced with spaces.

#### CSV (comma separator)

```
$ printf "John,Smith,42,NY\nJohn,Smith,35,CA\nJohn,Doe,28,TX\n" | sgditto -s ','
John,Smith,42,NY
           35,CA
     Doe,28,TX
```

#### Paths (slash separator)

```
$ printf "/usr/local/bin/bash\n/usr/local/bin/dash\n/usr/local/sbin/zsh\n" | sgditto -s '/'
/usr/local/bin/bash
               dash
           sbin/zsh
```

#### TSV (tab separator)

```bash
sgditto -s $'\t' data.tsv
```

#### Multiple separators

Each character in the SEP string is an independent separator:

```
$ printf "host1:8080|ok\nhost1:8080|err\nhost2:9090|ok\n" | sgditto -s ':|'
host1:8080|ok
            err
host2:9090|ok
```

### Keep separators visible (`-k`)

By default, separators in the matching prefix are replaced with spaces. Use `-k` to keep some or all of them, which helps maintain visual structure.

#### Keep all separators (`-k` or `-k all`)

```
$ printf "John,Smith,42\nJohn,Smith,35\nJohn,Doe,28\n" | sgditto -s ',' -k
John,Smith,42
    ,     ,35
    ,Doe,28
```

```
$ printf "/usr/local/bin/bash\n/usr/local/bin/dash\n" | sgditto -s '/' -k
/usr/local/bin/bash
/   /     /   /dash
```

#### Keep only the last separator (`-k last`)

Keeps just the separator before the first difference, giving a lighter visual anchor:

```
$ printf "John,Smith,42\nJohn,Smith,35\nJohn,Doe,28\n" | sgditto -s ',' -k last
John,Smith,42
          ,35
    ,Doe,28
```

```
$ printf "/usr/local/bin/bash\n/usr/local/bin/dash\n" | sgditto -s '/' -k last
/usr/local/bin/bash
              /dash
```

## Examples

### Spot differences in log output

```bash
tail -f app.log | sgditto -s ' '
```

### Compare sorted environment variables

```bash
env | sort | sgditto -s '='
```

### Directory listings

```bash
find . -name "*.go" | sort | sgditto -s '/'
```

### CSV diffs with structure

```bash
sgditto -s ',' -k data.csv        # keep all separators
sgditto -s ',' -k last data.csv   # keep only the last separator
```

## Running tests

Tests use [bats-core](https://github.com/bats-core/bats-core):

```bash
# Install bats
brew install bats-core    # macOS
sudo apt install bats     # Debian/Ubuntu

# Run tests
make test
```

## License

MIT
