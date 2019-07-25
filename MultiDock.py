'''

@author: Adam Closmore

'''
import os
import Scripts.cluspro_put_together as cpt
import MultiScripts.cluspro_renaming as cr
import MultiScripts.concatCSV as con
import MultiScripts.Create_bins_together as cbt
import MultiScripts.hb_nb_Heatmapgen as hm
import MultiScripts.hydrogenBondGen as hb
import MultiScripts.hydrophobicBondGen as nb
import MultiScripts.MolHeat as mh
import MultiScripts.percentr_contribution as pc
import MultiScripts.Sort_my_bins as smb
import MultiScripts.swapa as swap
import MultiScripts.Totals_Script as total
import tarfile
import shutil
import MultiScripts.Protein_Interaction_Analysis as pia
import re
import subprocess
from tkinter import *
from tkinter.ttk import *
from tkinter import filedialog
from tkinter import scrolledtext

# ids = ['296211', '296212', '296213']
# nms = ['D8', 'E12', 'H5']

window = Tk()
chk_state = BooleanVar()
chk_state.set(False)
window.geometry('600x400')
window.title("Multiple Ab Molecular Heatmap Generator")
allIDs = Label(window, text="What are all your Cluspro ID's?", font='Helvetica').grid(row=0)
allAbs = Label(window, text="What are all the Ab?", font='Helvetica').grid(row=1)
Ids = Entry(window)
Abs = Entry(window)
Ids.grid(row=0, column=1)
Abs.grid(row=1, column=1)




def userDirectory():
    global theirDirectory
    theirDirectory = filedialog.askdirectory()


directoryButton = Button(window, text="Select Directory", command=userDirectory)
directoryButton.grid(column=1, row=3)

def collectInput():

    theirID = Ids.get()
    names = Abs.get()

    splitID = theirID.split(' ')
    splitNames = names.split(' ')
    downloadDocks(splitID, splitNames, theirDirectory)


Button(window, text='Submit', command=collectInput).grid(row=5, column=1, stick=E)


def downloadDocks(theirID, names, theirDirectory):
    os.chdir(theirDirectory)
    os.mkdir('Project_interaction_tables')
    projTemp =''
    for listLength in range(0,len(names)):
        projTemp = projTemp + names[listLength] +'_'
    global projName
    projName = projTemp
    print(projName)
    for dock in range (0, len(theirID)):
        os.chdir(theirDirectory)
        global tid
        tid = str(theirID[dock])
        p = subprocess.run(["cluspro_download", tid], stderr=subprocess.PIPE)
        output = p.stderr
        output = output.decode('utf-8')
        fileTar = tarfile.open('cluspro.' + tid + '.tar.bz2')
        fileTar.extractall()
        os.remove('cluspro.' + tid + '.tar.bz2')
        os.chdir('cluspro.%s' % theirID[dock])
        abName = str(names[dock])
        cr.theRename(abName)
        os.mkdir('Balanced_models')
        os.mkdir('Electrostatic_models')
        os.mkdir('Hydrophobic_models')
        os.mkdir('Vdw_models')
        dirLength = [f for f in os.listdir('.') if re.search(r'balanced', f)]
        for balanced in range(0, len(dirLength)):
            shutil.move(dirLength[balanced], 'Balanced_models')
        dirLength = [f for f in os.listdir('.') if re.search(r'static', f)]
        for electrostatic in range(0, len(dirLength)):
            shutil.move(dirLength[electrostatic], 'Electrostatic_models')
        dirLength = [f for f in os.listdir('.') if re.search(r'phobic', f)]
        for hydro in range(0, len(dirLength)):
            shutil.move(dirLength[hydro], 'Hydrophobic_models')
        dirLength = [f for f in os.listdir('.') if re.search(r'vdw', f)]
        for vdw in range(0, len(dirLength)):
            shutil.move(dirLength[vdw], 'Vdw_models')

        print('Making Interaction Tables')
        os.chdir(str(theirDirectory))
        os.system("pwd")
        os.chdir('cluspro.' + tid)
        os.chdir('Balanced_models')
        cpt.putTogether(str(names[dock]))
        listLen = [f for f in os.listdir('.') if re.search(r'maegz', f)]

        # shutil.copy(str(theirDirectory) + '/Mac_Bonds/hbadd', str(theirDirectory) + '/cluspro.' + tid +
        #             '/Balanced_models')
        # shutil.copy(str(theirDirectory) + '/Mac_Bonds/hbplus', str(theirDirectory) + '/cluspro.' + tid +
        #             '/Balanced_models')

        # shutil.copy(str(theirDirectory) + '/Linux_Bonds/hbadd', str(theirDirectory) + '/cluspro.' + tid +
        #             '/Balanced_models')
        # shutil.copy(str(theirDirectory) + '/Linux_Bonds/hbplus', str(theirDirectory) + '/cluspro.' + tid +
        #             '/Balanced_models')



        for pdbFiles in range(0, len(listLen)):
            try:
                pia.proteinInteraction(listLen[pdbFiles])

                # hb.hydrogenBonds(str(listLen[pdbFiles]))
                # nb.hydrophobicBonds(str(listLen[pdbFiles]))
                # newHB = str(listLen[pdbFiles]).split('.pdb')
                # con.mergeThem(str(newHB[0]) + '_hb.csv', str(newHB[0]) + '_nnb.csv')
            except:
                pass
        # os.remove('hbadd')
        # os.remove('hbplus')
        itDir = [f for f in os.listdir('.') if re.search(r'_table', f)]
        for interTable in range(0, len(itDir)):
            shutil.move(itDir[interTable], theirDirectory + '/Project_interaction_tables')

        os.chdir('..')

    os.chdir(theirDirectory)
    os.chdir('Project_interaction_tables')
    hm.heatmap(names, projName)
    print("You now need to make a Community Plot")
    molecularheatmap(theirDirectory, projName)

