## -*- coding: utf-8 -*-
#
## --------------------------------------------------
## debut entete
## --------------------------------------------------
#
# 20120510 : suppression de la valeur par defaut de MATERIAU->PARAMETRES_MAT->NU
#            changement du nom MATERIAU->PARAMETRES_MAT->MASS_VOL en MATERIAU->PARAMETRES_MAT->RHO
#
# 20120619 : changement ordre d'affichage des macros -> ordre de création
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
    if type(valeur) == types.StringType:
      return None
    if len(valeur) != self.ntuple:
      return None
    return valeur

  def info(self):
    return "Tuple de %s elements" % self.ntuple

  __repr__=info
  __str__=info


#CONTEXT.debug = 1
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

############################# DIRECTION ########################################
DIRECTION = OPER(nom = "DIRECTION",
                  op = None,
                  sd_prod = Direction,
                  reentrant = 'n',
                  UIinfo = {"groupes": ("Machine tournante",)},
                  fr = "Direction de la ligne d'arbre",
                  AXE = SIMP(statut = 'o',
                             typ = 'TXM',
                             fr = "Choix de la direction \n de l'axe de la ligne d'arbre (horizontal = Z, vertical = X)",
                             ang = "Choix de la direction \n de l'axe de la ligne d'arbre (horizontal = Z, vertical = X)",
                             min=1,
                             max=1,
                             into = ('HORIZONTAL','VERTICAL'),
                             defaut = 'HORIZONTAL',
                             ), # end AXE
                 ) # end DIRECTION


############################# MATERIAUX ########################################
# @todo
# introduction manuelle => dans ce cas l'utilisateur definit le
# materiau comme ci-dessous
# recuperation depuis une bibliothèque de materiau => sera specife
# plus tard
MATERIAUX = OPER(nom = 'MATERIAUX',
                 op = None,
                 sd_prod = Materiau,
                 reentrant = 'n',
                 UIinfo = {"groupes": ("Machine tournante",)},
                 fr = "Description materiau MT  ",
                 TYPE_INTRO = SIMP(statut='o', 
                                   typ='TXM',
                                   into=('MANUELLE','FICHIER'),
                                   min=1,
                                   max=1,
                                   defaut='MANUELLE',
                                   ), # end TYPE_INTRO
                 PARAMETRES_MAT = BLOC(condition = "((TYPE_INTRO == 'MANUELLE') )",
                                       #MASS_VOL  = SIMP(statut='o', typ='R', min=1, max=1, fr='masse volumique'),
                                       RHO = SIMP(statut='o',
                                                  typ='R',
                                                  min=1,
                                                  max=1,
                                                  fr='masse volumique (en kg/m**3)',
                                                  ), # end RHO
                                       E = SIMP(statut='o',
                                                typ='R',
                                                min=1,
                                                max=1,
                                                fr='module de Young (en Pa)',
                                                ), # end E
                                       NU = SIMP(statut='o', 
                                                 typ='R',
                                                 min=1,
                                                 max=1,
                                                 val_min=-1.0,
                                                 val_max=0.5,
                                                 fr='coefficient de cisaillement (-1.0 <= NU <= 0.5)',
                                                 ), # end NU
                                       ALPHA = SIMP(statut='f', 
                                                    typ='R',
                                                    min=1,
                                                    max=1,
                                                    fr = "coefficient permettant de construire une matrice d'amortissement visqueux proportionnel a la rigidite",
                                                    ), # end ALPHA
                                       BETA = SIMP(statut='f',
                                                   typ='R', 
                                                   min=1, 
                                                   max=1, 
                                                   fr = "coefficient permettant de construire une matrice d'amortissement visqueux proportionnel a la masse",
                                                   ), # end BETA
                                       GAMA = SIMP(statut='f',
                                                   typ='R',
                                                   min=1,
                                                   max=1,
                                                   fr = "coefficient d'amortissement hysteretique permettant de definir le module d'Young complexe",
                                                   ), # end GAMA
                                       ), # end PARAMETRES_MAT
                   FICHIER_MAT = BLOC(condition = "((TYPE_INTRO == 'FICHIER') )",
                                      MATERIAU_CATALOGUE = SIMP(statut='o',
							      min=1, 
							      max=1, 
							      typ=('Fichier','Fichier materiau (*.*)'), 
							      fr="Format du fichier : CSV.",
							      ), # end MATERIAU_CATALOGUE
                                     ), # end FICHIER_MAT
                                     #SIMP(typ=('Fichier','JDC Files (*.comm)'),docu='',min=1,max=1,statut='o',defaut=None)
                 ) # end MATERIAU



