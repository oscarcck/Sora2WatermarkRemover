# CLAUDE.md - AI Assistant Guide for Sora2WatermarkRemover

**Last Updated:** 2025-11-18
**Repository:** Sora2WatermarkRemover
**Purpose:** AI-powered watermark removal from Sora-generated videos and images

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Technology Stack](#technology-stack)
4. [Core Workflows](#core-workflows)
5. [Key Files Reference](#key-files-reference)
6. [Development Setup](#development-setup)
7. [Code Conventions](#code-conventions)
8. [Common Tasks](#common-tasks)
9. [Testing and Debugging](#testing-and-debugging)
10. [Important Notes](#important-notes)

---

## Project Overview

### What This Project Does

Sora2WatermarkRemover is a sophisticated AI-powered tool that removes watermarks from Sora-generated videos and images using:

- **Florence-2**: Microsoft's vision foundation model for watermark detection via open-vocabulary object detection
- **LaMa**: Large Mask Inpainting model for realistic watermark removal
- **PyTorch**: Deep learning framework with CUDA GPU acceleration support

### Key Features

- Batch processing of images and videos
- Two removal modes: inpainting (realistic) or transparency
- Frame-stepping for faster video processing
- FPS control and format conversion
- Both CLI and GUI interfaces
- Real-time progress monitoring
- Cross-platform (Linux, macOS, Windows)

### Target Users

- Content creators working with Sora-generated media
- Users wanting to remove "Sora" or other watermarks from AI-generated content
- Researchers experimenting with inpainting models

---

## Repository Structure

```
Sora2WatermarkRemover/
├── remwm.py                          # Main CLI application (15KB)
├── remwmgui.py                       # PyQt6 GUI interface (20KB)
├── utils.py                          # Florence-2 utility functions (4KB)
├── download_lama.py                  # LaMa model download script
│
├── environment.yml                   # Conda environment specification
├── ui.yml                            # GUI configuration persistence
│
├── setup.sh                          # Linux/macOS setup script
├── setup.ps1                         # Windows PowerShell setup
├── install_windows.ps1               # Windows installation
├── install_windows.bat               # Windows batch installer
├── create_shortcut.ps1               # Windows shortcut creator
│
├── Sora2WatermarkRemover_Colab.ipynb # Google Colab notebook
│
├── README.md                         # Main documentation
├── INSTALLATION_FR.md                # French installation guide
├── DEMARRAGE_RAPIDE.md              # French quick start
├── CODE_OF_CONDUCT.md               # Community guidelines
├── LICENSE                           # Project license
│
└── .github/
    └── ISSUE_TEMPLATE/
        └── bug_report.md             # GitHub issue template
```

### File Organization Principles

- **Entry Points**: `remwm.py` (CLI) and `remwmgui.py` (GUI) are the only user-facing executables
- **Utilities**: `utils.py` contains reusable Florence-2 helper functions
- **Configuration**: `environment.yml` for dependencies, `ui.yml` for GUI state
- **Setup Scripts**: Platform-specific installation automation
- **No Build System**: Direct Python execution (no setup.py/pyproject.toml)

---

## Technology Stack

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **Python** | 3.12 | Base language |
| **PyTorch** | Nightly (CUDA 12.6) | Deep learning framework with GPU support |
| **transformers** | Latest | Florence-2 model loading and inference |
| **iopaint** | Latest | LaMa inpainting model management |
| **opencv-python** | Latest | Video/image processing |
| **Pillow** | Latest | Image manipulation and I/O |
| **PyQt6** | Latest | GUI framework |
| **loguru** | Latest | Structured logging |
| **click** | Latest | CLI argument parsing |
| **tqdm** | Latest | Progress bars |
| **numpy** | Latest | Numerical operations |
| **psutil** | Latest | System resource monitoring (GUI) |
| **PyYAML** | Latest | Configuration file handling |

### External Tools

- **FFmpeg**: Required for video audio merging (optional but recommended)
- **CUDA Toolkit**: Optional but highly recommended for GPU acceleration

### Environment

- **Conda Environment Name**: `py312aiwatermark`
- **Python Version**: 3.12
- **CUDA Version**: 12.6 (if GPU available)

---

## Core Workflows

### Watermark Detection and Removal Pipeline

```
┌─────────────┐
│ Input Image │
│  or Frame   │
└──────┬──────┘
       │
       v
┌─────────────────────────────────┐
│  Florence-2 Object Detection    │
│  Prompt: "watermark Sora logo"  │
│  Returns: Bounding boxes        │
└──────┬──────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  Filter by max_bbox_percent     │
│  (Ignore boxes >10% of image)   │
└──────┬──────────────────────────┘
       │
       v
┌─────────────────────────────────┐
│  Generate Binary Mask           │
│  (White=watermark, Black=keep)  │
└──────┬──────────────────────────┘
       │
       v
    ┌──┴──┐
    │ IF  │
    └──┬──┘
       │
   ┌───┴────────────┐
   │                │
   v                v
┌─────────┐  ┌──────────────┐
│LaMa     │  │Make Region   │
│Inpaint  │  │Transparent   │
│(Default)│  │(--transparent)
└────┬────┘  └──────┬───────┘
     │              │
     └──────┬───────┘
            v
     ┌──────────────┐
     │ Output Image │
     └──────────────┘
```

### Video Processing Pipeline

```
┌─────────────┐
│ Input Video │
└──────┬──────┘
       │
       v
┌──────────────────────────────┐
│ Extract Frames (OpenCV)      │
│ Optional: Skip frames via    │
│ --frame-step parameter       │
└──────┬───────────────────────┘
       │
       v
┌──────────────────────────────┐
│ For Each Frame:              │
│ 1. Convert BGR → RGB (PIL)   │
│ 2. Detect watermark (above)  │
│ 3. Remove watermark          │
│ 4. Convert RGB → BGR (OpenCV)│
└──────┬───────────────────────┘
       │
       v
┌──────────────────────────────┐
│ Reconstruct Video            │
│ - Use VideoWriter            │
│ - Apply codec (MP4/AVI)      │
│ - Optional: Custom FPS       │
└──────┬───────────────────────┘
       │
       v
┌──────────────────────────────┐
│ Merge Audio (FFmpeg)         │
│ - Extract audio from original│
│ - Combine with processed vid │
│ - Fallback if FFmpeg missing │
└──────┬───────────────────────┘
       │
       v
┌──────────────┐
│ Output Video │
└──────────────┘
```

### Model Loading Sequence

```python
# 1. Device Detection
device = "cuda" if torch.cuda.is_available() else "cpu"

# 2. Load Florence-2 for Detection
model_id = "microsoft/Florence-2-large"
model = AutoModelForCausalLM.from_pretrained(
    model_id, trust_remote_code=True
).to(device)
processor = AutoProcessor.from_pretrained(
    model_id, trust_remote_code=True
)

# 3. Load LaMa for Inpainting
model_manager = ModelManager(
    name="lama",
    device=torch.device(device)
)
```

---

## Key Files Reference

### remwm.py (CLI Application)

**Location**: `/remwm.py`
**Lines**: ~430
**Entry Point**: `main()` function with Click decorators

#### Key Functions

| Function | Line | Purpose |
|----------|------|---------|
| `identify()` | 29-48 | Florence-2 inference wrapper for object detection |
| `get_watermark_mask()` | 50-69 | Detect watermark regions and generate binary mask |
| `process_image_with_lama()` | 71-85 | Apply LaMa inpainting to masked regions |
| `make_region_transparent()` | 87-97 | Alternative to inpainting: make regions transparent |
| `is_video_file()` | 99-101 | Check file extension for video formats |
| `process_video()` | ~150-300 | Full video processing pipeline |
| `handle_one()` | ~300-400 | Process single file (dispatches to image/video) |
| `main()` | ~400-430 | CLI entry point with argument parsing |

#### CLI Arguments

```python
@click.command()
@click.argument("input_path", type=click.Path(exists=True))
@click.argument("output_path", type=click.Path())
@click.option("--overwrite", is_flag=True, help="Overwrite existing output files")
@click.option("--transparent", is_flag=True, help="Make watermark regions transparent")
@click.option("--max-bbox-percent", type=float, default=10.0,
              help="Skip detections covering >N% of image area")
@click.option("--force-format", type=click.Choice(["PNG", "WEBP", "JPG", "MP4", "AVI"]))
@click.option("--frame-step", type=int, default=1, help="Process every Nth frame")
@click.option("--target-fps", type=float, default=0.0, help="Output FPS (0=preserve)")
```

#### Important Constants

```python
VIDEO_EXTENSIONS = {'.mp4', '.avi', '.mov', '.mkv', '.flv', '.wmv', '.webm'}
IMAGE_EXTENSIONS = {'.png', '.jpg', '.jpeg', '.webp'}
DEFAULT_MAX_BBOX_PERCENT = 10.0
```

---

### remwmgui.py (GUI Application)

**Location**: `/remwmgui.py`
**Lines**: ~550
**Entry Point**: `if __name__ == "__main__"` block

#### Key Classes

| Class | Purpose |
|-------|---------|
| `Worker(QThread)` | Background thread for running remwm.py subprocess |
| `WatermarkRemoverGUI(QMainWindow)` | Main GUI window with all widgets |

#### GUI Components

```python
# Main sections
- File Selection Panel (input/output paths)
- Mode Toggle (single file vs batch directory)
- Processing Options
  - Overwrite checkbox
  - Transparent mode checkbox
  - Max bbox percent slider (1-100%)
  - Output format dropdown
- Execution Controls (Start/Cancel buttons)
- Progress Monitoring
  - Progress bar
  - Log viewer (toggleable)
- Status Bar
  - CUDA availability
  - RAM usage and percentage
  - VRAM usage (if GPU available)
  - CPU load percentage
```

#### Configuration Persistence

```python
# Saved to ui.yml
config = {
    'input_path': str,
    'output_path': str,
    'mode': 'single' | 'batch',
    'overwrite': bool,
    'transparent': bool,
    'max_bbox_percent': float,
    'force_format': str | None
}
```

---

### utils.py (Utility Functions)

**Location**: `/utils.py`
**Lines**: ~120
**Purpose**: Florence-2 helper functions and visualization tools

#### Key Components

```python
# Color palette for visualization
colormap = [
    (255, 0, 0), (0, 255, 0), (0, 0, 255), ...
]  # 19 colors total

# Task types enum
class TaskType(str, Enum):
    CAPTION = "<CAPTION>"
    DETAILED_CAPTION = "<DETAILED_CAPTION>"
    MORE_DETAILED_CAPTION = "<MORE_DETAILED_CAPTION>"
    OPEN_VOCAB_DETECTION = "<OPEN_VOCABULARY_DETECTION>"
    # ... more task types

# Core utilities
run_example()              # Florence-2 inference wrapper
draw_polygons()           # Visualize segmentation masks
draw_ocr_bboxes()         # Visualize OCR bounding boxes
convert_bbox_to_relative() # Pixel → relative coordinates
convert_relative_to_bbox() # Relative → pixel coordinates
```

---

### environment.yml (Dependency Specification)

**Location**: `/environment.yml`
**Lines**: 21

```yaml
name: py312aiwatermark
channels:
  - nvidia      # For CUDA packages
  - conda-forge # Community packages
  - defaults    # Anaconda default channel
dependencies:
  - python=3.12
  - pip
  - numpy
  - tqdm
  - loguru
  - click
  - pillow
  - opencv
  - pip:
      - --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu126
      - iopaint
```

**Important Notes:**
- Uses nightly PyTorch builds for latest CUDA 12.6 support
- `iopaint` automatically installs LaMa model dependencies
- `transformers` is installed via pip during setup scripts

---

## Development Setup

### Prerequisites

- **Anaconda/Miniconda**: Required for environment management
- **CUDA Toolkit 12.6**: Optional but recommended for GPU acceleration
- **FFmpeg**: Optional but recommended for video audio merging
- **16GB+ RAM**: Recommended (models are large)
- **6GB+ VRAM**: Recommended for GPU acceleration

### Installation Steps

#### Linux/macOS

```bash
# Standard installation
./setup.sh

# Just activate existing environment
./setup.sh --activate

# Force environment recreation
./setup.sh --reinstall

# Install in current directory instead of default conda envs
./setup.sh --current-dir

# Run with arguments (e.g., process files immediately)
./setup.sh -- input.png output.png
```

#### Windows

```powershell
# PowerShell installation
.\install_windows.ps1

# Or use batch file
.\install_windows.bat

# Create desktop shortcut
.\create_shortcut.ps1
```

#### Google Colab

Open the Colab notebook: [Sora2WatermarkRemover_Colab.ipynb](https://colab.research.google.com/drive/1Iqu4RZ9WAhcbO1Jn0wCkMOsw2l1p6z62?usp=sharing)

### Manual Setup

```bash
# 1. Create conda environment
conda env create -f environment.yml

# 2. Activate environment
conda activate py312aiwatermark

# 3. Install additional dependencies
pip install transformers PyQt6

# 4. Download LaMa model
iopaint download --model lama

# 5. Test CLI
python remwm.py --help

# 6. Test GUI
python remwmgui.py
```

### Verifying Installation

```bash
# Check Python version
python --version  # Should be 3.12.x

# Check CUDA availability
python -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"

# Check installed packages
conda list | grep -E "torch|transformers|iopaint"

# Check FFmpeg
ffmpeg -version
```

---

## Code Conventions

### Coding Style

#### Import Organization

```python
# Standard library imports
import sys
import os
from pathlib import Path
from enum import Enum

# Third-party imports
import click
import cv2
import numpy as np
from PIL import Image, ImageDraw
from transformers import AutoProcessor, AutoModelForCausalLM
from iopaint.model_manager import ModelManager
import torch
from loguru import logger
import tqdm
```

#### Type Hints

```python
# Use type hints for function parameters
def identify(
    task_prompt: TaskType,
    image: MatLike,
    text_input: str,
    model: AutoModelForCausalLM,
    processor: AutoProcessor,
    device: str
) -> dict:
    pass

# MatLike type alias for OpenCV compatibility
try:
    from cv2.typing import MatLike
except ImportError:
    MatLike = np.ndarray
```

#### Logging Convention

```python
# Use loguru for all logging
from loguru import logger

# Info messages for normal operation
logger.info(f"Processing {file_path}")
logger.info(f"input_path:{input_path}, output_path:{output_path}")

# Warning for skipped operations
logger.warning(f"Skipping large bounding box: {bbox} covering {percent:.2%}")

# Error for failures
logger.error(f"Failed to process {file_path}: {error}")
```

#### Progress Tracking

```python
# Use tqdm for progress bars
from tqdm import tqdm

# File processing loop
for file in tqdm(files, desc="Processing files"):
    process_file(file)

# Frame processing loop
for i in tqdm(range(frame_count), desc="Processing frames"):
    process_frame(i)

# GUI integration: print progress for parsing
print(f"overall_progress:{current}/{total}")
```

### Naming Conventions

| Convention | Example | Usage |
|------------|---------|-------|
| **snake_case** | `get_watermark_mask()` | Functions, variables |
| **PascalCase** | `TaskType`, `ModelManager` | Classes, Enums |
| **UPPER_CASE** | `VIDEO_EXTENSIONS` | Constants |
| **_private** | `_internal_func()` | Private/internal (rare) |

### File Handling Patterns

```python
# Use pathlib for path manipulation
from pathlib import Path

input_path = Path(input_str)
output_path = Path(output_str)

# Check if path exists
if not input_path.exists():
    raise FileNotFoundError(f"Input path not found: {input_path}")

# Get file extension
extension = input_path.suffix.lower()

# Build output path
output_file = output_path / f"{input_path.stem}_processed{extension}"

# Check overwrite
if output_file.exists() and not overwrite:
    logger.warning(f"Output file exists, skipping: {output_file}")
    return
```

### Error Handling Patterns

```python
# Try-except for optional features
try:
    # Attempt FFmpeg audio merge
    subprocess.run(['ffmpeg', ...], check=True)
except (subprocess.CalledProcessError, FileNotFoundError):
    logger.warning("FFmpeg not available, skipping audio merge")
    # Fallback to video without audio

# Validate input parameters
if frame_step < 1:
    raise ValueError("frame_step must be at least 1")

if target_fps < 0:
    raise ValueError("target_fps must be non-negative")
```

### Device Management

```python
# Auto-detect GPU availability
device = "cuda" if torch.cuda.is_available() else "cpu"
logger.info(f"Using device: {device}")

# Load models to device
model = model.to(device)

# Move tensors to device
inputs = {k: v.to(device) for k, v in inputs.items()}
```

---

## Common Tasks

### Task 1: Add New Detection Target

**Goal**: Detect and remove a different type of watermark

**Steps**:

1. Modify the detection prompt in `remwm.py:51`:

```python
# Original
text_input = "watermark Sora logo"

# New (e.g., for TikTok watermark)
text_input = "watermark TikTok logo"
```

2. Test with sample images:

```bash
python remwm.py input.png output.png
```

3. Adjust `max_bbox_percent` if needed to capture larger/smaller watermarks

---

### Task 2: Add New Video Format Support

**Goal**: Support additional video formats (e.g., .webm, .ogv)

**Steps**:

1. Update `VIDEO_EXTENSIONS` constant in `remwm.py`:

```python
VIDEO_EXTENSIONS = {
    '.mp4', '.avi', '.mov', '.mkv', '.flv', '.wmv', '.webm',
    '.ogv'  # Add new format
}
```

2. Update codec mapping in `process_video()` function if needed:

```python
# Find the codec selection logic (around line 200-250)
if output_path.suffix.lower() == '.ogv':
    fourcc = cv2.VideoWriter_fourcc(*'THEO')  # Theora codec
```

3. Test with new format:

```bash
python remwm.py input.ogv output.ogv
```

---

### Task 3: Modify Inpainting Parameters

**Goal**: Improve inpainting quality by adjusting LaMa parameters

**Steps**:

1. Edit `process_image_with_lama()` in `remwm.py:71-85`:

```python
config = Config(
    ldm_steps=50,          # Increase for better quality (slower)
    ldm_sampler=LDMSampler.ddim,
    hd_strategy=HDStrategy.CROP,
    hd_strategy_crop_margin=64,        # Increase for more context
    hd_strategy_crop_trigger_size=800, # Lower for high-res images
    hd_strategy_resize_limit=1600,     # Increase for 4K images
)
```

2. Available samplers:

```python
LDMSampler.ddim    # Default, fast
LDMSampler.plms    # Slightly better quality
LDMSampler.pndm    # Alternative sampler
```

3. Test changes:

```bash
python remwm.py test_input.png test_output.png
```

---

### Task 4: Add Progress Callback for Custom Integration

**Goal**: Integrate remwm.py into another application with custom progress handling

**Steps**:

1. Add progress callback parameter to `handle_one()`:

```python
def handle_one(
    input_path: Path,
    output_path: Path,
    progress_callback: callable = None,  # Add this
    **kwargs
):
    # Inside processing loop
    if progress_callback:
        progress_callback(current_frame, total_frames)
```

2. Use in external application:

```python
def my_progress(current, total):
    print(f"Progress: {current}/{total}")

from remwm import handle_one
handle_one(
    input_path=Path("input.mp4"),
    output_path=Path("output.mp4"),
    progress_callback=my_progress
)
```

---

### Task 5: Optimize Memory Usage

**Goal**: Reduce memory consumption for large videos

**Steps**:

1. Implement frame batching in `process_video()`:

```python
# Instead of loading all frames at once
frames = []
for i in range(frame_count):
    ret, frame = cap.read()
    frames.append(frame)  # Memory intensive!

# Use generator pattern
def frame_generator(cap, frame_step=1):
    frame_idx = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        if frame_idx % frame_step == 0:
            yield frame
        frame_idx += 1

# Process frames one at a time
for frame in frame_generator(cap, frame_step):
    processed = process_frame(frame)
    out.write(processed)
```

2. Clear CUDA cache periodically:

```python
import torch

# After processing each frame in GPU mode
if device == "cuda":
    torch.cuda.empty_cache()
```

---

### Task 6: Add Command-Line Logging Options

**Goal**: Add verbosity control to CLI

**Steps**:

1. Add Click option:

```python
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose logging")
@click.option("--quiet", "-q", is_flag=True, help="Suppress all logs except errors")
def main(verbose, quiet, **kwargs):
    # Configure logger
    if quiet:
        logger.remove()
        logger.add(sys.stderr, level="ERROR")
    elif verbose:
        logger.remove()
        logger.add(sys.stderr, level="DEBUG")
```

2. Add debug logging throughout code:

```python
logger.debug(f"Detected {len(bboxes)} bounding boxes")
logger.debug(f"Frame {i} processing time: {elapsed:.2f}s")
```

---

## Testing and Debugging

### Running Tests

**Note**: This repository currently has no formal test suite.

**Recommended Testing Approach**:

```bash
# Create test directory
mkdir test_samples
cd test_samples

# Download sample Sora videos (with watermarks)
# Test with various formats and resolutions

# Test basic image processing
python ../remwm.py image_test.png output.png

# Test video processing
python ../remwm.py video_test.mp4 output.mp4

# Test batch processing
mkdir batch_input batch_output
python ../remwm.py batch_input/ batch_output/

# Test edge cases
python ../remwm.py image.png output.png --transparent
python ../remwm.py video.mp4 output.mp4 --frame-step 5
python ../remwm.py video.mp4 output.webm --force-format WEBP  # Should fail
```

### Debugging Techniques

#### Enable Debug Logging

```python
# Add at top of remwm.py
from loguru import logger
import sys

logger.remove()
logger.add(sys.stderr, level="DEBUG")
```

#### Visualize Detection Results

```python
# In get_watermark_mask(), save mask for inspection
mask.save("debug_mask.png")

# Overlay mask on original image
from PIL import ImageChops
overlay = ImageChops.multiply(image, mask.convert("RGB"))
overlay.save("debug_overlay.png")
```

#### Profile Performance

```python
import time

# Add timing to functions
def process_image_with_lama(image, mask, model_manager):
    start = time.time()
    result = model_manager(image, mask, config)
    elapsed = time.time() - start
    logger.debug(f"LaMa inpainting took {elapsed:.2f}s")
    return result
```

#### Check GPU Memory Usage

```python
import torch

if torch.cuda.is_available():
    logger.info(f"GPU: {torch.cuda.get_device_name(0)}")
    logger.info(f"Memory Allocated: {torch.cuda.memory_allocated() / 1e9:.2f} GB")
    logger.info(f"Memory Cached: {torch.cuda.memory_reserved() / 1e9:.2f} GB")
```

### Common Issues and Solutions

#### Issue 1: CUDA Out of Memory

**Symptoms**: `RuntimeError: CUDA out of memory`

**Solutions**:

```python
# 1. Reduce batch size in Florence-2 inference
# 2. Clear cache between frames
torch.cuda.empty_cache()

# 3. Fallback to CPU
device = "cpu"  # Force CPU mode

# 4. Process smaller images
image = image.resize((image.width // 2, image.height // 2))
```

#### Issue 2: FFmpeg Not Found

**Symptoms**: `FileNotFoundError: [Errno 2] No such file or directory: 'ffmpeg'`

**Solutions**:

```bash
# Install FFmpeg
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html
# Add to PATH
```

#### Issue 3: LaMa Model Not Downloaded

**Symptoms**: Model loading errors, missing model files

**Solutions**:

```bash
# Manual download
conda activate py312aiwatermark
iopaint download --model lama

# Check model location
python -c "from iopaint.model_manager import ModelManager; print(ModelManager.model_dir)"
```

#### Issue 4: Poor Watermark Detection

**Symptoms**: Watermark not detected or too many false positives

**Solutions**:

```python
# 1. Adjust detection prompt
text_input = "watermark Sora logo text"  # More specific

# 2. Modify max_bbox_percent
max_bbox_percent = 5.0  # More restrictive (skip large detections)
max_bbox_percent = 20.0  # More permissive (allow larger detections)

# 3. Visualize detections
# Add debug code to save annotated images
draw = ImageDraw.Draw(image.copy())
for bbox in bboxes:
    draw.rectangle(bbox, outline="red", width=3)
image.save("debug_detections.png")
```

---

## Important Notes

### Performance Considerations

1. **GPU Acceleration**: ~10-20x faster than CPU
   - Requires CUDA-compatible NVIDIA GPU
   - Minimum 4GB VRAM recommended, 6GB+ ideal

2. **Video Processing Time**: Depends on:
   - Resolution: 1080p takes ~2-5 seconds per frame on GPU
   - Frame rate: Use `--frame-step` to skip frames for preview
   - Length: 10-second 30fps video = 300 frames

3. **Memory Requirements**:
   - Florence-2 model: ~2GB RAM/VRAM
   - LaMa model: ~1GB RAM/VRAM
   - Frame buffer: ~100MB per 1080p frame
   - **Total**: 16GB RAM + 6GB VRAM recommended

### Limitations

1. **Detection Quality**: Florence-2 may miss:
   - Very small watermarks (<20x20 pixels)
   - Watermarks matching background color
   - Highly transparent watermarks
   - Non-standard watermark placements

2. **Inpainting Quality**: LaMa may produce artifacts:
   - Complex textures (faces, text)
   - High-frequency details
   - Large watermarked regions (>30% of image)

3. **Video Limitations**:
   - Audio sync may drift for very long videos
   - Some codecs not supported (use `--force-format`)
   - Variable frame rate (VFR) videos may have timing issues

### Security and Ethics

**Important Ethical Considerations**:

⚠️ This tool is designed for removing watermarks from **personal content** you have generated yourself using Sora or similar AI tools.

**Do NOT use this tool to**:
- Remove watermarks from copyrighted content you don't own
- Violate terms of service of AI generation platforms
- Remove attribution from others' work
- Facilitate copyright infringement

**Legitimate Use Cases**:
- Cleaning up personal Sora-generated videos for portfolios
- Removing unwanted branding from your own content
- Educational and research purposes
- Fair use scenarios with proper attribution

### Model Information

#### Florence-2

- **Paper**: [Florence-2: Advancing a Unified Representation for a Variety of Vision Tasks](https://arxiv.org/abs/2311.06242)
- **Model ID**: `microsoft/Florence-2-large`
- **Task**: Open-vocabulary object detection
- **License**: MIT
- **Size**: ~2GB

#### LaMa

- **Paper**: [Resolution-robust Large Mask Inpainting with Fourier Convolutions](https://arxiv.org/abs/2109.07161)
- **Implementation**: via `iopaint` package
- **License**: Apache 2.0
- **Size**: ~1GB

### Contributing Guidelines

When contributing to this project:

1. **Code Style**: Follow existing conventions (see [Code Conventions](#code-conventions))
2. **Logging**: Use `loguru` for all output
3. **Error Handling**: Always provide fallbacks for optional features
4. **Documentation**: Update this CLAUDE.md for architectural changes
5. **Testing**: Test with various image/video formats before PR
6. **Commit Messages**: Use clear, descriptive messages

Example commit message:
```
Add support for WebM video format

- Update VIDEO_EXTENSIONS constant
- Add VP9 codec handling in process_video()
- Test with 1080p and 4K WebM files
```

### Recent Changes (Git History)

```
43f474c Update README.md
7c5242b Update README.md
b54b8a3 Update README.md
048d38c Merge pull request #1 from fulfulggg/feat/frame-step
8e61f3f Add debug info and file path validation to Colab notebook
63b8d45 Add Google Colab notebook for Sora2 watermark removal
ef20d79 Add --frame-step and --target-fps options
```

**Key Recent Features**:
- Frame-step temporal resolution control (PR #1)
- Google Colab integration
- Target FPS control
- Enhanced debugging in Colab notebook

### Troubleshooting Checklist

Before reporting issues, verify:

- [ ] Conda environment activated: `conda activate py312aiwatermark`
- [ ] All dependencies installed: `conda list | grep torch`
- [ ] CUDA available (if using GPU): `python -c "import torch; print(torch.cuda.is_available())"`
- [ ] LaMa model downloaded: `ls ~/.cache/iopaint/models/`
- [ ] FFmpeg installed (for video audio): `ffmpeg -version`
- [ ] Input file exists and is readable
- [ ] Output directory exists and is writable
- [ ] Sufficient disk space (videos can be large)
- [ ] Sufficient RAM/VRAM (check with `nvidia-smi` for GPU)

---

## Quick Reference

### CLI Examples

```bash
# Basic image processing
python remwm.py input.png output.png

# Image with transparency mode
python remwm.py input.png output.png --transparent

# Video processing with frame skipping
python remwm.py input.mp4 output.mp4 --frame-step 2

# Batch processing directory
python remwm.py input_dir/ output_dir/ --overwrite

# Custom FPS and format
python remwm.py input.mp4 output.mp4 --target-fps 30 --force-format MP4

# Allow larger detections
python remwm.py input.png output.png --max-bbox-percent 20
```

### GUI Usage

```bash
# Launch GUI
python remwmgui.py

# GUI features:
# 1. Select input file or directory
# 2. Select output directory
# 3. Toggle single/batch mode
# 4. Adjust max bbox % slider
# 5. Choose output format
# 6. Click "Start Processing"
# 7. Monitor progress bar and logs
```

### Python API Usage

```python
from pathlib import Path
from remwm import handle_one

# Process single file
handle_one(
    input_path=Path("input.png"),
    output_path=Path("output.png"),
    overwrite=True,
    transparent=False,
    max_bbox_percent=10.0,
    force_format="PNG"
)
```

---

## Additional Resources

- **README.md**: User-facing documentation and installation guide
- **INSTALLATION_FR.md**: French installation instructions
- **DEMARRAGE_RAPIDE.md**: French quick start guide
- **CODE_OF_CONDUCT.md**: Community guidelines
- **Colab Notebook**: [Interactive demo](https://colab.research.google.com/drive/1Iqu4RZ9WAhcbO1Jn0wCkMOsw2l1p6z62?usp=sharing)
- **Related Projects**:
  - [SoraWatermarkCleaner](https://github.com/linkedlist771/SoraWatermarkCleaner)
  - [sweeta](https://github.com/Kuberwastaken/sweeta)

---

## Glossary

| Term | Definition |
|------|------------|
| **Florence-2** | Microsoft's vision foundation model for various CV tasks |
| **LaMa** | Large Mask Inpainting model for image restoration |
| **Open Vocabulary Detection** | Object detection without predefined classes |
| **Inpainting** | Filling in missing/masked regions of images |
| **Bounding Box** | Rectangle coordinates [x1, y1, x2, y2] |
| **Frame Step** | Skip factor for video processing (1=all frames, 2=every other) |
| **FourCC** | Four-character code for video codec identification |
| **CUDA** | NVIDIA's parallel computing platform for GPU acceleration |

---

**End of CLAUDE.md**

For questions or issues, please check the [GitHub repository](https://github.com/oscarcck/Sora2WatermarkRemover) or file an issue using the bug report template.
