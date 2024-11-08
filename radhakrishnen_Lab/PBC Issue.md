***

### PBC issue

PBC issue - Our images are getting distorted visually. I guess I'll try a separated trajectory conversion workflow to try and fix it


#### Try 1

2. Extract first frame from trajectory or use the rn input file for step 
3. Convert trajectory to -pbc nojump to take out jumps 
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n index.ndx -s md.tpr -o no_cent_p1_memb_nojump.xtc -pbc nojump```
	- Index according to protein and lipids
4. Center the atom using -pbc mol or something or another 
	- Create the p1_memb.tpr by using the command:
		- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n index.ndx -o p1_memb.tpr```
		- This is done because in later calculations with the indexed trajectory, no water or ions, it will appear as if there is a mismatch with the starting structure, md.tpr, that includes those atoms.
	- ```/usr/local/gromacs/bin/gmx trjconv -f no_cent_p1_memb_nojump.xtc -n index.ndx -s p1_memb.tpr -o cent_p1_memb_nojump.xtc -pbc mol -center```
		- I centered on the membrane/protein combo and output that same group for p1
		- 15332rm 
5. Do RMSD to check up on the peptide
	- ```/usr/local/gromacs/bin/gmx rms -f cent_p1_memb_nojump.xtc -s p1_memb.tpr -o cent_1p_rms_nojump.xvg -n index.ndx -ng 1 -dt 10```
6. Do a trajectory check
	- for the analysis of the 1st weirdo protein that I may not have no jummped I used this command on the full trajectory
	- ```gmx trjconv -f cent_p1_memb_nojump.xtc -s p1_memb.tpr -o cent_end250_p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```



#### Try 2