############################# ZONES ########################################
ZONE = OPER(nom = 'ZONE',
             op = None,
             sd_prod = Zone,
             reentrant = 'n',
             UIinfo = {"groupes":("Machine tournante",)},
             fr = "Description zone MT  ",
             regles = (PRESENT_PRESENT("MASSE","TOTO","TITI")),
             TOTO=SIMP(typ="TXM",statut='f'),
             TITI=SIMP(typ="TXM",statut='f'),
             MASSE = FACT(statut='f',
                          min=0,
                          max='**',
			  fr = "Definition des masses",
			  #POSITION = SIMP(statut='o',
			  NOEUD = SIMP(statut='o', 
					  typ='TXM', 
					  defaut=None, 
					  fr = "Definition de la position de la masse par l'étiquette du noeud",
					  ), # end POSITION
			  TYPE_MASSE = SIMP(statut='o', 
					    typ='TXM', 
					    fr = "Choix du type de masse",
					    into=('DISQUE','AILETTE','QUELCONQUE'),
					    ), # end TYPE_MASSE
			  DISQUE = BLOC(condition = "((TYPE_MASSE == 'DISQUE') )",
			                TYPE_SAISIE = SIMP(statut='o',
			                                   typ='TXM',
			                                   fr = "Choix du type de saisie des parametres de la masse",
			                                   into = ('MECANIQUE','GEOMETRIQUE'),
			                                   defaut = 'MECANIQUE'
			                                   ), # end TYPE_SAISIE
			                PARAMETRES_MECANIQUE = BLOC(condition = "TYPE_SAISIE == 'MECANIQUE'",
								    PARAMETRES = FACT(statut = 'o',
										      fr = "Parametres mecanique pour Masse de type DISQUE",
										      MASSE = SIMP(statut='o',
											           typ='R',
												   val_min=0,
												   fr = "magnitude de la masse disque (en kg)",
												   ), # end MASSE_DISQUE
										      INERTIEX = SIMP(statut='o', 
												      typ='R',
												      fr = "inertie en x (en kg.m**2)",
												      ), # end INERTIEX
										      INERTIEY = SIMP(statut='o', 
												      typ='R',
												      fr = "inertie en y (en kg.m**2)",
												      ), # end INERTIEY
										      INERTIEZ = SIMP(statut='o', 
												      typ='R',
												      fr = "inertie en z (en kg.m**2)",
												      ), # end INERTIEZ
										      ) # nd PARAMETRES_DISQUE_M
		                                                    ), # end PARAMETRES_MECANIQUE
		                        PARAMETRES_GEOMETRIQUE = BLOC(condition = "TYPE_SAISIE == 'GEOMETRIQUE'",
								    PARAMETRES = FACT(statut = 'o',
										      fr = "Parametres geometrique pour Masse de type DISQUE",
										      DIAMETRE_EXT = SIMP(statut='o',
													  typ='R',
													  val_min=0,
													  fr = "diametre exterieur de la masse disque (en m)",
													  ), # end MASSE_DISQUE
										      DIAMETRE_INT = SIMP(statut='o', 
												          typ='R',
												          fr = "diametre interieur de la masse disque (en m). Verifier le diametre de la section avant saisie",
												          ), # end INERTIEX
										      EPAISSEUR = SIMP(statut='o', 
												       typ='R',
												       val_min=0,
												       fr = "epaisseur (largeur) de la masse disque (en m)",
												       ), # end INERTIEY
										      MATERIAU = SIMP(statut='o', 
												      typ=Materiau,
												      fr = "materiau defini par le concept MATERIAU",
												      ), # end INERTIEZ
										      ) # nd PARAMETRES_DISQUE_G
		                                                    ), # end PARAMETRES_MECANIQUE
					), # end DISQUE
			  AILETTE = BLOC(condition = "((TYPE_MASSE == 'AILETTE') )",
					 TYPE_SAISIE = SIMP(statut='o',
			                                    typ='TXM',
			                                    fr = "Choix du type de saisie des parametres de la masse",
			                                    into = ('MECANIQUE','GEOMETRIQUE'),
			                                    defaut = 'MECANIQUE'
			                                    ), # end TYPE_SAISIE
			                 PARAMETRES_MECANIQUE = BLOC(condition = "TYPE_SAISIE == 'MECANIQUE'",
								     PARAMETRES = FACT(statut = 'o',
									               fr = "Parametres mecanique pour Masse de type AILETTE",
										       MASSE = SIMP(statut='o',
										                    typ='R',
											            val_min=0,
											            fr = "magnitude de la masse ailette (en kg)",
											            ), # end MASSE_AILETTE
										       INERTIEX = SIMP(statut='o', 
												       typ='R',
												       fr = "inertie en x (en kg.m**2)",
												       ), # end INERTIEX
										       INERTIEY = SIMP(statut='o', 
											               typ='R',
											               fr = "inertie en y (en kg.m**2)",
												       ), # end INERTIEY
										       INERTIEZ = SIMP(statut='o', 
												       typ='R',
												       fr = "inertie en z (en kg.m**2)",
												       ), # end INERTIEZ
										       ) # nd PARAMETRES_AILETTE_M
		                                                      ), # end PARAMETRES_MECANIQUE
		                           PARAMETRES_GEOMETRIQUE = BLOC(condition = "TYPE_SAISIE == 'GEOMETRIQUE'",
								         PARAMETRES = FACT(statut = 'o',
										           fr = "Parametres geometrique pour Masse de type AILETTE",
										           MASSE_AILETTE = SIMP(statut='o',
										                                typ='R',
												  		val_min=0,
												  		fr = "Renseignement de la masse d'une ailette (en kg)",
														), # end MASSE_AILETTE
											   RAYON = SIMP(statut='o', 
													typ='R',
													val_min=0,
													fr = "Renseignement de la distance entre le pied de l'ailette et le centre de rotation (en m). Verifier le diametre de la section avant saisie",
													), # end RAYON
											   HAUTEUR = SIMP(statut='o',
											                  typ='R',
												          val_min=0,
												          fr = "Renseignement de la distance entre les deux extremites de l'ailette (en m)",
												          ), # end HAUTEUR
											   BASE = SIMP(statut='o', 
											               typ='R',
												       val_min=0,
												       fr = "Renseignement de la largeur du pied de l'ailette (en m)",
												       ), # end BASE
											   NOMBRE = SIMP(statut='o',
											                 typ='I',
											                 val_min=1,
											                 fr = "renseignement du nombre d'ailette sur le disque",
											                 ),
											   ) # end PARAMETRES_DISQUE
		                                                         ), # end PARAMETRES_MECANIQUE
					   ), # end AILETTE
			    QUELCONQUE = BLOC(condition = "((TYPE_MASSE == 'QUELCONQUE') )",
			                      #TYPE_SAISIE = SIMP(statut='c',typ='TXM',defaut="MECANIQUE"), # cf 20120622 test : mot-clé caché
					      PARAMETRES = FACT(statut = 'o',
								fr = "Parametres pour Masse de type QUELCONQUE",
								MASSE = SIMP(statut='o', 
									     typ='R',
									     val_min=0,
									     fr = "magnitude de la masse quelconque (en m)",
									     ), # end MASSE
								INERTIEX = SIMP(statut='o', 
										typ='R',
										fr = "inertie en x (en kg.m**2)",
									       ), # end INERTIEX
								INERTIEY = SIMP(statut='o', 
										typ='R',
										fr = "inertie en y (en kg.m**2)",
									       ), # end INERTIEY
								INERTIEZ = SIMP(statut='o', 
										typ='R',
										fr = "inertie en z (en kg.m**2)",
									       ), # end INERTIEZ
								), # end PARAMETRES_QUELCONQUE
					      ), # end QUELCONQUE
             ),  # end MASSE
             NOEUDS = FACT(fr = "abscisse curviligne du noeud",
                           statut='o',
                           min=2, 
                           max='**',
                           NOM = SIMP(statut='o',
                                      typ='TXM',
                                      fr="nom du noeud",
                                      ), # end NOM
                           X = SIMP(statut='o',
                                    typ='R',
                                    defaut=0.0,
                                    val_min=0.0,
                                    fr = "abscisse curviligne du noeud",
                                    ), # end X
                           ), # end NOEUDS
             ELEMENTS = FACT(statut='o',
                             min=1,
                             max='**',
                             NOM = SIMP(statut='o',
                                        typ='TXM',
                                        fr="Nom de l'element"
                                        ), # end NOM
                             DEBUT = SIMP(statut='o',
                                          typ='TXM',
                                          fr= "Noeud de debut de l'element (etiquette d'un noeud)"
                                          ), # end DEBUT
                             FIN = SIMP(statut='o',
                                        typ='TXM',
                                        fr= "Noeud de fin de l'element (etiquette d'un noeud)"
                                        ), # end FIN
                             RAFFINAGE = SIMP(statut='o',
                                              typ='TXM',
                                              into=('OUI','NON'),
                                              defaut='NON'
                                              ), # end RAFFINAGE
                             PARAM_RAFFINAGE = BLOC(condition = "((RAFFINAGE == 'OUI') )",
                                                    NB_POINTS_SUPPL = SIMP(statut='o', 
                                                                           typ='I'
                                                                           ), # end NB_POINTS_SUPPL
                                                    ), # end PARAM_RAFFINAGE
                             MATERIAU = SIMP(statut='o',
                                             typ=Materiau,
                                             fr= "Choix du Materiau de l'element"
                                             ), # end MATERIAU
			     SECTION_MASSE = FACT(statut='o',
                                                  fr = "Section liee à la masse  ",
                                                  TYPE_SECTION = SIMP(statut='o',
                                                                      typ='TXM',
                                                                      into=('CONSTANTE','VARIABLE'),
                                                                      defaut='CONSTANTE',
                                                                      ), # end TYPE_SECTION
                                                  DIAM_EXTERN_DEBUT = SIMP(statut='o',
                                                                           typ='R',
                                                                           fr = "diametre exterieur en debut de section (en m)",
                                                                           ), # end DIAM_EXTERN_DEBUT
                                                  DIAM_INTERN_DEBUT = SIMP(statut='o',
                                                                           typ='R',
                                                                           fr = "diametre interieur en debut de section (en m)",
                                                                           ), # end DIAM_INTERN_DEBUT
                                                  PARAMETRE_SECT_VAR = BLOC(condition = "((TYPE_SECTION == 'VARIABLE') )",
                                                                            DIAM_EXTERN_SORTIE = SIMP(statut='o',
                                                                                                      typ='R',
                                                                                                      fr = "diametre exterieur en fin de section (en m)",
                                                                                                      ), # end DIAM_EXTERN_SORTIE
                                                                            DIAM_INTERN_SORTIE = SIMP(statut='o',
                                                                                                      typ='R',
                                                                                                      fr = "diametre interieur en fin de section (en m)",
                                                                                                      ), # DIAM_INTERN_SORTIE
                                                                            ),
                                                  ), # end SECTION_MASSE
                             SECTION_RIGIDITE = FACT(statut='f',
                                                     fr = "Section liee à la rigidite  ",
                                                     TYPE_SECTION = SIMP(statut='o', 
                                                                         typ='TXM', 
                                                                         into=('CONSTANTE','VARIABLE'), 
                                                                         defaut='CONSTANTE',
                                                                         ), # end TYPE_SECTION
                                                     DIAM_EXTERN_DEBUT = SIMP(statut='o',
                                                                              typ='R',
                                                                              fr = "diametre exterieur en debut de section (en m)",
                                                                              ), # end DIAM_EXTERN_DEBUT
                                                     DIAM_INTERN_DEBUT = SIMP(statut='o',
                                                                              typ='R',
                                                                              fr = "diametre interieur en debut de section (en m)",
                                                                              ), # end DIAM_INTERN_DEBUT
                                                     PARAMETRE_SECT_VAR = BLOC(condition = "((TYPE_SECTION == 'VARIABLE') )",
                                                                               DIAM_EXTERN_SORTIE = SIMP(statut='o',
                                                                                                         typ='R',
                                                                                                         fr = "diametre exterieur en fin de section (en m)",
                                                                                                         ), # end DIAM_EXTERN_SORTIE
                                                                               DIAM_INTERN_SORTIE = SIMP(statut='o',
                                                                                                         typ='R',
                                                                                                         fr = "diametre interieur en fin de section (en m)",
                                                                                                         ), # end DIAM_INTERN_SORTIE
                                                                               ), # end PARAMETRE_SECT_VAR
                                                     ), # end SECTION_RIGIDITE
                             ),  # end ELEMENTS
                             FISSURE = FACT(statut='f',
                                            fr="Saisie de la presence d'une fissure (uniquement sur section constante a droite et a gauche)",
                                            MATERIAU = SIMP(statut='o',
                                                            typ=Materiau,
                                                            fr="Renseignement du materiau a la position de la fissure"
                                                           ), # end MATERIAU
                                            NOEUD_FISSURE = SIMP(statut='o',
                                                                 typ='TXM',
                                                                 fr="Renseignement de l'etiquette du noeud de la fissure",
                                                                 ), # end POSITION_FISSURE
                                            ORIENTATION_FISSURE = SIMP(statut='o',
                                                                       typ='R',
                                                                       fr="Renseignement de la position angulaire de la fissure (en degres)",
                                                                       ), # end ORIENTATION_FISSURE
                                            FICHIER_RAIDEUR = SIMP(statut='o',
                                                                   typ=('Fichier','Fichier loi de raideur (*.*)'),
                                                                   fr="Renseignement du fichier contenant la loi de raideur",
                                                                   ), # end FICHIER_RAIDEUR
                                            DIAMETRE = SIMP(statut='o',
                                                            typ='R',
                                                            fr="Renseignement du diametre (pour la proportion par rapport à l'eprouvette)",
                                                            ), # end DIAMETRE
                                            ), # end FISSURE

			)  # end ZONE
				
