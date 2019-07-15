import Scripts.mhFileReader as fr
from pymol import cmd
import pymol
from tkinter import filedialog
import Scripts.ColoringTools as ct
import os

#Can switch Featurecolumn between 8 and 9 depending on if you want "total" or "percentage"
def MolHM(td, pdb, Ab, bins):
    os.chdir(str(td))
    pdbname = pdb
    pdbname = str(pdbname)
    Antibody = Ab
    Antibody = str(Antibody)
    numBins = bins
    numBins = int(numBins)

    #build relations between Bin and Color
    if numBins ==1:
        BinColorDic={'Blue':'Residue Percent Bin 1.csv'}
    elif numBins ==2:
        BinColorDic = {'Blue': 'Residue Percent Bin 1.csv', 'Red': 'Residue Percent Bin 2.csv'}
    elif numBins ==3:
        BinColorDic = {'Blue': 'Residue Percent Bin 1.csv', 'Red': 'Residue Percent Bin 2.csv','Yellow': 'Residue Percent Bin 3.csv'}
    elif numBins ==4:
        BinColorDic = {'Blue': 'Residue Percent Bin 1.csv', 'Red': 'Residue Percent Bin 2.csv',
                       'Yellow': 'Residue Percent Bin 3.csv',
                       'Pink': 'Residue Percent Bin 4.csv'}
    elif numBins ==5:
        BinColorDic = {'Blue': 'Residue Percent Bin 1.csv', 'Red': 'Residue Percent Bin 2.csv',
                       'Yellow': 'Residue Percent Bin 3.csv','Pink': 'Residue Percent Bin 4.csv', 'Brown': 'Residue Percent Bin 5.csv'}
    elif numBins ==6:
        BinColorDic = {'Blue': 'Residue Percent Bin 1.csv', 'Red': 'Residue Percent Bin 2.csv',
                       'Yellow': 'Residue Percent Bin 3.csv',
                       'Pink': 'Residue Percent Bin 4.csv', 'Brown': 'Residue Percent Bin 5.csv',
                       'Green': 'Residue Percent Bin 6.csv'}

    #BinColorDic={'Pink':'Residue Percent Bin 1.csv'}


    ResiMax={}
    #specify the feature used to color degree
    FeatureColumn=9
    #get designate pdb file
    # pdbname=filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select PDB file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
    #build Color model for each Color
    choices = {'RED': [255,[255,0,0]], 'BLUE': [255,[0,0,255]],'YELLOW':[255,[255,255,0]],'GREEN':[255,[0,255,0]],
               'PURPLE':[255,[128,0,128]],'PINK':[255,[255,105,180]],'BROWN':[255,[139,69,19]]}


    #launch pymol GUI Interface
    # pymol.finish_launching()

    #load PDB file into pymol visualization
    cmd.load(pdbname)

    #Coloring all residues to white
    ##cmd.color('grey80','all')
    cmd.do("color grey80, all")


    #Coloring residues in Bin to its corresponding color
    for key,value in BinColorDic.items():
        #pre conversion of RawData type
        RawData=fr.openCSV(value)[1:]
        for x in RawData:
            x[FeatureColumn]=float(x[FeatureColumn].strip('%'))
        InputList=choices.get(key.upper())

        #Color the selected bin with designate color
        ResiMax=ct.ColorResidues(InputList[0], InputList[1], key, RawData,ResiMax,FeatureColumn)

    cmd.show('spheres','all')


    BlueRes=''
    GreenRes=''
    RedRes=''
    YellowRes=''
    # PurpleRes=''
    BrownRes=''
    PinkRes=''
    for key,value in ResiMax.items():
        if value[1].upper()=='BLUE':
            BlueRes=BlueRes+'res '+key+' '
            cmd.select('Blue', BlueRes)
        elif value[1].upper()=='RED':
            RedRes=RedRes+'res '+key+' '
            cmd.select('Red', RedRes)

        elif value[1].upper()=='GREEN':
            GreenRes=GreenRes+'res '+key+' '
            cmd.select('Green', GreenRes)

        # elif value[1].upper()=='PURPLE':
        #     PurpleRes=PurpleRes+'res '+key+' '
        elif value[1].upper()=='BROWN':
            BrownRes=BrownRes+'res '+key+' '
            cmd.select('Brown', BrownRes)

        elif value[1].upper()=='PINK':
            PinkRes=PinkRes+'res '+key+' '
            cmd.select('Pink', PinkRes)

        elif value[1].upper()=='YELLOW':
            YellowRes=YellowRes+'res '+key+' '
            cmd.select('Yellow', YellowRes)

    # cmd.select('Blue',BlueRes)
    # cmd.select('Red',RedRes)
    # cmd.select('Green',GreenRes)
    # # cmd.select('Purple',PurpleRes)
    # cmd.select('Brown',BrownRes)
    # cmd.select('Pink',PinkRes)
    # cmd.select('Yellow',YellowRes)


    cmd.save(Antibody + "_Molecular_Heatmap.pse")














