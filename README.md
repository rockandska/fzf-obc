# FZF-OBC (FZF Over Bash Complete)

## What is fzf-obc

A bash completion script intend to add [fzf](https://github.com/junegunn/fzf) over all known bash completion functions on your system with minimal modifications on original completion scripts.  
It is a replacement to the completion script natively provided by [fzf](https://github.com/junegunn/fzf) who replace original completion functions with its own (and create some behavior originally well implemented into original completion scripts).

## Demo

![demo](docs/img/demo.gif)

All functional tests recording as GIF are available [here](docs/src/tests_gallery.md) for review.

## Functionalities

- compatible with almost all linux complete script ( git, docker, ls, cd, vim ....)
- allow recursive path search with `**` for complete scripts who use _filedir / _filedir_xspec
- colorized paths with complete scripts who use _filedir / _filedir_xspec (ls, cd, vi, ....)
- allow `**` to activate multiple selection capability (select multiple containers, select multiple options)
- allow custom sort depending of the command / complete function
- allow replace / modification of the default complete results
- etc ....
