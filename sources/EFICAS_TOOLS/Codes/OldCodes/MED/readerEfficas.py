#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os
import raw.efficas as efficas
import types

sys.path.insert(0,os.path.abspath(os.path.join(os.getcwd(),'..')))
sys.path.insert(0,os.path.abspath(os.path.join(os.getcwd(),'..','UiQT5')))


from Accas import *


# Attention pas d heritage possible (cf doc pyxbe)

dictSIMPEficasXML= { 'typ'    : 'typeAttendu', 'statut'     : 'statut', 
                     'min_occurs': 'min'        , 'max_occurs' : 'max', 
                     'homo'      : 'homo'       , 'position'   : 'portee', 
                     'validators': 'validators' , 'sug'        : 'valeur_sugg',
                     'defaut'    : 'ValeurDef'  , 'into'       : ('PlageValeur','into'), 
                     'val_min'   : ('PlageValeur','borne_inf') , 'val_max'    : ('PlageValeur','borne_sup'),
                     'ang'       : ('doc','ang')               , 'fr'         : ('doc','fr',)   ,
                     'docu'      : ('doc','docu'),}
 
dictSIMPXMLEficas = {'doc' : {'fr' : 'fr' , 'ang' : 'ang' , 'docu' : 'docu' },
		     'PlageValeur' : {'borne_sup' : 'val_max' , 'into' : 'into' , 'borne_inf' : 'val_min' ,},
		     'statut' : 'statut' , 'validators' : 'validators' , 'homo' : 'homo' ,
		     'ValeurDef' : 'defaut' ,  'min' : 'min_occurs' ,
		     'valeur_sugg' : 'sug' , 'portee' : 'position' , 'max' : 'max_occurs' , }


# ------------------------------
class monSIMP (efficas.T_SIMP):
# ------------------------------

   def explore(self):
      print "je passe dans  explore pour SIMP ", self.nom
      self.dictArgsEficas={}
      self.dictArgsEficas['typ']=self.typeAttendu
      for nomXMLArg in dir(self) :
          if nomXMLArg in dictSIMPXMLEficas.keys() :
              nomEficasArg=dictSIMPXMLEficas[nomXMLArg]
              argu=getattr(self,nomXMLArg)
              if argu==None : continue
              if type(nomEficasArg) == types.DictionaryType:
                 for nomXML in nomEficasArg.keys():
                      arguDecoupe=getattr(argu,nomXML)
                      nomEficasDecoupe=nomEficasArg[nomXML]
                      self.dictArgsEficas[nomEficasDecoupe]=arguDecoupe
              else :
                 self.dictArgsEficas[nomEficasArg] = argu
                    
              #if argNew != None : print argNew
      self.objAccas=A_SIMP.SIMP(**self.dictArgsEficas)
      self.objAccas.nom=self.nom
     
   def getAccasEquivalent(self):
       return self.nom, self.objAccas

# ------------------------------
class monPROC(efficas.T_PROC):
# ------------------------------
   def explore(self):
      print "je passe dans  explore pour PROC ", self.nom
      self.dictConstruction={}
      self.dictConstruction['nom']=self.nom
      
      for obj in self.content(): 
          if  hasattr(obj,'explore') : obj.explore ()
          if  hasattr(obj,'getAccasEquivalent') : 
              nom,objetAccas=obj.getAccasEquivalent()
              self.dictConstruction[nom]=objetAccas
      self.dictConstruction['op']=None
      self.objAccas=A_PROC.PROC(**self.dictConstruction)
      print dir(self.objAccas)
      print self.objAccas.entites


# ------------------------------
class monFACT(efficas.T_FACT):
# ------------------------------
   def explore(self):
      #print "je passe dans  explore pour FACT ", self.nom
      self.dictConstruction={}
      for obj in self.content(): 
          if  hasattr(obj,'explore') : obj.explore 
          if  hasattr(obj,'creeAccasEquivalent') : 
              nom,objetAccas=obj.creeAccasEquivalent()
              self.dictConstruction[nom]=objetAccas
      self.objAccas=A_FACT.FACT(**self.dictConstruction)

   def getAccasEquivalent(self):
       return self.nom, self.objAccas


# ------------------------------
class monCata(efficas.T_cata):
# ------------------------------
   def exploreCata(self):
   # On positionne le contexte ACCAS
      self.JdC = JDC_CATA (code = 'MED', execmodul = None,)
      objAExplorer=self.commandes[0]
      for obj in objAExplorer.content(): 
         if  hasattr(obj,'explore') : obj.explore()
    
     

efficas.T_SIMP._SetSupersedingClass(monSIMP)
efficas.T_FACT._SetSupersedingClass(monFACT)
efficas.T_PROC._SetSupersedingClass(monPROC)
efficas.T_cata._SetSupersedingClass(monCata)

if __name__ == "__main__":
#   print dir(efficas)
#   print dir(efficas.T_SIMP)


   xml = open('Cata_MED_FAM.xml').read()
   SchemaMed = efficas.CreateFromDocument(xml)
   SchemaMed.exploreCata()

   #print dir(efficas.T_SIMP)
   #print dir(efficas.T_SIMP)

   #for maCommande in monCata.commandes :
   #    for monProc in maCommande.PROC:
   #        for monFact in monProc.FACT:
   #            for simp in monFact.SIMP:
   #                simp.creeAccasEquivalent()
