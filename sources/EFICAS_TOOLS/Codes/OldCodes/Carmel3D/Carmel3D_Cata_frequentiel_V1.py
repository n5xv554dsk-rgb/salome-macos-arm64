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



#print "catalogue carmel"
#print "repIni = ", repIni

# Version du catalogue
VERSION_CATA = "Code_Carmel3D 2.4.0 for harmonic problems"
# --------------------------------------------------
# definition d une classe pour les materiaux
# definition d une classe pour les sources
# definition d une classe pour les groupes de mailles
# --------------------------------------------------
class material ( ASSD ) : pass
class source   ( ASSD ) : pass
class grmaille ( ASSD ) : pass
class stranded_inductor_geometry ( ASSD ) : pass
class macro_groupe ( ASSD ) : pass 

#CONTEXT.debug = 1
# --------------------------------------------------
# déclaration du jeu de commandes : 1ere instruction du catalogue obligatoire 
#---------------------------------------------------

##=========================================================
JdC = JDC_CATA ( code = 'CARMEL3D',
                execmodul = None,
                 regles =(
                           AU_MOINS_UN ('PARAMETERS'),
                           AU_PLUS_UN ('PARAMETERS'),
                           AU_MOINS_UN ('SOLVEUR'),
                           AU_PLUS_UN ('SOLVEUR'),
                           AU_MOINS_UN ('POST_COMMANDS'), 
                           AU_PLUS_UN ('POST_COMMANDS'), 
                           AU_MOINS_UN ('MATERIAL','INCLUDE'),
                           AU_MOINS_UN ('SOURCE','INCLUDE'),
                           AU_MOINS_UN ('MESHGROUP'),
                           ),
                 ) # Fin JDC_CATA

import opsCarmel

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

PARAMETERS= PROC ( nom = "PARAMETERS",
                 op = None,
                 repetable = 'n',
                 UIinfo = { "groupes" : ( "1) Parametres", ) },
                 ang= "General parameters for this study", 
                 fr= u"Paramètres généraux de l'étude", 
#----------------------
# Liste des parametres
#----------------------                
    RepCarmel=SIMP(typ='Repertoire', statut='o', 
                                ang= "Code_Carmel3D executables directory",
                                fr= u"Répertoire contenant les programmes de Code_Carmel3D",
                                ),
    Fichier_maillage = SIMP (statut="o", typ=("FichierNoAbs",'All Files (*)',), # l'existence du fichier n'est pas vérifiée
                                             ang="Mesh file path (relative, aka file name, or absolute path).",
                                             fr =u"Emplacement du fichier contenant le maillage (relatif, i.e., nom du fichier, ou absolu, i.e., chemin complet).",
                                           ),
    
    Echelle_du_maillage = SIMP (statut='o',  typ="TXM",  defaut= "Millimetre",  into = ("Metre", "Millimetre"), 
                                                 ang="Mesh geometry units.",
                                                 fr =u"Unités géométriques du maillage.",
                                                ), 
    
    Formulation=SIMP(statut='o', typ='TXM', into=("TOMEGA","APHI"), 
                                                 ang="Problem formulation.",
                                                 fr =u"Formulation du problème.",
                                                ), 

    FREQUENCY = SIMP (statut="o",
                 typ="R",
                 defaut=50.0, 
                 ang = "enter the source frequency value, in Hz units",
                 fr = u"saisir la valeur de la fréquence de la source, en Hz",
                 val_min=0.0,
                ),
 
    Realiser_topologie_gendof = SIMP (statut='o',  typ="TXM", defaut="TRUE", into=("TRUE", "FALSE"),  
                                                 ang="Build topology (.car file) using gendof.exe.",
                                                 fr =u"Construction de la topologie (fichier .car) en éxécutant gendof.exe.",
                                                ), 
    Resoudre_probleme = SIMP (statut='o',  typ="TXM", defaut="TRUE", into=("TRUE", "FALSE"),
                                                 ang="Solve the problem using fcarmel.exe.",
                                                 fr =u"Résolution du problème en éxécutant fcarmel.exe.",
                                                ), 

    Realiser_post_traitement_aposteriori = SIMP (statut='o',  typ="TXM", defaut="TRUE", into=("TRUE", "FALSE"),
                                                 ang="Make post-processing using postprocess.exe.",
                                                 fr =u"Réalisation du post-traitement en éxécutant postprocess.exe.",
                                                ), 
) # Fin PROC PARAMETERS

