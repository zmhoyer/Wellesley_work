#!/usr/bin/env python

import time
import numpy as np
import pandas as pd
import xarray as xr


# array_1D = np.linspace(0, 9.5, 20)
# array_2D = np.reshape(array_1D, (4, 5))
# # print(array_2D)
# # print(array_2D.T)

# a = np.arange(0, 5)
# b = np.arange(5, 10)
# # print(np.vstack((a, b)))
# # print(np.hstack((a, b)))
# # print(np.dstack((a, b)))
# # print(np.column_stack((a,b)))
# # print(np.vstack((a,b)).T)

# row = [2,2,0,2]
# col = [0,1,3,0]

# print(array_2D[row, col])


#big = np.array(crd) #does not work
#big2 = np.genfromtxt(input) #works and genfromtext can handle missing data. It places nan in place
#big3 = xr.open_dataset(input, engine=None) #need to use numpy genfromtxt first as xarray doesn't have intrinsic functionality for it

#atom_number = range(1,16434)





#input file
input = str("initial_p1_memb750000.crd")
crd = open(input, 'r')

#CRD specific info
atom_information = ["ATOM_number", "RESIDUE_number", "RESIDUE_name", "ATOM_id", "X_coordinate", "Y_coordinate", "Z_coordinate", "SEGMENT_id", "RESIDUE_ID", "CHARGE/OTHER"]
Colspaces = [(0, 5), (5, 10), (10, 16), (16, 20), (20, 30), (30, 40), (40, 50), (50, 52), (52, 61), (61, -1)]
Dtype = {'ATOM_number': int, 'RESIDUE_number': int, 'RESIDUE_name': str, 'ATOM_id': str, 'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float, 'SEGMENT_id': str, 'RESIDUE_ID': int, 'CHARGE/OTHER': float}

pd.options.display.float_format = '{:,.5f}'.format #needed to get the for the proper precision of the coords

#I used pandas and then xarray as xarray didn't have any good fixed width options.

start_time = time.time() 
big4 = xr.DataArray(pd.read_fwf(input, 
                                colspecs=Colspaces, 
                                header=None, 
                                names=atom_information, 
                                dtype=Dtype, 
                                skiprows=3, 
                                index_col=False), 
                                    dims=["atom_number", "atom_information"]) #,coords=[atom_number,atom_information]
print(f"--- {time.time() - start_time} seconds ---")







sim_atom_information = ["X_coordinate", "Y_coordinate", "Z_coordinate"]
sim_Colspaces =  [(20, 30), (30, 40), (40, 50)]
sim_Dtype = {'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float}

start_time = time.time() 
sim_big4 = xr.DataArray(pd.read_fwf(input, 
                                colspecs=sim_Colspaces, 
                                header=None, 
                                names=sim_atom_information, 
                                dtype=sim_Dtype, 
                                skiprows=3, 
                                index_col=False), 
                                    dims=["atom_number", "atom_information"]) #,coords=[atom_number,atom_information]
print(f"--- {time.time() - start_time} seconds ---")



print(big4)
print(sim_big4)
crd.close()








'''
                self.atom_id = int(line[:5].strip())
                self.res_id = int(line[5:10].strip())
                self.res_type = line[10:16].strip()
                self.atom_type = line[16:20].strip()
                self.x_pos = float(line[21:30].strip())
                self.y_pos = float(line[31:40].strip())
                self.z_pos = float(line[41:50].strip())
                self.chain_name = line[51:52].strip()
                self.chain_id = int(line[56:61].strip())
                self.charge = float(line[62:].strip()) #till 70

                #variable function thing

                self.called_method(*args)

                #format output to crd style
                #return value
                yield "{:>5d}{:>5d} {:<4s} {:<4s}{:>10.5f}{:>10.5f}{:>10.5f} {:<4s} {:<4d}{:>10.5f}\n".format(self.atom_id, self.res_id, self.res_type, self.atom_type, self.x_pos, self.y_pos, self.z_pos, self.chain_name, self.chain_id, self.charge)
'''