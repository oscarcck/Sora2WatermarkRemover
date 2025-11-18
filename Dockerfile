# Sora2WatermarkRemover Docker Image
# Based on NVIDIA CUDA 12.2 with Python 3.10 (matching Google Colab environment)

FROM nvidia/cuda:12.2.0-base-ubuntu22.04

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    python3.10-dev \
    ffmpeg \
    wget \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Create jovyan user (standard Jupyter user)
RUN useradd -m -s /bin/bash -G users jovyan && \
    mkdir -p /home/jovyan/work && \
    chown -R jovyan:users /home/jovyan

# Switch to jovyan user for installations
USER jovyan
WORKDIR /home/jovyan/work

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Jupyter
RUN pip install --no-cache-dir \
    jupyter==1.0.0 \
    notebook==7.0.6 \
    jupyterlab==4.0.9

# Install Python dependencies with specific versions for CUDA 12.2 + Python 3.10
# Note: Using PyTorch cu121 builds (CUDA 12.1) which are compatible with CUDA 12.2 runtime
# PyTorch doesn't provide cu122 builds - cu121 works with CUDA 12.1-12.6
RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.1.2+cu121 \
    torchvision==0.16.2+cu121 \
    torchaudio==2.1.2+cu121 \
    huggingface_hub==0.23.0 \
    transformers==4.36.2 \
    opencv-python-headless==4.8.1.78 \
    Pillow==10.4.0 \
    iopaint==1.6.0 \
    click==8.1.7 \
    tqdm==4.66.1 \
    loguru==0.7.2 \
    ipywidgets==8.1.1 \
    diffusers==0.27.2 \
    accelerate==0.25.0 \
    omegaconf==2.3.0 \
    scikit-image==0.22.0 \
    yacs==0.1.8

# Copy project files
COPY --chown=jovyan:users . /home/jovyan/work/

# Pre-download LaMa model (optional, uncomment to pre-download)
# This increases image size but speeds up first run
# RUN iopaint download --model lama

# Create input/output directories
RUN mkdir -p /home/jovyan/work/input /home/jovyan/work/output

# Expose Jupyter port
EXPOSE 8888

# Start Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''", "--allow-root"]
