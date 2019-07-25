'''


@author: Juechen
'''
import Scripts.xlsx2list
import Scripts.SortingTools as st
import Scripts.MakeFolderTools as MFT
import os,shutil
import time


def sorting(table):
    tableName = str(table)
    os.system("rm -rf Bin\ 1 Bin\ 2 Bin\ 3 Bin\ 4 Bin\ 5 Bin\ 6")
    Metrics=Scripts.xlsx2list.getList(str(tableName), 'Table metrics')
    Metrics=st.SortMetrics(Metrics)

    Groups=list(set([x[1] for x in Metrics]))

    MFT.MakeBinFolder(Groups)

    filefolder= str(os.getcwd())

    dirname = filefolder

    FileSource=MFT.GetAllFileName(dirname)


    # for x in FileSource[:5]:
    #     print(x)
    MovDic={}
    for x in Metrics:
        MovDic[x[0].split('_dock_')[0] + (x[0].split('_dock_')[1]).zfill(1)]=x[1]


    ColorDic={}
    for x in Groups:
        ColorDic[x]='Bin '+str(Groups.index(x)+1)


    def MoveFile(Source,MovDic,ColorDic):
        for x in Source:
            # print(x)
            # print((x.split('_aff_rep_balanced_models_interaction_tables.csv_')[0]).split("/")[-1])
            # print(x.split('_aff_rep_balanced_models_interaction_tables.csv_')[1].split("_out.csv")[0])
            keyw=(x.split('_balanced_model_')[0]).split("/")[-1]+x.split('_balanced_model_')[1].split("_interaction_table.csv")[0]
            keyw = ' ' + keyw
            color=MovDic.get(keyw)

            Bin=os.path.join(os.getcwd(), ColorDic.get(color))
            try:
                shutil.copy(x, Bin)
            except:
                pass


    MoveFile(FileSource, MovDic,ColorDic)
