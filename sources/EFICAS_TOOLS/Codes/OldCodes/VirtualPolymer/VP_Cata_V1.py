# coding: utf-8
import types
from Accas import *
import sys,os
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/mapy/components/c_pre_polymer_data_management')
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/mapy/virtual_polymer_common')
sys.path.append('/home/A96028/opt/MAP/map-2016.1/lib/python2.7/site-packages/')
import pckdb, class_data, instruction, equation_part, utils


monDico= { 'Equation_Liste' : ('initiation', 'propagation', 'termination', 'stabilization'),
           'Modele_TechnicalUse' : ('cable', 'coating', 'pipes'),
         }

class Tuple:
    def __init__(self,ntuple):
        self.ntuple=ntuple

    def __convert__(self,valeur):
        if type(valeur) == types.StringType: return None
        if len(valeur) != self.ntuple: return None
        return valeur

    def info(self):
        return "Tuple de %s elements" % self.ntuple

    __repr__=info
    __str__=info

#class ObjetUtilisateur(ASSD): pass

class classeVisuEquation :
    def __init__(self,dicoListeAffiche, listEquation, listModele,listPostTraitement):
        self.dicoListeAffiche=dicoListeAffiche
        self.listEquation=listEquation
        self.listModele=listModele
        self.listPostTraitement=listPostTraitement


def maFunc():
    return ('a1','a2','a3')

