#!/bin/bash

script_path=$(dirname $(readlink -f $0))

echo "pulling recording from bela..."

rsync -avz root@bela.local:~/Bela/projects/schroedingers_box/rec/ $script_path/../bela/rec/

echo "done."
