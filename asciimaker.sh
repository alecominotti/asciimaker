#!/bin/bash

#Ale Cominotti - 2020

echo -ne "\033[00;33mLoading...\r"

#Char colors
NONE='\033[00m'
RED='\033[00;31m'
GREEN='\033[01;32m'
GREENTHIN='\033[00;32m'
YELLOW='\033[00;33m'
YELLOWBG='\033[07;33m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

resources_folder="resources"
sequence_folder="${resources_folder}/sequences"

function help {
  clear
  banner
  while read line; do    
    echo $line    
  done < $resources_folder/help.txt
  clean_temps
  exit 1
}

function help_message {
  echo -e "Use ${GREENTHIN}-h${NONE} or ${GREENTHIN}--help${NONE} to show help"
}

function banner {
  delay=0.05
  echo -ne "${YELLOW}"
  #echo '
  # ______   ______   ______   __   __       __    __   ______   __  __   ______   ______    
  #/\  __ \ /\  ___\ /\  ___\ /\ \ /\ \     /\ "-./  \ /\  __ \ /\ \/ /  /\  ___\ /\  == \   
  #\ \  __ \\ \___  \\ \ \____\ \ \\ \ \    \ \ \-./\ \\ \  __ \\ \  _"-.\ \  __\ \ \  __<   
  # \ \_\ \_\\/\_____\\ \_____\\ \_\\ \_\    \ \_\ \ \_\\ \_\ \_\\ \_\ \_\\ \_____\\ \_\ \_\ 
  #  \/_/\/_/ \/_____/ \/_____/ \/_/ \/_/     \/_/  \/_/ \/_/\/_/ \/_/\/_/ \/_____/ \/_/ /_/ 

  echo ' ______   ______   ______   __   __       __    __   ______   __  __   ______   ______    '
  sleep $delay
  echo '/\  __ \ /\  ___\ /\  ___\ /\ \ /\ \     /\ "-./  \ /\  __ \ /\ \/ /  /\  ___\ /\  == \   '
  sleep $delay
  echo '\ \  __ \\ \___  \\ \ \____\ \ \\ \ \    \ \ \-./\ \\ \  __ \\ \  _"-.\ \  __\ \ \  __<   '
  sleep $delay
  echo ' \ \_\ \_\\/\_____\\ \_____\\ \_\\ \_\    \ \_\ \ \_\\ \_\ \_\\ \_\ \_\\ \_____\\ \_\ \_\ '
  sleep $delay
  echo '  \/_/\/_/ \/_____/ \/_____/ \/_/ \/_/     \/_/  \/_/ \/_/\/_/ \/_/\/_/ \/_____/ \/_/ /_/ '
  sleep $delay
  echo''
  sleep $delay
  echo -e "${NONE}"
}

stty -echoctl # hide ^C

function clean_temps {
    `rm -f $resources_folder/outputascii.html`
    `rm -f $resources_folder/*.mp4`
    `rm -f $resources_folder/*.part`
    `rm -f $sequence_folder/*.jpg`
    `rm -f $sequence_folder/*.txt`
    `rm -f $resources_folder/running`
}

function clean_temps_verbose {
  echo -ne "${CYAN}Cleaning temporary files..."
    clean_temps
    echo -ne "${BOLD}${GREEN}√ "
    echo -e "Done${NONE}"
}



process_stop() {
    echo -e "\n${RED}Process stopped.${NONE}"
    clean_temps_verbose
    exit 1
}

trap 'process_stop' SIGINT


