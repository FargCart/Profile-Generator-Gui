import os
# import cluspro_renaming as cr
# import tarfile
# import shutil
# import fnmatch
# import re
# import cluspro_put_together as pt
# import pymol
# import Protein_Interaction_Analysis as pia
# import split_CSV as sc
# import heatmapGen as hm
# import time
# from tkinter import *
#
# from tkinter.ttk import *
#
# from tkinter import filedialog

from tkinter import scrolledtext
from glob import glob


# os.chdir('/tmp/ligplot')
# interDir = glob('/tmp/ligplot'+'/*/')
# interDir = interDir[0].split('/')
#
# os.system('cp -R '+str(interDir[3])+ ' ~/Desktop/Mytest')
# print(interDir[3])
# os.chdir('/Users/AdamClosmore/Desktop')
# os.system('pwd')
#
reqList = ['tkinter', 'tarfile', 'openpyxl', 'csv', 'pymol', 'xlrd']

for x in range(0,len(reqList)):
    try:
        os.system('conda install ' +str(reqList[x]))
    except:
        pass
    else:
        try:
            os.system('pip install ' + str(reqList[x]))
        except:
            pass
















