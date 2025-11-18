# Dependency Version Guide

This document explains the dependency versions used in Sora2WatermarkRemover and why they were chosen.

## Version Selection Criteria

All versions are pinned for:
- **CUDA 12 compatibility** (tested with 12.1-12.6)
- **Python 3.11 compatibility**
- **Stability** (avoiding breaking changes)
- **Security** (patched versions)

## Requirements Files

| File | Use Case | Installation |
|------|----------|-------------|
| `requirements.txt` | Standard CUDA 12.1 | `pip install -r requirements.txt` |
| `requirements-cu121.txt` | Full CUDA 12.1 with all extras | `pip install -r requirements-cu121.txt` |
| `requirements-cpu.txt` | CPU-only (no GPU) | `pip install -r requirements-cpu.txt` |

## Core Dependencies

### PyTorch Ecosystem

```
torch==2.1.2+cu121
torchvision==0.16.2+cu121
torchaudio==2.1.2+cu121
```

**Why these versions:**
- PyTorch 2.1.2 is stable and well-tested
- `+cu121` suffix indicates CUDA 12.1 builds
- Compatible with CUDA 12.1, 12.2, 12.3, 12.4, 12.5, 12.6
- Python 3.11 fully supported
- Good performance on modern GPUs (RTX 30/40 series)

**Installation note:** Requires `--extra-index-url https://download.pytorch.org/whl/cu121`

### HuggingFace Libraries

```
huggingface_hub==0.20.3
transformers==4.36.2
tokenizers==0.15.0
safetensors==0.4.1
```

**Why these versions:**
- `huggingface_hub==0.20.3`: Required by iopaint 1.3.5+, compatible version
- `transformers==4.36.2`: Stable, compatible with Florence-2
- `tokenizers==0.15.0`: Matches transformers version
- `safetensors==0.4.1`: Stable, secure model loading

**Note:** Newer iopaint versions (1.3.5+) require `huggingface_hub>=0.20.0` and have fixed the `cached_download` deprecation issue.

### Computer Vision

```
opencv-python-headless==4.8.1.78
Pillow==10.1.0
scikit-image==0.22.0
```

**Why these versions:**
- `opencv-python-headless==4.8.1.78`: Latest stable, no GUI dependencies
- `Pillow==10.1.0`: Python 3.11 compatible, security fixes
- `scikit-image==0.22.0`: Required by iopaint, stable version

### Inpainting

```
iopaint==1.3.3
diffusers==0.24.0
accelerate==0.25.0
```

**Why these versions:**
- `iopaint==1.3.3`: Latest stable 1.3.x with LaMa support, compatible with huggingface_hub 0.20.3
- `diffusers==0.24.0`: Required by iopaint
- `accelerate==0.25.0`: GPU optimization, required by iopaint

**Version history:**
- iopaint 1.0.x-1.2.x: Required huggingface_hub<0.20.0 (deprecated cached_download)
- iopaint 1.3.x (1.3.0-1.3.3): Transitioned to work with huggingface_hub>=0.20.0
- iopaint 1.4.x+: Requires huggingface_hub>=0.20.0, may have breaking changes
- **1.3.3 is the most stable** version that works with modern dependencies

### CLI and Utilities

```
click==8.1.7
tqdm==4.66.1
loguru==0.7.2
PyYAML==6.0.1
omegaconf==2.3.0
yacs==0.1.8
```

**Why these versions:**
- Latest stable versions as of 2024
- Python 3.11 compatible
- No known breaking changes

### GUI (Optional)

```
PyQt6==6.6.1
PyQt6-Qt6==6.6.1
PyQt6-sip==13.6.0
```

**Why these versions:**
- Latest stable PyQt6
- Python 3.11 compatible
- Consistent Qt version across components

### Jupyter (Optional)

```
ipywidgets==8.1.1
ipykernel==6.27.1
jupyter==1.0.0
notebook==7.0.6
```

**Why these versions:**
- Latest stable Jupyter ecosystem
- File upload widget support (ipywidgets 8.x)
- Python 3.11 compatible

## System Monitoring

```
psutil==5.9.6
```

**Why this version:**
- Latest stable
- Cross-platform (Linux, macOS, Windows)
- Used in GUI for RAM/CPU monitoring

## CUDA Compatibility Matrix

| CUDA Version | PyTorch Build | Status | Notes |
|--------------|---------------|--------|-------|
| 12.1 | +cu121 | ✅ Recommended | Most tested |
| 12.2 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.3 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.4 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.5 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.6 | +cu121 | ✅ Compatible | Use cu121 builds |
| 11.8 | +cu118 | ⚠️ Not recommended | Use CUDA 12 instead |

## Python Compatibility

| Python Version | Status | Notes |
|----------------|--------|-------|
| 3.11 | ✅ Recommended | Fully tested |
| 3.12 | ✅ Supported | Works but less tested |
| 3.10 | ⚠️ Might work | Not officially tested |
| 3.13+ | ❌ Not supported | PyTorch not ready |

