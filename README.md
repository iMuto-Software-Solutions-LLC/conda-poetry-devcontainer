# conda-poetry-devcontainer

A devcontainer based on microsoft's [miniconda devcontainer](https://github.com/devcontainers/images/tree/main/src/miniconda), with added support for poetry.

It includes:
* [oh-my-zsh](https://ohmyz.sh/) pre-configured to use zsh with omz, but bash is still there if you want it
* [miniconda](https://docs.conda.io/en/latest/miniconda.html) for environment dependency management (i.e. the python version, as well as other non-python binaries)
* [conda-lock](https://github.com/conda-incubator/conda-lock) to ensure repeatable environments
* [Poetry](https://python-poetry.org/) for python package management
* [preserve your shell history](https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history) if you mount a volume
* [support for git pre-commit hooks](https://pre-commit.com/)

## More reading
* [Great article on why devcontainers?](https://www.infoq.com/articles/devcontainers/)
* [Why Conda for environment, and Poetry for python dependencies... and HOW](https://stackoverflow.com/questions/70851048/does-it-make-sense-to-use-conda-poetry/71110028#71110028)
* [Slimming down images from dev to production](https://medium.com/semantixbr/getting-started-with-conda-or-poetry-for-data-science-projects-1b3add43956d)
* [vs code support for devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)
