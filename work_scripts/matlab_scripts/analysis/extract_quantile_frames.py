#!/usr/bin/env python

import os
import csv

import MDAnalysis as mda
from MDAnalysis.tests.datafiles import PSF, DCD, GRO, XTC
from MDAnalysis.analysis import diffusionmap, align, rms
import warnings
# suppress some MDAnalysis warnings about PSF files
warnings.filterwarnings('ignore')
from matplotlib import pyplot as plt
import numpy as np
print("Using MDAnalysis version", mda.__version__)

# traj = "/Users/zak/wellesley/work_scripts/matlab_scripts/analysis/characteristic_structures/wt/characteristic_trajectory.pdb"
# top = "/Users/zak/wellesley/work_scripts/matlab_scripts/analysis/characteristic_structures/wt/characteristic_trajectory.pdb" 
traj = "/Users/zak/wellesley/scp/wt_sim5/1p_modified_movie.pdb"
top = "/Users/zak/wellesley/scp/wt_sim5/1p_modified_movie.pdb" 

my_pdb = mda.Universe(top,traj)
print(my_pdb)
print(len(my_pdb.trajectory))
print(my_pdb.residues)

ref = my_pdb.trajectory[0]
aligner = align.AlignTraj(my_pdb, my_pdb, select='name CA',in_memory=True).run()
matrix = diffusionmap.DistanceMatrix(my_pdb, select='name CA').run()
plt.imshow(matrix.dist_matrix, cmap='viridis')
plt.gca().invert_yaxis()
plt.xlabel('Frame')
plt.ylabel('Frame')
plt.colorbar(label=r'RMSD ($\AA$)')
plt.savefig("pairwise_test.pdf")

#need to make it acutally update
print(len(my_pdb.trajectory))
updating_lipid_selection = my_pdb.select_atoms("((resname POE or resname POG) and byres (cyzone 5 45 -45 protein))", updating=True)
updating_cog = updating_lipid_selection.center_of_geometry()
print(updating_lipid_selection)
print(len(updating_lipid_selection))
print(updating_cog)
print(updating_cog[2])

# %matplotlib inline

'''
rootdir = '/Users/zak/wellesley/work_scripts/matlab_scripts/analysis/characteristic_structures'

for subdir, dirs, files in os.walk(rootdir):
    for file in files:
        if file == 'quantile_frames.csv':
            with open(os.path.join(subdir, file), 'r') as quantile_frame:
                quantile_list = csv.DictReader(quantile_frame)

                with open(subdir+'/characteristic_trajectory.pdb', 'w') as full_trajectory:
                    frame = 1

                    for quant_lines in quantile_list:
                        with open('/Users/zak/wellesley/scp/'+quant_lines['simulation']+'/'+quant_lines['peptide']+'_modified_movie.pdb', 'r') as full_pdb:
                            write = False

                            for pdb_line in full_pdb:
                                split_lines = pdb_line.split()

                                if (split_lines[0] == "MODEL" and split_lines[1] == quant_lines['frame_number']):
                                    quartile_frame = open(subdir+'/quantile_'+quant_lines['representative_percentage']+'.pdb','w')
                                    quartile_frame.write('REMARK   simulation - '+quant_lines['simulation']+'\n')
                                    quartile_frame.write('REMARK   peptide - '+quant_lines['peptide']+'\n')
                                    quartile_frame.write('REMARK   time - '+quant_lines['time']+'\n')
                                    quartile_frame.write('REMARK   frame_number - '+quant_lines['frame_number']+'\n')
                                    quartile_frame.write('REMARK   representative_percentage - '+quant_lines['representative_percentage']+'\n')
                                    write = True

                                if write == True:
                                    if split_lines[0] == "MODEL":
                                        full_trajectory.write("MODEL "+str(frame)+"\n")
                                        frame+=1
                                    elif ((len(split_lines) > 1) and (split_lines[3] == "POE" or split_lines[3] == "POG" or split_lines[3] == "DUM")):
                                        pass
                                    else:
                                        full_trajectory.write(pdb_line)

                                    quartile_frame.write(pdb_line)

                                    if split_lines[0] == 'ENDMDL':
                                        quartile_frame.write(pdb_line)
                                        quartile_frame.close()
                                        break
'''