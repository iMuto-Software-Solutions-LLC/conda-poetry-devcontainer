# note this is "mcr.microsoft.com/devcontainers/miniconda:0-3" as of Jan 11, 2023
FROM mcr.microsoft.com/devcontainers/miniconda@sha256:351cfc5b3063e10e4af7e89e94667f99223059d759ed42a6b859fb20ac11fbd4

# install tools for package management
RUN conda install --name base -c conda-forge mamba=1.1.0
RUN pipx install conda-lock==1.3.0
RUN pipx install poetry==1.3.2

# use zsh (includes oh-my-zsh)
ENV SHELL /usr/bin/zsh
CMD [ /usr/bin/zsh ]

# this user comes with the microsoft devcontainer image
ARG USERNAME=vscode

# allow for preserving shell history - see https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.zsh_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.zsh_history \
    && chown -R $USERNAME /commandhistory \
    && echo "${SNIPPET}" >> "/home/${USERNAME}/.zshrc"

# we'll be installing things
RUN apt-get update
WORKDIR /tmp

###########################################
# poetry
###########################################
RUN mkdir -p /home/${USERNAME}/.config && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
COPY --chown=${USERNAME} .config/pypoetry /home/${USERNAME}/.config/pypoetry
RUN mkdir /home/${USERNAME}/.oh-my-zsh/custom/plugins/poetry && \
    poetry completions zsh > /home/${USERNAME}/.oh-my-zsh/custom/plugins/poetry/_poetry && \
    sed -i 's/plugins=(/&poetry /' /home/${USERNAME}/.zshrc
RUN poetry self add pip
RUN poetry self add poetry-bumpversion==0.3.0

###########################################
# git pre-commit
###########################################
RUN pipx install pre-commit==2.21.0
RUN echo 'alias pcr="pre-commit run --files ./**/*"' >> /home/${USERNAME}/.zshrc

###########################################
# alais tips
###########################################
RUN git clone https://github.com/djui/alias-tips.git /home/${USERNAME}/.oh-my-zsh/custom/plugins/alias-tips && \
    sed -i 's/plugins=(/&alias-tips /' /home/${USERNAME}/.zshrc

###########################################
# misc
###########################################
# see https://stackoverflow.com/a/10872202/19269 and https://unix.stackexchange.com/a/87763/27677
RUN echo 'alias git="LC_ALL=C git"' >> /home/${USERNAME}/.zshrc
RUN echo 'if [ -f ".env" ]; then set -a && source .env && set +a; fi' >> /home/${USERNAME}/.zshrc

# set the user
USER ${USERNAME}

# get latest omz
RUN cd /home/${USERNAME}/.oh-my-zsh && ./tools/upgrade.sh 

WORKDIR /home/${USERNAME}