1. Restarting this workflow for the third time I think. Make an index file from the md.xtc
	- To make the index file from scratch```/usr/local/gromacs/bin/gmx make_ndx -f md.tpr -o new_index.ndx```
		- I made a protein index through    a 1-366
		- I made a p1_memb index through     12(other-membrane) | 27(p1 protein) 
	- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o p1_memb_new.tpr```
		- I chose the membrane and protein indexing I just made
2. Now I'm gonna run the nojumped trajectory command
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s p1_memb_new.tpr -o no_cent_p1_memb_nojump.xtc -pbc nojump```
		- Does not work. I think It's because of the TPR file
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o no_cent_p1_memb_nojump.xtc -pbc nojump```
		- It worked when I changed to the original .tpr file
3. I think since I created a new xtc file the index that's based off of the total system is essentially that and won't work due to the change in the numbering of atoms. So what I need to do now is find a new way to create a new index.
	- ```/usr/local/gromacs/bin/gmx make_ndx -f p1_memb_new.tpr -o p1_memb.ndx```
4. Now it's time for another trajectory conversion to center it. You have to use the previous index
	- ```/usr/local/gromacs/bin/gmx trjconv -f no_cent_p1_memb_nojump.xtc -n p1_memb.ndx -s p1_memb_new.tpr -o cent_p1_memb_nojump.xtc -pbc mol -center```
	- and you have to chose the system option (0) as the new index is the total subset of atoms in the new trajectory
	- As this previous one did not work I'm going to try this command
		- ```/usr/local/gromacs/bin/gmx trjconv -f no_cent_p1_memb_nojump.xtc -n p1_memb.ndx -s p1_memb_new.tpr -o 2_cent_p1_memb_nojump.xtc -pbc mol -center -ur compact```
	- Did not work so lets try the -fit option
		- ```/usr/local/gromacs/bin/gmx trjconv -f no_cent_p1_memb_nojump.xtc -n p1_memb.ndx -s p1_memb_new.tpr -o 3_cent_p1_memb_nojump.xtc -pbc mol -center -ur compact -fit translation```
			- I chose 0 to fit the entire system to the reference structure
	- one more time with the fit option but only fitting the membrane
		- ```/usr/local/gromacs/bin/gmx trjconv -f no_cent_p1_memb_nojump.xtc -n p1_memb.ndx -s p1_memb_new.tpr -o 4_cent_p1_memb_nojump.xtc -pbc mol -center -ur compact -fit translation```
5. Do RMSD to check up on the peptide
	- ```/usr/local/gromacs/bin/gmx rms -f cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o cent_1p_rms_nojump.xvg -n p1_memb.ndx -ng 1 -dt 10```
	- Once again because the first one didn't work
		- ```/usr/local/gromacs/bin/gmx rms -f 2_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 2_cent_1p_rms_nojump.xvg -n p1_memb.ndx -ng 1 -dt 10```
		- looking at the c-alphas
		- again but with the fit option 
			- ```/usr/local/gromacs/bin/gmx rms -f 3_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 3_cent_1p_rms_nojump.xvg -n p1_memb.ndx -ng 1 -dt 10```
		- again but with the new fit options
			- ```/usr/local/gromacs/bin/gmx rms -f 4_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 4_cent_1p_rms_nojump.xvg -n p1_memb.ndx -ng 1 -dt 10```
6. Do a trajectory check
	- for the analysis of the 1st weirdo protein that I may not have no jummped I used this command on the full trajectory
		- ```/usr/local/gromacs/bin/gmx trjconv -f cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o cent_end250_p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```
	- one more time since it didn't work the first time
		- ```/usr/local/gromacs/bin/gmx trjconv -f 2_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 2_cent_end250_p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```
		- chose whole system option
		- again but with the fit option
			- ```/usr/local/gromacs/bin/gmx trjconv -f 3_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 3_cent_end250_p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```
		- another with the new -fit option
			- ```/usr/local/gromacs/bin/gmx trjconv -f 4_cent_p1_memb_nojump.xtc -s p1_memb_new.tpr -o 4_cent_end250_p1_memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```


#### Try 3 - take out nojump from the workflow


The files new_index and p1_memb_new.tpr should be fine to use again as they're based off the md. files.
1. Going to begin by making sure the trajectory is whole and taking out unnecessary items like water and solvent
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o pre-cent_whole_p1memb.xtc -pbc whole```
2. Make a new index based off the trajectory with different atoms
	- ```/usr/local/gromacs/bin/gmx make_ndx -f p1_memb_new.tpr -o whole_p1_memb.ndx```
		- Visualize to see what this does by using this command
			- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n whole_p1_memb.ndx -o whole_p1_memb.tpr```
			- ```/usr/local/gromacs/bin/gmx trjconv -f pre-cent_whole_p1memb.xtc -s whole_p1_memb.tpr -o pre-cent_whole_p1memb.pdb -dt 1000 -b 750000 -e 1000000```
				- It looks as if atom bonds are being "stretched across the box due to jumping"
3. Use this index to center the molecules in the box. We'll work our way up from -pbc mol first and go through that pipeline before moving on to different -pbc options. I think it would also be beneficial to see how a no jump run would work here after defining whole. To save space I'll probably only output 300 or so frames. I'm gonna try a clustering before a nojump too.
	1. ```/usr/local/gromacs/bin/gmx trjconv -f pre-cent_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o mol_whole_p1memb.xtc -pbc mol -dt 1000 -b 750000 -e 1000000```
		- Failed out between 840000 and 850000 due to the molecule jumps
	2. ```/usr/local/gromacs/bin/gmx trjconv -f pre-cent_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o nojump_whole_p1memb.xtc -pbc nojump -dt 1000 -b 750000 -e 1000000```
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -s whole_p1_memb.tpr -o nojump_whole_p1memb.pdb```
			- looks horrible, still has bonds showing across the representation and it's weirdly diffused
	3. ```/usr/local/gromacs/bin/gmx trjconv -f pre-cent_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o cluster_whole_p1memb.xtc -pbc cluster -dt 1000 -b 750000 -e 1000000```
		- ```/usr/local/gromacs/bin/gmx trjconv -f cluster_whole_p1memb.xtc -s whole_p1_memb.tpr -o nojump_whole_p1memb.pdb```
			- nah, this jawn aint it
