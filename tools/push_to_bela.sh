#!/bin/bash

script_path=$(dirname $(readlink -f $0))

echo "pushing patch to bela (overwriting everything)..."

scp -r $script_path/../bela/* root@bela.local:~/Bela/projects/schroedingers_box

echo "done."
