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

# --------------------------------------------------
# debut entete
# --------------------------------------------------

#from Accas import ASSD, JDC_CATA, AU_MOINS_UN, PROC, SIMP, FACT, OPER, MACRO, BLOC, A_VALIDATOR
from Accas import *
import opsPSEN_N1
import pn
#
#class loi      ( ASSD ) : pass
#class variable ( ASSD ) : pass
class sd_charge     ( ASSD ) : pass
class sd_generateur ( ASSD ) : pass
class sd_ligne     ( ASSD ) : pass
class sd_transfo ( ASSD ) : pass
class sd_moteur ( ASSD ) : pass
#

# import types
class Tuple:
   def __init__(self,ntuple):
     self.ntuple=ntuple

   def __convert__(self,valeur):
     import types
     if type(valeur) == types.StringType:
       return None
     if len(valeur) != self.ntuple:
       return None
     return valeur

   def info(self):
     return "Tuple de %s elements" % self.ntuple

   __repr__=info
   __str__=info

# class Matrice:
#   def __init__(self,nbLigs=None,nbCols=None,methodeCalculTaille=None,formatSortie="ligne",valSup=None,valMin=None,structure=None):
#       self.nbLigs=nbLigs
#       self.nbCols=nbCols
#       self.methodeCalculTaille=methodeCalculTaille
#       self.formatSortie=formatSortie
#       self.valSup=valSup
#       self.valMin=valMin
#       self.structure=structure
#
#   def __convert__(self,valeur):
#     # Attention ne verifie pas grand chose
#     if type(valeur) != types.ListType :
#       return None
#     return valeur
#
#   def info(self):
#       return "Matrice %s x %s" % (self.nbLigs, self.nbCols)
#
#       __repr__=info
#       __str__=info


#CONTEXT.debug = 1
JdC = JDC_CATA ( code = 'PSEN',
                 execmodul = None,
                 regles = ( AU_MOINS_UN ( 'CASE_SELECTION', 'CONTINGENCY_PROCESSING' ),
                            AU_MOINS_UN ( 'CONTINGENCY_SELECTION','P_PROCESSING_OPTIONS','CONTINGENCY_PROCESSING' ),
                            PRESENT_PRESENT ( 'CONTINGENCY_SELECTION','CONTINGENCY_OPTIONS' ),
                            PRESENT_PRESENT ( 'CONTINGENCY_PROCESSING','CONTINGENCY_OPTIONS' ),
                             AU_MOINS_UN ( 'SIMULATION' ),
                            # AU_PLUS_UN ( 'PSSE_PARAMETERS' ),
                            AU_PLUS_UN ( 'CASE_SELECTION' ),
                            AU_PLUS_UN ( 'CONTINGENCY_OPTIONS' ),
                            AU_PLUS_UN ( 'CONTINGENCY_SELECTION' ),
                            AU_PLUS_UN ( 'CONTINGENCY_PROCESSING' ),
                            AU_PLUS_UN ( 'P_PROCESSING_OPTIONS' ),
                            # AU_PLUS_UN ( 'N_1_LINES' ),
                            # AU_PLUS_UN ( 'N_1_LOADS' ),
                            # AU_PLUS_UN ( 'N_1_TRANSFORMERS' ),

                            ),
                 ) # Fin JDC_CATA

MODIFICATION_CATALOGUE = MACRO ( nom = "MODIFICATION_CATALOGUE",
                     sd_prod = pn.modification_catalogue,
                     op_init=  pn.modification_catalogue2,
                     op=None,
                     UIinfo={"groupes":("CACHE")},
                     Fonction=SIMP(statut='o', typ='TXM', into=['ajoutDefinitionMC']),
                     Etape=SIMP(statut='o', typ='TXM',),
                     Genea=SIMP(statut='o', typ='TXM', min=0, max='**'),
                     NomSIMP=SIMP(statut='o', typ='TXM',),
                     TypeSIMP=SIMP(statut='o', typ='TXM',),
                     PhraseArguments=SIMP(statut='o', typ='TXM',),)


