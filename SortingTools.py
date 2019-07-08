'''
Created on Jun 12, 2018

@author: Juechen
'''
def SortMetrics(Metrics):
    Metrics=sorted(Metrics[1:], key=lambda l:l[1], reverse=False)
    return Metrics
def SortHeatmap(Heatmap,Metrics,heatmapdic):
    result=[]
    result.append(Heatmap[0])
    for x in Metrics:
        result.append([x[0]]+heatmapdic.get(x[0]))
    return result

def SwitchRC(table):
    for i in range(0,len(table)):
        for j in range(i,len(table)):
            if i!=j:
                temp=table[i][j]
                table[i][j]=table[j][i]
                table[j][i]=temp
    return table