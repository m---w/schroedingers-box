#!/bin/bash

script_path=$(dirname $(readlink -f $0))

echo "pushing patch to bela (overwriting everything)..."

# scp -r $script_path/../bela/* root@bela.local:~/Bela/projects/schroedingers_box
rsync -avz $script_path/../bela/ root@bela.local:~/Bela/projects/schroedingers_box/

rsync -avz $script_path/../SchroedingersUGens/ root@bela.local:/usr/local/share/SuperCollider/Extensions/SchroedingersUGens/

echo "done."
