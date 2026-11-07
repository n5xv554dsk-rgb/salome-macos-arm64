def MaFonction (monArgument1, monArgument2 = 3):
    print ('********************************************')
    print ('je passe dans MaFonction du catalogue metier')
    print ('monArgument1 = ', monArgument1)
    print ('monArgument2 = ', monArgument2)
    print ('********************************************')

# ----------------------------------------

import os, sys
if os.path.join(os.path.abspath(os.path.dirname(__file__)),'..') not in sys.path :
   sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))
from InterfaceQT4.eficas_go import validateFonction 

#MaFonction('1er appel sans Validation')
#MaFonction(1)
MaFonction=validateFonction(MaFonction)
#MaFonction('1er appel texte avec validation')
MaFonction('1er appel texte avec validation', monArgument2= 33)
MaFonction(1)

