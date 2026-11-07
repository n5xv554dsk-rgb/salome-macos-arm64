# coding: utf-8

import types
import sys,os

import listesDB


maClasseDelistesDB = listesDB.classeListesDB()
monModele=listesDB.sModele().monModele
monPost=listesDB.sModele().monPost

import types
class Tuple:
    def __init__(self,ntuple):
        self.ntuple=ntuple

    def __convert__(self,valeur):
        if type(valeur) == types.StringType:
            return None
        if len(valeur) != self.ntuple:
            return None
        return valeur

    def info(self):
        return "Tuple de %s elements" % self.ntuple

    __repr__=info
    __str__=info


dicoAgingFactor={ '40years BR top' : {'temperature' : 50, 'simulationTime' : 350640}}

# --------------------------------------
# Fonctions appellees depuis le catalogue
# --------------------------------------

# --------------------------------------
# Dans Equation
# --------------------------------------

def recupereDicoEquation(monMC):
        # Equation_reaction (ds 2 blocs)
        #  ou dans Equation b_type_show b_reaction_type
        #  ou dans Equation b_type_show b_aging_type

    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    monMC.dsMaFunct = True

    valeurDB=editor.getValeur('Equation','Equation_DB',())
    maClasseDelistesDB.metAJour(valeurDB)
    listEquation=maClasseDelistesDB.getListEquation()

    valeurEquationListe=editor.getValeur('Equation','Equation_Liste',('b_type_show',))
    valeurAgingType=editor.getValeur('Equation','Equation_reaction',('b_type_show','b_reaction_type',))
    if valeurAgingType == None :
        valeurAgingType=editor.getValeur('Equation','Equation_reaction',('b_type_show','b_aging_type',))
    if valeurAgingType == None : monMC.dsMaFunct = False; return

    listeEquationPourIhm = []
    listeReprEquationPourIhm = []
    dicoListAffiche = {}

    for equation in listEquation :
        if valeurEquationListe == 'aging_type' :
            if equation.type_vieil == valeurAgingType :
                listeEquationPourIhm.append(equation)
                listeReprEquationPourIhm.append(equation.representation)
                dicoListAffiche[equation.representation]=equation
        else:
            if equation.type_react == valeurAgingType :
                listeEquationPourIhm.append(equation)
                listeReprEquationPourIhm.append(equation.representation)
                dicoListAffiche[equation.representation]=equation
    maClasseDelistesDB.dicoListAffiche = dicoListAffiche

    change=editor.changeIntoDefMC('Equation', ('b_type_show','ListeEquation'), listeReprEquationPourIhm )
    if change :
        editor.reCalculeValiditeMCApresChgtInto('Equation', 'listeEquation', ('b_type_show',))
        if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    monMC.dsMaFunct = False

def afficheValeurEquation(monMC):
    # Equation b_modification modification
    print (monMC)
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    valeur=monMC.valeur
    if valeur == None : return
    maClasseDelistesDB.valeurEquationChoisie=str(valeur)
    monEquation=maClasseDelistesDB.dicoListAffiche[str(valeur)]

    aAfficher=str(monEquation)
    editor=monMC.jdc.editor
    editor._viewText(aAfficher, "Id",largeur=80,hauteur=300)

    monMC.dsMaFunct = False


