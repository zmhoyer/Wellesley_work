#! /usr/bin/env python

import os,subprocess

sim = ['p1', 'p2'] 
number = ['750000ps', '770000ps']#, 790000, 810000, 830000, 850000, 890000, 910000, 930000, 950000, 970000]


number_of_peptides = sim
list_of_snapshots = number
list_of_residues = ['1THR', '2ALA']

cwd = os.getcwd()



#list_of_residues = residueName(cwd+"/"+str(number_of_peptides[0])+"/"+str(list_of_snapshots[0]))
os.mkdir('ddg')
residue_summary = open(cwd+"/ddg/residue_summary_all_peps.txt", 'w')
for residue_name in list_of_residues:
    os.chdir(cwd+'/ddg')
    os.mkdir(residue_name)
    residue_summary.write("{:<11}".format(residue_name))
    for peptide_file in number_of_peptides:
        res_per_pep = open(residue_name+"/"+residue_name+"_"+peptide_file+"_allsnapshots_ddgs.txt", 'w')
        res_per_pep.close
residue_summary.write("\n")
residue_summary.close()
os.chdir(cwd)



for peptide in number_of_peptides:
    for snapshot in list_of_snapshots:
        peptide,snapshot = str(peptide),str(snapshot)
        #list_of_residues = residueName(cwd+"/"+peptide+"/"+snapshot)
        for residue in list_of_residues:

                #unhardcode these
            with open(cwd+"/"+peptide+"/"+snapshot+"/"+residue+"/extracted_elements/deltaG_constraint_7.txt", 'r') as file:
                deltaG_1 = float(list(file)[0].strip())
                
            with open(cwd+"/"+peptide+"/"+snapshot+"/"+residue+"/extracted_elements/deltaG_constraint_6.txt", 'r') as file:
                deltaG_2 = float(list(file)[0].strip())

            delta_delta_gopt = deltaG_1 - deltaG_2

            res_sum = open(cwd+"/ddg/residue_summary_all_peps.txt", 'a')
            res_sum.write("{:<11.4f}".format(delta_delta_gopt))


            res_per_pep = open(cwd+"/ddg/"+residue+"/"+residue+"_"+peptide+"_allsnapshots_ddgs.txt", 'a')
            res_per_pep.write("{:<11.4f}\n".format(delta_delta_gopt))
            res_per_pep.close()

        res_sum.write("\n")
        res_sum.close()

