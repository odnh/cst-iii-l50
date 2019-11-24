#!/bin/bash

# Bootstraps vms 1-4 from vm 0

for i in {1..4}
do
  scp -r ~/l50-tests "vm$i":~/
  ssh "vm$i" '~/l50-tests/setup.sh'
done
