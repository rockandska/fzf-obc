User has the possibility to place all its personal `fzf-obc` 
configurations/functions in directories of its choice and split in multiple
files if necessary.

- `FZF_OBC_PATH` environment variable should contain one or multiple paths separated by `:`
- Files present in directories specified in `FZF_OBC_PATH` need to have `.sh` or `.bash` extension to be loaded
- Configurations/functions loading from `FZF_OBC_PATH` will override `fzf-obc` default
    configurations/functions.
- `FZF_OBC_PATH` should be set **before** sourcing `fzf-obc`
