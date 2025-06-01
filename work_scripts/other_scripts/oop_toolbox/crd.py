#!/usr/bin/env python

import numpy as np
import pandas as pd
import argparse
import os
import time
import pathlib

# Copy this script with the submit_crd_extraction_and_modification.sh to the directory of the trajectory, itps, and tpr. 
# Run the submit script. Output will be in a directory called p1 up to however many peptides you have.

################################ 
parser = argparse.ArgumentParser()
parser.add_argument('-o', '--output', help='This is the final output name that will all modified crds will have. Something like bf2wt.crd is conscise and accurate if youre working with bf2 wildtype', required=True, type=str)
parser.add_argument('-pi', '--peptide_itp_file', help='This is the itp corresponding to a single peptide. Used to set charge and stuff. It cannot be an itp file with all four peptides. I dont think this will be an issue but if it is take out all but one peptide from the itp', required=True)
parser.add_argument('-oi', '--other_itp_file', nargs='*', help='feed all the itps in here corresponding to other molecules used for charge optimization. DNA, Lipids, somethign else?', required=True)
parser.add_argument('-ob', '--original_box_size', help='This is the box size in angstroms that was specified during the set up of the simulation. Put it in xyz format (e.g. 60 60 100)', required=True, type=int, nargs='+')
parser.add_argument('-p', '--dummy_padding_distance', help='This is the padding distance added by the dummy atoms. This padding distance is halved and added along the box vector.', required=False, type=int, default=10)
parser.add_argument('-n', '--num_peptides', help='number of peptides in a membrane or DNA simulation', required=False, default= 4, type=int)
parser.add_argument('-b', '--Beg_time', help='Start of the time snapshot of interest in ps', required=False, default= 750000, type=int)
parser.add_argument('-e', '--End_time', help='End of the time snapshot of interest in ps', required=False, default= 1000000, type=int)
parser.add_argument('-dt', '--interval', help='Interval of snapshots outputted in ps', required=False, default= 2500, type=int)
#will need an if membrane flag
args = parser.parse_args()



# Files
# Settings

# ################################

# #log file so everything isn't output to consol and you can check it out later
# log = open("snapshot_extraction_log.txt", 'w')
# log.write("# This file is a log of the CRD_extraction_and_modification.py script\n# It outputs the gromacs commands and inputs to this file for future reference\n# All gromacs commands are seperated by the corresponding CRD name.\n\n\n\n")
# log.flush() #Not sure why this is needed but stack overflow person said so https://stackoverflow.com/questions/7389158/append-subprocess-popen-output-to-file

# #error log file so everything isn't output to consol and you can check it out later
# err_log = open("snapshot_extraction_error_log.txt", 'w')
# err_log.write("# This file is a log of the CRD_extraction_and_modification.py script errors\n# It outputs the gromacs commands and inputs to this file for troubleshooting\n\n\n\n\n")
# err_log.flush() #Not sure why this is needed but stack overflow person said so https://stackoverflow.com/questions/7389158/append-subprocess-popen-output-to-file

# cwd = os.getcwd()
# path_that_called_script = pathlib.Path(__file__).resolve(strict=True).parent
# log.write("---Paths---\nPath To Script: "+str(path_that_called_script)+"/"+parser.prog+"\nCurrent Working Directory: "+cwd+"\n---Arguments---\n")
# err_log.write("---Paths---\nPath To Script: "+str(path_that_called_script)+"/"+parser.prog+"\nCurrent Working Directory: "+cwd+"\n---Arguments---\n")
# for arg in vars(args):
#     log.write(arg+": "+str(getattr(args, arg))+"\n")
#     err_log.write(arg+": "+str(getattr(args, arg))+"\n") 
# log.write("\n\n\n\n")
# err_log.write("\n\n\n\n")

# ################################

# ### Error processing function
# def error_confirmation(output, errors, subprocess_name):
#     loggy = output.decode('utf-8').splitlines()
#     dog = errors.decode('utf-8').splitlines()

