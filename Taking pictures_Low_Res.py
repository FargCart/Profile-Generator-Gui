import os
import pymol
from pymol import cmd
import threading
pymol.finish_launching()
# cmd.set('ray_trace_frames', 1)
#cmd.load('gD2_210x210_5Bins.pse')


###cmd.do("set_view (\
##     0.017460318,    0.924570978,    0.380608171,\
##    -0.993971765,   -0.025162365,    0.106722049,\
##     0.108249441,   -0.380176693,    0.918557346,\
##     0.000000000,    0.000000000, -405.812103271,\
##    55.625644684,   37.695159912,   84.070343018,\
##  -75252.234375000, 76063.843750000,  -20.000000000 )")



cmd.png("Face1.png",3500,2925,250.0,False,False)
cmd.sync(1.0,20)
cmd.turn('y',-90.0)
cmd.png('Face2.png',3500,2925,250,0,False,False)
cmd.sync(1.0,20)
cmd.turn('y',-90.0)
cmd.png('Face3.png',3500,2925,250,0,False,False)
cmd.sync(1.0,20)
cmd.turn('y',-90.0)
cmd.png('Face4.png',3500,2925,250,0,False,False)
cmd.sync(3.0,30)
cmd.turn('y',-90.0)
cmd.turn('y',-90.0)
cmd.turn('x',90.0)
cmd.sync(3.0,30)



  
  
