#!/usr/bin/python 

###### RUN /usr/local/bin/gromacs/GMXRC on the terminal if this script is called on silicon ###### 

#This is a sript to extract the snapshots needed for charge optimization and to modify the coordinate file coordinates.
#First, confirm that the arguments are correct. Most can stay the same but the top section needs to be throughly checked
#
#Finally, the script will output files you should look at vizually to make sure everything's okay. That shouldn't be skipped as it's always important to vizually confirm the script worked.

import argparse
import subprocess
import os
import random
import pathlib

####
######## If there is an issue with this script it's most likely in the argument naming so check that throughly. If it's not the arguments the next most likely position is the formatting of the translated coordinates around LINE 168####
####


parser = argparse.ArgumentParser()

#need to be specified when calling in the argument
parser.add_argument('-l', '--length_of_peptide', help='This is the length of the peptide in atom count so the peptide can be indexed properly. Will change with mutants', required=True, type=int) #366 for wt BFII as an example
#should confirm these but they can stay unchanged
parser.add_argument('-p', '--padding_distance', help='This is the distance that is ""added"" to the top of the peptide in case the membrane is above it and gets translated down unintentionally', required=False, default= 5, type=int)
parser.add_argument('-n', '--num_peptides', help='number of peptides in specified simulation', required=False, default= 4, type=int)
parser.add_argument('-sp', '--starting_peptide', help='if you want to run this script on only one peptide, use this flag and specify the number peptide you want to run', required=False, default=0, type=int)
parser.add_argument('-b', '--Beg_time', help='Start of the time frame of interest in ps', required=False, default= 750000, type=int)
parser.add_argument('-e', '--End_time', help='End of the time frame of interest in ps', required=False, default= 1000000, type=int)
parser.add_argument('-dt', '--interval', help='Interval of frames outputted in ps', required=False, default= 2500, type=int)
parser.add_argument('-f', '--traj', help='trajectory in xtc or trr format',required=False, default="md.xtc", type=str)
parser.add_argument('-s', '--starting_structure', help='starting structure, either .gro or the .tpr file', required=False, default="md.tpr", type=str)
parser.add_argument('-o', '--output', help='formatting of the output frame name. Formats to display [peptide number]_memb[frame number]. This is used for the pdb and crd in addition to directory names. This can be changed to a certain extent', required=False, default="_memb", type=str)

args = parser.parse_args()

#########################

#log file so everything isn't output to consol and you can check it out later
log = open("snapshot_extraction_log.txt", 'w')
log.write("# This file is a log of the snapshot_extraction.py script\n# It outputs the gromacs commands and inputs to this file for future reference\n# All gromacs commands are seperated by the corresponding CRD name.\n\n\n\n")
log.flush() #Not sure why this is needed but stack overflow man/woman said so https://stackoverflow.com/questions/7389158/append-subprocess-popen-output-to-file

#error log file so everything isn't output to consol and you can check it out later
err_log = open("snapshot_extraction_error_log.txt", 'w')
err_log.write("# This file is a log of the snapshot_extraction_hpc.py script errors\n# It outputs the gromacs commands and inputs to this file for troubleshooting\n\n\n\n\n")
err_log.flush() #Not sure why this is needed but stack overflow man/woman said so https://stackoverflow.com/questions/7389158/append-subprocess-popen-output-to-file

cwd = os.getcwd()
path_that_called_script = pathlib.Path(__file__).resolve(strict=True).parent
log.write("---Paths---\nPath To Script: "+str(path_that_called_script)+"/"+parser.prog+"\nCurrent Working Directory: "+cwd+"\n---Arguments---\n")
err_log.write("---Paths---\nPath To Script: "+str(path_that_called_script)+"/"+parser.prog+"\nCurrent Working Directory: "+cwd+"\n---Arguments---\n")
for arg in vars(args):
    log.write(arg+": "+str(getattr(args, arg))+"\n")
    err_log.write(arg+": "+str(getattr(args, arg))+"\n") 
log.write("\n\n\n\n")
err_log.write("\n\n\n\n")


################################


#set up the numbering and constants for the scripts
padding_distance = args.padding_distance
total_peptide_count = args.num_peptides
number_of_peptides = range(total_peptide_count)
starting_peptide = args.starting_peptide
start = int(args.Beg_time)
end = int(args.End_time)
interval = int(args.interval)
number_of_frames = int((end-start)/interval)
number_of_range = range(number_of_frames+1) #plus one otherwise it won't do the final structure
number_of_atoms = int(args.length_of_peptide)
start_struc = args.starting_structure
output_name_format = args.output
trajectory = args.traj



#########################


#Now that I think about it this GMXRC call may not work for the subprocess calls as they may be using a different shell type
# GMXRC = subprocess.Popen(["/usr/local/gromacs/bin/GMXRC"], shell=True) #need to call in the GMXRC if you're going to be doing any GMX calculations on silicon
#Does not seem to work probably maybe :( 
#But on the bright side I think this step is unnecessary as the subprocess module inheirits the parent processes env variables. Hopefully.