SOLVEUR = PROC ( nom ="SOLVEUR",
          op=None,
          repetable = 'n',
          UIinfo= {"groupes":("1) Parametres",)},
          ang= "Solver parameters for this study", 
          fr= u"Paramètres liés au solveur de l'étude", 
          
          Type= SIMP (statut="o",
                              typ="TXM",
                              into=("Solveur_lineaire"), 
                              defaut='Solveur_lineaire', 
                              ang="Linear solver only for harmonic problems.",
                              fr =u"Solveur linéaire seulement pour les problèmes fréquentiels.",
                            ), 
                                      
            Solveur_lineaire=BLOC(condition="Type=='Solveur_lineaire'", 
                                                  ang="This block contains whole linear solver properties.",
                                                  fr =u"Ce bloc contient toutes les propriétés du solveur linéaire.",
                    Methode_lineaire=SIMP(statut='o', typ='TXM', into=("Methode iterative BICGCR", "Methode directe MUMPS"), 
                                                          ang="Algorithm used for this linear solver.",
                                                          fr =u"Méthode (algorithme) utilisée par ce solveur linéaire.",
                                                        ), 
                                   
                    Parametres_methode_iterative_BICGCR=BLOC(condition="Methode_lineaire=='Methode iterative BICGCR'", 
                                                                                              ang="This block contains whole BICGCR algorithm properties used for the linear solver.",
                                                                                              fr =u"Ce bloc contient toutes les propriétés de la méthode BICGCR utilisée par le solveur linéaire.",
                              Precision=SIMP(statut='o', typ='R', defaut=1e-9,
                                                      ang="Accuracy on linear computations.",
                                                      fr =u"Précision du calcul linéaire.",
                                                      ), 
                              Nombre_iterations_max=SIMP(statut='o', typ='I',defaut=10000,  
                                                                              ang="Maximal number of iterations.",
                                                                              fr =u"Nombre maximal d'itérations.",
                                                                              ), 
                              Preconditionneur=SIMP(statut='f', typ='TXM',  into=("Jacobi"), defaut='Jacobi', 
                                                                  ang="Preconditioner choice. Jacobi only.",
                                                                  fr =u"Choix du préconditioneur. Jacobi disponible seulement.",
                                                                    ), 
                              ), 
                                
                    Parametres_methode_directe_MUMPS=BLOC(condition="Methode_lineaire=='Methode directe MUMPS'",
                                                                                              ang="This block contains whole MUMPS properties used for the linear solver.",
                                                                                              fr =u"Ce bloc contient toutes les propriétés de la méthode MUMPS utilisée par le solveur linéaire.",
                              Type_de_matrice=SIMP(statut='o', typ='I', defaut=2,
                                                                  ang="Matrix type (symetry). 2: symetric. Please refer to MUMPS documentation.",
                                                                  fr =u"Type de matrice (symétrie). Choisir 2 pour une matrice symétrique. Expliqué dans la documentation MUMPS.",
                                                                   ), 
                              ICNTL_Control_Parameters=SIMP(statut='o', typ='I', defaut=7,  
                                                                  ang="ICNTL control parameter. Please refer to MUMPS documentation.",
                                                                  fr =u"Paramètre de contrôle ICNTL. Expliqué dans la documentation MUMPS.",
                                                                   ), 
                              CNTL_Control_Parameters=SIMP(statut='o', typ='I', defaut=5,  
                                                                  ang="CNTL control parameter. Please refer to MUMPS documentation.",
                                                                  fr =u"Paramètre de contrôle CNTL. Expliqué dans la documentation MUMPS.",
                                                                   ), 
                              ), 
                ), 
    )

