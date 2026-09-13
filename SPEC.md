# sgditto

## Overview

I want to have a command `sgditto` that takes a list of full file and directory paths (as if they were the output of `find .`) and creates an indentation-based file tree.

The command begins as getting the output from the `find` command, but that is only the beginning and it will keep on expanding.

## Functional requirements

- [x] The main criteria for that output is that when it is piped to vim, one can do `:set foldmethod=indent` in vim and use vim folding commands to fold and navigate the tree.
- [x] The default options of the command must be such that it always works when the input is the output of the `find` command, like `find . | sgditto`. I shouldn't need to change any options from default when piping from `find .`.
- [x] The command must work whether directory paths end with a `/` (separator) or not.

## Deliverables

- [x] Each time a new feature is added, I want some raw test data to be added, and I want the feature to be tested on that raw data. I want all of these tests concatenated in one md file so I can look at the files and make sure every input-output conversion is according to what I had in mind.
- [x] The command should always have an up to date help option. The help must include a list of examples for the reader to use as a cheat sheet to remember stuff quickly.
- [x] The repo must always have an up to date README.md file. The README must contain how users on both Linux and macOS should install this on their machines so `sgditto` is recognized as a command.

## Rules for Claude

- Don't stage, commit, or push anything on your own unless told specifically.
