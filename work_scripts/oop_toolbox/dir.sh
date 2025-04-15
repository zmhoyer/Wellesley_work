#!/usr/bin/env bash

for ((in=4; in>=1 ; in-=1)); do for ((i=1000000; i>=750000; i-=2500)); do mkdir -p ./p''$in/$i''ps/; done; done
for ((in=4; in>=1 ; in-=1)); do for ((i=1000000; i>=750000; i-=2500)); do scp zak@iron.wellesley.edu:'/teaching/zak/1_wildtype_sim_partialchargeopt_snapshots/p'$in'/'$i'ps/initial_p'$in'_memb'$i'.crd' ./p''$in/$i''ps/; done; done
