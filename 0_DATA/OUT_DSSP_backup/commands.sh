#!/usr/bin/env bash
######################################
#		26/01/2023
#		By Elyna Bouchereau
######################################

## Structure 2XIW to PB
dssp -i IN_DSSP/2xiw.pdb -o OUT_DSSP/2xiw.dssp   
perl ./SCRIPTS/dssp_separator.pl ./OUT_DSSP/2xiw.dssp ./OUT_DSSP/
perl ./SCRIPTS/dssp_to_pb_tor_rmsda.pl ./OUT_DSSP/2xiw_A.dssp ./OUT_DSSP/
perl ./SCRIPTS/dssp_to_pb_tor_rmsda.pl ./OUT_DSSP/2xiw_B.dssp ./OUT_DSSP/

## FORSA
./SCRIPTS/FORSA/forsa_global IN_DSSP/rcsb_pdb_2XIW.fasta OUT_DSSP/2xiw_A.dssp.pb -5 > align_forsa_global_2XIW_A.txt