POST_COMMANDS = PROC ( nom = "POST_COMMANDS",
                                                op = None,
                                                repetable = 'n',
                                                UIinfo = { "groupes" : ( "1) Parametres", ) },
                                                ang= "post-processing commands .cmd or .post file", 
                                                fr= u"fichiers .cmd ou .post de commandes de post-traitement", 
    # Sous-parties, moins indentées pour améliorer la lisibilité
    # Grandeurs globales
    GLOBAL = FACT ( statut="f", 
                                ang ="Post-processing of global quantities",
                                fr  =u"Post-traitement des grandeurs globales",
                                ), 
    # Carte de tous les champs possibles
    VISU = FACT ( statut="f", 
                            ang ="Post-processing of field maps",
                            fr  =u"Post-traitement des cartes de champ",
                            VISU_Format=SIMP(statut='o', typ='TXM', into=("MED", "VTK"), defaut="MED"), 
                            VISU_Type=SIMP(statut='o', typ='TXM', into=("ELEMENT", "NOEUD"), defaut="ELEMENT"), 
                         ), 
    # Ligne de coupe
    CUTLINE = FACT ( statut="f", 
                            ang = "Post-processing of one cutline",
                            fr  = u"Post-traitement d'une ligne de coupe",
                            first_point = SIMP(statut='o', 
                            typ = Tuple(3),validators = VerifTypeTuple(('R','R','R')),
                            ang="First point of the cutline (cartesian coordinates).", 
                            fr=u"Point de départ (premier point) de la ligne de coupe (coordonnées cartésiennes).",
                                                             ), 

                            last_point = SIMP(statut='o', typ='R', min=3, max=3, 
                                                              ang="Last point of the cutline (cartesian coordinates).", 
                                                              fr=u"Point d'arrivée (dernier point) de la ligne de coupe (coordonnées cartésiennes)."
                                                             ), 
                            number_of_points = SIMP(statut='o', typ='I', 
                                                              ang="Number of points of the cutline.", 
                                                              fr=u"Nombre de points de la ligne de coupe."
                                                             ), 
                            name = SIMP(statut='o', typ='TXM', 
                                                              ang="Name of the cutline, used in the output filename.", 
                                                              fr=u"Nom de la ligne de coupe, utilisé dans le nom du fichier de sortie."
                                                             ), 
                            field = SIMP(statut='o', typ='TXM', into=("H", "B", "J", "E"),  
                                                              ang="Field on which the cutline is applied.", 
                                                              fr=u"Champ pour lequel la ligne de coupe est définie."
                                                             ), 
                         ), 
    # Plan de coupe
    CUTPLANE = FACT ( statut="f", 
                            ang = "Post-processing of one cutplane",
                            fr  = u"Post-traitement d'un plan de coupe",
                            normal_vector = SIMP(statut='o', typ='TXM', into=("Ox", "Oy", "Oz"),  
                                                              ang="Cutplane normal vector, i.e., perpendicular axis, 3 possible cartesian values: Ox, Oy, Oz.", 
                                                              fr=u"Vecteur normal au plan de coupe, i.e., son axe perpendiculaire, parmi les 3 valeurs cartésiennes Ox, Oy et Oz."
                                                             ), 
                            plane_position = SIMP(statut='o', typ='R', 
                                                              ang="Cutplane position, i.e., its coordinate along the normal vector axis.", 
                                                              fr=u"Position du plan de coupe, i.e., coordonnée le long de l'axe de vecteur normal."
                                                             ), 
                            number_of_points = SIMP(statut='o', typ='I', min=2, max=2,  
                                                              ang="Number of points on the cutplane, which define a cartesian grid along its canonical directions, e.g., Ox and Oy if plane normal to Oz.", 
                                                              fr=u"Nombre de points sur le plan de coupe dans les deux directions (grille cartésienne), e.g., Ox et Oy si le plan est normal à Oz."
                                                             ), 
                            name = SIMP(statut='o', typ='TXM', 
                                                              ang="Name of the cutplane, used in the output filename.", 
                                                              fr=u"Nom du plan de coupe, utilisé dans le nom du fichier de sortie."
                                                             ), 
                            field = SIMP(statut='o', typ='TXM', into=("H", "B", "J", "E"),  
                                                              ang="Field on which the cutplane is applied.", 
                                                              fr=u"Champ pour lequel le plan de coupe est défini."
                                                             ), 
                         ), 
            
) # Fin PROC POST_COMMANDS


