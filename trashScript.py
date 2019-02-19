import os
import cluspro_renaming as cr
import tarfile
import shutil
import fnmatch
import re
import cluspro_put_together as pt
import pymol
import Protein_Interaction_Analysis as pia
import split_CSV as sc
import heatmapGen as hm
import time
from tkinter import *

from tkinter.ttk import *

from tkinter import filedialog

from tkinter import scrolledtext


timerWindow = Tk()

def countdown(t):
    while t > 0:
        mins, secs = divmod(t, 60)
        timeformat = '{:02d}:{:02d}'.format(mins, secs)
        timerWindow.geometry('200x100')
        timerWindow.title('Attempting Download In:')
        Label(timerWindow, text=timeformat).grid(column=6, row=0)
        print(timeformat, end='\r')
        # time.sleep(1)
        t = t-1
        timerWindow.mainloop()


countdown(3)













# After download will need to untar the folder to get into it

# fileTar = tarfile.open('cluspro.260420.tar.bz2')
# fileTar.extractall()
# os.chdir('cluspro.260420')
# myFile = 'test'
#
#
# cr.theRename('test')
# os.system('rm -r Balanced_models')
# os.system('rm -r Electrostatic_models')
# os.system('rm -r Hydrophobic_models')
# os.system('rm -r Vdw_models')
#
# os.system('mkdir Balanced_models')
# os.system('mkdir Electrostatic_models')
# os.system('mkdir Hydrophobic_models')
# os.system('mkdir Vdw_models')
# dirLength = [f for f in os.listdir('.') if re.search(r'balanced', f)]
# for balanced in range(0, len(dirLength)):
#     shutil.move(dirLength[balanced], 'Balanced_models')
# dirLength = [f for f in os.listdir('.') if re.search(r'static', f)]
# for electrostatic in range(0, len(dirLength)):
#     shutil.move(dirLength[electrostatic], 'Electrostatic_models')
# dirLength = [f for f in os.listdir('.') if re.search(r'phobic', f)]
# for hydro in range(0, len(dirLength)):
#     shutil.move(dirLength[hydro], 'Hydrophobic_models')
# dirLength = [f for f in os.listdir('.') if re.search(r'vdw', f)]
# for vdw in range(0, len(dirLength)):
#     shutil.move(dirLength[vdw], 'Vdw_models')
#
# os.chdir('Balanced_models')
#
# pt.putTogether('test')
# pia.proteinInteraction('test', 'A', 'C')
# sc.csvParser("test_interaction_tables.csv", myFile)
# os.system('mkdir ' + myFile + '_interaction_tables')
# itDir = [f for f in os.listdir('.') if re.search(r'_table_', f)]
# for interTable in range(0,len(itDir)):
#     shutil.move(itDir[interTable], myFile + '_interaction_tables')
#
# os.chdir('test_interaction_tables')
# hm.heatmap(myFile)














