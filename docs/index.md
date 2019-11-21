## What is fzf-obc

A bash completion script intend to add [fzf](https://github.com/junegunn/fzf) over all known bash completion functions on your system with minimal modifications on original completion scripts.  
It is a replacement to the completion script natively provided by [fzf](https://github.com/junegunn/fzf) who replace original completion functions with its own (and create some behavior originally well implemented into original completion scripts).

## Demo

![demo](img/demo.gif)

## Functionalities

- Compatible with almost all linux complete script ( git, docker, ls, cd, vim ....)
- Recursive path search by adding `**` for completion scripts who use _filedir / _filedir_xspec
- Colorized paths with completion scripts who use _filedir / _filedir_xspec (ls, cd, vi, ....)
- Allow multiple selection capability by adding `**` (select multiple containers, select multiple options)
- Allow custom sort depending on the command / complete function
- Allow modifications of the default complete results
- etc ....
