FONTSDIR="/path/to/fonts/"
TEXTDIR="/path/to/text/"
OUTPUTDIR=/tmp/synthetic
MAXFILES=10

docker run -ti \
 -v $FONTSDIR:$FONTSDIR \
 -v $TEXTDIR:$TEXTDIR \
 -v /tmp/synthetic:/tmp/synthetic \
 loghi/docker.loghi-tooling \
 /src/loghi-tooling/minions/target/appassembler/bin/MinionGeneratePageImages \
 -add_salt_and_pepper \
 -font_path $FONTSDIR \
 -text_path $TEXTDIR \
 -output_path $OUTPUTDIR \
 -max_files $MAXFILES
