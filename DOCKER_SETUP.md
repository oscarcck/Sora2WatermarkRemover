# Docker Setup Guide for Sora2WatermarkRemover

This guide explains how to run Sora2WatermarkRemover locally using Docker with Jupyter Notebook support.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [GPU Setup (NVIDIA CUDA)](#gpu-setup-nvidia-cuda)
- [CPU-Only Setup](#cpu-only-setup)
- [Custom Docker Build](#custom-docker-build)
- [Usage Instructions](#usage-instructions)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)

---

## Prerequisites

### Required

- **Docker**: Version 20.10 or later
  - [Install Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/Mac)
  - [Install Docker Engine](https://docs.docker.com/engine/install/) (Linux)
- **Docker Compose**: Version 2.0 or later (usually included with Docker Desktop)

### Optional (for GPU acceleration)

- **NVIDIA GPU**: With compute capability 3.5 or higher
- **NVIDIA Driver**: Version 450.80.02 or later
- **NVIDIA Container Toolkit**: [Installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 8 GB | 16 GB+ |
| **VRAM** (GPU) | 4 GB | 6 GB+ |
| **Disk Space** | 10 GB | 20 GB+ |
| **CPU** | 4 cores | 8+ cores |

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/oscarcck/Sora2WatermarkRemover.git
cd Sora2WatermarkRemover
```

### 2. Create Input/Output Directories

```bash
mkdir -p input output
```

### 3. Build and Start Jupyter Notebook

**With GPU (recommended):**

```bash
# First time: build the custom image (may take 5-10 minutes)
docker compose build

# Start the container
docker compose up
```

**Without GPU (CPU-only):**

```bash
# Uses pre-built image, no build needed
docker compose -f docker-compose.cpu.yml up
```

**Note**: The GPU version uses a custom Dockerfile based on NVIDIA CUDA 12.2 with Python 3.10 (matching Google Colab). The first `docker compose up` will automatically build the image if not already built.

### 4. Access Jupyter

Open your browser and navigate to:

```
http://localhost:8888
```

**Note**: The notebook is configured with no password for local development. For production, set a password (see [Advanced Configuration](#advanced-configuration)).

### 5. Open the Notebook

In Jupyter, navigate to:

```
work/Sora2WatermarkRemover_Local.ipynb
```

### 6. Place Your Files

Copy your video/image files to the `input/` directory:

```bash
cp /path/to/your/video.mp4 input/
```

### 7. Run the Notebook

Follow the instructions in the notebook to process your files.

---

## GPU Setup (NVIDIA CUDA)

### Install NVIDIA Container Toolkit (Linux)

```bash
# Add NVIDIA package repositories
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install nvidia-container-toolkit
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# Restart Docker
sudo systemctl restart docker
```

### Verify GPU Access

```bash
# Test GPU availability in Docker
docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
```

You should see your GPU listed in the output.

### Start with GPU Support

```bash
docker compose up
```

The `docker-compose.yml` file is pre-configured for GPU support using:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

---

## CPU-Only Setup

If you don't have an NVIDIA GPU or prefer CPU processing:

### Start CPU-Only Container

```bash
docker compose -f docker-compose.cpu.yml up
```

**Note**: CPU processing is significantly slower than GPU:
- Images: ~10-30 seconds per image (vs 1-3 seconds on GPU)
- Videos: ~2-10 seconds per frame (vs 0.2-1 second on GPU)

For a 10-second 30fps video, expect:
- **GPU**: 5-10 minutes
- **CPU**: 30-90 minutes

---

## Custom Docker Build

The GPU version (`docker-compose.yml`) uses a custom Dockerfile by default:

### About the Custom Image

- **Base**: `nvidia/cuda:12.2.0-base-ubuntu22.04`
- **Python**: 3.10 (matching Google Colab)
- **CUDA**: 12.2 (matching Google Colab)
- **Pre-installed**: All dependencies including PyTorch, Florence-2, LaMa

### Rebuild After Changes

If you modify the Dockerfile or requirements:

```bash
# Rebuild the image
docker compose build --no-cache

# Or rebuild and start
docker compose up --build
```

### Pre-download LaMa Model

To pre-download the LaMa model (optional, increases image size):

1. Edit `Dockerfile`
2. Uncomment the line:
   ```dockerfile
   # RUN iopaint download --model lama
   ```
3. Rebuild: `docker compose build`

### Image Details

- **Size**: ~6-8 GB (with dependencies)
- **Build time**: 5-10 minutes (first time)
- **Advantages**: Faster startup, consistent environment, exact version control

---

## Usage Instructions

### File Organization

```
Sora2WatermarkRemover/
├── input/              # Place your input files here
│   ├── video1.mp4
│   ├── video2.mp4
│   └── image1.png
├── output/             # Processed files appear here
│   ├── video1.mp4
│   ├── video2.mp4
│   └── image1.png
└── Sora2WatermarkRemover_Local.ipynb
```

### Processing a Single File

1. Open `Sora2WatermarkRemover_Local.ipynb`
2. Run cells 1-3 to set up environment
3. In cell **"4. Process Single File"**, configure:

```python
input_filename = "your_video.mp4"
output_filename = "output_no_watermark.mp4"
max_bbox_percent = 10.0
frame_step = 1
target_fps = 0.0
transparent = False
```

4. Run the processing cell
5. Find output in `output/` directory

### Batch Processing

1. Place multiple files in `input/` directory
2. Navigate to **"5. Batch Processing"** section
3. Configure batch parameters
4. Run the batch processing cell
5. All processed files will appear in `output/`

### Parameters Explained

| Parameter | Default | Description |
|-----------|---------|-------------|
| `max_bbox_percent` | 10.0 | Skip detections covering >N% of image |
| `frame_step` | 1 | Process every Nth frame (2=skip half) |
| `target_fps` | 0.0 | Output FPS (0=preserve input FPS) |
| `transparent` | False | Make watermark transparent vs inpaint |
| `force_format` | None | Force output format (PNG/WEBP/JPG/MP4/AVI) |

---

## Troubleshooting

### Issue: "Cannot connect to the Docker daemon"

**Solution**:

```bash
# Start Docker service (Linux)
sudo systemctl start docker

# Or start Docker Desktop (Windows/Mac)
```

---

### Issue: "GPU not detected in container"

**Verify**:

1. Check NVIDIA driver on host:
   ```bash
   nvidia-smi
   ```

2. Check Docker GPU access:
   ```bash
   docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi
   ```

3. Check NVIDIA Container Toolkit:
   ```bash
   nvidia-ctk --version
   ```

**Solution**:
- Install NVIDIA Container Toolkit (see [GPU Setup](#gpu-setup-nvidia-cuda))
- Restart Docker: `sudo systemctl restart docker`

---

### Issue: "Port 8888 already in use"

**Solution**: Change port in `docker-compose.yml`:

```yaml
ports:
  - "9999:8888"  # Use port 9999 instead
```

Then access at `http://localhost:9999`

---

### Issue: "Permission denied" when accessing files

**Solution**: Fix ownership:

```bash
# On host machine
sudo chown -R $USER:$USER input/ output/
```

Or run container as your user:

```yaml
# In docker-compose.yml
user: "${UID}:${GID}"
```

---

### Issue: "Out of memory" errors

**Solutions**:

1. **Reduce frame processing** (videos):
   ```python
   frame_step = 2  # Process every other frame
   ```

2. **Process smaller files first**: Test with a short video clip

3. **Increase Docker memory limit**:
   - Docker Desktop: Settings → Resources → Memory
   - Increase to 8 GB or more

4. **Clear GPU cache** (in notebook):
   ```python
   import torch
   torch.cuda.empty_cache()
   ```

---

### Issue: "FFmpeg not found"

**Check**: FFmpeg should be installed automatically. If not:

```bash
# Enter container
docker exec -it sora2-watermark-remover bash

# Install FFmpeg
sudo apt-get update && sudo apt-get install -y ffmpeg
```

---

### Issue: Dependency conflict between iopaint and huggingface_hub

**Symptoms**:
```
ERROR: Cannot install huggingface_hub<0.20.0 and iopaint==1.4.4+
```

**Cause**: Version mismatch - diffusers needs functions not available in older huggingface_hub

**Solution**: This is already fixed in requirements files:

```python
# Requirements use compatible versions (matching Colab)
huggingface_hub==0.23.0
iopaint==1.6.0  # Latest stable version
diffusers==0.27.0
```

If you encounter this error:

```bash
# Use the provided requirements files
pip install -r requirements-cu121.txt
```

Or use the provided requirements files:

```bash
# CUDA 12+ (recommended, matches Colab)
pip install -r requirements-cu121.txt

# CPU only
pip install -r requirements-cpu.txt
```

**Note:** We use PyTorch cu121 builds which work with CUDA 12.1-12.6 runtime. PyTorch doesn't provide cu122 builds specifically.

See [DEPENDENCIES.md](DEPENDENCIES.md) for detailed version information.

---

### Issue: Slow processing on GPU

**Verify CUDA is being used**:

In the notebook, run:

```python
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA device: {torch.cuda.get_device_name(0)}")
```

Should output:
```
CUDA available: True
CUDA device: NVIDIA GeForce RTX 3080 (or your GPU)
```

If `False`, use CPU-only compose file or check GPU setup.

---

## Advanced Configuration

### Set Jupyter Password

Edit `docker-compose.yml`:

```yaml
command: >
  bash -c "
  apt-get update && apt-get install -y ffmpeg &&
  chown -R jovyan:users /home/jovyan/work &&
  su jovyan -c 'start-notebook.sh --NotebookApp.password=\"sha1:your-hashed-password\"'
  "
```

Generate hashed password:

```python
from notebook.auth import passwd
print(passwd('your-password'))
```

---

### Persist Model Downloads

Models are already persisted via Docker volume:

```yaml
volumes:
  - model-cache:/home/jovyan/.cache
```

To pre-download models, uncomment in `Dockerfile`:

```dockerfile
RUN iopaint download --model lama
```

Then rebuild:

```bash
docker build -t sora2-watermark-remover:latest .
```

---

### Enable JupyterLab

Already enabled by default via:

```yaml
environment:
  - JUPYTER_ENABLE_LAB=yes
```

To use classic Jupyter Notebook instead:

```yaml
environment:
  - JUPYTER_ENABLE_LAB=no
```

---

### Limit GPU Memory Usage

Add to `docker-compose.yml`:

```yaml
environment:
  - CUDA_VISIBLE_DEVICES=0  # Use only GPU 0
  - PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
```

---

### Custom Python Packages

Edit `Dockerfile` and add:

```dockerfile
RUN pip install --no-cache-dir \
    your-package \
    another-package
```

Rebuild:

```bash
docker build -t sora2-watermark-remover:latest .
```

---

### Run Container in Background

```bash
# Start in detached mode
docker compose up -d

# View logs
docker compose logs -f

# Stop container
docker compose down
```

---

## Docker Commands Reference

### Start Container

```bash
# GPU version
docker compose up

# CPU version
docker compose -f docker-compose.cpu.yml up

# Background mode
docker compose up -d
```

### Stop Container

```bash
docker compose down
```

### View Logs

```bash
docker compose logs -f
```

### Access Container Shell

```bash
docker exec -it sora2-watermark-remover bash
```

### Remove Containers and Volumes

```bash
# Stop and remove containers
docker compose down

# Remove volumes (WARNING: deletes model cache)
docker compose down -v
```

### Rebuild Image

```bash
docker compose build --no-cache
```

### Check Container Status

```bash
docker compose ps
```

---

## Performance Benchmarks

Approximate processing times (1080p video, 30fps):

| Hardware | Frame Processing | 10s Video (300 frames) |
|----------|------------------|------------------------|
| **RTX 4090** | 0.2s/frame | ~1 min |
| **RTX 3080** | 0.5s/frame | ~2.5 min |
| **RTX 2060** | 1s/frame | ~5 min |
| **CPU (16 cores)** | 5s/frame | ~25 min |
| **CPU (8 cores)** | 8s/frame | ~40 min |

**Note**: Times include detection + inpainting. Transparency mode is slightly faster.

---

## Comparison: Docker vs Conda

| Feature | Docker | Conda |
|---------|--------|-------|
| **Setup Time** | 5 minutes | 15-30 minutes |
| **Isolation** | Complete | Environment only |
| **FFmpeg** | Auto-installed | Manual install |
| **Portability** | High | Medium |
| **Disk Space** | ~5-10 GB | ~5 GB |
| **Updates** | Rebuild image | Update packages |
| **GUI** | Jupyter only | Jupyter + remwmgui.py |

---

## FAQ

### Q: Can I use the GUI (remwmgui.py) in Docker?

**A**: Not easily. Docker is optimized for web interfaces (Jupyter). For GUI, use Conda environment instead:

```bash
./setup.sh
conda activate py312aiwatermark
python remwmgui.py
```

---

### Q: How do I update to the latest code?

**A**: Pull latest changes and restart container:

```bash
git pull
docker compose down
docker compose up
```

---

### Q: Can I run multiple notebooks simultaneously?

**A**: Yes, start multiple containers with different ports:

```bash
# Container 1 (port 8888)
docker compose up -d

# Container 2 (port 8889)
docker compose -p sora2-2 -f docker-compose.yml up -d
# Edit docker-compose.yml to use port 8889 first
```

---

### Q: How do I process files via CLI instead of notebook?

**A**: Access container shell:

```bash
docker exec -it sora2-watermark-remover bash

# Then use remwm.py directly
cd /home/jovyan/work
python remwm.py input/video.mp4 output/result.mp4
```

---

### Q: Is my GPU supported?

**A**: Check CUDA compute capability:

```bash
nvidia-smi --query-gpu=compute_cap --format=csv
```

Requires compute capability ≥ 3.5 (most GPUs from 2012+).

---

## Additional Resources

- **Main README**: [README.md](README.md)
- **AI Assistant Guide**: [CLAUDE.md](CLAUDE.md)
- **Jupyter Docker Stacks**: https://jupyter-docker-stacks.readthedocs.io/
- **NVIDIA Container Toolkit**: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/
- **Docker Compose Reference**: https://docs.docker.com/compose/

---

## Support

For issues specific to Docker setup:

1. Check this guide's [Troubleshooting](#troubleshooting) section
2. Verify Docker installation: `docker --version` and `docker compose version`
3. Check GPU setup: `nvidia-smi` and `docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi`
4. File an issue: https://github.com/oscarcck/Sora2WatermarkRemover/issues

For general usage questions, see [README.md](README.md).

---

**Happy watermark removing! 🚀**
