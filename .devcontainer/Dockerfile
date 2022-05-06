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
    bat \
    tree \
    # Setup a bat -> batcat symlink or alias 
    && mkdir -p ~/.local/bin \
    && ln -s /usr/bin/batcat ~/.local/bin/bat \
    # Install eksctl
    && curl --silent \
            --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
            | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin \
    # Install known working version for kubectl
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.6/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl
    
