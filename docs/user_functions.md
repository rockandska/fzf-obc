# User functions

## Add personnal functions

- User has the possibility to place all its personal `fzf-obc` functions in  
`${XDG_CONFIG_HOME:-$HOME/.config}` by default.
- Additionnal paths to load could be placed in `$FZF_OBC_PATH` separated by `:`
- `FZF_OBC_PATH` should be set **before** sourcing `fzf-obc`
- Functions files need to have `.sh` or `.bash` extension to be loaded
- User functions loaded will override `fzf-obc` functions with the same names
- User functions are not dynamic and only loaded on the first load of `fzf-obc`

---

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
    - Will be set by `__fzf_obc_trap__get_comp_words_by_ref` with the trigger found,
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

---

## Post completion functions

### Details
Fzf-obc post completion functions are called right after the original
completion.

They are generally being used to modify results present in `${COMPREPLY}` before
being sent to fzf to display them or reuse original results to add nice preview
for example ( as `__fzf_obc_post_kill` does for the kill command ).  

User can add their own post completion functions if fzf-obc doesn't work well
for particularly completion function or if the default post completion provided
with fzf-obc doesn't fit the user.

### Naming convention

The post completion function could be used for a specific completion function or
for a specific command.

The post completion prefix is `__fzf_obc_post_`.

So if you want to alter the results displayed for `ls` command for example, you
will create a function called `__fzf_obc_post_ls`.

But if you want to alter all results for commands who use completion function 
`_longopt`, you will create a function called `__fzf_obc_post__longopt`.

**/!\ If both post command/completion function exist, they will be executed both
if needed**

### Example

As an example, Gradle had some comments in their completion results and remove
those comments only when there is only one result.  
As a result you will see those comments in the selection displayed by fzf but
will be also add to your command line after selecting a result.

This is how a user who use gradle could add a post completion function to
remove those comments before displaying them with fzf.

```bash
$ cat > ${HOME}/.config/fzf-obc/gradle.sh
__fzf_obc_post__gradle() {
	case "$current_prev" in
		-b|--build-file|-c|--settings-file|-I|--init-script|-g|--gradle-user-home|--include-build|--project-cache-dir|--project-dir)
		  type compopt &>/dev/null && compopt -o filenames
			return 0
			;;
		*)
			local i
			for i in "${!COMPREPLY[@]}";do
				COMPREPLY[$i]="${COMPREPLY[i]%%  *}"
			done
			return 0
			;;
	esac
}
```

If the user open a new terminal, he will now see as complete propositions only the
options without their comments.

---

## Finish completion functions

### Details

Fzf-obc finish completion functions are called right after the selection trough
fzf.

They are generally being used to modify results present in `${COMPREPLY}` before
they being added to the command line.  

User can add their own finish completion functions if fzf-obc doesn't work well
for particularly completion function or if the default finish completion provided
with fzf-obc doesn't fit the user.

### Naming convention

The finish completion function could be used for a specific completion function or
for a specific command.

The finish completion prefix is `__fzf_obc_finish_`.

So if you want to alter the results for `ls` before being added to the command line  
for example, you will create a function called `__fzf_obc_finish_ls`.

But if you want to alter all results for commands who use completion function 
`_longopt` before being add to the command line, you will create a function  
called `__fzf_obc_finish__longopt`.

**/!\ If both finish command/completion function exist, they will be executed both
if needed**

### Example

As an example, Gradle had some comments in their completion results and remove
those comments only when there is only one result.  
As a result you will see those comments in the selection displayed by fzf but
will be also add to your command line after selecting a result.

This is how a user who use gradle could add a finish completion function to
remove those comments just before its selection will be had to the command
line.

```bash
$ cat > ${HOME}/.config/fzf-obc/gradle.sh
__fzf_obc_finish__gradle() {
	case "$current_prev" in
		-b|--build-file|-c|--settings-file|-I|--init-script|-g|--gradle-user-home|--include-build|--project-cache-dir|--project-dir)
		  type compopt &>/dev/null && compopt -o filenames
			return 0
			;;
		*)
			local i
			for i in "${!COMPREPLY[@]}";do
				COMPREPLY[$i]="${COMPREPLY[i]%%  *}"
			done
			return 0
			;;
	esac
}
```

If the user open a new terminal, he will now see the same completion propositions  
as the original (with the comments) but will only see the options, without their  
comments, added to the command line without their comments.

---

## Sort completion functions

### Details
Fzf-obc sort completion functions are called right after the post completion
function if there is one or right after the original completion function.

As its name suggest, sort functions are used to sort results before being
displayed by fzf.

User can add their own sort completion functions if the default fzf-obc doesn't
fit the user needs or even replace the default function.

### Naming convention

The default sort function is named `__fzf_obc_default_sort`.  
This is the function used if there is no sort function for the complete function
and not a specific sort function for the command.

The sort completion function could be used for a specific completion function or
for a specific command.

The sort completion prefix is `__fzf_obc_sort_`.

So if you want to specifically sort the results displayed for `ls` command for 
example, you will create a function called `__fzf_obc_sort_ls`.

But if you want to sort all results for commands who use completion function 
`_longopt`, you will create a function called `__fzf_obc_sort__longopt`.

**/!\ Sort functions are exclusive and only one will be executed in this order:
sort command function, sort complete function, default sort**

### Example

Since the sort options are available through the sort_opts parameter, it will
not be so common to change the default sort function.
But if you want to add more to the default function, this is how it could be override:

```bash
$ cat > ${HOME}/.config/fzf-obc/sort_functions.sh
__fzf_obc_default_sort() {
    ( set -euo pipefail;
    eval "LC_ALL=C sort -z -u ${current_sort_opts:-} -S 50% --parallel=\"$(awk	'/^processor/{print $3}' /proc/cpuinfo 2> /dev/null | wc -l)\" 2> /dev/null" || eval "LC_ALL=C sort -z -u ${current_sort_opts:-}" )
}
```

If the user open a new terminal, he will now see its results with the new
sorting in place.

---

## Trap completion functions

### Details

Fzf-obc trap completion functions are add at the start of fzf-obc.

They are less often used than post completion functions because :

  - Only necessary for specific use cases when it is necessary to alter a
      private completion function.
  - Od at the start of fzf-obc, so the function targeted by the
      trap is not already loaded the trap will not be added.
  - Adding a trap alter the function and this is having as a side effect to modify
      **`$BASH_SOURCE`** and some functions will not work anymore.

Despite those warnings, a user can add its own trap completion functions if 
fzf-obc doesn't works well for specific cases or if the user is sure of its actions

### Naming convention

The trap completion function could be used over any functions if the function
exist prior to `fzf-obc` loading.

The trap completion prefix is `__fzf_obc_trap_`.

So if you want to alter the function `_a_private_func` before its return add
a trap function named `__fzf_obc_trap__a_private_func`.

### Example

As an example, `fzf-obc` use a trap on `_get_comp_words_by_ref` to remove the
pattern used as 'fzf-obc' trigger and to initialize some internal variables.
