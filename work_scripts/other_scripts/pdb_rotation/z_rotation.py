#!/usr/bin/env python

import argparse
import os 

read_rotmap = open("1p_rotmat.xvg", 'r')
rotational_matrix_dictionary = {}
read_file_lines = read_rotmap.readlines()
for line in read_file_lines:
    if line[0]== "@" or line[0] == "#":
        pass
    else:
        key = line.split()[0]
        value = line.split()[1:]
        rotational_matrix_dictionary.update({key: value})


read_pdb = open("rotxy+transxy_then_translation_p1.pdb", 'r')
temp_pdb = open("temp.pdb", 'w')
read_file_lines = read_pdb.readlines()




centroid_dictionary = {}
average_component_counter = 0
x_coordinate_total = 0
y_coordinate_total = 0
z_coordinate_total = 0
for line in read_file_lines:
    record_name = str(line[:7].strip())
    
    if record_name == "REMARK" or record_name == "MODEL" or record_name == "ENDMDL":
        pass

    elif record_name == "TITLE":
        time = int(float(line[30:40].strip()))
        key = time

    elif record_name == "TER":
        x_coordinate_average = x_coordinate_total/average_component_counter
        y_coordinate_average = y_coordinate_total/average_component_counter
        z_coordinate_average = z_coordinate_total/average_component_counter

        value = [x_coordinate_average,y_coordinate_average,z_coordinate_average]
        centroid_dictionary.update({key: value})
        average_component_counter = 0
        x_coordinate_total = 0
        y_coordinate_total = 0
        z_coordinate_total = 0


    elif record_name == "CRYST1": 
        pass

    else:
        x_pos = float(line[31:39].strip())
        y_pos = float(line[39:47].strip())
        z_pos = float(line[47:55].strip())


        x_coordinate_total = x_coordinate_total+x_pos
        y_coordinate_total = y_coordinate_total+y_pos
        z_coordinate_total = z_coordinate_total+z_pos

        average_component_counter = average_component_counter+1

read_pdb.close()





read_pdb = open("rotxy+transxy_then_translation_p1.pdb", 'r')

for line in read_file_lines:
    record_name = str(line[:7].strip())
    
    if record_name == "REMARK" or record_name == "MODEL" or record_name == "TER" or record_name == "ENDMDL":
        temp_pdb.write(line)

    elif record_name == "TITLE":
        time = int(float(line[30:40].strip()))
        temp_pdb.write(line) 

    elif record_name == "CRYST1": 
        crys_record_name = str(line[:7].strip())
        x_box_vector = float(line[7:16].strip())
        y_box_vector = float(line[16:25].strip())
        z_box_vector = float(line[25:34].strip())
        alpha = float(line[34:41].strip())
        beta = float(line[41:48].strip())
        gamma = float(line[48:55].strip())


        half_x_box_vector = x_box_vector/2
        half_y_box_vector = y_box_vector/2
        half_z_box_vector = z_box_vector/2

        temp_pdb.write(line)

    else:
        atom_record_name = str(line[:7].strip())
        atom_num = int(line[7:12].strip())
        atom_name = str(line[12:16].strip())
        altLoc = str(line[16:17].strip())
        res_name = str(line[17:22].strip())
        chain_name = str(line[22:23].strip())
        res_seq = int(line[23:27].strip())
        icode = str(line[27:28].strip())
        x_pos = float(line[31:39].strip())
        y_pos = float(line[39:47].strip())
        z_pos = float(line[47:55].strip())
        occupancy = float(line[55:61].strip())
        temp_factor = float(line[61:67].strip())
        seg_id = str(line[67:77].strip())
        element = str(line[77:79].strip())
        charge = str(line[79:].strip())

        #centroid centering
        if time in centroid_dictionary:
            translated_x_pos = x_pos-(float(centroid_dictionary[time][0]))
            translated_y_pos = y_pos-(float(centroid_dictionary[time][1]))
            translated_z_pos = z_pos-(float(centroid_dictionary[time][2]))


        #box vector centering
        # translated_x_pos = x_pos-half_x_box_vector
        # translated_y_pos = y_pos-half_y_box_vector
        # translated_z_pos = z_pos-half_z_box_vector

        if str(time) in rotational_matrix_dictionary:
            xx = float(rotational_matrix_dictionary[str(time)][0])
            xy = float(rotational_matrix_dictionary[str(time)][1])
            yx = float(rotational_matrix_dictionary[str(time)][3])
            yy = float(rotational_matrix_dictionary[str(time)][4])
        elif str(time) not in rotational_matrix_dictionary:
            print("frame not found in rotational matrix")

        #need to use the inverse of the matrix
        rotated_x = (translated_x_pos*xx) + (translated_y_pos*yx) + 0
        rotated_y = (translated_x_pos*xy) + (translated_y_pos*yy) + 0
        rotated_z = 0 + 0 + (translated_z_pos*1)


        #centroid centering
        if time in centroid_dictionary:
            final_x = rotated_x+(float(centroid_dictionary[time][0]))
            final_y = rotated_y+(float(centroid_dictionary[time][1]))
            final_z = rotated_z+(float(centroid_dictionary[time][2]))

        #box vector centering
        # final_x = rotated_x+half_x_box_vector
        # final_y = rotated_y+half_y_box_vector
        # final_z = rotated_z+half_z_box_vector

        if len(atom_name) == 4:
            temp_pdb.write("{:<6s}{:>5d} {:<4s}{:1s}{:<4s}{:1s}{:>4d}{:1s}   {:>8.3f}{:>8.3f}{:>8.3f}{:>6.2f}{:>6.2f}{:<10s}{:>2s}{:2s}\n".format(atom_record_name,atom_num,atom_name,altLoc,res_name,chain_name,res_seq,icode,final_x,final_y,final_z,occupancy,temp_factor,seg_id,element,charge))
        else: #aka, if the atom name has three or less letters start in coulmn 14 rather than 13
            temp_pdb.write("{:<6s}{:>5d}  {:<3s}{:1s}{:<4s}{:1s}{:>4d}{:1s}   {:>8.3f}{:>8.3f}{:>8.3f}{:>6.2f}{:>6.2f}{:<10s}{:>2s}{:2s}\n".format(atom_record_name,atom_num,atom_name,altLoc,res_name,chain_name,res_seq,icode,final_x,final_y,final_z,occupancy,temp_factor,seg_id,element,charge))
 

read_pdb.close()
temp_pdb.close()