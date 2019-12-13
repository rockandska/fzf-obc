# Installation 

***Don't forget to check the [prerequisites](prerequisites.md)***  
***Don't forget to deactivate original fzf auto-completion as described in
[prerequisites](prerequisites.md)***

---

## Set the path where to install fzf-obc
```bash
$ INSTALL_PATH=~/.local/opt/fzf-obc
```

## Clone the repository

### use latest source

```bash
$ git clone https://github.com/rockandska/fzf-obc ${INSTALL_PATH}
```

### use a specific release

```bash
$ git clone https://github.com/rockandska/fzf-obc ${INSTALL_PATH}
$ cd ${INSTALL_PATH}
$ git checkout x.x.X
```

## Add fzf-obc to your .bashrc
```bash
$ echo "source ${INSTALL_PATH}/bin/fzf-obc.bash" >> ~/.bashrc
```

**Make sure that fzf-obc is always the last completion script loaded in your
profile**

---

If you start a new shell you should be able to trigger fzf-obc by pressing `<TAB>` (only once) where you have to hit `<TAB>` twice with original bash completion before to see completion proposals.
