import pymol
import tkinter

from tkinter import *

from tkinter.ttk import *

from tkinter import filedialog

from tkinter import scrolledtext

import os

import subprocess

import tarfile

import time

import Scripts.cluspro_renaming as cr

import re

import shutil

import Scripts.Protein_Interaction_Analysis as pia

import Scripts.split_CSV as sc

import Scripts.heatmapGen as hm

import Scripts.cluspro_put_together as pt

import Scripts.excel_converter as ec

import Scripts.Sort_my_bins as sb

import Scripts.Create_bins_together as cbt

import Scripts.Totals_Script as ts

import Scripts.percentr_contribution as pc

import Scripts.MolHeat as molH



os.system('chmod 777 RCommunities.py')
# def center(win):
#     """
#     centers a tkinter window
#     :param win: the root or Toplevel window to center
#     """
#     win.update_idletasks()
#     width = win.winfo_width()
#     frm_width = win.winfo_rootx() - win.winfo_x()
#     win_width = width + 2 * frm_width
#     height = win.winfo_height()
#     titlebar_height = win.winfo_rooty() - win.winfo_y()
#     win_height = height + titlebar_height + frm_width
#     x = win.winfo_screenwidth() // 2 - win_width // 2
#     y = win.winfo_screenheight() // 2 - win_height // 2
#     win.geometry('{}x{}+{}+{}'.format(width, height, x, y))
#     win.deiconify()

# Window Setup
window = Tk()
chk_state = BooleanVar()
chk_state.set(False)


# Used to make Checkdock wait a certain amount of time before checking again
def countdown(t):
    while t:
        mins, secs = divmod(t, 60)
        timeformat = '{:02d}:{:02d}'.format(mins, secs)

        print(timeformat, end='\r')
        time.sleep(1)
        t -= 1


window.geometry('600x400')
# center(window)


window.title("Antibody-Antigen Profile Generator")
antibodyWindow = scrolledtext.ScrolledText(window, width=20, height=10)
antigenWindow = scrolledtext.ScrolledText(window, width=20, height=10)

antibodyWindow.grid(column=12, row=0)
antigenWindow.grid(column=10, row=0)

# A Bunch of Variables
dockButton1var = IntVar()
dockButton2var = IntVar()
interactionButton1var = IntVar()
interactionButton2var = IntVar()
heatmapButton1var = IntVar()
heatmapButton2var = IntVar()
clustButton1var = IntVar()
clustButton2var = IntVar()
metricButton1var = IntVar()
metricButton2var = IntVar()
venndiagramButton1var = IntVar()
venndiagramButton2var = IntVar()
mhButton1var = IntVar()
mhButton2var = IntVar()
checkDockButton1var = IntVar()
halfButton1var = IntVar()

# Options
dockLabel = Label(window, text="Docking", font='Helivtica')
interactionLabel = Label(window, text="Interaction table", font='Helivitca')
heatmapLabel = Label(window, text="Heatmap", font='Helivtica')
clusterLabel = Label(window, text="Cluster", font='Helivtica')
mhLabel = Label(window, text="Molecular Heatmap", font="Helivitica")
metricsLabel = Label(window, text="Metrics", font='Helivtica')
venndiagram = Label(window, text="Venn Diagram", font='Helivtica')
checkDock = Label(window, text="Check Dock", font='Helivtica')
halfWay = Label(window, text="Interactions_done", font='Helivtica')

# Options Placement
dockLabel.grid(column=0, row=1, sticky=W)
interactionLabel.grid(column=0, row=2, sticky=W)
heatmapLabel.grid(column=0, row=3, sticky=W)
clusterLabel.grid(column=0, row=4, sticky=W)
mhLabel.grid(column=0, row=5, sticky=W)
metricsLabel.grid(column=0, row=6, sticky=W)
venndiagram.grid(column=0, row=7, stick=W)
checkDock.grid(column=0, row=8, stick=W)
halfWay.grid(column=0, row=9, stick=W)