## Known Issues and Workarounds

### Issue 1: Dependency conflict between iopaint and huggingface_hub

**Problem:** `ERROR: Cannot install huggingface_hub<0.20.0 and iopaint==1.4.4+`

**Root cause:** Newer iopaint versions (1.4.4+) require huggingface_hub>=0.20.0, creating a conflict

**Solution:** Use compatible versions:
- `huggingface_hub==0.20.3` (works with newer iopaint)
- `iopaint==1.3.3` (latest stable 1.3.x, works with huggingface_hub 0.20.3)

**History:**
- Old approach (pre-fix): huggingface_hub==0.19.4 + iopaint==1.2.2
  - Problem: iopaint 1.2.2 used deprecated `cached_download()`
- Current approach: huggingface_hub==0.20.3 + iopaint==1.3.3
  - Fixed: iopaint 1.3.3 no longer uses deprecated API
  - Note: 1.3.3 is the latest in stable 1.3.x series (no 1.3.4 or 1.3.5 exists)

### Issue 2: PyTorch CUDA version mismatch

**Problem:** "CUDA driver version is insufficient"

**Solution:** Update NVIDIA drivers to 525+ or use CPU-only requirements

### Issue 3: iopaint model download fails

**Problem:** Connection timeout or SSL errors

**Solution:**
```bash
# Manual download
iopaint download --model lama

# Or set environment variable
export HF_ENDPOINT=https://hf-mirror.com
```

## Upgrading Dependencies

### Safe to upgrade:
- `click`, `tqdm`, `loguru` (CLI utilities)
- `PyYAML`, `psutil` (system utilities)
- `Pillow` (within 10.x series)
- `opencv-python-headless` (within 4.x series)

### Upgrade with caution:
- `transformers` (test with Florence-2)
- `torch`/`torchvision` (CUDA compatibility)
- `iopaint` (may change API)

### Upgrade together:
- `huggingface_hub` and `iopaint` should be upgraded together (they have tight dependency coupling)

## Testing New Versions

Before upgrading any dependency:

```bash
# Create test environment
conda create -n test-upgrade python=3.11
conda activate test-upgrade

# Install new version
pip install package==new.version

# Test basic functionality
python -c "import package; print(package.__version__)"

# Run full test
python remwm.py test_input.png test_output.png
```

## Installation Order

For best results, install in this order:

1. **PyTorch** (with CUDA)
   ```bash
   pip install --extra-index-url https://download.pytorch.org/whl/cu121 torch torchvision torchaudio
   ```

2. **HuggingFace** (pinned versions)
   ```bash
   pip install huggingface_hub==0.19.4 transformers==4.36.2
   ```

3. **Computer Vision**
   ```bash
   pip install opencv-python-headless Pillow scikit-image
   ```

4. **Inpainting and AI**
   ```bash
   pip install iopaint diffusers accelerate
   ```

5. **Utilities**
   ```bash
   pip install click tqdm loguru PyYAML omegaconf yacs psutil
   ```

6. **Optional: GUI/Jupyter**
   ```bash
   pip install PyQt6 ipywidgets
   ```

## Verification

After installation, verify all packages:

```bash
python -c "
import torch
import transformers
import iopaint
import cv2
import PIL

print(f'PyTorch: {torch.__version__}')
print(f'CUDA available: {torch.cuda.is_available()}')
print(f'CUDA version: {torch.version.cuda}')
print(f'Transformers: {transformers.__version__}')
print(f'OpenCV: {cv2.__version__}')
print(f'Pillow: {PIL.__version__}')
"
```

Expected output:
```
PyTorch: 2.1.2+cu121
CUDA available: True
CUDA version: 12.1
Transformers: 4.36.2
OpenCV: 4.8.1
Pillow: 10.1.0
```

## Alternative: Use requirements.txt

Instead of manual installation:

```bash
# CUDA 12.1
pip install -r requirements-cu121.txt

# CPU only
pip install -r requirements-cpu.txt

# Minimal (CLI only)
pip install -r requirements.txt
```

## Docker

The Dockerfile uses the same pinned versions for reproducibility:

```dockerfile
RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2+cu121 \
    ...
```

## Support

If you encounter version conflicts:

1. Check this document for known issues
2. Try the exact versions listed in requirements files
3. File an issue with your Python/CUDA versions
4. Include output of: `pip list` and `nvidia-smi`

## Last Updated

- **Date:** 2025-11-18
- **Tested with:**
  - CUDA 12.1, 12.3, 12.6
  - Python 3.11.7
  - Ubuntu 22.04, Windows 11
  - NVIDIA drivers 535.x, 545.x

## References

- [PyTorch CUDA compatibility](https://pytorch.org/get-started/locally/)
- [HuggingFace Hub versions](https://github.com/huggingface/huggingface_hub/releases)
- [IOPaint releases](https://github.com/Sanster/IOPaint/releases)
