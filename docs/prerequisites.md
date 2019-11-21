## Gnu Tools

- awk, find, sed, sort

## Bash

- version \>= 4.0

## Fzf

- version >= 0.18

- fzf-obc require to **not use** the default fzf bash complete script provided with fzf since it change the default complete functions too and fzf-obc needs to be over default complete functions.  
- ***fzf-obc should be the last completion function loaded into your profile.***

---

**If you install fzf for the first time :**  

Follow the [official instructions](https://github.com/junegunn/fzf#using-git) but don't forget to install fzf without its own completion script:

```bash
$ ./install --no-completion
```

instead of

```bash
$ ./install
```

---

**If you already have fzf installed :**  

You surely need to deactivate the auto-completion provided by fzf.  
You could deactivate it inside your fzf config (usually `~/.fzf.bash` or `~/.config/fzf/fzf.bash`) by commenting the auto-completion section.

```bash
# Auto-completion
# ---------------
#[[ $- == *i* ]] && source "~/.local/opt/fzf/shell/completion.bash" 2> /dev/null
```