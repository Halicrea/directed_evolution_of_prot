#! /usr/bin/env bash

for f in ./PB_OUT/*.pb
do
    #while mapfile -t -n 5 ary && ((${#ary[@]})); do
    #	printf '%s\n' "${ary[@]}" 
    #	printf '%s\n' "${ary[@]}" > tempo.fasta
    	needle -asequence $f -sprotein1 -bsequence reference.pb -sprotein2 -outfile tempo.needle -auto
    	cat tempo.needle >> pairwise_test_2.needle
    	#printf '%s\n' "${ary[@]}"
    	#printf -- '--- SNIP ---\n'
    #done < Alignement_multiple.fasta
    #<(grep '>' Alignement_multiple.fasta -A 3)
done
