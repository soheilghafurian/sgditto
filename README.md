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
brew install sgditto
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
sgditto [-c|-w|-W] [-h] [-V] [FILE...]
```

| Option | Description |
|--------|-------------|
| `-c` | **Character mode** (default) — compare char-by-char |
| `-w` | **Word mode** — tokenize by word boundaries (like vim `w`) |
| `-W` | **WORD mode** — tokenize by whitespace (like vim `W`) |
| `-h`, `--help` | Show help |
| `-V`, `--version` | Show version |

Reads from stdin if no files are given. Use `-` for explicit stdin.

## Modes explained

### Character mode (default, `-c`)

Compares each character position with the line above. The longest matching prefix from the start of the line is replaced with spaces.

```
$ printf "config/settings/production.yml\nconfig/settings/staging.yml\nconfig/defaults.yml\n" | sgditto
config/settings/production.yml
                staging.yml
       defaults.yml
```

### Word mode (`-w`)

Tokenizes by word boundaries: a "word" is a sequence of `[a-zA-Z0-9_]` characters, and each non-word non-whitespace character is a separate token. Matching leading tokens are replaced with spaces.

```
$ printf "error_handler_v2\nerror_handler_v3\n" | sgditto -w
error_handler_v2
error_handler_v3

$ printf "src/foo.js\nsrc/bar.js\n" | sgditto -w
src/foo.js
    bar.js
```

Word mode preserves whole words — a partial character match within a word does **not** get blanked.

### WORD mode (`-W`)

Tokenizes by whitespace (like vim's `W` motion). Each whitespace-delimited chunk is a token. Matching leading tokens are replaced with spaces.

```
$ printf "ERROR server1 connection timeout\nERROR server1 connection refused\nERROR server2 disk full\n" | sgditto -W
ERROR server1 connection timeout
                         refused
      server2 disk full
```

## Examples

### Spot differences in log output

```bash
tail -f app.log | sgditto -W
```

### Compare directory listings

```bash
find . -name "*.go" | sort | sgditto
```

### Pipe with other tools

```bash
env | sort | sgditto
git log --oneline | sgditto
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
