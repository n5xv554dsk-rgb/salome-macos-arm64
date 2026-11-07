import os, sys
repInitial = os.path.dirname(os.path.abspath(__file__))
repEficas  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if os.path.dirname(repInitial) not in sys.path : sys.path.insert(0,repInitial)
if os.path.dirname(repEficas) not in sys.path  : sys.path.insert(0,repEficas)
import types

from cata_RN import *

# sert a activer les options d incertitude dans eficas
# et a changer le convert en convertUQ

def supprimeExpressionIncertitude(obj):
    if not (hasattr(obj, 'oldValue')) : 
       obj.oldValue=obj.valeur
       return
    if obj.oldValue==obj.valeur : return
    obj.oldValue=obj.valeur
    jdc=obj.getJdcRoot()
    etapesUQ=obj.jdc.getEtapesByName('ExpressionIncertitude')
    for e in etapesUQ : # a priori une seule
        jdc.suppEntite(e)

def maFonctionDeModif(cata) :
    scenario_type=cata.Scenario_data.entites['scenario_type']
    scenario_type.changeSiValide(supprimeExpressionIncertitude)

avecIncertitude=True
modifieCatalogueDeterministe=maFonctionDeModif

def scenarioEgal(valeursPossibles, obj ):
    listeEtapeScenario=obj.jdc.getEtapesByName('Scenario_data')
    if len(listeEtapeScenario) !=1 : return False
    else : etapeScenario=listeEtapeScenario[0]
    scenario_type=etapeScenario.getChildOrChildInBloc('scenario_type')
    if scenario_type.valeur == None : return False
    if scenario_type.valeur in valeursPossibles : return True
    return False

dictUQConditions = {'initial_power'  : (scenarioEgal, {'valeursPossibles':('HLO', 'RIA')}),
                    'initial_core_inlet_temperature' : (scenarioEgal, {'valeursPossibles':('RIA','HLO')}),
                    'initial_boron_concentration'    : (scenarioEgal, {'valeursPossibles':('RIA')}),
                    'initial_inlet_pressure'         : (scenarioEgal, {'valeursPossibles':('RIA')}),
                    'initial_outlet_pressure'        : (scenarioEgal, {'valeursPossibles':('RIA')}),
                    'assembly_width'                 : (scenarioEgal, {'valeursPossibles':('RIA')}),
                   }

#  Creation des lois :
#  clef : variable deterministe 
#  valeur : dico des lois possibles ou le dictionnaire contient les parametres de creation de la loi
#  il faudra eventuellement revoir ce mecanisme si on decide d affiner par scenario ces parametres
#  cela pourrait se faire soit avec des blocs lors de la creation des lois
#  ou par activation de fonctions de changement dynamique des SIMP ( comme changeIntoSelonValeurs)
dictUQ = {'initial_power'                  : ({'Uniform' : {}}, {'TruncatedNormal' : {}}, {'UserDefined' :{}}),
          'initial_core_inlet_temperature' : ({'Uniform' : {}}, {'TruncatedNormal' : {}}),
          'initial_boron_concentration'    : ({'Uniform' : {}}, {'TruncatedNormal' : {}}),
          'initial_inlet_pressure'         : ({'Uniform' : {}}, {'TruncatedNormal' : {}}),
          'initial_outlet_pressure'        : ({'Uniform' : {}}, {'TruncatedNormal' : {}}),
          'assembly_width'                 : ({'Uniform' : {}}, {'TruncatedNormal' : {}}),
          # modifier la partie Accas pour garder une reference a l objet nomme
         }

listeDesSortiesNeutro = ("Boron concentration", "Kinetic reactivity", "Neutronic power",)
listeDesSortiesThermo = ("Average mass flux", "Boiling power fraction",  "Enthalpy",  "Fuel temperature",\
                         "Liquid power", "Mass flux", "Mass fraction", "Mass title", "Mixture density", \
                         "Mixture specific enthalpy", "Mixture temperature", "Outlet pressure", "Pollutant concentration", \
                         "Pressure ", "Rowlands fuel effective temp", "Thermal power", "Water density", "Water temperature", )

scriptPosttraitement = os.path.join(repEficas,"generator","post_csv_rn.py")
scriptDeLancement    = os.path.join(repInitial,"ib_test.sh")
dicoDesSortiesPossibles  = {'Neutronics':listeDesSortiesNeutro,'Thermalhydraulics':listeDesSortiesThermo}

from cata_UQ import creeOperExpressionIncertitude
ExpressionIncertitude = creeOperExpressionIncertitude(dictUQ, dicoDesSortiesPossibles, scriptPosttraitement, scriptDeLancement)

