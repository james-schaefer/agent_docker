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
        nodejs \
        npm \
        pandoc \
        chromium \
        locales \
        xclip \
        jq \
        x11-apps && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install --system --skip-repo && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Fix up user account
RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -d ${HOME_DIR} -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USERNAME} && \
    mkdir -p ${HOME_DIR}/docker_bridge

# Neovim 0.12 release binary
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64)   NVIM_ARCH="x86_64" ;; \
      arm64)   NVIM_ARCH="arm64"  ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-${NVIM_ARCH}.tar.gz" \
    | tar -xz -C /usr/local --strip-components=1

RUN echo 'export PS1="\u@\h:\w\$ "' > /etc/profile.d/prompt.sh
RUN echo 'alias vim="nvim"' > /etc/profile.d/vim-alias.sh

# Install mermaid-cli
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN npm install -g @mermaid-js/mermaid-cli

RUN echo '{"args":["--no-sandbox","--disable-setuid-sandbox"]}' \
    > /usr/local/etc/puppeteer-config.json && \
    mv /usr/local/bin/mmdc /usr/local/bin/mmdc-real && \
    printf '#!/bin/sh\nexec mmdc-real -p /usr/local/etc/puppeteer-config.json "$@"\n' \
    > /usr/local/bin/mmdc && \
    chmod +x /usr/local/bin/mmdc

USER ${USERNAME}
WORKDIR ${HOME_DIR}

# System-wide environment variables
ENV EDITOR=nvim
ENV VISUAL=nvim
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create Claude Code settings.json with vLLM configuration
RUN mkdir -p ~/.claude && \
    cat > ~/.claude/settings.json << 'EOF'
{
  "apiKeyHelper": "echo 'dummy-key'",
  "env": {
    "ANTHROPIC_BASE_URL": "http://localhost:8000",
    "API_TIMEOUT_MS": "3000000",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_AUTOUPDATER": "1",
    "DISABLE_ERROR_REPORTING": "1",
    "ANTHROPIC_MODEL": "default_model",
    "ANTHROPIC_SMALL_FAST_MODEL": "default_model",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "default_model",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "default_model",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "default_model"
  }
}
EOF

# Install neovim config
RUN git clone --depth=1 https://github.com/james-schaefer/neovim_config.git ~/.config/nvim

# Fix up path for AI agents
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash","-lc","exec /bin/bash -l"]

