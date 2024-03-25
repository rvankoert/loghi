FROM docker.base

EXPOSE 9006

RUN useradd -u 1000 rutger
#RUN useradd -m builder
RUN apt-get  update && \
  apt-get install -y locales && rm -rf /var/lib/apt
#  apt-get install -y openjdk-11-jre maven postgresql-client locales

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY loghi-tooling /src/loghi-tooling
COPY prima-core-libs /src/prima-core-libs
COPY dependency-check-data /root/.m2/repository/org/owasp/dependency-check-data

WORKDIR /src/prima-core-libs/java
#USER builder
RUN apt-get update && apt-get --no-install-recommends install -y openjdk-11-jre maven postgresql-client libdc1394-22 libavcodec58 libavformat58 libswscale5 libtbb2 git \
  && mvn deploy:deploy-file -Durl=file:///$HOME/repo -Dfile=/usr/local/share/java/opencv4/opencv-490.jar -DgroupId=org.opencv -DartifactId=opencv -Dpackaging=jar -Dversion=4.9.0 \
  && mvn clean package
RUN cd /src \
  && git clone https://github.com/rvankoert/langident.git \
  && cd langident \
  && mvn clean package \
  && mvn deploy:deploy-file -Durl=file:///$HOME/repo -Dfile=target/langident-1.0.5-SNAPSHOT.jar -DgroupId=nl.knaw.huygens.pergamon.nlp -DartifactId=langident -Dpackaging=jar -Dversion=1.0.5

#	  && mvn clean package \
RUN cd /src/loghi-tooling \
  && mvn clean org.owasp:dependency-check-maven:check package \
  && find . -name src | xargs rm -rf \
  && find . -name test-classes | xargs rm -rf \
  && rm -rf /src/loghi-tooling/layoutanalyzer/target \
  && apt-get remove -y maven && apt autoremove -y \
  && rm -rf /var/lib/apt \
  && rm -rf /home/root \
  && rm -rf /root


#WORKDIR /src
#RUN wget https://dl.min.io/client/mc/release/linux-amd64/mcli_20221029100923.0.0_amd64.deb && dpkg -i mcli_20221029100923.0.0_amd64.deb && rm mcli_20221029100923.0.0_amd64.deb
#RUN mcli alias set myminio/ http://MINIO-SERVER MYUSER MYPASSWORD


#FROM docker.base
#RUN useradd -u 1000 rutger
#RUN apt-get update \
#  && apt-get install -y --no-install-recommends openjdk-11-jre libtbb2 \
#  && apt autoremove -y
#
#COPY --from=0 /src/loghi-tooling /src/loghi-tooling
#
#USER root

#USER rutger
#  && apt remove -y git autotools-dev dpkg-dev icu-devtools libaec-dev libavutil-dev libblkid-dev libc-dev-bin libc6-dev libcrypt-dev libdatrie-dev \
#  libegl-dev libexif-dev libexpat1-dev libffi-dev libfreetype6-dev libfribidi-dev libgcc-9-dev libgl-dev libglib2.0-dev-bin libglu1-mesa-dev libglx-dev \
#  libgraphite2-dev libice-dev libicu-dev libjbig-dev libjpeg-turbo8-dev liblzma-dev libmount-dev libogg-dev libopenblas-pthread-dev libpcre2-dev libpcre3-dev \
#  libpixman-1-dev libpthread-stubs0-dev libqt5opengl5-dev libraw1394-dev libselinux1-dev libsepol1-dev libsm-dev libstdc++-9-dev libswresample-dev libthai-dev \
#  libvulkan-dev libx11-dev libxau-dev libxcb-render0-dev libxcb-shm0-dev libxcb1-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxdmcp-dev libxext-dev \
#  libxfixes-dev libxi-dev libxinerama-dev libxrandr-dev libxrender-dev libxt-dev linux-libc-dev manpages-dev qtbase5-dev qtbase5-dev-tools uuid-dev \
#  x11proto-core-dev x11proto-dev x11proto-input-dev x11proto-randr-dev x11proto-xext-dev x11proto-xinerama-dev xtrans-dev zlib1g-dev libllvm10 libllvm12 \
#  libx265-179 perl-modules-5.30 libperl5.30 humanity-icon-theme \
