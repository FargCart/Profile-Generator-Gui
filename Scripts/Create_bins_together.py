# Will put all the csv files that in a folder into one file
import os


def cbt(bins):

    Num=bins
    num=int(Num)
    name=str(Num)
    for i in range(0,num):
        os.chdir('Bin '+str(i+1))
        os.system('cat *.csv>Bin_'+str(i+1)+'.csv')
        os.chdir('..')
                
                  
