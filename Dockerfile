# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages, including gawk and bison
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    gcc \
    g++ \
    gdb \
    make \
    ninja-build \
    python3-pip \
    cmake \
    libc6-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    wget \
    build-essential \
    gawk \
    bison \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory to the project folder
WORKDIR /cs149gpt-flashattention

# Install specific Python dependencies
RUN pip3 install numpy==1.23.5
RUN pip3 install torch==2.1.2
RUN pip3 install tiktoken

# Check if glibc version is less than 2.32 and install glibc-2.32 if necessary
RUN GLIBC_VERSION=$(ldd --version | head -n 1 | awk '{print $NF}') && \
    REQUIRED_VERSION=2.32 && \
    dpkg --compare-versions $GLIBC_VERSION ge $REQUIRED_VERSION || \
    (echo "Installing glibc 2.32..." && \
    cd /tmp && \
    wget http://ftp.gnu.org/gnu/libc/glibc-2.32.tar.gz && \
    tar -xvf glibc-2.32.tar.gz && \
    mkdir glibc-2.32/build && \
    cd glibc-2.32/build && \
    ../configure --prefix=/opt/glibc-2.32 && \
    make -j$(nproc) && \
    make install)

# Set environment variable to use the newly installed glibc, if applicable
ENV LD_LIBRARY_PATH=/opt/glibc-2.32/lib:$LD_LIBRARY_PATH

# Copy the project files into the container
COPY . /cs149gpt-flashattention

# Clean up after installation
RUN apt-get clean

# Set default command to run the main script with specified arguments
CMD ["python3", "gpt149.py", "part0", "--inference", "-m", "shakes128"]