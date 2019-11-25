#!/bin/bash

# cleans all files from vms

for i in {1..4}
do
  ssh "vm$i" 'rm -rf ~/*'
done