#     if subprocess_name.returncode == 0: 
#         for line in loggy:
#             log.write(line+"\n")
#         for line in dog:
#             log.write(line+"\n")
#     else:
#         for line in loggy:
#             err_log.write(line+"\n")
#         for line in dog:
#             err_log.write(line+"\n"

# ################################
start_time = time.time()



### Variable creation
cwd = os.getcwd()
start,end,interval = int(args.Beg_time),int(args.End_time),int(args.interval)
number_of_snapshots = int((end-start)/interval)+1
number_of_snapshots_iterator = range(number_of_snapshots)
number_of_simulations_or_peptides = args.num_peptides
number_of_simulations_or_peptides_iterator = range(number_of_simulations_or_peptides)

box_x,box_y,box_z = args.original_box_size
padding_distance = args.dummy_padding_distance












### File reading and creation

#Creating a list of itps
peptide_itp_file = args.peptide_itp_file
peptide_name = str(peptide_itp_file).split('.')[0]
other_itp_file = args.other_itp_file
if type(other_itp_file) == list and type(peptide_itp_file) == str:
    list_of_itps = other_itp_file
    list_of_itps.append(peptide_itp_file)
elif type(other_itp_file) == str and type(peptide_itp_file) == str:
    list_of_itps = [peptide_itp_file, other_itp_file]
elif type(peptide_itp_file) != str:
    print("Did you mean to include multiple itps in the peptide itp flag? There should only be one unless you have a simulation with two peptides of different amino acid sequences.")
    exit()
    #add functionality for appending peps

#Reading in itp files
itp_atom_information = ['ATOM_number','ATOM_type','RESIDUE_number','RESIDUE_name','ATOM_id','CGNR','CHARGE','MASS']
itp_Dtype = {'ATOM_number':int, 'ATOM_type':str,'RESIDUE_number':int, 'RESIDUE_name':str, 'ATOM_id':str,'CGNR':int, 'CHARGE':float, 'MASS':float}
all_itps_list = []
list_of_itp_names = []
write_portion = False #bool for when to write itp lines to itp buffer file

for itp in list_of_itps:
    with open(itp) as itp_lines:
        itp_buffer_name = 'itp_buffer.txt' #can't read in the itps the same way as a crd as they're free form

        with open(itp_buffer_name,'w') as itp_buffer:

            for line in itp_lines:

                if line == '[ atoms ]\n':
                    write_portion = True
                        
                elif line == '[ bonds ]\n':
                    write_portion = False 
                    break

                elif write_portion == True:
                    itp_buffer.write(line)
                
                else:
                    pass


    single_itp = pd.read_table(itp_buffer_name, 
                        sep=r'\s+',
                        header=None, 
                        dtype=itp_Dtype, 
                        names=itp_atom_information, 
                        index_col=False,
                        comment=';',
                        skip_blank_lines=True
                        )
    all_itps_list.append(single_itp)
    list_of_itp_names.append(str(itp).split('.')[0]) 

# setting up the itp dataframe
all_itps_data = pd.concat(all_itps_list, keys=list_of_itp_names, names=['itps','Atoms'])
all_itps_data['Residues'] = all_itps_data['RESIDUE_number']
all_itps_data.set_index('Residues', append=True, inplace=True)
all_itps_data = all_itps_data.reorder_levels(['itps','Residues','Atoms'])
print("\n\nItp Object:\n\n",all_itps_data)
itp_dictionary_groupby_object = all_itps_data.groupby(level=[['itps','Residues']],sort=False, as_index=False, group_keys=False) #essentially an iterable of the itps
itp_residue_dictionary_groupby_object = all_itps_data.groupby(level=[['itps','Residues']],sort=False, as_index=False, group_keys=False) #essentially an iterable of the itps but with the peptide split into residues 

length_of_peptide = len(all_itps_data.loc[(peptide_name),])



#CRD information


