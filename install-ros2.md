# ROS2 Humble Installation on Debian Trixie ARM64

## Steps Successfully Used

## Note: Some of these steps can take a while so tmux is recommended

### 1. Install System Dependencies
```bash
sudo apt update
sudo apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  python3-setuptools \
  wget \
  build-essential \
  cmake \
  git \
  libbullet-dev \
  python3-flake8 \
  python3-pytest-repeat \
  python3-pytest-rerunfailures \
  libasio-dev \
  libtinyxml2-dev \
  libcunit1-dev
```

### 2. Create Python Virtual Environment and Install Build Tools
```bash
python3 -m venv ~/ros2_venv
source ~/ros2_venv/bin/activate

# CRITICAL: Pin versions for Python 3.13 compatibility
pip3 install "setuptools<75.0.0" "pytest<9.0.0" 
pip3 install empy==3.3.4
pip3 install lark-parser
pip3 install rosdep vcstool colcon-common-extensions

# Verify critical versions
python3 -c "import setuptools, pytest, em; print(f'setuptools: {setuptools.__version__}, pytest: {pytest.__version__}, empy: {em.__version__}')"
```

### 3. Initialize rosdep
```bash
sudo ~/ros2_venv/bin/rosdep init
rosdep update
```

### 4. Create ROS2 Workspace and Download Source
```bash
mkdir -p ~/ros2_humble/src
cd ~/ros2_humble
# Note: Only ros2.repos is available for Humble
# For headless, we'll use ros2.repos and skip GUI packages during build
wget https://raw.githubusercontent.com/ros2/ros2/humble/ros2.repos
vcs import src < ros2.repos
```

### 5. Increase Swap for Build (if you have limited RAM)
```bash
# Create a 4GB swap file for the build
sudo fallocate -l 4G /swapfile2
sudo chmod 600 /swapfile2
sudo mkswap /swapfile2
sudo swapon /swapfile2

# Verify swap is active
free -h

# Make permanent (optional)
echo '/swapfile2 none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 6. Install ROS2 Dependencies
```bash
source ~/ros2_venv/bin/activate
cd ~/ros2_humble
# Note: Set ROS_DISTRO and use -r (continue on error) for Debian Trixie compatibility
export ROS_DISTRO=humble
rosdep install --from-paths src --ignore-src -r -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers ignition-math6 ignition-cmake2"
```

### 7. Build ROS2
```bash
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
```

### 8. Reduce Swap After Build (optional)
```bash
# Remove the temporary swap file
sudo swapoff /swapfile2
sudo rm /swapfile2

# Remove from fstab if you added it
sudo sed -i '/\/swapfile2/d' /etc/fstab

# Verify swap is reduced
free -h
```

### 9. Setup Environment (add to ~/.bashrc)
```bash
source ~/ros2_humble/install/setup.bash
```

## Notes
- Build time: 30-90 minutes on ARM64
- ROS2 Humble LTS supported until May 2027
- Hardware (cameras, I2C) accessible normally - venv doesn't affect hardware access (allegedly...)

## Python 3.13 Compatibility Issues & Fixes

**ROS2 Humble was designed for Python 3.10/3.11.** Python 3.13 has breaking changes:

1. **setuptools 75+** - Breaking changes affect ROS2 build
   - **Fix:** Use setuptools < 75.0.0

2. **pytest 9.x** - Plugin compatibility issues with pytest-repeat/pytest-rerunfailures  
   - **Fix:** Use pytest < 9.0.0

3. **empy 4.x** - ROS2 requires empy 3.3.4 (BUFFERED_OPT attribute)
   - **Fix:** Use empy==3.3.4

4. **distutils removed** in Python 3.12+ - Some packages may fail
   - **Fix:** Ensure catkin_pkg 1.0.0+, modern setuptools

5. **If build fails mid-way:** Clean and rebuild from scratch
   ```bash
   cd ~/ros2_humble
   rm -rf build install log
   colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release
   ```
