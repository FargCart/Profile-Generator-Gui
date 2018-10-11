import tkinter

from tkinter import *

from tkinter.ttk import *

from tkinter import filedialog

import os
window = Tk()
chk_state = BooleanVar()
chk_state.set(False)


window.geometry('500x300')
window.title("Antibody-Antigen Profile Generator")

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
dockLabel.grid(column=0, row=0)
interactionLabel.grid(column=0, row=1)
heatmapLabel.grid(column=0, row=2)
clusterLabel.grid(column=0, row=3)
metricsLabel.grid(column=0, row=4)
venndiagram.grid(column=0, row=5)

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
dockButton1.grid(column=1,row=0)
dockButton2.grid(column=2,row=0)
interctionButton1.grid(column=1,row=1)
interactionButton2.grid(column=2,row=1)
heatmapButton1.grid(column=1,row=2)
heatmapButton2.grid(column=2,row=2)
clustButton1.grid(column=1,row=3)
clustButton2.grid(column=2,row=3)
metricButton1.grid(column=1,row=4)
metricButton2.grid(column=2,row=4)
venndiagramButton1.grid(column=1,row=5)
venndiagramButton2.grid(column=2,row=5)

def clicked():
    print(dockButton1var.get())

def antigenClicked():
    antigenFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select PDB file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))

antigenButton = Button(window,text='Select Antigen PDB',command=antigenClicked)
antigenButton.grid(column=6,row=20)
def antibodyClicked():
    antibodyFile =antigenFile = filedialog.askopenfilename(initialdir = str(os.system("pwd")),title = "Select PDB file",filetypes = (("pdb files","*.pdb"),("all files","*.*")))
antibodyButton = Button(window, text='Select Antibody PDB',command=antibodyClicked)
antibodyButton.grid(column=8,row=20)


window.mainloop()

