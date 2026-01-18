#!/bin/bash
# Build ROS2 Humble for ARM64 on x86_64 using Docker buildx

set -e

echo "Setting up Docker buildx for ARM64 builds..."

# Create a new builder instance if it doesn't exist
if ! docker buildx inspect ros2-builder &> /dev/null; then
    docker buildx create --name ros2-builder --use
else
    docker buildx use ros2-builder
fi

# Enable QEMU for ARM64 emulation
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

echo "Building ROS2 Humble for ARM64 (this will take 1-3 hours)..."
docker buildx build \
    --platform linux/arm64 \
    --load \
    -t ros2-humble-arm64:latest \
    -f Dockerfile.ros2-arm64 \
    .

echo "Extracting built ROS2 to ros2_humble_arm64.tar.gz..."
docker run --rm --platform linux/arm64 ros2-humble-arm64:latest \
    cat /ros2_humble_arm64.tar.gz > ros2_humble_arm64.tar.gz

echo "Done! Transfer ros2_humble_arm64.tar.gz to your Pi and extract:"
echo "  scp ros2_humble_arm64.tar.gz pi@<pi-ip>:~/"
echo "  ssh pi@<pi-ip>"
echo "  cd ~/ && tar -xzf ros2_humble_arm64.tar.gz"
echo "  source ~/ros2_humble/install/setup.bash"
