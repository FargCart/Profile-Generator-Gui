import os


def proteinInteraction(filename, chain1, chain2):
    nfile = str(filename)
    chain1 = str(chain1)
    chain2 = str(chain2)
    os.system("$schrodinger/run protein_interaction_analysis.py -structure "+(nfile)+"_balanced_models.maegz"+ " -group1 "+(chain1)+ " -group2 "+(chain2)+" -outfile "+ (nfile)+"_interaction_tables.csv")
