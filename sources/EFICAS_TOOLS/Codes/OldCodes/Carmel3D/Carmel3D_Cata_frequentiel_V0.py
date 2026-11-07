# -*- coding: utf-8 -*-
# --------------------------------------------------
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

import os
import sys
from Accas import *
import types
from decimal import Decimal
# repertoire ou sont stockés le catalogue carmel3d 
# et les fichiers de donnees des materiaux de reference
from prefs_CARMEL3D import repIni

#print "catalogue carmel"
#print "repIni = ", repIni

# Version du catalogue
VERSION_CATA = "2.3.1 for harmonic problems"
# --------------------------------------------------
# definition d une classe pour les materiaux
# definition d une classe pour les sources
# definition d une classe pour les groupes de mailles
# --------------------------------------------------
class material ( ASSD ) : pass
class source   ( ASSD ) : pass
class grmaille ( ASSD ) : pass

#CONTEXT.debug = 1
# --------------------------------------------------
# déclaration du jeu de commandes : 1ere instruction du catalogue obligatoire 
#---------------------------------------------------

##=========================================================
JdC = JDC_CATA ( code = 'CARMEL3D',
#                execmodul = None,
                 regles =(
                           AU_MOINS_UN ('MATERIAL','INCLUDE'),
                           AU_MOINS_UN ('SOURCE','INCLUDE'),
                           AU_MOINS_UN ('MESHGROUP'),
                           ),
                 ) # Fin JDC_CATA
##=========================================================
# création d'une macro pour traiter les INCLUDE
#
#----------------------------------------------------------

import opsCarmel
INCLUDE = MACRO ( nom = "INCLUDE",
                 op = None,
                 UIinfo = { "groupes" : ( "Gestion du travail", ) },
                 sd_prod = opsCarmel.INCLUDE,
                 op_init = opsCarmel.INCLUDE_context,
                 fichier_ini = 1,
 
   FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'comm Files (*.comm);;All Files (*)',),
                     fr = u"bibliothèque des matériaux",
                    ang = "material library file",
                     ),
  
 ) # Fin MACRO 
# --------------------------------------------------
# definition de groupe de mailles
# il est associe a un  materiau ou a une source
#---------------------------------------------------

MESHGROUP     = OPER (nom = "MESHGROUP",
                    op = None,
                repetable = 'n',
                    UIinfo= {"groupes":("Definition",)},
            fr= u"attribution d'un matériau ou d'une source à un groupe du maillage", 
            ang = "mesh group association to material or source", 
                    sd_prod= grmaille,
                    regles =(
                             EXCLUS ('MATERIAL','SOURCE'),
                           ),

# ----------------------------------------------------------
# le mot cle SIMP doit etre facultatif sinon la recuperation 
# des groupes de mailles sous SALOME ne fonctionne pas car 
# le concept ne peut pas etre nomme car non valide
#-----------------------------------------------------------
              MATERIAL =  SIMP (statut="f",
                         typ=(material,),
                                 ang="name of the linked material",
                         fr =u"nom du matériau associé",
                                ), 
              SOURCE =  SIMP (statut="f",
                         typ=(source,),
                                 ang="name of the linked source",
                         fr =u"nom de la source associée",
                                ), 
                      )


#======================================================================
# le fichier .PHYS contient 3 blocs et jusqu'a 3 niveaux de sous-blocs
# 
#======================================================================
# 1er bloc : bloc VERSION
# ce bloc est volontairement cache dans l IHM 
#===================================================

VERSION = PROC ( nom = "VERSION",
                        op = None,
                repetable = 'n',
                        UIinfo= {"groupes":("CACHE",)},
                        ang= "version block definition", 

#----------------------
# Liste des parametres
#----------------------
        
   NUM      = SIMP (statut="o",
                    typ="I",
            defaut=1, 
                    ang="version number of the physical model", 
                    into=( 1,),
                   ),
   FILETYPE = SIMP (statut="o",
                    typ="TXM",
            defaut="PHYS", 
                    ang="file type",
                    into=( "PHYS",),
                   ),

) # Fin PROC VERSION