def instancieChemicalFormulation(monMC):
    print ('instancieChemicalFormulation pour ', monMC.nom)
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur == False : return

    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True

    for e in monMC.jdc.etapes:
        if e.nom == 'Equation' :break
    print ('ds instancie')
    v=maClasseDelistesDB.valeurEquationChoisie
    monEquation=maClasseDelistesDB.dicoListAffiche[v]
    type_react=monEquation.type_react
    type_vieil=monEquation.type_vieil

    editor.changeIntoMCandSet('Equation', ('b_type_show','b_modification','b_modif','ChemicalFormulation'),( v,),v )
    print ("je passe la")
    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Reaction_Type'),type_react )
    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Aging_Type'), type_vieil )

    for index,valeurConstituant in enumerate(monEquation.constituants):
        valeurEquation=monEquation.equation[index]

        #PNPNPN --> decider des noms SVP ave un nom python
        monMcl1=('Constituant','TXM',{'statut':'o','defaut':valeurConstituant})
        monMcl2=('Differential_Equation','TXM',{'statut':'o','defaut':valeurEquation})
        listeMC=(monMcl1,monMcl2)
        editor.ajoutDefinitionMCFact ('Equation',('b_type_show','b_modification','b_modif',),valeurConstituant,listeMC,statut='f')
        #editor.ajoutMCFact (e,('b_type_show','b_modification','b_modif',),valeurConstituant)
        print (index,valeurConstituant,valeurEquation)

            #OptionnelConstituant =  FACT ( statut = 'f',max = '**',
            #    Constituant = SIMP (statut = 'o', typ = 'TXM'),
            #    Differential_Equation =  SIMP(statut= 'o',typ= 'TXM'),

    for index,valeurConstituant in enumerate(monEquation.const_cine_nom):
        valeurArrhe=monEquation.arrhenius[index]
        if valeurArrhe : valeurConstanteType='Arrhenius type'
        else           : valeurConstanteType='non Arrhenius type'
        monMcl1=('ConstanteName','TXM',{'statut':'o','defaut':valeurConstituant})
        monMcl2=('ConstanteType','TXM',{'statut':'o','defaut':valeurConstanteType,'into': ('Arrhenius type','non Arrhenius type') })
        listeMC=(monMcl1,monMcl2)
        editor.ajoutDefinitionMCFact ('Equation',('b_type_show','b_modification','b_modif',),valeurConstituant,listeMC,statut='f')
        #editor.ajoutMC(e,MCFils,mesValeurs,('b_type_creation','b_diffusion',))


    change=editor.changeDefautDefMC('Equation', ('b_type_show','b_modification','b_modif','Commentaire'),monEquation.comment )
    print (monEquation.comment )
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()

    monMC.dsMaFunct = False
    editor.dsMaFunct = False




def recupereDicoModele(monMC):
    if monMC.valeur == None: return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct = True
    print ('je passe dans recupereDicoModele')

    editor=monMC.jdc.editor
    valeurDB=editor.getValeur('Modele','Modele_DB',())
    maClasseDelistesDB.metAJour(valeurDB)

    print ('fin recupereDicoModele')
    monMC.dsMaFunct = False


def creeListeEquation(monMC):
    if monMC.valeur == None: return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True
    print ('debut de creeListeEquation')

    listeEquationsAAfficher=[]
    listeConstantesAAfficher=[]
    listeInitialEquations=[]

    listEquation=maClasseDelistesDB.getListEquation()
    for index,equation in enumerate( listEquation):
        if index in monModele.equa:
            listeEquationsAAfficher.append(equation.representation)
            listeConstantesAAfficher.append(equation.const_cine_nom)
            t=equation.representation+'\t\t\t\t    '+str(equation.const_cine_nom)
            listeInitialEquations.append(t)

    change=editor.changeIntoDefMC('Modele', ('b_type_creation','Chemical_Equation','Initial_Equation_List'),listeInitialEquations )
    maClasseDelistesDB.listeEquationsAAfficher = listeEquationsAAfficher
    maClasseDelistesDB.listeConstantesAAfficher = listeConstantesAAfficher
    monMC.dsMaFunct = False
    print ('fin de creeListeEquation')

    editor.dsMaFunct = False

    #        listeEquation_stabilization=SIMP(statut='o', homo='SansOrdreNiDoublon', max='**', min=0 ),

