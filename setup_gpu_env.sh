#!/bin/bash
set -e

echo "Starting GPU ML environment setup..."

# Check for Linux distribution and version
UBUNTU_VERSION=$(lsb_release -rs)
if [[ -z "$UBUNTU_VERSION" ]]; then
    echo "Could not detect Ubuntu version. Please enter it manually (e.g., 20.04, 22.04):"
    read -r UBUNTU_VERSION
fi
echo "Detected Ubuntu version: $UBUNTU_VERSION"

# Check for NVIDIA compatible driver
echo "Checking for NVIDIA compatible driver..."
sudo ubuntu-drivers devices

# Prompt for driver installation if necessary
read -p "Enter the NVIDIA driver version to install (e.g., nvidia-driver-535): " driver_version
sudo apt update
sudo apt install -y "$driver_version"

# Determine appropriate CUDA version based on Ubuntu version
if [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    CUDA_VERSION=12.2
elif [[ "$UBUNTU_VERSION" == "20.04" ]]; then
    CUDA_VERSION=11.8
else
    echo "Unsupported Ubuntu version for automatic CUDA setup. Please check compatibility and update the script manually."
    exit 1
fi
echo "Using CUDA version: $CUDA_VERSION"

# Install CUDA
echo "Installing CUDA $CUDA_VERSION..."
wget "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${UBUNTU_VERSION//./}/x86_64/cuda-repo-ubuntu${UBUNTU_VERSION//./}_${CUDA_VERSION}-1_amd64.deb"
sudo dpkg -i "cuda-repo-ubuntu${UBUNTU_VERSION//./}_${CUDA_VERSION}-1_amd64.deb"
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${UBUNTU_VERSION//./}/x86_64/7fa2af80.pub
sudo apt update
sudo apt install -y cuda

# Determine cuDNN version based on CUDA version
if [[ "$CUDA_VERSION" == "12.2" ]]; then
    CUDNN_VERSION=8.9.7
elif [[ "$CUDA_VERSION" == "11.8" ]]; then
    CUDNN_VERSION=8.4.1
else
    echo "Unsupported CUDA version for cuDNN setup. Please check compatibility and update the script manually."
    exit 1
fi
echo "Using cuDNN version: $CUDNN_VERSION"

# Install cuDNN
echo "Installing cuDNN $CUDNN_VERSION..."
wget "https://developer.download.nvidia.com/compute/cudnn/repos/ubuntu${UBUNTU_VERSION//./}/x86_64/cudnn-local-repo-ubuntu${UBUNTU_VERSION//./}-$CUDNN_VERSION.deb"
sudo dpkg -i "cudnn-local-repo-ubuntu${UBUNTU_VERSION//./}-$CUDNN_VERSION.deb"
sudo cp /var/cudnn-local-repo-ubuntu${UBUNTU_VERSION//./}-$CUDNN_VERSION/cudnn-local-*.gpg /usr/share/keyrings/
sudo apt update
sudo apt install -y libcudnn8 libcudnn8-dev

# Set up environment variables
echo "Configuring CUDA and cuDNN paths..."
echo "export PATH=/usr/local/cuda-$CUDA_VERSION/bin:\$PATH" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc

# Check for Conda installation
if ! command -v conda &> /dev/null; then
    echo "Conda is not installed. Please install Conda and rerun this script."
    exit 1
fi

# Set up Conda environment for TensorFlow and PyTorch
echo "Setting up Conda environment for TensorFlow and PyTorch..."
conda env create -f config/environment.yml

echo "Installation complete! Please restart your terminal."
