#!/bin/bash

# Bootstraps vms 1-4 from vm0

for i in {1..4}
do
  scp -q -r ~/l50-tests "vm$i":~/
  ssh "vm$i" 'bash ~/l50-tests/setup.sh'
done