def maFuncWithArg(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct = True

    editor=monMC.jdc.editor
    if monMC.valeur == 'POOH->P' : monInto=('a1','a2','a3')
    else : monInto=('b1','b2','b3')

    change=editor.changeIntoDefMC('AGING', ('Equation', 'b_approved','b_type_creation','Equation_Modification','Type2'), monInto )
    if change :
        print ('j ai change le into')
        editor.reCalculeValiditeMCApresChgtInto('AGING', 'Type2', ('Equation', 'b_approved','b_type_creation','Equation_Modification'))
        if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()

    monMC.dsMaFunct = False

def recupereDicoGenerique(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    print ('je passe dans la recuperation')
    editor=monMC.jdc.editor
    valeurDB=editor.getValeur('Equation','Equation_DB',())
    if valeurDB == None : valeurDB=editor.getValeur('Modele','Modele_DB',())
    correspond=pckdb.DBRENAME
    if valeurDB != None :
        listEquation, listModele,listPostTraitement=pckdb.read_pckdb(correspond[valeurDB])
    monMC.dsMaFunct = False
    return listEquation, listModele,listPostTraitement

def recupereDicoEquation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    listEquation, listModele,listePostTraitement=recupereDicoGenerique(monMC)
    editor=monMC.jdc.editor

    valeurEquationListe=editor.getValeur('Equation','Equation_Liste',('b_type_show',))
    valeurAgingType=editor.getValeur('Equation','Equation_reaction',('b_type_show','b_reaction_type',))
    if valeurAgingType == None :
        valeurAgingType=editor.getValeur('Equation','Equation_reaction',('b_type_show','b_aging_type',))
    if valeurAgingType == None : monMC.dsMaFunct = False; return

    listeEquationPourIhm = []
    listeReprEquationPourIhm = []
    dicoListeAffiche={}
    for equation in listEquation :
        if valeurEquationListe == 'aging_type' :
            if equation.type_vieil == valeurAgingType :
                listeEquationPourIhm.append(equation)
                listeReprEquationPourIhm.append(equation.representation)
                dicoListeAffiche[equation.representation]=equation
        else:
            if equation.type_react == valeurAgingType :
                listeEquationPourIhm.append(equation)
                listeReprEquationPourIhm.append(equation.representation)
                dicoListeAffiche[equation.representation]=equation
    change=editor.changeIntoDefMC('Equation', ('b_type_show','ListeEquation'), listeReprEquationPourIhm )
    if change :
        editor.reCalculeValiditeMCApresChgtInto('Equation', 'listeEquation', ('b_type_show',))
        if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    editor.maClasseVisuEquation = classeVisuEquation(dicoListeAffiche,listEquation, listModele,listPostTraitement)
    monMC.dsMaFunct = False

def afficheValeurEquation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    valeur=monMC.valeur
    if valeur == None :
        monMC.dsMaFunct = False
        return
    editor.maClasseVisuEquation.valeurEquationChoisie=valeur
    monMC.dsMaFunct = False


def instancieChemicalFormulation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur == False : return

    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True

    print ('ds instancie')
    v=editor.maClasseVisuEquation.valeurEquationChoisie
    monEquation=editor.maClasseVisuEquation.dicoListeAffiche[v]
    type_react=monEquation.type_react
    type_vieil=monEquation.type_vieil
    print (v, type_react, type_vieil)
    #editor.changeIntoMCandSet('Equation', ('b_type_show','b_modification','b_modif','ChemicalFormulation'),( v,),v )
    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Reaction_Type'),type_react )
    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Aging_Type'), type_vieil )

    for index,valeurConstituant in enumerate(monEquation.constituants):
        valeurEquation=monEquation.equation[index]
        editor.ajoutMC(monMC.etape,'OptionnelConstituant',None,('b_type_show','b_modification','b_modif',))
        print (index,valeurConstituant,valeurEquation)

            #OptionnelConstituant =  FACT ( statut = 'f',max = '**',
            #    Constituant = SIMP (statut = 'o', typ = 'TXM'),
            #    Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),
    for index,valeurConstituant in enumerate(monEquation.const_cine_nom):
        valeurArrhe=monEquation.arrhenius[index]
        if valeurArrhe : valeurConstanteType='Arrhenius type'
        else           : valeurConstanteType='non Arrhenius type'

        print (index,valeurConstituant,valeurConstanteType)
            #OptionnelleConstante  = FACT (statut = 'f', max = '**',
            #     ConstanteName= SIMP (statut = 'o', typ = 'TXM',),
            #    ConstanteType =  SIMP(statut= 'o',typ= 'TXM', min=1,into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Commentaire'),monEquation.comment )
    print (monEquation.comment )
    #if change :
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    monMC.dsMaFunct = False
    editor.dsMaFunct = False

# TEMPORAIRE
# TODO TODO TODO
# PNPNPNPNPN


maClasseDeModele=class_data.Modele()

def recupereDicoModele(monMC):
    if monMC.valeur == None: return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    print ('je passe dans recupereDicoModele')
    listEquation, listModele,listPostTraitement=recupereDicoGenerique(monMC)
    editor=monMC.jdc.editor
    editor.maClasseVisuEquation = classeVisuEquation({},listEquation, listModele,listPostTraitement)
    monMC.dsMaFunct = False


def creeListeEquation(monMC):
    if monMC.valeur == None: return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return

    editor=monMC.jdc.editor
# TEMPORAIRE
# TODO TODO TODO
    listeEquationsAAfficher=[]
    listeConstantesAAfficher=[]
    for index,equation in enumerate( editor.maClasseVisuEquation.listEquation):
        if index in maClasseDeModele.equa:
            listeEquationsAAfficher.append(equation.representation)
            listeConstantesAAfficher.append(equation.const_cine_nom)

    monMC.dsMaFunct = False

    #        listeEquation_stabilization=SIMP(statut='o', homo='SansOrdreNiDoublon', max='**', min=0 ),

def recupereModeleEquation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur==False : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return

    editor.dsMaFunct = True
    dicoListeEquationAAfficher={}

    for valeurReactionType in monDico['Equation_Liste']:
        dicoListeEquationAAfficher[valeurReactionType] = []
        for index,equation in enumerate( editor.maClasseVisuEquation.listEquation):
            if equation.type_react==valeurReactionType :
                dicoListeEquationAAfficher[valeurReactionType].append(equation.representation)
    print (dicoListeEquationAAfficher)

    change=editor.changeIntoDefMC('Modele', ('b_type_creation','b_ajout_equation','listeEquation_initiation'),dicoListeEquationAAfficher['initiation'] )
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','b_ajout_equation','listeEquation_propagation'),dicoListeEquationAAfficher['propagation'] )
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','b_ajout_equation','listeEquation_termination'),dicoListeEquationAAfficher['termination'] )
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','b_ajout_equation','listeEquation_stabilization'),dicoListeEquationAAfficher['stabilization'] )
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    editor.dsMaFunct = False

def prepareDiffusion(monMC):
    print ('je suis dans prepareDiffusion')
    if monMC.valeur==False : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct=True
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True
    editor.dicoCoefS={}
    editor.dicoCoefD={}
    for c in maClasseDeModele.coef[0].keys() :
        if c[0]=='S':
            clef=c[1:]
            valeur= maClasseDeModele.coef[0][c]
            editor.dicoCoefS[clef]=valeur
        if c[0]=='D':
            clef=c[1:]
            valeur= maClasseDeModele.coef[0][c]
            editor.dicoCoefD[clef]=valeur
    print (editor.dicoCoefS,editor.dicoCoefD)
    monMC.dsMaFunct=False
    editor.dsMaFunct = False


def ajouteDiffusion(monMC):
    print ('je suis dans ajouteDiffusion')
    if monMC.valeur == None : return
    print (monMC.valeur)
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct=True
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True


    for v in monMC.valeur :
        print (v)
        mesValeurs=editor.dicoCoefS[v]
        print (editor.dicoCoefS)
        print (mesValeurs)
        MCFils='S'+v
        for e in monMC.jdc.etapes:
            if e.nom == Modele :break

        print (e)
        editor.ajoutDefinitionMC(e,('b_type_creation','b_diffusion'),MCFils,typ='TXM',statut='o' )
        print ('ggggg')
        editor.ajoutMC(e,MCFils,mesValeurs,('b_type_creation','b_diffusion',))
        print ('______')
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    monMC.dsMaFunct=False
    editor.dsMaFunct = False

JdC = JDC_CATA(code='VP',
               execmodul=None,
                )



#---------------------------------
Equation = PROC (nom="Equation",
      op=None,
#---------------------------------
      Equation_DB=SIMP(statut= 'o',typ= 'TXM', into=("Approved data base", "My data base") ),
      Equation_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show equation database", "Equation creation"),),


#     ---------------------------------------------------------------------------
       b_type_show = BLOC(condition = " Equation_Type == 'Show equation database'",
#      ---------------------------------------------------------------------------
        Equation_Liste=SIMP(statut= 'o',typ= 'TXM', into=('reaction_type','aging_type')),

         b_reaction_type =  BLOC(condition = " Equation_Liste  == 'reaction_type'",
           Equation_reaction=SIMP(statut= 'o',typ= 'TXM', into=monDico['Equation_Liste'],siValide=recupereDicoEquation),
         ), # Fin b_reaction_type

         b_aging_type =  BLOC(condition = " Equation_Liste  == 'aging_type'",
              Equation_reaction=SIMP(statut= 'o',typ= 'TXM', into=('All', 'thermo', 'radio'),siValide=recupereDicoEquation),
         ), # Fin b_reaction_type

         ListeEquation = SIMP(statut='o', typ='TXM',  homo='SansOrdreNiDoublon',siValide=afficheValeurEquation),
         b_modification = BLOC(condition = " ListeEquation != None ",
           modification = SIMP(typ = bool, statut = 'o',defaut = False, fr='toto', ang='toto en anglais', siValide=instancieChemicalFormulation),

           b_modif = BLOC(condition = "modification == True",
            Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],),
            Aging_Type=SIMP(statut= 'o',typ= 'TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'),),

            OptionnelConstituant =  FACT ( statut = 'f',max = '**',
                Constituant = SIMP (statut = 'o', typ = 'TXM'),
                Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),
               ), # fin Const_Equa
            OptionnelleConstante  = FACT (statut = 'f', max = '**',
                  ConstanteName= SIMP (statut = 'o', typ = 'TXM',),
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', min=1,into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),# fin ConstanteOptionnelle
            Commentaire =  SIMP (statut = 'f', typ = 'TXM', defaut = ' '),

           ),# fin b_modif

         ), # fin b_modification
       ), # Fin b_type_show


