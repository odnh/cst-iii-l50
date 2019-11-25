#!/bin/bash
dir=~/data/exp0
mkdir -p $dir
sudo uname -a &> "$dir/uname-$(hostname)"
sudo lshw -c cpu &> "$dir/cpu-$(hostname)"
sudo lshw -c memory &> "$dir/memory-$(hostname)"
sudo lshw -c disk &> "$dir/disk-$(hostname)"
sudo lshw -c network &> "$dir/network-$(hostname)"
traceroute --version &> "$dir/traceroute-$(hostname)"
ping -V &> "$dir/ping-$(hostname)"
iperf --version &> "$dir/iperf-$(hostname)"
bash --version &> "$dir/bash-$(hostname)"
