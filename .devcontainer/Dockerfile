# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.231.6/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version (use bullseye on local arm64/Apple Silicon): bullseye, buster
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# ** [Optional] Uncomment this section to install additional packages. **
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        jq \
        tree \
        dnsutils \
        bat \
        fzf \
        kubecolor \
    # Setup a bat -> batcat symlink or alias 
    && ln -s $(which batcat) /bin/bat \
    # Install eksctl
    && curl --silent \
            --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
            | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin \
    # Install known working version for kubectl
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    # doctl for digital Ocean
    && wget https://github.com/digitalocean/doctl/releases/download/v1.74.0/doctl-1.74.0-linux-amd64.tar.gz \
    && tar xf ./doctl-1.74.0-linux-amd64.tar.gz \
    && chmod +x ./doctl \
    && mv ./doctl /usr/local/bin \
    && rm ./doctl-1.74.0-linux-amd64.tar.gz \
    # Load aliases 
    && echo ". /workspaces/dev-container/.bash_aliases" >> /etc/bash.bashrc \
    # Load fzf shortcuts for bash 
    && echo ". /usr/share/doc/fzf/examples/key-bindings.bash" >> /etc/bash.bashrc \
    && echo ". /usr/share/doc/fzf/examples/completion.bash" >> /etc/bash.bashrc
