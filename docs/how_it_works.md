#### Details

Fzf-obc create a wrapper over existing completion function when it is load and
create new ones when new completion functions are loaded dynamically.  
Basically, fzf-obc don't touch anything (except two core function from
bash-completion) until there is specific function for it.

The only core bash-completion functions override are `_filedir` /
`_filedir_xspec` for those reasons :

- compgen used in original bash complete functions doesn't handle newline in filenames
- having a unique function for the files/dir is simpler to maintain than a trap
- allow us more control over the results

#### Startup sequence

- Source default fzf-obc functions
- Load functions from ~/.config/fzf-obc and from paths specified in `$FZF_OBC_PATH`
- Add `_longopt` as `fzf` completion script if there is not already one defined
- Take a look at already bash complete functions defined and add the wrapper to them if not already done.
- Add traps to functions if they exist and not already add.

#### Wrapper workflow

- load configuration : default config, default user config, command config
- call the original completion script (the one in charge to populate `COMPREPLY`)
- if fzf-obc is enable for the actual command
    - load plugin config
    - plugin exist for the actual command and is enable
        - if a specific `__fzf_obc_post_[command]` function exist, run it
            - load subplugin config
            - execute subplugin functions if enable
        - display results by using `__fzf_obc_sort_[command]` function if exist, or the default one
        - if a specific `__fzf_obc_finish_[command]` function exist, run it
            - execute subplugin functions if enable
    - plugin doesn't exist for the actual command or is disable
        - display results by using default sort function
- if fzf_obc is disable for the actual command
    - try to act as if fzf-obc was not there
- check new complete functions loaded to add wrapper to them
