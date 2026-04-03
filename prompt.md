I want a bash utility that takes both stdin and text files as intput. For every line, it begins from the beginning of the line and for each character/word, it the charracter/word is the same as the line above, it replaces it with a space. 

We want the default behavior to be character-wise, but we want that to be configurable using CLI options. For word difintion, we want to have both the small definition and the big one.

We want to have unit tests to run and make sure everything works.

We want to push this utility to github (the pushing I will do). Once at github, we want everyone to be able to install this tool using brew and apt (or other linux package management tools).

There should be a README.md file that explains clearly how the tools should be installed and used.

First create a plan and then implement.
