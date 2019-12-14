# Plugins

## Purpose of plugins

Plugins are available to be able to :

- Change fzf-obc options for specific command
- Fix some specific issues with some completion scripts
- Add a friendly display for particular command / command options.

## What defined a plugins

A plugin for a particular command could be composed of :

- One or more of the following functions type
    - Post functions
        - Should be named `__fzf_obc_post_[command]`
        - Could change completion results before sending them to fzf
        - Could change / add fzf (and other) options used to display results
        - Subplugin config should be load here
        - **Not executed if the cmd plugin is disable**
    - Sort functions
        - Should be named `__fzf_obc_sort_[command]`
        - If your not satisfied with default sort function capability
        - **Not executed if the cmd plugin is disable**
    - Finish functions
        - Should be named `__fzf_obc_finish_[command]`
        - Let you clean the eventually verbosity of the results ( comments next to
            the options etc.. )
        - **Not executed if the cmd plugin is disable**
    - Trap functions
        - Should be named `__fzf_obc_trap_[private_function]`
        - Let you add trap over some private functions to be able to set/catch some
            internal vars used by completion functions
        - **Be careful if the private function use BASH_SOURCE, because add a
            trap replace BASH_SOURCE**
        - **Always executed even if the cmd plugin is disable**
- One or more configuration files
    - Sourced by plugin functions (generally used to add preview options etc...)
    - Always use `current_[option]` variables in those files
    - Load order :
        - `[fzf_obc_path]/plugins/[command]/default.cfg`
        - `${XDG_CONFIG_HOME:-$HOME/.config}/plugins/[command]/[specific].cfg`


## Add personnal functions

- User has the possibility to place all its personal `fzf-obc` functions in  
`${XDG_CONFIG_HOME:-$HOME/.config}` by default.
- Additionnal paths to load could be placed in `$FZF_OBC_PATH` separated by `:`
- `FZF_OBC_PATH` should be set **before** sourcing `fzf-obc`
- Functions files need to have `.sh` or `.bash` extension to be loaded
- User functions loaded will override `fzf-obc` functions with the same names
- User functions are **not dynamic** and only loaded on the first load of `fzf-obc`

## Default plugins

### kill

- Allow to have a nice window displaying `ps` output instead of PID list.
- Functions used
    - `__fzf_obc_post_kill`
    - `__fzf_obc_finish_kill`
- Configuration files
    - `plugins/kill/default.cfg`
        - default `<empty>`
    - `plugins/kill/process.cfg`
        - options specific when displaying process (current_[option])
        - default:
            - `current_fzf_opts+=" --min-height 15 --preview 'echo {}' --preview-window down:3:wrap"`

### gradle

- Remove options comments after selecting them
- Functions used
    - `__fzf_obc_finish_gradle`
- Configuration files
    - `plugins/gradle/default.cfg`
        - default `<empty>`
    - `plugins/gradle/remove_comments.cfg`
        - options specific when displaying completion and need to remove comments
        - default:
            - `<empty>`

## Internal environment variables available

Some variables are available in all fzf-obc functions triggered by the fzf-obc wrapper :

- `current_cmd_name`
    - Default: `<empty>`
    - Will be set with the name of the command to complete
- `current_func_name`
    - Default: `<empty>`
    - Will be set with the name of the complete function associated with the command to
        complete
- `current_filedir_depth`
    - default: `<empty>`
    - Will be set with the depth of the starting point, when _filedir/_fildir_xspec is used  
      Example:  
          - `ls /var/l<TAB>` -> current_filedir_depth=2
          - `ls /var/lib/<TAB>` -> current_filedir_depth=3
- `current_trigger_type`
    - default: `<empty>`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the trigger found (std,mlt,rec),
        empty if no trigger pattern math
- `current_cur`
    - default: `<empty>`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$cur`
        from _get_comp_words_by_ref
- `current_prev`
    - default: `<empty>`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$prev`
        from _get_comp_words_by_ref
- `current_words`
    - default: `<empty>`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$words`
        from _get_comp_words_by_ref
- `current_cword`
    - default: `<empty>`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$cword`
        from _get_comp_words_by_ref
- `current_[option]`
    - Will be set with the value of [option] after having detected the trigger

## Plugin configuration examples

### Disable totally the kill plugin

```
$ cat > ~/.config/fzf-obc/plugins/kill/default.cfg
current_enable=0
```

### Disable conditionnaly the kill plugin
```
$ cat > ~/.config/fzf-obc/plugins/kill/default.cfg
# Only for recursive trigger
if [[ "${current_trigger_type}" == "rec" ]];then
  current_enable=0
fi
```

### Disable only the kill process viewer functionality of the kill plugin

```
$ cat > ~/.config/fzf-obc/plugins/kill/process.cfg
current_enable=0
```

### Change the color of the preview window for kill process viewer functionality

```
$ cat > ~/.config/fzf-obc/plugins/kill/process.cfg
current_fzf_colors="border:124"
```
