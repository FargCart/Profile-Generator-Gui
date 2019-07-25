import os
import fnmatch

def mergeThem(file1,file2):

    name = file1.split('.000')
    n1 = file1.split('0.')
    n1 = n1[1].split('_united')
    if int(n1[0]) >9:
        n1 = int(n1[0]) + 1
        os.system('cat ' + file1 + ' ' + file2 + '>' + name[0] + '_' + str(n1) + '_interaction_table.csv')
    elif  int(n1[0]) <=9 and int(n1[0]) >0:
            n2 = n1[0].split('0')
            n2 = int(n2[1]) + 1
            os.system('cat ' + file1 + ' ' + file2 + '>' + name[0] + '_' + str(n2) + '_interaction_table.csv')
    elif int(n1[0]) ==0:
        n3 = int(n1[0]) +1
        os.system('cat ' + file1 + ' ' + file2 + '>' + name[0] + '_' + str(n3) + '_interaction_table.csv')

    try:
        os.remove(file1)
        os.remove(file2)
    except:
        pass


