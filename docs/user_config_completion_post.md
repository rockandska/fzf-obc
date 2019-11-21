#### Details
Fzf-obc post completion functions are called right after the original
completion.

They are generally being used to modify results present in `${COMPREPLY}` before
being sent to fzf to display them or reuse original results to add nice preview
for example ( as `__fzf_obc_post_kill` does for the kill command ).  

User can add their own post completion functions if fzf-obc doesn't work well
for particularly completion function or if the default post completion provided
with fzf-obc doesn't fit the user.

---

#### Naming convention

The post completion function could be used for a specific completion function or
for a specific command.

The post completion prefix is `__fzf_obc_post_`.

So if you want to alter the results displayed for `ls` command for example, you
will create a function called `__fzf_obc_post_ls`.

But if you want to alter all results for commands who use completion function 
`_longopt`, you will create a function called `__fzf_obc_post__longopt`.

**/!\ If both post command/completion function exist, they will be executed both
if needed**

---

#### Example

As an example, Gradle had some comments in their completion results and remove
those comments only when there is only one result.  
As a result you will see those comments in the selection displayed by fzf but
will be also add to your command line after selecting a result.

This is how a user who use gradle could add a post completion function to
remove those comments before displaying them with fzf.

We will assume that the user has add `${HOME}/.config/fzf-obc` to `FZF_OBC_PATH`  
(see [User configuration->Setup](user_config_setup.md) for instructions)

```bash
$ cat > ${HOME}/.config/fzf-obc/gradle.sh
__fzf_obc_post__gradle() {
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

If the user open a new terminal, he will now see as complete propositions only the
options without their comments.
