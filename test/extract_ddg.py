#! /usr/bin/env python

import os, sys

number_of_peptides = range(1,5)
list_of_snapshots = [750000, 770000, 790000, 810000, 830000, 850000, 890000, 910000, 930000, 950000, 970000]
list_of_residues = ['1THR']

cwd = os.getcwd()
for residue_file in list_of_residues:
    os.mkdir('ddg')
    os.chdir('ddg')
    res = open(residue_file, 'w')
    res.close
    os.chdir(cwd)


for peptide in number_of_peptides:
    #I'm thinking maybe open a file here that's per
    for snapshot in list_of_snapshots:
        for residue in list_of_residues:
            peptide,snapshot = str(peptide),str(snapshot)
            os.chdir(cwd+"/p"+peptide+"/"+snapshot+"ps/"+residue+"/extracted_elements")

            res = open(cwd+"/ddg/"+residue, 'w')
            #res.write() #gotta write the ddg to all of em

            #read delta g file
            #read in files for opt delta G calculation
            #need to implement a (delta G) - (opt delta G calculation)