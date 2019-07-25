import os


def proteinInteraction(filename):
    nfile = str(filename)


    os.system("$schrodinger/run protein_interaction_analysis.py -structure " + nfile +
              "_balanced_models.maegz" + " -group1 A -group2 H,L " +
              " -outfile " + nfile + "_interaction_tables.csv")
