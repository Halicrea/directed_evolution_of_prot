#! /usr/bin/env bash
for file in ./PB_IN/*; do
    perl dssp_to_pb_tor_rmsda.pl "$file" ./PB_OUT/
    echo $(cat)    
done
echo "Done \(o°i°o)/"
