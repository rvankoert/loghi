# WIP

# Stage 1: Build stage
FROM ubuntu:22.04 as builder

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /src/

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common wget git python3-pip python3 python3-dev g++

# Upgrade pip and clone necessary repositories
RUN python3 -m pip --no-cache-dir install --upgrade pip \
  && git clone https://github.com/rvankoert/CTCWordBeamSearch.git \
  && git clone https://github.com/rvankoert/loghi-htr.git

# Install CTCWordBeamSearch
WORKDIR /src/CTCWordBeamSearch
RUN pip install .

# Prepare loghi-htr
WORKDIR /src/loghi-htr
RUN git --git-dir=./.git log --format="%H" -n 1 > ./src/version_info \
  && python3 -m pip install --no-cache-dir --ignore-installed -r requirements.txt \
  && rm -rf .git tests README.md .github .gitignore requirements.txt environment.yml

# Stage 2: Final image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as final

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install Python and runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip python3 libtcmalloc-minimal4 ffmpeg libsm6 libxext6 cuda-nvcc-11-8 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy only the necessary files from the builder stage
COPY --from=builder /src/loghi-htr /src/loghi-htr
COPY --from=builder /usr/local /usr/local

WORKDIR /src/loghi-htr/src

