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
    files = os.listdir(dirname)
    results=[]
    for f in files:
        if 'balanced_model_' in f :
            results.append(dirname+"/"+f)
    return results

    
