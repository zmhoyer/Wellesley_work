---
Date Created: 2024-08-27 14:35
aliases: 
Daily Link: "[[2024-08-27]]"
---
---
# Different Simulations and Analysis 

This will be a log of the simulations I've read and why they were done. I'll also list the directory for each.

Reminder: Every time you use GROMACS on silicon you must run:
```/usr/local/gromacs/bin/GMXRC```
To initiate it and:
```/usr/local/gromacs/bin/gmx``` 
Every time you want to run a command

### Indexing Atoms

You need to make an index of a certain group of atoms if you want to run analysis on only one part of it. 
- To begin, you need to run ```gmx make_ndx -f file.gro -o output_index.ndx ```
	- This will list the default index and allow you to make changes based off of the information listed in the .gro file. (like the atom number and residue number)
- After running this command it shows you what's currently listed in the defualt index, the operations you're allowed to perform below that, and a waiting command line for your performances.
- Once done, the -n flag can be used to modify a currently existing index instead of making a brand new one each time BUT you still need to write to the same output file name or else it will default to index.ndx
	- ```/usr/local/gromacs/bin/gmx make_ndx -f md.tpr -n index.ndx -o index.ndx```



## Simulations
### Redoing Amy's membrane simulation - done
My directory is the /research/zak/amy_out5_redo directory on silicon
I got files from Amy's /data/aliu9/BF2_sim directories

