# Will take total tables that you have already generated and find out of all
# the hits, what percent of those belong to that specific residue 

import Scripts.perc_fileReader as fr
import Scripts.perc_fileWriter as fw
import os

def Percentages(bins):

    bnum=bins
    bnum=int(bnum)
    for z in range(0,bnum):
        os.chdir("Bin "+str(z+1))
        rawTable=fr.openCSV("Bin " + str(z+1) +" Total_Table.csv")
        totalAll=0
        for i in range(1,len(rawTable)):
            totalAll+=(int)(rawTable[i][8])
        for i in range(1,len(rawTable)):
            percentage='{:.2%}'.format((int)(rawTable[i][8])/totalAll)
            rawTable[i].append(percentage)

        rawTable[0].append("Percentage")
        rawTable[0].append("total number")
        rawTable[1].append(totalAll)

        fw.writeCSV("Residue Percent Bin "+str(z+1)+".csv",rawTable)
        os.chdir('..')

