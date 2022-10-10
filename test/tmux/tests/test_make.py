import pytest
from inspect import cleandoc
from textwrap import dedent

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

def test_make_dir(tmux, test_cfg, helpers, tmp_path):
    # Make change its completion based on COMP_TYPE
    # check this behavior
    helpers.dict2tree(tmp_path, tree())
    with open(tmp_path / "Makefile", "w") as w:
        w.write(dedent("""\
        dir/test:
        \techo 'dir/test' >$@

        bin/anothertest:
        \techo 'bin/anothertest' > $@

        test/test:
        \techo 'test/test' > $@
        """))
    tmux.config.session.window_command=test_cfg['cmd']
    assert tmux.screen() == '$'
    tmux.send_keys("make ", enter=False)
    assert tmux.screen() == '$ make'
    tmux.send_keys("Tab", enter=False)
    expected="""
    $ make
    >
      3/3
    > bin/
      dir/
      test/
    """
    assert tmux.screen() == cleandoc(expected)
    tmux.send_keys("Tab", enter=False)