# Options Check marks
dockButton1 = Checkbutton(window, text='Yes', var=dockButton1var)
dockButton2 = Checkbutton(window, text='No', var=dockButton2var)
interctionButton1 = Checkbutton(window, text='Yes', var=interactionButton1var)
interactionButton2 = Checkbutton(window, text='No', var=interactionButton2var)
heatmapButton1 = Checkbutton(window, text='Yes', var=heatmapButton1var)
heatmapButton2 = Checkbutton(window, text='No', var=heatmapButton2var)
clustButton1 = Checkbutton(window, text='Yes', var=clustButton1var)
clustButton2 = Checkbutton(window, text='No', var=clustButton2var)
mhButton1 = Checkbutton(window, text='Yes', var=mhButton1var)
mhButton2 = Checkbutton(window, text='No', var=mhButton2var)
metricButton1 = Checkbutton(window, text='Yes', var=metricButton1var)
metricButton2 = Checkbutton(window, text='No', var=metricButton2var)
venndiagramButton1 = Checkbutton(window, text='Yes', var=venndiagramButton1var)
venndiagramButton2 = Checkbutton(window, text='No', var=venndiagramButton2var)
checkDockButton1 = Checkbutton(window, text='Yes', var=checkDockButton1var)
halfwayButton1 = Checkbutton(window, text='Yes', var=halfButton1var)

# Options Check marks Placement
dockButton1.grid(column=1, row=1)
dockButton2.grid(column=2, row=1)
interctionButton1.grid(column=1, row=2)
interactionButton2.grid(column=2, row=2)
heatmapButton1.grid(column=1, row=3)
heatmapButton2.grid(column=2, row=3)
clustButton1.grid(column=1, row=4)
clustButton2.grid(column=2, row=4)
mhButton1.grid(column=1, row=5)
mhButton2.grid(column=2, row=5)
metricButton1.grid(column=1, row=6)
metricButton2.grid(column=2, row=6)
venndiagramButton1.grid(column=1, row=7)
venndiagramButton2.grid(column=2, row=7)
checkDockButton1.grid(column=1, row=8)
halfwayButton1.grid(column=1, row=9)

#Getting their directory they will be working in (THIS IS A REQ INPUT)
def userDirectory():
    global theirDirectory
    theirDirectory = filedialog.askdirectory()


directoryButton = Button(window, text="Select Directory", command=userDirectory)
directoryButton.grid(column=0, row=0)

# Loading the receptor
def antigenClicked():
    antigenFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select Antigen file",
                                             filetypes=(("pdb files", "*.pdb"), ("all files", "*.*")))
    antigenPDB = str(antigenFile).split('/')
    global antigenfileName
    antigenfileName = str(antigenPDB[-1])
    antigenWindow.insert(INSERT, str(antigenPDB[-1]))


antigenButton = Button(window, text='Select Antigen PDB', command=antigenClicked)
antigenButton.grid(column=10, row=1)

# Loading the Ab
def antibodyClicked():
    antibodyFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select Antibody file",
                                              filetypes=(("pdb files", "*.pdb"), ("all files", "*.*")))
    antibodyPDB = str(antibodyFile).split('/')
    global antibodyfileName
    antibodyfileName = str(antibodyPDB[-1])
    antibodyWindow.insert(INSERT, str(antibodyPDB[-1]))


antibodyButton = Button(window, text='Select Antibody PDB', command=antibodyClicked)
antibodyButton.grid(column=12, row=1)

# Checking if user wants to dock
def dockClicked():
    dockOutcome = (dockButton1var.get())
    checkdockOutcome = (checkDockButton1var.get())
    checkhalfOutcome = (halfButton1var.get())
    # print(dockOutcome)
    if dockOutcome == 1:
        LetsDock()
    else:
        if checkdockOutcome == 1: #This is ran if the user has already submitted a dock
            waitTime()
        else:
            if checkhalfOutcome == 1:
                halfwayThere()


submitButton = Button(window, text="Submit", command=dockClicked)
submitButton.grid(column=12, row=6)

