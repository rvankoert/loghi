#FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

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

RUN apt-get update && apt-get install -y software-properties-common wget git python3-pip python3 python3-dev
RUN apt-get install -y libtcmalloc-minimal4 ffmpeg libsm6 libxext6 libcudnn8 
RUN apt-get install -y cuda-nvcc-12-0 g++ nvidia-cudnn
RUN ln -s /usr/lib/x86_64-linux-gnu/libnvinfer.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer.so.7 \
  && ln -s /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.8 /usr/lib/x86_64-linux-gnu/libnvinfer_plugin.so.7
RUN python3 -m pip --no-cache-dir install --upgrade pip
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

WORKDIR /src/loghi-htr/src
