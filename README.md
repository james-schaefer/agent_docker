# Project Overview

A Docker container for running LLM CLI agents (Pi, Claude Code) with a rich dev
toolchain.

### Dockerfile

 - Base: debian:bookworm-slim
 - Toolchain: build-essential, zig, gdb, strace, llvm/clang/lld, cmake, python3, lua5.4, nodejs/npm, ripgrep, jq, pandoc, chromium
 - Arch-aware: Neovim 0.12.2 install handles both amd64 and arm64 at build time
 - Kernel-style Sphinx docs: pinned Sphinx 5.3.0 + RTD theme + svg2pdf/pymupdf/ply/ditaa extensions in `/opt/sphinx-venv`, on PATH. `make htmldocs` / `make pdfdocs` work against a cloned kernel tree out of the box.
 - agent harnesses: Claude Code, Pi.dev
 - james' Neovim config: cloned from james-schaefer/neovim_config repo 

### Scripts

| Script         | Purpose                                                      |
| -------------- | ------------------------------------------------------------ |
| build.sh       | Builds image with --no-cache, logs to build.log              |
| run.sh         | Runs container with X11, GPU, host networking, volume mounts |
| exec.sh        | Opens extra shell in running container                       |
| restart.sh     | Restarts container (re-grants X access)                      |
| archive.sh     | Renames old container/image to \*.old before rebuild         |
| archive_run.sh | Runs the archived container                                  |

### Kernel-style Sphinx docs

The image ships a pinned, isolated Sphinx toolchain at `/opt/sphinx-venv`
(Sphinx 5.3.0 + RTD theme + `sphinxcontrib-svg2pdfconverter`, `pymupdf`, `ply`,
`ditaa`) suitable for building Linux kernel documentation against 6.x trees.

Inside a cloned kernel source tree:

```bash
make htmldocs      # HTML output under Documentation/output/
make pdfdocs        # PDF via the installed TeX Live + latexmk
make latexdocs      # LaTeX sources
```

`sphinx-build` is on `PATH` and symlinked into `/usr/local/bin`, so the kernel's
`Documentation/Makefile` finds it automatically. `scripts/sphinx-pre-install`
can be run once per tree to confirm all system dependencies are satisfied.

For kernels that need a different Sphinx pin (e.g. 5.15 LTS requires Sphinx
2.4.x), create a per-tree venv from that tree's
`Documentation/sphinx/requirements.txt`:

```bash
python3 -m venv ~/.sphinx-venv
~/.sphinx-venv/bin/pip install -r Documentation/sphinx/requirements.txt
SPHINXBUILD=~/.sphinx-venv/bin/sphinx-build make htmldocs
```
