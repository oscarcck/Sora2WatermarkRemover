# Dependency Version Guide

This document explains the dependency versions used in Sora2WatermarkRemover and why they were chosen.

## Version Selection Criteria

All versions are pinned for:
- **CUDA 12.2 compatibility** (matching Google Colab environment)
- **Python 3.10 compatibility** (matching Google Colab environment)
- **Stability** (avoiding breaking changes)
- **Security** (patched versions)
- **Colab parity** (same versions as Google Colab for consistency)

## Requirements Files

| File | Use Case | Installation |
|------|----------|-------------|
| `requirements.txt` | Standard CUDA 12+ | `pip install -r requirements.txt` |
| `requirements-cu121.txt` | Full CUDA 12+ with all extras (Colab-compatible) | `pip install -r requirements-cu121.txt` |
| `requirements-cpu.txt` | CPU-only (no GPU) | `pip install -r requirements-cpu.txt` |

**Note**: We use PyTorch `cu121` builds which are compatible with CUDA 12.1-12.6 runtime. PyTorch doesn't provide `cu122` builds specifically.

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
- **Compatible with CUDA 12.1, 12.2, 12.3, 12.4, 12.5, 12.6 runtime**
- Python 3.10 fully supported
- Good performance on modern GPUs (RTX 30/40 series)

**Important:** PyTorch doesn't provide `cu122` builds. The `cu121` builds work perfectly with CUDA 12.2+ runtime (used in Google Colab).

**Installation note:** Requires `--extra-index-url https://download.pytorch.org/whl/cu121`

### HuggingFace Libraries

```
huggingface_hub==0.23.0
transformers==4.36.2
tokenizers==0.15.0
safetensors==0.4.1
```

**Why these versions:**
- `huggingface_hub==0.23.0`: Has all required functions (split_torch_state_dict_into_shards, etc.)
- `transformers==4.36.2`: Stable, compatible with Florence-2
- `tokenizers==0.15.0`: Matches transformers version
- `safetensors==0.4.1`: Stable, secure model loading

**Note:** huggingface_hub 0.23.0 includes all modern APIs needed by diffusers and iopaint.

### Computer Vision

```
opencv-python-headless==4.8.1.78
Pillow==10.4.0
scikit-image==0.22.0
```

**Why these versions:**
- `opencv-python-headless==4.8.1.78`: Latest stable, no GUI dependencies
- `Pillow==10.4.0`: Python 3.10 compatible, matches Colab, has is_directory fix
- `scikit-image==0.22.0`: Required by iopaint, stable version

### Inpainting

```
iopaint==1.6.0
diffusers==0.27.2
accelerate==0.25.0
```

**Why these versions:**
- `iopaint==1.6.0`: Latest stable release (matching Google Colab usage)
- `diffusers==0.27.2`: Required by iopaint 1.6.0 (exact version dependency)
- `accelerate==0.25.0`: GPU optimization, required by iopaint

**Version history:**
- iopaint 1.0.x-1.2.x: Required huggingface_hub<0.20.0 (deprecated cached_download)
- iopaint 1.3.x (1.3.0-1.3.3): Works with huggingface_hub>=0.20.0
- iopaint 1.4.x-1.6.x: Latest versions with improved features
- iopaint 1.6.0 specifically requires diffusers==0.27.2 (not 0.27.0)
- **Current combination is fully compatible** with all required APIs and matches Colab environment

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

| CUDA Runtime | PyTorch Build | Status | Notes |
|--------------|---------------|--------|-------|
| 12.2 | +cu121 | ✅ Recommended | Google Colab uses this combination |
| 12.3 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.4 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.5 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.6 | +cu121 | ✅ Compatible | Use cu121 builds |
| 12.1 | +cu121 | ✅ Compatible | Exact match |
| 11.8 | +cu118 | ⚠️ Not recommended | Use CUDA 12 instead |

**Important Note:** PyTorch build version (e.g., `cu121`) doesn't need to exactly match your CUDA runtime version. PyTorch `cu121` builds work with all CUDA 12.x runtimes (12.1-12.6).

## Python Compatibility

| Python Version | Status | Notes |
|----------------|--------|-------|
| 3.10 | ✅ Recommended | Fully tested, matches Google Colab |
| 3.11 | ✅ Supported | Works but less tested |
| 3.12 | ✅ Supported | Works but less tested |
| 3.13+ | ❌ Not supported | PyTorch not ready |

## Known Issues and Workarounds

### Issue 1: Missing function errors from huggingface_hub

**Problem:** `ImportError: cannot import name 'split_torch_state_dict_into_shards'`

**Root cause:** Version mismatch - diffusers needs functions not available in older huggingface_hub

**Solution:** Use compatible versions:
- `huggingface_hub==0.23.0` (has all required functions)
- `diffusers==0.27.2` (required by iopaint 1.6.0)
- `iopaint==1.6.0` (latest stable, works with hub 0.23.0)

**Function availability:**
- `cached_download()`: Removed in hub 0.20.0 (old API)
- `split_torch_state_dict_into_shards()`: Added in hub 0.21.0+
- Solution: Use hub 0.23.0 which has all modern functions

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
   pip install huggingface_hub==0.23.0 transformers==4.36.2
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
CUDA version: 12.1  (or 12.2, 12.3, etc. depending on your runtime)
Transformers: 4.36.2
OpenCV: 4.8.1
Pillow: 10.4.0
```

## Alternative: Use requirements.txt

Instead of manual installation:

```bash
# CUDA 12+ (recommended, matches Colab setup)
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

**Note:** Docker uses NVIDIA CUDA 12.2 base image with PyTorch cu121 builds - this combination matches Google Colab's environment.

## Support

If you encounter version conflicts:

1. Check this document for known issues
2. Try the exact versions listed in requirements files
3. File an issue with your Python/CUDA versions
4. Include output of: `pip list` and `nvidia-smi`

## Last Updated

- **Date:** 2025-11-18
- **Tested with:**
  - CUDA 12.2 (matching Google Colab)
  - Python 3.10.x
  - Ubuntu 22.04, Windows 11, Google Colab
  - NVIDIA drivers 535.x, 545.x

## References

- [PyTorch CUDA compatibility](https://pytorch.org/get-started/locally/)
- [HuggingFace Hub versions](https://github.com/huggingface/huggingface_hub/releases)
- [IOPaint releases](https://github.com/Sanster/IOPaint/releases)
