#!/bin/bash

#Basic variables to customize output:
width=220 #width of final ASCII animation
background="dark" #dark|light
chars="" #chars of ASCII animation, leave EMPTY for default



NONE='\033[00m'
RED='\033[00;31m'
GREEN='\033[01;32m'
YELLOW='\033[00;33m'
YELLOWBG='\033[07;33m'
PURPLE='\033[00;35m'
CYAN='\033[00;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

process_stop() {
    echo -e "\n${RED}Process stopped.${NONE} Cleaning temp files..."
    `rm -f outputascii.html`
    `rm -f secuenciaJPG/*.jpg`
    `rm -f secuenciaJPG/*.txt`
    echo -e "Done"
    exit 1
}

trap 'process_stop' SIGINT

function banner {
  delay=0.05
  echo -e "${YELLOW}"
  #echo '
 #______   ______   ______   __   __       __    __   ______   __  __   ______   ______    
#/\  __ \ /\  ___\ /\  ___\ /\ \ /\ \     /\ "-./  \ /\  __ \ /\ \/ /  /\  ___\ /\  == \   
#\ \  __ \\ \___  \\ \ \____\ \ \\ \ \    \ \ \-./\ \\ \  __ \\ \  _"-.\ \  __\ \ \  __<   
# \ \_\ \_\\/\_____\\ \_____\\ \_\\ \_\    \ \_\ \ \_\\ \_\ \_\\ \_\ \_\\ \_____\\ \_\ \_\ 
#  \/_/\/_/ \/_____/ \/_____/ \/_/ \/_/     \/_/  \/_/ \/_/\/_/ \/_/\/_/ \/_____/ \/_/ /_/ 
#  '

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

function ayuda {
  clear
  banner
  while read line; do    
    echo $line    
  done < ayuda.txt
  exit 1
}

if [[ $1 = "-h" ]] || [[ $1 = "--help" ]] || [[ $1 = "-help" ]]; then
  ayuda
fi

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


stty -echoctl # hide ^C

function clean_temps {
  echo -e "${CYAN}Cleaning temporary files..."
    `rm -f outputascii.html`
    `rm -f secuenciaJPG/*.jpg`
    `rm -f secuenciaJPG/*.txt`
    echo -e "Done${NONE}"
}

if [[ $1 = "-c" ]] || [[ $1 = "--clean" ]] || [[ $1 = "-clean" ]]; then
  clean_temps
  exit 0
fi

if [ ! -f $1 ]; then
    echo -e ${RED}ERROR:${NONE} File "'${1}' not found"
    echo "Use -h or --help to show help"
    exit 1
fi

re='^[0-9]+([.][0-9]+)?$'

if [ -z $1 ]
  then
    echo -e "${RED}ERROR:${NONE} Video name or path missing (ex.: './asciimaker video.mp4')">&2
    echo "Use -h or --help to show help"
  else
    if ! [[ $2 =~ $re ]] &&  [[ ! -z $2 ]]
      then
        echo -e "${RED}ERROR:${NONE} Second argument must be a number (ex.: './asciimaker video.mp4 24')">&2
        echo "Use -h or --help to show help"
    else
      clear
      banner
      echo -e "${BOLD}Video:${NONE} '${CYAN}${1}${NONE}'" #####
      if [ -z $2 ]
        then
          echo -e "${BOLD}FPS:${NONE} ${CYAN}Same as video${NONE}" #####
        else
          echo -e "${BOLD}FPS:${NONE} ${CYAN}${2}${NONE}" #####        
      fi    
      echo -e "${PURPLE}-----------------------${NONE}" #####
      #echo -e "${PURPLE}Press Ctrl+C to stop execution${NONE}" #####
      echo -ne "Generating JPG sequence..." #####
      ffmpeg -i $1 -vf fps=$2 'secuenciaJPG/secuen%05d.jpg' -y -loglevel panic
      echo -e "${BOLD}${GREEN}√${NONE}"
      echo -ne "Generating ASCII frames..." #####
      `rm -f output.html`
      `rm -f outputascii.html`
      if [ -z $chars ]
        then
          `find secuenciaJPG -name '*.jpg' | sort | xargs -I xxx jp2a --width=$width --background=$background xxx --output=xxx.txt`
        else
          `find secuenciaJPG -name '*.jpg' | sort | xargs -I xxx jp2a --chars=$chars --width=$width --background=$background xxx --output=xxx.txt`
      fi        
      echo -e "${BOLD}${GREEN}√${NONE}"
      echo -ne "Generating HTML file..." #####
      `for f in secuenciaJPG/*.txt; do echo '</pre><pre>'; cat "$f"; done >> outputascii.html`
      echo -e "${BOLD}${GREEN}√${NONE}"
      echo -ne "Cleaning temp files..." #####
      `rm -f secuenciaJPG/*.jpg`
      `rm -f secuenciaJPG/*.txt`
      `sed -i '1d' outputascii.html`
      `head --lines=-1 outputascii.html > output.html`
      `rm -f outputascii.html`

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

  fi
fi