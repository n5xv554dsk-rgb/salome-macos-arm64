
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

from ExtractGeneratorLoadLineandTransfoDicoProcess import *
import os

path1 = os.path.abspath(os.path.join(os.path.abspath(__file__), '../','TreatOutputs'))
sys.path.append(path1)
import Options

def INCLUDE(self,PSSE_path,**args):
   """
       Fonction sd_prod pour la macro INCLUDE
   """
   CaseFolder = args['output_folder']
   Options.RecursiveDepth = args['MaxDepth']
   if CaseFolder==None:
      return
   reevalue=0
   if hasattr(self,'fichier_ini'):
       reevalue=1
       if self.fichier_ini == CaseFolder : return
       if hasattr(self,'old_context_fichier_init' ):
         for concept in self.old_context_fichier_init.values():
             self.jdc.delete_concept(concept)
         self.jdc_aux=None
         self.contexte_fichier_init={}
         self.reevalue_sd_jdc()
         self.jdc.reset_context()

   self.fichier_ini=CaseFolder
   self.contexte_fichier_init = {}
   self.fichier_unite = 999
   self.fichier_err = None
   self.fichier_text=""

   unite = 999

   CaseFile = ''
   FolderList = os.listdir(CaseFolder)
   for folder in FolderList:
      if folder[0:7] == 'package' or folder[0:4]== 'core':
         # Get BaseCase.sav inside the first package folder we find
         FolderContents = os.listdir(os.path.join(CaseFolder, folder))
         for file in FolderContents:
            if file == 'BaseCase.sav':
               CaseFile = os.path.join(os.path.join(CaseFolder, folder), file)
               break
         break

           
   #try:
   if 1 :
      BusList, LinesList, TransfosList = getNominalkV(CaseFile)
      #print "version en dur : decommenter la ligne suivante"
      #getTrueLines(CaseFile)
   #except Exception, e:
   #   exc_type, exc_obj, exc_tb = sys.exec_info()
   #   print(e)
   #   print(exc_type, exc_tb.tb_lineno)

   
   for e in self.jdc.etapes:
       if e.nom == 'CASE_SELECTION' : 
          etape=e
          break
   self.jdc.editor.changeIntoMC(e, 'BusesList', BusList)
   self.jdc.editor.changeIntoMC(e, 'LinesList', LinesList)
   self.jdc.editor.changeIntoMC(e, 'TransformersList', TransfosList)

   self.jdc.editor.changeIntoDefMC('CONTINGENCY_SELECTION', ('Automatic_N_2_Selection', 'BusesList'), BusList)
   self.jdc.editor.changeIntoDefMC('CONTINGENCY_SELECTION', ('Automatic_N_2_Selection', 'LinesList'), LinesList)
   self.jdc.editor.changeIntoDefMC('CONTINGENCY_SELECTION', ('Automatic_N_2_Selection', 'TransformersList'), TransfosList)
   

   try:
       print "version en dur : decommenter la ligne suivante"
       #a = updateConts()
       self.jdc.editor.changeIntoDefMC('CONTINGENCY_SELECTION', ('MultipleContingencyList', 'ComponentList'), Options.ContFullList)
   except Exception as e:
      exc_type, exc_obj, exc_tb = sys.exec_info()
      print(e)
      print(exc_type, exc_tb.tb_lineno)





def INCLUDE_context(self,d):
   """
       Fonction op_init pour macro INCLUDE
   """
   for k,v in self.g_context.items():
      d[k]=v


def PROCESS_context(self,d):
    print "dans le init du Process"
    if self.get_child('XLS_file').valeur == "" or self.get_child('XLS_file').valeur== None : return
    self.OngletsSelectionnes= self.get_child('b_TabList').get_child('TabList').valeur
    print "fin de PROCESS_context"

def PROCESS(self,XLS_file,**args):

    # self = Accas.A_MACRO_ETAPE.MACRO_ETAPE
    self.sauve_args=args
    if XLS_file == "" or XLS_file == None: return
    #print XLS_file
    #Storage.csvFileName = XLS_file
    # c est la premiere fois
    
    if not (hasattr(self,'sheets')) :
       #print 'attention en dur'
       #from Processor_Storage import *
       #print getSheets
       #getSheets()
       #ComponentList, ContingencyList = getComponentandContingencyList(Storage.sheets[0])
       #print ComponentList
       #print ContingencyList
       #Storage.selectedDoubleRow[Storage.sheets[0]]=['PV MATIMBA']
       #Storage.selectedDoubleCol[Storage.sheets[0]]=['MAZENOD_MHDAM_LI1_']
       #self.jdc.editor.changeIntoMC(self,'TabList',Storage.sheets)
       #self.sheets=Storage.sheets
       #self.OngletsValeurs=[]

       from Processor import getXLSinfo        
       self.sheets = getXLSinfo(XLS_file)
       self.jdc.editor.changeIntoMC(self,'TabList',self.sheets.keys(),('b_TabList',))
 
       self.MCAjoutes=[]
       self.OngletsSelectionnes=[]
       
    else :
       # On a selectionne un onglet 
       # On teste si on a modifie la liste des onglets

       nouveauxOngletsSelectionnes= self.get_child('b_TabList').get_child('TabList').valeur
       if  nouveauxOngletsSelectionnes==self.OngletsSelectionnes : return
       if nouveauxOngletsSelectionnes==() or nouveauxOngletsSelectionnes == [] :
          for MC in self.MCAjoutes : self.jdc.editor.deleteMC(self,MC,('b_TabList',))
          self.MCAjoutes=[]
          self.OngletsSelectionnes=[]
          self.jdc.editor.fenetreCentraleAffichee.reaffiche()
          return
          
       for Onglet in nouveauxOngletsSelectionnes:
           if Onglet in self.OngletsSelectionnes : continue

           MCFils='Component_List_For_'+Onglet
           monInto=self.sheets[Onglet][0]
           self.jdc.editor.ajoutDefinitionMC('CONTINGENCY_PROCESSING',('b_TabList',),MCFils,'TXM',min=0, max='**', into=monInto, homo= 'SansOrdreNiDoublon')
           self.jdc.editor.ajoutMC(self,MCFils,[],('b_TabList',))
           self.MCAjoutes.append(MCFils)

           MCFils='Contingency_List_For_'+Onglet
           monInto=self.sheets[Onglet][1]
           self.jdc.editor.ajoutDefinitionMC('CONTINGENCY_PROCESSING',('b_TabList',),MCFils,'TXM',min=0, max='**', into=monInto, homo= 'SansOrdreNiDoublon')
           self.jdc.editor.ajoutMC(self,MCFils,[],('b_TabList',))
           self.MCAjoutes.append(MCFils)


       for Onglet in self.OngletsSelectionnes:
           if Onglet in nouveauxOngletsSelectionnes : continue

           MCFils='Contingency_List_For_'+Onglet
           self.jdc.editor.deleteMC(self,MCFils,('b_TabList',))
           self.jdc.editor.deleteDefinitionMC('CONTINGENCY_PROCESSING',('b_TabList',),MCFils)
           self.MCAjoutes.remove(MCFils)

           MCFils='Component_List_For_'+Onglet
           self.jdc.editor.deleteMC(self,MCFils,('b_TabList',))
           self.jdc.editor.deleteDefinitionMC('CONTINGENCY_PROCESSING',('b_TabList',),MCFils)
           self.MCAjoutes.remove(MCFils)

       self.OngletsSelectionnes=nouveauxOngletsSelectionnes
       self.jdc.editor.fenetreCentraleAffichee.reaffiche()
   
