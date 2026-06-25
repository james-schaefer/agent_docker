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
        build-essential \
        linux-headers-generic \
        binutils \
        strace \
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
        pandoc \
        graphviz\
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-recommended \
        latexmk \
        chromium \
        locales \
        jq \
        x11-apps \
        xclip \
        graphviz && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install --system --skip-repo && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Fix up user account
RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -d ${HOME_DIR} -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USERNAME} && \
    mkdir -p ${HOME_DIR}/docker_bridge

# Node.js 22 LTS from NodeSource (Debian's nodejs is v18, too old for pi.dev's /v regex flag)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Neovim 0.12 release binary
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64)   NVIM_ARCH="x86_64" ;; \
      arm64)   NVIM_ARCH="arm64"  ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v0.12.3/nvim-linux-${NVIM_ARCH}.tar.gz" \
    | tar -xz -C /usr/local --strip-components=1

# Zig 0.16.0 release binary
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64)   ZIG_ARCH="x86_64" ;; \
      arm64)   ZIG_ARCH="aarch64" ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://ziglang.org/download/0.16.0/zig-${ZIG_ARCH}-linux-0.16.0.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1 && \
    ln -sf /usr/local/zig /usr/local/bin/zig

# Symlink vi, vim, neovim → nvim (system-wide, works in scripts and non-interactive shells)
RUN ln -sf /usr/local/bin/nvim /usr/local/bin/vim && \
    ln -sf /usr/local/bin/nvim /usr/local/bin/vi && \
    ln -sf /usr/local/bin/nvim /usr/local/bin/neovim

RUN echo 'export PS1="\u@agent-dev:\w\$ "' > /etc/profile.d/prompt.sh

# Install pi coding agent
RUN npm install -g @earendil-works/pi-coding-agent

USER ${USERNAME}
WORKDIR ${HOME_DIR}

# System-wide environment variables
ENV EDITOR=nvim
ENV VISUAL=nvim
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install neovim config
RUN git clone --depth=1 https://github.com/james-schaefer/neovim_config.git ~/.config/nvim

# Fix up path for AI agents
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash","-lc","exec /bin/bash -l"]

