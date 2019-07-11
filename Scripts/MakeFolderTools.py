'''

@author: Juechen


'''

import os
def MakeBinFolder(Groups):
    for x in Groups:
        Bin=os.getcwd()+"/Bin "+str(Groups.index(x)+1)
        try:
            os.makedirs(Bin)
        except OSError as e:
            print('Group already exist')
            pass
def GetAllFileName(dirname):
    os.chdir(dirname)
    files = os.listdir(os.curdir)
    results=[]
    for f in files:
        if '_interaction_table_' in f :
            results.append(dirname+"/"+f)
    return results

    