############################# PALIERS ########################################
PALIER = OPER(nom = 'PALIER',
               op = None,
               sd_prod = Palier,
               reentrant = 'n',
               UIinfo = {"groupes":("Machine tournante",)},
               fr = "Description palier MT  ",
               POSITION = SIMP(statut='o', 
                               typ='R', 
                               defaut=0.0, 
                               fr = "position (absolue) du palier",
                               ), # end POSITION
               TYPE_PALIER = SIMP(statut='o', 
                                  typ='TXM', 
                                  into=('PALIER LINEAIRE','PALIER NON-LINEAIRE','PALIER DE TORSION','LAME FLUIDE'),
                                  ), # end TYPE_PALIER
	      PALIER_LINEAIRE = BLOC(condition = "((TYPE_PALIER == 'PALIER LINEAIRE') )", 
			              TYPE_SAISIE = SIMP(statut='o', 
							typ='TXM', 
							into=('MANUELLE', 'CATALOGUE'),
							), # end TYPE_SAISIE
				      MANUELLE = BLOC(condition = "((TYPE_SAISIE == 'MANUELLE') )",
				                      CARAC_PALIER = FACT(statut = 'o',max='**',fr = "Saisie des caracteristiques du palier par vitesse de rotation de l'arbre",
                                                              VITESSE_ROTATION = SIMP(statut='o',
                                                                                      typ='R',
                                                                                      fr= "Vitesse de rotation",
                                                                                      ), # end VITESSE_ROTATION
							      SYME = SIMP(statut = 'o',
									  typ = 'TXM',
									  max = 1,
									  fr = "Symetrie des matrices du palier",
									  into = ('OUI','NON'),
									  defaut = 'OUI',
									  ), # end SYME
							      RIGIDITE_NS = BLOC(condition="(SYME=='NON')",
							              RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques de rigidite du palier",
									      KXX = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kxx dans la matrice de rigidite",
											),# end KXX
									      KXY = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kxy dans la matrice de rigidite",
											),# end KXY
									      KYX = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kyx dans la matrice de rigidite",
											),# end KYX
									      KYY = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kyy dans la matrice de rigidite",
											),# end KYY
									              ), # end RIGIDITE
									      ), # end RIGIDITE_S
							      RIGIDITE_S = BLOC(condition="(SYME=='OUI')",
							              RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de rigidite du palier",
									      KXX = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kxx dans la matrice de rigidite",
											),# end KXX
									      KXY = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kxy dans la matrice de rigidite",
											),# end KXY
									      KYY = SIMP(statut = 'o',
											typ = 'R',
											max = 1,
											fr = "Valeur de Kyy dans la matrice de rigidite",
											),# end KYY
									              ), # end RIGIDITE
									      ), # end RIGIDITE_NS
							      AMORTISSEMENT_NS = BLOC(condition="(SYME=='NON')",
							              AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques d'amortissement du palier",
										  AXX = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Axx dans la matrice d'amortissement",
											    ),# end AXX
										  AXY = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Axy dans la matrice d'amortissement",
											    ),# end AXY
										  AYX = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Ayx dans la matrice d'amortissement",
											    ),# end AYX
										  AYY = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Ayy dans la matrice d'amortissement",
											    ),# end AYY
									                  ), # end AMORTISSEMENT
											), # end AMORTISSEMENT_NS
							      AMORTISSEMENT_S = BLOC(condition="(SYME=='OUI')",
							              AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques symetriques d'amortissement du palier",
										  AXX = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Axx dans la matrice d'amortissement",
											    ),# end AXX
										  AXY = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Axy dans la matrice d'amortissement",
											    ),# end AXY
										  AYY = SIMP(statut = 'o',
											      typ = 'R',
											      max = 1,
											      fr = "Valeur de Ayy dans la matrice d'amortissement",
											    ),# end AYY
									                  ), # end AMORTISSEMENT
											), # end AMORTISSEMENT_S
	                                                      ), # end CARAC_PALIER
						      ), # end MANUELLE
						      CATALOGUE = BLOC(condition = "((TYPE_SAISIE == 'CATALOGUE') )",
								      CATALOGUE_AMORTISSEMENT = SIMP(statut='o',
											      min=1, 
											      max=1, 
											      typ='Fichier', 
											      fr="Format du fichier : CSV.",
											      ), # end CATALOGUE_AMORTISSEMENT
								      CATALOGUE_RIGIDITE = SIMP(statut='o',
											      min=1, 
											      max=1, 
											      typ='Fichier', 
											      fr="Format du fichier : CSV.",
											      ), # end CATALOGUE_RIGIDITE
								      ), # end CATALOGUE
			             ), # end PALIER_LINEAIRE
			      LAME_FLUIDE = BLOC(condition = "((TYPE_PALIER == 'LAME FLUIDE') )",
			                          TYPE_SAISIE = SIMP(statut='o', 
							typ='TXM', 
							into=('MANUELLE', 'CATALOGUE'),
							), # end TYPE_SAISIE
				                  MANUELLE = BLOC(condition = "((TYPE_SAISIE == 'MANUELLE') )",
				                                CARAC_PALIER = FACT(statut = 'o',max='**',fr = "Saisie des caracteristiques du palier par vitesse de rotation de l'arbre",
								      SYME = SIMP(statut = 'o',
										typ = 'TXM',
										max = 1,
										fr = "Symetrie des matrices du palier",
										into = ('OUI','NON'),
										defaut = 'OUI',
										), # end SYME
								    RIGIDITE_NS = BLOC(condition="(SYME=='NON')",
								            RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques de rigidite du palier",
										    KXX = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kxx dans la matrice de rigidite",
												),# end KXX
										    KXY = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kxy dans la matrice de rigidite",
												),# end KXY
										    KYX = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kyx dans la matrice de rigidite",
												),# end KYX
										    KYY = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kyy dans la matrice de rigidite",
												),# end KYY
										            ), # end RIGIDITE
										    ), # end RIGIDITE_NS
								    RIGIDITE_S = BLOC(condition="(SYME=='OUI')",
								            RIGIDITE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de rigidite du palier",
										    KXX = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kxx dans la matrice de rigidite",
												),# end KXX
										    KXY = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kxy dans la matrice de rigidite",
												),# end KXY
										    KYY = SIMP(statut = 'o',
												typ = 'R',
												max = 1,
												fr = "Valeur de Kyy dans la matrice de rigidite",
												),# end KYY
										            ), # end RIGIDITE
										    ), # end RIGIDITE_S
								    AMORTISSEMENT_NS = BLOC(condition="(SYME=='NON')",
								            AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques d'amortissement du palier",
											  AXX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Axx dans la matrice d'amortissement",
												    ),# end AXX
											  AXY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Axy dans la matrice d'amortissement",
												    ),# end AXY
											  AYX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Ayx dans la matrice d'amortissement",
												    ),# end AYX
											  AYY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Ayy dans la matrice d'amortissement",
												    ),# end AYY
												), # end AMORTISSEMENT
											), # end AMORTISSEMENT_NS
								    AMORTISSEMENT_S = BLOC(condition="(SYME=='OUI')",
								            AMORTISSEMENT=FACT(statut='o',fr="Renseignement des caracteristiques symetriques d'amortissement du palier",
											  AXX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Axx dans la matrice d'amortissement",
												    ),# end AXX
											  AXY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Axy dans la matrice d'amortissement",
												    ),# end AXY
											  AYY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Ayy dans la matrice d'amortissement",
												    ),# end AYY
												), # end AMORTISSEMENT
										        ), # end AMORTISSEMENT_S
								    MASSE_NS = BLOC(condition="(SYME=='NON')",
								            MASSE=FACT(statut='o',fr="Renseignement des caracteristiques non symetriques de masse du palier",
											  MXX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Mxx dans la matrice de masse",
												    ),# end MXX
											  MXY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Mxy dans la matrice de masse",
												    ),# end MXY
											  MYX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Myx dans la matrice de masse",
												    ),# end MYX
											  MYY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Myy dans la matrice de masse",
												    ),# end MYY
												), # end MASSE
											), # end MASSE_NS
								    MASSE_S = BLOC(condition="(SYME=='OUI')",
								        MASSE=FACT(statut='o',fr="Renseignement des caracteristiques symetriques de masse du palier",
											  MXX = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Mxx dans la matrice de masse",
												    ),# end MXX
											  MXY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Mxy dans la matrice de masse",
												    ),# end MXY
											  MYY = SIMP(statut = 'o',
												    typ = 'R',
												    max = 1,
												    fr = "Valeur de Myy dans la matrice de masse",
												    ),# end MYY
												), # end MASSE
											), # end MASSE_S
								    VITESSE_ROTATION = SIMP(statut='o',
											    typ='R',
											    fr= "Vitesse de rotation",
											    ), # end VITESSE_ROTATION
                                                               ), # end CARAC_PALIER
						      ), # end MANUELLE
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
				                                  # 20121126 : reception spec du calcul transitoire accidentel
				                                  #
				                                  TYPE = SIMP(statut='o',
				                                              typ='TXM',
				                                              into=('PAPANL','PAFINL','PAHYNL','PACONL'),
				                                              defaut=None,
				                                              fr="Le choix d'un palier non-lineaire n'est valide que lors d'un calcul Aster/Edyos",
				                                              ), # end TYPE
				                                  REPERTOIRE_EDYOS = SIMP(statut='o',
				                                                          typ=('Repertoire'),
				                                                          defaut=None,
				                                                          fr="Renseigement du repertoire contenant le fichier DONNEES_YACS (il faudra choisir ce repertoire au moment de la creation du cas de calcul)",
				                                                          ), # end REPERTOIRE_EDYOS
				                                  ), # end PALIER_NON_LINEAIRE
				        PALIER_DE_TORSION = BLOC(condition = "((TYPE_PALIER == 'PALIER DE TORSION') )",
				                                # ce type de palier sera implémenté dans la version 2 ...
				                                ), # end PALIER_DE_TORSION
               )  # end PALIER
		

