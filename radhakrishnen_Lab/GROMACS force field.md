---
Date Created: 2024-08-20 15:45
aliases: 
Daily Link: "[[2024-08-20]]"
---
---
### General tips:
- .gro files are in nm, not Å
- Unless stated otherwise, we'll be using nonbonded interaction cutoffs of 1 nm. This means we'll need at least 0.5 nm leeway on each side of the box so the protein doesn't interact
- The mdp script integrator time is in picoseconds for the timestep we'll have to use 0.002 or something similar to specify femtoseconds
- -s stands for strucutre/state file

### General production run commands and flags

#### To get a .gro file
To get a .gro file use ```gmx pdb2gmx```
- the following flags will be needed
	- -f for the filename of the pdb
	- -o for the output .gro name
	- -p for the output .top name
	- -inter is not necessary but it's an interactive option. It'll ask you questions on the specific system
- We used 10 for the first sim force field


#### Box creation
To edit the water box on the .gro file we'll use ```gmx editconf```
- the following flags will be needed
	- -f the file name where the box will be changed
	- -o the output with the defined box
	- -bt cubic - makes the box cubic
	- -d is the minimum distance between the closest atom of the protein (in the .gro file) and a side of the box. It's in nm
	- -box (0 0 0) can be used in place of d to set a strict box size 


#### Water addition
To add water to the box we use ```genbox``` functionality but not genbox as the command. Instead we use a command ```gmx solvate```
- This command essentially fills the box with smaller boxes of 216 water molecules pre-equilibrated and fills them in as long as there's no overlapping molecules
- The topology files is written to the same topology file so it's good practice to create a new one beforehand but it's not necessary as the program does it for you. It's really only needed for new names
	- -cp is the input .gro file the solvent will be added to
	- -cs is the file that specifies the solvent molecule coordinates. For water this is spc216.gro and it comes with a box of 216 water molecules. It can also be other pre-loaded water models like the tip3p model
	- -o is the output .gro file with the solvent
	- -p this is the topology that's overwritten


#### .tpr creation for adding solvent
Since we need a .tpr file (the starting coordinates, topology, and simulation parameter file (this is a .mdp file)) for the add ions script, we need to use ```gmx grompp``` file to create the .tpr file (.tpr stands for portable binary input file)
- some necessary flags
	- -f is the .mdp (the simulation parameters) run file
	- -o is the output .tpr filename
	- -c is the .gro file used for the start of the simulation
	- -p is the input .top file


#### Ion generation
to add the ions we'll need to use ```gmx genion```. This will take the coordinate/topology/parameter (.tpr) to create the .gro and .top file with ions
- This command will also overwrite the .top file so you might wanna create another
- some flags
	- -s is the .tpr file created from a coor, top, and param file
	- -o is the output .gro file that will have some waters replaced with ions
	- -p is the output topology file with the ions included and some water removed
	- -neutral tells the genion command to neutralize the system with ions
	- -conc # this is telling you to add enough salt to come out to a certain salt concentration. It's in M
	- -pname XX is the name of the positive ion to use
	- -nname XX is the name of the negative ion to use
- It will ask which molecules to replace and so SOL for solvent should be chosen


#### .tpr creation for the minimization 
Since we don't want the simulation to explode during production we do a quick steepest descents minimization for this. We thus create a .tpr file with ```gmx grompp``` once again
- flags
	- -f parameter minimization file (.mdp)
	- -o output .tpr file
	- -c initial structure for min
	- -p initial topology for this run



#### Running the minimization
After the creation of the .tpr minimization file we can do the minimization. To do this we need the ```gmx mdrun``` command.
- The flags needed
	- -v this makes the md output verbose
	- -s is the start .tpr file made from the coordinates/topology/param files
	- -o is the output for this "trajectory" run and includes coordinates for each step of the minimization. It's in a .trr file format which stands for trajectory and contains the coordinates, velocities, forces and energies.
	- -x is a compressed version of the .trr file and has the extension .xtc
	- -c is the coordinate file in .gro format which will contain the coordinates of the final position after the minimization
	- -g is a log file for the job
	- -e is a file that lists the energies throughout the run and has the .edr (portable energy file) extension


#### Running production

It's essentially the exact same as the minimization step just using the production mdp. The top is the same as for the minization, the gro is from the minimization.
it is the same but I would not use the verbose modifier

### General analysis commands and flags

You can use ```gmx editconf``` to change the .gro file to a .pdb
- flags needed
	- -f is used to define the input coordinate file
	- -o is used to tell editconf where to save the new coordinates and with what extension
	- -ndef makes the program confirm which group to include in the output file\


The ```gmx trjconv``` command can be used to extract individual frames from a trajectory as individual pdb files. Trjconv stands for trajectory converter.
- Flags needed
	- -f the input trajectory file
	- -s the .tpr file which has the necessary topology 
	- -o the output file that has the snapshot's name
	- -b This is the first frame to export from the .xtc file
	- -e this is the ending frame exported from the .xtc file (if the same as the -b frame it will only print one pdb)
- Additional flags needed to export multiple frames
	- -e will need to be different from -b
	- -dt will specify the interval at which frames are exported
	- -sep will export frames as separate files
- Additional flags to make it a movie
	- will leave out -sep
	- -pbc will be set to nojump
		- pbc means periodic box conditions and no jump will essentially center the box on the molecule. makes it so the molecule doesn't appear to get split up and stuff

To do RMSD the ```gmx rms``` command can be run. This will give you the deviation during a given trajectory from one defined selection to the another defined selection. Since it's an average over all selected atoms in a simulation it's a larger tell as to whether the structure of the molecule is changing. 
- usually the alpha carbon is chosen as the selection
- the flags needed are
	- -f is the starting coordinate trajectory either xtc or trr (the lab uses xtc)
	- -s is the reference structure (.gro file) and thus is equivalent to the pre production file used for the production. Generally the minimized structure
	- -o is the output file in the .xvg format and it's contain two lines with it
	- -ng is the number of groups you want to calculate RMSD from after fitting to the initial protein
	- -dt this how often you wanna output data. default is to print them all. I don't think it saves any calculation time though

RMSF is similar to RMSD and can be run using the ```gmx rmsf``` which will calculate the fluctuations in a given set of atoms compared to their original. This is useful as the larger the fluctuations around a given atom/residue (typically printed in the x axis) will give you an idea of how disordered the structure is at that location.
- usually the alpha carbon is chosen as the selection
- flags to use
	- -f s the starting coordinate trajectory either xtc or trr (the lab uses xtc)
	- -s is the .tpr file that has the topology information for the structures in the trajectory
	- -o is the output file with the .xvg file tag.
	- -b is the first frame of the equilibrated structure (unchanging RMSD)
	- -e is the  last from of the equilibrated structure

You can use ```gmx energy``` to look at many different types of energy from the system. In the tutorial we looked at the potential energy option rather than some of the others
- interesting flags
	- -f is the input file with energies from the minimization for g_energy. It will look something like md.edr
	- -o is the output file that will be in the .xvg format
	- -skip # this is telling the command to output on every \#th frame

Another analysis that can be performed is the ```gmx mindist``` that will show you the minimum distance between any two defined atoms. In the following instance this command will be used to calculate the minimum distance between periodic boxes
- interesting flags
	- -f is the coordinate trajectory file from a simulation. This can be an xtc or a trr
	- -s is teh reference structure and is usually the start of the traj file or the minimized structure
	- -od is the output file that will contain the minimum distance information in .xvg
	- -pi is telling the program to do a mindist on the periodic box image of the protein
	- -dt is the output interval steps in picoseconds


