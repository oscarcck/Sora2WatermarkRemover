# Sora2WatermarkRemover Docker Image
# Based on Jupyter PyTorch notebook with CUDA 12 and Python 3.10

FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.10

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

# Install Python dependencies with specific versions for CUDA 12.2 + Python 3.10
# Using PyTorch CUDA 12.2 builds (matches Google Colab environment)
# Updated: Use Colab-compatible versions
RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cu122 \
    torch==2.1.2+cu122 \
    torchvision==0.16.2+cu122 \
    torchaudio==2.1.2+cu122 \
    huggingface_hub==0.23.0 \
    transformers==4.36.2 \
    opencv-python-headless==4.8.1.78 \
    Pillow==10.4.0 \
    iopaint==1.6.0 \
    click==8.1.7 \
    tqdm==4.66.1 \
    loguru==0.7.2 \
    ipywidgets==8.1.1 \
    diffusers==0.27.0 \
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
