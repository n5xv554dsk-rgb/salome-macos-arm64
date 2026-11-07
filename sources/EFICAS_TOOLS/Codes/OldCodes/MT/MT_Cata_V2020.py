## -*- coding: utf-8 -*-
#
## --------------------------------------------------
## debut entete
## --------------------------------------------------
#
# 20120510 : suppression de la valeur par defaut de MATERIAU->PARAMETRES_MAT->NU
#            changement du nom MATERIAU->PARAMETRES_MAT->MASS_VOL en MATERIAU->PARAMETRES_MAT->RHO
#
# 20120619 : changement ordre d'affichage des macros -> ordre de crÃ©ation
# 20120725 : modification definition (matrices A,K,M) palier et support
# 20130411 : ajout elements dans palier generalise (mail tdg + comm tdg)
#
# todo : supprimer les noeuds -> definir les elements par leur longueur
#
#
#
#
#








from Accas import *
#

import types
class Tuple:
  def __init__(self,ntuple):
    self.ntuple=ntuple

  def __convert__(self,valeur):
    if type(valeur) == bytes:
      return None
    if len(valeur) != self.ntuple:
      return None
    return valeur

  def info(self):
    return "Tuple de %s elements" % self.ntuple

  __repr__=info
  __str__=info


#CONTEXT.debug = 1
VERSION_CATALOGUE="2019.0.0";
JdC = JDC_CATA(code = 'MT',
               execmodul = None,
               regles = (AU_MOINS_UN ( 'LIGNE_ARBRE',),
                         AU_PLUS_UN ( 'LIGNE_ARBRE',)),
               ) # Fin JDC_CATA

class Direction(ASSD): pass
class Materiau(ASSD): pass
#class Masse(ASSD): pass
class Zone(ASSD): pass
class Palier(ASSD): pass
#class Masse(ASSD): pass
#class ConditionsAuxLimites(ASSD): pass
class LigneArbre(ASSD): pass
class Support(ASSD): pass
class Butee(ASSD): pass
class PalTor(ASSD):pass
#class Noeud(ASSD): pass

## def macro_noeuds(self, NOEUD, **args):
##     """
##     """
##     if NOEUD is not None:
##         self.type_sdprod(NOEUD, Noeud)
##         pass
##     else:
##         raise AsException("Impossible de typer les concepts resultats")
    
##     return Noeuds

############################# MATERIAUX ########################################
# @todo
# introduction manuelle => dans ce cas l'utilisateur definit le
# materiau comme ci-dessous
# recuperation depuis une bibliothÃšque de materiau => sera specife
# plus tard
MATERIAUX = MACRO(nom = 'MATERIAUX',
                 op = None,
                 sd_prod = Materiau,
                 reentrant = 'n',
                 UIinfo = {"groupes": ("Machine tournante",)},
                 fr = "Renseignement des caracteristiques des materiaux",
                 TYPE_INTRO = SIMP(statut='o', 
                                   fr = "Mode de description des caracteristiques des materiaux",
                                   typ='TXM',
                                   into=('MANUELLE','FICHIER'),
                                   min=1,
                                   max=1,
                                   defaut='MANUELLE',
                                   ), # end TYPE_INTRO
                 PARAMETRES_MAT = BLOC(condition = "((TYPE_INTRO == 'MANUELLE') )",
                                       #MASS_VOL  = SIMP(statut='o', typ='R', min=1, max=1, fr='masse volumique'),
                                       fr = "Saisie manuelle des caracteristiques du materiau",
                                       RHO = SIMP(statut='o',
                                                  typ='R',
                                                  min=1,
                                                  max=1,
                                                  fr='Masse volumique (kg/m**3)',
                                                  ), # end RHO
                                       E = SIMP(statut='o',
                                                typ='R',
                                                min=1,
                                                max=1,
                                                fr="Module d'Young (Pa)",
                                                ), # end E
                                       NU = SIMP(statut='o', 
                                                 typ='R',
                                                 min=1,
                                                 max=1,
                                                 val_min=-1.0,
                                                 val_max=0.5,
                                                 fr='Coefficient de cisaillement (-1.0 <= NU <= 0.5)',
                                                 ), # end NU
                                       ALPHA = SIMP(statut='f', 
                                                    typ='R',
                                                    min=1,
                                                    max=1,
                                                    fr = "Coefficient permettant de construire une matrice d'amortissement visqueux proportionnel a la rigidite",
                                                    ), # end ALPHA
                                       BETA = SIMP(statut='f',
                                                   typ='R', 
                                                   min=1, 
                                                   max=1, 
                                                   fr = "Coefficient permettant de construire une matrice d'amortissement visqueux proportionnel a la masse",
                                                   ), # end BETA
                                       GAMMA = SIMP(statut='f',
                                                   typ='R',
                                                   min=1,
                                                   max=1,
                                                   fr = "Coefficient d'amortissement hysteretique permettant de definir le module d'Young complexe",
                                                   ), # end GAMMA
                                       ), # end PARAMETRES_MAT
                   FICHIER_MAT = BLOC(condition = "((TYPE_INTRO == 'FICHIER') )",
                                      MATERIAU_CATALOGUE = SIMP(statut='o',
                                  fr="Fichier decrivant les caracteristiques materiaux (format decrit dans le Manuel Utilisateur)",
                                                              min=1, 
                                  max=1, 
                                  typ=('Fichier','Fichier materiau (*.*)'), 
                                  ), # end MATERIAU_CATALOGUE
                                     ), # end FICHIER_MAT
                                     #SIMP(typ=('Fichier','JDC Files (*.comm)'),docu='',min=1,max=1,statut='o',defaut=None)
                 ) # end MATERIAU



