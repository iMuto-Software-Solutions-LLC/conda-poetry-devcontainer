# note this is "mcr.microsoft.com/devcontainers/miniconda:3" as of Apr 14, 2023
FROM mcr.microsoft.com/devcontainers/miniconda@sha256:efc9a8484266dd6ca776fe90dea66c55548706c956da8aebd4b275474eac0d11

USER root

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

# # we'll be installing things
RUN apt-get update
WORKDIR /tmp

# ###########################################
# # poetry
# ###########################################
RUN mkdir -p /home/${USERNAME}/.config && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
COPY --chown=${USERNAME} .config/pypoetry /home/${USERNAME}/.config/pypoetry
RUN mkdir /home/${USERNAME}/.oh-my-zsh/custom/plugins/poetry && \
    poetry completions zsh > /home/${USERNAME}/.oh-my-zsh/custom/plugins/poetry/_poetry && \
    sed -i 's/plugins=(/&poetry /' /home/${USERNAME}/.zshrc
RUN poetry self add pip
RUN poetry self add poetry-bumpversion==0.3.0

# ###########################################
# # aws cli
# ###########################################
RUN curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
	./aws/install 
# configure shell for autocomplete
RUN echo 'export PATH=/usr/local/bin/aws_completer:$PATH' >> "/home/${USERNAME}/.zshrc" && \ 
    echo 'autoload bashcompinit && bashcompinit' >> "/home/${USERNAME}/.zshrc" && \ 
    echo 'autoload -Uz compinit && compinit' >> "/home/${USERNAME}/.zshrc" && \ 
    echo 'complete -C "/usr/local/bin/aws_completer" aws' >> "/home/${USERNAME}/.zshrc"

# ###########################################
# # kubectl
# ###########################################
RUN mkdir /etc/apt/keyrings && \
    curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl=1.26.0-00
# configure shell
COPY --chown=${USERNAME} .kube /home/${USERNAME}/.kube
RUN echo 'source <(kubectl completion zsh)' >> /home/${USERNAME}/.zshrc && \
    echo 'alias kc="kubectl"' >> /home/${USERNAME}/.zshrc && \
    echo 'alias node-roles="kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints,PROXY:.metadata.labels.proxy,WORKLOAD:.metadata.labels.workload,\"NODEGROUP\":\".metadata.labels.eks\.amazonaws\.com/nodegroup\",VERSION:.status.nodeInfo.kubeletVersion --sort-by=\".metadata.labels.eks\.amazonaws\.com/nodegroup\""'  >> /home/${USERNAME}/.zshrc

# ###########################################
# # kube-ps1
# ###########################################
RUN sed -i 's/plugins=(/&kube-ps1 /' /home/${USERNAME}/.zshrc && \
    echo "export PROMPT='\$(kube_ps1)'\$PROMPT" >> /home/${USERNAME}/.zshrc

# ###########################################
# # kubeswitch
# ###########################################
ARG KUBESWITCH_VERSION=0.7.2
RUN curl -sSL https://github.com/danielfoehrKn/kubeswitch/releases/download/${KUBESWITCH_VERSION}/switcher_linux_amd64 -o /usr/local/bin/switcher && \
    chmod +x /usr/local/bin/switcher && \
    curl -sSL https://github.com/danielfoehrKn/kubeswitch/releases/download/${KUBESWITCH_VERSION}/switch.sh -o /usr/local/bin/switch.sh && \
    chmod +x /usr/local/bin/switch.sh
RUN echo 'source /usr/local/bin/switch.sh' >> /home/${USERNAME}/.zshrc
# see https://github.com/danielfoehrKn/kubeswitch/blob/master/docs/command_completion.md#zsh
RUN echo 'autoload bashcompinit' >> /home/${USERNAME}/.zshrc && \
    echo 'bashcompinit' >> /home/${USERNAME}/.zshrc && \
    echo 'source ~/.kube/_switch.bash' >> /home/${USERNAME}/.zshrc

# ###########################################
# # git pre-commit
# ###########################################
RUN pipx install pre-commit==2.21.0
RUN echo 'alias pcr="pre-commit run --files ./**/*"' >> /home/${USERNAME}/.zshrc

# ###########################################
# # alias tips
# ###########################################
RUN git clone https://github.com/djui/alias-tips.git /home/${USERNAME}/.oh-my-zsh/custom/plugins/alias-tips && \
    sed -i 's/plugins=(/&alias-tips /' /home/${USERNAME}/.zshrc

# ###########################################
# # yq
# ###########################################
RUN wget https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_386 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# ###########################################
# # docker cli
# ###########################################
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# ###########################################
# # misc
# ###########################################
# see https://stackoverflow.com/a/10872202/19269 and https://unix.stackexchange.com/a/87763/27677
RUN echo 'alias git="LC_ALL=C git"' >> /home/${USERNAME}/.zshrc
RUN echo 'if [ -f ".env" ]; then set -a && source .env && set +a; fi' >> /home/${USERNAME}/.zshrc

# # set the user
USER ${USERNAME}

# # get latest omz
RUN cd /home/${USERNAME}/.oh-my-zsh && ./tools/upgrade.sh 

WORKDIR /home/${USERNAME}
