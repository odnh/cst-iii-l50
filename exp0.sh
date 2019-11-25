#!/bin/bash
dir=~/data/exp0
mkdir $dir
uname -a > "$dir/uname-${hostname}"
lshw -c cpu > "$dir/cpu-${hostname}"
lshw -c memory > "$dir/memory-${hostname}"
lshw -c disk > "$dir/disk-${hostname}"
lshw -c network > "$dir/network-${hostname"
