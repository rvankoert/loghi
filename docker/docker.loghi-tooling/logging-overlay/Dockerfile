# Overlay that turns the minion logging default from DEBUG to INFO.
#
# The base image's minions run on Logback (logback-classic 1.2.10, bound via
# SLF4J) with no logback.xml anywhere, so Logback's built-in default applies:
# root level DEBUG. The appassembler launcher scripts put the directory
# /src/loghi-tooling/minions/target/appassembler/etc FIRST on the classpath,
# so a logback.xml placed there is picked up automatically by every minion.
#
# Build:
#   docker build -t loghi/docker.loghi-tooling:2.3.1beta-loginfo .
#
# Then point the pipeline at it, e.g. in na-pipeline-cabr-*.sh:
#   DOCKERLOGHITOOLING=loghi/docker.loghi-tooling:2.3.1beta-loginfo
FROM loghi/docker.loghi-tooling:2.3.1beta

RUN mkdir -p /src/loghi-tooling/minions/target/appassembler/etc
COPY logback.xml /src/loghi-tooling/minions/target/appassembler/etc/logback.xml
