I want to have a command sgditto that takes a list of full file and directory paths (as if they were the output of `find .` and create an indentation based file tree.

The main criteria for that output is that when it is piped to vim, one can do `:set foldmethod=indentation` in vim and use vim folding commands  to fold and navigate the tree.

Each time a new feature is added, I want some raw test data to be added and then I want the feature to be tested on the raw data and I want all of these tests to be concatenated in one md file so that I can look at the files and make sure every input-output ocnversation is according to what I had in mind.

The command begins as getting the output from the `find` command, but that is only the beginning and it will keep on expanding.

# Requirements


- The fefault options of the command must be so that it always works when the input is the output of the find command like this `find . | sgditto`. I shouldn't need to change any options from default when I'm piping from `find .`.
- The command must work whether directory paths end with a `/` (seperator) or not.


# Rules

- Don't stage, commit, or push anything on your own unless told specfically.
- The command should always have an up to date help option. The help must include a list of examples for the reader to use as a cheat sheet to remember stuff quickly.
- The repo must always and an up to date README.md file. The REAADME file must contain how the users on both linux and maxos should install this on the machines so `sgditto` is recognised aaas a command.
