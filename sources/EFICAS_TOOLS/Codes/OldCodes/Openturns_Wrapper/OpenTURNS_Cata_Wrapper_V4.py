# -*- coding: utf-8 -*-
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

import Accas
from Accas import *

class variable(ASSD ) : pass


#CONTEXT.debug = 1
JdC = JDC_CATA ( code = 'OPENTURNS_WRAPPER',
                 execmodul = None,
                 regles = ( AU_MOINS_UN ( 'WRAPPER' ), ),
                 ) # Fin JDC_CATA

# --------------------------------------------------
# fin entete
# --------------------------------------------------


#================================
# 2. Definition des variables
#================================


                       
VARIABLE = OPER ( nom = "VARIABLE",
                      sd_prod = variable,
                      op = None,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree",
              

                     Type = SIMP ( statut = "o",
                                   typ = "TXM",
                                   max = 1,
                                   into = ( "in", "out", ),
                                   defaut = "in",
                                   fr = "variable d'entree ou de sortie du solver",
                                   ang = "Input or Output variable",
                                   ),

                     Unit = SIMP ( statut = "f",
                                   typ = "TXM",
                                   max = 1,
                                   fr = "Unite",
                                   ang = "Unit",
                                   ),

                     Comment = SIMP ( statut = "f",
                                      typ = "TXM",
                                      max = 1,
                                      fr = "Commentaire",
                                      ang = "Comment",
                                      ),

                     Regexp = SIMP ( statut = "f",
                                     typ = "TXM",
                                     max = 1,
                                     fr = "Expression reguliere",
                                     ang = "Regular expression",
                                     ),

                     Format = SIMP ( statut = "f",
                                     typ = "TXM",
                                     max = 1,
                                     fr = "Format d'ecriture",
                                     ang = "Format",
                                     ),


             ) # Fin FACT Variables
#


#================================
# Definition des parametres du wrapper
#================================

