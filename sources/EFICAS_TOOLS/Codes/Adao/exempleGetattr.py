#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""
"""
import sys,os
import prefs
sys.path.append(os.path.join(os.path.abspath(os.path.dirname(__file__)),'..'))

from InterfaceQT4 import eficas_go
jdd = eficas_go.createFromDocumentAccas('ADAO_Cata_V0_pour_V9_5_0.py','exemple01_Func.comm')


# les premiers niveaux sont tous des listes dans eficas car il est possible 
# d en avoir plusieurs
myCheckingStudy=jdd.CHECKING_STUDY[0]
print ('myCheckingStudy', myCheckingStudy, ' a pour nom', myCheckingStudy.StudyName)

# Pour les Facts, si c est une liste d'elements, utilisation de [n] 
# si la liste ne contient qu'un element, l' utilisation de [0]  est optionnelle

print (myCheckingStudy.AlgorithmParameters.Algorithm)
print (myCheckingStudy.AlgorithmParameters[0].NumberOfRepetition)

print ('on fait une erreur volontaire')
try :
  myAssimilationStudy=jdd.ASSIMILATION_STUDY[0]
except : 
  print ('myAssimilationStudy non trouve')
  myAssimilationStudy=None

# Pour les OPER il est aussi possible de chercher par le nom du concept produit
# n exite pas dans Adao
#monRodBank2=jdd.getEtapeByConceptName('RB')