def molecularheatmap(theirDirectory, project_name ):
    projName = project_name
    print('Creating Molecular Heatmap')
    os.chdir(str(theirDirectory))
    binWindow = Tk()
    binWindow.title('Molecular Heatmap')
    binWindow.geometry('400x200')
    # center(binWindow)
    binWindow.title("Community Check")
    Label(binWindow, text='How many communities did you select?').grid(row=0, stick=W)
    Label(binWindow, text='What is the receptor chain?').grid(row=1, stick=W)
    # Label(binWindow, text='What is the Name of NBclust file w/ extension?').grid(row=1)
    communityBox = Entry(binWindow)
    chainBox = Entry(binWindow)
    communityBox.grid(row=0, column=1)
    chainBox.grid(row=1, column=1)
    def xlsxClicked():
        xlsxFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select .xlsx file",
                                              filetypes=(("xlsx files", "*.xlsx"), ("all files", "*.*")))
        commFile = str(xlsxFile).split('/')
        global nbFileName
        nbFileName = str(commFile[-1])

    def recfileClicked():
        recPDB = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select .pdb file",
                                              filetypes=(("pdb files", "*.pdb"), ("all files", "*.*")))
        recFile = str(recPDB).split('/')
        global receptorPDB
        receptorPDB = str(recFile[-1])


    def finishingUp():
        os.chdir(theirDirectory)
        os.chdir('Project_interaction_tables')
        global numCommunities
        numCommunities = communityBox.get()
        global recChain
        recChain = chainBox.get()
        # global nbFileName
        # nbFileName = nbFile.get()
        smb.sorting(str(nbFileName))  # This will short the interaction tables into correct bins
        cbt.cbt(numCommunities)  # This will put all the .csv files in each bin together into one big file
        swap.swapa(numCommunities)  # Reorganizing the csv files
        total.Totals(str(recChain), str(numCommunities))  # This is where to totals scripts will be created
        pc.Percentages(numCommunities)  # This will normalize the total tables and add a percentage column
        os.chdir(str(theirDirectory))
        os.chdir('Project_interaction_tables')
        os.mkdir(str(projName) + "_Molecular_Heatmap")
        mhDir = str(theirDirectory) + '/Project_interaction_tables/' + str(projName + '_Molecular_Heatmap')
        mhDir = str(mhDir)
        for rt in range(0, int(numCommunities)): # This will move all the appropriate .csv files from their original dir and put them
                                            # in a dir that is intended for all Molecular heatmap files
            shutil.copy(str(theirDirectory) + '/Project_interaction_tables/' + 'Bin ' + str(rt+1) +
                        "/Residue Percent Bin " + str(rt+1) + '.csv', mhDir)
        shutil.copy(str(theirDirectory) + '/' + str(receptorPDB), mhDir)  # Brings the PDB to be colored to the right dir
        os.chdir(mhDir)
        mh.MolHM(mhDir, receptorPDB, projName, numCommunities) # Molecular Heatmap Magic
    xlsxButton = Button(binWindow, text='Select xlsx File', command=xlsxClicked)
    receptorButton = Button(binWindow, text='Select receptor File', command=recfileClicked)
    xlsxButton.grid(column=1, row=2, stick=E)
    receptorButton.grid(column=1, row=3, stick=E)
    Button(binWindow, text='Submit', command=finishingUp).grid(row=5, column=1, stick=E)
    binWindow.mainloop()


window.mainloop()

