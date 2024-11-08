---
Date Created: 2024-08-12 10:31
aliases: 
Daily Link: "[[2024-08-12]]"
---
---
## Electrostatics and Gibbs
delta G can be split into multiple parts and so we really only focus on the electrostatic aspects
- we focus on the charge distribution or how a charge is spread over a molecule
	- The Desolvation penalty is the energy required to rip the solvent off the receptor or the molecule.
	- <mark style="background: #FF5582A6;">The biggest issue</mark> is finding a way to make the binding as strong as possible, biggest seperation of charges for the receptor and ligand, while still making the desolvation penalty low

## The continuum electrostatic model

As a disclaimer we do not use coulomb's law which is discussed below. We use a more fundamental equation called the poisson equation.

We approximate a molecule by saying it is globular shape of interacting point charges
 - We also use the theory behind coulombs law to estimate this force of interaction![[Pasted image 20240812105712.png]]
 - Mala gives the electric potential energy equation and not exactly coulomb's law. coulomb's constant also equals (N\*\M\*\M) / (C\*\C).
 - We want to treat water as a bulk continuum for continuum electrostatics as water screens electrostatic interactions
 - We use a <mark style="background: #BBFABBA6;">Linear Response Model</mark> for how water responds to a point charge.
	 - if we double the charge of an atom the reaction field strength from the water, or polarization response, is linearly proportional the the inducing charge
		 - <mark style="background: #FF5582A6;">But But But</mark>.... This leads to squared relationship due to coulomb's law since the force or electric potential energy is involving both the charge terms
		 - Another way of saying this is that the solvation energies are proportional to the charge squared
		 - water is one of the most polarizable substances with it's dielectric constant of 80. This dielectric is accounted for in the equation with the dielectric in the denominator and this screens interactions in water by 1/80th
- We now model the interiors of biomolecules as a electric medium as well even though it isn't as accurate
	- <mark style="background: #FF5582A6;">But But But....</mark> this leads to a spatially variant dielectric constant and thus render coulomb's law useless. We then use the poisson-boltzmann equation
		- The poisson equation is shown below. The laplacian is essentially the partial derivative in three coordinate directions and thus we use phi function (it calculates the electrical potential (V\*C) of the three coordinates) and the laplacian with respect to X Y and Z.![[Screenshot 2024-08-12 at 11.46.31 AM.png]]

Short little linearized poisson-Boltzmann aside:

> From wikee-pee-di-a
> ![[Screenshot 2024-08-12 at 11.53.14 AM.png]]

The initial equation is a little hard to understand but it appears to be saying the divergence of the vector field, the electric displacement field (C\*m<sup>-2</sup>), is equal to the scalar free charge density which has the units of C\*m<sup>-3</sup> 

![[Screenshot 2024-08-13 at 7.39.39 AM.png]]\

This equation can the allow us to say that the vector field of electric displacement is equal to the permittivity of the medium multiplied by the vector electric field (V\*m)


![[Screenshot 2024-08-13 at 7.23.37 AM.png]]
In electrostatics, we assume that there is no magnetic field (the argument that follows also holds in the presence of a constant magnetic field).


 This following equation is essentially saying that the electric field (V\*m) is equal to the negative gradient of the electric potential (since phi is the electric potential (V) taking the derivative with respect to distance gives us the electric vector field)
![[Screenshot 2024-08-13 at 7.05.28 AM.png]]

The minus sign is introduced so that we can find the minima of the gradient vector field rather than the maxima since the gradient operator finds maxima inherently. I think this is right but you know, idk

This leads to the derivation

![[Screenshot 2024-08-13 at 8.04.05 AM.png]]

where we get the laplacian (the divergence of the gradient) is equal to the negative scalar field of the charge density divided by the permittivity of the field

To actually solve this is a different matter:

We need to know the charge density distribution where we assume, for the ions in water I think, follow a Boltzmann distribution. We can't just use the standard permittivity constant due to ions in water. 

