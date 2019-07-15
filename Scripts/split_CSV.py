#ONLY COMPATIBLE WITH 2.6.XX PYTHON 

import Scripts.FileReader as fr
import Scripts.FileWriter as fw
import os


def csvParser(csvFile, fileName):
    rawdata = fr.openCSV(str(csvFile))
    rawdata.append(['Residue'])
    file = []
    i = 0
    for x in rawdata:
        if x[0] == 'Residue':
            if i != 0:
                fw.writeCSV(str(fileName)+"_interaction_table_"+str(i)+'.csv', file)
                file = []

            i = i+1
        file.append(x)