4. I'm going to attempt pbc cluster to see if clustering the atoms around the center of mass will give a better trajectory. I'm also going to attempt -pbc mol -ur rect -center  to see how that does. Also -pbc mol -ur compact -center. Also Also -pbc mol -ur compact -center -boxcenter rect.
	1. ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o cluster_nojump_whole_p1memb.xtc -pbc cluster```
		- ```/usr/local/gromacs/bin/gmx trjconv -f cluster_nojump_whole_p1memb.xtc -s whole_p1_memb.tpr -o cluster_nojump_whole_p1memb.pdb```
		- Worst one yet. Actually horrible
	2. ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o molrect_nojump_whole_p1memb.xtc -pbc mol -ur rect -center```
		- failed out due to molecule jumps across the boundary
		- Trying to use pbc atom
			- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o atomrect_nojump_whole_p1memb.xtc -pbc atom -ur rect -center```
				- ```/usr/local/gromacs/bin/gmx trjconv -f atomrect_nojump_whole_p1memb.xtc -s whole_p1_memb.tpr -o atomrect_nojump_whole_p1memb.pdb```
	3. ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o molcompactrect_nojump_whole_p1memb.xtc -pbc mol -ur compact -center -boxcenter rect```
		- failed out as well at the same point. 840000-850000 or so
		- going to try this again with atom
	4. I'm going to try a simple one with atom and mol
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_whole_p1memb.xtc -n whole_p1_memb.ndx -s whole_p1_memb.tpr -o atom_nojump_whole_p1memb.xtc -pbc atom```
			- ```/usr/local/gromacs/bin/gmx trjconv -f atom_nojump_whole_p1memb.xtc -s whole_p1_memb.tpr -o atom_nojump_whole_p1memb.pdb```


#### Try 4 - modified chatGPT edition
Got this all from chatGPT so blame him fo real

1. Cull the simulation
	- Made a new index
		- ```/usr/local/gromacs/bin/gmx make_ndx -f md.tpr -o chatgpt_p1_memb.ndx```
	- Made a new tpr
		- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n chatgpt_p1_memb.ndx -o chatgpt_p1_memb.tpr```
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n chatgpt_p1_memb.ndx -s md.tpr -o nojump_cull_p1memb.xtc -pbc nojump -dt 1000 -b 750000 -e 1000000```
		- Selection of membrane and protein
		- Visualized this -nojump trajectory
			- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o nojump_cull_p1memb.pdb```
			- looks bad, random ions floating around
	- I wanna try a -box and -center option without jumping
		- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n chatgpt_p1_memb.ndx -s md.tpr -o centerbox_p1memb.xtc -center -box 6.2 6.2 10 -dt 1000 -b 750000 -e 1000000```
			- viz
			- ```/usr/local/gromacs/bin/gmx trjconv -f centerbox_p1memb.xtc -s chatgpt_p1_memb.tpr -o centerbox_p1memb.pdb```
			- no way
		- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n chatgpt_p1_memb.ndx -s md.tpr -o wholecenterbox_p1memb.xtc -pbc whole -center -box 6.2 6.2 15 -dt 1000 -b 750000 -e 1000000```
			- ```/usr/local/gromacs/bin/gmx trjconv -f wholecenterbox_p1memb.xtc -s chatgpt_p1_memb.tpr -o wholecenterbox_p1memb.pdb```
			- just nah
2. Now we're going to try centering it to see if it matches with the first time I did this
	- first need to make the new index
		- ```/usr/local/gromacs/bin/gmx make_ndx -f p1_memb_new.tpr -o tired.ndx```\
	- Need to center it now... chose full system
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o mol_nojump_cull_p1memb.xtc -pbc mol -center```
		- Visualize 
			- ```/usr/local/gromacs/bin/gmx trjconv -f mol_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o mol_nojump_cull_p1memb.pdb```
			- It looks the same as it did before. It somehow fixed the lone atoms and I have no clue how
	- Doing this one but centered on the protein
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o molprobox_nojump_cull_p1memb.xtc -pbc mol -center -box 10.2 10.2 15```
			- 
	- Going to do two subsequent centerings. First on the membrane and then second on the protein.
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o molmemb_nojump_cull_p1memb.xtc -pbc mol -center```
			- ```/usr/local/gromacs/bin/gmx trjconv -f molmemb_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o molmemb_nojump_cull_p1memb.pdb```
			- didn't work
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o molmemb_nojump_cull_p1memb.xtc -pbc mol -center``` Didn't do
	- try it with the pbc res option centered on the membrane
		- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o resmemb_nojump_cull_p1memb.xtc -pbc res -center```
			- ```/usr/local/gromacs/bin/gmx trjconv -f resmemb_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o resmemb_nojump_cull_p1memb.pdb```
			- Better, a lot better, but it still had atom jumps
			- Im going to try this line of thinking but now centering on the protein/membrane combo and just the protein
			- ```/usr/local/gromacs/bin/gmx trjconv -f resmemb_nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o respromemb_resmemb_nojump_cull_p1memb.xtc -pbc res -center```
				- ```/usr/local/gromacs/bin/gmx trjconv -f respromemb_resmemb_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o respromemb_resmemb_nojump_cull_p1memb.pdb```
				- close
			- ```/usr/local/gromacs/bin/gmx trjconv -f resmemb_nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o respro_resmemb_nojump_cull_p1memb.xtc -pbc res -center```
				- ```/usr/local/gromacs/bin/gmx trjconv -f respro_resmemb_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o respro_resmemb_nojump_cull_p1memb.pdb```
	- Going to try setting the ur to compact alongside boxcenter rect and -ur compact -center(memb)
	- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o compactrect_nojump_cull_p1memb.xtc -ur compact -boxcenter rect```
		- ```/usr/local/gromacs/bin/gmx trjconv -f compactrect_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o compactrect_nojump_cull_p1memb.pdb```
	- ```/usr/local/gromacs/bin/gmx trjconv -f nojump_cull_p1memb.xtc -n tired.ndx -s chatgpt_p1_memb.tpr -o compactmemb_nojump_cull_p1memb.xtc -ur compact -center```
		- ```/usr/local/gromacs/bin/gmx trjconv -f compactmemb_nojump_cull_p1memb.xtc -s chatgpt_p1_memb.tpr -o compactmemb_nojump_cull_p1memb.pdb```



