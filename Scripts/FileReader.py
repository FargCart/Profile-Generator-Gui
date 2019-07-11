'''
Created on Feb.28,2018

@author: Juechen
'''
import csv

def openCSV(filename):
    storeList=[]
    with open(filename,"r") as tempList:
        tableReader=csv.reader(tempList)
        for row in tableReader:
            if len(row)!=0:
                storeList=storeList+[row]
    return storeList
    tempList.close()