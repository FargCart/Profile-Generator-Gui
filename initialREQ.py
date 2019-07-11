import os

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
