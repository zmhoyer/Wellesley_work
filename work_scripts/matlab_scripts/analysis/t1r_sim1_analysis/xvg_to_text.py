#!/usr/bin/env python

# To use this file quicker you can do "-f *.xvg" to turn all .xvg files to text files without having to type the individual names

import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument('-f', '--files', help='files you want converted to .txt files without headings', required=True, nargs='+')
parser.add_argument('-e', '--extension', help='what extension should these be changed to', required=False, default=".txt")
args = parser.parse_args()

file_list = args.files
extension = args.extension

for file in file_list:

    file_name, original_extension = os.path.splitext(file)
    read_file = open(file, 'r')
    write_file = open(file_name+extension, 'w')

    for line in read_file:
        if line[0] == "@" or line[0] == "#":
            pass
        else:
            write_file.write(line)

    write_file.close()
    read_file.close()


