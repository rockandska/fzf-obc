# User configuration

## Override config

- User has the possibility to place all its personal `fzf-obc`  
configurations in `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/`.  
- User configuration is dynamic and is load each time a completion is asked and  
does not require to reload fzf-obc when the configuration is changed.
- Each trigger type has its own configuration
- The configuration could be changed at 3 level (global,complete function,
    command). The configuration are loaded in the following order :
    - `fzf-obc default install config`
    - `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg`
    - `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/[complete function].cfg`
    - `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/[command].cfg`

## Settings

Each setting are available for each trigger type and could be set indenpendently

### enable

- should we display completion results with fzf-obc or not
- standard trigger:
    - default : `1`
    - config variables :
        - `std_enable`
        - `FZF_OBC_STD_ENABLE`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_enable`
        - `FZF_OBC_MLT_ENABLE`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_enable`
        - `FZF_OBC_REC_ENABLE`

### fzf_trigger

- Which pattern will trigger fzf-obc in which mode when asking for a completion
- standard trigger:
    - default : `<empty>`
    - config variables :
        - `std_fzf_trigger`
        - `FZF_OBC_STD_FZF_TRIGGER`
- multi selection trigger
    - default : `*`
    - config variables :
        - `mlt_fzf_trigger`
        - `FZF_OBC_MLT_FZF_TRIGGER`
- recursive trigger
    - default : `**`
    - config variables :
        - `rec_fzf_trigger`
        - `FZF_OBC_REC_FZF_TRIGGER`

### fzf_multi

- should we enable multiple selection when displaying results with fzf
- standard trigger:
    - default : `0`
    - config variables :
        - `std_fzf_multi`
        - `FZF_OBC_STD_FZF_MULTI`
- multi selection trigger
    - default : `1`
    - config variables :
        - `mlt_fzf_multi`
        - `FZF_OBC_MLT_FZF_MULTI`
- recursive trigger
    - default : `1`
    - config variables :
        - `rec_fzf_multi`
        - `FZF_OBC_REC_FZF_MULTI`

### fzf_opts

- defaults options for fzf
- standard trigger:
    - default : `--select-1 --exit-0 --no-sort`
    - config variables :
        - `std_fzf_opts`
        - `FZF_OBC_STD_FZF_OPTS`
        - `FZF_OBC_OPTS`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_opts`
        - `FZF_OBC_MLT_FZF_OPTS`
        - `FZF_OBC_OPTS`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_opts`
        - `FZF_OBC_REC_FZF_OPTS`
        - `FZF_OBC_GLOBS_OPTS`

### fzf_binds

- Bindings used with fzf when displaying results
- standard trigger:
    - default : `--bind tab:accept' 'FZF_OBC_BINDINGS`
    - config variables :
        - `std_fzf_binds`
        - `FZF_OBC_STD_FZF_BINDS`
        - `FZF_OBC_BINDINGS`
- multi selection trigger
    - default : `--bind tab:toggle+down;shift-tab:toggle+up`
    - config variables :
        - `mlt_fzf_binds`
        - `FZF_OBC_MLT_FZF_BINDS`
        - `FZF_OBC_GLOBS_BINDINGS`
- recursive trigger
    - default : 
        - inherited from multi selection trigger if multi selection is ON for
            recursive mode
        - inherited from standard trigger if multi selection is OFF for recusrive
            mode
    - config variables :
        - `rec_fzf_binds`
        - `FZF_OBC_REC_FZF_BINDS`

### fzf_size

- Size of the fzf window when displaying results
- standard trigger:
    - default : `40%`
    - config variables :
        - `std_fzf_size`
        - `FZF_OBC_STD_FZF_SIZE`
        - `FZF_OBC_HEIGHT`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_size`
        - `FZF_OBC_MLT_FZF_SIZE`
        - `FZF_OBC_HEIGHT`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_size`
        - `FZF_OBC_REC_FZF_SIZE`
        - `FZF_OBC_HEIGHT`

### fzf_position

