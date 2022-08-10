#!/bin/bash

CWD=$(pwd)
BELAIP="bela.local"

# go to bela repository
cd ~/src/Bela/scripts

# halt board
BBB_HOSTNAME=$BELAIP ./halt_board.sh

