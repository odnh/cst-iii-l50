#!/bin/bash

# cleans all files from vms

for i in {1..4}
do
  ssh "vm$i" 'rm -rf ~/data; rm ~/errors.log; mkdir -p ~/data/exp{0..13}'
done
rm -rf ~/data
rm ~/errors.log
mkdir -p ~/data/exp{0..13}
