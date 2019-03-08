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

import cluspro_renaming as cr

import re

import shutil

import Protein_Interaction_Analysis as pia

import split_CSV as sc

import heatmapGen as hm

import cluspro_put_together as pt


window = Tk()




chk_state = BooleanVar()
chk_state.set(False)


def countdown(t):
    while t:
        mins, secs = divmod(t, 60)
        timeformat = '{:02d}:{:02d}'.format(mins, secs)

        print(timeformat, end='\r')
        time.sleep(1)
        t -= 1


window.geometry('600x300')
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
checkDockButton1var = IntVar()

# Options
dockLabel = Label(window, text="Docking", font='Helivtica')
interactionLabel = Label(window, text="Interaction table", font='Helivitca')
heatmapLabel = Label(window, text="Heatmap", font='Helivtica')
clusterLabel = Label(window, text="Cluster", font='Helivtica')
metricsLabel = Label(window, text="Metrics", font='Helivtica')
venndiagram = Label(window, text="Venn Diagram", font='Helivtica')
checkDock = Label(window, text="Check Dock", font='Helivtica')

# Options Placement
dockLabel.grid(column=0, row=1, sticky=W)
interactionLabel.grid(column=0, row=2, sticky=W)
heatmapLabel.grid(column=0, row=3, sticky=W)
clusterLabel.grid(column=0, row=4, sticky=W)
metricsLabel.grid(column=0, row=5, sticky=W)
venndiagram.grid(column=0, row=6, stick=W)
checkDock.grid(column=0, row=7, stick=W)

# Options Check marks
dockButton1 = Checkbutton(window, text='Yes', var=dockButton1var)
dockButton2 = Checkbutton(window, text='No', var=dockButton2var)
interctionButton1 = Checkbutton(window, text='Yes', var=interactionButton1var)
interactionButton2 = Checkbutton(window, text='No', var=interactionButton2var)
heatmapButton1 = Checkbutton(window, text='Yes', var=heatmapButton1var)
heatmapButton2 = Checkbutton(window, text='No', var=heatmapButton2var)
clustButton1 = Checkbutton(window, text='Yes', var=clustButton1var)
clustButton2 = Checkbutton(window, text='No', var=clustButton2var)
metricButton1 = Checkbutton(window, text='Yes', var=metricButton1var)
metricButton2 = Checkbutton(window, text='No', var=metricButton2var)
venndiagramButton1 = Checkbutton(window, text='Yes', var=venndiagramButton1var)
venndiagramButton2 = Checkbutton(window, text='No', var=venndiagramButton2var)
checkDockButton1 = Checkbutton(window, text='Yes', var=checkDockButton1var)

# Options Check marks Placement
dockButton1.grid(column=1, row=1)
dockButton2.grid(column=2, row=1)
interctionButton1.grid(column=1, row=2)
interactionButton2.grid(column=2, row=2)
heatmapButton1.grid(column=1, row=3)
heatmapButton2.grid(column=2, row=3)
clustButton1.grid(column=1, row=4)
clustButton2.grid(column=2, row=4)
metricButton1.grid(column=1, row=5)
metricButton2.grid(column=2, row=5)
venndiagramButton1.grid(column=1, row=6)
venndiagramButton2.grid(column=2, row=6)
checkDockButton1.grid(column=1, row=7)


def userDirectory():
    global theirDirectory
    theirDirectory = filedialog.askdirectory()


directoryButton = Button(window, text="Select Directory", command=userDirectory)
directoryButton.grid(column=0, row=0)


def antigenClicked():
    antigenFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select Antigen file",
                                             filetypes=(("pdb files", "*.pdb"), ("all files", "*.*")))
    antigenPDB = str(antigenFile).split('/')
    global antigenfileName
    antigenfileName = str(antigenPDB[-1])
    antigenWindow.insert(INSERT, str(antigenPDB[-1]))


antigenButton = Button(window, text='Select Antigen PDB', command=antigenClicked)
antigenButton.grid(column=10, row=1)


def antibodyClicked():
    antibodyFile = filedialog.askopenfilename(initialdir=str(os.system("pwd")), title="Select Antibody file",
                                              filetypes=(("pdb files", "*.pdb"), ("all files", "*.*")))
    antibodyPDB = str(antibodyFile).split('/')
    global antibodyfileName
    antibodyfileName = str(antibodyPDB[-1])
    antibodyWindow.insert(INSERT, str(antibodyPDB[-1]))


antibodyButton = Button(window, text='Select Antibody PDB', command=antibodyClicked)
antibodyButton.grid(column=12, row=1)


def dockClicked():
    dockOutcome = (dockButton1var.get())
    checkdockOutcome = (checkDockButton1var.get())
    # print(dockOutcome)
    if dockOutcome == 1:
        LetsDock()
    else:
        if checkdockOutcome == 1:
            waitTime()


submitButton = Button(window, text="Submit", command=dockClicked)
submitButton.grid(column=12, row=6)


def LetsDock():
    os.chdir(str(theirDirectory))
    antibodyFile = antibodyfileName
    antigenFile = antigenfileName
    dockWindow = Tk()
    # print(antibodyFile)
    # print(antigenFile)
    # print(os.system('pwd'))
    dockWindow.geometry('300x100')
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




def waitTime():
    waitWindow = Tk()
    waitWindow.geometry('300x100')
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
    pia.proteinInteraction(str(finaljobName), str(antibodyChain), str(antigenChain))
    sc.csvParser(str(finaljobName) + "_interaction_tables.csv", )
    os.mkdir(str(finaljobName) + '_interaction_tables')
    itDir = [f for f in os.listdir('.') if re.search(r'_table_', f)]
    for interTable in range(0, len(itDir)):
        shutil.move(itDir[interTable], str(finaljobName) + '_interaction_tables')
    if heatmapButton1var.get() == 1:
        createHeatmap()
    else:
        return


# Heatmap generation

def heatmapClicked():
    heatmapOutcome = (heatmapButton1var.get())
    if heatmapOutcome == 1:
        createHeatmap()
def createHeatmap():
    print("Generating Heat map")
    os.chdir(str(finaljobName) + '_interaction_tables')
    hm.heatmap(str(finaljobName))




window.mainloop()
