#!/bin/bash

#Ale Cominotti - 2020

#char colors
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
  echo -e "${CYAN}Cleaning temporary files..."
    `rm -f $resources_folder/outputascii.html`
    `rm -f $sequence_folder/*.jpg`
    `rm -f $sequence_folder/*.txt`
    echo -e "Done${NONE}"
}

process_stop() {
    echo -e "\n${RED}Process stopped.${NONE}"
    clean_temps
    exit 1
}

trap 'process_stop' SIGINT

function help {
  clear
  banner
  while read line; do    
    echo $line    
  done < $resources_folder/help.txt
  exit 1
}

function help_message {
  echo -e "Use ${GREENTHIN}-h${NONE} or ${GREENTHIN}--help${NONE} to show help"
}


#Dependecies check-----------------------------------------------------
#1 = installed | 0 = not installed
jp2a_installed=$(dpkg-query -W -f='${Status}' jp2a 2>/dev/null | grep -c "ok installed")
ffmpeg_installed=$(dpkg-query -W -f='${Status}' ffmpeg 2>/dev/null | grep -c "ok installed")

if [[ $jp2a_installed -eq 0 ]] || [[ $ffmpeg_installed -eq 0 ]]; then

  if [[ $jp2a_installed -eq 0 ]] ; then
    echo -e "${YELLOWBG}'jpa2' is not installed and ASCII Maker needs it.${NONE}"
    read -p "Would you like to install it? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
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
#End dependecies check-------------------------------------------------


#Variables, do not modify
#----------------------------------------------------------
input=""
fps=""
width=220 #width of final ASCII animation, default= 220
background="dark" #dark | light
chars="" #chars of ASCII animation, leave EMPTY for default
re='^[0-9]+([.][0-9]+)?$' #decimal number regex
#----------------------------------------------------------


#Parameter handling----------------------------------------------------------
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -i|--input) 
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        if [ ! -f $2 ]; then
          echo -e "${RED}ERROR:${NONE} Input file '${2}' not found! (ex.: './asciimaker -i video.mp4')" >&2
          help_message
          exit 1
        fi
        input=$2
        shift 2
      else
        echo -e "${RED}ERROR:${NONE} Missing input value! (ex.: './asciimaker -i video.mp4)" >&2
        help_message
        exit 1
      fi
      ;;
    -h|--help)
        help
        exit 0
        shift 2
      ;;
    -fps|--frames)
      if [ -n "$2" ]; then
        if ! [[ $2 =~ $re ]] &&  [[ ! -z $2 ]]
        then
          echo -e "${RED}ERROR:${NONE} FPS parameter must be a number! (ex.: './asciimaker -i video.mp4 -fps 29.97')" >&2
          help_message
          exit 1
        fi
        fps=$2
        shift 2
      else
        echo -e "${RED}ERROR:${NONE} Missing FPS value! (ex.: './asciimaker -i video.mp4 -fps 60')" >&2
        help_message
        exit 1
      fi
      ;;
    -w|--width)
      if [ -n "$2" ]; then
        width=$2
        shift 2
      else
        echo -e "${RED}ERROR:${NONE} Missing width value! (ex.: './asciimaker -i video.mp4 -w 200')" >&2
        help_message
        exit 1
      fi
      ;;
    -c|--chars)
      if [ -n "$2" ]; then
        chars=$2
        shift 2
      else
        echo -e "${RED}ERROR:${NONE} Missing chars value! (ex.: './asciimaker -i video.mp4 -c \".-01abc\" ')" >&2
        help_message
        exit 1
      fi
      ;;
    -b|--background)
      if [ -n "$2" ]; then
        if ! [[ $2 == "dark" ]] && [[ ! $2 == "light"  ]]
          then
            echo -e "${RED}ERROR:${NONE} Incorrect background parameter! (ex.: './asciimaker -i video.mp4 -b \"dark\" ')" >&2
            help_message
            exit 1
        fi
        background=$2
        shift 2
      else
        echo -e "${RED}ERROR:${NONE} Missing background value! (ex.: './asciimaker -i video.mp4 -b \"dark\" ')" >&2
        help_message
        exit 1
      fi
      ;;
    -C|--clean)
      clean_temps
      exit 0
      ;;
    -*|--*=) # unsupported flags
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

#Mandatory input -i check:
if [[ $input = "" ]]; then
  echo -e "${RED}ERROR:${NONE} Missing input value! (ex.: './asciimaker -i video.mp4')" >&2
  help_message
  exit 1
fi
#End parameter handling------------------------------------------------------

#Aca empieza la joda
  clear
  banner
  echo -e "${BOLD}Input:${NONE} '${CYAN}${input}${NONE}'" #####
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
  ffmpeg -i $input -vf fps=$fps "${sequence_folder}/secuen%05d.jpg" -y -loglevel panic
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
  `rm -f $sequence_folder/*.jpg`
  `rm -f $sequence_folder/*.txt`
  `sed -i '1d' $resources_folder/outputascii.html`
  `head --lines=-1 $resources_folder/outputascii.html > output.html`
  `rm -f $resources_folder/outputascii.html`

  `echo "<!DOCTYPE html>
  <html>
    <head>
      <meta charset='UTF-8'>
      <title>Animación ASCII</title>
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
  echo -e "ASCII HTML Animation saved in '${BOLD}${GREEN}output.html${NONE}'"

exit 0
