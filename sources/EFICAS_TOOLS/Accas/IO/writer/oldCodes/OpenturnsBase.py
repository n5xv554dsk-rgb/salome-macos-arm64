# -*- coding: iso-8859-1 -*-
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
Ce module contient la partie commune 
aux generateurs XML et Etude d Openturns
"""

__revision__ = "V1.0"

import os
import sys

path=os.getcwd()
pathDef=path+"DefautOpenturns"

sys.path.append(pathDef)


#=============================================
# La classe generale
#=============================================

class Generateur :

  '''
  Classe generale du generateur
  DictMCVal : dictionnaire des mots-cles
  ListeVariables : chaque variable est decrite par un dictionnaire ; cette liste les regroupe
  DictLois : dictionnaires des lois
  '''
  def __init__ (self, appli, DictMCVal = {}, ListeVariables = [], DictLois = {}, DictVariables = {} ) :
  #---------------------------------------------------------#
    self.ListeVariables = ListeVariables
    self.ListeVariablesIn = []
    self.ListeVariablesOut = []
    self.DictLois = DictLois
    self.DictVariables = DictVariables
    self.DictMCVal = DictMCVal
    self.DictTypeVar = {}
    self.nbVarIn = 0
    self.nbVarOut = 0
    self.creeInfoVar()
    self.appli = appli
    #
    # On charge eventuellement le Solver par defaut
    # et les valeurs par defaut du Solver (dans l init)
    #
    try :
    #if 1 :
        Solver = self.DictMCVal["PhysicalSolver"]
        import_name = "Defaut"+Solver
	self.module = __import__( import_name, globals(), locals() )
	monDefaut = self.module.Defaut( self )
    #else :
    except:
        self.module = None


  def getSTDGenerateur(self) :
  #--------------------------#
    try :
	gener = self.module.__dict__["MonSTDGenerateur"]
	monSTDGenerateur=gener( self.DictMCVal, self.ListeVariablesIn, self.ListeVariablesOut, self.DictLois )
    except :
        from OpenturnsSTD import STDGenerateur
        monSTDGenerateur = STDGenerateur( self.appli, self.DictMCVal, self.ListeVariablesIn, self.ListeVariablesOut, self.DictLois )
    return monSTDGenerateur
      
  def getXMLGenerateur(self) :
  #--------------------------#
    try :
	gener = self.module.__dict__["MonXMLGenerateur"]
	monXMLGenerateur=gener( self.DictMCVal, self.ListeVariables, self.DictLois )
    except :
        from OpenturnsXML import XMLGenerateur
        monXMLGenerateur = XMLGenerateur( self.appli, self.DictMCVal, self.DictVariables )
    return monXMLGenerateur
      
  def creeInfoVar (self) :
  #----------------------#
    """
    On repere les variables in/out et on les numerote.
    """
    num = 0
    liste = []
    for DictVariable in self.ListeVariables :
      if not DictVariable.has_key("Type") : DictVariable["Type"] = "in"
      self.DictTypeVar[num] = DictVariable["Type"]
      if DictVariable["Type"] == "in" : 
         self.nbVarIn = self.nbVarIn + 1
         self.ListeVariablesIn.append( DictVariable )
         print "OpenturnsBase.py: new input variable = ", DictVariable
      else:
         self.nbVarOut = self.nbVarOut + 1
         self.ListeVariablesOut.append( DictVariable )
         print "OpenturnsBase.py: new output variable = ", DictVariable
      liste.append( DictVariable )
      num = num + 1
    self.ListeVariables = liste


  def ajouteDictMCVal(self, dicoPlus) :
  #-----------------------------------#
  # Appele par le classe Defaut du python specifique au code (exple DefautASTER.py)
  # enrichit self.DictMCVal avec les valeurs donnees dans dicoPlus
  # si elles ne sont pas deja dans le dictionnaire

    for clef in dicoPlus.keys():
        if not self.DictMCVal.has_key(clef) :
	   self.DictMCVal[clef] = dicoPlus[clef]

  def ajouteInfoVariables (self, dicoVariablesIn, dicoVariablesOut) :
  #-----------------------------------------------------------------#
  # Appele par le classe Defaut du python specifique au code (exple DefautASTER.py)
  # met a jour les dictionnaires qui decrivent les variables (regexp par exemple)
    liste=[]
    num = 0
    for dictVariable in self.ListeVariables:
         if self.DictTypeVar[num] == "in" :
	    dico = dicoVariablesIn
	 else :
	    dico = dicoVariablesOut
	 for nouvelleVariable in dico.keys() :
	    if not dictVariable.has_key(nouvelleVariable):
	       dictVariable[nouvelleVariable] = dico[nouvelleVariable]
	 liste.append( dictVariable )
	 num = num + 1