def recupereModeleEquation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur==False : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True
    print ('je suis dans  recupereModeleEquation')

    editor.dsMaFunct = True
    dicoListeEquationAAfficher={}

    from VP_Cata_V2 import monDico
    listEquation=maClasseDelistesDB.getListEquation()
    for valeurReactionType in monDico['Equation_Liste']:
        dicoListeEquationAAfficher[valeurReactionType] = []
        for index,equation in enumerate( listEquation):
            if equation.type_react==valeurReactionType :
                dicoListeEquationAAfficher[valeurReactionType].append(equation.representation)
                maClasseDelistesDB.dictParametresInitiaux[equation.representation]=equation
    #print (dicoListeEquationAAfficher)
    #print('maClasseDelistesDB.dictParametresInitiaux', maClasseDelistesDB.dictParametresInitiaux)
    prepareDiffusionSansMC(editor,monMC.nom)

    change=editor.changeIntoDefMC('Modele', ('b_type_creation','Chemical_Equation','b_ajout_equation','listeEquation_initiation'),dicoListeEquationAAfficher['initiation'])
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','Chemical_Equation','b_ajout_equation','listeEquation_propagation'),dicoListeEquationAAfficher['propagation'] )
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','Chemical_Equation','b_ajout_equation','listeEquation_termination'),dicoListeEquationAAfficher['termination'] )
    change=editor.changeIntoDefMC('Modele', ('b_type_creation','Chemical_Equation','b_ajout_equation','listeEquation_stabilization'),dicoListeEquationAAfficher['stabilization'] )
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()

    print ('fin recupereModeleEquation')
    monMC.dsMaFunct = False
    editor.dsMaFunct = False

