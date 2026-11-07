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

#from ExtractGeneratorLoadLineandTransfoDico import *
#from ExtractGeneratorLoadLineandTransfoDico import ExtractGeneratorLoadLineandTransfoDico2

def INCLUDE(self,PSSE_path,**args):
   """
       Fonction sd_prod pour la macro INCLUDE
   """
   #print('in INCLUDE')
   #print args
   CaseFolder = args['output_folder']
   if CaseFolder==None: return
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

   BusList = [138, 77, 69]
   self.jdc.appli.changeIntoMC(self,'BusesList',BusList)



def INCLUDE_context(self,d):
   """
       Fonction op_init pour macro INCLUDE
   """
   for k,v in self.g_context.items():
      d[k]=v


def PROCESS_context(self,d):
    print "dans le init du Process"

def PROCESS(self,XLS_file,**args):
    if XLS_file == "" or XLS_file == None: return
    if not (hasattr(self,'dico')) :
       from Processor import getXLS
       self.dico=getXLS(XLS_file)
       self.jdc.appli.changeIntoMC(self,'Onglets',self.dico.keys())
       self.OngletsValeurs=[]
    else :
       # On teste si on a modifie la liste des onglets
       OngletsValeurs= self.get_child('Onglets').getval()
       

       if not (hasattr(self,'OngletsValeurs')) : self.OngletsValeurs=OngletsValeurs
       elif self.OngletsValeurs == OngletsValeurs : print 'return' ;return
       else : self.OngletsValeurs=OngletsValeurs

       if OngletsValeurs==() or OngletsValeurs == []: 
          self.jdc.appli.deleteMC(self,'BusList')
          self.jdc.appli.deleteMC(self,'ContList')
          self.OngletsValeurs=[]
          return

       OldBusValeurs= self.get_child('BusList').getval()
       OldContValeurs= self.get_child('ContList').getval()
       if OldBusValeurs ==  None : OldBusValeurs=[]
       if OldContValeurs ==  None : OldContValeurs=[]

       listeBus=[]
       listeCont=[]
       listeBusCoches=[]
       listeContCoches=[]
       for o in OngletsValeurs :
           for b in self.dico[o][0]:
               texte=b+" ("+ str(o) +" )"
               listeBus.append(str(texte))
               if texte in OldBusValeurs : listeBusCoches.append(str(texte))
           for c in self.dico[o][1]:
               texte=c+" ("+ str(o) +" )"
               listeCont.append(str(texte))
               if texte in OldContValeurs : listeContCoches.append(str(texte))
           
       self.jdc.appli.changeIntoMCandSet(self,'BusList',listeBus,listeBusCoches)
       self.jdc.appli.changeIntoMCandSet(self,'ContList',listeCont,listeContCoches)
   