#Dependecies check-----------------------------------------------------
#1 = installed | 0 = not installed
case "${OSTYPE}" in
    linux-gnu)
      jp2a_installed=$(dpkg-query -W -f='${Status}' jp2a 2>/dev/null | grep -c "ok installed")
      ffmpeg_installed=$(dpkg-query -W -f='${Status}' ffmpeg 2>/dev/null | grep -c "ok installed")

      if [[ $jp2a_installed -eq 0 ]] || [[ $ffmpeg_installed -eq 0 ]] && [[ ! "$*" == "-h" ]] && [[ ! "$*" == "--help" ]]; then

          if [[ $jp2a_installed -eq 0 ]] ; then
            echo -e "${YELLOWBG}'jpa2' is not installed and ASCII Maker needs it.${NONE}"
            read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1 && clean_temps
            sudo apt-get install -y jp2a
          fi

          if [[ $ffmpeg_installed -eq 0 ]] ; then
            echo -e "${YELLOWBG}'FFmpeg' is not installed and ASCII Maker needs it.${NONE}"
            read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            sudo apt-get install -y ffmpeg
          fi

          echo -e "${GREEN}---------------------------------------------------------------------"
          read -n 1 -s -r -p "Dependencies were installed! Press any key to continue to ASCII Maker"
          echo -e "${NONE}"
      fi
      ;;
    Darwin)
    echo -e "${RED}ERROR:${NONE} ASCII Maker is not compatible with Mac OS systems yet."
    exit 1
    ;;
    *) 
      echo -e "${RED}ERROR:${NONE} ASCII Maker is only compatible with Linux systems."
      exit 1
      ;;
esac

#End dependecies check-------------------------------------------------

if [ -f $resources_folder/running ] && [[ ! "$*" == "-h" ]] && [[ ! "$*" == "--help" ]]; then
    echo -e "${RED}ERROR:${NONE} ASCII Maker already running in another window" >&2
    help_message
    exit 1
  else
    touch $resources_folder/running 
fi

#Variables, do not modify
#----------------------------------------------------------
input=""
youtube_url=""
yt_name=""
fps=""
start_pos=""
end_pos=""
width=220 #width of final ASCII animation, default= 220
background="dark" #dark | light
chars="" #chars of ASCII animation, leave EMPTY for default
re='^[0-9]+([.][0-9]+)?$' #decimal number regex
time_regex='^([0-5][0-9]:)?[0-5][0-9]:[0-5][0-9]$'
#----------------------------------------------------------

youtube_dependencies_check(){
  #installs python3, pip3, youtube-dl package and updates pip, setuptools and wheel
  clean_temps
  python3_installed=`command -v python3 >/dev/null 2>&1 && echo 1`
  pip3_installed=`command -v pip3 >/dev/null 2>&1 && echo 1`
  if [[ ! $python3_installed -eq 1 ]] ; then
    echo -e "${YELLOWBG}'Python 3' is not installed and ASCII Maker needs it to download Youtube videos.${NONE}"
    read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1 && clean_temps
    sudo apt-get install python3.6
    python -m pip install --upgrade pip setuptools wheel #check pip, setuptools, and wheel are up to date
  fi
  if [[ ! $pip3_installed -eq 1 ]] ; then
    echo -e "${YELLOWBG}'Pip3' is not installed and ASCII Maker needs it to download a Python Youtube package.${NONE}"
    read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1 && clean_temps
    sudo apt install python3-pip
  fi
  if ! pip3 freeze | grep "youtube-dl"= > /dev/null ; then
    echo -e "${YELLOWBG}'youtube-dl' is not installed and ASCII Maker needs it to download Youtube videos.${NONE}"
    read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    sudo python3 -m pip install youtube-dl
    echo -e "${GREEN}---------------------------------------------------------------------"
    read -n 1 -s -r -p "Youtube dependencies were installed! Press any key to continue to ASCII Maker"
    echo -e "${NONE}"
  fi
}

