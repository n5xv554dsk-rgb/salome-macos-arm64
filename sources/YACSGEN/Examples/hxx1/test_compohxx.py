#==============================================================================
#  File      : CALCUL_test.py
#  Created   :
#  Author    :
#  Project   : SALOME
#  Copyright : CEA 2005-2022
#==============================================================================
#
# Test du composant CALCUL
#
from salome.kernel import SALOME
from salome.kernel import salome
salome.salome_init()
print("Test du composant CALCUL genere par hxx2salome")
import hxxcompos_ORB
myCalc = salome.lcc.FindOrLoadComponent("FactoryServer", "CALCUL")
print("10+15 = ",myCalc.add(10,15))
print("10x15 = ",myCalc.mul(10,15))
#print "6!    = ",myCalc.fact(6)
res1,res2 = myCalc.sqr2(12.0)
print("12*12 = ",res1," ",res2)
j=1
i1,i2,i3 = myCalc.return_3_int(j)
assert (i1 == j+1),'Erreur dans la fonction return_3_int'
assert (i2 == j+2),'Erreur dans la fonction return_3_int'
assert (i3 == j+3),'Erreur dans la fonction return_3_int'
print('return_3_int : ',j,' ',i1,' ',i2,' ',i3)
print("True && True  = ",myCalc.And(True,True))
print("True && False = ",myCalc.And(True,False))
print("True || False = ",myCalc.Or(True,False))
from math import fabs
assert (fabs(res1-144.0)<1.0e-6 ), 'Erreur dans la fonction myCalc.sqr2 : 12*12 = '+str(res1)
assert ( myCalc.And(True,True)==True ) , 'Erreur dans la fonction And(True,True)'
assert ( myCalc.And(True,False)==False ) , 'Erreur dans la fonction And(True,False)'
assert ( myCalc.Or(True,False)==True ) , 'Erreur dans la fonction Or(True,False)'
print("Fin test hxx2salome/001/A1")
#
myCoco = salome.lcc.FindOrLoadComponent("FactoryServerI", "ICOCO")
#
liste_champs = myCoco.getInputFieldsNames()
nb_champs=len(liste_champs)
print("Nombre de champs = ",nb_champs)
assert  nb_champs == 2 , 'erreur dans le nombre de champs, different de 2!'
#
print("Champ 1 (SourceField) : ",liste_champs[0])
print("Champ 2 (TargetField) : ",liste_champs[1])
assert liste_champs[0] == "SourceField", 'erreur dans le nom du champ 1'
assert liste_champs[1] == "TargetField", 'erreur dans le nom du champ 2'
#
print("Fin test hxx2salome/ICOCO/A1")
myCoco1 = salome.lcc.FindOrLoadComponent("FactoryServerI1", "ICOCO")
myCoco2 = salome.lcc.FindOrLoadComponent("FactoryServerI2", "ICOCO")
#
myCoco1.initialize()
m=myCoco1.getInputFieldTemplate("TargetField")
myCoco1.solve()  #to test with 5.1.5
f=myCoco1.getOutputField("SourceField")
myCoco2.printField(f)
#
print("##################################")
print("Fin test hxx2salome/ICOCO/A2")
