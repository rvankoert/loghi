#FROM nvidia/cuda:12.0.0-runtime-ubuntu22.04
#FROM nvidia/cuda:12.1.0-base-ubuntu22.04
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

RUN useradd -u 1000 rutger
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY loghi-htr /src
WORKDIR /src/src
RUN apt-get update 
RUN apt-get install -y software-properties-common
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y python3-pip python3 python3-dev
RUN apt-get install -y libtcmalloc-minimal4 
RUN apt-get install -y ffmpeg
RUN apt-get install -y libsm6
RUN apt-get install -y libxext6 
RUN apt-get install -y g++
#RUN apt-get install -y libcudnn8 
#RUN apt-get install -y nvidia-cudnn
RUN apt-get install -y libcudnn8
RUN apt-get install -y cuda-cudart-11-8
RUN apt-get install -y libcufft-11-8
RUN apt-get install -y libcusparse-11-8
RUN apt-get install -y --allow-change-held-packages libcublas-11-8 libcurand-11-8 libcusolver-11-8 cuda-toolkit-12-1

RUN apt-get remove -y python3-blinker
#RUN ln -s /usr/lib/x86_64-linux-gnu/libnvinfer.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer.so.7 \
#  && ln -s /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.7
RUN python3 -m pip --no-cache-dir install --upgrade pip \
  && python3 -m pip --no-cache-dir install -r requirements.txt
RUN cd /src \
  && git clone https://github.com/rvankoert/CTCWordBeamSearch.git \
  && cd /src/CTCWordBeamSearch \
  && pip install . \
  && apt autoremove -y \
  && cd /src/src \
  && python3 -m pip --no-cache-dir install -r requirements.txt \
  && apt autoremove -y \
  && rm -rf /src/CTCWordBeamSearch /root
RUN rm -rf /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 /usr/lib/x86_64-linux-gnu/libcuda.so.1

