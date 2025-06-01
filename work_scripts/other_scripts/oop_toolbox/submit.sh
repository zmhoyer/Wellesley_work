#!/usr/bin/env bash -

source /opt/homebrew/Caskroom/miniconda/base/bin/activate iron #source is refrencing the current shell, aka the child process

./crd.py -o bf2wt.crd -ob 60 60 100 -pi bf2.itp -oi POPE.itp POPG.itp

