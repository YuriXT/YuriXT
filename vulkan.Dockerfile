FROM nvidia/cuda:12.3.1-devel-ubuntu22.04
RUN --mount=type=cache,target=/var/cache/cuda/apt,sharing=locked \
    apt-get update --fix-missing  && apt-get upgrade -y && \
    apt-get install -y --fix-missing git build-essential cmake gcc g++ portaudio19-dev ffmpeg libportaudio2 libasound-dev python3 python3-pip wget ocl-icd-opencl-dev opencl-headers clinfo libclblast-dev libopenblas-dev ninja-build && \
    wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | apt-key add - && \
    wget -qO /etc/apt/sources.list.d/lunarg-vulkan-jammy.list https://packages.lunarg.com/vulkan/lunarg-vulkan-jammy.list && \
    apt update -y && apt-get install -y vulkan-sdk && \
    mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python
WORKDIR /app
ENV HOST 0.0.0.0
ENV CUDA_DOCKER_ARCH=all
ENV LLAMA_VULKAN=1
COPY cuda-requirements.txt .
RUN --mount=type=cache,target=/var/cache/cuda/pip,sharing=locked \
    python3 -m pip install --upgrade pip cmake scikit-build setuptools wheel --no-cache-dir && \
    CMAKE_ARGS="-DLLAMA_VULKAN=1" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir && \
    pip install --no-cache-dir -r cuda-requirements.txt
COPY . .
RUN python3 download.py
EXPOSE 8091
RUN chmod +x start.sh
ENTRYPOINT ["sh", "-c", "./start.sh"]
