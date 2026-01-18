# ROS2 Humble Build Files

This directory contains files for building ROS2 Humble for ARM64 architecture.

## Files

- **install-ros2.md** - Complete installation guide for building ROS2 Humble on Debian Trixie ARM64
- **Dockerfile.ros2-arm64** - Docker configuration for cross-building ROS2 on x86_64 for ARM64 target
- **build-ros2-x86-for-arm64.sh** - Build script for automated Docker-based cross-compilation

## Quick Start

### Building on x86_64 Server for ARM64 Target

```bash
./build-ros2-x86-for-arm64.sh
```

This will produce `ros2_humble_arm64.tar.gz` that can be transferred to your ARM64 device.

### Building Directly on ARM64 Device

Follow the instructions in `install-ros2.md` for native compilation on the target device.

## Transfer to Robot

```bash
scp ros2_humble_arm64.tar.gz <user>@<robot-ip>:~/
ssh <user>@<robot-ip>
mkdir -p ~/ros2_humble && cd ~/ros2_humble
tar -xzf ../ros2_humble_arm64.tar.gz
source install/setup.bash
```
