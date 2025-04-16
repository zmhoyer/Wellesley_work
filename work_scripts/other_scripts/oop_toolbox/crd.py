#!/usr/bin/env python

'''
I'm using numpy in this script as the idea is to create a simulation object that gets
progressively bigger the more class instances that are called. Using a large
n-dimensional array should be easier with numpy.

Game plan

Simulation class 
- creates initial matrix

subclasses
- children to Simulation class or other children classes
- Merges into the initial matrix

functions or object classes?
Classes to create nessecary information with specific classes as needed?
Or big class with many functions to work on all files




'''
import numpy as np
import pandas as pd
import argparse
import os
import time


### Arguments
parser = argparse.ArgumentParser()
#need to be specified when calling in the argument
parser.add_argument('-l', '--length_of_peptide', help='This is the length of the peptide in atom count so the peptide can be indexed properly. Will change with mutants', required=True, type=int) #366 for wt BFII as an example
parser.add_argument('-o', '--output', help='This is the final output name that is desired. Something like bf2wt.crd is conscise and accurate if youre working with bf2 wildtype', required=True, type=str)
#should confirm these but they can stay unchanged
parser.add_argument('-n', '--num_peptides_or_simulations', help='number of peptides in specified membrane simulation or number of DNA simulations being analyzed at once', required=False, default= 4, type=int)
parser.add_argument('-b', '--Beg_time', help='Start of the time frame of interest in ps', required=False, default= 750000, type=int)
parser.add_argument('-e', '--End_time', help='End of the time frame of interest in ps', required=False, default= 1000000, type=int)
parser.add_argument('-dt', '--interval', help='Interval of frames outputted in ps', required=False, default= 2500, type=int)
#not required but can be changed if needed/wanted
args = parser.parse_args()


### Variable creation
cwd = os.getcwd()
start,end,interval = int(args.Beg_time),int(args.End_time),int(args.interval)

number_of_frames = int((end-start)/interval)+1
number_of_frames_iterator = range(number_of_frames)

number_of_simulations_or_peptides = args.num_peptides_or_simulations
number_of_simulations_or_peptides_iterator = range(number_of_simulations_or_peptides)

atom_information = ['ATOM_number', 'RESIDUE_number', 'RESIDUE_name', 'ATOM_id', 'X_coordinate', 'Y_coordinate', 'Z_coordinate', 'SEGMENT_id', 'RESIDUE_ID', 'CHARGE/OTHER']
Colspaces = [(0, 5), (5, 10), (10, 16), (16, 20), (20, 30), (30, 40), (40, 50), (50, 52), (52, 61), (61, -1)]
Dtype = {'ATOM_number': int, 'RESIDUE_number': int, 'RESIDUE_name': str, 'ATOM_id': str, 'X_coordinate': float, 'Y_coordinate': float, 'Z_coordinate': float, 'SEGMENT_id': str, 'RESIDUE_ID': int, 'CHARGE/OTHER': float}

all_crd_header_list = []
all_crd_data_frames = []
key_list = []


### File reading and creation
for simulation in number_of_simulations_or_peptides_iterator:
    simulation_string = str(simulation+1)

    for frame_number in number_of_frames_iterator:
        frame = str(start+(frame_number*interval))
        crd = str(cwd+'/p'+simulation_string+'/'+frame+'ps/initial_p'+simulation_string+'_memb'+frame+'.crd')
        total_frame_number = frame_number+1+(simulation*(number_of_frames))

        with open(crd) as crd_lines: #header
            buffer_crd_header = []

            for index, line in enumerate(crd_lines):
                if len(line.split()) == 1 and line.split()[0] != '*':
                    header_length = index+1
                    atom_number = int(line.split()[0])

                elif line.split()[0] == '*':
                    header_length = index+1
                    buffer_crd_header.append(line)

                else:
                    all_crd_header_list.append("".join(buffer_crd_header)+str(atom_number))
                    break

        ### Object creation and concatanation
        single_crd = pd.read_fwf(crd, 
                            colspecs=Colspaces,
                            header=None, 
                            dtype=Dtype, 
                            names=atom_information,
                            skiprows=header_length, 
                            index_col=False,
                            )
        

        all_crd_data_frames.append(single_crd)
        key_list.append('frame'+str(total_frame_number))
concat_data = pd.concat(all_crd_data_frames, keys=key_list,) # The keys argument represents hierarchical/multi indexing # https://pandas.pydata.org/docs/user_guide/advanced.html

### CRD modification
start_time = time.time() 


x_max = concat_data['X_coordinate'].max(axis=None)
y_max = concat_data['Y_coordinate'].max(axis=None)
z_max = concat_data['Z_coordinate'].max(axis=None)
tot_max = concat_data[['X_coordinate', 'Y_coordinate', 'Z_coordinate']].max(axis=None)
# print(x_max,y_max,z_max,tot_max)x
print(concat_data['ATOM_id'].str.len())
    #figure out how to do an if than statement and then split and move
    #https://stackoverflow.com/questions/23307301/replacing-column-values-in-a-pandas-dataframe
# "".join(concat_data['ATOM_id'].split()[-1][0][1][2])

print(concat_data['ATOM_id'].str.strip().str.split(''))
concat_data['ATOM_id'] = np.where(len(concat_data['ATOM_id'].str.len()) == 4, "".join([concat_data['ATOM_id'].str.split('').str[-2],concat_data['ATOM_id'].str.split('').str[1],concat_data['ATOM_id'].str.split('').str[2],concat_data['ATOM_id'].str.split('').str[-3]]), concat_data['ATOM_id'])
# and where first alphneumeric is a digit

print(f'--- {time.time() - start_time} seconds ---')
### new crd creation
for simulation in number_of_simulations_or_peptides_iterator:
    simulation_string = str(simulation+1)

    for frame_number in number_of_frames_iterator:
        frame = str(start+(frame_number*interval))
        with open(cwd+'/p'+simulation_string+'/'+frame+'ps/'+args.output, 'w') as output_crd:
            total_frame_number = frame_number+1+(simulation*(number_of_frames))
        
            numpy_array = concat_data.loc[('frame'+str(total_frame_number))].to_numpy(na_value='')
            np.savetxt(output_crd, numpy_array, fmt='%5d%5d %-4s %-4s%10.5f%10.5f%10.5f %-4s %-4d%10.5f',header=all_crd_header_list[total_frame_number-1], comments='')


### Housekeeping