#======================================================================
# le fichier .PHYS contient 3 blocs et jusqu'a 3 niveaux de sous-blocs
# 
#======================================================================

#===================================================================
# 2eme bloc : bloc MATERIALS
#===================================================================
# definition des matériaux utilisateurs 
# a partir des materiaux de reference ou de materiaux generiques
#-------------------------------------------------------------------

MATERIAL = OPER (nom = "MATERIAL",
                 op = None,
                 repetable = 'n',
                 UIinfo = { "groupes" : ( "2) Proprietes", ) },
                 ang= "real material block definition", 
                 fr= u"définition d'un matériau réel", 
                 sd_prod= material,
 #                regles=EXCLUS('PERMITTIVITY','CONDUCTIVITY'),

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
 PERMEABILITY_properties = BLOC (condition="TYPE=='DIELECTRIC' or TYPE=='CONDUCTOR'", 
  PERMEABILITY = FACT ( statut="o", 
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
                                      defaut=1,
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
             ), 
    ),# fin FACT PERMEABILITY


##----------------------------------------------------------------------------------------------
# Données de conductivité, utilisée pour les conducteurs et impédances de surface
#-----------------------------------------------------------------------------------------------
  #HAS_CONDUCTIVITY = BLOC(condition="TYPE in ('CONDUCTOR','ZSURFACIC')",
#------------------------------------------------
# sous bloc niveau 2 : CONDUCTIVITY
#------------------------------------------------
  
 CONDUCTIVITY_properties= BLOC (condition="TYPE=='CONDUCTOR'", 
  CONDUCTIVITY = FACT ( statut="o", 
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
                                      defaut=1, 
                                      ang = "enter a complex relative value",
                                      fr = u"saisir une valeur complexe relative",
                                     ),
                       ), # Fin BLOC HOMOGENEOUS_ISOTROPIC_PROPERTIES
                      ), 

             ), 

            
        # fin FACT CONDUCTIVITY

   

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
                 regles =(
                           AU_MOINS_UN ('CONDUCTIVITY_File','PERMEABILITY_File'),
                           ),
           CONDUCTIVITY_File = SIMP (statut="f", 
                                     typ=("FichierNoAbs",'MED Files (*.med)',),
                                     ang="CONDUCTIVITY MED data file name",
                                     fr = u"nom du fichier MED CONDUCTIVITY",
                                    ),
           PERMEABILITY_File = SIMP (statut="f", 
                                     typ=("FichierNoAbs",'MED Files (*.med)',),
                                     ang="PERMEABILITY MED data file name",
                                     fr = u"nom du fichier MED PERMEABILITY",
                                    ),
   ), # fin bloc EM_ISOTROPIC_properties

    