############################# ZONES ########################################
ZONE = MACRO(nom = 'ZONE',
             op = None,
             sd_prod = Zone,
             reentrant = 'n',
             UIinfo = {"groupes":("Machine tournante",)},
             fr = "Description d'une zone (comportant noeuds et elements, et en option masses ponctuelles et fissures)",
             regles = (AU_MOINS_UN("ELEMENTS")),
             fenetreIhm='deplie1Niveau',
             MASSE = FACT(statut='f',
                          min=0,
                          max='**',
              fr = "Description des masses ponctuelles",
              #POSITION = SIMP(statut='o',
              NOEUD = SIMP(statut='o', 
                      typ='TXM', 
                      defaut=None, 
                      fr = "Definition de la position axiale de la masse (label du noeud de la ligne d'arbres en vis-a-vis)",
                      ), # end POSITION
              TYPE_MASSE = SIMP(statut='o', 
                        typ='TXM', 
                        fr = "Renseignement du type de masse consideree",
                        into=('DISQUE','AILETTE','QUELCONQUE'),
                        ), # end TYPE_MASSE
              DISQUE = BLOC(condition = "((TYPE_MASSE == 'DISQUE') )",
                            TYPE_SAISIE = SIMP(statut='o',
                                               typ='TXM',
                                               fr = "Type de saisie des parametres du DISQUE",
                                               into = ('MECANIQUE','GEOMETRIQUE'),
                                               defaut = 'MECANIQUE'
                                               ), # end TYPE_SAISIE
                            PARAMETRES_MECANIQUE = BLOC(condition = "TYPE_SAISIE == 'MECANIQUE'",
                                    PARAMETRES = FACT(statut = 'o',
                                              fr = "Parametres mecaniques pour un DISQUE",
                                              MASSE = SIMP(statut='o',
                                                       typ='R',
                                                   val_min=0,
                                                   fr = "Masse du DISQUE (kg)",
                                                   ), # end MASSE_DISQUE
                                              INERTIEX = SIMP(statut='o', 
                                                      typ='R',
                                                      fr = "Inertie du DISQUE en X (kg.m**2)",
                                                      ), # end INERTIEX
                                              INERTIEY = SIMP(statut='o', 
                                                      typ='R',
                                                      fr = "Inertie du DISQUE en Y (kg.m**2)",
                                                      ), # end INERTIEY
                                              INERTIEZ = SIMP(statut='o', 
                                                      typ='R',
                                                      fr = "Inertie du DISQUE en Z (axe de rotation de la ligne d'arbres)(kg.m**2)",
                                                      ), # end INERTIEZ
                                              ) # end PARAMETRES_DISQUE_M
                                                            ), # end PARAMETRES_MECANIQUE
                                PARAMETRES_GEOMETRIQUE = BLOC(condition = "TYPE_SAISIE == 'GEOMETRIQUE'",
                                    PARAMETRES = FACT(statut = 'o',
                                              fr = "Parametres geometriques pour un DISQUE",
                                              DIAMETRE_EXT = SIMP(statut='o',
                                                      typ='R',
                                                      val_min=0,
                                                      fr = "Diametre exterieur du DISQUE (m)",
                                                      ), # end MASSE_DISQUE
                                              DIAMETRE_INT = SIMP(statut='o', 
                                                          typ='R',
                                                          fr = "Diametre interieur du DISQUE (m). Verifier le diametre exterieur du rotor avant saisie",
                                                          ), # end INERTIEX
                                              EPAISSEUR = SIMP(statut='o', 
                                                       typ='R',
                                                       val_min=0,
                                                       fr = "Epaisseur (dans la direction axiale) du DISQUE (m)",
                                                       ), # end INERTIEY
                                              MATERIAU = SIMP(statut='o', 
                                                      typ=Materiau,
                                                      fr = "Materiau constituant le DISQUE (doit avoir ete defini via une entree MATERIAUX)",
                                                      ), # end INERTIEZ
                                              ) # nd PARAMETRES_DISQUE_G
                                                            ), # end PARAMETRES_MECANIQUE
                    ), # end DISQUE
              AILETTE = BLOC(condition = "((TYPE_MASSE == 'AILETTE') )",
                     TYPE_SAISIE = SIMP(statut='o',
                                                typ='TXM',
                                                fr = "Type de saisie des parametres de la rangee d'AILETTES",
                                                into = ('MECANIQUE','GEOMETRIQUE'),
                                                defaut = 'MECANIQUE'
                                                ), # end TYPE_SAISIE
                             PARAMETRES_MECANIQUE = BLOC(condition = "TYPE_SAISIE == 'MECANIQUE'",
                                     PARAMETRES = FACT(statut = 'o',
                                                   fr = "Parametres mecaniques de la rangee d'AILETTES",
                                               MASSE = SIMP(statut='o',
                                                            typ='R',
                                                        val_min=0,
                                                        fr = "Masse de la rangee d'AILETTES (kg)",
                                                        ), # end MASSE_AILETTE
                                               INERTIEX = SIMP(statut='o', 
                                                       typ='R',
                                                       fr = "Inertie de la rangee d'AILETTES en X (kg.m**2)",
                                                       ), # end INERTIEX
                                               INERTIEY = SIMP(statut='o', 
                                                           typ='R',
                                                           fr = "Inertie de la rangee d'AILETTES en Y (kg.m**2)",
                                                       ), # end INERTIEY
                                               INERTIEZ = SIMP(statut='o', 
                                                       typ='R',
                                                       fr = "Inertie de la rangee d'AILETTES en Z (axe de rotation de la ligne d'arbres) (kg.m**2)",
                                                       ), # end INERTIEZ
                                               ) # nd PARAMETRES_AILETTE_M
                                                              ), # end PARAMETRES_MECANIQUE
                                   PARAMETRES_GEOMETRIQUE = BLOC(condition = "TYPE_SAISIE == 'GEOMETRIQUE'",
                                         PARAMETRES = FACT(statut = 'o',
                                                   fr = "Parametres geometriques d'une AILETTE",
                                                   MASSE_AILETTE = SIMP(statut='o',
                                                                        typ='R',
                                                        val_min=0,
                                                        fr = "Masse d'une AILETTE (kg)",
                                                        ), # end MASSE_AILETTE
                                               RAYON = SIMP(statut='o', 
                                                    typ='R',
                                                    val_min=0,
                                                    fr = "Distance entre le pied de l'AILETTE et le centre de rotation (m). Verifier le diametre exterieur du rotor avant saisie",
                                                    ), # end RAYON
                                               HAUTEUR = SIMP(statut='o',
                                                              typ='R',
                                                          val_min=0,
                                                          fr = "Distance entre les deux extremites de l'AILETTE (m)",
                                                          ), # end HAUTEUR
                                               BASE = SIMP(statut='o', 
                                                           typ='R',
                                                       val_min=0,
                                                       fr = "Largeur du pied de l'AILETTE (m)",
                                                       ), # end BASE
                                               NOMBRE = SIMP(statut='o',
                                                             typ='I',
                                                             val_min=1,
                                                             fr = "Nombre d'AILETTES dans la rangee",
                                                             ),
                                               ) # end PARAMETRES_DISQUE
                                                                 ), # end PARAMETRES_MECANIQUE
                       ), # end AILETTE
                QUELCONQUE = BLOC(condition = "((TYPE_MASSE == 'QUELCONQUE') )",
                                  #TYPE_SAISIE = SIMP(statut='c',typ='TXM',defaut="MECANIQUE"), # cf 20120622 test : mot-clÃ© cachÃ©
                          PARAMETRES = FACT(statut = 'o',
                                fr = "Parametres pour masse de type QUELCONQUE",
                                MASSE = SIMP(statut='o', 
                                         typ='R',
                                         val_min=0,
                                         fr = "Masse (m)",
                                         ), # end MASSE
                                INERTIEX = SIMP(statut='o', 
                                        typ='R',
                                        fr = "Inertie en X (kg.m**2)",
                                           ), # end INERTIEX
                                INERTIEY = SIMP(statut='o', 
                                        typ='R',
                                        fr = "Inertie en Y (kg.m**2)",
                                           ), # end INERTIEY
                                INERTIEZ = SIMP(statut='o', 
                                        typ='R',
                                        fr = "Inertie en Z (axe de rotation de la ligne d'arbres) (kg.m**2)",
                                           ), # end INERTIEZ
                                ), # end PARAMETRES_QUELCONQUE
                          ), # end QUELCONQUE
             ),  # end MASSE
             NOEUDS = SIMP(fr = "Definition des noeuds de la zone (2 noeuds minimum)",
                           fenetreIhm='Tableau',
                           homo = ('NOM','POSITION_AXIALE'),
                           statut='o',
                           min=2, 
                           max='**',
                           typ = Tuple(2),
                           validators=VerifTypeTuple(('TXM','R')),
                           ), # end NOEUDS                 
             ELEMENTS = FACT(fr = "Definition des elements poutre de la zone",
                             statut='o',
                             min=1,
                             max='**',
                             NOM = SIMP(statut='o',
                                        typ='TXM',
                                        fr="Label de l'element"
                                        ), # end NOM
                             NOEUD_DEBUT = SIMP(statut='o',
                                          typ='TXM',
                                          fr= "Noeud de debut de l'element poutre (label d'un noeud)"
                                          ), # end DEBUT
                             NOEUD_FIN = SIMP(statut='o',
                                        typ='TXM',
                                        fr= "Noeud de fin de l'element poutre (label d'un noeud)"
                                        ), # end FIN
                             RAFFINEMENT = SIMP(fr = "Choix de raffiner l'element poutre",
                                              statut='o',
                                              typ='TXM',
                                              into=('OUI','NON'),
                                              defaut='NON'
                                              ), # end RAFFINEMENT
                             PARAM_RAFFINEMENT = BLOC(fr = "Nombre de points supplementaires a ajouter pour le raffinement (nombre elements : 1 -> nb points + 1)",
                                                    condition = "((RAFFINEMENT == 'OUI') )",
                                                    NB_POINTS_SUPPL = SIMP(statut='o', 
                                                                           typ='I'
                                                                           ), # end NB_POINTS_SUPPL
                                                    ), # end PARAM_RAFFINEMENT
                             MATERIAU = SIMP(statut='o',
                                             typ=Materiau,
                                             fr= "Materiau constituant l'element poutre (doit avoir ete defini via une entree MATERIAUX)"
                                             ), # end MATERIAU
                 SECTION_MASSE = FACT(statut='o',
                                                  fr = "Section a partir de laquelle est determinee la masse de l'element poutre",
                                                  TYPE_SECTION = SIMP(statut='o',
                                                                      fr = "Choix d'une section de dimensions constantes ou variables",
                                                                      typ='TXM',
                                                                      into=('CONSTANTE','VARIABLE'),
                                                                      defaut='CONSTANTE',
                                                                      ), # end TYPE_SECTION
                                                  DIAM_EXTERN_DEBUT = SIMP(statut='o',
                                                                           typ='R',
                                                                           fr = "Diametre exterieur en debut d'element poutre (m)",
                                                                           ), # end DIAM_EXTERN_DEBUT
                                                  DIAM_INTERN_DEBUT = SIMP(statut='o',
                                                                           typ='R',
                                                                           fr = "Diametre interieur en debut d'element poutre (m) (different de 0 si element creux)",
                                                                           ), # end DIAM_INTERN_DEBUT
                                                  PARAMETRE_SECT_VAR = BLOC(condition = "((TYPE_SECTION == 'VARIABLE') )",
                                                                            fr = "Renseignement des dimensions de fin d'element (variation lineaire entre le debut et la fin)",
                                                                            DIAM_EXTERN_SORTIE = SIMP(statut='o',
                                                                                                      typ='R',
                                                                                                      fr = "Diametre exterieur en fin d'element (m)",
                                                                                                      ), # end DIAM_EXTERN_SORTIE
                                                                            DIAM_INTERN_SORTIE = SIMP(statut='o',
                                                                                                      typ='R',
                                                                                                      fr = "Diametre interieur en fin d'element (m)",
                                                                                                      ), # DIAM_INTERN_SORTIE
                                                                            ),
                                                  ), # end SECTION_MASSE
                             SECTION_RIGIDITE = FACT(statut='f',
                                                     fr = "Section a partir de laquelle est determinee la rigidite de l'element poutre",
                                                     TYPE_SECTION = SIMP(statut='o', 
                                                                         fr = "Choix d'une section de dimensions constantes ou variables",
                                                                         typ='TXM', 
                                                                         into=('CONSTANTE','VARIABLE'), 
                                                                         defaut='CONSTANTE',
                                                                         ), # end TYPE_SECTION
                                                     DIAM_EXTERN_DEBUT = SIMP(statut='o',
                                                                              typ='R',
                                                                              fr = "Diametre exterieur en debut d'element poutre (m)",
                                                                              ), # end DIAM_EXTERN_DEBUT
                                                     DIAM_INTERN_DEBUT = SIMP(statut='o',
                                                                              typ='R',
                                                                              fr = "Diametre interieur en debut d'element poutre (m) (different de 0 si element creux)",
                                                                              ), # end DIAM_INTERN_DEBUT
                                                     PARAMETRE_SECT_VAR = BLOC(condition = "((TYPE_SECTION == 'VARIABLE') )",
                                                                               fr = "Renseignement des dimensions de fin d'element (variation lineaire entre le debut et la fin)",
                                                                               DIAM_EXTERN_SORTIE = SIMP(statut='o',
                                                                                                         typ='R',
                                                                                                         fr = "Diametre exterieur en fin d'element (m)",
                                                                                                         ), # end DIAM_EXTERN_SORTIE
                                                                               DIAM_INTERN_SORTIE = SIMP(statut='o',
                                                                                                         typ='R',
                                                                                                         fr = "Diametre interieur en fin d'element (m)",
                                                                                                         ), # end DIAM_INTERN_SORTIE
                                                                               ), # end PARAMETRE_SECT_VAR
                                                     ), # end SECTION_RIGIDITE
                             ),  # end ELEMENTS
                             FISSURE = FACT(statut='f',
                                            fr="Description d'une fissure sur un noeud de l'arbre (licite uniquement si les elements poutres a gauche et a droite du noeud ont des sections masse et rigidite constantes)",
                                            MATERIAU = SIMP(statut='o',
                                                            typ=Materiau,
                                                            fr="Materiau a la position de la fissure (doit avoir ete defini via une entree MATERIAUX)"
                                                           ), # end MATERIAU
                                            NOEUD_FISSURE = SIMP(statut='o',
                                                                 typ='TXM',
                                                                 fr="Label du noeud ou est positionnee la fissure",
                                                                 ), # end POSITION_FISSURE
                                            ORIENTATION_FISSURE = SIMP(statut='o',
                                                                       typ='R',
                                                                       fr="Angle initial du fond de fissure par rapport à sa définition dans la loi de comportement de fissure (0. par defaut)(degres)",
                                                                       ), # end ORIENTATION_FISSURE
                                            FICHIER_RAIDEUR = SIMP(statut='o',
                                                                   typ=('Fichier','Fichier loi de raideur (*.*)'),
                                                                   fr="Fichier contenant la loi de comportement en raideur de la fissure",
                                                                   ), # end FICHIER_RAIDEUR
                                            DIAMETRE = SIMP(statut='o',
                                                            typ='R',
                                                            fr="Diametre du rotor a l'emplacement de la fissure (m)",
                                                            ), # end DIAMETRE
                                            ), # end FISSURE

            )  # end ZONE
                