# Nota : les variables de type PROC doivent etre en majuscules !
WRAPPER = PROC ( nom = "WRAPPER",
                 op = None,
                 docu = "",
                 fr = "Mise en donnee pour le fichier de configuration de OPENTURNS.",
                 ang = "Writes the configuration file for OPENTURNS.",

    Framework = SIMP ( statut = "o",
                       typ = "TXM",
                       into = ( "Salome", "Stand-alone", ),
                       max = 1,
                       fr = "Dans quel environnement le wrapper doit-il etre utilise ?",
                       ang = "Which framework is this wrapper designed for ?",
                       ),

    StandAlone = BLOC ( condition = " Framework in ( 'Stand-alone', ) ",
    
    
        WrapperPath = SIMP ( statut = "o",
                             typ = "TXM",
                             max = 1,
                             fr = "Chemin d acces au wrapper",
                             ang = "Wrapper library path",
                             ),
    
        FunctionName = SIMP ( statut = "o",
                              typ = "TXM",
                              max = 1,
                              fr = "Nom de la fonction dans le wrapper",
                              ang = "Function's name in wrapper",
                              ),
    
        GradientName = SIMP ( statut = "f",
                              typ = "TXM",
                              max = 1,
                              fr = "Nom du gradient dans le wrapper",
                              ang = "Gradient's name in wrapper",
                              ),
    
        HessianName = SIMP ( statut = "f",
                             typ = "TXM",
                             max = 1,
                             fr = "Nom du hessian dans le wrapper",
                             ang = "Hessian's name in wrapper",
                             ),
    
        WrapCouplingMode = SIMP ( statut = "o",
                                  typ = "TXM",
                                  max = 1,
                                  into = ( "static-link", "dynamic-link", "fork", ),
                                  defaut = "fork",
                                  fr = "Mode de couplage du solver",
                                  ang = "Solver coupling mode",
                                  ),
    
        Fork = BLOC ( condition = " WrapCouplingMode in ( 'fork', ) ",
                        
                      Command = SIMP ( statut = "o",
                                       max = 1,
                                       typ = "TXM",
                                       fr = "Chemin du solver",
                                       ang = "Solver path",
                                       ),
                        
                      UserPrefix = SIMP ( statut = "f",
                                       max = 1,
                                       typ = "TXM",
                                       fr = "Prefixe pour retrouver les repertories temporaires de calcul",
                                       ang = "Prefix to help finding compute directories",
                                       ),
                      ), # Fin BLOC Fork
    
        State = SIMP ( statut = "f",
                       typ = "TXM",
                       max = 1,
                       into = ( "shared", "specific" ),
                       fr = "Partage de l'etat interne entre les fonctions",
                       ang = "Internal state sharing",
                       ),
    
        InDataTransfer = SIMP ( statut = "o",
                                typ = "TXM",
                                max = 1,
                                into = ( "files", "arguments", "corba" ),
                                fr = "Mode de transfert des donnees d'entree",
                                ang = "Input transfering mode",
                                ),
    
        OutDataTransfer = SIMP ( statut = "o",
                                 typ = "TXM",
                                 max = 1,
                                 into = ( "files", "arguments", "corba" ),
                                 fr = "Mode de transfert des donnees de sortie",
                                 ang = "Output transfering mode",
                                 ),
  
    ), # Fin BLOC StandAlone


    Salome = BLOC ( condition = " Framework in ( 'Salome', ) ",

        SolverComponentName  = SIMP ( statut = "f",
                                      typ = "TXM",
                                      max = 1,
                                      defaut = "UNDEFINED",
                                      fr = "Nom du composant solver",
                                      ang = "Solver component name",
                                      ),
    
    
        WrapperPath = SIMP ( statut = "o",
                             typ = "TXM",
                             into = ( "GenericWrapper4Salome.so", ),
                             defaut = "GenericWrapper4Salome.so",
                             max = 1,
                             fr = "Chemin d acces au wrapper",
                             ang = "Wrapper library path",
                             ),
    
        FunctionName = SIMP ( statut = "o",
                              typ = "TXM",
                              into = ( "GENERICSOLVER", ),
                              defaut = "GENERICSOLVER",
                              max = 1,
                              fr = "Nom de la fonction dans le wrapper",
                              ang = "Function's name in wrapper",
                              ),
    
        GradientName = SIMP ( statut = "f",
                              typ = "TXM",
                              into = ( "GENERICSOLVER", ),
                              defaut = "GENERICSOLVER",
                              max = 1,
                              fr = "Nom du gradient dans le wrapper",
                              ang = "Gradient's name in wrapper",
                              ),
    
        HessianName = SIMP ( statut = "f",
                             typ = "TXM",
                             into = ( "GENERICSOLVER", ),
                             defaut = "GENERICSOLVER",
                             max = 1,
                             fr = "Nom du hessian dans le wrapper",
                             ang = "Hessian's name in wrapper",
                             ),
    
        WrapCouplingMode = SIMP ( statut = "o",
                                  typ = "TXM",
                                  max = 1,
                                  into = ( "static-link", ),
                                  defaut = "static-link",
                                  fr = "Mode de couplage du solver",
                                  ang = "Solver coupling mode",
                                  ),
    
        State = SIMP ( statut = "f",
                       typ = "TXM",
                       max = 1,
                       into = ( "shared", "specific" ),
                       fr = "Partage de l'etat interne entre les fonctions",
                       ang = "Internal state sharing",
                       ),
    
        InDataTransfer = SIMP ( statut = "o",
                                typ = "TXM",
                                max = 1,
                                into = ( "files", "arguments", "corba", ),
                                defaut = "corba",
                                fr = "Mode de transfert des donnees d'entree",
                                ang = "Input transfering mode",
                                ),
    
        OutDataTransfer = SIMP ( statut = "o",
                                 typ = "TXM",
                                 max = 1,
                                 into = ( "files", "arguments", "corba", ),
                                 defaut = "corba",
                                 fr = "Mode de transfert des donnees de sortie",
                                 ang = "Output transfering mode",
                                 ),
  
    ), # Fin BLOC Salome


  Files = FACT ( statut = "f",
                 min = 1,
                 max = "**",

                 Id = SIMP ( statut = "o",
                             typ = "TXM",
                             max = 1,
                             fr = "Identificateur du  fichier",
                             ang = "File id",
                             ),

                 Type = SIMP ( statut = "o",
                               typ = "TXM",
                               max = 1,
                               into = ( "in", "out", ),
                               fr = "Fichier d entree ou de sortie du solveur ?",
                               ang = "Input or Output file ?",
                               ),

                 Name = SIMP ( statut = "f",
                               typ = "TXM",
                               max = 1,
                               fr = "Nom du fichier",
                               ang = "File name",
                               ),

                 Path = SIMP ( statut = "o",
                               typ = "TXM",
                               max = 1,
                               fr = "Chemin du fichier",
                               ang = "Path file ",
                               ),

                 Subst = SIMP ( statut = "f",
                                typ = "TXM",
                                max = "**",
                                fr = "Liste de variables",
                                ang = "List",
                                ),

                 ), # Fin FACT Files

) # Fin PROC WRAPPER