def ajoutDUneEquation(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur==False : return
    editor=monMC.jdc.editor
    prepareDiffusionSansMC(editor,monMC.nom)
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = False
    monMC.dsMaFunct = False

def prepareDiffusion(monMC):
    if monMC.valeur==False : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct=True
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    editor.dsMaFunct = True
    print ('je suis dans prepareDiffusion', monMC.nom)
    prepareDiffusionSansMC(editor,monMC.nom)
    print ('fin de prepareDiffusion', monMC.nom)
    monMC.dsMaFunct=False
    editor.dsMaFunct = False

def prepareDiffusionSansMC(editor,monMCNom):
    lInitialBadCoche=editor.getValeur('Modele', 'Initial_Equation_List',('b_type_creation','Chemical_Equation'),)
    lInitialCoche=[]
    for equ in lInitialBadCoche: lInitialCoche.append(equ.split('\t')[0])
    lInititiationCoche=editor.getValeur('Modele','listeEquation_initiation', ('b_type_creation','Chemical_Equation',))
    lPropagationCoche =editor.getValeur('Modele', 'listeEquation_propagation',('b_type_creation','Chemical_Equation',))
    lTerminationCoche=editor.getValeur('Modele','listeEquation_termination', ('b_type_creation','Chemical_Equation',))
    lStabilizationCoche=editor.getValeur('Modele','listeEquation_stabilization', ('b_type_creation','Chemical_Equation',))

    print (lInitialCoche,lInititiationCoche,lPropagationCoche,lTerminationCoche,lStabilizationCoche)
    for liste in (lInitialCoche,lInititiationCoche,lPropagationCoche,lTerminationCoche,lStabilizationCoche):
            # Il est possible qu'une liste soit vide lors de l initialisation
        if liste == None : continue
        for equation in liste :
            print (equation)
            for const in maClasseDelistesDB.dictParametresInitiaux[equation].constituants :
                if const not in maClasseDelistesDB.listeParametresInitiaux : maClasseDelistesDB.listeParametresInitiaux.append(const)
            #for coef in maClasseDelistesDB.dictParametresInitiaux[equation].const_cine_nom :
            #  if coef not in maClasseDelistesDB.listeCoefInitiaux : maClasseDelistesDB.listeCoefInitiaux.append(coef)
            for num,coef in enumerate(maClasseDelistesDB.dictParametresInitiaux[equation].const_cine_nom ):
                maClasseDelistesDB.dicoCoefAffichageArr[coef]=maClasseDelistesDB.dictParametresInitiaux[equation].arrhenius[num]
                if coef not in maClasseDelistesDB.listeCoefInitiaux : maClasseDelistesDB.listeCoefInitiaux.append(coef)

    #print('maClasseDelistesDB.dictParametresInitiaux', maClasseDelistesDB.dictParametresInitiaux)
    if monMCNom == 'Diffusion' :
        change=editor.changeIntoDefMC('Modele', ('b_type_creation','Transport','b_diffusion','listeProduitPourLaDiffusion'), maClasseDelistesDB.listeParametresInitiaux )
    if monMCNom == 'Evaporation' :
        change=editor.changeIntoDefMC('Modele', ('b_type_creation','Transport','b_evaporation','listeProduitPourLEvaporation'), maClasseDelistesDB.listeParametresInitiaux )

    if monMCNom in ('Evaporation','Diffusion') :
        for c in list(monModele.coef[0].keys()) :
            if c[0]=='D':
                clef=c[1:]
                if clef in maClasseDelistesDB.listeParametresInitiaux :
                    maClasseDelistesDB.listeCoefD.append(clef)
                    maClasseDelistesDB.listeCoefInitiaux.append('D'+clef)
                    maClasseDelistesDB.listeCoefInitiaux.append('S'+clef)
                else :
                    maClasseDelistesDB.listeCoefASupprimer.append('S'+clef)
                    maClasseDelistesDB.listeCoefASupprimer.append('D'+clef)
            if c[0]=='B':
                clef=c[1:]
                if clef in maClasseDelistesDB.listeParametresInitiaux :
                    maClasseDelistesDB.listeCoefB.append(clef)
                    maClasseDelistesDB.listeCoefInitiaux.append(c)
                else :
                    maClasseDelistesDB.listeCoefASupprimer.append(c)
    print ('aClasseDelistesDB.listeCoefB',maClasseDelistesDB.listeCoefB)
    print ('aClasseDelistesDB.listeCoefB',maClasseDelistesDB.listeCoefD)
    print ('maClasseDelistesDB.listeCoefInitiaux',maClasseDelistesDB.listeCoefInitiaux)
    print ('maClasseDelistesDB.listeCoefASupprimer',maClasseDelistesDB.listeCoefASupprimer)
    print ('maClasseDelistesDB.listeParametresInitiaux',maClasseDelistesDB.listeParametresInitiaux)
    # au lieu des print il faut mettre a jour le MC Fact Coefficients avec ,maClasseDelistesDB.listeCoefInitiaux et le MC FACT
    # Paraetres_initiaux avec maClasseDelistesDB.listeParametresInitiaux
    # TO DO TO DO PNPN
    # si on arrive avex
    # if monMC.nom = Diffusion
    if monMCNom == 'Diffusion' :
        editor.setValeur('Modele','listeProduitPourLaDiffusion' ,maClasseDelistesDB.listeCoefD, ('b_type_creation','Transport','b_diffusion',))
    #editor.changeValeur(....,'listeProduitPourLaDiffusion',maClasseDelistesDB.listeCoefD')
    # if monMCNom == 'Evaporation' :
    #editor.changeValeur(....,'listeProduitPourLaDiffusion',maClasseDelistesDB.listeCoefB')



def ajouteEvaporation(monMC):
    print ('je suis dans ajouteDiffusion')
    if monMC.valeur == None : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return

    monMC.dsMaFunct=True
    for v in monMC.valeur :
        clef='B'+v
        if clef not in maClasseDelistesDB.listeCoefInitiaux :
            maClasseDelistesDB.listeCoefInitiaux.append(clef)

    print ('sortie de ajouteDiffusion' , maClasseDelistesDB.listeCoefInitiaux)
    monMC.dsMaFunct=False
    editor.dsMaFunct = False

def ajouteDiffusion(monMC):
    print ('je suis dans ajouteDiffusion')
    if monMC.valeur == None : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return

    monMC.dsMaFunct=True
    for v in monMC.valeur :
        clef='D'+v
        if clef not in maClasseDelistesDB.listeCoefInitiaux :
            maClasseDelistesDB.listeCoefInitiaux.append(clef)
            maClasseDelistesDB.listeCoefInitiaux.append('S'+v)
            maClasseDelistesDB.dicoCoefAffichageArr[clef] = True
            maClasseDelistesDB.dicoCoefAffichageArr['S'+v] = False
            #maClasseDelistesDB.dicoCoefAffichageArr['B'+v] = True

        # on affiche dans l interface  un mot clef avec clef comme nom et
        # 2 reels si ce commence par D soit iniitialise a 0 si pas de valeur
        # soit avec comme deifaut nomCoef in monModele.coef[0].keys()
    print ('sortie de ajouteDiffusion' , maClasseDelistesDB.listeCoefInitiaux)

    for nomCoef in maClasseDelistesDB.listeCoefInitiaux:
        #A jout Ds Coef d'un MC
        nomMC='Coef_'+nomCoef
        if maClasseDelistesDB.dicoCoefAffichageArr[nomCoef]  == True:
            print ('2 r'),
            if nomCoef in monModele.coef[0].keys() :
                print (monModele.coef[0][nomCoef])
            else :
                print ((0,0))
        else :
            print ('1 r')
            if nomCoef in monModele.coef[0].keys() :
                print (monModele.coef[0][nomCoef])
            else :
                print (0)

    print ('______________________')
    #for v in monMC.valeur :
    #    print (v)
    #    mesValeurs=editor.dicoCoefS[v]
    #    MCFils='S'+v
    #    for e in monMC.jdc.etapes:
    #        if e.nom == 'Modele' :break
    #    editor.ajoutDefinitionMC(e,('b_type_creation','b_diffusion'),MCFils,typ='TXM',statut='o' )
    #    editor.ajoutMC(e,MCFils,mesValeurs,('b_type_creation','b_diffusion',))
    #    print ('______')
    #if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    monMC.dsMaFunct=False
    editor.dsMaFunct = False


# --------------------------------------------------------------------------------------------
# pour les modeles en modification ou en utilisation
# --------------------------------------------------------------------------------------------
def creeListeMateriauxSelonModele(monMC):
    if monMC.valeur == None : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return

    valeurDB=editor.getValeur('Modele','Modele_DB',())
    maClasseDelistesDB.metAJour(valeurDB)
    listModele=maClasseDelistesDB.getListModele()
    listModeleFiltre=[]
    listMateriauxFiltre=[]
    for modele in listModele :
        if modele.technical_use == monMC.valeur :
            maClasseDelistesDB.dicoModeleFiltre[modele.nom]=modele
            listModeleFiltre.append(modele.nom)
            if type(modele.materiaux) not in (list, tuple): modeleATraiter= modele.materiaux
            else : modeleATraiter= modele.materiaux[0]
            if modeleATraiter not in listMateriauxFiltre :
                listMateriauxFiltre.append(modeleATraiter)
                maClasseDelistesDB.dicoMateriauxFiltre[modeleATraiter]=[modele.nom,]
            else :
                maClasseDelistesDB.dicoMateriauxFiltre[modeleATraiter].append(modele.nom)



    change=editor.changeIntoDefMC('Modele', ('b_type_modification','b_technicalUse','material'),listMateriauxFiltre )

    monMC.dsMaFunct=False
    editor.dsMaFunct = False

def creeListeModelesPossibles(monMC):
    if monMC.valeur == None : return
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    editor=monMC.jdc.editor
    if hasattr(editor,'dsMaFunct') and editor.dsMaFunct== True : return
    change=editor.changeIntoDefMC('Modele', ('b_type_modification','b_technicalUse','modele'),maClasseDelistesDB.dicoMateriauxFiltre[monMC.valeur] )

    monMC.dsMaFunct=False
    editor.dsMaFunct = False

def choisitModele(monMC):
    # Equation b_modification modification
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    valeur=monMC.valeur
    if valeur == None : return
    modele=maClasseDelistesDB.dicoModeleFiltre[monMC.valeur]
    maClasseDelistesDB.monModele=modele
    monMC.dsMaFunct = False

def choisitActionModele(monMC):
    if monMC.valeur == 'display' : afficheModele(monMC)
    if monMC.valeur == 'modify' : changeValeurDefautModele(monMC)

def afficheModele(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    valeur=monMC.valeur
    aAfficher=str(maClasseDelistesDB.monModele)
    editor=monMC.jdc.editor
    editor._viewText(aAfficher, "Id",largeur=700,hauteur=500)

    monMC.dsMaFunct = False

def changeValeurDefautModele(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    monMC.dsMaFunct = True
    editor=monMC.jdc.editor
    change=editor.changeIntoMCandSet('Modele', ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID','modeleName'),(maClasseDelistesDB.monModele.nom,),maClasseDelistesDB.monModele.nom, )
    editor.setValeur('Modele','technicalUse',maClasseDelistesDB.monModele.technical_use, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))

    editor.setValeur('Modele','material',maClasseDelistesDB.monModele.materiaux, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))
    editor.setValeur('Modele','agingType',maClasseDelistesDB.monModele.type_vieil, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))

    if maClasseDelistesDB.monModele.stabilise == 'True' : monBool = True
    else : monBool = False
    editor.setValeur('Modele','stabilizer',monBool, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))
    editor.setValeur('Modele','material_thickness',maClasseDelistesDB.monModele.thickness, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))

    if maClasseDelistesDB.monModele.dvt_EDF == 'True' : monBool = True
    else : monBool = False
    editor.setValeur('Modele','model_developed_by_for_EDF',monBool, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))
    editor.setValeur('Modele','documentation',maClasseDelistesDB.monModele.reference, ('b_type_modification','b_technicalUse','b_modele','b_type_modify','ID'))
    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()
    monMC.dsMaFunct = False



