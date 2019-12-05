#!/bin/bash

# general installs
sudo apt-get -qq update -y
sudo apt-get -qq upgrade -y
sudo apt-get -qq install -y iperf traceroute

# install Julia
curl -O https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz
tar xf julia-1.2.0-linux-x86_64.tar.gz
rm julia-1.2.0-linux-x86_64.tar.gz
mv julia-1.2.0 ~/

# create data folder
mkdir -p ~/data/exp{0..13}

# configure ssh
rm -rf ~/.ssh
cp -r ~/l50-tests/ssh ~/.ssh
chmod -R 700 ~/.ssh
