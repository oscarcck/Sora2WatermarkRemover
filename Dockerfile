# Sora2WatermarkRemover Docker Image
# Based on Jupyter PyTorch notebook with CUDA 12 and Python 3.11

FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.11

# Switch to root to install system dependencies
USER root

# Install FFmpeg (required for video audio merging)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to jovyan user for pip installations
USER jovyan

# Set working directory
WORKDIR /home/jovyan/work

# Copy requirements file if exists, otherwise install packages directly
COPY --chown=jovyan:users . /home/jovyan/work/

# Install Python dependencies with specific versions for CUDA 12 + Python 3.11
# Using PyTorch CUDA 12.1 builds (compatible with CUDA 12.1-12.6)
# Updated: Use compatible versions of huggingface_hub and iopaint
RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2+cu121 \
    torchvision==0.16.2+cu121 \
    torchaudio==2.1.2+cu121 \
    huggingface_hub==0.20.3 \
    transformers==4.36.2 \
    opencv-python-headless==4.8.1.78 \
    Pillow==10.1.0 \
    iopaint==1.3.3 \
    click==8.1.7 \
    tqdm==4.66.1 \
    loguru==0.7.2 \
    ipywidgets==8.1.1 \
    diffusers==0.24.0 \
    accelerate==0.25.0 \
    omegaconf==2.3.0 \
    scikit-image==0.22.0 \
    yacs==0.1.8

# Pre-download LaMa model (optional, can be done at runtime)
# Uncomment the following line to pre-download the model (increases image size)
# RUN iopaint download --model lama

# Create input/output directories
RUN mkdir -p /home/jovyan/work/input /home/jovyan/work/output

# Expose Jupyter port
EXPOSE 8888

# Default command (start Jupyter)
CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.password=''"]