# ---------------------------------------------------------------------------------------------------------
# Starting the dock process
def LetsDock():
    os.chdir(str(theirDirectory))
    antibodyFile = antibodyfileName
    antigenFile = antigenfileName
    dockWindow = Tk()
    dockWindow.geometry('300x300')
    # center(dockWindow)
    dockWindow.title("Chain Select")
    Label(dockWindow, text='Job Name').grid(row=0)
    Label(dockWindow, text='Antigen Chain').grid(row=1)
    Label(dockWindow, text='Antibody Chain').grid(row=2)
    antigenchainBox = Entry(dockWindow)
    antibodychainBox = Entry(dockWindow)
    jobName = Entry(dockWindow)
    jobName.grid(row=0, column=1)
    antigenchainBox.grid(row=1, column=1)
    antibodychainBox.grid(row=2, column=1)

    def ReturnChains():
        global antigenChain
        antigenChain = antigenchainBox.get()
        global antibodyChain
        antibodyChain = antibodychainBox.get()
        global finaljobName
        finaljobName = jobName.get()

        # os.system("cluspro_submit --ligand " + str(antibodyFile) + " --receptor " + str(
        #     antigenFile) + " --lig-chains " + '"' + str(antibodyChain) + '"' + " --rec-chains  " + str(
        #     antigenChain) + " -j " + str(jobName))
        dockOutcome = subprocess.run(
            ["cluspro_submit", "--receptor", str(antigenFile), "--rec-chains", str(antigenChain), "--ligand",
             str(antibodyFile), "--lig-chains", str(antibodyChain), "-j", str(finaljobName)], stdout=subprocess.PIPE)
        print('This is dockOutcome = '+str(dockOutcome))

        jobid = dockOutcome.stdout
        global finalID
        finalID = jobid.decode('utf -8')
        finalID = str(finalID)
        print('This is your JobID : %s' % finalID)
        taskComplete = 0
        while taskComplete == 0:
            print('Checking agian in:')
            countdown(1800)

            p = subprocess.run(["cluspro_download", finalID], stderr=subprocess.PIPE)
            output = p.stderr
            output = output.decode('utf-8')
            # print(str(output))
            # print(output.decode('utf-8'))
            myMessage = 'Downloading ' + finalID + '...ERROR \nJob not finished'
            # print(myMessage)
            if str(output[0:25]) == str(myMessage[0:25]):
                print("Still Cooking")
            else:
                taskComplete = 1

        print('Job is Completed')
        expandFolder()

    Button(dockWindow, text='Submit', command=ReturnChains).grid(row=3, column=1, stick=W, pady=4)

# ---------------------------------------------------------------------------------------------------------
# Used to check a dock that has already been submitted
def waitTime():
    waitWindow = Tk()
    waitWindow.geometry('300x100')
    # center(waitWindow)
    waitWindow.title("Input iD")
    Label(waitWindow, text='Job ID ').grid(row=1)
    Label(waitWindow, text='Job Name').grid(row=0)
    Label(waitWindow, text='Antibody Chain').grid(row=2)
    Label(waitWindow, text='Antigen Chain').grid(row=3)
    idNumber = Entry(waitWindow)
    idNumber.grid(row=1, column=1)
    jobName = Entry(waitWindow)
    jobName.grid(row=0, column=1)
    abchain = Entry(waitWindow)
    abchain.grid(row=2, column=1)
    antichain = Entry(waitWindow)
    antichain.grid(row=3, column=1)

    def theCheck():
        taskComplete = 0
        global finalID
        finalID = idNumber.get()
        finalID = str(finalID)
        global finaljobName
        finaljobName = jobName.get()
        finaljobName = str(finaljobName)
        global antibodyChain
        antibodyChain = abchain.get()
        global antigenChain
        antigenChain = antichain.get()
        while taskComplete == 0:

            p = subprocess.run(["cluspro_download", finalID], stderr=subprocess.PIPE)
            output = p.stderr
            output = output.decode('utf-8')
            # print(str(output))
            # print(output.decode('utf-8'))
            myMessage = 'Downloading ' + finalID + '...ERROR \nJob not finished'
            # print(myMessage)
            if str(output[0:25]) == str(myMessage[0:25]):
                print("Still Cooking")
                print('Checking agian in:')
                countdown(1800)
            else:
                taskComplete = 1

        print('Job is Completed')
        print(finalID)
        expandFolder(finalID, finaljobName)
    Button(waitWindow, text='Submit', command=theCheck).grid(row=5, column=1, stick=W, pady=4)

