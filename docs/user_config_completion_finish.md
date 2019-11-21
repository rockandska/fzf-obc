#### Details

Fzf-obc finish completion functions are called right after the selection trough
fzf.

They are generally being used to modify results present in `${COMPREPLY}` before
they being added to the command line.  

User can add their own finish completion functions if fzf-obc doesn't work well
for particularly completion function or if the default finish completion provided
with fzf-obc doesn't fit the user.

---

#### Naming convention

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

---

#### Example

As an example, Gradle had some comments in their completion results and remove
those comments only when there is only one result.  
As a result you will see those comments in the selection displayed by fzf but
will be also add to your command line after selecting a result.

This is how a user who use gradle could add a finish completion function to
remove those comments just before its selection will be had to the command
line.

We will assume that the user has add `${HOME}/.config/fzf-obc` to `FZF_OBC_PATH`  
(see [User configuration->Setup](user_config_setup.md) for instructions)

```bash
$ cat > ${HOME}/.config/fzf-obc/gradle.sh
__fzf_obc_finish__gradle() {
	local prev
	_get_comp_words_by_ref -n : -p prev
	case "$prev" in
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