#### Final trys
1. ```/usr/local/gromacs/bin/gmx make_ndx -f md.tpr -o easy_memb.ndx```
2. ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n easy_memb.ndx -s md.tpr -o cull_p1memb.xtc -center -dt 1000 -b 750000 -e 1000000```
	- [```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n easy_memb.ndx -o cull_p1memb.tpr```](<```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n easy_memb.ndx -o cull_p1memb.tpr```>)
	- ```/usr/local/gromacs/bin/gmx trjconv -f cull_p1memb.xtc -s cull_p1memb.tpr -o cull_p1memb.pdb```
3. ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n easy_memb.ndx -s md.tpr -o 2_cull_p1memb.xtc -pbc nojump -center -dt 1000 -b 750000 -e 1000000```
	- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n easy_memb.ndx -o 2_cull_p1memb.tpr```
	- ```/usr/local/gromacs/bin/gmx trjconv -f 2_cull_p1memb.xtc -s cull_p1memb.tpr -o 2_cull_p1memb.pdb```


#### Redoing the first tries to do some stuff
1. ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o 1_centmemb_nojump.xtc -center yes -pbc nojump```
	- center on the membrane
	- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o p1memb_nojump.tpr```
	- ```/usr/local/gromacs/bin/gmx trjconv -f 1_centmemb_nojump.xtc -s p1memb_nojump.tpr -o p1memb_nojump.pdb -dt 1000 -b 750000 -e 1000000```
2. Individual snapshot extraction
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o p1_center.pdb -center yes -box -1 -1 15 -sep -dt 10000 -b 750000 -e 850000```
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o p1_whole_center.pdb -pbc whole -center yes -box -1 -1 15 -sep -dt 10000 -b 750000 -e 900000```
	- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p1_whole_center.pdb -pbc whole -center yes -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
		- Should work
		- For piscidin /data/pazgospel/piscidin3_wt_250ns_1/
		- ```/usr/local/gromacs/bin/gmx trjconv -f /data/pazgospel/piscidin3_wt_250ns_1/md.xtc -n /data/pazgospel/piscidin3_wt_250ns_1/Protein_DNA.ndx -s /data/pazgospel/piscidin3_wt_250ns_1/md_p_r.tpr -o check.pdb -pbc whole -center yes -box -13 13 13 -dt 1000```

To check the new protocal is working I used these commands all centering on the peptide

```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p2_whole_center.pdb -pbc whole -center yes -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p3_whole_center.pdb -pbc whole -center yes -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p4_whole_center.pdb -pbc whole -center yes -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
- no whole
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p4center.pdb -center yes -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o sep_p4_center.pdb -center -box -1 -1 15 -sep -dt 10000 -b 750000 -e 1000000```
	- no
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o p4_centerboxcenter.pdb -center -box -1 -1 15 -boxcenter rect -dt 10000 -b 750000 -e 1000000```
	- no
