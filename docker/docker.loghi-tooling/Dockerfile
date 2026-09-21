FROM docker.base

EXPOSE 9006

RUN useradd -u 1000 rutger

RUN apt-get update && \
  apt-get install -y locales && rm -rf /var/lib/apt

RUN locale-gen en_US.UTF-8
ARG LOGHI_VERSION=1.0-SNAPSHOT

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV LOGHI_VERSION=${LOGHI_VERSION}

COPY loghi-tooling /src/loghi-tooling
COPY prima-core-libs /src/prima-core-libs
COPY dependency-check-data /root/.m2/repository/org/owasp/dependency-check-data

WORKDIR /src/prima-core-libs/java

RUN apt-get update && apt-get --no-install-recommends install -y openjdk-17-jre openjdk-17-jdk maven postgresql-client libdc1394-25 libavcodec62 libavformat62 libswscale9 libavutil60 libswresample6 libtbb12 git \
  && mvn deploy:deploy-file -Durl=file:///$HOME/repo -Dfile=/usr/local/share/java/opencv4/opencv-4140.jar -DgroupId=org.opencv -DartifactId=opencv -Dpackaging=jar -Dversion=4.14.0 \
  && mvn clean package
RUN cd /src \
  && git clone https://github.com/rvankoert/langident.git \
  && cd langident \
  && mvn clean package \
  && mvn deploy:deploy-file -Durl=file:///$HOME/repo -Dfile=target/langident-1.0.5-SNAPSHOT.jar -DgroupId=nl.knaw.huygens.pergamon.nlp -DartifactId=langident -Dpackaging=jar -Dversion=1.0.5

RUN cd /src/loghi-tooling \
  && mvn versions:set -DgenerateBackupPoms=false -DnewVersion=$LOGHI_VERSION clean package \
  && find . -name src | xargs rm -rf \
  && find . -name test-classes | xargs rm -rf \
  && rm -rf /src/loghi-tooling/layoutanalyzer/target \
  && apt-get remove -y --purge maven openjdk-17-jdk openjdk-17-jdk-headless \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt \
  && rm -rf /home/root \
  && rm -rf /root \
  && java -version 2>&1 | grep -q '"17\.' \
  && if which javac >/dev/null 2>&1; then echo "FATAL: javac should have been removed"; exit 1; fi \
  && M=$(ldd /usr/local/lib/libopencv_videoio.so.414 /usr/local/lib/libopencv_core.so.414 2>/dev/null | grep "not found" || true) \
  && if [ -n "$M" ]; then echo "FATAL: missing runtime libs: $M"; exit 1; fi
