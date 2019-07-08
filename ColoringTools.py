'''
Created on Mar 20, 2018

@author: Juechen
'''
from pymol import cmd
def ColorResidues(BaseNumber,model,color,RawData,ResiMax,FeatureColumn):
    for x in RawData:
        number=x[0].split(':')[1]
        if number in ResiMax.keys():
            if ResiMax.get(number)[0]<float(x[FeatureColumn]):
                ColorDegree=float(1-float(x[FeatureColumn])/float(RawData[0][FeatureColumn]))*BaseNumber
                if ColorDegree==BaseNumber:
                    continue
                else:
                    RGBList=[0,0,0]
                    for y in range(0,3):
                        if model[y]==BaseNumber:
                            RGBList[y]=model[y]
                        else:
                            RGBList[y]=model[y]+ColorDegree*(1-model[y]/float(BaseNumber))
                    
                    ResiMax[number]=[float(x[FeatureColumn]),color]
                    cmd.set_color(number+color+'desired',RGBList)
                    cmd.color(number+color+'desired','res '+number)
        else:
            ColorDegree=float(1-float(x[FeatureColumn])/float(RawData[0][FeatureColumn]))*BaseNumber
            if ColorDegree==BaseNumber:
                continue
            else:
                RGBList=[0,0,0]
                for y in range(0,3):
                    if model[y]==BaseNumber:
                        RGBList[y]=model[y]
                    else:
                        RGBList[y]=model[y]+ColorDegree*(1-model[y]/float(BaseNumber))
                
                ResiMax[number]=[float(x[FeatureColumn]),color]
                cmd.set_color(number+color+'desired',RGBList)
                cmd.color(number+color+'desired','res '+number)

    
    return ResiMax


    
    