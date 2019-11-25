#!/bin/bash

for i in {1..4}
do
  scp -r "vm$i":~/data/* ~/data/
done
