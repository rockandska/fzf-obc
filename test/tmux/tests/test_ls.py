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

def test_ls_basic(tmux, test_cfg, helpers, tmp_path):
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("ls ", enter=False)
    assert tmux.screen() == '$ ls'
    tmux.send_keys("Tab", enter=False)
    expected=r"""
    $ ls
    >
      5/5
    > .bashrc
      dir
      dir 2
      dir1
      dir3
    """
    assert tmux.screen() == cleandoc(expected)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls .bashrc'

def test_ls_space(tmux, test_cfg, helpers, tmp_path):
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("ls ", enter=False)
    assert tmux.screen() == '$ ls'
    tmux.send_keys("Tab", enter=False)
    expected=r"""
    $ ls
    >
      5/5
    > .bashrc
      dir
      dir 2
      dir1
      dir3
    """
    assert tmux.screen() == cleandoc(expected)
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == r'$ ls dir\ 2/'

def test_ls_prefix(tmux, test_cfg, helpers, tmp_path):
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("ls d", enter=False)
    assert tmux.screen() == '$ ls d'
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls dir'
    tmux.send_keys("Tab", enter=False)
    expected=r"""
    $ ls dir
    >
      4/4
    > dir
      dir 2
      dir1
      dir3
    """
    assert tmux.screen() == cleandoc(expected)
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls dir3/'

def test_ls_prefix_middle(tmux, test_cfg, helpers, tmp_path):
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("ls dm", enter=False)
    assert tmux.screen() == '$ ls dm'
    tmux.send_keys("Left", enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls dirm'
