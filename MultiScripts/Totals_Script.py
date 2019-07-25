#### Must use Bin_sorting.py before this one 

# allows you to go through all the interaction tables located in each bin
# and make a total table so  you can see which residues were hit the most

import csv
import os
import time


def Totals(chain, bins):
    #open original csv file
    name=['Bin']
    #colorList=input("What Bin?")
    #olorList=str(colorList)
    chain = str(chain)
    bnum=bins
    bnum=int(bnum)
    for g in range(0,bnum):
        os.chdir("Bin " +str(g+1))
        for w in range (0,len(name)):
            #for z in range(0,len(colorList)):
            try:
                with open(name[w]+'_'+ str(g+1) + '.csv',"r", newline='', encoding='utf8') as tempTable:
                    tableReader=csv.reader(tempTable);
                    originTable = []
                    for row in tableReader:
                        if len (row) !=0:
                            originTable=originTable+[row]
                    tempTable.close()
                print("length of originTable is: "+str(len(originTable)))

                #find the unique chain identifier list
                def findUniChainA():
                    resultList=[]
                    for x in range(1,len(originTable)):
                        if originTable[x][0][:2]==chain+'0':
                            resultList.append(originTable[x][0]) # This is giving me the first column of the table
                    resultList=list(set(resultList))
                    return resultList

                labelList=findUniChainA() # Same as resultslist

                #create the result table that needs to be write to the output file
                resultList=[]

                #create headers
                headerList=['Donor', 'AtomA', 'Acceptor', 'Distance', 'C-alpha Distance', 'Total']

                #adding each row with summation
                for x in range(1,len(labelList)):
                    count=0
                    closest=''
                    distance=''
                    HB=''
                    Salt_Bridge=''
                    Pi_stacking=''
                    Disulf=''
                    vdW=''
                    resultInnerList=[]
                    for y in range(1,len(originTable)):
                        if (originTable[y][0][:2] == chain+'0') and (labelList[x] == originTable[y][0]):
                            # count=count+int(originTable[y][4])+int(originTable[y][5])+int(originTable[y][6])+int(originTable[y][7])+int(originTable[y][8])
                            count = count + 1

                            # time.sleep(3)

                            closest+=originTable[y][1] + '\r\n'
                            distance+=originTable[y][2]+'\r\n'
                            HB+=str(originTable[y][4]) + '\r\n'
                            Salt_Bridge+=str(originTable[y][5]) + '\r\n'
                            # Pi_stacking+=str(originTable[y][6])
                            # Disulf+=str(originTable[y][7])
                            # vdW+=str(originTable[y][8])
                    resultInnerList.append(labelList[x])
                    resultInnerList.append(closest)
                    resultInnerList.append(distance)
                    resultInnerList.append(HB)
                    resultInnerList.append(Salt_Bridge)
                    # resultInnerList.append(Pi_stacking)
                    # resultInnerList.append(Disulf)
                    # resultInnerList.append(vdW)
                    resultInnerList.append(count)
                    resultList.append(resultInnerList)

                #sort the result output by using attribute 'total'
                resultList=sorted(resultList, key=lambda resultInnerList: resultInnerList[5],reverse=True)
                print('Length of New Table: ' + str(len(resultList)))

                #add header to the resultList
                resultList.insert(0,headerList)

                #write to "Output.csv"
                with open(name[w]+ " "+str(g+1)+ " Total_Table.csv", "w", newline='') as csv_file:
                    writer = csv.writer(csv_file, delimiter=',')
                    for i in range(0,len(resultList)):
                        writer.writerow(resultList[i])
            except OSError:
                pass;

        os.chdir('..')



