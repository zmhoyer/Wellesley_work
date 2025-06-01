#!/usr/bin/python 


from membraneprep import crdtools #the package format for this script was totally unecessary and I understand that I just wanted to learn how to do it
import membraneprep



parser = membraneprep.argparse.ArgumentParser()

#need to be specified when calling in the argument
parser.add_argument('-l', '--length_of_polypeptide', help='This is the length of the peptide in atom count so the peptide can be indexed properly. Will change with mutants', required=True, type=int) #366 for wt BFII as an example
parser.add_argument('-d', '--dummy_offset', help='this is the distance (in angstrom) the dummy atoms will be placed away form the atoms along the box vector', required=True, type=int) #a value of 10 will add (or subtract) 10 angstroms to all three box vectors before placing the dummy atom
parser.add_argument('-i', '--itp_files', nargs='*', help='feed all the itps in here corresponding to molecules used for charge optimization', required=True)
parser.add_argument('-o2', '--output2', help='This is the final output name that is desired. Something like bf2wt.crd is conscise and accurate if youre working with bf2 wildtype', required=True, type=str)
##should confirm these but they can stay unchanged
parser.add_argument('-n', '--num_peptides', help='number of peptides in specified simulation', required=False, default= 4, type=int)
parser.add_argument('-b', '--Beg_time', help='Start of the time frame of interest in ps', required=False, default= 750000, type=int)
parser.add_argument('-e', '--End_time', help='End of the time frame of interest in ps', required=False, default= 1000000, type=int)
parser.add_argument('-dt', '--interval', help='Interval of frames outputted in ps', required=False, default= 2500, type=int)
##not required but can be changed if needed/wanted
parser.add_argument('-c', '--crd_placeholder', help='placeholder for crd testing', required=False, default="initial_p1_memb750000.crd", type=str)
parser.add_argument('-o', '--output', help='formatting of the output frame name. Formats to display [peptide number]_memb[frame number]. This is used for the pdb and crd in addition to directory names. This can be changed to a certain extent', required=False, default="_memb", type=str)

args = parser.parse_args()



cwd = membraneprep.os.getcwd()
total_peptide_count = args.num_peptides
number_of_peptides = range(total_peptide_count)
start = int(args.Beg_time)
end = int(args.End_time)
interval = int(args.interval)
number_of_frames = int((end-start)/interval)
number_of_range = range(number_of_frames+1)

crdobj = [] #the list idea is so convoluted
for z in range((total_peptide_count*number_of_frames)+5):
    crdobj.append(z)
z = 0 #index for the objects so that I can call them in the second loop. There has to be an easier way.

for x in number_of_peptides:
    x = x+1
    for n in number_of_range:
        nanosecond = str((n*interval)+start)
        membraneprep.os.chdir("./p"+str(x)+"/"+nanosecond+"ps/")
        crd_filename = "initial_p"+str(x)+str(args.output)+str(nanosecond)+".crd"

        print(str(n)+" out of "+str(number_of_range[-1])+" for peptide "+str(x))

        #first loop through before adding the dummy atoms according to the max box size from all 400 files
        
        crdobj[z] = crdtools(crd_filename, args.length_of_polypeptide)
        crdobj[z].rechain()
        crdobj[z].atom_type_number_move()
        crdobj[z].residue_name_fix()
        crdobj[z].charge_fixin(args.itp_files) #I need to fix the naming of POPG and stuff so this file works
        crdobj[z].translation()
        z += 1
        membraneprep.os.chdir("../../")


#needs to be in the second for loop as these need to know the min and max of each crd to get everything consistent
z = 0
for x in number_of_peptides:
    x = x+1
    for n in number_of_range:
        nanosecond = str((n*interval)+start)
        membraneprep.os.chdir("./p"+str(x)+"/"+nanosecond+"ps/")
        
        print("cleaning up and adding dummy atoms for "+str(n)+" out of "+str(number_of_range[-1])+" in peptide "+str(x))

        crdobj[z].dummy(args.dummy_offset)
        crdobj[z].housekeeping(rename=args.output2, remove=True)
        
        z += 1
        membraneprep.os.chdir("../../")


#what I still need to do.
# - need to optimize the file for running in every directory
## - I probably won't end up doing this as I plan to remake this script later on
# - need to add a crd_movie maker