############################# PALIERS ########################################
PALIER = MACRO(nom = 'PALIER',
               op = None,
               sd_prod = Palier,
               reentrant = 'n',
               UIinfo = {"groupes":("Machine tournante",)},
               fr = "Description d'un palier radial",
               POSITION = SIMP(statut='o', 
                               typ='R', 
                               defaut=0.0, 
                               fr = "Position axiale (absolue) du palier radial (m)",
                               ), # end POSITION
               NOM_NOEUD = SIMP(statut='f',
                                typ='TXM',
                                fr="Nom du noeud dans le cas où plusieurs noeuds se trouvent à la même position axiale"),
               TYPE_PALIER = SIMP(statut='o', 
                                  fr = "Type de palier radial",
                                  typ='TXM', 
                                  into=('PALIER LINEAIRE','PALIER NON-LINEAIRE','LAME FLUIDE'),
                                  ), # end TYPE_PALIER
           PALIER_LINEAIRE = BLOC(condition = "((TYPE_PALIER == 'PALIER LINEAIRE') )", 
                          fr = "Description d'un palier radial lineaire",
                                      TYPE_SAISIE = SIMP(statut='o', 
                            fr = "Mode de description des caracteristiques du palier radial lineaire",
                                                        typ='TXM', 
                            into=('MANUELLE', 'CATALOGUE'),
                            ), # end TYPE_SAISIE
                      MANUELLE = BLOC(condition = "((TYPE_SAISIE == 'MANUELLE') )",
                                      fr = "Saisie manuelle des caracteristiques du palier radial lineaire",
                                                      CARAC_PALIER = FACT(statut = 'o',max='**',fr = "Caracteristiques du palier par vitesse de rotation de la ligne d'arbres",
                                                              VITESSE_ROTATION = SIMP(statut='o',
                                                                                      typ='R',
                                                                                      fr= "Vitesse de rotation (tr/min)",
                                                                                      ), # end VITESSE_ROTATION
                                  SYME = SIMP(statut = 'o',
                                      typ = 'TXM',
                                      max = 1,
                                      fr = "Symetrie des matrices du palier radial lineaire (KXY=KYX et AXY=AYX)",
                                      into = ('OUI','NON'),
                                      defaut = 'OUI',
                                      ), # end SYME
                                  RIGIDITE_NS = BLOC(condition="(SYME=='NON')",
                                          RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques non-symetriques de rigidite du palier radial lineaire",
                                          KXX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXX dans la matrice de rigidite (N/m)",
                                            ),# end KXX
                                          KXY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXY dans la matrice de rigidite (N/m)",
                                            ),# end KXY
                                          KYX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYX dans la matrice de rigidite (N/m)",
                                            ),# end KYX
                                          KYY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYY dans la matrice de rigidite (N/m)",
                                            ),# end KYY
                                                  ), # end RIGIDITE
                                          ), # end RIGIDITE_S
                                  RIGIDITE_S = BLOC(condition="(SYME=='OUI')",
                                          RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de rigidite du palier radial lineaire",
                                          KXX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXX dans la matrice de rigidite (N/m)",
                                            ),# end KXX
                                          KXY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXY dans la matrice de rigidite (N/m)",
                                            ),# end KXY
                                          KYY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYY dans la matrice de rigidite (N/m)",
                                            ),# end KYY
                                                  ), # end RIGIDITE
                                          ), # end RIGIDITE_NS
                                  AMORTISSEMENT_NS = BLOC(condition="(SYME=='NON')",
                                          AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques non-symetriques d'amortissement du palier radial lineaire",
                                          AXX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXX
                                          AXY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXY
                                          AYX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYX
                                          AYY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYY
                                                      ), # end AMORTISSEMENT
                                            ), # end AMORTISSEMENT_NS
                                  AMORTISSEMENT_S = BLOC(condition="(SYME=='OUI')",
                                          AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques symetriques d'amortissement du palier radial lineaire",
                                          AXX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXX
                                          AXY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXY
                                          AYY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYY
                                                      ), # end AMORTISSEMENT
                                            ), # end AMORTISSEMENT_S
                                                          ), # end CARAC_PALIER
                              ), # end MANUELLE
                              CATALOGUE = BLOC(condition = "((TYPE_SAISIE == 'CATALOGUE') )",
                                      fr = "Renseignement des fichiers contenant les caracteristiques du palier radial lineaire",
                                                                      CATALOGUE_AMORTISSEMENT = SIMP(statut='o',
                                                  min=1, 
                                                  max=1, 
                                                  typ='Fichier', 
                                                  fr="Fichier decrivant les caracteristiques d'amortissement (N.s/m) du palier radial lineaire (format decrit dans le Manuel Utilisateur)",
                                                  ), # end CATALOGUE_AMORTISSEMENT
                                      CATALOGUE_RIGIDITE = SIMP(statut='o',
                                                  min=1, 
                                                  max=1, 
                                                  typ='Fichier', 
                                                  fr="Fichier decrivant les caracteristiques de rigidite (N/m) du palier radial lineaire (format decrit dans le Manuel Utilisateur)",
                                                  ), # end CATALOGUE_RIGIDITE
                                      ), # end CATALOGUE
                         ), # end PALIER_LINEAIRE
                  LAME_FLUIDE = BLOC(condition = "((TYPE_PALIER == 'LAME FLUIDE') )",
                                      fr = "Description d'une lame fluide",
                                                  TYPE_SAISIE = SIMP(statut='o', 
                            fr = "Mode de description des caracteristiques de la lame fluide",
                                                        typ='TXM', 
                                                        defaut = 'MANUELLE',
                            #into=('MANUELLE', 'CATALOGUE'), #Fonctionnalite catalogue non encore implementee
                            into=('MANUELLE',),
                            ), # end TYPE_SAISIE
                                  MANUELLE = BLOC(condition = "((TYPE_SAISIE == 'MANUELLE') )",
                                                fr = "Saisie manuelle des caracteristiques de la lame fluide",
                                                                CARAC_PALIER = FACT(statut = 'o',max='**',fr = "Caracteristiques de la lame fluide par vitesse de rotation de la ligne d'arbres",
                                      SYME = SIMP(statut = 'o',
                                        typ = 'TXM',
                                        max = 1,
                                        fr = "Symetrie des matrices de la lame fluide  (KXY=KYX et AXY=AYX)",
                                        into = ('OUI','NON'),
                                        defaut = 'OUI',
                                        ), # end SYME
                                    RIGIDITE_NS = BLOC(condition="(SYME=='NON')",
                                            RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques non-symetriques de rigidite de la lame fluide",
                                          KXX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXX dans la matrice de rigidite (N/m)",
                                            ),# end KXX
                                          KXY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXY dans la matrice de rigidite (N/m)",
                                            ),# end KXY
                                          KYX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYX dans la matrice de rigidite (N/m)",
                                            ),# end KYX
                                          KYY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYY dans la matrice de rigidite (N/m)",
                                            ),# end KYY
                                            ),# end RIGIDITE
                                            ), # end RIGIDITE_NS
                                    RIGIDITE_S = BLOC(condition="(SYME=='OUI')",
                                            RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de rigidite de la lame fluide",
                                          KXX = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXX dans la matrice de rigidite (N/m)",
                                            ),# end KXX
                                          KXY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KXY dans la matrice de rigidite (N/m)",
                                            ),# end KXY
                                          KYY = SIMP(statut = 'o',
                                            typ = 'R',
                                            max = 1,
                                            fr = "Valeur de KYY dans la matrice de rigidite (N/m)",
                                            ),# end KYY
                                                  ), # end RIGIDITE
                                            ), # end RIGIDITE_S
                                    AMORTISSEMENT_NS = BLOC(condition="(SYME=='NON')",
                                            AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques non-symetriques d'amortissement de la lame fluide",
                                          AXX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXX
                                          AXY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXY
                                          AYX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYX
                                          AYY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYY
                                                      ), # end AMORTISSEMENT
                                                ), # end AMORTISSEMENT
                                            #), # end AMORTISSEMENT_NS
                                    AMORTISSEMENT_S = BLOC(condition="(SYME=='OUI')",
                                            AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques symetriques d'amortissement de la lame fluide",
                                          AXX = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXX dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXX
                                          AXY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AXY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AXY
                                          AYY = SIMP(statut = 'o',
                                                  typ = 'R',
                                                  max = 1,
                                                  fr = "Valeur de AYY dans la matrice d'amortissement (N.s/m)",
                                                ),# end AYY
                                                      ), # end AMORTISSEMENT
                                                ), # end AMORTISSEMENT_S
                                    MASSE_NS = BLOC(condition="(SYME=='NON')",
                                            MASSE=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques de masse de la lame fluide",
                                              MXX = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MXX dans la matrice de masse (kg)",
                                                    ),# end MXX
                                              MXY = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MXY dans la matrice de masse (kg)",
                                                    ),# end MXY
                                              MYX = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MYX dans la matrice de masse (kg)",
                                                    ),# end MYX
                                              MYY = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MYY dans la matrice de masse (kg)",
                                                    ),# end MYY
                                                ), # end MASSE
                                            ), # end MASSE_NS
                                    MASSE_S = BLOC(condition="(SYME=='OUI')",
                                        MASSE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de masse de la lame fluide",
                                              MXX = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MXX dans la matrice de masse (kg)",
                                                    ),# end MXX
                                              MXY = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MXY dans la matrice de masse (kg)",
                                                    ),# end MXY
                                              MYY = SIMP(statut = 'o',
                                                    typ = 'R',
                                                    max = 1,
                                                    fr = "Valeur de MYY dans la matrice de masse (kg)",
                                                    ),# end MYY
                                                ), # end MASSE
                                            ), # end MASSE_S
                                    VITESSE_ROTATION = SIMP(statut='o',
                                                typ='R',
                                                fr= "Vitesse de rotation (tr/min)",
                                                ), # end VITESSE_ROTATION
                                                               ), # end CARAC_PALIER
                              ), # end MANUELLE
                              #Fonctionnalite non encore implementee
                                                      CATALOGUE = BLOC(condition = "((TYPE_SAISIE == 'CATALOGUE') )",
                                    PALIERS_CATALOGUE = SIMP(statut='o',
                                                min=1, 
                                                max=1, 
                                                typ='Fichier', 
                                                fr="Format du fichier : CSV.",
                                                ), # end PALIERS_CATALOGUE
                                    ), # end CATALOGUE
                              
                        ), # end LAME_FLUIDE
                        PALIER_NON_LINEAIRE = BLOC(condition = "((TYPE_PALIER == 'PALIER NON-LINEAIRE') )",
                                                  fr = "Description d'un palier non-lineaire (licite uniquement en cas d'analyse de type 'TRANSITOIRE ACCIDENTEL'",
                                                                  TYPE = SIMP(statut='o',
                                                              typ='TXM',
                                                              into=('PAPANL','PAFINL','PAHYNL','PACONL'),
                                                              defaut=None,
                                                              fr="Type de palier non-lineaire parmi ceux proposes dans Edyos",
                                                              ), # end TYPE
                                                  REPERTOIRE_EDYOS = SIMP(statut='o',
                                                                          typ=('Repertoire'),
                                                                          defaut=None,
                                                                          fr="Repertoire 'CDC' du palier non-lineaire utilise (les fichiers Geometrie et Donnees doivent exister dans les repertoires parents respectivement de niveau 2 et 1 de CDC)",
                                                                          ), # end REPERTOIRE_EDYOS
                                                  ), # end PALIER_NON_LINEAIRE
               )  # end PALIER

