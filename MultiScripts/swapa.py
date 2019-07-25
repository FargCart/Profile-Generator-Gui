import os 
import csv

# Everytime H0 is in row 0 and A0 is in row 2 take the value from row 2 & 3 and swap it with value from rows 0 & 1

def swapa(bin):
    bin = int(bin) + 1
    for x in range(1, bin):
        os.chdir('Bin ' + str(x))
        os.system('pwd')
        with open('Bin_' + str(x) + '.csv', 'r', newline='', encoding='utf8') as inf:
            reader = csv.reader(inf, delimiter=' ')

            with open('Bin_' + str(x) + '_swap.csv', 'w') as outf:
                writer = csv.writer(outf)
                for line in reader:
                    if line[2][:2] == "A0":
                        r0 = line[0]  # Column 0
                        r1 = line[1]  # Column 1
                        r2 = line[2]  # Column 2
                        r3 = line[3]  # Column 3
                        r4 = line[4]
                        r5 = line[5]
                        myList = [r2, r3, r0, r1, r4, r5]
                        writer.writerow(myList)
                    else:
                        writer.writerow(line)
        os.rename('Bin_' + str(x) + '_swap.csv', 'Bin_' + str(x) + '.csv')
        os.chdir('..')




