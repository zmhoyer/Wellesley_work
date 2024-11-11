#!/usr/bin/env python

# To use this file you need to do $conda activate iron
#this file is primarily used to test git and various other tools in the directory
# see if I can find a way to activate an environment from a script to streamline this process even more for Mala

#I'm going to replace this pretty soon so idk how much I'm actually doing here but meh shmeh


### still just testing junk

### testing to see if my obsidian git plugin is what's automatically pushing this git dir

#la de da da


import numpy as np
import pandas as pd
import xarray as xr


array_1D = np.linspace(0, 9.5, 20)
array_2D = np.reshape(array_1D, (4, 5))
# print(array_2D)
# print(array_2D.T)

a = np.arange(0, 5)
b = np.arange(5, 10)
# print(np.vstack((a, b)))
# print(np.hstack((a, b)))
# print(np.dstack((a, b)))
# print(np.column_stack((a,b)))
# print(np.vstack((a,b)).T)

row = [2,2,0,2]
col = [0,1,3,0]

print(array_2D[row, col])

input = str("initial_p1_memb750000.crd")
crd = open(input, 'r')

#big = np.array(crd) #does not work
#big2 = np.genfromtxt(input) #works and genfromtext can handle missing data. It places nan in place
#big3 = xr.open_dataset(input, engine=None) #need to use numpy genfromtxt first as xarray doesn't have intrinsic functionality for it

atom_number = range(1,16434)

atom_information = ["ATOM_number", "RESIDUE_number", "RESIDUE_name", "ATOM_id", "X_coordinate", "Y_coordinate", "Z_coordinate", "SEGMENT_id", "RESIDUE_ID", "CHARGE/OTHER"]


big4 = xr.DataArray(pd.read_fwf(input, widths=87689 ),coords=[atom_number,atom_information], dims=["atom_number", "atom_information"])

print(big4.coords)
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