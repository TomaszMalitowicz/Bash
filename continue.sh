#!/bin/bash

for i in {0..20}; do
    if [ $i -eq 10 ]; then
        continue;
    fi
    echo "Element $i"
done