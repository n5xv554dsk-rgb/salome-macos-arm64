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
                 regles = ( AU_MOINS_UN ( 'CASE_SELECTION' ),
                            # AU_MOINS_UN ( 'DIRECTORY' ),
                            # AU_MOINS_UN ( 'DISTRIBUTION' ),
                            # AU_MOINS_UN ( 'SIMULATION' ),
                            # AU_PLUS_UN ( 'PSSE_PARAMETERS' ),
                            # AU_PLUS_UN ( 'DIRECTORY' ),
                            # AU_PLUS_UN ( 'SIMULATION' ),
                            # AU_PLUS_UN ( 'CORRELATION' ),
                            # AU_PLUS_UN ( 'N_1_GENERATORS' ),
                            # AU_PLUS_UN ( 'N_1_LINES' ),
                            # AU_PLUS_UN ( 'N_1_LOADS' ),
                            # AU_PLUS_UN ( 'N_1_TRANSFORMERS' ),

                            ),
                 ) # Fin JDC_CATA


# --------------------------------------------------
# fin entete
# --------------------------------------------------
## TODO : RUN
CASE_SELECTION = MACRO ( nom = "CASE_SELECTION",
                      sd_prod = opsPSEN_N1.INCLUDE,
                      op_init = opsPSEN_N1.INCLUDE_context,
                      regles = (UN_PARMI('FromFile', 'AllCases', 'WorstCases'),),
                      fichier_ini = 1,
                      op = None,
                      fr = "Sélectionnez les cas à analyser",
                      ang = 'Select the cases to analyze',
                      PSSE_path = SIMP(statut="o",typ='Repertoire',defaut='C:\Program Files (x86)\PTI\PSSE33\PSSBIN'),
                      output_folder = SIMP(statut="o", typ="Repertoire"),

                      FromFile = FACT(
                           statut = 'f',
                           input_path = SIMP(statut="f",typ='Repertoire'),
                           branch_cases = SIMP(statut='o', typ='TXM'),
                           transfo_cases = SIMP(statut='o', typ='TXM'),
                           high_cases = SIMP(statut='o', typ='TXM'),
                           low_cases = SIMP(statut='o', typ='TXM'),
                        ),

                      AllCases = FACT(
                           statut='f',
                           all_cases = SIMP(statut='o', typ=bool, defaut = True),
                         ),

                      WorstCases = FACT(
                          regles = (UN_PARMI('AvgBranchLoad', 'AvgBranchLoadPercent'), UN_PARMI('AvgTransfoLoad', 'AvgTransfoLoadPercent'), UN_PARMI('AvgHighVoltage', 'AvgHighVoltagePercent'), UN_PARMI('AvgLowVoltage', 'AvgLowVoltagePercent'),),
                          statut = 'f',
                          AvgBranchLoad = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgBranchLoadPercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgTransfoLoad = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgTransfoLoadPercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgHighVoltage = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgHighVoltagePercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                          AvgLowVoltage = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0),
                          AvgLowVoltagePercent = SIMP(statut = 'f', typ = 'I', defaut = 0, val_min = 0, val_max = 100),
                        ),

                      MaxDepth = SIMP(statut = 'o', typ = 'I', defaut = 5),
                      Consigne = SIMP(statut = "o",homo = 'information',typ = "TXM", defaut = "complete CASE SELECTION"),

                      BusesList = SIMP(statut = 'f', typ = 'R', min = 0, max = '**', defaut = (), homo = 'SansOrdreNiDoublon'),

                      optionsLF = FACT (
                        statut = 'o',
                        AdjTaps = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Lock', '1 - Stepping', '2 - Direct'], defaut = '1 - Stepping'),
                        AdjDCtaps = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Enable'], defaut = '1 - Enable'),
                        SolutionMethod = SIMP(statut = 'o', typ = 'TXM', into = ['0 - FDNS', '1 - FNSL', '2 - Optimized FDNS'], defaut = '1 - FNSL'),
                        AdjSwitchedShunts = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Enable', '2 - Enable continuous mode'], defaut = '1 - Enable'),
                        DispatchMode = SIMP(statut = 'o', typ = 'TXM', into = ['0 - Disable', '1 - Reserve', '2 - Pmax', '3 - Inertia', '4 - Droop'], defaut = '1 - Reserve'),
                        FlatStart = SIMP(statut = 'o', typ = bool, defaut = False),
                        VarLimits = SIMP(statut = 'o', typ = 'I', defaut = 99),
                      ),                 
                 )

CONTINGENCY_OPTIONS = PROC ( nom = 'CONTINGENCY_OPTIONS',
                            op = None,
                            fr = "Definitions des lois marginales utilisees par les variables d'entree",
                            ang = 'Nyu',
                            Vmin = SIMP(statut = 'o', typ = 'R', defaut = 0.9, val_min = 0),
                            Vmax = SIMP(statut = 'o', typ = 'R', defaut = 1.1, val_min = 0),
                            ContRate = SIMP(statut = 'o', typ = 'TXM', defaut = 'a', into=['a', 'b']),
                            FlowLimitLines = SIMP(statut = 'o', typ = 'I', defaut = 110, val_min = 0),
                            FloLimitTransfos = SIMP(statut = 'o', typ = 'I', defaut = 100, val_min = 0),
                            Tolance = SIMP(statut = 'o', typ = 'I', defaut = 10, val_min = 0),
                            RadialLinesOnly = SIMP(statut = 'o', typ = bool, defaut = False),
                            TripTransfos = SIMP(statut = 'o', typ = bool, defaut = True),
                            TripGenerators = SIMP(statut = 'o', typ = bool, defaut = True),
                            TripN_2 = SIMP(statut = 'o', typ = bool, defaut = False),
                            IsolatedGen = SIMP(statut = 'o', typ = bool, defaut = True),
                        )

OUTPUT_OPTIONS = PROC ( nom = 'OUTPUT_OPTIONS',
                        op = None,
                        fr = "Definitions des lois marginales utilisees par les variables d'entree",
                        ang = 'Nyu',
                        TrNoGSUorGNDOutput = SIMP(statut = 'o', typ = bool, defaut = True),
                        TestBusName = SIMP(statut = 'o', typ = bool, defaut = True),
                        ReportSpaces = SIMP(statut = 'o', typ = bool, defaut = True),
                        RepeatComponentAllLines = SIMP(statut = 'o', typ = bool, defaut = True),
                        MultipleContingencyReport = SIMP(statut = 'o', typ = bool, defaut = True),
                        WriteIndivExcels = SIMP(statut = 'o', typ = bool, defaut = True),
                        WriteFlowDifs = SIMP(statut = 'o', typ = bool, defaut = True),
                    )

DATA_PROCESSING = MACRO ( nom = 'DATA_PROCESSING',
                        sd_prod = opsPSEN_N1.PROCESS,
                        op_init = opsPSEN_N1.PROCESS_context,
                        fichier_ini = 1,
                        op = None,
                        fr = "Sélectionnez les cas à analyser",
                        ang = 'Select the cases to analyze',
                        XLS_file = SIMP(statut="o", typ = ('Fichier', 'XLS file (*.xls);;All Files (*)',),),
                        Onglets  = SIMP(statut = 'f', typ = 'TXM', min = 0, max = '**', homo = 'SansOrdreNiDoublon',into=(),),
                        BusList  = SIMP(statut = 'f', typ = 'TXM', min = 0, max = '**', homo = 'SansOrdreNiDoublon',into=(),),
                        ContList  = SIMP(statut = 'f', typ = 'TXM', min = 0, max = '**', homo = 'SansOrdreNiDoublon',into=(),),
                      )
