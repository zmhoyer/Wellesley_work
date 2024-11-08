---
Date Created: 2024-08-13 08:49
aliases: 
Daily Link: "[[2024-08-13]]"
---
---

1. Calculate the delta G binding free energy using the linearized poisson Boltzmann equation at varying grid sizes until numerical convergence is seen
	- We have to use the finite difference method since we can't solve the infinite derivatives. This finite difference is due to the grid spacing
	- We can split the ΔG into three parts:
		- The LDP - ligand desolvation penalty energy
			- unfavorable
		- The RDP - Receptor desolvation penalty energy
			- unfavorable
		- The INT - the interaction energy. Looking at the bound state only if we charge up the receptor and allow the partners to interact
			- Hopefully a favorable term
	- <mark style="background: #BBFABBA6;">How do we do this?</mark>
		- We need to define the bound and unbound states - For the bound states, depending on whether we are calculating RDP or LDP, we will charge up the receptor or ligand of interest but not allow them to interact with the other. The unbound is self explanatory\
			- Where and what the point charges are
				- From the CRD file
			- Where the dielectric boundary is
				- The radius file specifies the radius for every atom in the simulation and the CRD will give you the positions. Further solver information is defined in the param file 
		- We need to tell the solver the parameters
			- see [[2024-07-30]]
		-  We then use the run file to specify the bound/unbound states to calculate the potentials
2. Do a charge optimization