# ---------------------------------------------------------------------------------------------------------
# Changing the naming of Cluspro docks to something more usable
def expandFolder(finalID, finaljobName):
    finalID = str(finalID)
    # After download will need to untar the folder to get into it
    os.chdir(str(theirDirectory))
    # print('instance 1 = '+os.system('ls'))
    fileTar = tarfile.open('cluspro.' + finalID + '.tar.bz2')
    # print('instance 2 = '+os.system('ls'))
    fileTar.extractall()
    # print('instance 3 = '+os.system('ls'))
    os.chdir('cluspro.%s' % finalID)
    # print('instance 4 = '+os.system('ls'))
    cr.theRename(str(finaljobName))
    # Sorting everything into clean folders
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
    if interactionButton1var.get() == 1:
        makeInteraction()
    else:
        if interactionButton1var.get() == 0 and heatmapButton1var.get() == 1:
            print('You need to generate interaction tables to make heatmap')
        else:
            return



# ---------------------------------------------------------------------------------------------------------
# Interaction Table generation

def interClicked():
    interOutcome = (interactionButton1var.get())
    if interOutcome == 1:
        makeInteraction()
def makeInteraction():
    print('Making Interaction Tables')
    os.chdir(str(theirDirectory))
    os.chdir('cluspro.' + finalID)
    os.chdir('Balanced_models')

    pt.putTogether(str(finaljobName))
    pia.proteinInteraction(str(finaljobName), str(antibodyChain), str(antigenChain),str(theirDirectory))
    sc.csvParser(str(finaljobName) + "_interaction_tables.csv", str(finaljobName) )
    os.mkdir(str(finaljobName) + '_interaction_tables')
    itDir = [f for f in os.listdir('.') if re.search(r'_table_', f)]
    for interTable in range(0, len(itDir)):
        shutil.move(itDir[interTable], str(finaljobName) + '_interaction_tables')
    if heatmapButton1var.get() == 1:
        createHeatmap()
    else:
        return
# ---------------------------------------------------------------------------------------------------------

def halfwayThere(): # This is a point in which we can use already generated interaction tables
    halfWindow = Tk()
    halfWindow.geometry('500x200')
    # center(halfWindow)
    global halfwayDir
    # halfwayDir = '/home/lab/Desktop/Profile-Generator-Gui-master/cluspro.290087/Balanced_models' # Linux
    halfwayDir = '/Users/AdamClosmore/PycharmProjects/Profile_Generator/cluspro.290087/Balanced_models' # Mac


    # halfButton = Button(halfWindow, text="Dir above Interaction tables", command=halfwayThere)
    # halfButton.grid(column=0, row=0)
    Label(halfWindow, text='Job ID ').grid(row=1)
    Label(halfWindow, text='Job Name').grid(row=0)
    Label(halfWindow, text='Antibody Chain').grid(row=2)
    Label(halfWindow, text='Antigen Chain').grid(row=3)
    idNumber = Entry(halfWindow)
    idNumber.grid(row=1, column=1)
    jobName = Entry(halfWindow)
    jobName.grid(row=0, column=1)
    abchain = Entry(halfWindow)
    abchain.grid(row=2, column=1)
    antichain = Entry(halfWindow)
    antichain.grid(row=3, column=1)
    def theCheck():
        global finalID
        finalID = idNumber.get()
        finalID = str(finalID)
        global finaljobName
        finaljobName = jobName.get()
        finaljobName = str(finaljobName)
        global antibodyChain
        antibodyChain = abchain.get()
        global antigenChain
        antigenChain = antichain.get()
        os.chdir(str(halfwayDir))
        createHeatmap()
    Button(halfWindow, text='Submit', command=theCheck).grid(row=5, column=1, stick=W, pady=4)
    Button(halfWindow, text='Communities Done', command=createMH).grid(row=5, column=2, stick=W, pady=4)

# ---------------------------------------------------------------------------------------------------------
# Heatmap generation
def heatmapClicked():
    heatmapOutcome = (heatmapButton1var.get())
    if heatmapOutcome == 1:
        createHeatmap()
