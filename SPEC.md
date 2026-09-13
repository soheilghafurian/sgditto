# sgditto

## Overview

I want to have a command `sgditto` that takes a list of full file and directory paths (as if they were the output of `find .`) and creates an indentation-based file tree.

The command begins as getting the output from the `find` command, but that is only the beginning and it will keep on expanding. Besides `find .`, `gron` is another very common source of input.

## Terminology

- **Input format: path list** — a flat, separator-delimited list of full paths, one per line, exactly the shape `find` produces. "Flat" because it carries no structure of its own; depth is implicit in each line's path.
- **Output format: indent tree** — one path component (basename) per line, with depth encoded purely as leading whitespace, no connector characters. This is what makes it foldable in vim with `:set foldmethod=indent`.
- **gron as a source** — [gron](https://github.com/tomnomnom/gron) turns JSON into lines of `path = value;`, e.g. `json.config.indent = " ";` or `json.authors[0] = "Soheil";`. That's not a plain path list — the `= value;` part isn't part of the path. `sgditto -g` handles this directly: it splits each line on the first `" = "`, uses only the part before it to build the tree, and keeps the rest verbatim on that node's printed line, so nothing is lost (values, `{}`/`[]` container markers, everything is preserved exactly as `gron` wrote it). Raw `gron` output can be piped straight in with no preprocessing: `gron file.json | sgditto -g -s '.'`. Without `-g`, a line's value text (which may itself contain the separator, e.g. `"1.0"`) would get misread as extra path components — `-g` is what prevents that. Array indices such as `authors[0]` are attached to their key without a separator, so they appear as siblings of the key they index into, not nested under it — this is expected, not a bug.
- **Subcommands: `tree` and `paths`** — `sgditto` (or `sgditto tree`, same thing) is the default: path list in, indent tree out. `sgditto paths` is the reverse: indent tree in, path list out. `paths` must be given the same `-i`/`-n`/`-s`/`-g` that were used to build the tree, since those are what tell it how to read the indentation back out — it doesn't guess. `sgditto tree | sgditto paths` (matching options on both sides) round-trips back to the original path list.

## Functional requirements

- [x] The main criteria for that output is that when it is piped to vim, one can do `:set foldmethod=indent` in vim and use vim folding commands to fold and navigate the tree.
- [x] The default options of the command must be such that it always works when the input is the output of the `find` command, like `find . | sgditto`. I shouldn't need to change any options from default when piping from `find .`.
- [x] The command must work whether directory paths end with a `/` (separator) or not.
- [x] The separator between path components must be configurable (default `/`), and may be more than one character.
- [x] The indent string — what gets repeated to build each level's indentation — must be configurable independently of how many times it repeats per level (default: a single space).
- [x] The command must produce a correct tree directly from raw, unmodified `gron` output via `sgditto -g -s '.'`, with nothing discarded — every value and container marker is preserved on its node's line.
- [x] There must be a `sgditto paths` subcommand that reconstructs a path list from an indent tree, reusing the same `-i`/`-n`/`-s`/`-g` options as the `tree` direction.

## Deliverables

- [x] Each time a new feature is added, I want some raw test data to be added, and I want the feature to be tested on that raw data. I want all of these tests concatenated in one md file so I can look at the files and make sure every input-output conversion is according to what I had in mind.
- [x] The command should always have an up to date help option. The help must include a list of examples for the reader to use as a cheat sheet to remember stuff quickly.
- [x] The repo must always have an up to date README.md file. The README must contain how users on both Linux and macOS should install this on their machines so `sgditto` is recognized as a command.

## Rules for sgditto

- Other than what has been specified in the specs, sgditto shouldn't change the content, delete, or add anything. It is just for changing formatting and presentation.

## Rules for Claude

- Don't stage, commit, or push anything on your own unless told specifically.
