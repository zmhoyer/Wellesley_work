#/usr/bin/env python


# This file can create the pymol file based on the structure name
# To run the outputted .pml file you need to type @/filepath_to_pml/.pml file


import argparse


#argparse for the file for vizualization
#argparse for nonpolar hydrogens


.write("# Use this commandto vizualized this file: @"+absolute_path+"/"+structure_name+".pml")