crd_atom_information = ['ATOM_number', 'RESIDUE_number', 'RESIDUE_name', 'ATOM_id', 'X_coordinate', 'Y_coordinate', 'Z_coordinate', 'SEGMENT_id', 'RESIDUE_ID', 'CHARGE/OTHER']
crd_Colspaces = [(0, 5), (5, 10), (10, 16), (16, 20), (20, 30), (30, 40), (40, 50), (50, 52), (52, 61), (61, -1)]
crd_Dtype = {'ATOM_number':int, 'RESIDUE_number':int, 'RESIDUE_name':str, 'ATOM_id':str, 'X_coordinate':float, 'Y_coordinate':float, 'Z_coordinate':float, 'SEGMENT_id':str, 'RESIDUE_ID':int, 'CHARGE/OTHER':float}

all_crd_header_list = []
all_crds_list = []
List_of_snapshots_numbers = []


for simulation_number in number_of_simulations_or_peptides_iterator:
    simulation_string = str(simulation_number+1)

    for snapshot_number in number_of_snapshots_iterator:
        snapshot = str(start+(snapshot_number*interval))
        crd = str(cwd+'/p'+simulation_string+'/'+snapshot+'ps/initial_p'+simulation_string+'_memb'+snapshot+'.crd')
        total_snapshot_number = snapshot_number+1+(simulation_number*(number_of_snapshots))

        with open(crd) as crd_lines: #header
            buffer_crd_header = []

            for index, line in enumerate(crd_lines): # A quick read of the header information and comments. Doesn't read through the whole crd
                if len(line.split()) == 1 and line.split()[0] != '*':
                    header_length = index+1
                    atom_number = int(line.split()[0])+2 #adding two for the dummy atoms

                elif line.split()[0] == '*':
                    header_length = index+1
                    buffer_crd_header.append(line)

                else:
                    all_crd_header_list.append("".join(buffer_crd_header)+str(atom_number))
                    break

        ### Object creation and concatanation
        single_crd = pd.read_fwf(crd, 
                            colspecs=crd_Colspaces,
                            header=None, 
                            dtype=crd_Dtype, 
                            names=crd_atom_information,
                            skiprows=header_length, 
                            index_col=False,
                            )
        

        all_crds_list.append(single_crd)
        List_of_snapshots_numbers.append('Snapshot_'+str(total_snapshot_number))

# setting up the crd dataframe
all_crds_datasnapshot = pd.concat(all_crds_list, keys=List_of_snapshots_numbers, names=['Snapshots','Atoms']) # The keys argument represents hierarchical/multi indexing # https://pandas.pydata.org/docs/user_guide/advanced.html
all_crds_datasnapshot['Residues'] = all_crds_datasnapshot['RESIDUE_number']
all_crds_datasnapshot.set_index('Residues', append=True, inplace=True)
all_crds_datasnapshot = all_crds_datasnapshot.reorder_levels(['Snapshots','Residues','Atoms'])
print("To get a sense of the all_crds_datasnapshot object:\n\n",all_crds_datasnapshot)












### CRD modification

#changing atom id order
all_crds_datasnapshot['ATOM_id'].mask((all_crds_datasnapshot['ATOM_id'].str.len() == 4) & (all_crds_datasnapshot['ATOM_id'].str.match(r"^[1-9]")), #selecting all atom ids with 4 characters and a number to start with. Sets their bool values to False
                                  other = all_crds_datasnapshot['ATOM_id'].str[1:2]+all_crds_datasnapshot['ATOM_id'].str[2:3]+all_crds_datasnapshot['ATOM_id'].str[3:]+all_crds_datasnapshot['ATOM_id'].str[0:1], # rearranging the letters/numbers for condition == False
                                  inplace=True) # so you don't have to make a new datasnapshot object



