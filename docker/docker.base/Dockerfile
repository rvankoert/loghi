FROM ubuntu:20.04
ENV SUDO_FORCE_REMOVE=yes
ENV HOME=/root
ENV TZ=Europe/Amsterdam
ENV ANT_HOME=/usr/share/ant/


WORKDIR /src/
COPY buildAndInstallOpencv.sh .
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && apt-get update && apt-get --no-install-recommends install -y sudo libjna-jni git make libtool m4 automake g++ gawk autoconf-archive libleptonica-dev \
  leptonica-progs pkg-config git libjpeg8-dev libavcodec-dev libavformat-dev \
  libswscale-dev libv4l-dev qt5-default libgtk2.0-dev libtbb-dev libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev \
  libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils \
  libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev \
  libhdf5-dev doxygen cmake default-jdk ant libtbb2 libtbb-dev maven \
  libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev libopenblas-base libopenblas-dev \
  && apt-get dist-upgrade -y \
  && apt-get clean \
  && ./buildAndInstallOpencv.sh \
  && sh -c 'echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf' \
  && ldconfig \
  && rm -rf /src \
  && rm -rf /usr/local/share/opencv4/samples \
  && rm -rf rm -rf /var/lib/apt \
  && apt-get remove -y libjna-jni make libtool m4 automake g++ gawk autoconf-archive libleptonica-dev \
  leptonica-progs pkg-config git libjpeg8-dev libavcodec-dev libavformat-dev \
  libswscale-dev libv4l-dev qt5-default libgtk2.0-dev libtbb-dev libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev \
  libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils \
  libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libeigen3-dev \
  libhdf5-dev doxygen cmake default-jdk ant libtbb2 libtbb-dev \
  libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev libopenblas-base libopenblas-dev \
  gcc-9 cpp-9 default-jre-headless default-jre openjdk-11-jre-headless openjdk-11-jre sudo maven \
  && apt autoremove -y


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
