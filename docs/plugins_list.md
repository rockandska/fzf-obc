# Plugins list

## git
Configuration file: `plugins/git/default.cfg`  
Default:
```shell
current_fzf_preview_window='right:80%:wrap'
```

### diff

Allow to preview the diff when selecting ref/file

Configuration file: `plugins/gradle/diff.cfg`  
Default:
```shell
current_fzf_opts+=" --preview=\"echo {} | sed -r 's/^ +//g;s/ +$//g' | xargs -I% git diff --color=always %\" "
```

### add

Allow to preview the diff of files to add

Configuration file: `plugins/gradle/add.cfg`  
Default:
```shell
current_sort_opts+=" -t $'\t' -k2"
current_fzf_opts+=" --preview=\"echo -n {} | sed -r -z 's/^.*][[:space:]]//' | sed -r -z 's/.* -> +//' | xargs -0 printf '%q' | xargs -I% git diff --color=always -- %\" "
```

## gradle

Configuration file: `plugins/gradle/default.cfg`  
Default:

### remove_comments

Remove options comments after selecting an option

Configuration file: `plugins/gradle/remove_comments.cfg`  
Default:

## kill

Configuration file: `plugins/kill/default.cfg`  
Default:

### process

Allow to have a nice window displaying `ps` output instead of PID list.

Configuration file: `plugins/kill/process.cfg`  
Default:  
```shell
current_fzf_opts+=" --min-height 15 --preview 'echo {}' --preview-window down:3:wrap"
```

