# Use this command to vizualized this file: @/Users/zak/wellesley/scp/viz_test/test_memb.pml


# change background color of PyMOL window
bg white

# Vizualization for SOL
sele resn SOL
extract water, sele
hide, model water
desele

# Vizualization for POPG
sele resn POPG
extract POPG, sele
show sticks, model POPG
color dirtyviolet, model POPG
desele


# Vizualization for POPE
sele resn POPE
extract POPE, sele
show sticks, model POPE
color slate, model POPE 
desele


# Vizualization for Protein
sele resn ALA+ASP+GLU+TRP+GLN+SER+CYS+VAL+ASN+MET+LEU+LYS+PRO+ILE+TYR+THR+ARG+PHE+GLY+HIS+HISD
extract Protein, sele
# show cartoon, model Protein
# color smudge, model Protein 
# desele
show sticks, model Protein
util.cbac model Protein
desele


# Vizualization for Phosphorus
sele name P
create Phos, sele
show spheres, model Phos
color firebrick, model Phos
desele
 

# Hides all nonpolar hydrogens from the structure. This should be done AFTER structures are already vizualized the way you want them.
hide (h. and (e. c extend 1))


# antialias =1 smooths jagged edges, 0 turns it off
set antialias, 1
