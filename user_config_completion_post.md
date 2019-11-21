Fzf-obc post completion functions are called right after the original
completion.

They are generally being used to modify results present in "${COMPREPLY}" before
being send to fzf to display them.  

User can add their own post completion functions if fzf-obc doesn't works well
for particulary completion function or if the default post completion provided
with fzf-obc doesn't fit the user.

As an example, Gradle had some comments in their completion results and remove
those comments only when there is only one result.  
As a result you will see those comments in the selection displayed by fzf but
will be also add to your command line after selecting a result.
