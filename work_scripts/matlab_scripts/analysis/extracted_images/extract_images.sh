#!/bin/bash

for file in ../*sim*/pictures_of_data/Simulation\ ?:\ *\ -\ \ Hydrogen\ Bonding\ Summary\ from\ 750ns\ to\ 1000ns.pdf; do cp "$file" ./hbond_summary; done