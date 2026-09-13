I want to have a command sgditto that takes a list of full file and directory paths (as if they were the output of `find .` and create an indentation based file tree.

The main criteria for that output is that when it is piped to vim, one can do `:set foldmethod=indentation` in vim and use vim folding commands  to fold and navigate the tree.
