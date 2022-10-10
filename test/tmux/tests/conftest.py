import pytest
import os
import docker
import subprocess
import logging

from pathlib import Path

@pytest.fixture()
def helpers():
    return Helpers()

@pytest.fixture()
def test_cfg(test_container, bashrc, tmp_path):
    cfg = {}
    if 'DOCKER_IMAGE' in os.environ:
        cfg['cmd'] = f'\
            docker exec -ti -w "{tmp_path}"\
            {test_container.name} bash --rcfile {bashrc} --noprofile \
            '
    else:
        cfg['cmd'] = f'env -i PS1= PATH="$PATH" bash --rcfile {bashrc} --noprofile'
    return cfg

@pytest.fixture()
def bashrc(tmp_path):
    data = f"""
    if [ "`id -u`" -eq 0 ]; then
        PS1='# '
    else
        PS1='$ '
    fi
    HOME={tmp_path}
    TERM="{os.environ.get('TERM','dumb')}"
    source /etc/bash_completion
    source {getGitRoot()}/bin/fzf-obc
    cd "$HOME"
    """
    file = f'{tmp_path}/.bashrc'
    with open(file, 'w') as f:
        f.write(data)

    return file

@pytest.fixture(scope='session')
def test_container(request, tmp_path_factory):
    if 'DOCKER_IMAGE' in os.environ:
        project_root = getGitRoot()
        tmp_dir = tmp_path_factory.getbasetemp()
        bin_path = f"{project_root}/bin/fzf-obc"
        client = docker.from_env()
        container = client.containers.run(
            os.environ['DOCKER_IMAGE'],
            'bash -c "tail -f /dev/null"',
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