#Parameter handling----------------------------------------------------------
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -i|--input) 
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        if [ ! -f $2 ]; then
          clean_temps 
          echo -e "${RED}ERROR:${NONE} Input file '${2}' not found (ex.: './asciimaker -i video.mp4')" >&2
          help_message
          exit 1
        fi
        input=$2
        shift 2
      else
        clean_temps 
        echo -e "${RED}ERROR:${NONE} Missing input value (ex.: './asciimaker -i video.mp4)" >&2
        help_message
        exit 1
      fi
      ;;
    -h|--help)
        help
        exit 0
        shift 2
      ;;
    -f|--fps)
      if [ -n "$2" ]; then
        if ! [[ $2 =~ $re ]] &&  [[ ! -z $2 ]]
        then
          clean_temps 
          echo -e "${RED}ERROR:${NONE} FPS parameter must be a number (ex.: './asciimaker -i video.mp4 -fps 29.97')" >&2
          help_message
          exit 1
        fi
        fps=$2
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing FPS value (ex.: './asciimaker -i video.mp4 -fps 60')" >&2
        help_message
        exit 1
      fi
      ;;
    -w|--width)
      if [ -n "$2" ]; then
        width=$2
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing width value (ex.: './asciimaker -i video.mp4 -w 200')" >&2
        help_message
        exit 1
      fi
      ;;
    -c|--chars)
      if [ -n "$2" ]; then
        chars=$2
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing chars value (ex.: './asciimaker -i video.mp4 -c \".-01abc\" ')" >&2
        help_message
        exit 1
      fi
      ;;
    -b|--background)
      if [ -n "$2" ]; then
        if ! [[ $2 == "dark" ]] && [[ ! $2 == "light"  ]]
          then
            clean_temps
            echo -e "${RED}ERROR:${NONE} Incorrect background parameter (ex.: './asciimaker -i video.mp4 -b \"dark\" ')" >&2
            help_message
            exit 1
        fi
        background=$2
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing background value (ex.: './asciimaker -i video.mp4 -b \"dark\" ')" >&2
        help_message
        exit 1
      fi
      ;;
    -s|--start)
      if [ -n "$2" ]; then
        if ! [[ $2 =~ $time_regex ]] &&  [[ ! -z $2 ]]
          then
            clean_temps
            echo -e "${RED}ERROR:${NONE} Incorrect time expression (ex.: './asciimaker -i video.mp4 -s 00:15 ')" >&2
            help_message
            exit 1
        fi
        start_pos=$2
        if [[ ${#2} -eq 5 ]]; then
          start_pos=`echo 00:$start_pos`
        fi
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing starting position (ex.: './asciimaker -i video.mp4 -s 00:15 ')" >&2
        help_message
        exit 1
      fi
      ;;
    -e|--end)
      if [ -n "$2" ]; then
        if ! [[ $2 =~ $time_regex ]] &&  [[ ! -z $2 ]]
          then
            clean_temps
            echo -e "${RED}ERROR:${NONE} Incorrect time expression (ex.: './asciimaker -i video.mp4 -e 00:45 ')" >&2
            help_message
            exit 1
        fi
        end_pos=$2
        if [[ ${#2} -eq 5 ]]; then
          end_pos=`echo 00:$end_pos`
        fi
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing ending position (ex.: './asciimaker -i video.mp4 -e 00:45 ')" >&2
        help_message
        exit 1
      fi
      ;;
    -C|--clean)
      clean_temps_verbose
      exit 0
      ;;
    -y|--youtube)
      if ! [ -z $input ]; then
        clean_temps
        echo -e "${RED}ERROR:${NONE} You can't use both local and Youtube inputs at the same time" >&2
        help_message
        exit 1
      fi
      youtube_dependencies_check
      if [ -n "$2" ]; then
        youtube_url="${2}"
        shift 2
      else
        clean_temps
        echo -e "${RED}ERROR:${NONE} Missing youtube URL (ex.: './asciimaker -y https://www.youtube.com/watch?v=dQw4w9WgXcQ')" >&2
        help_message
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      clean_temps
      echo -e "${RED}ERROR:${NONE} Unsupported argument: '$1'" >&2
      help_message
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

#Youtube video download
if [[ ! $youtube_url == "" ]]; then
  `rm -f $resources_folder/*.mp4`
  clear
  banner
  echo -e "${GREENTHIN}Downloading video from Youtube, please wait...${NONE}"
  video_dl=$(youtube-dl -o "resources/%(title)s" -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio' ${youtube_url})
  one=${video_dl#*Merging formats into }
  two=${one%Deleting*}
  input=`echo "$two" | awk -F'"' '{print $2}'`
  yt_name=`echo ${input##*/}`
  if [ -z "$yt_name" ]; then
    exit 1
  fi
fi

#Mandatory input -i check:
if [[ $input = "" ]]; then
  clean_temps
  echo -e "${RED}ERROR:${NONE} Missing input value! (ex.: './asciimaker -i video.mp4')" >&2
  help_message
  exit 1
fi

#Start and ending positions check:
if [ ! -z $start_pos ] && [ ! -z $end_pos ]; then
  IFS=: read ah am as <<< "$start_pos"
  IFS=: read bh bm bs <<< "$end_pos"
  secondsA=$((10#$ah*60*60 + 10#$am*60 + 10#$as))
  secondsB=$((10#$bh*60*60 + 10#$bm*60 + 10#$bs))
  DIFF_SEC=$((secondsB - secondsA))
  SEC=$(($DIFF_SEC%60))
  MIN=$((($DIFF_SEC-$SEC)%3600/60))
  HRS=$((($DIFF_SEC-$MIN*60)/3600))
  TIME_DIFF="$HRS:$MIN:$SEC";

  if [[ ! $TIME_DIFF != *"-"* ]];then
    clean_temps
    echo -e "${RED}ERROR:${NONE} Ending time position must be subsequent to the starting time position (ex.: './asciimaker -i video.mp4 -s 00:10 -e 00:15')" >&2
    help_message
    exit 1
  fi
fi
if [ ! -z $end_pos ]; then
  video_length=`ffprobe -i "$input" -show_entries format=duration -v quiet -of csv="p=0" | cut -d "." -f 1`
  diff="$(($secondsB - $video_length))"
  if (( $diff > 0 )); then
    clean_temps
    echo -e "${RED}ERROR:${NONE} Range of time selected not valid for that video (Maybe your ending time position exceeds video duration)." >&2
    help_message
    exit 1
  fi
fi

#End parameter handling------------------------------------------------------

#Aca empieza la joda
  clear
  banner
  if [[ "$yt_name" == "" ]]
    then
      echo -e "${BOLD}Input:${NONE} '${CYAN}${input}${NONE}'" #####
    else
      echo -e "${BOLD}Input:${NONE} '${CYAN}${yt_name}${NONE}' ${CYAN}(From Youtube)${NONE}" #####  
  fi
  if [ -z $start_pos ]
    then
      echo -e "${BOLD}Start position:${NONE} ${CYAN}Same as input${NONE}" #####
    else
      echo -e "${BOLD}Start position:${NONE} ${CYAN}${start_pos}${NONE}" #####  
  fi
  if [ -z $end_pos ]
    then
      echo -e "${BOLD}End position:${NONE} ${CYAN}Same as input${NONE}" #####
    else
      echo -e "${BOLD}End position:${NONE} ${CYAN}${end_pos}${NONE}" #####  
  fi
  if [ -z $fps ]
    then
      echo -e "${BOLD}FPS:${NONE} ${CYAN}Same as input${NONE}" #####
    else
      echo -e "${BOLD}FPS:${NONE} ${CYAN}${fps}${NONE}" #####        
  fi
  echo -e "${BOLD}Width:${NONE} ${CYAN}${width}${NONE}" #####  
  if [ -z $chars ]
    then
      echo -e "${BOLD}Chars:${NONE} ${CYAN}Default${NONE}" #####
    else
      echo -e "${BOLD}Chars:${NONE} '${CYAN}${chars}${NONE}'" #####        
  fi  
  echo -e "${BOLD}Background:${NONE} ${CYAN}${background}${NONE}" #####  
  echo -e "${PURPLE}-----------------------${NONE}" #####
  #echo -e "${PURPLE}Press Ctrl+C to stop execution${NONE}" #####
  echo -ne "Generating JPG sequence..." #####
  SECONDS=0 #timer start

  #Spaghet-ish
  if [ ! -z $start_pos ]
    then
      if [ ! -z $end_pos ]
        then
          ffmpeg -ss "${start_pos}" -to "${end_pos}" -i "${input}" -vf fps=$fps "${sequence_folder}/secuen%05d.jpg" -y -loglevel panic
        else
          ffmpeg -ss "${start_pos}" -i "${input}" -vf fps=$fps "${sequence_folder}/secuen%05d.jpg" -y -loglevel panic
      fi
    else
      if [ ! -z $end_pos ]
        then
          ffmpeg -to "${end_pos}" -i "${input}" -vf fps=$fps "${sequence_folder}/secuen%05d.jpg" -y -loglevel panic
        else
          ffmpeg -i "${input}" -vf fps=$fps "${sequence_folder}/secuen%05d.jpg" -y -loglevel panic
      fi
  fi  
  echo -e "${BOLD}${GREEN}√${NONE}"
  echo -ne "Generating ASCII frames..." #####
  `rm -f output.html`
  `rm -f $resources_folder/outputascii.html`
  if [ -z $chars ]
    then
      `find $sequence_folder -name '*.jpg' | sort | xargs -I xxx jp2a --width=$width --background=$background xxx --output=xxx.txt`
    else
      `find $sequence_folder -name '*.jpg' | sort | xargs -I xxx jp2a --chars=${chars@Q} --width=$width --background=$background xxx --output=xxx.txt`
  fi        
  echo -e "${BOLD}${GREEN}√${NONE}"
  echo -ne "Generating HTML file..." #####
  `for f in $sequence_folder/*.txt; do echo '</pre><pre>'; cat "$f"; done >> $resources_folder/outputascii.html`
  echo -e "${BOLD}${GREEN}√${NONE}"
  echo -ne "Cleaning temp files..." #####
  `rm -f $resources_folder/*.mp4`
  `rm -f $sequence_folder/*.jpg`
  `rm -f $sequence_folder/*.txt`
  `sed -i '1d' $resources_folder/outputascii.html`
  `head --lines=-1 $resources_folder/outputascii.html > output.html`
  `rm -f $resources_folder/outputascii.html`
  `rm -f $resources_folder/*.part`

  `echo "<!DOCTYPE html>
  <html>
    <head>
      <meta charset='UTF-8'>
      <title>ASCII HTML Art</title>
    </head>
    <body>
      <style>
        html {
        background-color: black;
        color: white;
        }
      </style>
  <div id='images'>
  <pre>" | cat - output.html > temp && mv temp output.html`

  `echo '</pre>
  </div>
  <script type="text/javascript">
    (function() {
        var pres = document.querySelectorAll("#images pre");
        var len = pres.length;
        for(var i = 0; i < pres.length; i = i + 1) {
            pres[i].style.display = "none";
        }
        var a = 0;
        window.setInterval(function() {
            pres[a].style.display = "none";
            pres[(a + 1)%len].style.display = "block";
            a = (a + 1) % len;
            console.log(a)
        }, 40);
    }());
  </script>
  </body>
  </html>' >> output.html`
  echo -e "${BOLD}${GREEN}√${NONE}"
  if (( $SECONDS > 3600 )) ; then
    let "hours=SECONDS/3600"
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo "Completed in $hours hour(s), $minutes minute(s) and $seconds second(s)" 
  elif (( $SECONDS > 60 )) ; then
    let "minutes=(SECONDS%3600)/60"
    let "seconds=(SECONDS%3600)%60"
    echo -ne "Completed in $minutes minute(s) and $seconds second(s)"
  else
    echo -ne "Completed in $SECONDS seconds"
  fi
  echo -e "${BOLD}${GREEN} √${NONE}"
  echo -e "ASCII HTML Animation saved in '${BOLD}${GREEN}output.html${NONE}'"

`rm -f $resources_folder/running`

exit 0