#     ---------------------------------------------------------------------------
      b_type_creation = BLOC(condition = " Equation_Type == 'Equation creation'",
#         ---------------------------------------------------------------------------
         Equation_Modification = FACT ( statut = 'o',

            ChemicalFormulation = SIMP(statut='o', typ='TXM', defaut = 'POOH -> 2P'),

            Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],),
            Aging_Type=SIMP(statut= 'o',typ= 'TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'),),

            Constituants = FACT ( statut = 'o',
               ConstituantPOOH = SIMP (statut = 'f', typ = 'TXM', into = ('POOH',), defaut= 'POOH'),
               b_pooh =  BLOC(condition = " ConstituantPOOH == 'POOH'" ,
                  Differential_Equation_POOH =  SIMP(statut= 'o',typ= 'TXM', defaut = '-ku1*POOH'),
               ), # Fin b_pooh
               ConstituantP = SIMP (statut = 'f', typ = 'TXM', into = ('P',),defaut='P'),
               b_p =  BLOC(condition = " ConstituantP == 'P'" ,
                 Differential_Equation_P =  SIMP(statut= 'o',typ= 'TXM', defaut = '2*ku1*POOH'),
               ), # Fin b_p
            OptionnelConstituant =  FACT ( statut = 'f',max = '**',
                Constituant = SIMP (statut = 'o', typ = 'TXM'),
                Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),
               ), # fin Const_Equa
            ),# Fin Constituants

            Constante = FACT ( statut = 'o',
               Constanteku1 = SIMP (statut = 'f', typ = 'TXM', into = ('ku1',), defaut= 'ku1'),
               b_cku1 =  BLOC(condition = "Constanteku1 == 'ku1'" ,
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),
               OptionnelleConstante  = FACT (statut = 'f', max = '**',
                  ConstanteName= SIMP (statut = 'o', typ = 'TXM',),
                  ConstanteType =  SIMP(statut= 'o',typ= 'TXM', min=1,into=('Arrhenius type','non Arrhenius type'),defaut='Arrhenius type'),
                  ),# fin ConstanteOptionnelle
            ), # fin constante
            Commentaire =  SIMP (statut = 'f', typ = 'TXM', defaut = ' '),

         ), # Fin Equation_Modification

                 #Chemical_Formulation =  SIMP(statut= 'o',typ= 'TXM', defaut = 'POOH->P',siValide=maFuncWithArg),
                 #Type1 = SIMP(statut='o', typ = 'TXM', into=maFunc),
                 #Type2 = SIMP(statut='o', typ = 'TXM'),

        ),  # fin b_type_creation


) # Fin Equation

