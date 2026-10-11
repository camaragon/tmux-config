"""Run with python3 scripts/test-git-status.py; only creates temporary data."""
from pathlib import Path
import subprocess
import tempfile

helper = Path(__file__).with_name('git-status.sh')


def label(mode, path):
    return subprocess.check_output(['sh', str(helper), mode, str(path)], text=True)


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    repo = root / 'example repo'
    repo.mkdir()
    subprocess.run(['git', 'init', '-q', '-b', 'feature/status', str(repo)], check=True)
    nested = repo / 'nested'
    nested.mkdir()
    assert label('repo', nested) == 'example repo'
    assert label('branch', nested) == 'feature/status'
    assert label('repo', root) == root.name
    assert label('branch', root) == '—'
    assert label('repo', '/') == '/'
    unusual = root / 'quote\' space #name'
    unusual.mkdir()
    assert label('repo', unusual) == "quote' space _name"
    subprocess.run(['git', '-C', str(repo), '-c', 'user.name=Test',
                    '-c', 'user.email=test@example.invalid', '-c', 'commit.gpgsign=false', 'commit', '-q',
                    '--allow-empty', '-m', 'test'], check=True)
    subprocess.run(['git', '-C', str(repo), 'checkout', '-q', '--detach'], check=True)
    commit = subprocess.check_output(['git', '-C', str(repo), 'rev-parse',
                                      '--short', 'HEAD'], text=True).strip()
    assert label('branch', repo) == commit
print('PASS: repository, nested/spaced paths, branch, detached HEAD, non-Git fallback')