#---------------------------------------------------
# matériau  anisotropique non homogene generique 
#---------------------------------------------------
   EM_ANISOTROPIC_properties=BLOC(condition="TYPE=='EM_ANISOTROPIC'",
                 regles =(
                           AU_MOINS_UN ('CONDUCTIVITY_File','PERMEABILITY_File'),
                           ),                 
           PERMEABILITY_File = SIMP (statut="f", 
                                     #typ=("Fichier",'.mater Files (*.mater)'), # le fichier doit exister dans le répertoire d'où on lancer Eficas si le fichier est défini par un nom relatif, ce qui est trop contraignant
                                     #typ=("Fichier",'.mater Files (*.mater)','Sauvegarde'), # Le fichier peut ne pas exister, mais on propose de le sauvegarder et d'écraser un fichier existant : pas approprié
                                     typ=("FichierNoAbs",'.mater Files (*.mater)'), # l'existence du fichier n'est pas vérifiée, mais on peut le sélectionner quand même via la navigateur. C'est suffisant et permet une bibliothèque de matériaux.
                                     ang="PERMEABILITY .mater data file name",
                                     fr ="nom du fichier .mater PERMEABILITY",
                                    ),
           CONDUCTIVITY_File = SIMP (statut="f", 
                                     typ=("FichierNoAbs",'.mater Files (*.mater)'),
                                     ang="CONDUCTIVITY .mater data file name",
                                     fr ="nom du fichier .mater CONDUCTIVITY",
                                    ),
   ), # fin bloc EM_ANISOTROPIC_properties


#------------------------------------------------------------------
# Données de permittivité, utilisée pour les diélectriques seulement
#-------------------------------------------------------------------
  #HAS_PERMITTIVITY = BLOC(condition="TYPE == 'DIELECTRIC'",

#------------------------------------------------
# sous bloc niveau 2 : PERMITTIVITY
#------------------------------------------------

 Utiliser_la_permittivite = SIMP (statut='o', 
                                 typ='TXM',
                                 into = ("OUI","NON"),
                                 defaut="NON", 
                                ang ="Optionnaly use permittivity or not (default)",
                                fr  = u"Utilisation optionnelle de la permittivité du matériau. Pas d'utilisation par défaut.",
                                ), 
 PERMITTIVITY_properties = BLOC (condition="Utiliser_la_permittivite=='OUI'", 
  PERMITTIVITY = FACT ( statut="o", 
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
                                      defaut=1,
                                      ang = "enter a complex relative value",
                                      fr = u"saisir une valeur complexe relative",
                                     ),
                       ), # Fin BLOC HOMOGENEOUS_ISOTROPIC_PROPERTIES
                    ), 
                ),# fin FACT PERMITTIVITY

        )  # fin OPER MATERIAL
    
    

##############################################################################
# Remarque generale a tous les materiaux : 
# pour conserver l'affichage scientifique le nombre derriere l'exposant doit
# etre strictement superieur au nombre de decimales 


#===================================================================
# 3eme bloc : bloc SOURCES
#====================================================================
# definition des differentes sources qui seront dans le bloc SOURCES
#-------------------------------------------------------------------



