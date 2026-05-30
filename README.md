# Project Overview

A Docker container for running LLM CLI agents (Pi, Claude Code) with a rich dev
toolchain.

### Dockerfile

 - Base: debian:bookworm-slim
 - Toolchain: build-essential, zig, gdb, strace, llvm/clang/lld, cmake, python3, lua5.4, nodejs/npm, ripgrep, jq, pandoc, chromium
 - Arch-aware: Neovim 0.12.2 install handles both amd64 and arm64 at build time
 - Mermaid: @mermaid-js/mermaid-cli with puppeteer pointed at system chromium (sandbox disabled for Docker)
 - Claude Code: installed via official curl script
 - james' Neovim config: cloned from james-schaefer/neovim_config repo

### Scripts

| Script         | Purpose                                                      |
| -------------- | ------------------------------------------------------------ |
| build.sh       | Builds image with --no-cache, logs to build.log              |
| run.sh         | Runs container with X11, GPU, host networking, volume mounts |
| exec.sh        | Opens extra shell in running container                       |
| restart.sh     | Restarts container (re-grants X access)                      |
| archive.sh     | Renames old container/image to *.old before rebuild          \
\ archive_run.sh \ Runs the archived container                                  \
