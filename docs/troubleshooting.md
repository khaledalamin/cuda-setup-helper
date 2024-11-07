# Troubleshooting CUDA Setup

This guide provides solutions for common issues encountered during CUDA setup.

## Common Issues and Fixes

### 1. CUDA Toolkit Not Found
- **Solution**: Verify the `LD_LIBRARY_PATH` includes the path to `cuda/lib64`. Run:
  ```bash
  echo $LD_LIBRARY_PATH
  ```

### 2. Version Mismatch with TensorFlow/PyTorch
- **Solution**: Ensure that `cudatoolkit` and `cudnn` versions match the framework requirements. Adjust versions in `config/environment.yml` if needed.

### 3. Permission Denied
- **Solution**: Run `setup_gpu_env.sh` with `sudo` to ensure permissions for driver installation.

## Testing Installation

After setup, test CUDA with:
```python
import tensorflow as tf
print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))
```
