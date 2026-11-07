# -*- coding: utf-8 -*-

# --------------------------------------------------
# debut entete
# --------------------------------------------------

import Accas
from Accas import *


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

VARIABLEPOOL = PROC ( nom = "VARIABLEPOOL",
                       op = None,
                       docu = "",
                       fr = "L'ensemble des variables probabilistes",
                       ang = "The pool of probabilistic variables",

                       
  Variables = FACT ( statut = "o",
                     min = 1,
                     max = "**",



                     Name = SIMP ( statut = "o",
                                   typ = "TXM",
                                   max = 1,
                                   fr = "Nom de la variable, identique au nom dans le solver.",
                                   ang = "Name of the variable, identical to the name in solver."
                                   ),

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


                      ), # Fin FACT Variables

) # Fin PROC VARIABLEPOOL


#================================
# Definition des parametres du wrapper
#================================

# Nota : les variables de type PROC doivent etre en majuscules !
WRAPPER = PROC ( nom = "WRAPPER",
                 op = None,
                 docu = "",
                 fr = "Mise en donnee pour le fichier de configuration de OPENTURNS.",
                 ang = "Writes the configuration file for OPENTURNS.",


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
                              fr = "Mode de couplage du solver",
                              ang = "Solver coupling mode",
                              ),

    Fork = BLOC ( condition = " WrapCouplingMode in ( 'fork', ) ",
                    
                  Command = SIMP ( statut = "o",
                                   max = 1,
                                   typ = "TXM",
                                   fr = "Chemin du solver",
                                   ang = "solver path",
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
                            into = ( "files", "arguments", ),
                            fr = "Mode de transfert des donnees d'entree",
                            ang = "Input transfering mode",
                            ),

    OutDataTransfer = SIMP ( statut = "o",
                             typ = "TXM",
                             max = 1,
                             into = ( "files", "arguments",  ),
                             fr = "Mode de transfert des donnees de sortie",
                             ang = "Output transfering mode",
                             ),




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
