# Triggers Type

`fzf-obc` will let you filtering completion results over fzf when using one of  
the pattern configured for each triggers type

---

## Standard

### Description

- Only one item could be selected.

### Trigger

- Default : `<empty>`
- fzf-obc will be trigger without the need to specify a pattern

Example:
```bash
$ ls /s<TAB>
```

### Default bindings

- The default binding to validate your selection is the key <TAB\> ( you already have your finger on it right ? )

---

## Multi selection

### Description

- Multiple items could be selected.

### Trigger

- Default : `*`
- fzf-obc will be trigger in multiple select mode only if the trigger is  
present at the end of the string before pressing `<TAB>`

Example:
```bash
$ ls /s*<TAB>
```

#### Default bindings

- The default binding to select/unselect an entry and move cursor **down** is the key <TAB\>.  
- The default binding to select/unselect an entry and move cursor **up** is the key <SHIFT\><TAB\>.  
- The default binding to validate your selection is the key <ENTER\>.

---

## Recursive selection

### Description

- Multiple items could be selected.
- Allow recursive files lookup on complete functions used for path/files lookup :
    - _filedir
        - cd
        - ls
        - and more than 400 commands
    - _filedir_xspec
        - vi(m)
        - bunzip2
        - lynx
        - and more than 140 commands

**Be aware that using this capability on huge directories could freeze your shell for ages**

### Trigger

- Default : `**`
- fzf-obc will be trigger in recursive mode only if the trigger is  
present at the end of the string before pressing `<TAB>`

Example:
```bash
$ ls /s**<TAB>
```

### Default bindings

- The default binding to select/unselect an entry and move cursor **down** is the key <TAB\>.  
- The default binding to select/unselect an entry and move cursor **up** is the key <SHIFT\><TAB\>.  
- The default binding to validate your selection is the key <ENTER\>.

---

