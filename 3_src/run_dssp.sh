#!/usr/bin/env bash

# introduire le fichier .pdb
homologue=$1
#sortie=$(echo $1 | sed 's/.pdb/.sansZ/g')
PB_sansZZ=$(echo $1 | sed 's/.pdb/.sansZ/g')
separator="dssp_separator.pl"
dssp_to_pb="dssp_to_pb_tor_rmsda.pl"
fichier_final=$(echo $1 | sed 's/.pdb/.alignementPB/g')
fichier_global=$(echo $1 | sed 's/.pdb/.alignementPBG/g')
#Le fichier de référence que j'ai choisit. Mais il est possible de le changer si vous voulez faire avec une autre séquence. 
reference=$(cat 1A4F.sansZ)
folder="/home/jyglyweg/Desktop/homologues/folder_pb/"


# creer un fichier .dssp avec le même nom que le fichier pdb
output=$(echo $1 | sed 's/pdb/dssp/g')

#run dssp et renvois le fichier de sortie dans un fichier .dssp
#ATTENTION : il faut remplacer par le moyen de lancer dssp sur la machine sur laquelle vous êtes !!!
dssp $1 > $output

perl $separator ./$output ./

A="_A" # permet de cibler une chaine splité par separator
pb=".pb"
#insert _A avant le .dssp dans la chaine pour le 2nd script perl
chaine_A=$(echo $output | sed "s/\./$A./g")

perl $dssp_to_pb ./$chaine_A ./

#crée une variable avec l'extension ..._Adssp.pb pour pouvoir l'utiliser plus tard.
temp="$chaine_A$pb" 
#cat $temp

#Coupe les ZZ dans la chaine pb générée par le script dssp_to_pb_tor_rmsda
chaine_pb=$(cat $temp| sed 's/ZZ//g')

#range la chaine dans un fichier séparé avec une extension .sansZ
echo $chaine_pb > $PB_sansZZ 

#Compte la taille de la chaine de protein block de la reference et de l'homologue
len_reference=${#reference}
len_homologue=${#chaine_pb}

#Ligne pas necessaire affiche la taille des deux chaines.
echo $len_homologue
echo $len_reference

#Pour lancer PB align il faut chaine ref, chaine homo, len ref homo -5 fichier sortie

./pbalign_local $reference $chaine_pb $len_reference $len_homologue -5 $fichier_final
./pbalign_global $reference $chaine_pb $len_reference $len_homologue -5 $fichier_global

#Normalement pas besoin de creer le folder sinon creer le truc avec un If pour eviter les erreur
#mkdir $folder

mv $fichier_final $folder
mv $fichier_global $folder
