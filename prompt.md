I want to have a command sgditto that takes a list of full file and directory paths (as if they were the output of `find .` and create an indentation based file tree.

The main criteria for that output is that when it is piped to vim, one can do `:set foldmethod=indentation` in vim and use vim folding commands  to fold and navigate the tree.

Each time a new feature is added, I want some raw test data to be added and then I want the feature to be tested on the raw data and I want all of these tests to be concatenated in one md file so that I can look at the files and make sure every input-output ocnversation is according to what I had in mind.
