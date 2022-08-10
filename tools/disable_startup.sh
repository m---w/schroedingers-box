#!/bin/bash

CWD=$(pwd)
BELAIP="bela.local"

# go to bela repository
cd ~/src/Bela/scripts

# set startup patch
BBB_HOSTNAME=$BELAIP ./set_startup.sh nostartup

