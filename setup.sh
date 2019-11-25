#!/bin/bash

# general installs
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y iperf traceroute

# install Julia
curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz
tar xf julia-1.2.0-linux-x86_64.tar.gz
rm julia-1.2.0-linux-x86_64.tar.gz

# create data folder
mkdir ~/data

# configure ssh
cp -r ~/l50-tests/ssh ~/.ssh
