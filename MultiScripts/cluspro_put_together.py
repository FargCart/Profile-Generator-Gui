import pymol
import os
from pymol import cmd

#STEP 2
#THIS SHOULD CREATE A MAEGZ FILE THAT IS SUITABLE TO RUN SCHRODINGERS PROTEIN INTERACTION ANALYSIS WITH.
#WILL NEED ALL OF THE FILES IN IN A SHARED FOLDER 



##fileN="D1.3_balanced_model.000."
##fileF="D1.3_balanced_models.maegz"
def putTogether(name):

    for i in range(0,30):
        cmd.do("load "+str(name)+"_balanced_model.000."+str(i).zfill(2)+".pdb")
        cmd.do("sele all")
        cmd.do("create "+str(name)+"_balanced_model.000."+str(i).zfill(2)+", sele")
        cmd.do("save "+str(name)+"_balanced_model.000."+str(i).zfill(2)+"_united.pdb, "+str(name)+"_balanced_model.000."+str(i).zfill(2))
        cmd.do("reinitialize")
        os.system("rm "+str(name)+"_balanced_model.000."+str(i).zfill(2)+".pdb")

    for z in range(0,30):
        cmd.do("load "+str(name)+"_balanced_model.000."+str(z).zfill(2)+"_united.pdb")
    cmd.do("reinitialize")