PALIER_TORSION=MACRO(nom="PALIER_TORSION",
                     op=None,
                     sd_prod=PalTor,
                     reentrant='n',
                     UIinfo={"groupes":("Machine tournante",)},
                     fr="Description d'un palier de torsion",
                     POSITION = SIMP(statut='o',typ='R',defaut=0.0,fr = "Position axiale (absolue) du palier de torsion (m)",), # end POSITION
                     TYPE_SAISIE = SIMP(statut='o',typ='TXM',into=('MANUELLE',),fr = "Mode de description des caracteristiques du palier de torsion",), # end TYPE_SAISIE
                                   MANUELLE = BLOC(condition = "((TYPE_SAISIE == 'MANUELLE') )", 
                                              fr = "Saisie manuelle des caracteristiques du palier de torsion",
                                                          CARAC_PALIER = FACT(statut = 'o',max=1,fr = "Caracteristiques du palier par vitesse de rotation de l'arbre",
                                                                VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max='**',fr= "Liste des vitesses de rotation (tr/min)",), # end VITESSE_ROTATION          
                                                                KRZ = SIMP(statut = 'o',typ = 'R',min=1,max = '**',fr = "Liste des caracteristiques de rigidite (N/m) du palier de torsion en fonction de la vitesse de rotation",),# end KRZ
                                                                ARZ = SIMP(statut = 'o',typ = 'R',min=1,max = '**',fr = "Liste des caracteristiques d'amortissement (N.s/m) du palier de torsion  en fonction de la vitesse de rotation",),# end ARZ
                                                                MRZ = SIMP(statut = 'f',typ = 'R',min=1,max = '**',fr = "Liste des caracteristiques de masse ajoutee (kg) du palier de torsion  en fonction de la vitesse de rotation",),# end MRZ                    
                                                              ),#end CARAC_PALIER
                                                            ), # end MANUELLE
                                   #Fonctionnalite pas encore implementee
                                                           CATALOGUE = BLOC(condition = "((TYPE_SAISIE == 'CATALOGUE') )",
                                                                            fr = "Renseignement des fichiers contenant les caracteristiques du palier de torsion",
                                                    CATA_PALIER = SIMP(statut='o',min=1,max=1,typ='Fichier',fr="Format du fichier : CSV.",), # end CATA_PALIER
                                                   ), # end CATALOGUE
                 )#end PALIER TORSION
        
