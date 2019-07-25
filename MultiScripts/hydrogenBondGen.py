import os
import csv





headerList = ['Donor', 'AtomD', 'Acceptor', 'AtomA', 'Distance', 'C-alpha_Distance']

def hydrogenBonds(file):
    fileName = file.split('.pdb')
    fileName = fileName[0]
    os.system('./hbplus '+ file)
    os.rename(fileName + '.hb2', fileName + '.txt')
    myTxt = fileName + '.txt'
    betaTxt = fileName + '_beta.txt'
    csv_file = fileName + '.csv'
    with open(myTxt, 'r') as f:
        lines = f.readlines()

    # remove spaces
    lines = [line.replace('  ', ' ') for line in lines]
    lines = [line.replace('  ', ' ') for line in lines]


    # finally, write lines in the file
    with open(betaTxt, 'w') as f:
        f.writelines(lines[8:])

    num_lines = sum(1 for line in open(betaTxt))

    with open(betaTxt, 'r') as mfile:
        in_txt = csv.reader(open(betaTxt, "r", newline='', encoding='utf8'), delimiter='\t')
        out_csv = csv.writer(open(csv_file, 'w', newline='', encoding='utf8'))
        # out_csv.writerow(headerList)
        out_csv.writerows(in_txt)

    remove_from = 5
    remove_to = 7

    with open(csv_file, "r", newline='', encoding='utf8') as fp_in, open(fileName + '_final.csv', "w", newline='', encoding='utf8') as fp_out:
        reader = csv.reader(fp_in, delimiter=" ")
        writer = csv.writer(fp_out, delimiter=" ")
        for row in reader:
            del row[5:7]
            del row[6:16]
            writer.writerow(row)

    with open(fileName + '_final.csv', 'r', newline='', encoding='utf8') as unsorted:
        with open(fileName + "_hb.csv", "w", newline='', encoding='utf8') as sorted:
            reader = csv.reader(unsorted, delimiter=' ')
            writer = csv.writer(sorted, delimiter=' ')
            writer.writerow(headerList)
            for row in reader:
                if 'A0' in row[0] and 'H0' in row[2]:
                    writer.writerow(row)
                if 'A0' in row[0] and 'L0' in row[2]:
                    writer.writerow(row)
                if 'H0' in row[0] and 'A0' in row[2]:
                    writer.writerow(row)
                if 'L0' in row[0] and 'A0' in row[2]:
                    writer.writerow(row)
    os.remove(betaTxt)
    os.remove(csv_file)
    os.remove(myTxt)
    os.remove(fileName + '_final.csv')