#===================================================================
# 2eme bloc : bloc MATERIALS
#===================================================================
# definition des matériaux utilisateurs 
# a partir des materiaux de reference ou de materiaux generiques
#-------------------------------------------------------------------
#
MATERIAL = OPER (nom = "MATERIAL",
                 op = None,
                 repetable = 'n',
                 ang= "material block definition", 
                 fr= u"définition d'un matériau", 
                 sd_prod= material,
                 regles=EXCLUS('PERMITTIVITY','CONDUCTIVITY'),

#---------------------------------------------------------------------
# liste des matériaux de reference fournis par THEMIS et  des
# materiaux generiques (les materiaux generiques peuvent etre utilises 
# si aucun materiau de reference  ne convient) 
#---------------------------------------------------------------------
                 TYPE = SIMP(statut='o',
                             typ='TXM',
                             into=(
#  matériaux génériques 
                                 "DIELECTRIC",
                                 "CONDUCTOR",
                                 "ZINSULATOR","ZSURFACIC",
                                 "NILMAT","EM_ISOTROPIC","EM_ANISOTROPIC",
                             ),
                             ang = "generic materials list",
                             fr  = u"liste des matériaux génériques",
                            ),

##############################################################################
# Remarque generale a tous les materiaux : 
# pour conserver l'affichage scientifique le nombre derriere l'exposant doit
# etre strictement superieur au nombre de decimales 
#

##----------------------------------------------------------------------------------------------
# Données de perméabilité, utilisée pour les diélectriques, conducteurs et impédances de surface
#-----------------------------------------------------------------------------------------------
  #HAS_PERMEABILITY = BLOC(condition="TYPE in ('DIELECTRIC','CONDUCTOR','ZSURFACIC')",

#------------------------------------------------
# sous bloc niveau 2 : PERMEABILITY
#------------------------------------------------
#
  PERMEABILITY = FACT ( statut="f", 
                        ang ="Permeability properties",
                        fr  =u"propriétés de perméabilité du matériau",
                        HOMOGENEOUS = SIMP (statut="o",
                                            typ="TXM",
                                            defaut="TRUE",
                                            into = ("TRUE","FALSE"),
                                            ang = "the material is homogeneous or not",
                                            fr  = u"le matériau est homogène ou non",
                                           ),
                        ISOTROPIC = SIMP (statut="o",
                                          typ="TXM",
                                          defaut="TRUE",
                                          into = ("TRUE","FALSE"),
                                          ang = "the material is isotropic or not",
                                          fr  = u"le matériau est isotrope ou non",
                                         ),
                   HOMOGENEOUS_ISOTROPIC_PROPERTIES = BLOC (condition="HOMOGENEOUS=='TRUE' and ISOTROPIC=='TRUE'",
                        LAW = SIMP (statut="o",
                                    typ="TXM",
                                    defaut="LINEAR",
                                    into = ("LINEAR","NONLINEAR"),
                                    ang = "harmonic or time-domain linear or nonlinear law only for homogeneous and isotropic materials",
                                    fr  = u"loi linéaire (fréquentielle ou temporelle) ou non (homogène et isotrope seulement)",
                                   ), 
                        VALUE = SIMP (statut="o",
                                      typ="C", 
                                      defaut=('RI',1,0),
                                      ang = "Relative linear permeability value, also used at first nonlinear iteration",
                                      fr = u"Valeur de la perméabilité relative à l'air utilisée pour une loi linéaire ou pour la première itération non-linéaire",
                                     ),
                    NONLINEAR_LAW_PROPERTIES = BLOC (condition="LAW=='NONLINEAR'",
                        NATURE = SIMP (statut="o",
                                       typ="TXM",
                                       defaut="MARROCCO",
                                       into = ("SPLINE","MARROCCO","MARROCCO+SATURATION"),
                                       ang = "nature law",
                                       fr  = u"nature de la loi",
                                      ),
                     SPLINE_LAW_PROPERTIES = BLOC (condition="NATURE=='SPLINE'",
                        FILENAME = SIMP (statut="o", 
                                         typ=("FichierNoAbs",'All Files (*)',), # l'existence du fichier n'est pas vérifiée
                                         ang="data file name",
                                         fr =u"nom du fichier contenant les mesures expérimentales B(H)",
                                        ),
                     ), # Fin BLOC SPLINE_PROPERTIES
                     MARROCCO_LAW_PROPERTIES = BLOC (condition="NATURE in ('MARROCCO','MARROCCO+SATURATION')",
                        ALPHA = SIMP (statut="o", 
                                      typ="R",
                                      defaut=0,
                                      val_min=0,
                                      ang="alpha parameter",
                                      fr =u"paramètre alpha de la loi de Marrocco" ,
                                     ),
                        TAU = SIMP (statut="o", 
                                    typ="R",
                                    defaut=0,
                                    val_min=0,
                                    ang="tau parameter",
                                    fr =u"paramètre tau de la loi de Marrocco" ,
                                   ),
                        C = SIMP (statut="o", 
                                  typ="R",
                                  defaut=0,
                                  val_min=0,
                                  ang="c parameter",
                                  fr =u"paramètre c de la loi de Marrocco" ,
                                 ),
                        EPSILON = SIMP (statut="o", 
                                        typ="R",
                                        defaut=0,
                                        val_min=0,
                                        ang="epsilon parameter",
                                        fr =u"paramètre epsilon de la loi de Marrocco" ,
                                       ),
                     ), # Fin BLOC MARROCCO_LAW_PROPERTIES
                     SATURATION_LAW_PROPERTIES = BLOC (condition="NATURE=='MARROCCO+SATURATION'",
                        BMAX = SIMP (statut="o", 
                                     typ="R",
                                     defaut=0,
                                     val_min=0,
                                     ang="intersection B",
                                     fr = u"valeur de B marquant la fin de la loi de Marrocco et le début du raccord à la loi de saturation",
                                    ),
                        HSAT = SIMP (statut="o", 
                                     typ="R",
                                     defaut=0,
                                     val_min=0,
                                     ang="H value",
                                     fr = u"valeur de H définissant la loi de saturation",
                                    ),
                        BSAT = SIMP (statut="o", 
                                     typ="R",
                                     defaut=0,
                                     val_min=0,
                                     ang="B value",
                                     fr = u"valeur de B définissant la loi de saturation",
                                    ),
                        JOIN = SIMP (statut="o", 
                                     typ="TXM",
                                     defaut="SPLINE",
                                     into= ("SPLINE","PARABOLIC","LINEAR"),
                                     ang="type of join between laws",
                                     fr =u"type de raccord entre la loi choisie et la loi de saturation" ,
                                    ),
                     ), # Fin BLOC SATURATION_LAW_PROPERTIES
                        APPLIEDTO = SIMP (statut="o",    
                                          typ="TXM",   
                                          into=("B(H)&H(B)","B(H)","H(B)"),
                                          defaut="B(H)&H(B)",
                                          ang="join applied to",
                                          fr =u"Le raccord tel que défini est appliqué à la courbe B(H) seulement, à la courbe H(B) seulement ou aux deux courbes à la fois. Dans les deux premiers cas, le raccord de la courbe H(B) est inversé numériquement à partir du raccord défini pour la courbe B(H), et vice-versa.",
                                         ),
                    ), # Fin BLOC NONLINEAR_LAW_PROPERTIES
                   ), # Fin BLOC HOMOGENEOUS_ISOTROPIC_PROPERTIES
             ), # fin FACT PERMEABILITY
   #), # Fin BLOC HAS_PERMEABILITY

##------------------------------------------------------------------
# Données de permittivité, utilisée pour les diélectriques seulement
#-------------------------------------------------------------------
  #HAS_PERMITTIVITY = BLOC(condition="TYPE == 'DIELECTRIC'",

#------------------------------------------------
# sous bloc niveau 2 : PERMITTIVITY
#------------------------------------------------
  PERMITTIVITY = FACT ( statut="f", 
                        ang ="Permittivity properties",
                        fr  = u"propriétés de permittivité du matériau",
                        HOMOGENEOUS = SIMP (statut="o",
                                            typ="TXM",
                                            defaut="TRUE",
                                            into = ("TRUE","FALSE"),
                                            ang = "the material is homogeneous or not",
                                            fr  = u"le matériau est homogène ou non",
                                           ),
                        ISOTROPIC = SIMP (statut="o",
                                          typ="TXM",
                                          defaut="TRUE",
                                          into = ("TRUE","FALSE"),
                                          ang = "the material is isotropic or not",
                                          fr  = u"le matériau est isotrope ou non",
                                         ),
                       HOMOGENEOUS_ISOTROPIC_PROPERTIES = BLOC (condition="HOMOGENEOUS=='TRUE' and ISOTROPIC=='TRUE'",
                        LAW = SIMP (statut="o",
                                    typ="TXM",
                                    defaut="LINEAR",
                                    into = ("LINEAR",),
                                    ang = "linear law",
                                    fr  = u"loi linéaire",
                                   ),
                        VALUE = SIMP (statut="o",
                                      typ="C", 
                                      defaut=('RI',1,0),
                                      ang = "enter a complex relative value",
                                      fr = u"saisir une valeur complexe relative",
                                     ),
                       ), # Fin BLOC HOMOGENEOUS_ISOTROPIC_PROPERTIES
                      ), # fin FACT PERMITTIVITY

   #), # Fin BLOC HAS_PERMITTIVITY

##----------------------------------------------------------------------------------------------
# Données de conductivité, utilisée pour les conducteurs et impédances de surface
#-----------------------------------------------------------------------------------------------
  #HAS_CONDUCTIVITY = BLOC(condition="TYPE in ('CONDUCTOR','ZSURFACIC')",
#------------------------------------------------
# sous bloc niveau 2 : CONDUCTIVITY
#------------------------------------------------
  CONDUCTIVITY = FACT ( statut="f", 
                        ang ="Permittivity properties",
                        fr  = u"propriétés de permittivité du matériau",
                        HOMOGENEOUS = SIMP (statut="o",
                                            typ="TXM",
                                            defaut="TRUE",
                                            into = ("TRUE","FALSE"),
                                            ang = "the material is homogeneous or not",
                                            fr  = u"le matériau est homogène ou non",
                                           ),
                        ISOTROPIC = SIMP (statut="o",
                                          typ="TXM",
                                          defaut="TRUE",
                                          into = ("TRUE","FALSE"),
                                          ang = "the material is isotropic or not",
                                          fr  = u"le matériau est isotrope ou non",
                                         ),
                       HOMOGENEOUS_ISOTROPIC_PROPERTIES = BLOC (condition="HOMOGENEOUS=='TRUE' and ISOTROPIC=='TRUE'",
                        LAW = SIMP (statut="o",
                                    typ="TXM",
                                    defaut="LINEAR",
                                    into = ("LINEAR",),
                                    ang = "linear law",
                                    fr  = u"loi linéaire",
                                   ),
                        VALUE = SIMP (statut="o",
                                      typ="C", 
                                      defaut=('RI',1,0),
                                      ang = "enter a complex relative value",
                                      fr = u"saisir une valeur complexe relative",
                                     ),
                       ), # Fin BLOC HOMOGENEOUS_ISOTROPIC_PROPERTIES
                      ), # fin FACT CONDUCTIVITY

   #), # Fin BLOC HAS_CONDUCTICITY

###################################################################################################
#---------------------------------------------
# sous bloc niveau 1  
#---------------------------------------
# matériau generique de type ZINSULATOR 
#---------------------------------------
  
# aucun parametre a saisir pour ce materiau


###################################################################################################
#---------------------------------------------
# sous bloc niveau 1     
#---------------------------------------------
# matériau generique de type NILMAT (fictif)  
#---------------------------------------------
  
# aucun parametre a saisir pour ce materiau


###################################################################################################
#----------------------------------------------------------
# sous bloc niveau 1 : EM_ISOTROPIC_FILES   
#-------------------------------------------------
# matériau isotropique non homogene generique
#-------------------------------------------------
   EM_ISOTROPIC_properties=BLOC(condition="TYPE=='EM_ISOTROPIC'", 
               
           CONDUCTIVITY_File = SIMP (statut="o", 
                                     typ=("FichierNoAbs",'MED Files (*.med)',),
                                     ang="CONDUCTIVITY MED data file name",
                                     fr = u"nom du fichier MED CONDUCTIVITY",
                                    ),
           PERMEABILITY_File = SIMP (statut="o", 
                                     typ=("FichierNoAbs",'MED Files (*.med)',),
                                     ang="PERMEABILITY MED data file name",
                                     fr = u"nom du fichier MED PERMEABILITY",
                                    ),
   ), # fin bloc EM_ISOTROPIC_properties

    
#---------------------------------------------------
# matériau  anisotropique non homogene generique 
#---------------------------------------------------
   EM_ANISOTROPIC_properties=BLOC(condition="TYPE=='EM_ANISOTROPIC'",
                 
           PERMEABILITY_File = SIMP (statut="o", 
                                     #typ=("Fichier",'.mater Files (*.mater)'), # le fichier doit exister dans le répertoire d'où on lancer Eficas si le fichier est défini par un nom relatif, ce qui est trop contraignant
                                     #typ=("Fichier",'.mater Files (*.mater)','Sauvegarde'), # Le fichier peut ne pas exister, mais on propose de le sauvegarder et d'écraser un fichier existant : pas approprié
                                     typ=("FichierNoAbs",'.mater Files (*.mater)'), # l'existence du fichier n'est pas vérifiée, mais on peut le sélectionner quand même via la navigateur. C'est suffisant et permet une bibliothèque de matériaux.
                                     ang="PERMEABILITY .mater data file name",
                                     fr ="nom du fichier .mater PERMEABILITY",
                                    ),
           CONDUCTIVITY_File = SIMP (statut="o", 
                                     typ=("FichierNoAbs",'.mater Files (*.mater)'),
                                     ang="CONDUCTIVITY .mater data file name",
                                     fr ="nom du fichier .mater CONDUCTIVITY",
                                    ),
   ), # fin bloc EM_ANISOTROPIC_properties


) # fin OPER MATERIAL
    