BUTEE=MACRO(nom="BUTEE",
            op=None,
            sd_prod=Butee,
            reentrant='n',
            UIinfo={"groupes":("Machine tournante",)},
            fr="Description d'une butee",
            POSITION = SIMP(statut='o',typ='R',defaut=0.0,fr = "Position axiale (absolue) de la butee (m)",), # end POSITION
            TYPE_BUTEE = SIMP(statut='o',typ='TXM',into=('BUTEE LINEAIRE',),fr = "Type de butee",), # end TYPE_BUTEE, BUTEE NON LINEAIRE reintegrable
            BUTEE_LINEAIRE=BLOC(condition="TYPE_BUTEE=='BUTEE LINEAIRE'",
                                fr = "Description d'une butee lineaire",
                                TYPE_SAISIE = SIMP(statut='o',typ='TXM',into=('MANUELLE',),fr = "Mode de description des caracteristiques de la butee lineaire",), # end TYPE_SAISIE; 'CATALOGUE' reintegrable
                                MANUELLE=BLOC(condition="TYPE_SAISIE=='MANUELLE'",
                                              fr = "Saisie manuelle des caracteristiques de la butee lineaire",
                                              CARAC_BUTEE=FACT(statut='o',max=1,fr="Caracteristiques de la butee en fonction de la vitesse de rotation",
                                                            VITESSE_ROTATION=SIMP(statut='o',typ='R',min=1,max='**',fr="Liste des vitesses de rotation (tr/min)",),
                                                            SYMETRIQUE=SIMP(statut='o',typ='TXM',min=1,max=1,into=("OUI","NON"),defaut="OUI",fr="Symetrie des matrices de la butee (KRXRY=KRYRX , ARXRY=ARYRX et MRXRY=MRYRX)",),

                                                            RIGIDITE_NS = BLOC(condition="(SYMETRIQUE=='NON')",
                                                                            RIGIDITE=FACT(statut='o',max=1,fr="Caracteristiques non-symetriques de rigidite de la butee lineaire en fonction de la vitesse de rotation",
                                                                          KZZ=SIMP(statut='o',typ='R',min=1,max='**',fr="Rigidite axiale (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite directe de rotation autour de l'axe X (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite croisee de rotation autour de l'axe X (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRYRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite croisee de rotation autour de l'axe Y (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite directe de rotation autour de l'axe Y (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                             ), #END RIGIDITE
                                                            ),#END RIGIDITE_NS
                                                            RIGIDITE_S = BLOC(condition="(SYMETRIQUE=='OUI')",
                                                                RIGIDITE=FACT(statut='o',max=1,fr="Caracteristiques symetriques de rigidite de la butee lineaire en fonction de la vitesse de rotation",
                                                                          KZZ=SIMP(statut='o',typ='R',min=1,max='**',fr="Rigidite axiale (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite directe de rotation autour de l'axe X (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite croisee de rotation autour de l'axe X (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          KRYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Rigidite directe de rotation autour de l'axe Y (N/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                             ), #END RIGIDITE
                                                            ),#END RIGIDITE_S

                                                            AMORTISSEMENT_NS = BLOC(condition="(SYMETRIQUE=='NON')",
                                                                AMORTISSEMENT=FACT(statut='o',max=1,fr="Caracteristiques non-symetriques d'amortissement de la butee lineaire en fonction de la vitesse de rotation",
                                                                          AZZ=SIMP(statut='o',typ='R',min=1,max='**',fr="Amortissement axial (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement direct de rotation autour de l'axe X (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement croise de rotation autour de l'axe X (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARYRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement croise de rotation autour de l'axe Y (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement croise de rotation autour de l'axe Y (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),                                       
                                                                  ),#END AMORTISSEMENT
                                                            ),#END AMORTISSEMENT_NS
                                                            AMORTISSEMENT_S = BLOC(condition="(SYMETRIQUE=='OUI')",
                                                                AMORTISSEMENT=FACT(statut='o',max=1,fr="Caracteristiques symetriques d'amortissement de la butee lineaire en fonction de la vitesse de rotation",
                                                                          AZZ=SIMP(statut='o',typ='R',min=1,max='**',fr="Amortissement axial (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement direct de rotation autour de l'axe X (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement croise de rotation autour de l'axe X (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          ARYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Amortissement croise de rotation autour de l'axe Y (N.s/m) de la butee lineaire en fonction de la vitesse de rotation"),                                       
                                                                  ),#END AMORTISSEMENT
                                                            ),#END AMORTISSEMENT_S

                                                            INERTIE_NS = BLOC(condition="(SYMETRIQUE=='NON')",
                                                                INERTIE=FACT(statut='f',max=1,fr="Caracteristiques non-symetriques de masse ajoutee de la butee lineaire en fonction de la vitesse de rotation",
                                                                          MZZ=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee axiale (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee directe de rotation autour de l'axe X (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee croisee de rotation autour de l'axe X (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRYRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee croisee de rotation autour de l'axe Y (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee croisee de rotation autour de l'axe Y (kg) de la butee lineaire en fonction de la vitesse de rotation"),                                       
                                                                 ),#END INERTIE
                                                            ),#END INERTIE_NS                                   
                                                            INERTIE_S = BLOC(condition="(SYMETRIQUE=='OUI')",
                                                                INERTIE=FACT(statut='f',max=1,fr="Caracteristiques symetriques de masse ajoutee de la butee lineaire en fonction de la vitesse de rotation",
                                                                          MZZ=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee axiale (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRXRX=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee directe de rotation autour de l'axe X (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRXRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee croisee de rotation autour de l'axe X (kg) de la butee lineaire en fonction de la vitesse de rotation"),
                                                                          MRYRY=SIMP(statut='f',typ='R',min=1,max='**',fr="Masse ajoutee croisee de rotation autour de l'axe Y (kg) de la butee lineaire en fonction de la vitesse de rotation"),                                       
                                                                 ),#END INERTIE
                                                            ),#END INERTIE_S
                                                            
                                                          ),#END CARA_BUTEE
                                              ),#end MANUELLE
                                CATALOGUE=BLOC(condition="TYPE_SAISIE=='CATALOGUE'",
                                               fr = "Renseignement des fichiers contenant les caracteristiques de la butee lineaire",
                                               ),#END CATALOGUE
                               ),#END BUTEE LINEAIRE

            BUTEE_NON_LINEAIRE=BLOC(condition="TYPE_BUTEE=='BUTEE NON LINEAIRE'",
                                    fr = "Description d'une butee non-lineaire",
                                    ),#END BUTEE NON LINEAIRE

    );#END BUTEE

############################# SUPPORT ########################################
SUPPORT = MACRO(nom = "SUPPORT",
                op = None,
                sd_prod = Support,
                reentrant = 'n',
                UIinfo = {"groupes":("Machine tournante",)},
                fr = "Description d'un support ",
                TYPE_SUPPORT = SIMP(statut='o', 
                                    fr = "Type de support",
                                    typ='TXM', 
                                    defaut="RIGIDE", 
                                    into=("RIGIDE", "SIMPLIFIE", "GENERALISE", ),
                                    ), # end TYPE_SUPPORT
                SIMPLIFIE = BLOC(condition = "((TYPE_SUPPORT == 'SIMPLIFIE') )",
                                fr = "Description d'un support simplifie",
                                RIGIDITE = FACT(statut='o', fr = "Renseignement des caracteristiques de rigidite du support simplifie",
                        KXX = SIMP(statut = 'o',
                              typ = 'R',
                              max = 1,
                              fr = "Valeur de KXX dans la matrice de rigidite (N/m)",
                              ),# end KXX
                        KXY = SIMP(statut = 'o',
                              typ = 'R',
                              max = 1,
                              fr = "Valeur de KXY dans la matrice de rigidite (N/m)",
                              ),# end KXY
                        KYX = SIMP(statut = 'o',
                              typ = 'R',
                              max = 1,
                              fr = "Valeur de KYX dans la matrice de rigidite (N/m)",
                              ),# end KYX
                        KYY = SIMP(statut = 'o',
                              typ = 'R',
                              max = 1,
                              fr = "Valeur de KYY dans la matrice de rigidite (N/m)",
                              ),# end KYY
                        ), # end RIGIDITE
                AMORTISSEMENT = FACT(statut='o', fr= "Renseignement des caracteristiques d'amortissement du support simplifie",
                            AXX = SIMP(statut = 'o',
                                typ = 'R',
                                max = 1,
                                fr = "Valeur de AXX dans la matrice d'amortissement (N.s/m)",
                                  ),# end AXX
                            AXY = SIMP(statut = 'o',
                                typ = 'R',
                                max = 1,
                                fr = "Valeur de AXY dans la matrice d'amortissement (N.s/m)",
                                  ),# end AXY
                            AYX = SIMP(statut = 'o',
                                typ = 'R',
                                max = 1,
                                fr = "Valeur de AYX dans la matrice d'amortissement (N.s/m)",
                                  ),# end AYX
                            AYY = SIMP(statut = 'o',
                                typ = 'R',
                                max = 1,
                                fr = "Valeur de AYY dans la matrice d'amortissement (N.s/m)",
                                  ),# end AYY
                              ), # end AMORTISSEMENT
                                MASSE = FACT(statut='o', fr= "Renseignement des caracteristiques de masse du support simplifie",
                        MXX = SIMP(statut = 'o',
                            typ = 'R',
                            max = 1,
                            fr = "Valeur de MXX dans la matrice de masse (kg)",
                              ),# end MXX
                        MXY = SIMP(statut = 'o',
                            typ = 'R',
                            max = 1,
                            fr = "Valeur de MXY dans la matrice de masse (kg)",
                              ),# end MXY
                        MYX = SIMP(statut = 'o',
                            typ = 'R',
                            max = 1,
                            fr = "Valeur de MYX dans la matrice de masse (kg)",
                              ),# end MYX
                        MYY = SIMP(statut = 'o',
                            typ = 'R',
                            max = 1,
                            fr = "Valeur de MYY dans la matrice de masse (kg)",
                              ),# end MYY
                        ), # end MASSE
                                 ), # end SIMPLIFIE
                GENERALISE = BLOC(condition = "((TYPE_SUPPORT == 'GENERALISE') )",
                                  fr = "Description d'un support generalise",
                                  ANGL_NAUT = SIMP(statut='f',
                                                  fr="Rotation du modele du support generalise a effectuer pour coincider avec le repere de la ligne d'arbres (rotation autour de X, puis Y, puis Z (degres))",
                                                  typ='R',
                                                  min=3,max=3,
                                                  ), # end ANGL_NAUT
                                  TRANS = SIMP(statut='f',
                                              fr="Translation du modele du support generalise a effectuer pour que ses noeuds de connexion soient confondus avec ceux de la ligne d'arbres (translation suivant X, Y et Z (m))",
                                              typ='R',
                                              min=3,max=3,
                                              ), # end TRANS
                                  MAIL_TDG = SIMP(statut='o',
                                                 fr="Fichier du maillage du support generalise",
                                                 typ=("Fichier","Fichier maillage TdG (*.*)"),
                                                 min=1,max=1,
                                                ), # end MAIL_TDG
                                  COMM_TDG = SIMP(statut='o',
                                                 fr="Fichier de la mise en donnees du support generalise",
                                                 typ=("Fichier","Fichier commande TdG (*.*)"),
                                                 min=1,max=1,
                                                ), # end COMM_TDG
                                  NOM_MACRO_ELEMENT_DYNAMIQUE = SIMP(statut='o',
                                                                     fr="Nom du macro element dynamique cree pour le support generalise",
                                                                     typ='TXM',
                                                                     min=1,max=1,
                                                                    ), # end NOM_MACRO_ELEMENT_DYNAMIQUE
                                  NOM_INTERFACE = SIMP(statut='o',
                                                       fr="Nom de l'interface cree pour le support generalise",
                                                       typ='TXM',
                                                       min=1,max=1,
                                                      ), # end NOM_INTERFACE
                                  NOM_GROUP_MA_MASSIF = SIMP(statut='o',
                                                             fr="Nom du groupe de maille representant le support generalise",
                                                             typ='TXM',
                                                             min=1,max=1,
                                                            ), # end NOM_GROUP_MA_MASSIF
                                  REDUIT = SIMP(statut='f',
                                                fr="Introduction du mot-cle REDUIT pour le cas ou le nombre d'interfaces n'est pas identique entre le support generalise et la ligne d'arbres",
                                                typ='TXM',
                                                into=("OUI",),
                                                defaut="OUI",
                                               ), # end REDUIT 
                                  ), # end GENERALISE
                ) # end SUPPORT

############################# LIGNE_ARBRE ########################################
LIGNE_ARBRE = MACRO(nom = 'LIGNE_ARBRE',
                    op = None,
                    sd_prod = LigneArbre,
                    reentrant = 'n',
                    UIinfo = {"groupes":("Machine tournante",)},
                    fr = "Description de la ligne d'arbres",
                    ZONES = SIMP(statut='o', 
                                 fr = "Zone(s) composant la ligne d'arbres (choisir, en faisant attention a l'ordre, parmi les entrees ZONE creees)",
                                 typ=Zone, 
                                 min=1, 
                                 max='**',
                                 ), # end ZONES
                    PALIERS = SIMP(statut='o',
                                   fr = "Paliers supportant la ligne d'arbres (choisir, en faisant attention a l'ordre, parmi les entrees PALIER creees)",
                                   typ=Palier,
                                   min=2,
                                   max='**',
                                   ), # end PALIERS
                    BUTEES  = SIMP(statut='f',
                                   fr = "Butee(s) guidant axialement la ligne d'arbres (choisir, en faisant attention a l'ordre, parmi les entrees BUTEES creees)",
                                   typ=Butee,
                                   max='**'
                                   ),#end BUTEE
                    PALIERS_TORSION=SIMP(statut='f',
                                         fr = "Palier(s) de torsion de la ligne d'arbres (choisir, en faisant attention a l'ordre, parmi les entrees PALIERS_TORSION creees)",
                                         typ=PalTor,
                                         max='**'
                                         ),#end PALIERS_TORSION
                    SUPPORTS = SIMP(statut='o', 
                                    fr = "Supports sous les paliers (choisir, en faisant attention a l'ordre, parmi les entrees SUPPORTS creees)",
                                    typ=Support, 
                                    min=1, 
                                    max='**',
                                    ), # end SUPPORTS
                    ) # end LIGNE_ARBRE