# Rechaining - will mess up if you have a receptor molecule not listed here. If that's the case, follow the pattern and add it to the mask and where command
all_crds_datasnapshot['SEGMENT_id'] = all_crds_datasnapshot['SEGMENT_id'].where((all_crds_datasnapshot['RESIDUE_name'] == 'POP') | (all_crds_datasnapshot['RESIDUE_name'] == 'POPE') | (all_crds_datasnapshot['RESIDUE_name'] == 'POPG') | (all_crds_datasnapshot['RESIDUE_name'] == 'DA') | (all_crds_datasnapshot['RESIDUE_name'] == 'DG') | (all_crds_datasnapshot['RESIDUE_name'] == 'DC') | (all_crds_datasnapshot['RESIDUE_name'] == 'DT'), other='L', axis=0) #where true, keep value
all_crds_datasnapshot['SEGMENT_id'] = all_crds_datasnapshot['SEGMENT_id'].mask((all_crds_datasnapshot['RESIDUE_name'] == 'POP') | (all_crds_datasnapshot['RESIDUE_name'] == 'POPE') | (all_crds_datasnapshot['RESIDUE_name'] == 'POPG') | (all_crds_datasnapshot['RESIDUE_name'] == 'DA') | (all_crds_datasnapshot['RESIDUE_name'] == 'DG') | (all_crds_datasnapshot['RESIDUE_name'] == 'DC') | (all_crds_datasnapshot['RESIDUE_name'] == 'DT'), other='R', axis=0) #where true, replace value



# pope and popg renaming his too
start_time_2 = time.time()

def rename(groupby_crd_dataframe, itp_dictionary_groupby_object): #sets the new index with the correct snapshot and atom number. I could not find a way to reduce the code here but I'm sure I'm missing something.

    for name, current_itp_in_groupby_object in itp_dictionary_groupby_object:
        # if len(current_itp_in_groupby_object) == len(groupby_crd_dataframe):
        #     current_groupby_itp_name = str(current_itp_in_groupby_object['RESIDUE_name'].iloc[0])
        #     groupby_crd_dataframe['RESIDUE_name'] = groupby_crd_dataframe['ATOM_id'].reset_index(drop=True).eq(current_itp_in_groupby_object['ATOM_id'].reset_index(drop=True)).map({True:current_groupby_itp_name}).values
        
        if (len(current_itp_in_groupby_object) == len(groupby_crd_dataframe)) and (groupby_crd_dataframe['ATOM_id'].reset_index(drop=True).eq(current_itp_in_groupby_object['ATOM_id'].reset_index(drop=True)).all() == True):
           current_groupby_itp_name = str(current_itp_in_groupby_object['RESIDUE_name'].iloc[0]) 
           groupby_crd_dataframe['RESIDUE_name'] = current_groupby_itp_name 
            
    return groupby_crd_dataframe
all_crds_datasnapshot = all_crds_datasnapshot.groupby(level=[['Snapshots','Residues']],sort=False, as_index=False, group_keys=False).apply(lambda crd_groupby_object: rename(crd_groupby_object,itp_dictionary_groupby_object))
print(f'--- {time.time() - start_time_2} seconds ---')



# charge fixing
start_time_3 = time.time()
def charge_fixin(groupby_crd_dataframe, itp_residue_dictionary_groupby_object): #sets the new index with the correct snapshot and atom number. I could not find a way to reduce the code here but I'm sure I'm missing something.

    for name, current_itp_residue_in_groupby_object in itp_residue_dictionary_groupby_object:
        if (len(current_itp_residue_in_groupby_object) == len(groupby_crd_dataframe)) and (groupby_crd_dataframe['ATOM_id'].reset_index(drop=True).eq(current_itp_residue_in_groupby_object['ATOM_id'].reset_index(drop=True)).all() == True):
           groupby_crd_dataframe['CHARGE/OTHER'] = current_itp_residue_in_groupby_object['CHARGE'].values 
            
    return groupby_crd_dataframe
all_crds_datasnapshot = all_crds_datasnapshot.groupby(level=[['Snapshots','Residues']],sort=False, as_index=False, group_keys=False).apply(lambda crd_groupby_object: charge_fixin(crd_groupby_object,itp_residue_dictionary_groupby_object))
print(f'--- {time.time() - start_time_3} seconds ---')



