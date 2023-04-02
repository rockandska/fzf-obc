import pytest
import os
import docker
import subprocess
import logging

from pathlib import Path

@pytest.fixture(scope='session')
def helpers():
    return Helpers()

@pytest.fixture()
def tmux_session_config(test_session_cfg, tmp_path, bashrc, test_container):
    cfg ={}
    if test_session_cfg['docker']:
        cfg['window_command'] = f'\
            docker exec -ti -w "{tmp_path}" \
            {test_container.name} bash --rcfile {bashrc} --noprofile \
            '
    else:
        cfg['window_command'] = f'env -i PS1= PATH="$PATH" bash --rcfile {bashrc} --noprofile'
    return cfg

@pytest.fixture(scope='session')
def test_session_cfg():
    cfg = {}
    if 'DOCKER_IMAGE' in os.environ:
        cfg['docker'] = True
        cfg['docker_image'] = os.environ['DOCKER_IMAGE']
    else:
        cfg['docker'] = False
        cfg['docker_image'] = None
    cfg['project_dir'] = getGitRoot()
    return cfg

@pytest.fixture()
def test_cfg(test_session_cfg):
    cfg = test_session_cfg.copy()
    return cfg

@pytest.fixture(params=[
    {
        'readline':
            {
                'completion-ignore-case': 'off' }
            },
    {
        'readline':
            {
                'completion-ignore-case': 'on'
            },
    }
])
def bashrc(test_cfg, tmp_path, request):
    test_cfg.update(request.param)

    data = f"""
    source /etc/profile
    if [ "`id -u`" -eq 0 ]; then
        PS1='# '
    else
        PS1='$ '
    fi
    HOME={tmp_path}
    TERM="{os.environ.get('TERM','dumb')}"
    source /usr/share/bash-completion/completions/*
    source {test_cfg['project_dir']}/bin/fzf-obc
    cd "$HOME"
    """

    for k in test_cfg['readline'].keys():
        data += f"bind 'set {k} {test_cfg['readline'][k]}'"

    file = f'{tmp_path}/.bashrc'
    with open(file, 'w') as f:
        f.write(data)

    return file

@pytest.fixture(scope='session')
def test_container(test_session_cfg, request, tmp_path_factory):
    if test_session_cfg['docker']:
        project_root = test_session_cfg['project_dir']
        tmp_dir = tmp_path_factory.getbasetemp()
        bin_path = f"{project_root}/bin/fzf-obc"
        client = docker.from_env()
        container = client.containers.run(
            test_session_cfg['docker_image'],
            tty=True,
            stdin_open=True,
            remove=True,
            detach=True,
            user=os.getuid(),
            volumes={
                bin_path: {
                    'bind': str(bin_path),
                    'mode': 'ro'
                },
                tmp_dir: {
                    'bind': str(tmp_dir)
                },
                '/etc/passwd': {
                    'bind': '/etc/passwd',
                    'mode': 'ro'
                },
                '/etc/group': {
                    'bind': '/etc/group',
                    'mode': 'ro'
                }
            }
        )

        yield container

        container.kill()
    else:
        yield None

def getGitRoot():
    return subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')

class Helpers():
    @staticmethod
    def dict2tree(root_directory, obj_dict):
        for k, v in obj_dict.items():
            if isinstance(v,dict):
                # add the key to the path
                new_root = os.path.join(root_directory, k) # you'll need to import os
                Helpers.dict2tree(new_root, v)
            elif isinstance(v,list):
                for f in v:
                    # write the file
                    Path(os.path.join(root_directory,k)).mkdir(parents=True, exist_ok=True)
                    with open(os.path.join(root_directory,k,f), mode='a'): pass
            else:
                Path(os.path.join(root_directory,k)).mkdir(parents=True, exist_ok=True)
                with open(os.path.join(root_directory,k,v), mode='a'): pass

