#### Details
Fzf-obc sort completion functions are called right after the post completion
function if there is one or right after the original completion function.

As its name suggest, sort functions are used to sort results before being
displayed by fzf.

User can add their own sort completion functions if the default fzf-obc doesn't
fit the user needs or even replace the default function.

---

#### Naming convention

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

---

#### Example

As an example, the default sort function could be override as bellow.

We will assume that the user has add `${HOME}/.config/fzf-obc` to `FZF_OBC_PATH`  
(see [User configuration->Setup](user_config_setup.md) for instructions)

```bash
$ cat > ${HOME}/.config/fzf-obc/sort_functions.sh
__fzf_obc_default_sort() {
  local cmd
  # move colors to the right
  cmd="sed -z -r 's/^(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])(.*)/\5\1/g'"
  # sort cmd used to show results
  cmd="(set -euo pipefail; eval LC_ALL=C sort -z $* -S 50% --parallel=\"$(awk '/^processor/{print $3}' /proc/cpuinfo 2> /dev/null | wc -l)\" 2> /dev/null || eval LC_ALL=C sort -z $*) < <($cmd)"
  # move colors back to the left
  cmd="sed -z -r 's/(.*)(\x1B\[([0-9]{1,}(;[0-9]{1,})?(;[0-9]{1,})?)?[mGK])$/\2\1/g' < <($cmd)"
  eval "$cmd"
}
```

If the user open a new terminal, he will now see its results with the new
sorting in place.
