FONTSDIR=/home/rutger/Downloads/toLaptop/fonts/usable/
TEXTDIR=/media/rutger/HDI0002/toLaptop/text/
OUTPUTDIR=/tmp/synthetic
MAXFILES=10

#mkdir -p $OUTPUTDIR/page

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
