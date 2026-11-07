# coding: utf-8
import types
import sys,os
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/mapy/components/c_pre_polymer_data_management')
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/mapy/virtual_polymer_common')
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/')
import pckdb, class_data, instruction, equation_part, utils

# --------------------------------------
class sModele :
# --------------------------------------

    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(sModele, cls).__new__(
                                cls, *args, **kwargs)

        return cls._instance

    def __init__ (self):
        self.monModele=class_data.Modele()
        self.monPost=class_data.Post_traitement()


# --------------------------------------
class classeListesDB :
# --------------------------------------

    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(listesDB, cls).__new__(
                                cls, *args, **kwargs)

        return cls._instance

    def __init__ (self):
        self.listEquation       = None
        self.listModele         = None
        self.listPostTraitement = None
        self.dicoListAffiche   = {}
        self.valeurEquationChoisie = None
        self.listeConstantesAAfficher = []
        self.listeEquationsAAfficher = []
        self.listeCoefD  = []
        self.listeCoefB  = []
        self.dictParametresInitiaux = {}
        self.listeParametresInitiaux= []
        self.listeCoefInitiaux= []
        self.listeCoefASupprimer= []
        self.dicoCoefAffichageArr   = {}
        self.dicoModeleFiltre = {}
        self.dicoMateriauxFiltre = {}
        self.monModele = None
        self.listeDiffusion = []

    def metAJour(self,valeur):
        print ('metAJour')
        if valeur == None : return
        correspond=pckdb.DBRENAME
        self.listEquation, self.listModele,self.listPostTraitement=pckdb.read_pckdb(correspond[valeur])
        self.dicoListeEquation   = {}
        for equation in self.listEquation :
            self.dicoListeEquation[equation.representation]=equation

    def getListEquation(self):
        return self.listEquation

    def getListModele(self):
        return self.listModele

    def getListPostTraitement(self):
        return self.listPostTraitement

    def getdicoListAffiche(self):
        return self.dicoListAffiche
