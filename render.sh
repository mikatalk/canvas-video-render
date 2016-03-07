#!/bin/bash
# Argument = -s size -o output

usage()
{
cat << EOF
usage: $0 options
OPTIONS:
   -h      Show this message
   -s      size
   -o      output
   -f      fps
example ᐅ ./render.sh -s 320x240 -o output.mp4
EOF
}

SIZE=
OUTPUT=
FPS=
PIPE=./tmp.fifo

while getopts ":hs:o:f:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    s)
      SIZE=$OPTARG
      ;;
    o)
      OUTPUT=$OPTARG
      ;;
    f)
      FPS=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
  esac
done

if [[ -z $SIZE ]] || [[ -z $OUTPUT ]] || [[ -z $FPS ]]
then
     usage
     exit 1
fi

# run program:

[ -e $PIPE ] && rm -f $PIPE

mkfifo -m 0666 $PIPE

node server.js $PIPE $SIZE | ffmpeg -y  -f rawvideo -pix_fmt rgba -vcodec rawvideo \
-s $SIZE -r $FPS -i $PIPE -codec:v libx264 -profile:v high -preset slow -pix_fmt yuv420p \
-b:v 500k -maxrate 500k -bufsize 1000k -vf scale=-1:480 -threads 0 -an out.mp4

[ -e $PIPE ] && rm -f $PIPE

# exit
true
