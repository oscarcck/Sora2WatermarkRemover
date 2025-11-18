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

# Install Python dependencies
RUN pip install --no-cache-dir \
    transformers \
    opencv-python-headless \
    tqdm \
    loguru \
    iopaint \
    click \
    pillow

# Pre-download LaMa model (optional, can be done at runtime)
# Uncomment the following line to pre-download the model (increases image size)
# RUN iopaint download --model lama

# Create input/output directories
RUN mkdir -p /home/jovyan/work/input /home/jovyan/work/output

# Expose Jupyter port
EXPOSE 8888

# Default command (start Jupyter)
CMD ["start-notebook.sh", "--NotebookApp.token=''", "--NotebookApp.password=''"]
