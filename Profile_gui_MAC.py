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

import shutil


window = Tk()
dockWindow = Tk()
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
antibodyWindow = scrolledtext.ScrolledText(window,width=20,height=10)
antigenWindow = scrolledtext.ScrolledText(window,width=20,height=10)


antibodyWindow.grid(column=12,row=0)
antigenWindow.grid(column=10, row=0)

# A Bunch of Variables
dockButton1var = IntVar()
dockButton2var = IntVar()
interctionButton1var = IntVar()
interactionButton2var = IntVar()
heatmapButton1var = IntVar()
heatmapButton2var = IntVar()
clustButton1var = IntVar()
clustButton2var = IntVar()
metricButton1var = IntVar()
metricButton2var = IntVar()
venndiagramButton1var = IntVar()
venndiagramButton2var = IntVar()

# Options
dockLabel = Label(window, text="Docking", font=('Helivtica'))
interactionLabel = Label(window, text="Interaction table", font=('Helivitca'))
heatmapLabel = Label(window, text="Heatmap", font=('Helivtica'))
clusterLabel = Label(window, text="Cluster", font=('Helivtica'))
metricsLabel = Label(window, text="Metrics", font=('Helivtica'))
venndiagram = Label(window, text="Venn Diagram", font=('Helivtica'))

# Options Placement
dockLabel.grid(column=0, row=1,sticky=W)
interactionLabel.grid(column=0, row=2,sticky=W)
heatmapLabel.grid(column=0, row=3,sticky=W)
clusterLabel.grid(column=0, row=4,sticky=W)
metricsLabel.grid(column=0, row=5,sticky=W)
venndiagram.grid(column=0, row=6,stick=W)

# Options Check marks
dockButton1 = Checkbutton(window, text='Yes', var=dockButton1var)
dockButton2 = Checkbutton(window, text='No', var=dockButton2var)
interctionButton1 = Checkbutton(window, text='Yes', var=interctionButton1var)
interactionButton2 = Checkbutton(window, text='No', var=interactionButton2var)
heatmapButton1 = Checkbutton(window, text='Yes', var=heatmapButton1var)
heatmapButton2 = Checkbutton(window, text='No', var=heatmapButton2var)
clustButton1 = Checkbutton(window, text='Yes', var=clustButton1var)
clustButton2 = Checkbutton(window, text='No', var=clustButton2var)
metricButton1 = Checkbutton(window, text='Yes', var=metricButton1var)
metricButton2 = Checkbutton(window, text='No', var=metricButton2var)
venndiagramButton1 = Checkbutton(window, text='Yes', var=venndiagramButton1var)
venndiagramButton2 = Checkbutton(window, text='No', var=venndiagramButton2var)





# Options Check marks Placement
dockButton1.grid(column=1,row=1)
dockButton2.grid(column=2,row=1)
interctionButton1.grid(column=1,row=2)
interactionButton2.grid(column=2,row=2)
heatmapButton1.grid(column=1,row=3)
heatmapButton2.grid(column=2,row=3)
clustButton1.grid(column=1,row=4)
clustButton2.grid(column=2,row=4)
metricButton1.grid(column=1,row=5)
metricButton2.grid(column=2,row=5)
venndiagramButton1.grid(column=1,row=6)
venndiagramButton2.grid(column=2,row=6)

def userDirectory():
    global theirDirectory
    theirDirectory = filedialog.askdirectory()


directoryButton = Button(window,text="Select Directory",command=userDirectory)
directoryButton.grid(column=0,row=0)
def antigenClicked():
    antigenFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select Antigen file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
    antigenPDB = str(antigenFile).split('/')
    global antigenfileName
    antigenfileName = str(antigenPDB[-1])
    antigenWindow.insert(INSERT,str(antigenPDB[-1]))
antigenButton = Button(window,text='Select Antigen PDB',command=antigenClicked)
antigenButton.grid(column=10,row=1)

def antibodyClicked():
    antibodyFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select Antibody file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
    antibodyPDB= str(antibodyFile).split('/')
    global antibodyfileName
    antibodyfileName = str(antibodyPDB[-1])
    antibodyWindow.insert(INSERT,str(antibodyPDB[-1]))

antibodyButton = Button(window, text='Select Antibody PDB',command=antibodyClicked)
antibodyButton.grid(column=12,row=1)

def clicked():
    dockOutcome= (dockButton1var.get())
    # print(dockOutcome)
    if dockOutcome ==1:
        LetsDock()
submitButton = Button(window,text="Submit",command=clicked)
submitButton.grid(column=12,row=6)


def LetsDock():
    os.chdir(str(theirDirectory))
    antibodyFile = antibodyfileName
    antigenFile = antigenfileName
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
    jobName.grid(row=0,column=1)
    antigenchainBox.grid(row=1,column=1)
    antibodychainBox.grid(row=2,column=1)

    def ReturnChains():
        antigenChain = antigenchainBox.get()
        antibodyChain = antibodychainBox.get()
        global finaljobName
        finaljobName = jobName.get()

        # os.system("cluspro_submit --ligand " + str(antibodyFile) + " --receptor " + str(
        #     antigenFile) + " --lig-chains " + '"' + str(antibodyChain) + '"' + " --rec-chains  " + str(
        #     antigenChain) + " -j " + str(jobName))
        dockOutcome = subprocess.run(
            ["cluspro_submit", "--receptor", str(antigenFile), "--rec-chains", str(antigenChain), "--ligand",
                str(antibodyFile),"--lig-chains",str(antibodyChain), "-j", str(finaljobName)], stdout=subprocess.PIPE)
        global jobid
        jobid = dockOutcome.stdout
        jobid = jobid.decode('utf -8')
        print('This is your JobID : '+str(jobid))
        taskComplete = 0
        # Pausing for 1 hour
        # time.sleep(60)

        while taskComplete == 0:
            print('Checking agian in:')
            countdown(1800)

            p = subprocess.run(["cluspro_download", str(jobid)], stderr=subprocess.PIPE)
            output = p.stderr
            output = output.decode('utf-8')
            # print(str(output))
            # print(output.decode('utf-8'))
            myMessage = 'Downloading '+str(jobid)+'...ERROR \nJob not finished'
            # print(myMessage)
            if str(output[0:25]) == str(myMessage[0:25]):
                print("Still Cooking")
            else:
                taskComplete = 1

        print('Job is Completed')
    Button(dockWindow, text='Submit', command=ReturnChains).grid(row=3, column=1, stick=W, pady=4)

def expandFolder():
    #After download will need to untar the folder to get into it
    os.chdir(str(theirDirectory))
    fileTar = tarfile.open('cluspro.'+str(jobid)+'.tar.bz2')
    os.chdir('cluspro.'+str(jobid))
    cr.theRename(str(finaljobName))
    shut

window.mainloop()

