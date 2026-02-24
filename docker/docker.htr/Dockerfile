##############################################################################
# Stage 1 – builder
# Compiles TensorFlow from source and builds CTCWordBeamSearch.
# All toolchain debris (Bazel, LLVM, JDK, build-essential, git repos, …)
# stays in this stage and is never shipped in the final image.
##############################################################################
FROM nvcr.io/nvidia/tensorflow:25.02-tf2-py3 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /src/

COPY .tf_configure.bazelrc /tmp/.tf_configure.bazelrc

RUN --mount=target=/var/lib/apt/lists,type=cache,id=apt-lists-builder,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,id=apt-cache-builder,sharing=locked \
    apt-get update && apt-get install -y \
      software-properties-common wget git python3-pip python3 python3-dev \
      pkg-config libhdf5-dev ffmpeg libsm6 libxext6 libcudnn9-cuda-12 \
      llvm-15 apt-transport-https curl gnupg \
      build-essential zip unzip openjdk-21-jdk coreutils bash lld && \
    apt-get dist-upgrade -y && \
    # ── LLVM-20 (clang for CUDA build) ──────────────────────────────────────
    wget -O llvm.sh https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && ./llvm.sh 20 all && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100 && \
    rm llvm.sh && \
    # ── Bazel 7.4.1 (built from source, no external apt repo needed) ────────
    mkdir -p /src/bazel-dist && \
    cd /src/bazel-dist && \
    wget -q https://github.com/bazelbuild/bazel/releases/download/7.4.1/bazel-7.4.1-dist.zip && \
    unzip -q ./bazel-7.4.1-dist.zip && \
    EXTRA_BAZEL_ARGS="--tool_java_runtime_version=local_jdk" bash ./compile.sh && \
    mv output/bazel /usr/local/bin/ && \
    cd /src && rm -rf /src/bazel-dist && \
    # ── TensorFlow 2.20 wheel ────────────────────────────────────────────────
    git clone --depth=1 --branch v2.20.0 https://github.com/tensorflow/tensorflow.git && \
    mv /tmp/.tf_configure.bazelrc /src/tensorflow/.tf_configure.bazelrc && \
    cd /src/tensorflow && \
    bazel clean --expunge && \
    bazel build //tensorflow/tools/pip_package:wheel \
      --repo_env=USE_PYWRAP_RULES=1 \
      --repo_env=WHEEL_NAME=tensorflow \
      --config=cuda --config=cuda_wheel --config=opt \
      --action_env=BAZEL_CACHE_BUST=evex512 && \
    # ── CTCWordBeamSearch wheel ──────────────────────────────────────────────
    cd /src && \
    git clone --depth=1 https://github.com/rvankoert/CTCWordBeamSearch.git && \
    cd /src/CTCWordBeamSearch && \
    pip wheel --no-deps -w /wheels . && \
    # ── loghi-htr source ─────────────────────────────────────────────────────
    cd /src && \
    git clone https://github.com/knaw-huc/loghi-htr.git && \
    git --git-dir=/src/loghi-htr/.git log --format="%H" -n 1 \
      > /src/loghi-htr/src/version_info && \
    # ── Copy the TF wheel to a known location ────────────────────────────────
    cp /src/tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow-*.whl /wheels/


##############################################################################
# Stage 2 – runtime
# Starts from the same NGC base (has all CUDA/cuDNN libs already wired up).
# Only the two custom wheels + loghi-htr source + runtime pip deps are added.
# Final image should be ~8-12 GB instead of ~27 GB.
##############################################################################
FROM nvcr.io/nvidia/tensorflow:25.02-tf2-py3 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Runtime-only system packages (no build tools, no JDK, no LLVM, no Bazel)
RUN --mount=target=/var/lib/apt/lists,type=cache,id=apt-lists-runtime,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,id=apt-cache-runtime,sharing=locked \
    apt-get update && apt-get install -y \
      locales libhdf5-dev ffmpeg libsm6 libxext6 libcudnn9-cuda-12 \
      libtcmalloc-minimal4t64 && \
    locale-gen en_US.UTF-8 && \
    apt-get clean

# Copy custom-built wheels from builder
COPY --from=builder /wheels/*.whl /wheels/

# Copy loghi-htr application source (no .git directory)
COPY --from=builder /src/loghi-htr /src/loghi-htr

# Install Python dependencies in one layer, then wipe caches
RUN pip install --upgrade pip setuptools wheel && \
    # Pre-install numpy + h5py without build isolation (h5py needs it)
    pip install --no-cache-dir numpy==2.1.3 && \
    pip install --no-cache-dir --no-build-isolation h5py==3.11.0 && \
    # Uninstall the NGC-bundled TF before installing our custom wheel
    pip uninstall -y tf-keras tensorflow tensorflow-and-cuda keras \
      nvidia-tensorflow 2>/dev/null || true && \
    # Install loghi-htr runtime requirements (tensorflow + word-beam-search
    # are replaced by the custom wheels below, so exclude them here)
    pip install --no-cache-dir --ignore-installed \
      editdistance==0.8.1 \
      keras==3.9.2 \
      matplotlib==3.10.3 \
      opencv_python==4.11.0.86 \
      tf_keras_vis==0.8.7 \
      "elasticdeform @ git+https://github.com/gvtulder/elasticdeform" \
      blinker==1.9.0 \
      fpdf==1.7.2 \
      scikit-image==0.25.2 \
      prometheus-client==0.21.1 \
      xlsxwriter==3.2.3 \
      six \
      Pillow==10.4.0 \
      "fastapi[standard]==0.115.12" \
      uvicorn==0.34.2 \
      typing-extensions==4.13.2 \
      psutil==7.0.0 \
      scipy==1.15.3 \
      vgslify==0.14.0 \
      python-bidi && \
    # Install custom-built wheels (CTCWordBeamSearch + TensorFlow)
    pip install --no-cache-dir --ignore-installed /wheels/*.whl && \
    # cuDNN runtime pin (must come after TF wheel to avoid downgrades)
    pip install --no-cache-dir --upgrade nvidia-cudnn-cu12==9.17.1.4 && \
    # Wipe pip cache and wheel staging area
    pip cache purge && \
    rm -rf /wheels /root/.cache /tmp/*

WORKDIR /src/loghi-htr/src
