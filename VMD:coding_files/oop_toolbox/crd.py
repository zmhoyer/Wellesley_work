#!/usr/bin/env python

#when using on local, need to use
#maybe conda init (shell)
#conda activate iron

'''
I'm using numpy in this script as the idea is to create a simulation object that gets
progressively bigger the more class instances that are called. Using a large
n-dimensional array should be easier with numpy.

Game plan

Simulation class 
- parent
- creates initial matrix

subclasses
- children to Simulation class or other children classes
- Merges into the initial matrix

'''
import numpy as np
import pandas as pd


input = str("initial_p1_memb750000.crd")
crd = open(input, 'r')

#big = np.array(crd) #does not work
big2 = np.genfromtxt(input) #works and genfromtext can handle missing data. It places nan in place

print(big2)

