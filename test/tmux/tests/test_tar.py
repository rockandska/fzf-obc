import pytest
import re
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

def test_tar_arg(tmux, test_cfg, helpers, tmp_path):
    if re.match(r'.*3\.2.*', test_cfg['docker_image']):
        pytest.skip("No - for options in bash 3.2")
    helpers.dict2tree(tmp_path, tree())
    assert tmux.screen() == '$'
    tmux.send_keys("tar -", enter=False)
    assert tmux.screen() == '$ tar -'
    tmux.send_keys("Tab", enter=False)
    tmux.send_keys("x", enter=False)
    assert tmux.row(3) == '> -x'
    tmux.send_keys("Tab", enter=False)
    assert tmux.screen() == '$ tar -x'
