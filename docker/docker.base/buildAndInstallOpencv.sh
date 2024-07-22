#!/bin/bash
export ANT_HOME=/usr/share/ant/
VERSION=4.9.0
NODOTSVERSION=${VERSION//./}
CURRENT=`pwd`
rm -rf $CURRENT/opencv
rm -rf $CURRENT/opencv_contrib

set -e

numcores=`nproc`

git clone https://github.com/opencv/opencv_contrib.git
git clone https://github.com/opencv/opencv.git
cd $CURRENT/opencv_contrib
git checkout $VERSION
cd $CURRENT/opencv
git checkout $VERSION
mkdir build
cd $CURRENT/opencv/build
#cmake -D OPENCV_ENABLE_MEMALIGN=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D OPENCV_IO_ENABLE_JASPER=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -D WITH_TBB=ON ..
#cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D OPENCV_IO_ENABLE_JASPER=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules ..
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D INSTALL_C_EXAMPLES=ON -D OPENCV_IO_ENABLE_JASPER=ON -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -D WITH_TBB=ON ..
make -j $numcores
sudo make install
sudo sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig
sudo mkdir -p /usr/lib/jni/ && sudo cp /usr/local/share/java/opencv4/libopencv_java$NODOTSVERSION.so  /usr/lib/jni/
mvn deploy:deploy-file -Durl=file:///$HOME/repo -Dfile=/usr/local/share/java/opencv4/opencv-$NODOTSVERSION.jar -DgroupId=org.opencv -DartifactId=opencv -Dpackaging=jar -Dversion=$VERSION
mkdir -p $HOME/.m2/repository/org/opencv/opencv/$VERSION/
cp $HOME/repo/org/opencv/opencv/$VERSION/* $HOME/.m2/repository/org/opencv/opencv/$VERSION/
sudo cp $CURRENT/opencv/build/lib/libopencv_java$NODOTSVERSION.so /usr/lib
