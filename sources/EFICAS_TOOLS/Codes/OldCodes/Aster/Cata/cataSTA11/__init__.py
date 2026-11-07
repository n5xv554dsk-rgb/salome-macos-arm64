import os,sys
sys.modules["Cata"]=sys.modules[__name__]
rep_macro = os.path.dirname(__file__)
sys.path.insert(0,rep_macro)
rep_macro=os.path.join(rep_macro,'Macro')
sys.path.insert(0,rep_macro)

if sys.modules.has_key("SD"):
  del sys.modules["SD"]
for k in sys.modules.keys():
  if k[0:3] == "SD.":
    del sys.modules[k]


from cata import *
from math import ceil
from Accas.extensions import param2
pi=param2.Variable('pi',pi)
