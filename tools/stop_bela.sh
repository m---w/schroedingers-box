#!/bin/bash

CWD=$(pwd)
BELAIP="bela.local"

# go to bela repository
cd ~/src/Bela/scripts

# stop bela ide
BBB_HOSTNAME=$BELAIP ./ide.sh stop

# stop currently running project
BBB_HOSTNAME=$BELAIP ./stop_running.sh


