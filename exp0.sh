#!/bin/bash
dir=~/data/exp0
mkdir $dir
sudo uname -a > "$dir/uname-$(hostname)"
sudo lshw -c cpu > "$dir/cpu-$(hostname)"
sudo lshw -c memory > "$dir/memory-$(hostname)"
sudo lshw -c disk > "$dir/disk-$(hostname)"
sudo lshw -c network > "$dir/network-$(hostname)"
