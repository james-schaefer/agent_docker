# DGX Spark (ARM64) Notes

## Platform

The NVIDIA DGX Spark uses ARM64 (aarch64) Grace CPUs. The Docker image builds and
runs on both x86_64 and arm64 without separate Dockerfiles.

## Changes Made

### Dockerfile — architecture-aware Neovim download

The Neovim binary download was hardcoded to `nvim-linux-x86_64.tar.gz`, which does
not run on ARM. It now detects the build architecture at image build time:

```dockerfile
RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64)   NVIM_ARCH="x86_64" ;; \
      arm64)   NVIM_ARCH="arm64"  ;; \
      *)       echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-linux-${NVIM_ARCH}.tar.gz" \
    | tar -xz -C /usr/local --strip-components=1
```

### run.sh — GPU passthrough

Added `--gpus all` to the `docker run` command so all NVIDIA GPUs are visible inside
the container via the NVIDIA Container Toolkit.

## Host Prerequisites (DGX Spark)

### 1. Verify NVIDIA Container Toolkit is installed

```bash
nvidia-ctk --version
docker info | grep -i runtime
# Expected output includes: Runtimes: nvidia runc
```

### 2. Install if missing

```bash
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

### 3. Smoke-test GPU access before building

```bash
docker run --rm --gpus all nvidia/cuda:12-base-ubuntu22.04 nvidia-smi
```

This should print the GPU table. If it fails, the toolkit is not correctly configured.

## Building on the Spark

No extra flags are needed — Docker on an ARM64 host defaults to `linux/arm64`:

```bash
./build.sh
```
