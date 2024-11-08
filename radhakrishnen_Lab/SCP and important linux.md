---
Date Created: 2024-08-22 09:26
aliases: 
Daily Link: "[[2024-08-22]]"
---
---
### SCP
I forget this stupid command every time

to "local" from server
```scp zak@iron.wellesley.edu:/home/zak/.../filename ./```

from server to local
```scp -T username@ip.of.server.copyfrom:"file1.txt file2.txt" "~/yourpathtocopy"```


### nice priorities

Need to do this so you can allocate cpu resources
- It seems to me you can only decrease priority(numerically higher) with the nice command if you don't have sudo access
- You can decrease the priority if you don't which is why I'm going to try decreasing the gmx mdrun command and then running my analysis on the relatively higher priority(lower numerically)
- I think you can also increase priority if and only if you don't go into the negative numbers
	- Wrong Wrong Wrong

To try this my I used ```ps -ef``` to get the command PID
```/usr/local/gromacs/bin/gmx mdrun -s md.tpr -o md.trr -x md.xtc -c md.gro -g md.log -e md.edr -cpi state.cpt```
command was running on the PID 433744

and then cross referenced this PID with the priority listed on ps -el
it had a priority of 0
\
You can also run ```ps -elf``` but it's a little harder to read

so I ran ```renice 1 -p 433744``` to set the priority of my mdrun 1 lower than the default. this will allow me to run analysis at the same time at a faster rate

The ```top``` command will also show you the nice levels of current commands and also display their cpu/memory usage
