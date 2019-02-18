'''
Created on May 16, 2018

@author: Juechen
'''
import csv
def writeCSV(filename, rawTable):
    with open(filename, "wb") as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for i in range(0,len(rawTable)):
            writer.writerow(rawTable[i])