#---------------------------------
Modele = PROC (nom="Modele",
      op=None,
      Modele_DB=SIMP(statut= 'o',typ= 'TXM', into=("Approved data base", "My data base"),siValide=recupereDicoModele ),
      Modele_Type = SIMP(statut= 'o',typ= 'TXM', into=("Show modele database", "Modele creation"),siValide=creeListeEquation),
#     ---------------------------------------------------------------------------
      b_type_creation = BLOC(condition = " Modele_Type == 'Modele creation'",
#         ---------------------------------------------------------------------------
        technicalUse= SIMP(statut= 'o',typ= 'TXM',into=monDico['Modele_TechnicalUse'],defaut=maClasseDeModele.technical_use ),
        modeleName=SIMP(statut='o',typ='TXM',defaut=maClasseDeModele.nom,),
        material=SIMP(statut='o',typ='TXM',defaut=maClasseDeModele.materiaux[0],),
        stabilizer = SIMP(typ = bool, statut = 'o',defaut = maClasseDeModele.stabilise),
        model_developed_by_for_EDF = SIMP(typ = bool, statut = 'o',defaut = maClasseDeModele.dvt_EDF[0]),
        documentation=SIMP(statut='o',typ='TXM',defaut=maClasseDeModele.reference,),

       # ajouter la liste des equations et le remove (il faut garder ceux qu on a enlever)


       AjoutEquation=SIMP(statut= 'o',typ= bool, defaut=False, siValide=recupereModeleEquation),
       b_ajout_equation = BLOC(condition = " AjoutEquation == True",
          listeEquation_initiation=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[] ),
          listeEquation_propagation=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[] ),
          listeEquation_termination=SIMP(statut='o', typ='TXM',homo='SansOrdreNiDoublon', max='**', min=0, defaut=[] ),
          listeEquation_stabilization=SIMP(statut='o',typ='TXM', homo='SansOrdreNiDoublon', max='**', min=0, defaut=[] ),
       ),# fin b_ajout_equation

        # coefficients maClasseDeModele.coef = liste de dictionnaire mais il faut prendre que le 0
        # on enleve ceux qui commence par D, S et B(casse imprtante)
        # la clef est le coef, puis les valeurs

        Aging_Type=SIMP(statut= 'o',typ='TXM', min=1,max='**', homo='SansOrdreNiDoublon', into=('All', 'thermo', 'radio'), defaut=maClasseDeModele.type_vieil),
        Diffusion = SIMP(typ = bool, statut = 'o',defaut = maClasseDeModele.diffusion,siValide = prepareDiffusion),

        b_diffusion = BLOC(condition = " Diffusion == True",
         #coefficients maClasseDeModele.coef = liste de dictionnaire mais il faut prendre que le 0
        # on met ceux qui commence par D, S et pas les B ni les aitres( casse imprtante)
           listeProduitPourLaDiffusion=SIMP(statut='o', typ='TXM', max='**', min=1,homo='SansOrdreNiDoublon', into = maClasseDeModele.param_ini.keys(),siValide=ajouteDiffusion),
       ),  # fin b_diffusion

       ),  # fin b_type_creation


       #AjoutEquation=Fact(statut='f',
       #     Reaction_Type=SIMP(statut= 'o',typ= 'TXM', min=1,into=monDico['Equation_Liste'],siValide=recupereModeleEquation),
       #), # fin AjoutEquation

      Commentaire =  SIMP (statut = 'f', typ = 'TXM'),
) # Fin Modele
