#ONLY COMPATIBLE WITH 2.6.XX PYTHON 

import FileReader as fr
import FileWriter as fw
import os

files = os.listdir(os.curdir)
for f in files:
    if ".csv" in f:
        print(f)

thefile=raw_input("What file are you using?(with extension) ")

    
rawdata=fr.openCSV(str(thefile))
rawdata.append(['Residue'])
file=[]
i=0
for x in rawdata:
    if x[0]=='Residue':
        if i!=0:
            fw.writeCSV(str(thefile)+"_"+str(i)+'_out.csv', file)
            file=[]
           
        i=i+1
    file.append(x)
        
        