#creating a list of the edited files
edited_PDBs = []


### Error processing function
def error_confirmation(output, errors, subprocess_name):
    loggy = output.decode('utf-8').splitlines()
    dog = errors.decode('utf-8').splitlines()

    if subprocess_name.returncode == 0: 
        for line in loggy:
            log.write(line+"\n")
        for line in dog:
            log.write(line+"\n")
    else:
        for line in loggy:
            err_log.write(line+"\n")
        for line in dog:
            err_log.write(line+"\n") 



#########################


y = 0


for x in number_of_peptides: #Too nested, not very readable # This section is creating the p directories and the indexes for each one.

    if starting_peptide == 0:
        x = x+1
    else:
        x = x+starting_peptide #starting peptide is a correction factor when you only want to do one peptide. If you wanted to do peptide three all you'd do if specify that in the flag.
        y = y+(starting_peptide-1)
    
    pep_dirs = subprocess.Popen(["mkdir", "p"+str(x)])
    pep_dirs.wait() # If this wait command isn't used it'll randomly crash out because a directory wasn't created but when checked(after the crash) the directory stated to not exist is sitting there. This seems to have fixed the issue
    
    #making a file for the protein movies
    p_movie = open("./p"+str(x)+"/p"+str(x)+"_movie.pdb", 'w') #this file is opened and closed here so that we can append later and not overwrite it
    p_movie.close()

    #This is to create the index file
    if y == 0 or starting_peptide != 0: #need to have this if else statement so that if it's the first time the index is created it names it without trying to call an already existing index
        with subprocess.Popen(["/home/delmore/gromacs_gpu/bin/gmx", "make_ndx", "-f", start_struc, "-o", "se_index.ndx"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as index: #No -n flag cuz we neeed to create it
            output, errors = index.communicate(bytes('a '+str((y*number_of_atoms)+1)+'-'+str(x*number_of_atoms)+'\nq\n' , encoding='utf-8'))
            error_confirmation(output, errors, index)
    else:
        with subprocess.Popen(["/home/delmore/gromacs_gpu/bin/gmx", "make_ndx", "-f", start_struc, "-o", "se_index.ndx", "-n", "se_index.ndx"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as index: # -n flag yay
            output, errors = index.communicate(bytes('a '+str((y*number_of_atoms)+1)+'-'+str(x*number_of_atoms)+'\nq\n' , encoding='utf-8')) #can change this in the future to make the naming a little better for the index file and to reduce the number of index files made
            error_confirmation(output, errors, index)

    with subprocess.Popen(["/home/delmore/gromacs_gpu/bin/gmx", "make_ndx", "-f", start_struc, "-o", "se_index.ndx", "-n", "se_index.ndx"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as index2: #-n flag yippee
        output, errors = index2.communicate(bytes('"a_'+str((y*number_of_atoms)+1)+'-'+str(x*number_of_atoms)+'" | "Other"\nq\n' , encoding='utf-8')) #if this ever breaks I'll cry
        error_confirmation(output, errors, index2)
    


    for n in number_of_range:
        nanosecond = str((n*interval)+start)
        PDB_temp = "p"+str(x)+str(output_name_format)+str(nanosecond)+".pdb" # sets up the naming of the pdb file pre-translation
       

        frame_dirs = subprocess.Popen(["mkdir", nanosecond+"ps"], cwd="./p"+str(x)+"/") #cwd allows you to specify the directory a subprocess is run
        frame_dirs.wait() # we stay waiting
        with subprocess.Popen(["/home/delmore/gromacs_gpu/bin/gmx", "trjconv", "-f", "../../"+trajectory, "-n", "../../se_index.ndx", "-s", "../../"+start_struc, "-o", PDB_temp, "-pbc", "res", "-center", "-b", nanosecond, "-e", nanosecond], cwd="./p"+str(x)+"/"+nanosecond+"ps/", stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as pdb: 
            output, errors = pdb.communicate(bytes('a_'+str((y*number_of_atoms)+1)+'-'+str(x*number_of_atoms)+'\na_'+str((y*number_of_atoms)+1)+'-'+str(x*number_of_atoms)+'_Other\n' , encoding='utf-8')) #Oh nooooooooo, time for the center than output
            error_confirmation(output, errors, pdb)

        print(str(n)+" out of "+str(number_of_range[-1])+" for peptide "+str(x)) # Just for cutsie terminal output
 

        # Move into the new directory
        os.chdir("./p"+str(x)+"/"+nanosecond+"ps/")

        #editing the PDB file
        open_PDB_temp = open(PDB_temp, 'r')
        final_PDB = open("final_"+str(PDB_temp), 'w')
        p_movie = open("../p"+str(x)+"_movie.pdb", 'a') #inside the individual frame directories I have to append the lines to this file as well to easily make the movie


        read_file_lines = open_PDB_temp.readlines()
        atom_max = [] # setting up the protein atom max list so that it gets emptied every new pdb file but not every line

        for line in read_file_lines: #reading in the PDB
            split_line = line.split()
            title_check = len(split_line[0])

            if split_line[0] == "CRYST1": # PDB Title stuff
                z_length = float(split_line[3]) #getting the z vector length from the top of the PDB file
                warning_length = z_length - 2.5 #the length of a long hydrogen bond to give a warning that a bond is stretching of the box 
                final_PDB.write(line)
                p_movie.write(line)

            elif split_line[0] == "REMARK" or split_line[0] == "TITLE" or split_line[0] == "TER" or split_line[0] == "ENDMDL": #more title/end file stuff
                final_PDB.write(line)
                p_movie.write(line)


            elif split_line[0] == "MODEL": #title stuff but it differs for the movie :)
                final_PDB.write(line)
                p_movie.write(line[:5]+("%9s" %str(n+1))+"\n" )


            elif split_line[0] == "ATOM": #everything from this point on is actual coordinate translation stuff.
                prot_z_coor = float(split_line[8]) #this object sets up the max z coor of the protein
                atom_numb = int(split_line[1]) #getting the atom number to compare to eventually the length of the peptide
                

                if atom_numb <= number_of_atoms: #if protein
                    atom_max.append(prot_z_coor) #putting the z coor in a list to eventually find max
                    final_PDB.write(line)
                    p_movie.write(line)
                    
                    continue 

                else: #if not protein
                    non_protein_z_coor = float(split_line[7]) #changes to 7 due to the fact that pdb indexing messes up with membrane chains and concatenates them into one line
                    prot_coor_max = float(max(atom_max)) #finding the max z coor for the protein
                    prot_coor_max_padded = prot_coor_max+padding_distance
                    

                    if non_protein_z_coor > prot_coor_max_padded: #if the current lines z coordinate is larger than the max protein coordinat
                        new_z = (non_protein_z_coor-z_length) #translate the z-coordinate down
                        donzo_lineo_never_wanna_toucha_pdb_again_o = str(line[0:-33]+("%8.3f" %new_z)+line[-25:]) #remake line with new z coor
                        final_PDB.write(donzo_lineo_never_wanna_toucha_pdb_again_o) #write the line
                        p_movie.write(donzo_lineo_never_wanna_toucha_pdb_again_o)

                        #appending the set of the edited files
                        set_item_PDB = "p"+str(x)+"_"+str(nanosecond)
                        edited_PDBs.append(set_item_PDB)
                        continue

                    #now we print the membrane that doesn't get translated    
                    final_PDB.write(line)
                    p_movie.write(line)


        open_PDB_temp.close()
        final_PDB.close()
        p_movie.close()

        

        str_x = str(x)
        crd_filename = "initial_p"+str_x+str(output_name_format)+str(nanosecond)+".crd"
       
        str_final_PDB = "final_"+str(PDB_temp)
        print(crd_filename)
        log.write("\n\n\n\n##########\n"+str(n)+" out of "+str(number_of_range[-1])+" for peptide "+str(x)+"\n"+crd_filename+"\n\n##########\n\n\n\n")
        log.flush() #Not sure why this is needed but stack overflow man/woman said so https://stackoverflow.com/questions/7389158/append-subprocess-popen-output-to-file
 
        crd_conv = subprocess.Popen(["/home/zh106/currently_used_scripts_and_files/pdb2crd", str_final_PDB, crd_filename]) #cwd="./p"+str(x)+"/"+nanosecond+"/")
        crd_conv.wait()
    
        os.chdir("../../")

    y = y+1
    #del_dirs = subprocess.Popen(["rm", "-r", "p"+str(x)]) #this is just used for testing to easily delete directories



# finally, this will report all the changed files for review and if there are none it will choose five random files
    
unique_edited_PDBs = []#each translated atom creates a copy in the edited_PDBs list so I wanna remove them 
for pdb in edited_PDBs:
    if pdb not in unique_edited_PDBs:
        unique_edited_PDBs.append(pdb)

len_of_unique_edited_PDBs = len(unique_edited_PDBs)

if len_of_unique_edited_PDBs > 0: # This set of code prints out the files that should be viewed or which files had translations
    print("This is the full list of translated frames. Check some of these files as a vizual check or check out the peptide movies.")
    for file_name in unique_edited_PDBs:
        print(file_name)
else:
    print("There were no translated coordinates! Yippee!")
    print("Check these five random PDB/CRD files vizually to make sure they look okay or check out the peptide movies")
    for x in range(6):
        random_ns = random.randrange(start, end+interval, interval)
        random_protein = random.randrange(1,total_peptide_count+1,1)
        print("p"+str(random_protein)+"_"+str(random_ns))



# A little something something that removes the index files

index_del_range = (total_peptide_count*2)
for protein_num in range(index_del_range):
    if protein_num == 0:
        continue
    else:
        with subprocess.Popen("rm *.ndx.*", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as del_files:
            output, errors = del_files.communicate() 
            error_confirmation(output, errors, del_files)