From minimization I had to go back and redo the solvation and ion addition :( because the atom numbers weren't right



#### Box creation
To do this I got Amy's out5.gro file and put that in my directory

I did not want to write a script to delete the water and ions in the out5.gro so I just used vim and renamed the file to out5_solvdel.gro.

Things to remember:
Delete the waters and ions but remember to change the total atom number at the top of the file

I then used:
```/usr/local/gromacs/bin/gmx editconf -f out5_solvdel.gro -o boxed_out5_solvdel.gro -bt cubic -box 6.2 6.2 10.0```
To set the box


#### Water addition
I then copied Amy's final.top file over to my directory and called it mod_final.top after deleting the waters and ions from it.

after this I copied the POPE.itp, POPG.itp, and the bf2.itp over into my directory in addition to the charmm forcefield.

<mark style="background: #FF5582A6;">I then used the following command:</mark>
```/usr/local/gromacs/bin/gmx solvate -cp out5_solvdel.gro -cs tip4p.gro -o solvated_out5.gro -p mod_final.top```
to solvate this thang. 

<mark style="background: #FF5582A6;">Now weirdly, the .itp is called the tip3p.itp but the default .gro is the tip4p.gro and that's what I ended up using so we'll see how that goes</mark>
- This was before I knew that the spc216.gro was compatible with tip3p and a lot of other water molecules. The 3 forcefield is not compatible with the 4p coordinates

I also renamed the topology to solve_final.top before fixing the simulation


I then used the following command to make ammends:
```/usr/local/gromacs/bin/gmx solvate -cp out5_solvdel.gro -cs spc216.gro -o solvated_out5.gro -p solve_final.top```
to solvate this thang. The wrong topology got saved to the \#solve_final.top\# and the \#solvated_out5.gro\# got saved as well. I also had to edit the .top file to take out the repeated water molecules

This outputted some info:
- 38762 atoms
- 7291 residues
- volume of 384.4 nm<sup>3</sup>
- density of 998.513 (g/l)
- 7078 solvent molecules



#### Grompping my way to minimization

I had to steal amy's .mdp file for the ion generation run

so to create the .tpr for ion generation I did this command:
```/usr/local/gromacs/bin/gmx grompp -f min.mdp -o tosolv_out5.tpr -c solvated_out5.gro -p solve_final.top``` 
I got an error about the mdp having the ions included so I had to take those out. I will need to replace those during the minimization step

I was also told that the charge is -8 for my system which sounds about right
l
#### Ion-shmion

Unfortunately need to add ions sooooooooo:

```/usr/local/gromacs/bin/gmx genion -s tosolv_out5.tpr -o myion_out5.gro -p solve_final.top -pname NA -np 21 -nname CL -nn 13```


Now I did this command an switched out the SOL waters hoping the replaced waters would be outside the membrane. I'm also calculated to concentration for the number of waters I had, 500 more than Amy, and so that gave me an extra NaCl. 
- since I ran the genion command twice there are two top files saved and a single myion gro file saved.


I then renamed the topology file to myfinal.top

I also converted myion_out5 to a pdb to check that there were no ions in the memb. I scpd this onto my local directory to take a look
- This yielded me with an ion in the lipid membrane... so I have to get that out now. It's NA 7196 and Im going to vizually search for an open space and swap their coordinates
	- 7196      13.470  10.590  49.580
- after looking at the water coordinates and seeing that they're three seperate coordinates I decided not to. I'm just deleting this water and throwing it in
- 3576 is getting deleted
	- it's coords are 1.940   4.280   1.386
- Due to the indexing of the atom numbers being all wonky if I did that, I chose to just try translating it up to the very bottom of the box. like very bottom
- changed the sodium coordinates to
	- 7196      13.470  10.590  0.058

Soooooooooo scuffed, need to create a script for this


When I needed to redo everything I went back and used this command instead
```/usr/local/gromacs/bin/gmx genion -s tosolv_out5.tpr -o myion_out5.gro -p myfinal.top -pname NA -np 21 -nname CL -nn 13```
- but I first needed to mv solve_final.top to myfinal.top


#### Minimization

Needed to replace the ion names in the minimization script
Needed to delete ions from the topology because they get double counted the way I've been messing up in combination with my renaming scheme

than I created the .tpr by getting gromppy:
```/usr/local/gromacs/bin/gmx grompp -f min.mdp -o min.tpr -c myion_out5.gro -p myfinal.top```

annnnddddd it didn't work because the atom numbers don't match by about 96 more atoms in the .gro file compared to the topology. I have no clue why this happened soo I'm just deleding files



Thank god it worked when I re-did it . Now I just have to actually run the minimization instead of loafing around. I used this command
```/usr/local/gromacs/bin/gmx mdrun -v -s min.tpr -o min.trr -x min.xtc -c min.gro -g min.log -e min.edr```
And I tried to use subfast on silicon but Ilearned that silicon doesn't have it. I may be dumb

Either way it finished in around 30 seconds and I got this potential enerygy which is okay for minimization.
- -4.4835647e+05

#### MD simulation time


essentialy the same as the minimization steps just no verbose and useing the md.mdp from mala's simulations. I used the following grompp command to do this:
```/usr/local/gromacs/bin/gmx grompp -f md.mdp -o md.tpr -c min.gro -p myfinal.top -maxwarn 1```
I had to include the maxwarn flag because the Parrinello-Rahman pressure coupling required for the isotropic membrane simulation and it doesn't want you to use this for equlibration. But we're doing MD so it doesn't really matter


To actually run the production script I used:
```/usr/local/gromacs/bin/gmx mdrun -s md.tpr -o md.trr -x md.xtc -c md.gro -g md.log -e md.edr```

but I learned that if I want this to run seperatly from my terminal I need to add 
```nohup blah blah blah &```
nohup and an ampersand to detach from my terminal
you can type kill -9 \#PID# to then kill the command if needed

I ended up doing this command to restart the simulation from the state file and to append to all the listed files
```nohup /usr/local/gromacs/bin/gmx mdrun -s md.tpr -o md.trr -x md.xtc -c md.gro -g md.log -e md.edr -cpi state.cpt &```



### Doin Amy's sim again

**the c-terminus(lys21)** looks weird in the initial visualization of it. Like freaky weird where the oxygens are overlapping
#### Box creation
exact same as the first time
```/usr/local/gromacs/bin/gmx editconf -f out5_solvdel.gro -o boxed_out5_solvdel.gro -bt cubic -box 6.2 6.2 10.0```

#### Water addition

Used:
```/usr/local/gromacs/bin/gmx solvate -cp out5_solvdel.gro -cs spc216.gro -o solvated_out5.gro -p solve_final.top```
just like before

got
38762 atoms and 7291 residues
volume of 384.4
density of 998.513
and 7078 solvent molecules


#### NEW STEP - deleting waters from the .gro file

Used MY fancy smamshi script for deleting atoms out of the membrane

the new water count is 37712
350 waters were deleted from the membrane

#### Next step to grompp before ionization

used this grompp command AFTER I deleted the ion names from min.mdp
```gmx grompp -f min.mdp -o tosolv_out5.tpr -c no_membrane_water.gro -p solve_final.top```
I got a charge of -8
#### Now for da ions

first I moved the top file to myfinal.top

I used this command to replace the ions and decreased the ion count by 1 as we deleted 350 waters from the membrane
```gmx genion -s tosolv_out5.tpr -o myion_out5.gro -p myfinal.top -pname NA -np 20 -nname CL -nn 12```

- Then I did a visual check by copying the .gro to my device
	- Perfect

#### Minimization time

First I added back in the atom names to the min.mdp

Then I grommppied with:
```/usr/local/gromacs/bin/gmx mdrun -v -s min.tpr -o min.trr -x min.xtc -c min.gro -g min.log -e min.edr```
Which worked!!!!

and then I minimized with
```/usr/local/gromacs/bin/gmx mdrun -v -s min.tpr -o min.trr -x min.xtc -c min.gro -g min.log -e min.edr```

which too about 40 seconds and gave a potential energy -4.3596028e+05
which is actually worse than before so that's hype

#### Time to submit the sim

I did 
```/usr/local/gromacs/bin/gmx grompp -f md.mdp -o md.tpr -c min.gro -p myfinal.top -maxwarn 1```
to grompp and
```nohup /usr/local/gromacs/bin/gmx mdrun -s md.tpr -o md.trr -x md.xtc -c md.gro -g md.log -e md.edr -cpi state.cpt &```
to actually submit the run.

It'll be 500,000,000 steps at 2 fs which equates to 1 μs or 1,000,000 ps


### Doing my own first membrane simulation

Need to make sure the histidine is in the d tautomer (I think I should fact check this)
I should look into using the g_solvate routine if I'm not using charmm_gui

Try to write a script to take the water out of the membrane

BF2 has 366 atoms - delta tautomer
POPE has
POPG has
Be very carful for the prep of the protein and the 

***

>Melcr et al. found a significant improvement in the binding affinity of Na+ and Ca2+ ions to a POPC bilayer by implicitly including electronic polarization as a mean field correction to the lipid headgroup region, particularly for the nonpolarizable Lipid14 and CHARMM36 models
>- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9534443/


## Simulations

### General types of post production analysis
***

example of a loos command I think
```merge-traj --xy-centering-selection 'segid == "PROA"' --z-centering-selection 'segid == "MEMB"' --selection-is-split on 6ps5_bound.drude.psf merge-reori.dcd input.dcd```

***

If we ever get conda

conda create --name mdanalysis 
conda activate mdanalysis 
conda install -c conda-forge mamba
 
***

https://mptg-cbp.github.io/teaching/tutorials/membranes/index.html

Protein analysis
- RMSD
- RMSF
- distance to membrane instead of periodic image

Membrane analysis
- Area per lipid
	- To see how the box size changes throughout the simulation
- bilayer thickness
- order parameter
- lipid diffusion
	- Good for looking at lipid mobility and lipid motion timescales. 
	- Can be looked at in the xy plane or the z plane

***


need to look and make sure and extract snapshots like every 2.5 ns per peptide when we start charge opt



### Analysis on the redo of Amy's simulation
### Analysis on Mala's simulations


#### Initial analysis - the RMSD and Min dist was wrong as there were four peptides
***

First I did 
```gmx traj -f md.xtc -s min.gro -ob box.xvg``` 
To look at the box size of the simulation throughout the trajectory

***

I wanted rms deviation so I did 
```gmx rms -f md.xtc -s min.gro -o rms.xvg -ng 1 -dt 10```
I also selected the alpha carbons for the reference points

***

I wanted potential energy:
```gmx energy -f md.edr -o mdenergy.xvg -skip 10```
- and I selected the potential option and then I had to hit enter again cuz it just waits for another term otherwise

***

DID NOT finish because it was taking a while and I want instant results
I also did mindist just to see it even though I knew it was gonna do an average over four peptides
```gmx mindist -f md.xtc -s min.gro -od mindist.xvg -dt 100```
and then selected side chain as the first group and other as the second group to represent the membrane

***

I'm going to try cluster analysis to seperate out the proteins on the membrane with the following command
```gmx cluster -f md.xtc -skip 10 -s md.tpr```
and then I chose protein cuz why not you know

***

#### Redoing the RMS and mindist with the index thingy

I kind of knew this already but it still kinda sucks a tiny bit

I'm essentially going to be going through each of these again except with each of the four peptides

***

##### RMSD sorta

To help this process I indexed each of the four peptides with their atom numbers.
I then went through the index process again but did ```26 & 3``` to create a new index with peptide 1 and the 84 ca atoms. This gave me their overlapping groups yippee
```gmx rms -f md.xtc -s min.gro -o 1p_rms.xvg -n index.ndx -ng 1 -dt 10```

I was given a warning about the starting structure that could have molecules broken over the periodic boundary and that using the .tpr as the starting file could help during the calculations so I ran:
```gmx rms -f md.xtc -s md.tpr -o 1p_rms.xvg -n index.ndx -ng 1 -dt 10```

No it was taking forever sooooooo I decided to take out the water and ions to see if that speeds things up
- to do this I made indicies of each of the four peptides on the membrane and then made four separate trajectories
- I tried the following command to break down the trajectory and also center the molecules```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p1_memb.xtc -center yes -pbc mol``` but it was going slower than the rms
- My new hypothesis is that this was taking so long due to the calculation of the center of mass and I'm going to try doing these separately to speed up the process ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p1_memb.xtc```
- Still takes too much time so I'm going to try doing just the protein
	- Still ends up being about the same amount of time so I'm assuming its the reading of the file that's the stop-gap. I'm going to use the .trr file instead as there's a lot less data there and get the membrane/protein .xtc from there

I used
```/usr/local/gromacs/bin/gmx trjconv -f md.trr -n index.ndx -s md.tpr -o p1_memb.xtc -center yes -pbc mol```
for each of the corresponding peptides
And did not finish these as they were taking too long while my other simulation was running

##### Prep of each protein

I wanted to go back and try the fun way of breaking down the simulations into each protein on the membrane
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p1_memb.xtc -center yes -pbc mol```
I centered on the membrane/protein combo and output that same group for p1

for p2 I did
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p2_memb.xtc -center yes -pbc mol```
and selected peptide 2 for centering and membrane/peptide output

for p3 I did
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p3_memb.xtc -center yes -pbc mol```
This time I centered on the membrane and output the membrane and protien

for p4 I did
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p4_memb.xtc -center yes -pbc mol```
I also centered on the membrane/protein in this one as well

##### Back to RMS

To start I ran this command
```/usr/local/gromacs/bin/gmx rms -f p1_memb.xtc -s md.tpr -o 1p_rms.xvg -n index.ndx -ng 1 -dt 10```
- and got hit with the error that I didn't change the topology so I made a new one titled RMS.tpr 
- This warning led me to the gmx convert-tpr command to help me get a matching tpr file

so I tried the following command to edit the tpr into a useable form
```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n index.ndx -o p1_memb.tpr```
and it worked!!!
I then did the same thing for the other three trajectories but with different out names p2-p4

so now I can hopefully run these god forsaken rms commands
I did the following command and changed the timestep to every 20 ps as this is what was output to the 
```/usr/local/gromacs/bin/gmx rms -f p1_memb.xtc -s p1_memb.tpr -o 1p_rms.xvg -n index.ndx -ng 1 -dt 20```
for which I chose the the alpha carbons for one group and got the error
##### Error
```
*** Error in `/usr/local/gromacs/bin/gmx': malloc(): memory corruption: 0x00000000034c6960 ***
======= Backtrace: =========
/lib64/libc.so.6(+0x7dd7d)[0x7fe2f4052d7d]
/lib64/libc.so.6(__libc_calloc+0xb4)[0x7fe2f4055b64]
/usr/local/gromacs/bin/gmx[0x51b030]
/usr/local/gromacs/bin/gmx[0x709bea]
/usr/local/gromacs/bin/gmx[0x440171]
/usr/local/gromacs/bin/gmx[0x40c695]
/lib64/libc.so.6(__libc_start_main+0xf5)[0x7fe2f3ff6c05]
/usr/local/gromacs/bin/gmx[0x41131e]
======= Memory map: ========
00400000-0312c000 r-xp 00000000 08:02 12328188                           /usr/local/gromacs/bin/gmx
0332c000-0332f000 r--p 02d2c000 08:02 12328188                           /usr/local/gromacs/bin/gmx
0332f000-03344000 rw-p 02d2f000 08:02 12328188                           /usr/local/gromacs/bin/gmx
03344000-0334c000 rw-p 00000000 00:00 0 
033f3000-0361f000 rw-p 00000000 00:00 0                                  [heap]
7fe2ec000000-7fe2ec021000 rw-p 00000000 00:00 0 
7fe2ec021000-7fe2f0000000 ---p 00000000 00:00 0 
7fe2f3979000-7fe2f3d5e000 rw-p 00000000 00:00 0 
7fe2f3fd5000-7fe2f418d000 r-xp 00000000 08:02 11928270                   /usr/lib64/libc-2.17.so
7fe2f418d000-7fe2f438d000 ---p 001b8000 08:02 11928270                   /usr/lib64/libc-2.17.so
7fe2f438d000-7fe2f4391000 r--p 001b8000 08:02 11928270                   /usr/lib64/libc-2.17.so
7fe2f4391000-7fe2f4393000 rw-p 001bc000 08:02 11928270                   /usr/lib64/libc-2.17.so
7fe2f4393000-7fe2f4398000 rw-p 00000000 00:00 0 
7fe2f4398000-7fe2f43ad000 r-xp 00000000 08:02 11942504                   /usr/lib64/libgcc_s-4.8.5-20150702.so.1
7fe2f43ad000-7fe2f45ac000 ---p 00015000 08:02 11942504                   /usr/lib64/libgcc_s-4.8.5-20150702.so.1
7fe2f45ac000-7fe2f45ad000 r--p 00014000 08:02 11942504                   /usr/lib64/libgcc_s-4.8.5-20150702.so.1
7fe2f45ad000-7fe2f45ae000 rw-p 00015000 08:02 11942504                   /usr/lib64/libgcc_s-4.8.5-20150702.so.1
7fe2f45ae000-7fe2f45d3000 r-xp 00000000 08:02 11929156                   /usr/lib64/libgomp.so.1.0.0
7fe2f45d3000-7fe2f47d2000 ---p 00025000 08:02 11929156                   /usr/lib64/libgomp.so.1.0.0
7fe2f47d2000-7fe2f47d3000 r--p 00024000 08:02 11929156                   /usr/lib64/libgomp.so.1.0.0
7fe2f47d3000-7fe2f47d4000 rw-p 00025000 08:02 11929156                   /usr/lib64/libgomp.so.1.0.0
7fe2f47d4000-7fe2f48d5000 r-xp 00000000 08:02 11928278                   /usr/lib64/libm-2.17.so
7fe2f48d5000-7fe2f4ad4000 ---p 00101000 08:02 11928278                   /usr/lib64/libm-2.17.so
7fe2f4ad4000-7fe2f4ad5000 r--p 00100000 08:02 11928278                   /usr/lib64/libm-2.17.so
7fe2f4ad5000-7fe2f4ad6000 rw-p 00101000 08:02 11928278                   /usr/lib64/libm-2.17.so
7fe2f4ad6000-7fe2f4bbf000 r-xp 00000000 08:02 11928315                   /usr/lib64/libstdc++.so.6.0.19
7fe2f4bbf000-7fe2f4dbf000 ---p 000e9000 08:02 11928315                   /usr/lib64/libstdc++.so.6.0.19
7fe2f4dbf000-7fe2f4dc7000 r--p 000e9000 08:02 11928315                   /usr/lib64/libstdc++.so.6.0.19
7fe2f4dc7000-7fe2f4dc9000 rw-p 000f1000 08:02 11928315                   /usr/lib64/libstdc++.so.6.0.19
7fe2f4dc9000-7fe2f4dde000 rw-p 00000000 00:00 0 
7fe2f4dde000-7fe2fb035000 r-xp 00000000 08:02 12202997                   /usr/local/cuda-10.0/targets/x86_64-linux/lib/libcufft.so.10.0.145
7fe2fb035000-7fe2fb234000 ---p 06257000 08:02 12202997                   /usr/local/cuda-10.0/targets/x86_64-linux/lib/libcufft.so.10.0.145
7fe2fb234000-7fe2fb244000 rw-p 06256000 08:02 12202997                   /usr/local/cuda-10.0/targets/x86_64-linux/lib/libcufft.so.10.0.145
7fe2fb244000-7fe2fb292000 rw-p 00000000 00:00 0 
7fe2fb292000-7fe2fb299000 r-xp 00000000 08:02 11928300                   /usr/lib64/librt-2.17.so
7fe2fb299000-7fe2fb498000 ---p 00007000 08:02 11928300                   /usr/lib64/librt-2.17.so
7fe2fb498000-7fe2fb499000 r--p 00006000 08:02 11928300                   /usr/lib64/librt-2.17.so
7fe2fb499000-7fe2fb49a000 rw-p 00007000 08:02 11928300                   /usr/lib64/librt-2.17.so
7fe2fb49a000-7fe2fb49c000 r-xp 00000000 08:02 11928276                   /usr/lib64/libdl-2.17.so
7fe2fb49c000-7fe2fb69c000 ---p 00002000 08:02 11928276                   /usr/lib64/libdl-2.17.so
7fe2fb69c000-7fe2fb69d000 r--p 00002000 08:02 11928276                   /usr/lib64/libdl-2.17.so
7fe2fb69d000-7fe2fb69e000 rw-p 00003000 08:02 11928276                   /usr/lib64/libdl-2.17.so
7fe2fb69e000-7fe2fb6b5000 r-xp 00000000 08:02 11928296                   /usr/lib64/libpthread-2.17.so
7fe2fb6b5000-7fe2fb8b4000 ---p 00017000 08:02 11928296                   /usr/lib64/libpthread-2.17.so
7fe2fb8b4000-7fe2fb8b5000 r--p 00016000 08:02 11928296                   /usr/lib64/libpthread-2.17.so
7fe2fb8b5000-7fe2fb8b6000 rw-p 00017000 08:02 11928296                   /usr/lib64/libpthread-2.17.so
7fe2fb8b6000-7fe2fb8ba000 rw-p 00000000 00:00 0 
7fe2fb8ba000-7fe2fb8db000 r-xp 00000000 08:02 11928263                   /usr/lib64/ld-2.17.so
7fe2fba63000-7fe2fbac2000 rw-p 00000000 00:00 0 
7fe2fbad7000-7fe2fbadb000 rw-p 00000000 00:00 0 
7fe2fbadb000-7fe2fbadc000 r--p 00021000 08:02 11928263                   /usr/lib64/ld-2.17.so
7fe2fbadc000-7fe2fbadd000 rw-p 00022000 08:02 11928263                   /usr/lib64/ld-2.17.so
7fe2fbadd000-7fe2fbade000 rw-p 00000000 00:00 0 
7fff54520000-7fff54541000 rw-p 00000000 00:00 0                          [stack]
7fff54580000-7fff54582000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
Abort (core dumped)
```

***
##### RMS again
So I reran ```/usr/local/gromacs/bin/GMXRC```
and then the command to which I got the error again but with a different memory corruption

I then exited the shell and re-entered to rerun the GMXRC and this time nothing bad happened. Maybe it was due to the environment being reset through my failed sudo access. But I don't know if a failed sudo access does that like a successful one.

I re-ran the command but I had to set the nice level to 10 for it to get any appreciable speed. It seemed like I hit a point of diminishing returns with the nice level when I went up to 20

anyways I got it to work even though I set the niceness wayyyyyy too high for both the md command and the analysis command

##### RMSD with nojump included going to redo the trajectory making with the no jump command to see if that fixes the RMSD
For p1 I did this command for the four trajectories to fix my mistake
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p1_memb_nojump.xtc -center yes -pbc nojump```
I centered on the membrane/protein combo and output that same group for p1

For p2
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p2_memb_nojump.xtc -center yes -pbc nojump```
and selected peptide 2 for centering and membrane/peptide output

For p3\
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p3_memb_nojump.xtc -center yes -pbc nojump```
This time I centered on the membrane and output the membrane and protien

For p4
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p4_memb_nojump.xtc -center yes -pbc nojump```
I also centered on the membrane/protein in this one as well




NOW NOW NOW NOW NOW
RMSD time
```/usr/local/gromacs/bin/gmx rms -f p1_memb_nojump.xtc -s p1_memb.tpr -o 1p_rms_nojump.xvg -n index.ndx -ng 1 -dt 10 -nice 0```
for which I chose the carbon alphas for least squares fit and root mean squared deviation.
- weirdly, I saw only 54% cpu usage with the nice level set to 0 (which it somehow receives sudo privileges for)
checked my previous commands to make sure

for p2 I did the following with no nice component
```/usr/local/gromacs/bin/gmx rms -f p2_memb_nojump.xtc -s p2_memb.tpr -o 2p_rms_nojump.xvg -n index.ndx -ng 1 -dt 10```
and at a nice level of 19 it gets a cpu usage of 91%

for p3 I did
```/usr/local/gromacs/bin/gmx rms -f p3_memb_nojump.xtc -s p3_memb.tpr -o 3p_rms_nojump.xvg -n index.ndx -ng 1 -dt 10 -nice -19```
I tried with the -19 nice rating but It ended up defaulting to 0 and tanked the cpu usage again

for p4 I ran
```/usr/local/gromacs/bin/gmx rms -f p4_memb_nojump.xtc -s p4_memb.tpr -o 4p_rms_nojump.xvg -n index.ndx -ng 1 -dt 10```
and got about 90 percent cpu usage


Solution is found in [[PBC Issue#Solution]]

##### RMSF
this is what my RMSF command looks like


For the third replicate it looks pretty equilibrated over 409ns-1000ns
```/usr/local/gromacs/bin/gmx rmsf -f p3_memb_nojump.xtc -s p3_memb.tpr -o 1p_400ens_rms_nojump.xvg -n index.ndx -dt 10 -b 409570 -e 1000000```

For all 4 protein replicates
```/usr/local/gromacs/bin/gmx rmsf -f p1_memb_nojump.xtc -s p1_memb.tpr -o 1p_750ens_rms_nojump.xvg -n index.ndx -dt 10 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx rmsf -f p2_memb_nojump.xtc -s p2_memb.tpr -o 2p_750ens_rms_nojump.xvg -n index.ndx -dt 10 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx rmsf -f p3_memb_nojump.xtc -s p3_memb.tpr -o 3p_750ens_rms_nojump.xvg -n index.ndx -dt 10 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx rmsf -f p4_memb_nojump.xtc -s p4_memb.tpr -o 4p_750ens_rms_nojump.xvg -n index.ndx -dt 10 -b 750000 -e 1000000```


##### Min Dist

~~Order does matter for the speed of the calculation!!!!~~
This command is being really weird and it's very specific for some reason the way the GMXRC is called and whether the calculation actually starts


```/usr/local/gromacs/bin/gmx mindist -f p1_memb_nojump.xtc -s p1_memb.tpr -od 1p_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```
I chose the p1 and the "other" index as the molecules of interest here. 
I should do the ends of the protein and maybe use a lower timescale tomorrow on the last 250 ns of the simulation as that's what we're doing the snapshot extraction on

for p2 I did
```/usr/local/gromacs/bin/gmx mindist -f p2_memb_nojump.xtc -s p2_memb.tpr -od 2p_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```
went much quicker since I chose the membrane first in relation to the protein

for p3 I did
```/usr/local/gromacs/bin/gmx mindist -f p3_memb_nojump.xtc -s p3_memb.tpr -od 3p_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

for p4 I did
```/usr/local/gromacs/bin/gmx mindist -f p4_memb_nojump.xtc -s p4_memb.tpr -od 4p_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

To do mindist on the terminal chains I used
r LYS & 26
to index the c terminal residue lysine (logical and) in the 26 index which was the protein molecule
I then did 
r THR & 26
to index the n terminal residue threonine (logical and) in the 26 index which was the lone protein

then I did mindist on either of the terminii for each protein end chain. I had to specify each of the end termii in the indexing portion of the command


for p1
```/usr/local/gromacs/bin/gmx mindist -f p1_memb_nojump.xtc -s p1_memb.tpr -od 1p_lys_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```
Looked freek ass ![[Pasted image 20240911122218.png]]



```/usr/local/gromacs/bin/gmx mindist -f p1_memb_nojump.xtc -s p1_memb.tpr -od 1p_thr_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

for p2 I did
```/usr/local/gromacs/bin/gmx mindist -f p2_memb_nojump.xtc -s p2_memb.tpr -od 2p_lys_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

```/usr/local/gromacs/bin/gmx mindist -f p2_memb_nojump.xtc -s p2_memb.tpr -od 2p_thr_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

for p3 I did
```/usr/local/gromacs/bin/gmx mindist -f p3_memb_nojump.xtc -s p3_memb.tpr -od 3p_lys_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

```/usr/local/gromacs/bin/gmx mindist -f p3_memb_nojump.xtc -s p3_memb.tpr -od 3p_thr_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

for p4 I did
```/usr/local/gromacs/bin/gmx mindist -f p4_memb_nojump.xtc -s p4_memb.tpr -od 4p_lys_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```

```/usr/local/gromacs/bin/gmx mindist -f p4_memb_nojump.xtc -s p4_memb.tpr -od 4p_thr_nojump_mindist.xvg -dt 100 -n index.ndx -b 750000 -e 1000000```


Since some of the min dist calculations looked a little weird I'm gonna get some pdbs and send them to mala
```/usr/local/gromacs/bin/gmx trjconv -f p1_memb_nojump.xtc -s p1_memb.tpr -o p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```

#### Other analysis
##### compressibility term
***
I was looking at the mdp file and noticed the compressibility factor we use is standard for a isothermal temperature of 300 and we're doing 310k. I tried to calculate the isothermal compressibility factor by doing
```gmx energy -f md.edr -o p1_isothermal_compressibility.xvg -fluct_props yes```
and selecting vol and temperature

but this doesn't work since the xy plane is different from the z plane
***

##### Radius of gyration


#### Creating fun tiny trajectories to look at
##### Jumpped trajectories
used 
```/usr/local/gromacs/bin/gmx trjconv -f p3_memb.xtc -s p3_memb.tpr -o p3_memb_jump.pdb -dt 10000```
for the jumpable pdb with 100 frames as a quick check

and I will create a none jumpable one soon

##### No jummped trajectories

I did blah
```/usr/local/gromacs/bin/gmx trjconv -f p2_memb.xtc -s p2_memb.tpr -o p2_memb_nojump.pdb -dt 10000```

may have forgotten to output the .xtc as the nojump version
for p3 I did
```/usr/local/gromacs/bin/gmx trjconv -f p3_memb_nojump.xtc -s p3_memb.tpr -o p3_memb_nojump.pdb -dt 10000```

for the analysis of the 1st weirdo protein that I may not have no jummped I used this command on the full trajectory
```gmx trjconv -f p1_memb_nojump.xtc -s p1_memb.tpr -o p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```

for the 4p protein that looked like it was super close I did
```gmx trjconv -f p4_memb_nojump.xtc -s p4_memb.tpr -o p4_750ns_memb_nojump.pdb -b 750000 -e 750000```

#### End products (Fake)
***
For all xvg files I converted them to .txt files by deleting the header and changing the file type
***
First I did 
```gmx traj -f md.xtc -s min.gro -ob box.xvg``` 
To look at the box size of the simulation throughout the trajectory

In matlab I then used this box sizing to calculate area per lipid as well as the coordinate vectors over time
***
I wanted total potential energy:
```gmx energy -f md.edr -o mdenergy.xvg -skip 10```
- and I selected the potential option and then I had to hit enter again cuz it just waits for another term otherwise
***
For RMSD of each protein with nojump

For p1 I did this command for the four trajectories to fix my mistake
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p1_memb_nojump.xtc -center yes -pbc nojump```
I centered on the membrane/protein combo and output that same group for p1

For p2
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p2_memb_nojump.xtc -center yes -pbc nojump```
and selected peptide 2 for centering and membrane/peptide output

For p3\
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p3_memb_nojump.xtc -center yes -pbc nojump```
This time I centered on the membrane and output the membrane and protien

For p4
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o p4_memb_nojump.xtc -center yes -pbc nojump```
I also centered on the membrane/protein in this one as well


I also had to convert the initial tpr file to just the membrane and protein for each individual proteins. 
```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n index.ndx -o p1_memb.tpr```
so I used this command 4 times


#### End products (real)

For all xvg files I converted them to .txt files by deleting the header and changing the file type
***
##### Box analysis
First I did 
```gmx traj -f md.xtc -s min.gro -ob box.xvg``` 
To look at the box size of the simulation throughout the trajectory

In matlab I then used this box sizing to calculate area per lipid as well as the coordinate vectors over time
***
##### Potential energy
I wanted total potential energy:
```gmx energy -f md.edr -o mdenergy.xvg -skip 10```
- and I selected the potential option and then I had to hit enter again cuz it just waits for another term otherwise
***
##### Trajectory conversion and pdb makin
For trajectory conversion I did the following

Make an index of the individual proteins, their alpha carbons, and the protein with the membrane

For p1 trj
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p1.xtc -pbc res -center -box -1 -1 15```
- For pdb
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p1.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
For p2 trj
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p2.xtc -pbc res -center -box -1 -1 15```
- For pdb
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p2.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
For p3 trj
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p3.xtc -pbc res -center -box -1 -1 15```
- for pdb
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p3.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
For p4 trj
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p4.xtc -pbc res -center -box -1 -1 15```
- for pdb
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p4.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```

***
##### RMSD
```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o res_p1.tpr```
```/usr/local/gromacs/bin/gmx rms -f res_p1.xtc -s res_p1.tpr -o 1p_res_rms.xvg -n new_index.ndx -ng 1 -dt 10```
![[Screenshot 2024-09-23 at 10.37.27 PM.png]]
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p1_115490.pdb -pbc res -center -box -1 -1 15 -b 115490 -e 115490```


