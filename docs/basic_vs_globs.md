#### Difference with original bash completion

**/!\ The completion suggestion will be displayed after the first hit on
`<TAB>` against the usual `<TAB><TAB>`**

So you will maybe hit this ['issue'](https://github.com/rockandska/fzf-obc/issues/22) and will need to change the defaults
`fzf-obc` accept binding as suggest in the issue report.

#### Basic

This behavior is the default one.  
[fzf](https://github.com/junegunn/fzf) will be trigger over `$COMPREPLY` to let you filter the result easily.  
The default binding to select an entry is the key <TAB\> ( you already have your finger on it right ? )

#### Globs

Adding `**` at the end of the cursor before pressing <TAB\> activate the GLOB completion.

It have multiple effects depending on the situation :

- Allow recursive and multiple selection on complete functions used for path/files lookup :
    - _filedir
        - cd
        - ls
        - and more than 400 commands
    - _filedir_xspec
        - vi(m)
        - bunzip2
        - lynx
        - and more than 140 commands
- Allow multiple selection with all commands
    - select multiple docker containers to start/stop
    - select multiple options for tar
    - and more....
- If there is no results, you will be aware by seeing the `\*\*` removed from your current search

**Be aware that using this capability on huge directories could freeze your shell for ages**

**The bindings with globs are different ( <TAB\>, <SHIFT-TAB\> are used to (un)select multiples results and <ENTER\> to validate )**
