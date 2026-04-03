FROM debian:bookworm-slim

ARG USERNAME=schaefer
ARG HOME_DIR=/home/${USERNAME}
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update && \
    apt-get install -y \
        bash \
        curl \
        ca-certificates \
        build-essential\
        linux-headers-generic \
        binutils \
        strace \
        ltrace \
        ripgrep \
        libcapstone4 \
        libcapstone-dev \
        gdb \
        python3 \
        python3-dev \
        python3-pip \
        cmake \
        autoconf \
        automake \
        gettext \
        unzip \
        tar \
        xz-utils \
        git \
        git-lfs \
        llvm-dev \
        libclang-dev \
        lld \
        zlib1g-dev \
        libzstd-dev \
        lua5.4 \
        liblua5.4-dev \
        nodejs \
        npm \
        pandoc \
        chromium \
        locales \
        xclip \
        x11-apps && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install --system --skip-repo && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# fix up user account
RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -d ${HOME_DIR} -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USERNAME} && \
    mkdir -p ${HOME_DIR}/docker_bridge

# Neovim 0.12 release binary
RUN curl -fsSL https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-linux-x86_64.tar.gz \
    | tar -xz -C /usr/local --strip-components=1

RUN echo 'export PS1="\u@\h:\w\$ "' > /etc/profile.d/prompt.sh
RUN echo 'alias vim="nvim"' > /etc/profile.d/vim-alias.sh

# Install mermaid-cli using system Chromium (skip Puppeteer's bundled download)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN npm install -g @mermaid-js/mermaid-cli

# Mermaid diagramming tool requires --no-sandbox inside the container; embed config and wrap mmdc
RUN echo '{"args":["--no-sandbox","--disable-setuid-sandbox"]}' \
    > /usr/local/etc/puppeteer-config.json && \
    mv /usr/local/bin/mmdc /usr/local/bin/mmdc-real && \
    printf '#!/bin/sh\nexec mmdc-real -p /usr/local/etc/puppeteer-config.json "$@"\n' \
    > /usr/local/bin/mmdc && \
    chmod +x /usr/local/bin/mmdc

USER ${USERNAME}
WORKDIR ${HOME_DIR}

ENV EDITOR=nvim
ENV VISUAL=nvim
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR ${HOME_DIR}

# Install neovim config
RUN git clone --depth=1 https://github.com/james-schaefer/neovim_config.git ~/.config/nvim

# fix up path for ai agents
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

#install claude code (binary is "claude")
RUN curl -fsSL https://claude.ai/install.sh | bash

#install cursor agent (binary is "agent")
RUN curl https://cursor.com/install -fsS | bash

#install codex (binary is "codex")
RUN npm install -g @openai/codex


CMD ["bash","-lc","exec /bin/bash -l"]
