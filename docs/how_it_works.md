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

- Source default fzf-obc `traps ` / `posts ` / `sorts` functions
- Load functions from ~/.config/fzf-obc and from paths specified in `$FZF_OBC_PATH`
- Add `_longopt` as `fzf` completion script if there is not already one defined
- Take a look at already bash complete functions defined and add the wrapper to them if not already done.
- Add traps to functions if they exist and not already add.

#### Wrapper workflow

- load configuration : default config, default user config, complete function config,
    command config
- call the original completion script (the one in charge to populate `COMPREPLY`)
- if a specific `__fzf_obc_trap_[function_name]`  function exist, execute it
    before exiting the completion script
- if a specific `__fzf_obc_post_[completion_script_name/command]` function exist, run them
- if a specific `__fzf_obc_sort_[completion_script_name/command]` function exist, run it
- display `$COMPREPLY` with fzf
- check new complete functions loaded to add the wrapper
