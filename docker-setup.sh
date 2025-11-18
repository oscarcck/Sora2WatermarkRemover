#!/bin/bash
# Quick setup script for Docker environment

set -e

echo "========================================="
echo "Sora2WatermarkRemover Docker Setup"
echo "========================================="
echo ""

# Create input/output directories
echo "📁 Creating input/output directories..."
mkdir -p input output
echo "✅ Directories created: input/ and output/"
echo ""

# Check Docker installation
echo "🔍 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker found: $(docker --version)"
echo ""

# Check Docker Compose
echo "🔍 Checking Docker Compose..."
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed or outdated!"
    echo "Please install Docker Compose v2: https://docs.docker.com/compose/install/"
    exit 1
fi
echo "✅ Docker Compose found: $(docker compose version)"
echo ""

# Check for NVIDIA GPU
echo "🔍 Checking for NVIDIA GPU..."
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA GPU detected:"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    echo ""

    # Check NVIDIA Container Toolkit
    echo "🔍 Checking NVIDIA Container Toolkit..."
    if docker run --rm --gpus all nvidia/cuda:12.0.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA Container Toolkit is working!"
        GPU_SUPPORT=true
    else
        echo "⚠️  NVIDIA Container Toolkit not found or not working"
        echo "GPU acceleration will not be available in Docker"
        echo "Install from: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/"
        GPU_SUPPORT=false
    fi
else
    echo "ℹ️  No NVIDIA GPU detected (CPU-only mode)"
    GPU_SUPPORT=false
fi
echo ""

# Determine which compose file to use
if [ "$GPU_SUPPORT" = true ]; then
    COMPOSE_FILE="docker-compose.yml"
    echo "🚀 Ready to start with GPU support!"
else
    COMPOSE_FILE="docker-compose.cpu.yml"
    echo "🚀 Ready to start with CPU-only mode!"
fi
echo ""

# Ask user to start container
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "To start the Jupyter environment, run:"
echo ""
if [ "$GPU_SUPPORT" = true ]; then
    echo "  docker compose up"
else
    echo "  docker compose -f docker-compose.cpu.yml up"
fi
echo ""
echo "Then open your browser to: http://localhost:8888"
echo ""
echo "To run in background (detached mode):"
echo ""
if [ "$GPU_SUPPORT" = true ]; then
    echo "  docker compose up -d"
else
    echo "  docker compose -f docker-compose.cpu.yml up -d"
fi
echo ""
echo "📖 For detailed instructions, see: DOCKER_SETUP.md"
echo ""

# Offer to start immediately
read -p "Start container now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting container..."
    docker compose -f "$COMPOSE_FILE" up
fi
