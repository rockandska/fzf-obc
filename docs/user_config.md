# User configuration

## Override config

- User has the possibility to place all its personal `fzf-obc`  configurations in  `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/`.  
- User configuration is dynamic and is load each time a completion is asked and does not require to reload fzf-obc when the configuration is changed.
- Each trigger type has its own configuration
- The configuration could be changed on :
    - Global level : `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/default.cfg`
    - Command level : `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/[command].cfg`
    - Global plugins level : `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/default.cfg`
    - Command plugins level : `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/[command]/default.cfg`
    - Specific command plugin level : `${XDG_CONFIG_HOME:-$HOME/.config}/fzf-obc/plugins/[command]/[plugin].cfg`
- Disable `fzf-obc` on a level will have the effect to do not load all the configuration related to the level disabled.

## Settings

Each setting are available for each trigger type and could be set independently

### enable

- should we display completion results with fzf-obc or not
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `1`
    - config variables :
        - `std_enable`
        - `FZF_OBC_STD_ENABLE`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_enable`
        - `FZF_OBC_MLT_ENABLE`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_enable`
        - `FZF_OBC_REC_ENABLE`

### fzf_trigger

- Which pattern will trigger fzf-obc in which mode when asking for a completion
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `<empty>`
    - config variables :
        - `std_fzf_trigger`
        - `FZF_OBC_STD_FZF_TRIGGER`
- **multi selection trigger**
    - default : `*`
    - config variables :
        - `mlt_fzf_trigger`
        - `FZF_OBC_MLT_FZF_TRIGGER`
- **recursive trigger**
    - default : `**`
    - config variables :
        - `rec_fzf_trigger`
        - `FZF_OBC_REC_FZF_TRIGGER`

### fzf_multi

- should we enable multiple selection when displaying results with fzf
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `0`
    - config variables :
        - `std_fzf_multi`
        - `FZF_OBC_STD_FZF_MULTI`
- **multi selection trigger**
    - default : `1`
    - config variables :
        - `mlt_fzf_multi`
        - `FZF_OBC_MLT_FZF_MULTI`
- **recursive trigger**
    - default : `1`
    - config variables :
        - `rec_fzf_multi`
        - `FZF_OBC_REC_FZF_MULTI`

### fzf_opts

- defaults options for fzf
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `--select-1 --exit-0 --no-sort`
    - config variables :
        - `std_fzf_opts`
        - `FZF_OBC_STD_FZF_OPTS`
        - `FZF_OBC_OPTS` (***deprecated***)
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_opts`
        - `FZF_OBC_MLT_FZF_OPTS`
        - `FZF_OBC_OPTS` (***deprecated***)
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_opts`
        - `FZF_OBC_REC_FZF_OPTS`
        - `FZF_OBC_GLOBS_OPTS` (***deprecated***)

### fzf_binds

- Bindings used with fzf when displaying results
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `--bind tab:accept' 'FZF_OBC_BINDINGS`
    - config variables :
        - `std_fzf_binds`
        - `FZF_OBC_STD_FZF_BINDS`
        - `FZF_OBC_BINDINGS` (***deprecated***)
- **multi selection trigger**
    - default : `--bind tab:toggle+down;shift-tab:toggle+up`
    - config variables :
        - `mlt_fzf_binds`
        - `FZF_OBC_MLT_FZF_BINDS`
        - `FZF_OBC_GLOBS_BINDINGS` (***deprecated***)
- **recursive trigger**
    - default : 
        - inherited from multi selection trigger if multi selection is ON for
            recursive mode
        - inherited from standard trigger if multi selection is OFF for recursive
            mode
    - config variables :
        - `rec_fzf_binds`
        - `FZF_OBC_REC_FZF_BINDS` (***deprecated***)

### fzf_size

- Size of the fzf window when displaying results
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger:**
    - default : `40%`
    - config variables :
        - `std_fzf_size`
        - `FZF_OBC_STD_FZF_SIZE`
        - `FZF_OBC_HEIGHT` (***deprecated***)
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_size`
        - `FZF_OBC_MLT_FZF_SIZE`
        - `FZF_OBC_HEIGHT` (***deprecated***)
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_size`
        - `FZF_OBC_REC_FZF_SIZE`
        - `FZF_OBC_HEIGHT` (***deprecated***)

### fzf_position

- Position of the fzf window when displaying results (only with tmux)
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `d`
    - config variables :
        - `std_fzf_position`
        - `FZF_OBC_STD_FZF_POSITION`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_position`
        - `FZF_OBC_MLT_FZF_POSITION`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_position`
        - `FZF_OBC_REC_FZF_POSITION`

### fzf_tmux

- Should we display the fzf window in a tmux pane or not (only with tmux)
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `1`
    - config variables :
        - `std_fzf_tmux`
        - `FZF_OBC_STD_FZF_TMUX`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_tmux`
        - `FZF_OBC_MLT_FZF_TMUX`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_tmux`
        - `FZF_OBC_REC_FZF_TMUX`

### fzf_colors

