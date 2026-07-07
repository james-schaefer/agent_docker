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
        gcc-arm-none-eabi \
        binutils-arm-none-eabi \
        libnewlib-arm-none-eabi \
        libstdc++-arm-none-eabi-newlib \
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
        texlive-latex-recommended \
        texlive-latex-extra \
        texlive-fonts-recommended \
        latexmk \
        python3-venv \
        librsvg2-bin \
        imagemagick \
        chromium \
        locales \
        jq \
        x11-apps \
        xclip \
        gnuplot-nox \
        datamash \
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

# Linux Kernel-style Sphinx docs toolchain (pinned to 6.x-kernel-supported versions).
# Installed into an isolated venv so it doesn't clash with distro Python packages;
# the kernel's Documentation/Makefile finds sphinx-build via PATH.
# Note: ditaa is a Java application (distributed as a JAR), not a PyPI package, so
# it is NOT installed via pip here -- install its JAR separately if/when needed.
RUN python3 -m venv /opt/sphinx-venv && \
    /opt/sphinx-venv/bin/python -m pip install --upgrade pip && \
    /opt/sphinx-venv/bin/pip install \
        "sphinx==5.3.0" \
        "sphinx_rtd_theme==1.3.0" \
        "sphinxcontrib-svg2pdfconverter==1.2.2" \
        "pymupdf==1.23.8" \
        "ply==3.11" \
        "Babel" "Jinja2" "MarkupSafe" "alabaster" "docutils" \
        "imagesize" "packaging" "pygments" "requests" "snowballstemmer" \
        "sphinxcontrib-applehelp" "sphinxcontrib-devhelp" \
        "sphinxcontrib-htmlhelp" "sphinxcontrib-qthelp" \
        "sphinxcontrib-serializinghtml" && \
    ln -sf /opt/sphinx-venv/bin/sphinx-build /usr/local/bin/sphinx-build && \
    ln -sf /opt/sphinx-venv/bin/sphinx-apidoc /usr/local/bin/sphinx-apidoc

# Install pi coding agent
RUN npm install -g @earendil-works/pi-coding-agent

USER ${USERNAME}
WORKDIR ${HOME_DIR}

# System-wide environment variables
ENV EDITOR=nvim
ENV VISUAL=nvim
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PATH="/opt/sphinx-venv/bin:${PATH}"

# Install neovim config
RUN git clone --depth=1 https://github.com/james-schaefer/neovim_config.git ~/.config/nvim

# Fix up path for AI agents
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

CMD ["bash","-lc","exec /bin/bash -l"]

