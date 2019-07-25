import csv
def writeCSV(filename, rawTable):
    with open(filename, "w",newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        for i in range(0,len(rawTable)):
            writer.writerow(rawTable[i])
