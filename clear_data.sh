#!/bin/bash

# cleans all files from vms

for i in {1..4}
do
  ssh "vm$i" 'rm -rf ~/data; mkdir -p ~/data/{exp0,exp1,exp2,exp3,exp4,exp5}'
done
rm -rf ~/data
mkdir -p ~/data/{exp0,exp1,exp2,exp3,exp4,exp5}