############################# SUPPORT ########################################
SUPPORT = OPER(nom = "SUPPORT",
                op = None,
                sd_prod = Support,
                reentrant = 'n',
                UIinfo = {"groupes":("Machine tournante",)},
                fr = "Description d'un support ",
                TYPE_SUPPORT = SIMP(statut='o', 
                                    typ='TXM', 
                                    defaut="RIGIDE", 
                                    into=("RIGIDE", "SIMPLIFIE", "GENERALISE", ),
                                    ), # end TYPE_SUPPORT
                SIMPLIFIE = BLOC(condition = "((TYPE_SUPPORT == 'SIMPLIFIE') )",
                                RIGIDITE = FACT(statut='o', fr = "Matrice de rigidite",
						KXX = SIMP(statut = 'o',
							  typ = 'R',
							  max = 1,
							  fr = "Valeur de Kxx dans la matrice de rigidite",
							  ),# end KXX
						KXY = SIMP(statut = 'o',
							  typ = 'R',
							  max = 1,
							  fr = "Valeur de Kxy dans la matrice de rigidite",
							  ),# end KXY
						KYX = SIMP(statut = 'o',
							  typ = 'R',
							  max = 1,
							  fr = "Valeur de Kyx dans la matrice de rigidite",
							  ),# end KYX
						KYY = SIMP(statut = 'o',
							  typ = 'R',
							  max = 1,
							  fr = "Valeur de Kyy dans la matrice de rigidite",
							  ),# end KYY
						), # end RIGIDITE
				AMORTISSEMENT = FACT(statut='o', fr= "Matrice d'amortissement",
						    AXX = SIMP(statut = 'o',
								typ = 'R',
								max = 1,
								fr = "Valeur de Axx dans la matrice d'amortissement",
							      ),# end AXX
						    AXY = SIMP(statut = 'o',
								typ = 'R',
								max = 1,
								fr = "Valeur de Axy dans la matrice d'amortissement",
							      ),# end AXY
						    AYX = SIMP(statut = 'o',
								typ = 'R',
								max = 1,
								fr = "Valeur de Ayx dans la matrice d'amortissement",
							      ),# end AYX
						    AYY = SIMP(statut = 'o',
								typ = 'R',
								max = 1,
								fr = "Valeur de Ayy dans la matrice d'amortissement",
							      ),# end AYY
							  ), # end AMORTISSEMENT
                                MASSE = FACT(statut='o', fr= "Matrice d'amortissement",
					    MXX = SIMP(statut = 'o',
							typ = 'R',
							max = 1,
							fr = "Valeur de Mxx dans la matrice de masse",
						      ),# end MXX
					    MXY = SIMP(statut = 'o',
							typ = 'R',
							max = 1,
							fr = "Valeur de Mxy dans la matrice de masse",
						      ),# end MXY
					    MYX = SIMP(statut = 'o',
							typ = 'R',
							max = 1,
							fr = "Valeur de Myx dans la matrice de masse",
						      ),# end MYX
					    MYY = SIMP(statut = 'o',
							typ = 'R',
							max = 1,
							fr = "Valeur de Myy dans la matrice de masse",
						      ),# end MYY
					    ), # end MASSE
                                 ), # end SIMPLIFIE
                GENERALISE = BLOC(condition = "((TYPE_SUPPORT == 'GENERALISE') )",
                                  # cft 20130422 modif
                                  ANGL_NAUT = SIMP(statut='f',
                                                  fr="Renseignement de la rotation du modele de la table de groupe a effectuer (X,Y,Z)",
                                                  typ='R',
                                                  min=3,max=3,
                                                  ), # end ANGL_NAUT
                                  TRANS = SIMP(statut='f',
                                              fr="Renseignement de la translation du modele de la table de groupe a effectuer (X,Y,Z)",
                                              typ='R',
                                              min=3,max=3,
                                              ), # end TRANS
                                  MAIL_TDG = SIMP(statut='o',
                                                 fr="Maillage de la table de groupe",
                                                 typ=("Fichier","Fichier maillage TdG (*.*)"),
                                                 min=1,max=1,
                                                ), # end MAIL_TDG
                                  COMM_TDG = SIMP(statut='o',
                                                 fr="Mise en données de la table de groupe",
                                                 typ=("Fichier","Fichier commande TdG (*.*)"),
                                                 min=1,max=1,
                                                ), # end COMM_TDG
                                  NOM_MACRO_ELEMENT_DYNAMIQUE = SIMP(statut='o',
                                                                     fr="Renseignement du nom du macro element dynamique cree dans le fichier importe",
                                                                     typ='TXM',
                                                                     min=1,max=1,
                                                                    ), # end NOM_MACRO_ELEMENT_DYNAMIQUE
                                  NOM_INTERFACE = SIMP(statut='o',
                                                       fr="Renseignement du nom de l'interface cree dans le fichier importe",
                                                       typ='TXM',
                                                       min=1,max=1,
                                                      ), # end NOM_INTERFACE
                                  NOM_GROUP_MA_MASSIF = SIMP(statut='o',
                                                             fr="Renseignement du nom du groupe de maille du massif cree dans le fichier importe",
                                                             typ='TXM',
                                                             min=1,max=1,
                                                            ), # end NOM_GROUP_MA_MASSIF
                                  REDUIT = SIMP(statut='f',
                                                fr="Introduction du mot-cle REDUIT pour le cas ou le nombre d'interface n'est pas identique entre le support et le ligne d'arbre",
                                                typ='TXM',
                                                into=("OUI"),
                                                defaut="OUI",
                                               ), # end REDUIT 
                                  # fin cft 20130422 modif
                                  #MODELE_COMPLET = SIMP(statut = 'o',
                                  #                      fr = "Parametres pour support generalisee",
                                  #                      typ='Fichier',
                                  #                      min=1,
                                  #                      max=1,
                                  #                      ), # end MODELE_COMPLET
                                  ), # end GENERALISE
                ) # end SUPPORT