- Color scheme options for fzf
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default : `border:15`
    - config variables :
        - `std_fzf_colors`
        - `FZF_OBC_STD_FZF_COLORS`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_fzf_colors`
        - `FZF_OBC_MLT_FZF_COLORS`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_fzf_colors`
        - `FZF_OBC_REC_FZF_COLORS`

### sort_opts

- Which options to use with gnu sort when displaying the results
- could be change at :
    - global level
    - command level
    - plugin level
- **standard trigger**
    - default :  `-Vdf`
    - config variables :
        - `std_sort_opts`
        - `FZF_OBC_STD_SORT_OPTS`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_sort_opts`
        - `FZF_OBC_MLT_SORT_OPTS`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_sort_opts`
        - `FZF_OBC_REC_SORT_OPTS`

### filedir_short

- Should we display short paths as the original complete or full path
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `1`
    - config variables :
        - `std_filedir_short`
        - `FZF_OBC_STD_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR` (***deprecated***)
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_short`
        - `FZF_OBC_MLT_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR` (***deprecated***)
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_short`
        - `FZF_OBC_REC_FILEDIR_SHORT`
        - `FZF_OBC_SHORT_FILEDIR` (***deprecated***)

### filedir_colors

- Should we colorized files/paths when displaying the results (require `$LS_COLORS` to be set)
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `1`
    - config variables :
        - `std_filedir_colors`
        - `FZF_OBC_STD_FILEDIR_COLORS`
        - `FZF_OBC_COLORS` (***deprecated***)
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_colors`
        - `FZF_OBC_MLT_FILEDIR_COLORS`
        - `FZF_OBC_COLORS` (***deprecated***)
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_colors`
        - `FZF_OBC_REC_FILEDIR_COLORS`
        - `FZF_OBC_GLOBS_COLORS` (***deprecated***)

### filedir_hidden_first

- Should we put hidden files/directories first in results, at the end, or untouched
- Could be `0`,`1`,`<empty>`
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `0`
    - config variables :
        - `std_filedir_hidden_first`
        - `FZF_OBC_STD_FILEDIR_HIDDEN_FIRST`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_hidden_first`
        - `FZF_OBC_MLT_FILEDIR_HIDDEN_FIRST`
- **recursive trigger**
    - default : inherited from standard trigger
    - config variables :
        - `rec_filedir_hidden_first`
        - `FZF_OBC_REC_FILEDIR_HIDDEN_FIRST`

### filedir_maxdepth

- Maximum depth for files/paths lookup
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `1`
    - config variables :
        - `std_filedir_maxdepth`
        - `FZF_OBC_STD_FILEDIR_MAXDEPTH`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_maxdepth`
        - `FZF_OBC_MLT_FILEDIR_MAXDEPTH`
- **recursive trigger**
    - default : `999999`
    - config variables :
        - `rec_filedir_maxdepth`
        - `FZF_OBC_REC_FILEDIR_MAXDEPTH`
        - `FZF_OBC_GLOBS_MAXDEPTH` (***deprecated***)

### filedir_exclude_path

- Paths to exclude with files/paths lookup
- could be change at :
    - global level
    - command level
- **standard trigger**
    - default : `<empty>`
    - config variables :
        - `std_filedir_exclude_path`
        - `FZF_OBC_STD_FILEDIR_EXCLUDE_PATH`
- **multi selection trigger**
    - default : inherited from standard trigger
    - config variables :
        - `mlt_filedir_exclude_path`
        - `FZF_OBC_MLT_FILEDIR_EXCLUDE_PATH`
- **recursive trigger**
    - default : `.git:.svn`
    - config variables :
        - `rec_filedir_exclude_path`
        - `FZF_OBC_REC_FILEDIR_EXCLUDE_PATH`
        - `FZF_OBC_EXCLUDE_PATH` (***deprecated***)

## Examples

### Disable fzf-obc globally and enable it only on git

```shell
$ cat > ${HOME}/.config/fzf-obc/default.cfg
# Disable fzf-obc on std trigger
std_enable=0
# Since mlt_enable / rec_enable take by default the value of std_enable
# No need to add the bellow options
mlt_enable=0
rec_enable=0
# Since we disable fzf-obc, the bellow options will not be applied globally
# and should be applied on another level
std_fzf_position=d
std_fzf_size=10%

$ cat > ${HOME}/.config/fzf-obc/git.cfg
std_enable=1
# The bellow options will be applied to git command since we activated fzf-obc on it
std_fzf_position=d
std_fzf_size=10%
```

### Disable fzf-obc only on git command 

```shell
$ cat > ${HOME}/.config/fzf-obc/git.cfg
# Disable fzf-obc on std trigger
std_enable=0
# Since mlt_enable / rec_enable take by default the value of std_enable
# No need to add the bellow options
mlt_enable=0
rec_enable=0

```

### Use space with standard trigger for all commands to validate selection in fzf instead of <TAB\>

```shell
cat > ${HOME}/.config/fzf-obc/default.cfg
std_fzf_binds='--bind space:accept'
```
