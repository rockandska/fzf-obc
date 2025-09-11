import pytest
from inspect import cleandoc

def tree():
    return {
        'dir': 'file',
        'dir1': ['file1', 'File2'],
        'dir 2': ['file 2', 'file2'],
        'dir3': {
            'dir4': 'file3',
            'dir5': 'file 3'
            }
    }

@pytest.mark.parametrize(
    'bashrc',
    [
        {
            'readline': {
                'completion-ignore-case': 'off'
            },
        },
        {
            'readline': {
                'completion-ignore-case': 'on'
            }
        }
    ]
)
def test_ls_basic(tmux, test_cfg, helpers, bashrc):
    helpers.update_bashrc(test_cfg['bashrc'],bashrc)
    helpers.dict2tree(test_cfg['tmpdir'], tree())
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
    tmux.send_keys("Down", enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls dir1/'
    # Testing ignore-case
    tmux.send_keys("F", enter=False)
    tmux.send_keys("Tab", enter=False)
    if bashrc['readline']['completion-ignore-case'] == 'off':
        assert tmux.screen() == '$ ls dir1/File2'
    elif bashrc['readline']['completion-ignore-case'] == 'on':
        assert tmux.screen() == '$ ls dir1/File'
        tmux.send_keys("Tab", enter=False)
        expected=r"""
        $ ls dir1/File
        >
          2/2
        > dir1/File2
          dir1/file1
        """
        assert tmux.screen() == cleandoc(expected)

def test_ls_space(tmux, test_cfg, helpers):
    helpers.dict2tree(test_cfg['tmpdir'], tree())
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

def test_ls_prefix(tmux, test_cfg, helpers):
    helpers.dict2tree(test_cfg['tmpdir'], tree())
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

def test_ls_prefix_middle(tmux, test_cfg, helpers):
    helpers.dict2tree(test_cfg['tmpdir'], tree())
    assert tmux.screen() == '$'
    tmux.send_keys("ls dm", enter=False)
    assert tmux.screen() == '$ ls dm'
    tmux.send_keys("Left", enter=False)
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ ls dirm'
