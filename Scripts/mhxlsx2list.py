import xlrd
import csv

def getList(filename,sheetname):
    sheet=xlrd.open_workbook(filename).sheet_by_name(sheetname)
    result=[]
    for rownum in range(sheet.nrows):
        result.append([x.value for x in sheet.row(rownum)])
    return result
def writeCSV(filename, rawTable):
    with open(filename, "w",newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for i in range(0,len(rawTable)):
            writer.writerow(rawTable[i])




