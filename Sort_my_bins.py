'''


@author: Juechen
'''
import mhxlsx2list
import SortingTools as st
import MakeFolderTools as MFT
import os,shutil



def sorting(table):

    tableName = str(table)


    Metrics=mhxlsx2list.getList(str(tableName) , 'Table metrics')
    Metrics=st.SortMetrics(Metrics)

    Groups=list(set([x[1] for x in Metrics]))

    MFT.MakeBinFolder(Groups)

    filefolder= str(os.getcwd())


    dirname=filefolder

    FileSource=MFT.GetAllFileName(dirname)


    # for x in FileSource[:5]:
    #     print(x)
    MovDic={}
    for x in Metrics:
        MovDic[x[0].split('_dock_')[0] + (x[0].split('_dock_')[1]).zfill(1)]=x[1]
    ColorDic={}
    for x in Groups:
        ColorDic[x]='Bin '+str(Groups.index(x)+1)
    # os.chdir('..')
    dict = os.system("pwd")
    print(dict)

    def MoveFile(Source,MovDic,ColorDic):
        for x in Source:
            print(x)
            keyw=(x.split('_interaction_table_')[0]).split("/")[-1]+x.split('_interaction_table_')[1].split(".csv")[0]
            print(keyw)
            keyw = ' ' + keyw
            color=MovDic.get(keyw)
            print(color)
            Bin=os.getcwd()+"/"+ColorDic.get(color)
            try:
                shutil.copy(x, Bin)
            except:
                pass


    MoveFile(FileSource, MovDic,ColorDic)

