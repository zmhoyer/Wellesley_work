#! /usr/bin/env python

import os, sys, subprocess

sim = range(1,5) 
number = [750000, 770000, 790000, 810000, 830000, 850000, 890000, 910000, 930000, 950000, 970000]


number_of_peptides = sim
list_of_snapshots = number


cwd = os.getcwd()
list_of_residues = residueName(cwd+"/"+str(number_of_peptides[0])+"/"+str(list_of_snapshots[0]))
for residue_file in list_of_residues:
    os.mkdir('ddg')
    os.chdir('ddg')
    res = open(residue_file, 'w')
    res.close
    os.chdir(cwd)


for peptide in number_of_peptides:
    #I'm thinking maybe open a file here that's per
    for snapshot in list_of_snapshots:
        peptide,snapshot = str(peptide),str(snapshot)
        list_of_residues = residueName(cwd+"/"+peptide+"/"+snapshot)
        for residue in list_of_residues:
            os.chdir(cwd+"/p"+peptide+"/"+snapshot+"ps/"+residue+"/extracted_elements")

            subprocess.Popen("/programs/bin/matlab -nojvm")

            res = open(cwd+"/ddg/"+residue, 'w')
            #res.write() #gotta write the ddg to all of em

            #read delta g file
            #read in files for opt delta G calculation
            #need to implement a (delta G) - (opt delta G calculation)