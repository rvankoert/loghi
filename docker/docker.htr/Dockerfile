<<<<<<< HEAD
#FROM nvidia/cuda:12.0.0-runtime-ubuntu22.04
#FROM nvidia/cuda:12.1.0-base-ubuntu22.04
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
=======
#use 18.04 as it is the same as the hulk
#FROM ubuntu:18.04
#FROM nvidia/cuda:11.3.1-cudnn8-runtime-ubuntu18.04
#FROM nvidia/cuda:11.5-runtime-ubuntu20.04
#FROM nvidia/cuda:11.4.2-runtime-ubuntu20.04
#FROM nvidia/cuda:11.6.2-runtime-ubuntu20.04
#FROM nvcr.io/nvidia/tensorflow:22.01-tf2-py3
#FROM ubuntu:22.04
#FROM nvidia/cuda:12.0.0-runtime-ubuntu22.04
#FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04
>>>>>>> upstream/main

#RUN useradd -u 1000 rutger
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#COPY loghi-htr /src
# COPY loghi-htr-models/ /src/loghi-htr-models/
#COPY loghi-htr-models/model-new10-ijsberg_republicrandom_prizepapers_globalise_val_cer_ijsberg_globalise_0.0329 /src/loghi-htr-models/model-new10-ijsberg_republicrandom_prizepapers_globalise_val_cer_ijsberg_globalise_0.0329/
#COPY loghi-htr-models/model-new10-ijsberg_republicrandom_prizepapers_globalise_val_cer_ijsberg_globalise_0.0329.charlist /src/loghi-htr-models/model-new10-ijsberg_republicrandom_prizepapers_globalise_val_cer_ijsberg_globalise_0.0329.charlist
WORKDIR /src/src
<<<<<<< HEAD
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
=======
#apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub \
# tensorrt
RUN apt-get update && apt-get install -y software-properties-common wget git python3-pip python3 python3-dev
RUN apt-get install -y libtcmalloc-minimal4 ffmpeg libsm6 libxext6 libcudnn8 
RUN apt-get install -y cuda-nvcc-12-0 g++ nvidia-cudnn
RUN ln -s /usr/lib/x86_64-linux-gnu/libnvinfer.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer.so.7 \
  && ln -s /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.7
RUN python3 -m pip --no-cache-dir install --upgrade pip
>>>>>>> upstream/main
RUN cd /src \
  && git clone https://github.com/rvankoert/loghi-htr.git \
  && git clone https://github.com/rvankoert/CTCWordBeamSearch.git \
  && cd /src/CTCWordBeamSearch \
  && pip install . \
  && apt autoremove -y \
  && cd /src/loghi-htr/src \
  && git --git-dir=../.git log --format="%H" -n 1 > version_info \
  && python3 -m pip --no-cache-dir install -r requirements.txt \
  && apt autoremove -y \
  && rm -rf /src/CTCWordBeamSearch /root
RUN rm -rf /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 /usr/lib/x86_64-linux-gnu/libcuda.so.1
<<<<<<< HEAD

=======
WORKDIR /src/loghi-htr/src
#USER rutger

#  && apt-get remove -y x11-common x11-utils nvidia-visual-profiler openjdk-8-jre default-jre-headless g++ gcc \
#  && ln -s /usr/local/cuda-11/targets/x86_64-linux/lib/libcusolver.so.11 /usr/lib/libcusolver.so.10 \
#  && apt remove -y git wget software-properties-common g++ \
>>>>>>> upstream/main
