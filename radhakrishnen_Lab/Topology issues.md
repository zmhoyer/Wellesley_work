```/usr/local/gromacs/bin/gmx editconf -f out5_solvdel.gro -o out5_solvdel.pdb```
after fixing the horrific .gro file and mutating it I tried: (I don't know how I feel about the ignore hydrogens flag)
```/usr/local/gromacs/bin/gmx pdb2gmx -f normal_fixedv2.pdb -o normal_fixedv2_ignh.gro -inter -ignh```
- gross output, not doing that
```/usr/local/gromacs/bin/gmx pdb2gmx -f normal_fixedv2.pdb -o normal_fixedv2_ignh.gro -inter -chainsep -ter```
- no difference really so I made a new pdb with ARGN mutation instead of ARG
- ```/usr/local/gromacs/bin/gmx pdb2gmx -f ARGN_fixedv3.pdb -o ARGN_fixedv3.gro -inter```



> J Lemkul states: 
> The purpose of pdb2gmx is to write a topology. You already have that. The .itp  
> format (typically the topology of a single entity) is hardly different from that  
> of a .top (which is a system topology). A .top file:  
>   
> 1. #includes or otherwise has parameters from a parent force field  
> 2. Has a [system] directive  
> 3. Has a [molecules] directive  
>   
> Your topology from ATB is based on a GROMOS force field parameter set, which is  
> probably already in GROMACS and you can therefore start your .top with a  
> suitable #include statement to that parent force field. Then #include your  
> .itp, add [system] and [molecules], and you have a functional .top file.  
>   
> As for format conversion, use editconf, not pdb2gmx. But you don't have to use  
> .gro (a common misconception).

> J Lemkul states
> > So, instead of 128 separate lipid molecules I get one molecule with 128 residues. Am I doing something wrong, or is this really how lipids are treated in GROMACS topologies?
> > -random commenter
>
> This is the expected behavior of `pdb2gmx`. It makes no functional difference for the simulation whether you treat the lipids like a “solvent” and `#include` an `.itp` file or have a very verbose topology. `grompp` treats the information the same way, and an `#include` statement just gets expanded N times based on the contents of `[molecules]`
> 