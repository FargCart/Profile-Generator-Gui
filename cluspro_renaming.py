
import os

#will rename the cluspro files that you download to their appropriate dock type!

def theRename(ab):
    ab = str(ab)
    ab = ab+"_"
    ab = str(ab)

    for filename in os.listdir("."):
        if filename.startswith("model.000"):
            os.rename(filename, ab+"balanced_"+filename)

    for filename in os.listdir("."):
        if filename.startswith("model.002"):
            os.rename(filename, ab+"electrostatic-favored_"+filename)

    for filename in os.listdir("."):
        if filename.startswith("model.004"):
            os.rename(filename, ab+"hydrophobic-favored_"+filename)
            
    for filename in os.listdir("."):
        if filename.startswith("model.006"):
            os.rename(filename, ab+"vdw+elec_"+filename)



