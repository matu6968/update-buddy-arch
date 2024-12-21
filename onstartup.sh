#!/bin/bash

DIRECTORY="$(readlink -f "$(dirname "$0")")"

#From pi-apps add_english function
if [ "$(cat /usr/share/i18n/SUPPORTED | grep -o 'en_US.UTF-8' )" == "en_US.UTF-8" ]; then
  locale=$(locale -a | grep -oF 'en_US.utf8')
  if [ "$locale" != 'en_US.utf8' ]; then
    status "Adding en_US locale for better logging... "
    sudo sed -i '/en_US.UTF-8/s/^#[ ]//g' /etc/locale.gen
    sudo locale-gen
  fi
else
    warning "en_US locale is not available on your system. This may cause bad logging experience."
fi
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

while true;do
  update=1

  failwait=1
  while true;do
    output="$(sudo pacman -Sy 2>&1)"
    exitcode=$?
    if ! echo "$output" | grep -q 'Temporary failure resolving' ;then
      break
    elif [ $exitcode != 0 ];then
      break
    fi
    sleep "${failwait}m"
    failwait=$((failwait*2)) #exponential retry: 1m, 2m, 4m, 8m, 16m...
  done
  
  #pacman dosen't display the number of available updates when running pacman -Sy, so it will only be detected if the list variable is empty 
  if [ $exitcode != 0 ];then
    update=0
  fi
  
LIST=$(comm -23 \
  <(pacman -Qu | cut -d ' ' -f 1 | sort) \
  <(grep "^IgnorePkg" /etc/pacman.conf | cut -d '=' -f 2 | tr -s ' ' '\n' | sort))

  
  if [ -z "$LIST" ];then
    update=0
  fi
  
  if [ $update == 1 ];then
    screen_width="$(xdpyinfo | grep 'dimensions:' | tr 'x' '\n' | tr ' ' '\n' | sed -n 7p)"
    screen_height="$(xdpyinfo | grep 'dimensions:' | tr 'x' '\n' | tr ' ' '\n' | sed -n 8p)"
    
    yad --form --text='Update Buddy:
pacman updates available.' \
      --on-top --skip-taskbar --undecorated --close-on-unfocus \
      --geometry=260+$((screen_width-262))+$((screen_height-150)) \
      --image="${DIRECTORY}/logo.png" \
      --button="Details!${DIRECTORY}/icons/info.png":0 \
      --button="Later!${DIRECTORY}/icons/exit.png":1 \
      2>/dev/null || update=0
  fi
  
  if [ $update == 1 ];then
    echo -e "$LIST" | yad --center --title='Update Buddy' --width=310 --height=300 --no-headers --no-selection \
      --list --separator='\n' --window-icon="${DIRECTORY}/logo.png" \
      --text='These packages can be upgraded:' \
      --column=Package \
      --button='Cancel'!"${DIRECTORY}/icons/exit.png"!:1 \
      --button='Update now'!"${DIRECTORY}/icons/download.png":0 \
      2>/dev/null || update=0
  fi
  
  if [ $update == 1 ];then
    "${DIRECTORY}/terminal-run" 'sudo pacman -Syu --noconfirm;echo "Closing in 10 seconds.";sleep 10' 'Upgrading packages'
  fi
  
  #echo "Waiting 12 hours"
  sleep 12h
done
