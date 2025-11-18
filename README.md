# Sora2 Watermark Remover

Remove watermarks from Sora-generated videos and images using AI-powered detection and inpainting.

## Quick Start

### 🐳 Docker (Recommended for Local Use)

**GPU (CUDA 12):**
```bash
git clone https://github.com/oscarcck/Sora2WatermarkRemover.git
cd Sora2WatermarkRemover
./docker-setup.sh
```

Then open http://localhost:8888 and use `Sora2WatermarkRemover_Local.ipynb`

**See [DOCKER_SETUP.md](DOCKER_SETUP.md) for detailed instructions.**

### ☁️ Google Colab (Free GPU)

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1Iqu4RZ9WAhcbO1Jn0wCkMOsw2l1p6z62?usp=sharing)

Click the badge above to run in Google Colab (no installation required).

### 💻 Conda (Traditional Setup)

```bash
git clone https://github.com/oscarcck/Sora2WatermarkRemover.git
cd Sora2WatermarkRemover
./setup.sh
conda activate py312aiwatermark
python remwm.py input.mp4 output.mp4
```

**Or install manually with pip:**
```bash
# Create environment (Python 3.10 matches Google Colab)
conda create -n py312aiwatermark python=3.10
conda activate py312aiwatermark

# Install with CUDA 12+ support (recommended, matches Colab)
pip install -r requirements-cu121.txt

# Or CPU-only version
pip install -r requirements-cpu.txt
```

See [DEPENDENCIES.md](DEPENDENCIES.md) for version details.

### Removed watermark


[out.webm](https://github.com/user-attachments/assets/d902d040-f54c-4958-8d27-8b3c3bcbb6dd)




### Source

https://github.com/user-attachments/assets/8deffd66-b961-4ec2-9dc0-97695b0f91c5

## Features

- 🎯 **AI-Powered Detection**: Uses Florence-2 for accurate watermark detection
- 🎨 **Smart Inpainting**: LaMa model for realistic watermark removal
- 🚀 **GPU Acceleration**: CUDA 12 support for fast processing
- 📦 **Multiple Interfaces**: CLI, GUI, Jupyter notebooks
- 🎬 **Video Support**: Process videos with audio preservation
- ⚡ **Batch Processing**: Process multiple files at once
- 🔧 **Flexible**: Frame skipping, FPS control, transparency mode

## Installation Methods

| Method | Best For | Setup Time | GPU Support |
|--------|----------|------------|-------------|
| **Docker** | Quick local setup | 5 min | ✅ CUDA 12 |
| **Colab** | No local install | 0 min | ✅ Free GPU |
| **Conda** | Traditional dev | 15 min | ✅ Configurable |

## Usage

### Docker

```bash
# Place your files in input/ directory
cp your_video.mp4 input/

# Start Jupyter
docker compose up

# Open http://localhost:8888
# Run Sora2WatermarkRemover_Local.ipynb
```

### CLI

```bash
# Single file
python remwm.py input.mp4 output.mp4

# With options
python remwm.py input.mp4 output.mp4 \
  --frame-step 2 \
  --max-bbox-percent 10 \
  --target-fps 30

# Batch processing
python remwm.py input_dir/ output_dir/ --overwrite
```

### GUI

```bash
python remwmgui.py
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--max-bbox-percent` | 10.0 | Skip detections >N% of image |
| `--frame-step` | 1 | Process every Nth frame |
| `--target-fps` | 0 | Output FPS (0=preserve) |
| `--transparent` | False | Make watermark transparent |
| `--force-format` | None | Output format (PNG/WEBP/JPG/MP4/AVI) |
| `--overwrite` | False | Overwrite existing files |

## Documentation

- **[DOCKER_SETUP.md](DOCKER_SETUP.md)** - Complete Docker guide
- **[CLAUDE.md](CLAUDE.md)** - AI assistant codebase guide
- **[INSTALLATION_FR.md](INSTALLATION_FR.md)** - French installation guide
- **[DEMARRAGE_RAPIDE.md](DEMARRAGE_RAPIDE.md)** - French quick start

## Related Projects

This project builds upon and is inspired by:

- [SoraWatermarkCleaner](https://github.com/linkedlist771/SoraWatermarkCleaner) - Remove watermarks from SORA 2 videos with LaMA inpainting
- [sweeta](https://github.com/Kuberwastaken/sweeta) - Alternative watermark removal tool

## Video Tutorial

Watch the complete tutorial:

[![Sora2WatermarkRemover Tutorial](https://img.youtube.com/vi/HkXD4zwk6WY/0.jpg)](https://www.youtube.com/watch?v=HkXD4zwk6WY)

## Requirements

- **Python**: 3.10 (recommended, matches Colab), 3.11, or 3.12
- **RAM**: 16GB recommended
- **VRAM**: 6GB+ recommended (GPU)
- **FFmpeg**: For video audio merging

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for community guidelines.

## Support

- 📝 File issues: [GitHub Issues](https://github.com/oscarcck/Sora2WatermarkRemover/issues)
- 📖 Read docs: Start with [DOCKER_SETUP.md](DOCKER_SETUP.md) or [CLAUDE.md](CLAUDE.md)
- 💬 Check existing issues for common problems