- ```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o check_p4_whole.xtc -pbc whole -box -1 -1 15 -dt 1000 -b 750000 -e 1000000```
	- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o check_p4_whole.tpr```
	- ```/usr/local/gromacs/bin/gmx make_ndx -f check_p4_whole.tpr -o check_p4_whole.ndx```
		- ```/usr/local/gromacs/bin/gmx trjconv -f check_p4_whole.xtc -n check_p4_whole.ndx -s check_p4_whole.tpr -o nocentmol_check_p4_whole.pdb -pbc mol```
		- no cent
		- ```/usr/local/gromacs/bin/gmx trjconv -f check_p4_whole.xtc -n check_p4_whole.ndx -s check_p4_whole.tpr -o memprocentmol_check_p4_whole.pdb -pbc mol -center```
		- centered on memb_prot
		- ```/usr/local/gromacs/bin/gmx trjconv -f check_p4_whole.xtc -n check_p4_whole.ndx -s check_p4_whole.tpr -o procentmol_check_p4_whole.pdb -pbc mol -center```
		- centered on prot

```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p4_854ns.pdb -pbc res -center -box -1 -1 15 -b 854000 -e 854000```
why did this workkkkkk

trying a little bit more :((

```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o compact_15_res_p1_115490ns.pdb -pbc res -center -box -1 -1 15 -ur compact -b 115490 -e 115490```

```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o 15_p1_115490ns.pdb -center -box -1 -1 15 -b 115490 -e 115490```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o atom_15_p1_115490ns.pdb -pbc atom -center -box -1 -1 15 -b 115490 -e 115490```

Final try before I die:
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o newres_p1_115490ns.xtc -pbc res -center -b 115490 -e 115490```
- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o res_p1_115490ns.tpr```
- ```/usr/local/gromacs/bin/gmx make_ndx -f res_p1_115490ns.tpr -o newres_p1_115490ns.ndx```
	- ```/usr/local/gromacs/bin/gmx trjconv -f newres_p1_115490ns.xtc -n newres_p1_115490ns.ndx -s res_p1_115490ns.tpr -o atom_res_p1_115490ns.pdb -pbc atom```
		- For trying a nojump at the end here
		- ```/usr/local/gromacs/bin/gmx trjconv -f newres_p1_115490ns.xtc -n newres_p1_115490ns.ndx -s res_p1_115490ns.tpr -o atom_res_p1_115490ns.xtc -pbc atom```
		- ```/usr/local/gromacs/bin/gmx trjconv -f atom_res_p1_115490ns.xtc -n newres_p1_115490ns.ndx -s res_p1_115490ns.tpr -o nojump_atom_res_p1_115490ns.pdb -pbc nojump```
	- or  ```/usr/local/gromacs/bin/gmx trjconv -f newres_p1_115490ns.xtc -n newres_p1_115490ns.ndx -s res_p1_115490ns.tpr -o centatom_res_p1_115490ns.pdb -pbc atom -center```
		- They look exactly the same

A quick atom center version
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o centatom_p1_movie.pdb -pbc atom -center -b 110000 -e 120000 -dt 100```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o centres_p1_movie.pdb -pbc res -center -b 110000 -e 120000 -dt 100```


```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o newres_p1_movie.xtc -pbc res -center -b 110000 -e 120000 -dt 100```
- ```/usr/local/gromacs/bin/gmx convert-tpr -s md.tpr -n new_index.ndx -o newres_p1_movie.tpr```
- ```/usr/local/gromacs/bin/gmx make_ndx -f newres_p1_movie.tpr -o newres_p1_movie.ndx```
	- ```/usr/local/gromacs/bin/gmx trjconv -f newres_p1_movie.xtc -n newres_p1_movie.ndx -s newres_p1_movie.tpr -o atom_res_p1_movie.pdb -pbc atom```



# Solution
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p4.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p3.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p2.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```
```/usr/local/gromacs/bin/gmx trjconv -f md.xtc -n new_index.ndx -s md.tpr -o res_p1.pdb -pbc res -center -box -1 -1 15 -dt 10000 -b 750000 -e 1000000```

- Trying it on Erini's
	- ```/usr/local/gromacs/bin/gmx trjconv -f /data/pazgospel/piscidin3_wt_250ns_1/md.xtc -n /data/pazgospel/piscidin3_wt_250ns_1/Protein_DNA.ndx -s /data/pazgospel/piscidin3_wt_250ns_1/md_p_r.tpr -o 2check.pdb -pbc res -center yes -center -dt 10000```

### RMSF and RMSD issues
"Similarly, for structures, averages will tend to be meaningless anytime there are separate metastable conformational states." From the GROMACS wiki
- I think this applies to us in the sense that the simulations should be taken with a grain of salt.


### Potential thermostat issue

Separating POPE and POPG for tc-grps may be introducing unnecessary artifacts into the calculation and I'm unsure whether POPG is sufficiently big enough to justify it's own thermostat

Looked at the max temperature of the p1_memb 
![[Pasted image 20240917220437.png]]
and the move I made from 519550 to 550000 didn't show too much except the peptide dug into the membrane like a tick. Not too important