# --------------------------------------------------
# fin entete
# --------------------------------------------------
## TODO : RUN
CASE_SELECTION = MACRO ( nom = "CASE_SELECTION",
                      sd_prod = opsPSEN_N1.INCLUDE,
                      op_init = opsPSEN_N1.INCLUDE_context,
                      fichier_ini = 1,
                      op = None,
                      fr = "Selectionnez les cas a analyser",
                      ang = 'Select the cases to analyze',
                      PSSE_path = SIMP(statut="o",typ='Repertoire',defaut='C:\Program Files (x86)\PTI\PSSE33\PSSBIN'),
                      output_folder = SIMP(statut="o", typ="Repertoire"),


                      BusesList = SIMP(statut = 'f', typ = 'R', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                      LinesList = SIMP(statut = 'f', typ = 'R', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                      TransformersList = SIMP(statut = 'f', typ = 'TXM', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                      MaxDepth = SIMP(statut = 'o', typ = 'I', defaut = 5),
                      OutputNewCsv = SIMP ( statut = "o",typ=bool,defaut=False,),
                 )
P_PROCESSING_OPTIONS = PROC ( nom = 'P_PROCESSING_OPTIONS',
                            op = None,
                            ang = "Select whether the program should be displaying data about the different categories.\nThe values displayed will be the min, max, and mean of each item, plus a chart.",
                           Output_bus_values = SIMP(statut = 'o', typ = bool, defaut = True),
                           Output_lines_values = SIMP(statut = 'o', typ = bool, defaut = True),
                           Output_transformer_values = SIMP(statut = 'o', typ = bool, defaut = True),
                           Threshold_selection_for_the_treated_cases = FACT(
                              statut = 'f',
                              Branches = SIMP(statut="o",typ=Tuple(3),defaut=(0,0,0),validators=VerifTypeTuple(('R','R','R'),),),
                              Transformers = SIMP(statut="o",typ=Tuple(3),defaut=(0,0,0),validators=VerifTypeTuple(('R','R','R'),),),
                              High_voltage = SIMP(statut="o",typ=Tuple(3),defaut=(0,0,0),validators=VerifTypeTuple(('R','R','R'),),),
                              Low_voltage = SIMP(statut="o",typ=Tuple(3),defaut=(0,0,0),validators=VerifTypeTuple(('R','R','R'),),),
                           ),
                           )


CONTINGENCY_OPTIONS = PROC (nom = 'CONTINGENCY_OPTIONS',
                            op = None,

                            GeneralOptions = FACT(statut='o',
                                Vmin = SIMP(statut = 'o', typ = 'R', defaut = 0.9, val_min = 0),
                                Vmax = SIMP(statut = 'o', typ = 'R', defaut = 1.1, val_min = 0),
                                ContingencyRate = SIMP(statut = 'o', typ = 'TXM', defaut = 'a', into=['a', 'b']),
                                FlowLimitLines = SIMP(statut = 'o', typ = 'I', defaut = 120, val_min = 0),
                                FlowLimitTransformers = SIMP(statut = 'o', typ = 'I', defaut = 120, val_min = 0),
                                Tolerance = SIMP(statut = 'o', typ = 'R', defaut = 0.5, val_min = 0),
                                TripLines = SIMP(statut = 'o', typ = bool, defaut = True),
                                TripTransfos = SIMP(statut = 'o', typ = bool, defaut = True),
                                TripGenerators = SIMP(statut = 'o', typ = bool, defaut = True),
                                TripBuses = SIMP(statut = 'o', typ = bool, defaut = False),
                                ),

                            LoadFlowOptions = FACT(statut='o',
                                AdjustTaps = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Lock', '1 - Stepping', '2 - Direct'], defaut = '1 - Stepping'),
                                AdjustDCtaps = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Enable'], defaut = '1 - Enable'),
                                SolutionMethod = SIMP(statut = 'o', typ = 'TXM', into = ['0 - FDNS', '1 - FNSL', '2 - Optimized FDNS'], defaut = '1 - FNSL'),
                                AdjustSwitchedShunts = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Enable', '2 - Enable continuous mode'], defaut = '1 - Enable'),
                                DispatchMode = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Reserve', '2 - Pmax', '3 - Inertia', '4 - Droop'], defaut = '1 - Reserve'),
                                FlatStart = SIMP(statut = 'o', typ = bool, defaut = False),
                                VarLimits = SIMP(statut = 'o', typ = 'I', defaut = 99,ang = 'if set to -1, var limits will not be applied'),
                                ),

#                            OutputOptions = FACT(statut='o',
#                                consigne1 = SIMP(statut='o',homo='information',typ = "TXM",defaut = 'Output PSSE multiple contingency report to Shell?'),
#                                MultipleContingencyReport = SIMP(statut = 'o', typ = bool, defaut = True, ang = 'Output PSSE multiple contingency report to Shell?'),
#                                consigne2 = SIMP(statut='o',homo='information',typ = "TXM",defaut = 'Write an Excel file for the results of each case file?'),
#                                WriteIndivExcels = SIMP(statut = 'o', typ = bool, defaut = True),
#                                consigne3 = SIMP(statut='o',homo='information',typ = "TXM",defaut = 'Add a tab in Excel results file for the differences between the max flow rate (MVAR) and the actual flow rate in lines and transformers?'),
#                                WriteFlowDifs = SIMP(statut = 'o', typ = bool, defaut = True),
#                            ),
                        )




CONTINGENCY_SELECTION = PROC(nom='CONTINGENCY_SELECTION',op = None,
                      SelectionMethod = SIMP(statut='o',typ='TXM',into=['CaseSelectionFromFile','SelectAllCases','SelectWorstCases'],
                      ),

                      b_file = BLOC(condition="SelectionMethod=='CaseSelectionFromFile'",
                      CaseSelectionFromFiles = FACT(
                           statut = 'o',
                           case = FACT(statut='o',max='**',
                                       case_name=SIMP(statut='o',typ='TXM'),
                                       csv_file= SIMP(statut='o', typ = ('Fichier', 'CSV file (*.csv);;All Files (*)',),),),
#                           regles=(AU_MOINS_UN('branch_cases','transformer_cases','high_voltage_cases','low_voltage_cases',),),
#                           branch_cases = SIMP(statut='o', defaut='', typ = ('Fichier', 'CSV file (*.csv);;All Files (*)','Sauvegarde'),),
#                           transformer_cases = SIMP(statut='o', defaut='', typ = ('Fichier', 'CSV file (*.csv);;All Files (*)','Sauvegarde',),),
#                           high_voltage_cases = SIMP(statut='o', defaut='', typ = ('Fichier', 'CSV file (*.csv);;All Files (*)','Sauvegarde'),),
#                           low_voltage_cases = SIMP(statut='o', defaut='', typ = ('Fichier', 'CSV file (*.csv);;All Files (*)','Sauvegarde'),),
                        ),

#                      CaseSelectionFromFile = FACT(
#                           statut = 'o',
#                           input_path = SIMP(statut="o",typ='Repertoire'),
#                           branch_cases = SIMP(statut='o', typ='TXM'),
#                           transformer_cases = SIMP(statut='o', typ='TXM'),
#                           high_cases = SIMP(statut='o', typ='TXM'),
#                           low_cases = SIMP(statut='o', typ='TXM'),
#                        ),

                        ),

#                      b_all = BLOC(condition="SelectionMethod=='SelectAllCases'",
#                      SelectAllCases = FACT(
#                           statut='o',
#                           all_cases = SIMP(statut='o', typ=bool, defaut = True),
#                         ),
#                         ),

                      b_worst = BLOC(condition="SelectionMethod=='SelectWorstCases'",
                      SelectWorstCases = FACT(
                          regles = (AU_MOINS_UN('AvgLineLoad', 'AvgLineLoadPercent','AvgTransformerLoad','AvgTransformerLoadPercent','AvgHighVoltage', 'AvgHighVoltagePercent','AvgLowVoltage', 'AvgLowVoltagePercent'),
                                    EXCLUS('AvgLineLoad', 'AvgLineLoadPercent'),EXCLUS('AvgTransformerLoad','AvgTransformerLoadPercent'),EXCLUS('AvgHighVoltage', 'AvgHighVoltagePercent'),EXCLUS('AvgLowVoltage', 'AvgLowVoltagePercent'),),
                          statut = 'o',
                          consigne = SIMP(statut='o',homo='information',typ = "TXM",defaut = 'Choose at least one of the potential selection criteria from the SelectWorstCases list on the right.'),
                          AvgLineLoad = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgLineLoadPercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgTransformerLoad = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgTransformerLoadPercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgHighVoltage = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgHighVoltagePercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgLowVoltage = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgLowVoltagePercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                        ),
                        ),


                      Automatic_N_2_Selection = FACT(statut='f',

                          BusesList = SIMP(statut = 'o', typ = 'R', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                          LinesList = SIMP(statut = 'o', typ = 'R', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                          TransformersList = SIMP(statut = 'o', typ = 'TXM', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
                        ),

                     MultipleContingencyList = FACT (statut='f',
                                                          max="**",
                                                          ComponentList=SIMP(statut='o', typ = 'TXM', max='**', homo = 'SansOrdreNiDoublon',),
                     ),

                      )

CONTINGENCY_PROCESSING = MACRO ( nom = 'CONTINGENCY_PROCESSING',
                        sd_prod = opsPSEN_N1.PROCESS,
                        op_init = opsPSEN_N1.PROCESS_context,

                        #sd_prod=None,

                        op = None,
                        fichier_ini = 1,
                        fr = "",
                        ang="",
                        XLS_file = SIMP(statut="o", typ = ('Fichier', 'XLS file (*.xls);;All Files (*)',),),
                        b_TabList = BLOC(condition="XLS_file != None and XLS_file != ''",
                            TabList = SIMP(statut = 'o', typ = 'TXM', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'), ),

#                        b_highVoltage = BLOC(condition="'High Voltage 0' in TabList",
#                                                     HighVoltageBuses = SIMP(statut = 'o', typ = 'TXM', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
#                                                     HighVoltageContingencies = SIMP(statut = 'o', typ = 'TXM', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),
#                                                     ),

                    )

Ordre_Des_Commandes = ('CASE_SELECTION' , 'P_PROCESSING_OPTIONS' , 'CONTINGENCY_SELECTION', 'CONTINGENCY_OPTIONS' ,'CONTINGENCY_PROCESSING',)
Classement_Commandes_Ds_Arbre = ('CASE_SELECTION' , 'P_PROCESSING_OPTIONS' , 'CONTINGENCY_SELECTION', 'CONTINGENCY_OPTIONS' ,'CONTINGENCY_PROCESSING',)