<mark style="background: #BBFABBA6;">Back to the video</mark>:

The poisson equation gives us the potential (V) as a function of our system's charge distribution so del<sup>2</sup>φ(x,y,z) = -4πρ(x,y,z)
- <mark style="background: #FF5582A6;">We don't use this poisson equation exactly</mark> as we need something a little easier to solve than the laplacian so we use a different equation in the solver and something called the <mark style="background: #BBFABBA6;">Linearized Poisson-Boltzmann equation</mark> because we use ions in the equation![[Screenshot 2024-08-13 at 8.41.44 AM.png]]
- Because we can never have an analytical function of the potential (V) at every point in a simulation, we must use a grid to discretize the function

<mark style="background: #FF5582A6;">Need to continue</mark>

## Charge optimization

The basic idea is you want the atoms to be as charged as possible without too high of a desolvation penalty and this method is how you find the optimal values
- Part of this is the idea behind the linear response model that creates the reaction field (it is a model)

When thinking of charge optimization we need to first think about ligand binding as an event and how to properly model the multiple charge interactions
Instead of taking a lot of time to write out the full ligand desolvation penalty equation, we can rewrite it as a vector matrix product.

## New understanding and workflow

#### LPBE - Grid Sizing - Radii File - Get Potential

LPBE is used to get potential (voltage) at each point along the grid sizing
- We can't use coulombs law as we have a varying dielectric medium due to ions
	- Thus we use the boltzmann variant of the poisson equation to account for the variability in the dielectric gradient
- To get a dielectric medium and to make computations more cheap, we use the continuum electrostatics model to define the borders for dielectrics
	- To do this we need the radii file to get the shape of the continuum
- We can't solve the LPBE analytically due to the fact it's a differential equation. we need to make approximations and so we use the grid spacing method to solve the<mark style="background: #BBFABBA6;"> differential equation</mark> it numerically there
	- We have to choose a higher grid number to get a good resolution of the simulation while balancing the computational cost
	- We use offsets to shift the grid around slightly to minimize error due to this being a numerical  solution
	- due to the whole integration thing leaving a +c at the end, we need to set boundary conditions so we can solve the integration of the partial differential equation
		- if we do a really high grid resolution we get good insight into the core parts of the grid but bad boundary conditions 
		- if we want good boundary conditions, we have to do calculations in a stepwise process.

potential (voltage) is then multiplied by charge at every point in the ligand (maybe receptor too?) to get free energy


### Workflow

---
#### First step - LPBE - old solver

need: make_radii.py, partial_charge_opt_create.py, partial_charge_opt_analyze.py, partial_charge_opt_config.txt, partial_charge_opt_func.py

First - partial_charge_opt_config.txt
- I changed the crd_file
	- still got no clue what this one is but I've been putting the path to the origional snapshot
- changed the ATOM_RANGE_OF_RECEPTOR and ATOM_RANGE_OF_LIGAND
	- Givin the ranges
- I changed the MONOPOLE to 6
	- self explanatory
- I upped CHARGE_CONSTRAINT by one
	- self explanatory
- changed the PATH_OF_DIR and PATH_OF_FILES in a way consistent with maya's. I'm unsure exactly what the convention was though
	- PATH_OF_DIR - relates to the directories to be created
	- PATH_OF_FILES - relates to the files already created 
- for testing I changed the snapshot only to 750000
	- self explanatory, will be a pain in the ass to automate
- SIM_DIR_NAMES I got no clue what to name this man
	- This is equivalent to my p1-p4 directories


Secondly - Partial_charge_opt_func.py
- I changed the oldpath variable to fit /p1
- I also changed the step 3 crdFileName to bf2wt.crd
	- And in step three I also changed the script to take out "snapshots" and replaced it with the directory number
- I commented out a make_radii call and rewrote it in the Partial_charge_opt_func.py script



---
Second step - Optimizing Charge