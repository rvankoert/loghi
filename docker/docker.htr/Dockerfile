#FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04
FROM nvidia/cuda:12.5.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR /src/

RUN apt-get update && apt-get install -y software-properties-common wget git python3-pip python3 python3-dev && apt-get dist-upgrade -y

RUN apt-get install -y libtcmalloc-minimal4 ffmpeg libsm6 libxext6 libcudnn8 
RUN apt-get install -y cuda-nvcc-11-8 g++ nvidia-cudnn
RUN ln -s /usr/lib/x86_64-linux-gnu/libnvinfer.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer.so.7 \
  && ln -s /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.7
RUN python3 -m pip --no-cache-dir install --upgrade pip
RUN cd /src \
  && git clone https://github.com/rvankoert/CTCWordBeamSearch.git \
  && git clone https://github.com/knaw-huc/loghi-htr.git \
  && cd /src/CTCWordBeamSearch \
  && pip install . \
  && apt autoremove -y \
  && cd /src/loghi-htr/src \
  && git --git-dir=/src/loghi-htr/.git log --format="%H" -n 1 > /src/loghi-htr/src/version_info \
  && cd /src/loghi-htr \
  && python3 -m pip install --no-cache-dir --ignore-installed -r requirements.txt \
  && apt autoremove -y \
  && rm -rf /src/CTCWordBeamSearch /root

RUN rm -rf \
    /usr/lib/x86_64-linux-gnu/libcuda.so* \
    /usr/lib/x86_64-linux-gnu/libnvcuvid.so* \
    /usr/lib/x86_64-linux-gnu/libnvidia-*.so* \
    /usr/lib/x86_64-linux-gnu/libcudadebugger.so* \
    /usr/lib/firmware \
    /usr/local/cuda/compat/lib

WORKDIR /src/loghi-htr/src
