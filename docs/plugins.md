# Plugins

## Purpose of plugins

Plugins are available to be able to :

- Change fzf-obc options for specific cases for specific commands
- Fix some specific issues with some completion scripts
- Add a friendly display for particular command / command options.

**Plugins will be loaded only if fzf-obc is enable globally or at the command level**

## What defined a plugins

A plugin for a particular command could be composed of :

- One or more of the following functions type
    - Post functions
        - Should be named `__fzf_obc_post_[command]`
        - Could change completion results before sending them to fzf
        - Could change / add fzf (and other) options used to display results
        - Subplugin config should be load here
    - Sort functions
        - Should be named `__fzf_obc_sort_[command]`
        - If your not satisfied with default sort function capability
    - Finish functions
        - Should be named `__fzf_obc_finish_[command]`
        - Let you clean the eventually verbosity of the results ( comments next to
            the options etc.. )
    - Trap functions
        - Should be named `__fzf_obc_trap_[private_function]`
        - Let you add trap over some private functions to be able to set/catch some
            internal vars used by completion functions
        - **Be careful if the private function use BASH_SOURCE, because adding a
            trap replace BASH_SOURCE**
        - **Always executed even if the plugin is disable**
- One or more configuration files
    - Sourced by plugin functions (generally used to add preview options etc...)
    - Load order :
        - `[fzf_obc_path]/plugins/default.cfg` 
        - `${XDG_CONFIG_HOME:-$HOME/.config}/default.cfg` 
        - `[fzf_obc_path]/plugins/[command]/default.cfg`
        - `${XDG_CONFIG_HOME:-$HOME/.config}/plugins/[command]/default.cfg`
        - `[fzf_obc_path]/plugins/plugins/[command]/[plugin].cfg`
        - `${XDG_CONFIG_HOME:-$HOME/.config}/plugins/[command]/[plugin].cfg`


## Add personnal functions

- User has the possibility to place all its personal `fzf-obc` functions in  
`${XDG_CONFIG_HOME:-$HOME/.config}` by default.
- Additional paths to load could be placed in `$FZF_OBC_PATH` separated by `:`
- `FZF_OBC_PATH` should be set **before** sourcing `fzf-obc`
- Functions files need to have `.sh` or `.bash` extension to be loaded
- User functions loaded will override `fzf-obc` functions with the same names
- User functions are **not dynamic** and are only loaded on the first load of `fzf-obc`

## Default plugins

### kill

- Allow to have a nice window displaying `ps` output instead of PID list.
- Functions used
    - `__fzf_obc_post_kill`
    - `__fzf_obc_finish_kill`
- Configuration files
    - `plugins/kill/process.cfg`
        - options specific when displaying process
        - default:
            - `std_fzf_opts=" --min-height 15 --preview 'echo {}' --preview-window down:3:wrap"`

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

Some variables are available in all fzf-obc plugins :

- `current_cmd_name`
    - Will be set with the name of the command to complete
- `current_func_name`
    - Will be set with the name of the complete function associated with the command to complete
- `current_filedir_depth`
    - Will be set with the depth of the starting point, when _filedir/_fildir_xspec is used  
    - Example:
        - `ls /var/l<TAB>` -> `current_filedir_depth=2`
        - `ls /var/lib/<TAB>` -> `current_filedir_depth=3`
- `current_plugin`
    - Will be set by `__fzf_obc_load_plugin_config` with the current plugin in use
    - Example:
        - `__fzf_obc_load_plugin_config` -> `current_plugin="default"`
        - `__fzf_obc_load_plugin_config default ` -> `current_plugin="${current_cmd_name}/default"`
        - `__fzf_obc_load_plugin_config remove_comments` -> `current_plugin="${current_cmd_name}/remove_comments"`
- `current_trigger_type`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the trigger found (std,mlt,rec), empty if no trigger pattern math
- `current_cur`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$cur` from _get_comp_words_by_ref
- `current_prev`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$prev` from _get_comp_words_by_ref
- `current_words`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$words` from _get_comp_words_by_ref
- `current_cword`
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the value of `$cword` from _get_comp_words_by_ref

## Plugin configuration examples

### Disable all plugins for all commands

```
$ cat > ~/.config/fzf-obc/plugins/default.cfg
std_enable=0
```

### Disable all plugins for kill command

```
$ cat > ~/.config/fzf-obc/plugins/kill/default.cfg
std_enable=0
```

### Disable all plugins for kill command only with recursive trigger
```
$ cat > ~/.config/fzf-obc/plugins/kill/default.cfg
rec_enable=0
```

### Disable only the kill process viewer plugin of the kill plugin

```
$ cat > ~/.config/fzf-obc/plugins/kill/process.cfg
std_enable=0
```

### Change the color of the preview window for kill process viewer functionality

```
$ cat > ~/.config/fzf-obc/plugins/kill/process.cfg
std_fzf_colors="border:124"
```
