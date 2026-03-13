FROM debian:bookworm-slim

ARG USERNAME=schaefer
ARG HOME_DIR=/home/${USERNAME}
ARG USER_UID=1000
ARG USER_GID=1000
ARG NEOVIM_REF=master

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
        libtool \
        gettext \
        autopoint \
        ninja-build \
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
        locales && \
    rm -rf /var/lib/apt/lists/* && \
    git lfs install --system --skip-repo && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# fix up user account
RUN groupadd -g ${USER_GID} ${USERNAME} && \
    useradd -m -d ${HOME_DIR} -s /bin/bash -u ${USER_UID} -g ${USER_GID} ${USERNAME} && \
    mkdir -p ${HOME_DIR}/docker_bridge

# Neovim build from sources
RUN git clone --depth=1 --branch ${NEOVIM_REF} https://github.com/neovim/neovim.git /tmp/neovim && \
    make -C /tmp/neovim CMAKE_BUILD_TYPE=RelWithDebInfo && \
    make -C /tmp/neovim install && \
    rm -rf /tmp/neovim

RUN echo 'export PS1="\u@\h:\w\$ "' > /etc/profile.d/prompt.sh
RUN echo 'alias vim="nvim"' > /etc/profile.d/vim-alias.sh

USER ${USERNAME}
WORKDIR ${HOME_DIR}

ENV EDITOR=nvim
ENV VISUAL=nvim
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

WORKDIR ${HOME_DIR}

#install claude code
ENV PATH="${HOME_DIR}/.local/bin:$PATH"
RUN curl -fsSL https://claude.ai/install.sh | bash


CMD ["bash","-lc","exec /bin/bash -l"]
