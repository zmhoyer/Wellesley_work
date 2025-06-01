#!/usr/bin/env python

import time
import numpy as np
import pandas as pd
import xarray as xr
import io




#input file

output_name = 'bf2wt'

start_snapshot = 750000
end_snapshot = 1000000
interval = 2500
snapshot_extraction_range = range(start_snapshot,end_snapshot,interval)
print(snapshot_extraction_range)

#CRD specific info
atom_information = ['ATOM_number', 'RESIDUE_number', 'RESIDUE_name', 'ATOM_id', 'X_coordinate', 'Y_coordinate', 'Z_coordinate', 'SEGMENT_id', 'RESIDUE_ID', 'CHARGE/OTHER']
Colspaces = [(0, 5), (5, 10), (10, 16), (16, 20), (20, 30), (30, 40), (40, 50), (50, 52), (52, 61), (61, -1)]
Dtype = {'ATOM_number': int, 'RESIDUE_number': int, 'RESIDUE_name': str, 'ATOM_id': str, 'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float, 'SEGMENT_id': str, 'RESIDUE_ID': int, 'CHARGE/OTHER': float}
atom_number = []
for a in range(0,16430):
    b = a+1
    atom_number.append('Sim1')

pd.options.display.float_format = '{:,.5f}'.format #needed to get the for the proper precision of the coords


#Loading data

for peptide in 1:
    peptide = peptide+1

    for snapshot in snapshot_extraction_range:



        crd = open('initial_p'+peptide+'_memb'+snapshot+'.crd', 'r')
        start_time = time.time() 
        yikes = pd.read_fwf(input, 
                            colspecs=Colspaces,
                            header=None, 
                            dtype=Dtype, 
                            names=atom_information,
                            skiprows=3, 
                            index_col=False)
        yikes.index = atom_number
        print(yikes)
        print(f'--- {time.time() - start_time} seconds ---')







start_time = time.time() 
numby = yikes.to_numpy(na_value='')
np.savetxt('test.crd', numby, fmt='%5d%5d %-4s %-4s%10.5f%10.5f%10.5f %-4s %-4d%10.5f')
print(f'--- {time.time() - start_time} seconds ---')
test.close()
