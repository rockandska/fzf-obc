# Compatibility matrix

Non exhaustive list of compatibility over distributions

## Linux

| Distribution | Addons installed | Standard Completion | Globs Completion * | DirColors ** |
| :----------: | :--------------: | :-----------------: | :----------------: | :----------: |
| Ubuntu 18.04 |        -         |         yes         |        yes         |     yes      |
| Ubuntu 16.04 |        -         |         yes         |        yes         |     yes      |

## macOS

| Distribution |                       Addons installed                       | Standard Completion | Globs Completion * | DirColors ** |
| :----------: | :----------------------------------------------------------: | :-----------------: | :----------------: | :----------: |
|    10.13     |                              -                               |         yes         |       **no**       |    **no**    |
|    10.13     | brew install bash-completion coreutils findutils gawk gnu-sed |         yes         |       **no**       |     yes      |
|    10.13     | brew install bash bash-completion@2 coreutils findutils gawk gnu-sed |         yes         |        yes         |     yes      |

\* : require bash >= 4
** : require gnu find