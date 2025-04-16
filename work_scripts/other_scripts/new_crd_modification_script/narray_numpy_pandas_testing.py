#!/usr/bin/env python

import time
import numpy as np
import pandas as pd
import xarray as xr
import io




#input file
input1 = str('initial_p1_memb750000.crd')
input2 = str('initial_p1_memb752500.crd')
crd = open(input, 'r')
test = open('test.crd', 'w')

#CRD specific info
atom_information = ['ATOM_number', 'RESIDUE_number', 'RESIDUE_name', 'ATOM_id', 'X_coordinate', 'Y_coordinate', 'Z_coordinate', 'SEGMENT_id', 'RESIDUE_ID', 'CHARGE/OTHER']
Colspaces = [(0, 5), (5, 10), (10, 16), (16, 20), (20, 30), (30, 40), (40, 50), (50, 52), (52, 61), (61, -1)]
Dtype = {'ATOM_number': int, 'RESIDUE_number': int, 'RESIDUE_name': str, 'ATOM_id': str, 'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float, 'SEGMENT_id': str, 'RESIDUE_ID': int, 'CHARGE/OTHER': float}

pd.options.display.float_format = '{:,.5f}'.format #needed to get the for the proper precision of the coords
# sim_atom_information = ['X_coordinate', 'Y_coordinate', 'Z_coordinate']
# sim_Colspaces =  [(20, 30), (30, 40), (40, 50)]
# sim_Dtype = {'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float}


atom_number = []
for a in range(0,16430):
    b = a+1
    atom_number.append('Sim1')

# np.set_printoptions(floatmode='maxprec_equal')
# delim = [5,5,6,4,10,10,10,2,9,10]
# ball = np.genfromtxt(input, dtype=(int, int, 'S6', 'S4', float, float, float, 'S2', int, float),skip_header=3, delimiter=delim)
# ball_big4 = xr.DataArray(ball)
# print(ball_big4)

start_time = time.time() 


yikes = pd.read_fwf(input, 
                    colspecs=Colspaces,
                    header=None, 
                    dtype=Dtype, 
                    names=atom_information,
                    skiprows=3, 
                    index_col=False)

yikes.index = atom_number

# yikes = yikes.groupby(by=3286)

print(yikes)


# sim_big4 = xr.DataArray(yikes,
#                         coords=[atom_number,sim_atom_information], dims=['atom_number', 'atom_identifiers']
#                         )

print(f'--- {time.time() - start_time} seconds ---')



# xr.set_options(display_expand_data=True)
# float = sim_big4.astype(dtype=float)

# log = sim_big4[0][0]
# sim_big4 = sim_big4 - 0.00001
# print(sim_big4)

start_time = time.time() 

# format_dictionary = {'ATOM_number':'{:>5d}', 'RESIDUE_number': , 'RESIDUE_name': , 'ATOM_id': ,'X_coordinate': , 'Y_coordinate': , 'Z_coordinate': , 'SEGMENT_id': , 'RESIDUE_ID': , 'CHARGE/OTHER':  }
# format_dictionary = {'ATOM_number':'{:>5d}'.format, 'RESIDUE_number':'{:>5d}'.format, 'RESIDUE_name':' {:<4s}'.format, 'ATOM_id': ' {:<4s}'.format, 'X_coordinate':'{:>10.5f}'.format, 'Y_coordinate':'{:>10.5f}'.format, 'Z_coordinate':'{:>10.5f}'.format, 'SEGMENT_id':' {:<4s}'.format, 'RESIDUE_ID':' {:<4d}'.format, 'CHARGE/OTHER':'{:>10.5f}'.format}


# print_string = yikes.to_string(index=False,
#                                header=False,
                            #    formatters={'{:>5s}{:>5s} {:<4s} {:<4s}{:>10.5s}{:>10.5s}{:>10.5s} {:<4s} {:<4s}{:>10.5s}\n'.format('ATOM_number', 'RESIDUE_number', 'RESIDUE_name', 'ATOM_id', 'X_coordinate', 'Y_coordinate', 'Z_coordinate', 'SEGMENT_id', 'RESIDUE_ID', 'CHARGE/OTHER')}
                            #    formatters=['{:>5s}'.format('ATOM_number'), '{:>5s}'.format('RESIDUE_number'), ' {:<4s}'.format('RESIDUE_name'), ' {:<4s}'.format('ATOM_id'), '{:>10.5s}'.format('X_coordinate'), '{:>10.5s}'.format('Y_coordinate'), '{:>10.5s} '.format('Z_coordinate'), ' {:<4s}'.format('SEGMENT_id'), ' {:<4s}'.format('RESIDUE_ID'), '{:>10.5s}\n'.format('CHARGE/OTHER')] 
                            #    formatters=format_dictionary,
                            #    na_rep=''
                            #    )


numby = yikes.to_numpy(na_value='')
np.savetxt('test.crd', numby, fmt='%5d%5d %-4s %-4s%10.5f%10.5f%10.5f %-4s %-4d%10.5f')
print(numby)


# test.write(print_string)
print(f'--- {time.time() - start_time} seconds ---')


test.close()




# '%-5d%-5d %4s %4s%-10.5f%-10.5f%-10.5f %4s %4d%-10.5f\n'
# '{:>5d}{:>5d} {:<4s} {:<4s}{:>10.5f}{:>10.5f}{:>10.5f} {:<4s} {:<4d}{:>10.5f}\n' 
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
                yield '{:>5d}{:>5d} {:<4s} {:<4s}{:>10.5f}{:>10.5f}{:>10.5f} {:<4s} {:<4d}{:>10.5f}\n'.format(self.atom_id, self.res_id, self.res_type, self.atom_type, self.x_pos, self.y_pos, self.z_pos, self.chain_name, self.chain_id, self.charge)
'''