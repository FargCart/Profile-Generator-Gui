import csv
import os
tableOfResidueList=[]
tableOfInteractionList=[]
# titleList=["DL11","E317","MC2","MC5","MC14","MC23","1D3"]
existNumbers=[]
DockPerAntibody=31
titleList = []
def heatmap(name):

    titleList.append(name)
    numBlock = 0
    numMiss = 0
    totalFiles = len(os.listdir('.'))

#open csv file
    for i in range(0, len(titleList)):
        for t in range(0, DockPerAntibody):
            try:
                with open(str(titleList[i])+"_interaction_table_"+str(t)+".csv", "r") as firstDock:
                    firstDockReader=csv.reader(firstDock)
                    dockList = []
                    for row in firstDockReader:
                        if len (row) !=0:
                            dockList=dockList+[row]



        #define the array to collect the desired data
                existNumbers.append(t+i*DockPerAntibody)
                columnOfResidue=0
                columnOfinteraction=3
                residueList=[]
                interactionList=[]

                for x in range(1,len(dockList)):
                    if dockList[x][0][:2]=="A:":
                        residueList.append(dockList[x][columnOfResidue])
                        interactionList.append(dockList[x][columnOfinteraction])
                tableOfResidueList.append(residueList)
                tableOfInteractionList.append(interactionList)

            except:
                pass

    #print(len(tableOfResidueList))

    #firstDock.close()
    #for i in range(0,len(dockList)):
       # print(dockList[i][0])


        resultList=[]

        for i in range(0,len(tableOfInteractionList)):
            innerList=[]
            innerList.append(str(titleList[int(existNumbers[i]/DockPerAntibody)])+"_dock_"+str(int(existNumbers[i]%DockPerAntibody)))
            for j in range(0,len(tableOfInteractionList)):

                result=bool(set(tableOfResidueList[i])&set(tableOfResidueList[j]))
                matchList=[]
                if(result==True):
                    compareList=[p for p, item in enumerate(tableOfResidueList[i]) if item in set(tableOfResidueList[j])]

                    #used for debugging
                    #print(len(compareList))

                    for k in range(0,len(compareList)):
                        for l in range(0,len(tableOfResidueList[j])):
                            if(tableOfResidueList[i][compareList[k]]==tableOfResidueList[j][l]):
                                match=[compareList[k],l]
                                matchList.append(match)


                    for m in range(0,len(matchList)):
                        a=matchList[m][0]
                        b=matchList[m][1]
                        if(tableOfInteractionList[i][a] =="" or tableOfInteractionList[j][b]==""):
                            result=False
                        else:
                            result=True
                            break

                if result==True:
                    innerList.append(0)
                    numBlock = numBlock + 1
                    # print(0,end=" ")
                else:
                    innerList.append(1)
                    numMiss = numMiss + 1
                    # print(1,end=" ")

            # print(" ")

            resultList.append(innerList)


        # append title of the result file
        dockTitle=[]
        dockTitle.append("")
        for i in range(0,len(tableOfInteractionList)):
            dockTitle.append(str(titleList[int(existNumbers[i]/DockPerAntibody)])+"_dock_"+str(int(existNumbers[i]%DockPerAntibody)))



        #write to csv file
        with open(str(titleList[0])+"_Heatmap.csv", "w",newline='') as csv_file:
            writer = csv.writer(csv_file, delimiter=',')
            writer.writerow(dockTitle)
            for i in range(0,len(tableOfInteractionList)):
                writer.writerow(resultList[i])
    print('Block = 0')
    print('Miss = 1')
    numBlock = (numBlock / (totalFiles*totalFiles))*100
    numMiss = (numMiss / (totalFiles*totalFiles))*100
    print("Percentage of Ab docks that BLOCK = " + str(round(numBlock, 2)) + "%")
    print('Number of Ab docks that MISS = '+ str(round(numMiss, 2))+ '%')