def createHeatmap():
    print("Generating Heat map")
    os.chdir(str(finaljobName) + '_interaction_tables')
    hm.heatmap(str(finaljobName))
    ec.converter(str(finaljobName) + '_Heatmap')
    if clustButton1var.get() == 1:
        createCluster()
    else:
        return




# ---------------------------------------------------------------------------------------------------------
# Opening Clustering Program (NBclust)
def clusteringClicked():
    clusterOutcome = (clustButton1var.get())
    if clusterOutcome == 1:
        createCluster()


def createCluster():
    os.chdir(str(theirDirectory))
    clusWindow = Tk()
    clusWindow.geometry('100x100')
    # center(clusWindow)
    Button(clusWindow, text="Communities Done!?", command=createMH).grid(row=1, column=1, stick=W)
    # subprocess.run("Rscript -e \"shiny::runApp('NBClust_program',launch.browser=TRUE)\"", shell=False)
    #
    # if mhButton1var.get() == 1:
    #     createMH()
    # else:
    #     return

# ---------------------------------------------------------------------------------------------------------
# Opening Molecular Heatmap protocol
def MHclicked():
    mhOutcomes = (mhButton1var.get())
    if mhOutcomes == 1:
        createMH()

def createMH():
    print('Creating Molecular Heatmap')
    os.chdir(str(theirDirectory))
    binWindow = Tk()
    binWindow.title('Molecular Heatmap')
    binWindow.geometry('400x200')
    # center(binWindow)
    binWindow.title("Community Check")
    Label(binWindow, text='How many communities did you select?').grid(row=0)
    # Label(binWindow, text='What is the Name of NBclust file w/ extension?').grid(row=1)
    communityBox = Entry(binWindow)
    # nbFile = Entry(binWindow)
    communityBox.grid(row=0, column=1)
    # nbFile.grid(row=1, column=1)
    def xlsxClicked():
        xlsxFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select .xlsx file",
                                              filetypes=(("xlsx files", "*.xlsx"), ("all files", "*.*")))
        commFile = str(xlsxFile).split('/')
        global nbFileName
        nbFileName = str(commFile[-1])
    os.chdir(str(theirDirectory) + '/cluspro.' + str(finalID) + "/Balanced_models/" + str(finaljobName) + '_interaction_tables')
    os.system('pwd')
    def finishingUp():
        global numCommunities
        numCommunities = communityBox.get()
        # global nbFileName
        # nbFileName = nbFile.get()
        sb.sorting(str(nbFileName))  # This will short the interaction tables into correct bins
        cbt.cbt(numCommunities) # This will put all the .csv files in each bin together into one big file
        ts.Totals(str(antigenChain), str(numCommunities)) # This is where to totals scripts will be created
        pc.Percentages(numCommunities) # This will normalize the total tables and add a percentage column
        os.chdir(str(theirDirectory))
        os.chdir('cluspro.' + finalID)
        os.chdir('Balanced_models')
        os.mkdir(str(finaljobName) + "_Molecular_Heatmap")
        mhDir = str(theirDirectory) + '/cluspro.' + str(finalID) + '/Balanced_models/' + str(finaljobName + '_Molecular_Heatmap')
        mhDir = str(mhDir)
        for rt in range(0, int(numCommunities)): # This will move all the appropriate .csv files from their original dir and put them
                                            # in a dir that is intended for all Molecular heatmap files
            shutil.copy(str(theirDirectory) + '/cluspro.' + str(finalID) + "/Balanced_models/" + str(finaljobName) + '_interaction_tables/' +
                        'Bin ' + str(rt+1) + "/Residue Percent Bin " + str(rt+1) + '.csv' , mhDir)
        shutil.copy(str(theirDirectory) + '/' + str(antigenfileName), mhDir) # Brings the PDB to be colored to the right dir
        molH.MolHM(mhDir, antigenfileName, finaljobName, numCommunities) # Molecular Heatmap Magic
    xlsxButton = Button(binWindow, text='Select xlsx File', command=xlsxClicked)
    xlsxButton.grid(column=1, row=1)
    Button(binWindow, text='Submit', command=finishingUp).grid(row=5, column=1, stick=W, pady=4)


window.mainloop()
