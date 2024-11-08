What to do for crds, Chow has a script for this and ask ashley for this

make a wrapper script to call all these little scripts


- <mark style="background: #BBFABBA6;">re chain (Easy</mark>)
	- peptide L
	- membrane R
- f<mark style="background: #BBFABBA6;">or every atom name move a starting number to the end of the atom name</mark> (Probably Easy)
	- Creating a function in a class for this could be good
- m<mark style="background: #BBFABBA6;">ake the last column in crd: make the c</mark>hAarge on the each atom (itp). The order of atoms are not the same. (hard)
	- to do this each atom needs to be uniquely identified.
	- each atom needs residue key, carbon type
- make the radii file (kinda easy)
	- Ask Ashley
	- Truncated: /teaching/storage/malea/AMP/des1/ols/make
- <mark style="background: #BBFABBA6;">Need to make</mark> a file that sets a consistent box size, through dummy atoms, for all of the files. I should find the max and min of all files so that I can set this (eh shmeh, maybe try to get this done and make thi)
	- i could use instance variables, or class I think it's class variables, to save the biggest box sizes to place record largest coordinates. i could also include it in the snapshot one using a cool class file
	- <mark style="background: #BBFABBA6;">change number</mark> of the total atomst


/programs/common/utilities/totalcharge
use /teaching for membrane jobs