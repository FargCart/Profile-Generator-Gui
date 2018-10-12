import tkinter

from tkinter import *

from tkinter.ttk import *

from tkinter import filedialog

from tkinter import scrolledtext

import os

import time
window = Tk()
dockWindow = Tk()
chk_state = BooleanVar()
chk_state.set(False)


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
    theirDirectory = filedialog.askdirectory()
    global theirDirectory

directoryButton = Button(window,text="Select Directory",command=userDirectory)
directoryButton.grid(column=0,row=0)
def antigenClicked():
    antigenFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select Antigen file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
    antigenPDB = str(antigenFile).split('/')
    antigenfileName = str(antigenPDB[-1])
    antigenWindow.insert(INSERT,str(antigenPDB[-1]))
    global antigenfileName
antigenButton = Button(window,text='Select Antigen PDB',command=antigenClicked)
antigenButton.grid(column=10,row=1)

def antibodyClicked():
    antibodyFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select Antibody file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
    antibodyPDB= str(antibodyFile).split('/')
    antibodyfileName = str(antibodyPDB[-1])
    antibodyWindow.insert(INSERT,str(antibodyPDB[-1]))
    global antibodyfileName
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
    print(antibodyFile)
    print(antigenFile)
    print(os.system('pwd'))
    dockWindow.geometry('600x300')
    dockWindow.title("Chain Select")
    
    # os.system("cluspro_submit --ligand " + str(antibodyFile) + " --receptor " + str(
    #     receptor) + " --lig-chains " + '"' + str(lChain) + '"' + " --rec-chains  " + str(
    #     rChain) + " -j " + str(textL) + "_docking_" + str(textR))



window.mainloop()