# translation to zero
half_simulation_box_lengths = (all_crds_datasnapshot[['X_coordinate','Y_coordinate','Z_coordinate']].groupby(level=[['Snapshots']],sort=False).min()+all_crds_datasnapshot[['X_coordinate','Y_coordinate','Z_coordinate']].groupby(level=['Snapshots'],sort=False).max())/2
all_crds_datasnapshot[['X_coordinate','Y_coordinate','Z_coordinate']] = all_crds_datasnapshot[['X_coordinate','Y_coordinate','Z_coordinate']].sub(half_simulation_box_lengths)



# dummy atom box fixing - I changed the atom number up top where it's saved in the the header list
dummy_placement = ((box_x**2 + box_y**2 + box_z**2)**0.5)+(padding_distance/2)
dummy_box_x = (((dummy_placement**2)-(box_y**2 + box_z**2))**0.5)/2 #dividing by two at the end because we centered on zero
dummy_box_y = (((dummy_placement**2)-(box_x**2 + box_z**2))**0.5)/2
dummy_box_z = (((dummy_placement**2)-(box_x**2 + box_y**2))**0.5)/2

def add_line(groupby_crd_dataframe): #sets the new index with the correct snapshot and atom number
    groupby_crd_dataframe.loc[(groupby_crd_dataframe.index[-1][0],groupby_crd_dataframe.index[-1][1],len(groupby_crd_dataframe)),:] = [groupby_crd_dataframe['ATOM_number'].iloc[-1]+1, (groupby_crd_dataframe['RESIDUE_number'].iloc[-1])+1,'DUM','D1',dummy_box_x,dummy_box_y,dummy_box_z,'D',(groupby_crd_dataframe['RESIDUE_ID'].iloc[-1])+1,float(0.00000)] #freak indexing in tthe .loc function is saying [last line in snapshot, last residue in snapshot, last atom in residue]
    groupby_crd_dataframe.loc[(groupby_crd_dataframe.index[-2][0],groupby_crd_dataframe.index[-2][1],len(groupby_crd_dataframe)),:] = [groupby_crd_dataframe['ATOM_number'].iloc[-1]+1, (groupby_crd_dataframe['RESIDUE_number'].iloc[-1])+1,'DUM','D2',(dummy_box_x*(-1)),(dummy_box_y*(-1)),(dummy_box_z*(-1)),'D',(groupby_crd_dataframe['RESIDUE_ID'].iloc[-1])+1,float(0.00000)] 
    return groupby_crd_dataframe

all_crds_datasnapshot = all_crds_datasnapshot.groupby(level=[['Snapshots']],sort=False, as_index=False).apply(add_line).droplevel(level=0)



# Changing POPE POPG and HISH to their three letter counterparts
all_crds_datasnapshot['RESIDUE_name'] = all_crds_datasnapshot['RESIDUE_name'].mask((all_crds_datasnapshot['RESIDUE_name']=='POPE'), other='POE')
all_crds_datasnapshot['RESIDUE_name'] = all_crds_datasnapshot['RESIDUE_name'].mask((all_crds_datasnapshot['RESIDUE_name']=='POPG'), other='POG')













print("\n\nEnding CRD object:\n\n",all_crds_datasnapshot)
### new crd creation
for simulation_number in number_of_simulations_or_peptides_iterator:
    simulation_string = str(simulation_number+1)

    for snapshot_number in number_of_snapshots_iterator:
        snapshot = str(start+(snapshot_number*interval))
        with open(cwd+'/p'+simulation_string+'/'+snapshot+'ps/'+args.output, 'w') as output_crd:
            total_snapshot_number = snapshot_number+1+(simulation_number*(number_of_snapshots))
        
            numpy_array = all_crds_datasnapshot.loc[('Snapshot_'+str(total_snapshot_number))].to_numpy(na_value='')
            np.savetxt(output_crd, numpy_array, fmt='%5d%5d %-4s %-4s%10.5f%10.5f%10.5f %-4s %-4d%10.5f',header=all_crd_header_list[total_snapshot_number-1], comments='')


print(f'--- {time.time() - start_time} seconds ---')

### Housekeeping

#delete itp buffer file