- Position of the fzf window when displaying results (only with tmux)
- standard trigger:
    - default : `r`
    - config variables :
        - `std_fzf_position`
        - `FZF_OBC_STD_FZF_POSITION`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_position`
        - `FZF_OBC_MLT_FZF_POSITION`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_position`
        - `FZF_OBC_REC_FZF_POSITION`

### fzf_tmux

- Should we display the fzf window in a tmux pane or not (only with tmux)
- standard trigger:
    - default : `1`
    - config variables :
        - `std_fzf_tmux`
        - `FZF_OBC_STD_FZF_TMUX`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_tmux`
        - `FZF_OBC_MLT_FZF_TMUX`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_tmux`
        - `FZF_OBC_REC_FZF_TMUX`

### sort_opts

- Which options to use with gnu sort when displaying the results
- standard trigger:
    - default :  `-Vdf`
    - config variables :
        - `std_sort_opts`
        - `FZF_OBC_STD_SORT_OPTS`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_sort_opts`
        - `FZF_OBC_MLT_SORT_OPTS`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_sort_opts`
        - `FZF_OBC_REC_SORT_OPTS`

### filedir_short

- Should we display the path as the original complete or the full path
- standard trigger:
    - default : `1`
    - config variables :
        - `std_filedir_short`
        - `FZF_OBC_STD_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_short`
        - `FZF_OBC_MLT_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_short`
        - `FZF_OBC_REC_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR`

### filedir_colors

- Should we colorized files/paths when displaying the results
- standard trigger:
    - default : `1`
    - config variables :
        - `std_filedir_colors`
        - `FZF_OBC_STD_FILEDIR_COLORS`
        - `FZF_OBC_COLORS`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_colors`
        - `FZF_OBC_MLT_FILEDIR_COLORS`
        - `FZF_OBC_COLORS`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_colors`
        - `FZF_OBC_REC_FILEDIR_COLORS`
        - `FZF_OBC_GLOBS_COLORS`

### filedir_hidden_first

- Should we put hidden files/directories first in results, at the end, or untouched
- Could be `0`,`1`,`<empty>`
- standard trigger:
    - default : `0`
    - config variables :
        - `std_filedir_hidden_first`
        - `FZF_OBC_STD_FILEDIR_HIDDEN_FIRST`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_hidden_first`
        - `FZF_OBC_MLT_FILEDIR_HIDDEN_FIRST`
- recursive trigger
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_hidden_first`
        - `FZF_OBC_REC_FILEDIR_HIDDEN_FIRST`

### filedir_maxdepth

- Maximum depth for files/paths lookup
- standard trigger:
    - default : `1`
    - config variables :
        - `std_filedir_maxdepth`
        - `FZF_OBC_STD_FILEDIR_MAXDEPTH`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_maxdepth`
        - `FZF_OBC_MLT_FILEDIR_MAXDEPTH`
- recursive trigger
    - default : `999999`
    - config variables :
        - `rec_filedir_maxdepth`
        - `FZF_OBC_REC_FILEDIR_MAXDEPTH`
        - `FZF_OBC_GLOBS_MAXDEPTH`

### filedir_exclude_path

- Paths to exclude with files/paths lookup
- standard trigger:
    - default : `<empty>`
    - config variables :
        - `std_filedir_exclude_path`
        - `FZF_OBC_STD_FILEDIR_EXCLUDE_PATH`
- multi selection trigger
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_exclude_path`
        - `FZF_OBC_MLT_FILEDIR_EXCLUDE_PATH`
- recursive trigger
    - default : `.git:.svn`
    - config variables :
        - `rec_filedir_exclude_path`
        - `FZF_OBC_REC_FILEDIR_EXCLUDE_PATH`
        - `FZF_OBC_EXCLUDE_PATH`

## Examples

### Disable fzf-obc over git command and use "original" completion 

```shell
$ cat > ${HOME}/.config/fzf-obc/git.cfg
# Disable fzf-obc on std trigger
std_enable=0
# Since mlt_enable / rec_enable take by default the value of std_enable
# No need to add
# mlt_enable=0
# rec_enable=0
```

### Use space with standard trigger for all commands to validate selection in fzf instead of <TAB\>

```shell
cat > ${HOME}/.config/fzf-obc/default.cfg
std_fzf_binds='--bind space:accept'
```