############################# LIGNE_ARBRE ########################################
LIGNE_ARBRE = OPER(nom = 'LIGNE_ARBRE',
                    op = None,
                    sd_prod = LigneArbre,
                    reentrant = 'n',
                    UIinfo = {"groupes":("Machine tournante",)},
                    fr = "Description Ligne d'arbre  ",
                    DIRECTION = SIMP(statut='o',
                                     typ=Direction,
                                     min=1,
                                     max=1,
                                     ), # end DIRECTION
                    ZONES = SIMP(statut='o', 
                                 typ=Zone, 
                                 min=1, 
                                 max='**',
                                 ), # end ZONES
                    PALIERS = SIMP(statut='o',
                                   typ=Palier,
                                   min=2,
                                   max='**',
                                   ), # end PALIERS
                    #MASSES = SIMP(statut='f',
                                  #typ=Masse, 
                                  #max='**',
                                  #), # end MASSES
                    #POIDS_PROPRE = SIMP(statut='f',
                                       #fr= "Poids propre",
                                       #typ='TXM', 
                                       #into=('OUI', 'NON'),
                                       #defaut='NON',
                                       #), # end POIDS_PROPRE
                    SUPPORTS = SIMP(statut='o', 
                                    typ=Support, 
                                    min=1, 
                                    max='**',
                                    ), # end SUPPORTS
                    ) # end LIGNE_ARBRE