SOURCE = OPER ( nom = "SOURCE",
                op = None,
                repetable = 'n',
                UIinfo = { "groupes" : ( "2) Proprietes", ) },
                ang = "source definition", 
                fr = u"définition d'une source", 
                sd_prod = source,
#                regles = (UN_PARMI('STRANDED_INDUCTOR','HPORT','EPORT'), # choix d'un type de source
#                          UN_PARMI('WAVEFORM_CONSTANT','WAVEFORM_SINUS'), # choix d'une forme de source
                        

#----------------------------------------------------------
# sous bloc niveau 1 : stranded inductor source 
##---------------------------------------------------------
        Type=SIMP(statut='o', 
                                typ='TXM', 
                                into=("STRANDED_INDUCTOR", "HPORT", "EPORT"), 
                                ang = "Source type", 
                                fr = u"Type de source", 
                                ), 

            STRANDED_INDUCTOR_properties = BLOC (condition="Type=='STRANDED_INDUCTOR'", 
                STRANDED_INDUCTOR = FACT(statut='o',
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
                                ), 
            ),# FIN de FACT STRANDED_INDUCTOR
         HPORT_properties = BLOC (condition="Type=='HPORT'",
                HPORT = FACT(statut='o',
                             ang="Magnetic port source",
                             fr=u"source de type port magnétique",
                             TYPE = SIMP (statut="o",
                                          typ="TXM",
                                          into=("VOLTAGE","CURRENT"),
                                          fr= u"source de type tension ou courant",
                                          ang="voltage or current source type",
                                         ),
                ), 
            ),# FIN de FACT HPORT
         EPORT_properties = BLOC (condition="Type=='EPORT'",
                EPORT = FACT(statut='o',
                             ang="Electric port source",
                             fr=u"source de type port électrique",
                             TYPE = SIMP (statut="o",
                                          typ="TXM",
                                          into=("VOLTAGE","CURRENT"),
                                          fr= u"source de type tension ou courant",
                                          ang="voltage or current source type",
                                         ),
                ), 
            ),# FIN de FACT EPORT
            
            Signal=SIMP(statut='o', 
                                typ='TXM', 
                                into=("WAVEFORM_CONSTANT", "WAVEFORM_SINUS"), 
                                ang = "Signal type, i.e., source evolution shape", 
                                fr = u"Type de signal, i.e., forme de la source", 
                                ), 
           WAVEFORM_CONSTANT_properties = BLOC (condition="Signal=='WAVEFORM_CONSTANT'", 
                WAVEFORM_CONSTANT = FACT(statut='o',
                                         ang="constant source",
                                         fr=u"source constante",
                                         AMPLITUDE = SIMP (statut="o",
                                                           typ="R", 
                                                           defaut=1,
                                                           ang = "enter the source magnitude value, in A or V units",
                                                           fr = u"saisir la valeur de l'amplitude de la source, en unités A ou V",
                                                          ),
                ),
            ),# FIN de FACT WAVEFORM_CONSTANT
            
            WAVEFORM_SINUS_properties = BLOC (condition="Signal=='WAVEFORM_SINUS'", 
                WAVEFORM_SINUS = FACT(statut='o',
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
                                                        defaut=0.0,
                                                        ang = "enter the source frequency value, in Hz units",
                                                        fr = u"saisir la valeur de la fréquence de la source, en Hz",
                                                       ),
                                      PHASE = SIMP (statut="o",
                                                    typ="R", 
                                                    defaut=0.0,
                                                    ang = "enter the source phase value, in degrees units",
                                                    fr = u"saisir la valeur de la phase de la source, en degrés",
                                                   ),
                ), 
            ),# FIN de FACT WAVEFORM_SINUS

       
)# Fin OPER SOURCE


STRANDED_INDUCTOR_GEOMETRY=OPER(nom="STRANDED_INDUCTOR_GEOMETRY",
            op=None,
            repetable = 'n',
            sd_prod=stranded_inductor_geometry,
            UIinfo = { "groupes" : ( "2) Proprietes", ) },
            ang = "Geometry properties (shape, direction, etc.) for this stranded inductor",
            fr = u"Propriétés géométriques de cet inducteur bobiné, e.g., forme, direction, sens",
            
            Forme=SIMP(statut='o', typ="TXM", into=("Droit", "Circulaire"), 
                                ang = "Stranded inductor shape. Straight or circular.",
                                fr = u"Forme de l'inducteur bobiné (complet ou morceau) : droit ou circulaire.",
                                ), 
            Propriete= BLOC (condition="Forme=='Circulaire'",
                    Centre=SIMP(statut='o',typ='R',min=3,max=3,
                                        ang = "Circular stranded inductor rotation center (cartesian coordinates).",
                                        fr = u"Centre de rotation, en coordonnées cartésiennes, de l'inducteur bobiné (complet ou morceau) circulaire.",
                                        ),  
                    ),               
            Direction=SIMP(statut='o',typ='R',min=3,max=3,
                                        ang = "Stranded inductor direction (or rotation) axis for the straight (circular) inductor (cartesian coordinates).",
                                        fr = u"Axe indiquant la direction de l'inducteur bobiné droit, ou l'axe de rotation (support : Centre) de l'inducteur circulaire, en coordonnées cartésiennes.",
                                        ),  
            Section=SIMP(statut='o', typ='R',
                                        ang = "Stranded inductor section (m^2).",
                                        fr = u"Section de l'inducteur bobiné, en m^2.",
                                        ),  
)              

