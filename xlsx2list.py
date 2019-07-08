import openpyxl as op

def getList(filename):
    sheet=op.load_workbook(filename).active
    result=[]
    for r in sheet.rows:
        result.append([x.value for x in r])
    return result




