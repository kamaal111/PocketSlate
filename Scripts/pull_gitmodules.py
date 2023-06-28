import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List

GITMODULES_PATH = ".gitmodules"
GITMODULE_PROPERTIES = ["path", "url", "branch"]


@dataclass
class Gitmodule:
    name: str
    path: str
    url: str
    branch: str

    @staticmethod
    def from_dict(dictionary: Dict[str, str]):
        return Gitmodule(
            name=dictionary["name"],
            path=dictionary["path"],
            url=dictionary["url"],
            branch=dictionary["branch"],
        )


def parse_gitmodules(text: str):
    gitmodules: List[Gitmodule] = []
    gitmodule_buffer: Dict[str, str] = {}
    for line in text.splitlines():
        if "[submodule " in line:
            if gitmodule_buffer:
                gitmodules.append(Gitmodule.from_dict(gitmodule_buffer))

            gitmodule_buffer = {}
            gitmodule_buffer["name"] = line.split("[submodule ")[-1].split('"')[1]
        else:
            for property in GITMODULE_PROPERTIES:
                if f"{property} = " in line:
                    gitmodule_buffer[property] = line.split(f"{property} = ")[-1]

    if gitmodule_buffer:
        gitmodules.append(Gitmodule.from_dict(gitmodule_buffer))

    return gitmodules


def clone_gitmodules(gitmodules: List[Gitmodule]):
    clone_processes: List[subprocess.Popen[bytes]] = []
    for gitmodule in gitmodules:
        gitmodule_directory = Path(gitmodule.path)
        if gitmodule_directory.exists():
            continue

        process = subprocess.Popen(
            ["sh", "-c", f"git clone {gitmodule.url} {gitmodule.path}"]
        )
        clone_processes.append(process)

    for process in clone_processes:
        process.wait()


def pull_gitmodules(gitmodules: List[Gitmodule]):
    current_directory = Path.cwd()
    for gitmodule in gitmodules:
        subprocess.Popen(["sh", "-c", f"cd {current_directory.absolute()}"]).wait()
        subprocess.Popen(["sh", "-c", f"cd {gitmodule.path} && git pull"]).wait()


def main():
    gitmodules_file = Path(GITMODULES_PATH)
    gitmodules = parse_gitmodules(text=gitmodules_file.read_text())
    clone_gitmodules(gitmodules=gitmodules)
    pull_gitmodules(gitmodules=gitmodules)


if __name__ == "__main__":
    main()