#=========================================================
# création d'une macro pour traiter les INCLUDE
#
#----------------------------------------------------------

INCLUDE = MACRO ( nom = "INCLUDE",
                 op = None,
                 UIinfo = { "groupes" : ( "3) Bibliotheque", ) },
                 sd_prod = opsCarmel.INCLUDE,
                 op_init = opsCarmel.INCLUDE_context,
                 fichier_ini = 1,
                ang = "Used in order to add external material, source, etc. libraries to the study.",
                fr = u"Permet d'utiliser des bibliothèques de matériaux, sources, etc., dans l'étude.",
 
   FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'comm Files (*.comm);;All Files (*)',),
                     fr = u"Emplacement du fichier (chemin absolu ou relatif) contenant la bibliothèque des matériaux, etc.",
                    ang = "material library file (full or relative path)",
                     ),
  
 ) # Fin MACRO 

MESHGROUP  = OPER (nom = "MESHGROUP",
                op = None,
                repetable = 'n',
                UIinfo= {"groupes":("4) Maillage",)},
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
              Domaine = SIMP (statut="f", 
                        typ=(grmaille, 'TXM'), 
                        defaut="default", 
                        ang="Domain used with stranded inductors or topological holes.",
                        fr =u"Domaine utilisé par les inducteurs bobinés ou les trous topologiques.",
                        ), 

              MATERIAL =  SIMP (statut="f",
                        typ=(material),
                        ang="name of the linked real or imaginary material",
                        fr =u"nom du matériau réel ou imaginaire associé",
                                ), 
              SOURCE =  SIMP (statut="f",
                        typ=(source,),
                        ang="name of the linked source",
                        fr =u"nom de la source associée",
                                ), 
               STRANDED_INDUCTOR_GEOMETRY = SIMP ( statut="f", 
                       typ=(stranded_inductor_geometry), 
                        ang="name of the linked stranded inductor geometry",
                        fr =u"nom de la géométrie d'inducteur bobiné associée",
                                                   )
                      )

# --------------------------------------------------
# definition de macro-groupe de mailles
# il est associe a un  materiau, source ou inducteur bobiné en morceaux
#---------------------------------------------------

MACRO_GROUPE = OPER (nom="MACRO_GROUPE", 
                    op=None, 
                    repetable='n', 
                    sd_prod=macro_groupe, 
                    UIinfo = { "groupes" : ( "4) Maillage", ) },  
                    fr=u"Macro-groupe = liste de groupes de maillage, e.g., inducteur bobiné en morceaux.", 
                    ang=u"Macro-groupe = liste of mesh groups, e.g., stranded inductor defined as several parts.", 
                    regles =(
                             EXCLUS ('MATERIAL','SOURCE'),
                           ),
              Domaine = SIMP (statut='f',
                                            typ=(grmaille, 'TXM'), 
                                            defaut="default", 
                                            ang="Domain used with stranded inductors or topological holes.",
                                            fr =u"Domaine utilisé par les inducteurs bobinés ou les trous topologiques.",
                                           ),  

              MATERIAL =  SIMP (statut="f",
                                            typ=(material,),
                                            ang="name of the linked real or imaginary material",
                                            fr =u"nom du matériau réel ou imaginaire associé",
                                    ), 
              SOURCE =  SIMP (statut="f",
                                        typ=(source,),
                                        ang="name of the linked source",
                                        fr =u"nom de la source associée",
                                    ), 
               LISTE_MESHGROUP=SIMP(statut='f',# facultatif pour l'acquisition automatique des groupes du maillage
                                                        typ=(grmaille,),
                                                        min=1,max=100,                     
                                                        ang="Ordered list of associated mesh groups, e.g., stranded inductor parts or topological hole parts.",
                                                        fr =u"Liste ordonnée de groupes de maillage associés entre eux, e.g., morceaux d'un inducteur bobiné ou d'un trou topologique.",
                                                        ), 
) # Fin OPER
