# A plug and chug script that will allow you to convert any single csv file
# into an excel file 

from openpyxl import Workbook
import csv
import os



def converter(name):
    wb = Workbook()
    ws = wb.active
    name=str(name)
    with open(name+'.csv', 'r') as f:
        for row in csv.reader(f):
            ws.append(row)
    wb.save(name+'.xlsx')
