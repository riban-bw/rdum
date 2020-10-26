#!/usr/bin/env bash
# This script shows an icon in the notification area indicating the staus of available updates for dpkg based system.
# The total quantity of updates and the quantity of security updates is shown.
# The icon colour and symbol indicate whether none, only non-security or security updates are available.
# Right click to show context menu allowing installation of updates.
# Relies on background task to periodically query for updates, e.g. cron job performing apt update
#
# Dependencies: yad xterm awk bash

# Seconds between refreshing icon
REFRESH_PERIOD=600

# Create a pipe for control of yad
PIPE1=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
mkfifo $PIPE1
# Add descriptor to pipe
exec 3<> $PIPE1
PIPE2=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
mkfifo $PIPE2
# Add descriptor to pipe
exec 4<> $PIPE2

# Function to run on exit
function on_exit() {
  # Clean up
  echo "quit" >&3
  rm -f $PIPE1
  rm -f $PIPE2
  rm -f /tmp/rdup
}

trap on_exit EXIT

# Launch notification handler
yad --no-middle --notification --listen --image none --command="echo show" --text="Checking for updates..." <&3 > /proc/$$/fd/4 &
while true
do
  # Refresh update status from apt cache
  echo "tooltip:Checking for updates..." >&3
  echo "icon:none" >&3
  apt list --upgradeable | grep -v ^Listing...$ | awk '{print $1}' > /tmp/rdup
  security=`grep security /tmp/rdup|wc -l`
  total=`cat /tmp/rdup|wc -l`
  # Consume any commands recieved during previous processing
  read -t 1 -N 10000 <&4

  # Update systray icon
  if [ $security -gt 0 ]
  then
    echo "icon:important" >&3
    echo "tooltip:$total updates available ($security security updates)" >&3
    echo "menu:Check for new updates!echo update|Show $total available updates!echo show|Install updates!echo upgrade|Refresh status!echo refresh" >&3
    echo "visible:true" >&3
  elif [ $total -gt 0 ]
  then
    echo "icon:warning" >&3
    echo "tooltip:$total updates available" >&3
    echo "menu:Check for new updates!echo update|Show $total available updates!echo show|Install updates!echo upgrade|Refresh status!echo refresh" >&3
    echo "visible:true" >&3
  else
    echo "icon:none" >&3
    echo "tooltip:System is up to date" >&3
    echo "menu:Check for new updates!echo update|Show $total available updates!echo show|Refresh status!echo refresh" >&3
    echo "visible:false" >&3
  fi

  # Wait for next command
  read -t $REFRESH_PERIOD command <&4
  
  # Process command
  if [ " $command " == " update " ]
  then
    xterm -e pkexec apt update
  elif [ " $command " == " upgrade " ]
  then
      xterm -e pkexec apt upgrade
  elif [ " $command " == " show " ]
  then
    yad --title "Available updates" --center --height 200 --window-icon=system_section --button=Cancel --button="Install updates":1 --list --column "Software package name" $(awk -F'/' '{print $1}' /tmp/rdup) > /proc/$$/fd/4
    if [ $? -eq 1 ]
    then
      xterm -e pkexec apt upgrade
    fi
  fi
done
