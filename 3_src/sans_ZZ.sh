#! /usr/bin/env bash
for f in *.pb; do
	#cat $f | tr -d 'ZZ' > ./NO_ZZ/"$f"
	cat $f #| tr -d 'ZZ'
	printf "\n"
done
echo echo "Done \(o°i°o)/"
