#!/usr/bin/env python

'''
A mess of a file, will become obsolete as I get better at coding and start working
with oop paradigms more

NOT COOL SCRIPT :(

'''

import subprocess

class crdtools():
    '''
    This is a class used to modify crds. I have it set up so that after the object is initialized
    you can call methods that work on the coordinate lines themselves. My thinking was that if I 
    were to add methods in the future I could think soley in terms of an individual line and once
    you know how you want to change the coordinate lines all you have to do is write a little code
    to change the line and not have to focus on formatting or reading through the lines. I think
    the downsides of writing the class this way is that it's a little convoluted logic wise and 
    I'm unsure how fixable it'll be if it breaks in the future. This is my first time working with
    classes so let's hope for it's longevity.

    File set up:
    -class variables, init, and other dunders if I ever use them
    -file reading and function calling per line. Functions that are used a lot and can work modularly
    -method pairs. First method is to call the loop method for the specific tool and the second
    method is the actual function as it works on a single line.

    Warning - I would be very carful about altering the first two sections as those are utilized
    for more than one method. If the structure of something in section 2 needs to be changed it 
    may be best to copy the method and create a modified one in the method pair section if using
    the original file or just do whatever if it's a copy of the original crd.py file.

    In theory, this should be pretty modular and a small amount of code per function but we shall 
    see. I don't think there needs to be any more sections as I'd split up other file types to 
    other classes in their own files.
    '''
 ########   

 ######## class variables, init, and other dunders if I ever use them ########

 ######## 
    

    max_box_vector = 0000.00000

 ########

 ########

    def __init__(self, crd, length_of_polypeptide):
        '''
        I'm learning how to use classes so I chose to create an object for crds that
        automatically give some useful variables. 
        '''
        self.x_men, self.x_max, self.y_min, self.y_max, self.z_mien, self.z_max = 0000.00000, 0000.00000, 0000.00000, 0000.00000, 0000.00000, 0000.00000
        self.init_crd_name = crd
        self.method_count = 0
        self.length_of_polypeptide = length_of_polypeptide

 ########

 ######## file reading and function calling per line ########

 ########

    def crd_flexible(self, crd_lines, method, *args):
        '''
        This is different from the method loop_through_crd (next method) as it allows a little more
        flexibility in what lines are actually being altered. This function is used a litte 
        differently than loop_through_crd in the way that you control which lines you feed into 
        it and when. It can get convoluted but gives more flexibility. The main issue with using 
        loop_through_crd is that all the lines are altered and sent back to the method 
        calling it AFTER the function has been run on each line of coordinates. In most cases,
        this methodology works because you know you want to alter all lines. In the case of
        fixing residue names that may be in different orders and different lengths it may be
        hard to know how many lines you want to change and what you want to change them to.
        '''
        self.called_method = method

        for line in crd_lines:
            if line[0] == '*' or line.strip().isdigit():
                yield line
            else:
                self.atom_id = int(line[:5].strip())
                self.res_id = int(line[5:10].strip())
                self.res_type = line[10:16].strip()
                self.atom_type = line[16:20].strip()
                self.x_pos = float(line[21:30].strip())
                self.y_pos = float(line[31:40].strip())
                self.z_pos = float(line[41:50].strip())
                self.chain_name = line[51:52].strip()
                self.chain_id = int(line[56:61].strip())
                self.charge = float(line[62:].strip()) #till 70
                #variable function thing

                self.called_method(*args)

                #format output to crd style
                #return value
                yield "{:>5d}{:>5d} {:<4s} {:<4s}{:>10.5f}{:>10.5f}{:>10.5f} {:<4s} {:<4d}{:>10.5f}\n".format(self.atom_id, self.res_id, self.res_type, self.atom_type, self.x_pos, self.y_pos, self.z_pos, self.chain_name, self.chain_id, self.charge)  





    #comprehensive loop with file creation
    def loop_trough_crd(self, method, *args):
        '''
        I want this method to loop through a crd and perform the function that called it.
        I know this is probably a bad way to do things as this is over-abstracted and may 
        make the logic hard to follow. My whole reasoning for doing it this way is to 
        focus on later methods in a way that modifies CRDs one line at a time rather than 
        the collection to hopefully streamline the editing process.
        '''
        self.called_method = method

        if self.method_count == 1:
            self.crd = open(self.init_crd_name, 'r')
            crd_readlines = self.crd.readlines()
        else:
            self.crd = open("final"+str(int(self.method_count) - 1)+"_"+self.init_crd_name, 'r')
            crd_readlines = self.crd.readlines()
            

        for line in crd_readlines:

            if line[0] == '*' or line.strip().isdigit():
                yield line
            else:
                self.atom_id = int(line[:5].strip())
                self.res_id = int(line[5:10].strip())
                self.res_type = line[10:16].strip()
                self.atom_type = line[16:20].strip()
                self.x_pos = float(line[21:30].strip())
                self.y_pos = float(line[31:40].strip())
                self.z_pos = float(line[41:50].strip())
                self.chain_name = line[51:52].strip()
                self.chain_id = int(line[56:61].strip())
                self.charge = float(line[62:].strip()) #till 70
                #variable function thing

                self.called_method(*args)

                #format output to crd style
                #return value
                yield "{:>5d}{:>5d} {:<4s} {:<4s}{:>10.5f}{:>10.5f}{:>10.5f} {:<4s} {:<4d}{:>10.5f}\n".format(self.atom_id, self.res_id, self.res_type, self.atom_type, self.x_pos, self.y_pos, self.z_pos, self.chain_name, self.chain_id, self.charge)  
                
                #x instance variable
                if self.x_pos > self.x_max:
                   self.x_max = self.x_pos
                if self.x_pos < self.x_men:
                   self.x_men = self.x_pos
                #y instance variable
                if self.y_pos > self.y_max:
                   self.y_max = self.y_pos
                if self.y_pos < self.y_min:
                   self.y_min = self.y_pos
                #z instance variable
                if self.z_pos > self.z_max:
                   self.z_max = self.z_pos
                if self.z_pos < self.z_mien:
                   self.z_mien = self.z_pos

 ########
                
 ########

    def itp_dictionary(self, *itps): 
        self.itp_dict = {}
        for itp_file in itps[0]:
            # to read and create a list of dictionaries from the itp files, 
            # indexed to 0 because it's a tuple that contains the list of itps in [0]
            home_itp_file = "../../"+itp_file
            with open(home_itp_file, "r") as itp:
                itp_readlines = itp.readlines()
                for index, line in enumerate(itp_readlines):
                    if line == "[ atoms ]\n":
                        atom_index = index
                    elif line == "[ bonds ]\n":
                        bond_index = index

                for index, line in enumerate(itp_readlines):
                    if index > atom_index and index < bond_index:
                        if line[0] == ";" or line[0] == "\n":
                            continue
                        else:
                            self.itp_nr = int(line[:6].strip())
                            self.itp_type = str(line[6:17].strip())
                            self.itp_residu = str(line[24:33].strip())
                            self.itp_atom = str(line[33:40].strip())
                            self.itp_charge = float(line[47:58].strip())
                            
                            if self.itp_residu == "HISH":
                                self.itp_residu = "HIS" #necessary because The crd2pdb script cuts off the H making it mismatch the itp file
                            
                            #More verbose dictionary but a unique ID will need to be reconstructed. might be even better to try and get it verbose someday and have that be the standard #itp_dict = dict([("itp_nr", self.itp_nr), ("itp_type", self.itp_type), ("res_type", self.itp_residu), ("atom_type", self.itp_atom), ("charge", self.itp_charge)])
                            unique_ID_key, charge_value = str(self.itp_residu+"_"+self.itp_atom), (self.itp_charge)
                            self.itp_dict[unique_ID_key] = charge_value

 ########

 ######## method pairs ########

 ########
            
    def rechain(self):
        self.method_count += 1
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:
            for line in (list(crdtools.loop_trough_crd(self, crdtools.rechain_func, self))): 
                #here loopthrough crd is called and fed the method I want to call and then the arguments that method needs
                file.write(line)
        self.crd.close()
        return

    
 #now it's sent to loop_through_crd and the below method will get called
    

    def rechain_func(self): 
        '''
        A method for rechaining a protein_membrane crd. It sets the protein to P and the membrane to M.
        Easy to read too :)
        '''
        if self.atom_id <= self.length_of_polypeptide:
            self.chain_name = "L"
        else:
            self.chain_name = "R"
            
 ########
        
 ########

    def atom_type_number_move(self):
        self.method_count += 1
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:
            for line in (list(crdtools.loop_trough_crd(self, crdtools.atom_type_number_move_func, self))): 
                #here loopthrough crd is called and fed the method I want to call and then the arguments that method needs
                file.write(line)
        self.crd.close()
        return


 #now it's sent to loop_through_crd and the below method will get called
    

    def atom_type_number_move_func(self):
        '''
        Testing to see if the first symbol of the atom type is a number and if it is it gets moved
        to the back of the end of the atom type
        '''
        if self.atom_type[:1].isdigit() == True: 
            #I'm fairly confident this works as the only time the atom type spits is when there are 4 alpha-nuemerics(pretentious nounage)
            self.atom_type = str(self.atom_type[1:2]+self.atom_type[2:3]+self.atom_type[3:]+self.atom_type[0])
        
 ########
        
 ########

    def charge_fixin(self, *itps):
        self.method_count += 1
        crdtools.itp_dictionary(self, itps[0])
        #I used itps[0] as the *itps arguments are written to the first index, as a list, in a tuple. This gives us the list of dictionaries for atoms
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:
            for line in (list(crdtools.loop_trough_crd(self, crdtools.charge_fixin_func, self))): 
                file.write(line)
        self.crd.close()
        return


 #now it's sent to loop_through_crd and the below method will get called
    

    def charge_fixin_func(self):
        
        #random starting alias that has no chance of being a residue type (I hope)
        alias = "yippe_yay_woo"
        

        #aliase functionality
        if self.res_type == "POE":
            alias = "POPE"
        elif self.res_type == "POG":
            alias = "POPG"
        
        #serch itp dictionaries for matching atom name to find charge
        for key in self.itp_dict:
            if key.split("_")[0] == self.res_type or key.split("_")[0] == alias:
                if key.split("_")[1] == self.atom_type:
                    self.charge = self.itp_dict[key]

 ########
        
 ########

    def translation(self):

        self.init_min_x = self.x_men 
        self.init_min_y = self.y_min
        self.init_min_z = self.z_mien
        self.init_max_x = self.x_max
        self.init_max_y = self.y_max
        self.init_max_z = self.z_max 

        self.method_count += 1
        box_vector = ((self.init_max_x - self.init_min_x)**2 + (self.init_max_y - self.init_min_y)**2 + (self.init_max_z - self.init_min_z)**2)**0.5
        crdtools.max_box_vector = box_vector if box_vector > crdtools.max_box_vector else crdtools.max_box_vector 
        
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:
            for line in (list(crdtools.loop_trough_crd(self, crdtools.translation_func, self))): 
                file.write(line)
        self.crd.close()
        return


 #now it's sent to loop_through_crd and the below method will get called
    

    def translation_func(self): 
        #Translate so the bottom left corner is 000 by subtracting each of the min coordinates there

        #self.x_pos = float(self.x_pos) - float(self.init_min_x)
        #self.y_pos = float(self.y_pos) - float(self.init_min_y)
        #self.z_pos = float(self.z_pos) - float(self.init_min_z)

        #center on zero by translating each coordinate by half what's left of the box in the positive coordinates

        self.x_pos = float(self.x_pos) + float(0-(self.init_min_x + self.init_max_x)/2)
        self.y_pos = float(self.y_pos) + float(0-(self.init_min_y + self.init_max_y)/2)
        self.z_pos = float(self.z_pos) + float(0-(self.init_min_z + self.init_max_z)/2)

 ########
        
 ########

    def dummy(self, dummy_offset):
        '''
        I would totally translate the box to center on zero before placing the dummy atoms.
        Translating them all to 0 occurs first and then they get centered to 0 based on their 
        own box vectors. After this occurs the dummy atoms will be placed according to a certain
        specified distance away from the min and max coordinates along the box vector so everything
        has a consistant box size

        

        for looping over multiple files I need to figure out a way to reset the max coordinate
        values as those will stay too big otherwise
        '''
        print(crdtools.max_box_vector)
        self.dummy_offset = dummy_offset
        self.method_count += 1
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:
            for line in (list(crdtools.loop_trough_crd(self, crdtools.dummy_func, self))):
                if line.strip().isdigit():
                    self.final_atom_num = int(line.strip())
                    self.new_atom_count = int(line) + 2
                    file.write(str(self.new_atom_count)+"\n")
                elif line.strip()[0] == "*":
                    file.write(line)
                elif int(line[:5].strip()) == self.final_atom_num: #can't use self.atom_id here as that's now equal to the last atom id. This is because the entire file is read before being printed to a list here.
                    
                    half_max_box_vector = crdtools.max_box_vector/2 
                    print(half_max_box_vector)

                    dummy_coor = ((((half_max_box_vector**2)/3)**0.5) + self.dummy_offset)

                    dummy_atom_placce_neg = dummy_coor * (-1)
                    print(dummy_atom_placce_neg)

                    dummy_atom_placce_pos = abs(dummy_coor)
                    print(dummy_atom_placce_pos)

                    file.write((line+str(self.final_atom_num+1)+"  "+str(self.res_id+1)+" DUM  D1  {:>10.5f}{:>10.5f}{:>10.5f} D    "+str(self.chain_id+1)+"    0.00000\n"+str(self.final_atom_num+2)+"  "+str(self.res_id+2)+" DUM  D2  {:>10.5f}{:>10.5f}{:>10.5f} D    "+str(self.chain_id+2)+"    0.00000").format(dummy_atom_placce_neg, dummy_atom_placce_neg, dummy_atom_placce_neg, dummy_atom_placce_pos, dummy_atom_placce_pos, dummy_atom_placce_pos))
                else:
                    file.write(line)
        self.crd.close()
        return


 # Hi, for symmetries sake


    def dummy_func(self):
        # I know it's bad pratice putting this dummy funct here to be called each line but I 
        # couldn't think of another(easy) way to fix the issue with no method being called for the crd loop funciton
        pass
        
 ########
        
 ########

    def residue_name_fix(self):
        '''
        In this case, if you need more molecules re-named you can just rewrite the 
        dictionary to include the residue name you want in the crd and it's length. 
        An issue occurs if there's already a residue with the same length as another one

        For this method, I am hard coding a dictionary for molecule lengths that need to be fixed.
        In this case, it seems soooooo specific to four letter residue type's that it doesn't
        seem worth it to introduce another .itp flag to automatically read the molecule type
        (which may not even be the residue_type name) and rename it. 
        '''
        self.method_count += 1

        if self.method_count == 1:
            self.residue_crd = open(self.init_crd_name, 'r')
            residue_crd_readlines = self.residue_crd.readlines()
        else:
            self.residue_crd = open("final"+str(int(self.method_count) - 1)+"_"+self.init_crd_name, 'r')
            residue_crd_readlines = self.residue_crd.readlines()


        atom_count = 0
        with open("final"+str(self.method_count)+"_"+self.init_crd_name, "w") as file:

            self.res_list = []
            #I create a list here so that we can identify the lines of a residue

            for line in residue_crd_readlines: #here 
                
                atom_count += 1
                
                if line[0] == '*':
                    #getting rid of comments or total atom number
                    atom_count = 0
                    file.write(line)
                    
                elif line.strip().isdigit(): 
                    atom_count = 0
                    file.write(line)
                    total_atom_count = int(line)                    
                elif int(line[:5].strip()) <= self.length_of_polypeptide:
                    #Just rewriting the protein as that shouldn't be changed
                    atom_count = 0
                    file.write(line)
                else:
                    #where each molecule is defined for the crd_flexible function
                    if atom_count == 1:
                        residue_num = line[5:10].strip()
                        self.res_list.append(line)
                    elif line[5:10].strip() == residue_num:
                        self.res_list.append(line)

                        #This next line is only for the last line of the file so it can write out the last residue
                        if int(line[:5].strip()) == total_atom_count:
                            for res_list_line in list(crdtools.crd_flexible(self, self.res_list, crdtools.residue_name_fix_func, self)):
                                file.write(res_list_line)
                                                 
                    else:
                        for res_list_line in list(crdtools.crd_flexible(self, self.res_list, crdtools.residue_name_fix_func, self)):
                           file.write(res_list_line) 
                           #writing out all the edited res lines

                        atom_count = 1 #resetting the count for the new residue
                        self.res_list = [] #resetting the list to an empty one for the new residue
                        residue_num = line[5:10].strip() #resetting the residue number for the new residue
                        self.res_list.append(line) #appending the new first atom of the residue to the new residue list
    
        self.residue_crd.close()
        return
 
 
 #now it's sent to loop_through_crd and the below method will get called
    
 
    def residue_name_fix_func(self):

        residue_dict = {
        #residue length : residue name
        #if you want a different residue name that's not very intuitive comment what it means
        "127": "POG", #POPG
        "125": "POE" #POPE
        }
        for residue_length in residue_dict.keys():
            if len(self.res_list) == int(residue_length):
                self.res_type = residue_dict[residue_length]
        return
 
 ########
        
 ########

    def housekeeping(self, **kwargs):
        '''
        This is a function for general house keeping with discrete options. They don't have
        to be in any particular order the dictionary just needs to be passed as so:

        first function: rename, name
        This will rename the final script to whatever name is specified

        second function: remove, (True/False)
        This function will remove previous files if desired

        The requirement for the housekeeping function is that it needs to be performed last
        after all other arguments.

        '''
        
        rename = kwargs.get("rename")
        remove = kwargs.get("remove")
        
        if rename != None:
           subprocess.Popen(["cp", "final"+str(self.method_count)+"_"+self.init_crd_name, rename]) 

        if remove != None:
            for x in range(1, int(self.method_count)+1):
                subprocess.Popen(["rm", "final"+str(x)+"_"+self.init_crd_name])
        
        return

            
 ########
        
 ######## 
