import pytest
from inspect import cleandoc

def tree():
    return {
        'dir': 'file',
        'dir1': 'file1',
        'dir 2': ['file 2', 'file2'],
        'dir3': {
            'dir4': 'file3',
            'dir5': 'file 3'
            }
    }

def test_git_diff_arg(tmux, test_cfg, helpers, tmp_path):
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("git diff --sta", enter=False)
    assert tmux.screen() == '$ git diff --sta'
    tmux.send_keys("Tab", enter=False)
    expected=r"""
    $ git diff --sta
    >
      2/2
    > --staged
      --stat
    """
    assert tmux.screen() == cleandoc(expected)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ git diff --staged'