def creeCoefAModifier(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur == None : return
    monMC.dsMaFunct = True
    editor=monMC.jdc.editor
    dicoArr={}
    dicoNonArr={}
    for coef in maClasseDelistesDB.monModele.coef[0] :
        if len (maClasseDelistesDB.monModele.coef[0][coef]) == 1 :
            dicoNonArr[coef]=maClasseDelistesDB.monModele.coef[0][coef][0]
        else :
            dicoArr[coef]=maClasseDelistesDB.monModele.coef[0][coef]
            if coef[0] == 'D' : maClasseDelistesDB.listeDiffusion.append(coef[1:])
    print (dicoNonArr)
    print (dicoArr)
    if 'ri' in dicoNonArr :
        print ('ajoutDefinitionMC debitOfDose')
        editor.ajoutDefinitionMC('Modele', ('b_type_modification','b_technicalUse','b_modele','b_type_use2','Aging_Factor'), 'debitOfDose',typ='R',statut='o' )

    for coef in dicoNonArr :
        print (coef)
        # attention, notation scientifique
        editor.ajoutDefinitionMC('Modele',('b_type_modification','b_technicalUse','b_modele','b_type_use',),coef, 'R', statut='o',defaut=dicoNonArr[coef])
        # a faire marcher
        # pour les Arr il faut un tuple(2)

    # il fait creer un fact Boundary_Conditions_Param pour chacque espece de listeDiffusion

    if editor.fenetreCentraleAffichee : editor.fenetreCentraleAffichee.node.affichePanneau()

    monMC.dsMaFunct = False


def remplirAgingFactor(monMC):
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur == None : return
    monMC.dsMaFunct = True
    editor=monMC.jdc.editor
    if monMC.valeur in dicoAgingFactor:
        print (monMC.valeur, 'trouve')
        for MC in dicoAgingFactor[monMC.valeur]:
            print (MC)
            print (dicoAgingFactor[monMC.valeur][MC]),
            editor.setValeur('Modele',MC,dicoAgingFactor[monMC.valeur][MC],('b_type_modification','b_technicalUse','b_modele','b_type_use2','Aging_Factor'))
    monMC.dsMaFunct = False


def creeInitialParameter(monMC):
    print ('je passe dans creeInitialParameter')
    if hasattr(monMC,'dsMaFunct') and monMC.dsMaFunct== True : return
    if monMC.valeur == None : return
    monMC.dsMaFunct = True
    editor=monMC.jdc.editor
    for coef in maClasseDelistesDB.monModele.param_ini:
        editor.ajoutDefinitionMC('Modele',('b_type_modification','b_technicalUse','b_modele','b_type_use2','Initial_Parameter'),coef, 'R', statut='o',defaut=maClasseDelistesDB.monModele.param_ini[coef][0])
    monMC.dsMaFunct = False
    # creer nbdenode = monMC.valeur Initial_Parameter
