import csv

def openCSV(filename):
    with open(filename,"r") as tempList:
        storeList=[]
        tableReader=csv.reader(tempList)
        for row in tableReader:
            if len(row)!=0:
                storeList=storeList+[row]
    return storeList
    tempList.close()
            
