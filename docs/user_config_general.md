Default fzf-obc configuration could be customized by settings some environment
 variables with your own needs and are described below.  
Those environment variables could be set per directory if needed by using [direnv](https://direnv.net/) for
example.

- `FZF_OBC_HEIGHT`
    - Default : `40%`
    - Height of the fzf filtering window
- `FZF_OBC_SHORT_FILEDIR`
    - Default : `1`
    - Do not show the full path but only the last part of it (like the original
        completion) for completion who use `_filedir`/`_filedir_xpsec`.
- `FZF_OBC_EXCLUDE_PATH`
    - Default : `.git:.svn`
    - Paths to exclude from the completion results
    - If using multiples paths, paths need to be separate by `:`
    - **Only used with globs completion who use `_filedir`/`_filedir_xpsec`**
- `FZF_OBC_COLORS`
    - Default : 1
    - Add colors to completion who use `_filedir`/`_filedir_xpsec` if `$LS_COLORS`
        is set
- `FZF_OBC_OPTS`
    - Default : `--select-1 --exit-0`
    - Options used with fzf when displaying completion results
- `FZF_OBC_BINDINGS`
    - Default : `--bind tab:accept`
    - Bindings options used to validate your choice.
- `FZF_OBC_GLOBS_MAXDEPTH`
    - Default : `999999`
    - Maximum depth to search when using globs lookup on completion who use
      `_filedir`/`_filedir_xpsec`
- `FZF_OBC_GLOBS_COLORS`
    - Default : 1
    - Add colors when using globs lookup on completion who use `_filedir`/`_filedir_xpsec` if `$LS_COLORS`
        is set
- `FZF_OBC_GLOBS_OPTS`
    - Default : `-m --select-1 --exit-0`
    - Options used with fzf when displaying globs completion results
- `FZF_OBC_GLOBS_BINDINGS`
    - Default :
    - Bindings options used to select/unselect/validate choice with globs completion results