#===================================================================
# 3eme bloc : bloc SOURCES
#====================================================================
# definition des differentes sources qui seront dans le bloc SOURCES
#-------------------------------------------------------------------
#

SOURCE = OPER ( nom = "SOURCE",
                op = None,
                repetable = 'n',
                ang = "source definition", 
                fr = u"définition d'une source", 
                sd_prod = source,
                regles = (UN_PARMI('STRANDED_INDUCTOR','HPORT','EPORT'), # choix d'un type de source
                          UN_PARMI('WAVEFORM_CONSTANT','WAVEFORM_SINUS'), # choix d'une forme de source
                         ),

#----------------------------------------------------------
# sous bloc niveau 1 : stranded inductor source 
##---------------------------------------------------------
                STRANDED_INDUCTOR = FACT(statut='f',
                                         ang="Stranded inductor source",
                                         fr=u"source de type inducteur bobiné",
                                         NTURNS = SIMP (statut="o",
                                                        typ="I",
                                                        defaut=1,
                                                        ang="number of turns in the inductor",
                                                        fr= u"nombre de tours dans l'inducteur bobiné",
                                                       ),
                                         TYPE = SIMP (statut="o",
                                                      typ="TXM",
                                                      defaut="CURRENT",
                                                      into=("CURRENT",),
                                                      fr= u"source de type courant",
                                                      ang="current source type",
                                                     ),
                ), # FIN de FACT STRANDED_INDUCTOR
                HPORT = FACT(statut='f',
                             ang="Magnetic port source",
                             fr=u"source de type port magnétique",
                             TYPE = SIMP (statut="o",
                                          typ="TXM",
                                          into=("VOLTAGE","CURRENT"),
                                          fr= u"source de type tension ou courant",
                                          ang="voltage or current source type",
                                         ),
                ), # FIN de FACT HPORT
                EPORT = FACT(statut='f',
                             ang="Electric port source",
                             fr=u"source de type port électrique",
                             TYPE = SIMP (statut="o",
                                          typ="TXM",
                                          into=("VOLTAGE","CURRENT"),
                                          fr= u"source de type tension ou courant",
                                          ang="voltage or current source type",
                                         ),
                ), # FIN de FACT EPORT
                WAVEFORM_CONSTANT = FACT(statut='f',
                                         ang="constant source",
                                         fr=u"source constante",
                                         AMPLITUDE = SIMP (statut="o",
                                                           typ="R", 
                                                           defaut=1,
                                                           ang = "enter the source magnitude value, in A or V units",
                                                           fr = u"saisir la valeur de l'amplitude de la source, en unités A ou V",
                                                          ),
                ), # FIN de FACT WAVEFORM_CONSTANT
                WAVEFORM_SINUS = FACT(statut='f',
                                      ang="sinus variation source",
                                      fr=u"source variant avec une forme sinusoïdale, définie par son amplitude, sa fréquence et sa phase",
                                      AMPLITUDE = SIMP (statut="o",
                                                        typ="R", 
                                                        defaut=1,
                                                        ang = "enter the source magnitude value, in A or V units",
                                                        fr = u"saisir la valeur de l'amplitude de la source, en unités A ou V",
                                                       ),
                                      FREQUENCY = SIMP (statut="o",
                                                        typ="R", 
                                                        defaut=50.0,
                                                        ang = "enter the source frequency value, in Hz units",
                                                        fr = u"saisir la valeur de la fréquence de la source, en Hz",
                                                       ),
                                      PHASE = SIMP (statut="o",
                                                    typ="R", 
                                                    defaut=0.0,
                                                    ang = "enter the source phase value, in degrees units",
                                                    fr = u"saisir la valeur de la phase de la source, en degrés",
                                                   ),
                ), # FIN de FACT WAVEFORM_SINUS
) # Fin OPER SOURCE
