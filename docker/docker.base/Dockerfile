FROM ubuntu:26.04
ENV SUDO_FORCE_REMOVE=yes
ENV HOME=/root
ENV TZ=Europe/Amsterdam
ENV ANT_HOME=/usr/share/ant/


WORKDIR /src/
COPY buildAndInstallOpencv.sh .
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && apt-get update && apt-get --no-install-recommends install -y sudo libjna-jni git make libtool m4 automake g++ gawk autoconf-archive libleptonica-dev \
  leptonica-progs pkg-config git libjpeg8-dev libavcodec-dev libavformat-dev \
  libswscale-dev libv4l-dev qtbase5-dev libgtk2.0-dev libtbb-dev libfaac-dev libmp3lame-dev libtheora-dev \
  libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils \
  libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev \
  libhdf5-dev doxygen cmake openjdk-17-jdk ant maven \
  libjpeg-dev libpng-dev libtiff-dev libdc1394-dev libopenblas-dev \
  libstdc++6 libgcc-s1 \
  && apt-get dist-upgrade -y \
  && apt-get clean \
  && ./buildAndInstallOpencv.sh \
  && sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf' \
  && ldconfig \
  && rm -rf /src \
  && rm -rf /usr/local/share/opencv4/samples \
  && rm -rf /var/lib/apt \
  && apt-get remove -y --purge sudo libjna-jni make libtool m4 automake g++ gawk autoconf-archive libleptonica-dev \
  leptonica-progs pkg-config git libjpeg8-dev libavcodec-dev libavformat-dev \
  libswscale-dev libv4l-dev qtbase5-dev libgtk2.0-dev libtbb-dev libfaac-dev libmp3lame-dev libtheora-dev \
  libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils \
  libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev \
  libhdf5-dev doxygen cmake ant maven \
  openjdk-17-jdk openjdk-17-jdk-headless openjdk-17-jre openjdk-17-jre-headless \
  g++-15 gcc-15 cpp-15 libstdc++-15-dev libgcc-15-dev \
  libjpeg-dev libpng-dev libtiff-dev libdc1394-dev libopenblas-dev \
  && apt-get autoremove -y \
  && apt-get clean \
  && MISSING=$(ldd /usr/local/lib/libopencv_core.so.414 | grep "not found" | grep -v "libtbb.so" || true) \
  && if [ -n "$MISSING" ]; then echo "FATAL: missing OpenCV runtime libs in base: $MISSING"; exit 1; fi


#git clone https://github.com/opencv/opencv_contrib.git \
#  && cd /src/opencv_contrib \
#  && git checkout 4.5.3 \
#  && cd /src \
#  && git clone https://github.com/opencv/opencv.git \
#  && cd /src/opencv \
#  && git checkout 4.5.3 \
#  && mkdir build \
#  && cd /src/opencv/build \
#  && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D OPENCV_IO_ENABLE_JASPER=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -D WITH_TBB=ON .. \
#  && make -j`grep -c ^processor /proc/cpuinfo` \
#  && make install \
#  && mkdir -p /usr/lib/jni/ && cp /usr/local/share/java/opencv4/libopencv_java453.so /usr/lib/jni/ \
