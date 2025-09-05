import pytest
import stat
from inspect import cleandoc

def test_completion_with_comments(tmux, test_cfg, helpers):
    # Create a dummy completion script
    script=r"""
        #/usr/bin/env bash
        _test_comp()
        {
            local suggestions=(
            "--file # Path to file"
            "--priority # Priority to use"
            "--force # Force to use"
        )
        local IFS=$'\n'
        local suggestion=($(compgen -W "$(printf '%s\n' ${suggestions[@]})" -- "${COMP_WORDS[1]}"))

        if [ "${#suggestion[@]}" == "1" ]; then
            COMPREPLY=( "${suggestion[0]%% *}" )
        else
            COMPREPLY=("${suggestion[@]}")
        fi
    }

    complete -F _test_comp test_comp
    """
    d = test_cfg['tmpdir'] / '.local' / 'bin'
    d.mkdir(parents=True, exist_ok=True)
    file = d / 'test_comp'
    with file.open(mode='w') as f:
        f.write(cleandoc(script))
    file.chmod(file.stat().st_mode | stat.S_IEXEC)
    assert tmux.screen() == '$'
    tmux.send_keys('source .local/bin/test_comp')
    # reload fzf-obc
    tmux.send_keys('fzf-obc')
    assert tmux.row(0) == '$ source .local/bin/test_comp'
    assert tmux.row(1) == '$ fzf-obc'
    assert tmux.row(2) == '$'
    tmux.send_keys("clear")
    assert tmux.screen() == '$'
    tmux.send_keys('test_comp ', enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ test_comp --'
    tmux.send_keys('p', enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ test_comp --priority'
