#### Details

Fzf-obc trap completion functions are add at the start of fzf-obc.

They are less often used than post completion functions because :

  - They are only necessary for specific use cases when it is necessary to alter a
      private completion function.
  - They are only loaded at the start of fzf-obc, so the function targeted by the
      trap is not already loaded the trap will not be added.
  - Adding a trap alter the function and this is having as a side effect to modify
      **`$BASH_SOURCE`** and some functions will not work anymore.

Despite those warnings, a user can add its own trap completion functions if 
fzf-obc doesn't works well for specific cases or if the user is sure of its actions

---

#### Naming convention

The trap completion function could be used over any functions if the function
exist prior to `fzf-obc` loading.

The trap completion prefix is `__fzf_obc_trap_`.

So if you want to alterate the function `_a_private_func` before its return add
a trap function named `__fzf_obc_trap__a_private_func`.

---

### Example

As an example, `fzf-obc` use a trap on `_get_comp_words_by_ref` to remove the
eventual `**` used to trigger "globs completion" and initalize a variable used
by later functions.

```bash
__fzf_obc_trap__get_comp_words_by_ref() {
  : "${fzf_obc_is_glob:=0}"
  if [[ "${cur}" == *'**' ]];then
    fzf_obc_is_glob=1
    cur="${cur%\*\*}"
  fi
}
```
