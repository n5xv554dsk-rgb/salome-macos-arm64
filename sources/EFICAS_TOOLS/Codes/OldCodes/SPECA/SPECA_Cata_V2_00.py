## -*- coding: utf-8 -*-
#
## --------------------------------------------------
## debut entete
## --------------------------------------------------
#
from Accas import *


# rend disponible le type tuple (liste)
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



#
#CONTEXT.debug = 1

VERSION_CATALOGUE="2.0.0";

JdC = JDC_CATA ( code = 'SPECA',
                execmodul = None,
                regles=(AU_MOINS_UN('SPECIFICATION_ANALYSE',),
                        AU_PLUS_UN('SPECIFICATION_ANALYSE',),
                        ),
                       )# Fin JDC_CATA

## ----- SPECIFICATION DE L'ETUDE ----- ##
SPECIFICATION_ANALYSE= MACRO (nom       = 'SPECIFICATION_ANALYSE',
              op        = None,
              UIinfo    = {"groupes":("Machine tournante",)},
              fr        = "Specification des analyses",
              TYPE_ANALYSE     = SIMP(statut='o', typ='TXM',into=('STATIQUE', 'MODALE', 'HARMONIQUE', 'TRANSITOIRE', 'TRANSITOIRE_ACCIDENTEL','SYNTHESE')),
              # pour V1.1 flexion uniquement
              #TYPE_COMPORTEMENT = SIMP(statut='o', typ='TXM',into=('FLEXION'),defaut='FLEXION',fr="Renseignement du type de comportement voulu"),
              TYPE_COMPORTEMENT = BLOC(condition = "TYPE_ANALYSE in ('MODALE','HARMONIQUE','STATIQUE','TRANSITOIRE','TRANSITOIRE_ACCIDENTEL','SYNTHESE')",
                                        FLEXION = SIMP(statut='o',typ='TXM',into=('OUI',),defaut='OUI',fr="Prise en compte la flexion de la ligne d'arbres: obligatoire"),
                                        TORSION = SIMP(statut='f',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Choix de la prise en compte la torsion de la ligne d'arbres"),
                                        COMPRESSION = SIMP(statut='f',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Choix de la prise en compte la traction/compression de la ligne d'arbres"),
                                      ),

         	  SURCHARGE=BLOC(condition = "TYPE_ANALYSE in ('MODALE','HARMONIQUE','STATIQUE','TRANSITOIRE','TRANSITOIRE_ACCIDENTEL','SYNTHESE')",statut="f",
         	  				TEMPLATE=SIMP(	statut="f",
         	  						typ=("Fichier","Fichier Template (*.tpl)"),
         	  						min=1,max=1,
                                                                fr="Utiliser un template d'analyse modifie"
         	  						),
         	  				PARAMETRES= FACT(statut='f',min=1,max='**',fr="Definition et renseignement des parametres utilises dans le template surcharge",
         	  								CLE=SIMP(statut='o',typ='TXM',defaut=None,fr="Nom du parametre dans le template"),
         	  								TYPE=SIMP(statut='o',typ='TXM',into=('ENTIER','REEL','CHAINE','FICHIER','REPERTOIRE'),fr="Nature du parametre a renseigner"),
         	  								ENTIER=BLOC(condition="TYPE=='ENTIER'",
         	  									VALUE=SIMP(statut='o',typ='I',defaut=0,fr="Renseignement d'un nombre entier"),
         	  									),
         	  								REEL=BLOC(condition="TYPE=='REEL'",
         	  									VALUE=SIMP(statut='o',typ='R',defaut=0.0,fr="Renseignement d'un nombre reel"),
         	  									),
         	  								CHAINE=BLOC(condition="TYPE=='CHAINE'",
         	  									VALUE=SIMP(statut='o',typ='TXM',defaut='',fr="Renseignement d'une chaine de caracteres"),
         	  									),
         	  								FICHIER=BLOC(condition="TYPE=='FICHIER'",
         	  									VALUE=SIMP(statut='o',typ=("Fichier","All files (*.*)"),fr="Renseignement d'un fichier")
         	  									),
				                                                REPERTOIRE =BLOC(condition="TYPE=='REPERTOIRE'",
         	  									VALUE=SIMP(statut='o',typ="Repertoire",fr="Renseignement d'un repertoire")
         	  									),

         	  							),
         	  	),



### ----- CALCUL STATIQUE ----- ##
              ANALYSE_STATIQUE = BLOC(condition = "TYPE_ANALYSE == 'STATIQUE' ",fr="Analyse statique (vitesse de rotation nulle de la ligne d'arbres)"
              
                      CHARGES= FACT(statut='o',min=1,max='**',fr="Definition et renseignement du chargement applique",
                      TYPE = SIMP(statut='o',typ='TXM',into=('POIDS','FORCE','MOMENT','DELIGNAGE'),defaut=None,min=1,max=1,fr="Choix du type de chargement a appliquer"),
                      POIDS = BLOC(condition = "TYPE == 'POIDS' ",fr="Prise en compte du champ de pesanteur",
				              GRAVITE = SIMP(statut='o',typ='R',defaut=9.81,fr="Renseignement de l'intensite de la gravite (m/s^2)"),
				              DIRECTION = SIMP(statut='o',typ='R',min=3,max=3,defaut=(1,0,0),fr="Renseignement de la direction de la force de gravite"),
                      ), # fin POIDS
                      FORCE = BLOC(condition = "TYPE == 'FORCE' ",fr="Application d'une force ponctuelle",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique la force (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant la force (N)"),
				              #FONC_APPLI = SIMP(statut='f',typ='R',min=2,max=2,defaut=None,fr="Renseignement de la fonction appliquee"),
                      ), # fin FORCE
                      MOMENT = BLOC(condition = "TYPE == 'MOMENT' ",fr="Application d'un moment ponctuel",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique le moment (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant le moment (N/m)"),
                      ), # fin MOMENT
                      DELIGNAGE = BLOC(condition = "TYPE == 'DELIGNAGE' ",fr="Application d'un delignage sur un ou plusieurs paliers",
                              NOM_PALIER = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom du palier deligne"),
                              DX = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du delignage suivant X du palier (m)"),
                              DY = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du delignage suivant Y du palier (m)"),
                      ), # fin Delignage
                      ), #fin CHARGES
                     
                      ## POST-TRAITEMENTS DU CALCUL STATIQUE
		      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Definition et renseignement des post-traitements",
		          TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','REAC_NODA','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
                          DEPL = BLOC(condition="TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',defaut=None,fr="Renseignement de la coordonnee du deplacement"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
                          ), # fin DEPL
                          CONTRAINTES = BLOC(condition="TYPE == 'CONTRAINTES' ",fr="Export des contraintes",regles=UN_PARMI('POSITION','ZONE','TOUT'),
                              POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
                              ZONE = SIMP(statut='f',typ='TXM',defaut=None,fr="Renseignement de la zone de la contrainte"),
                              TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),fr="Export pour tous les noeuds"),
                          ), # fin CONTRAINTES
                          REAC_NODA = BLOC(condition="TYPE == 'REAC_NODA' ", fr="Reaction nodale",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la reaction"),
                              #ZONE = SIMP(statut='f',typ='TXM',defaut=None,fr="Renseignement de l'etiquette de la zone de la reaction"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
                          ), # fin REAC_NODA
		      ), # fin POST_TRAITEMENT
                      ## fin bloc POST_TRAITEMENTS
                      
              ),# fin ANALYSE_STATIQUE

### ----- CALCUL MODALE ----- ##
              ANALYSE_MODALE = BLOC(condition = "TYPE_ANALYSE == 'MODALE' ",fr="Analyse modale de la ligne d'arbres"
                      BASE_CALCUL = SIMP(statut='o',typ="TXM",into=('MODALE','PHYSIQUE'),defaut=None,fr="Choix du type de resolution de l'analyse modale (sur base physique ou sur base modale)"),
                      BASE_MODALE = BLOC(condition="BASE_CALCUL=='MODALE'",fr="Resolution sur base modale",
                                         regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                         NB_MODES=SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de modes constituant la base de projection"),
                                         FREQ_MAX=SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale des modes constituant la base de projection (Hz)"),
                      ), # fin BASE_MODALE
                      AMORTISSEMENT = SIMP(statut='o',typ='TXM',min=1,max=1,into=('OUI','NON'),defaut='OUI',fr="Choix de la prise en compte de l'amortissment"),
                      GYROSCOPIE = SIMP(statut='o',typ='TXM',min=1,max=1,into=('OUI','NON'),defaut='OUI',fr="Choix de la prise en compte de la gyroscopie"),
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la liste des vitesses de rotation etudiees (tr/min)"),
		      OPTION_CALCUL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('PLUS_PETITE','CENTRE'),defaut=None,fr="Choix de l'option de calcul"),
                      PLUS_PETITE = BLOC(condition="OPTION_CALCUL=='PLUS_PETITE'",fr="Option PLUS_PETITE",fr="Calcul des n premieres frequences"
			      NMAX_FREQ = SIMP(statut='o',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre maximal de frequences a calculer"),
                      ), # fin PLUS_PETITE
                      CENTRE = BLOC(condition="OPTION_CALCUL=='CENTRE'",fr="Option CENTRE",fr="Calcul d'un nombre n de frequences autour d'une frequence donnee"
			      FREQ = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence centrale (Hz)"),
			      NMAX_FREQ = SIMP(statut='o',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre maximal de frequences"),
                      ), # fin CENTRE
                      METHODE=SIMP(statut='f',typ='TXM',min=1,max=1,into=('QZ','SORENSEN'),defaut='SORENSEN',fr="Choix de la methode de resolution"),
                      
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Definition et renseignement des post-traitements",
			      TYPE = SIMP(statut='o',typ='TXM',defaut=None,into=('TABLEAU_PARAM_MODAUX','DIAG_CAMPBELL'),fr="Choix du type de post-traitement",),
			      #TABLEAU_PARAM_MODAUX = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,into=('SIMPLE','COMPLET'),fr="Choix du type de tableau"),
			      TABLEAU_PARAM_MODAUX = BLOC(condition = "TYPE == 'TABLEAU_PARAM_MODAUX'",fr="Choix du type de tableau",
			              TABLEAU = SIMP(statut='o',max=1,typ='TXM',defaut='SIMPLE',into=('SIMPLE','COMPLET'),),
			      ), # fin TABLEAU_PARAM_MODAUX
			      DIAG_CAMPBELL = BLOC(condition = "TYPE == 'DIAG_CAMPBELL'", fr = "Choix des options du diagramme de Campbell",
			              PRECESSION = SIMP(statut='o',typ='TXM',max=1,defaut=None,into=('SOMME','PLUS_GRANDE_ORBITE'),fr="Critere de determination de la precession"),
			              SUIVI = SIMP(statut='o',typ='TXM',max=1,defaut=None,into=('SANS_TRI','TRI_PREC','TRI_FORM_MOD'),fr="Methode de suivi des modes"),
                                      # 20121018 ajout de NB_MODES a la demande de Ionel Nistor
				      NB_MODES = SIMP(statut='o',typ='I',max=1,defaut=None,fr="Nombre de modes affiches dans le diagramme, doit etre inferieur au nombre de modes calcules (NMAX_FREQ)"),
			      ), # fin DIAG_CAMPBELL
			      #DIAG_CAMPBELL = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,into=('OUI','NON'),fr="Choix de calcul du diagramme de Campbell (uniquement si plusieurs vitesses de rotation ont ete renseignees)",),
                      ), # fin POST_TRAITEMENTS
                      
                      
              ), # fin ANALYSE_MODALE

## ----- CALCUL HARMONIQUE ----- ##
              ANALYSE_HARMONIQUE = BLOC(condition = "TYPE_ANALYSE == 'HARMONIQUE' ",fr="Analyse harmonique de la ligne d'arbres",
              
                      ## specification calcul harmonique
	              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('PHYSIQUE','MODALE'),defaut=None,fr="Choix du type de resolution de l'analyse modale (sur base physique ou sur base modale)"),
		      BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Resolution sur base modale",
		              #MODALE = FACT(statut='o',
		                      regles=UN_PARMI('NB_MODES','FREQ_MAX'),
	                              NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de modes constituant la base de projection"),
			              FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale des modes constituant la base de projection (Hz)"),
			      #),# fin MODALE
		      ),# fin BASE_MODALE
		      AMORTISSEMENT_P = BLOC(condition = "BASE_CALCUL == 'PHYSIQUE' ",
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      ), # fin AMORTISSEMENT_P
		      AMORTISSEMENT_M = BLOC(condition = "BASE_CALCUL == 'MODALE' ",
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		              AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                      #AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		                      AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes constituant la base de projection"),
		              ),# fin AMOR_MODALE
		      ), # fin AMORTISSEMENT_M
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la liste des vitesses de rotation etudiees (tr/min)"),
                      # 20121018 retrait de defaut_fn a la demande de EDF
                      CHARGES= FACT(statut='o',min=1,max='**',fr="Definition et renseignement du chargement applique",
                      TYPE = SIMP(statut='o',typ='TXM',into=('BALOURD','HARMONIQUE'),defaut=None,min=1,max=1,fr="Choix du type de chargement a appliquer"),
                      BALOURD = BLOC(condition = "TYPE == 'BALOURD' ",fr="Chargement de type balourd",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique le balourd (m)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude du balourd (kg.m)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (degres)"),
                      ),# fin BALOURD
                      HARMONIQUE = BLOC(condition = "TYPE == 'HARMONIQUE' ",fr="Charge harmonique",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique la charge harmonique (m)"),
                              FREQUENCE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence d'excitation harmonique (Hz)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude de la charge harmonique, (N)"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la liste de coefficients appliques sur la charge harmonique (autant que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge harmonique (degres)"),
                              TYPE_DDL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('DX','DRX','DY','DRY','DZ','DRZ'),defaut=None,fr="Renseignement du DDL sur lequel s'applique la charge harmonique"),
                      ), # fin HARMONIQUE
                      ), #FIN CHARGES
                      ## POST-TRAITEMENTS DU CALCUL HARMONIQUE
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Definition et renseignement des post-traitements",
		          TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_RELA','REAC_NODA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			  DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',defaut=None,fr="Renseignement de la coordonnee du deplacement"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
			  ), # fin DEPL
			  CONTRAINTES = BLOC(condition="TYPE == 'CONTRAINTES' ",fr="Export des contraintes",regles=UN_PARMI('POSITION','ZONE','TOUT'),
				  POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				  ZONE = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la zone de la contrainte"),
				  TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),min=1,max=1,fr="Export pour tous les noeuds"),
			  ), # fin CONTRAINTES
		      ),
		      ## fin bloc POST_TRAITEMENTS
                      
              ),# fin ANALYSE_HARMONIQUE

### ----- CALCUL TRANSITOIRE ----- ##
              ANALYSE_TRANSISTOIRE = BLOC(condition = "TYPE_ANALYSE == 'TRANSITOIRE' ",fr="Analyse transitoire de la ligne d'arbres",
                      
                      VITESSE = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,into=('CONSTANTE','VARIABLE'),fr="Renseignement du type de vitesse de rotation consideree"),
                      BASE_C = BLOC(condition ="VITESSE == 'CONSTANTE'",fr="Analyse transitoire a vitesse constante"
                              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('PHYSIQUE','MODALE'),defaut=None,fr="Choix du type de resolution de l'analyse transitoire (sur base physique ou sur base modale)"),
                              BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Resolution sur base modale",
	                                        regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                                NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de modes constituant la base de projection"),
		                                FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale des modes constituant la base de projection (Hz)"),
		              ),# fin BASE_MODALE
		              AMORTISSEMENT_M = BLOC(condition = "BASE_CALCUL == 'MODALE' ",
		                      AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		                      AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                              AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes constituant la base de projection"),
		                      ),# fin AMOR_MODALE
		              ), # fin AMORTISSEMENT_M
                      ), # fin BASE_C
                      BASE_V = BLOC(condition ="VITESSE == 'VARIABLE'",fr="Analyse transitoire a vitesse variable"
                              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('MODALE'),defaut='MODALE',fr="Choix du type de resolution de l'analyse transitoire (obligatoirement sur base modale)"),
                              BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Resolution sur base modale",
	                                         regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                      NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de modes constituant la base de projection"),
		                      FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale des modes constituant la base de projection (Hz)"),
		              ),# fin BASE_MODALE
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		              AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                      #AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		                      AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes constituant la base de projection"),
		              ),# fin AMOR_MODALE
                      ), # fin BASE_C
		      VITESSE_CONSTANTE = BLOC(condition = "VITESSE == 'CONSTANTE' ", fr="Vitesse de rotation constante",
                              VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation (tr/min)"),
                      ),# fin VITESSE_CONSTANTE
                      VITESSE_VARIABLE = BLOC(condition = "VITESSE == 'VARIABLE' ", fr="Vitesse de rotation variable", regles=UN_PARMI('LINEAIRE','EXPONENTIELLE','FORMULE'),
                              LINEAIRE = FACT(statut='f',min=1,max=1,fr="Variation lineaire de la vitesse de rotation",
                                      VITESSE_INITIALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation initiale (tr/min)",),
                                      VITESSE_FINALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation finale (tr/min)",),
                                      DEPHASAGE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la postion angulaire initiale (degres)"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement du pas de mise a jour des matrices des paliers (tr/min)"),
                              ),# fin LINEAIRE
                              EXPONENTIELLE = FACT(statut='f',min=1,max=1,fr="Variation exponentielle de la vitesse de rotation",
                                      VITESSE_INITIALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation initiale (tr/min)",),
                                      VITESSE_FINALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation finale (tr/min)",),
                                      DEPHASAGE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la postion angulaire initiale (degres)"),
                                      LAMBDA = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du parametre de la loi exponentielle (Hz)"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement du pas de mise a jour des matrices des paliers (tr/min)"),
                              ),# fin EXPONENTIELLE
                              FORMULE = FACT(statut='f',min=1,max=1,fr="Fonction personnalisee decrivant la variation de la vitesse de rotation",
                                      FICHIER = SIMP(statut='o',typ=('Fichier','Formule vitesse rotation (*.*)'),min=1,max=1,defaut=None,fr="Renseignement du fichier contenant les fonctions de la vitesse de rotation"),
                                      PHI = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule de position angulaire (max 8 caractere)"),
                                      OM = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule de vitesse angulaire (max 8 caractere)"),
                                      ACC = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule d'acceleration angulaire (max 8 caractere)"),
                                      VITE_MOY = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la moyenne des vitesses balayees (tr/min)"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max='**',defaut=None,fr="Renseignement du pas de mise a jour des matrices des paliers (tr/min)"),
                              ),# fin FORMULE
                      ),# fin VITESSE_VARIABLE
                      #POIDS = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='OUI',fr="Choix d'application d'un poids"),

                      CHARGES= FACT(statut='o',min=1,max='**',fr="Definition et renseignement du chargement applique",
                      TYPE = SIMP(statut='o',typ='TXM',into=('POIDS','BALOURD','FORCE','MOMENT','HARMONIQUE'),defaut=None,min=1,max=1,fr="Choix du type de chargement a appliquer"),
                      BALOURD = BLOC(condition = "TYPE == 'BALOURD' ",fr="Chargement de type balourd",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique le balourd (m)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude du balourd (kg.m)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (degres)"),
                              INST_APPLI= SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseignement de l'instant d'apparition du balourd (s)"),
                              TEMPS_MONTEE=SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseignement du temps necessaire pour atteindre l'amplitude nominale du balourd (s)"),
                      ),# fin BALOURD
                      POIDS = BLOC(condition = "TYPE == 'POIDS' ",fr="Prise en compte du champ de pesanteur",
				              GRAVITE = SIMP(statut='o',typ='R',defaut=9.81,fr="Renseignement de l'intensite de la gravite (m/s^2)"),
				              DIRECTION = SIMP(statut='o',typ='R',min=3,max=3,defaut=(1,0,0),fr="Renseignement de la direction de la force de gravite"),
                      ), # fin POIDS
                      FORCE = BLOC(condition = "TYPE == 'FORCE' ",fr="Application d'une force ponctuelle",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique la force (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant la force (N)"),
				              #FONC_APPLI = SIMP(statut='f',typ='R',min=2,max=2,defaut=None,fr="Renseignement de la fonction appliquee"),
                      ), # fin FORCE
                      MOMENT = BLOC(condition = "TYPE == 'MOMENT' ",fr="Application d'un moment ponctuel",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique le moment (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant le moment (N/m)"),
                      ), # fin MOMENT
                      HARMONIQUE = BLOC(condition = "TYPE == 'HARMONIQUE' ",fr="Charge harmonique",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique la charge harmonique (m)"),
                              FREQUENCE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence d'excitation harmonique (Hz)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude de la charge harmonique, (N)"),
                              #FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge harmonique (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge harmonique (degres)"),
                              TYPE_DDL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('DX','DRX','DY','DRY','DZ','DRZ'),defaut=None,fr="Renseignement du DDL sur lequel s'applique la charge harmonique"),
                      ), # fin HARMONIQUE
                      ), #fin CHARGES

                      ETAT_INIT = FACT(statut='o',fr="Renseignement de l'etat initial du calcul",
                              #RESULTAT = SIMP(statut='o',typ=('sd_resultat'),max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              RESULTAT = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Choix de la structure de donnees de type 'resultat' de Code_Aster"),
                              INST_INIT = SIMP(statut='f',typ='R',max=1,defaut=0.0,fr="Renseignement de l'instant de la structure de donnees a partir duquel il faut lancer le calcul (s)"),
                      ), # fin ETAT_INIT
                      PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS','LISTE'),defaut=None,fr="Choix du type de discretisation temporelle"),
                      #PAS = BLOC(condition = "VITESSE == 'VARIABLE'",fr="Renseignement des parametres des pas",
                      PAS = BLOC(condition = "PARAM_TEMPS == 'PAS'",fr="Renseignement de pas de temps",
                              TEMPS_PAS = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps d'integration(en s)"),
                              INST_INI = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de l'instant initial du calcul (s)"),
                              INST_FIN = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement de l'instant final du calcul (s)"),
                      ), # fin TEMPS_PAS
                      LIST_INST = BLOC(condition = "PARAM_TEMPS == 'LISTE'",fr="Renseignement d'une liste d'instants",
                              LISTE = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement d'une liste d'instants auxquels resoudre le calcul (s)"),
                      ), # fin LIST_INST
                      PAS_ARCHIVAGE = SIMP(statut='o',typ='I',max=1,defaut=1,fr="Renseignement du pas d'archivage des resultats (une sauvegarde tous les 'PAS_ARCHIVAGE' instants d'integration)",),
                      SCHEMA_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('NEWMARK','EULER','WILSON','ADAPT_ORDRE1','ADAPT_ORDRE2','DIFF_CENTRE'),defaut='NEWMARK',fr="Choix d'un schema d'integration temporelle"),
                      NEWMARK = BLOC(condition = "SCHEMA_TEMPS == 'NEWMARK' ",fr="Methode de NEWMARK",
                              BETA = SIMP(statut='f',typ='R',max=1,defaut=0.25,fr="Renseignement de la valeur beta pour la methode de NEWMARK"),
                              GAMMA = SIMP(statut='f',typ='R',max=1,defaut=0.25,fr="Renseignement de la valeur gamma pour la methode de NEWMARK"),
                      ),# fin NEWMARK
                      WILSON = BLOC(condition = "SCHEMA_TEMPS == 'WILSON' ",fr="Methode de WILSON",
                              THETA = SIMP(statut='f',typ='R',max=1,defaut=1.4,fr="Renseignement de la valeur theta pour la methode de WILSON"),
                      ), # fin WILSON
                      
                      ## POST_TRAITEMENTS de l'analyse transitoire
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Definition et renseignement des post-traitements",
			      TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			      DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
				      #POSITION_DEPL = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      PALIER = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      ), # fin DEPL
			      CONTRAINTES = BLOC(condition = "TYPE == 'CONTRAINTES' ",fr="Export des contraintes",
						regles=UN_PARMI('POSITION','ZONE','TOUT'),
				      POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				      ZONE = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette de la zone de la contrainte"),
				      TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),max=1,fr="Export pour tous les noeuds"),
			      ), # fin CONTRAINTES
		      ), # fin POST_TRAITEMENTS
              
              ), # fin ANALYSE_TRANSISTOIRE
              

### ----- CALCUL COUPLE CODE_ASTER/EYDOS ----- ##
              ANALYSE_TRANSITOIRE_ACCIDENTEL = BLOC(condition = "TYPE_ANALYSE == 'TRANSITOIRE_ACCIDENTEL' ",fr="Analyse transitoire accidentelle de la ligne d'arbres",
                      #BASE_MODALE = FACT(statut='o', fr="Choix des parametres de la base modale",	              		   
		      #POIDS = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='OUI',fr="Choix d'application d'un poids"),
		      BASE_MODALE = BLOC(condition = "True", fr="Resolution sur base modale",
	                                 regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                              NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de modes constituant la base de projection"),
		              FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale des modes constituant la base de projection (Hz)"),
		      ),# fin BASE_MODALE      
                      # cft 20131217 suppression amortissement reduit
		      #AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL','REDUIT'),defaut=None,fr="Choix du type d'amortissement"),
		      AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		              #LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		              LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements modaux reduits (en %), la taille de la liste doit etre egale au nombre de modes constituant la base de projection"),
		      ),# fin AMOR_REDUIT
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation (tr/min)"),

                      CHARGES= FACT(statut='o',min=1,max='**',fr="Definition et renseignement du chargement applique",
                      TYPE = SIMP(statut='o',typ='TXM',into=('POIDS','BALOURD','FORCE','MOMENT','HARMONIQUE'),defaut=None,min=1,max=1,fr="Choix du type de chargement a appliquer"),
                      BALOURD = BLOC(condition = "TYPE == 'BALOURD' ",fr="Chargement de type balourd",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique le balourd (m)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude du balourd (kg.m)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (degres)"),
                              INST_APPLI= SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseignement de l'instant d'apparition du balourd (s)"),
                              TEMPS_MONTEE=SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseignement du temps necessaire pour atteindre l'amplitude nominale du balourd (s)"),
                      ),# fin BALOURD
                      POIDS = BLOC(condition = "TYPE == 'POIDS' ",fr="Prise en compte du champ de pesanteur",
				              GRAVITE = SIMP(statut='o',typ='R',defaut=9.81,fr="Renseignement de l'intensite de la gravite (m/s^2)"),
				              DIRECTION = SIMP(statut='o',typ='R',min=3,max=3,defaut=(1,0,0),fr="Renseignement de la direction de la force de gravite"),
                      ), # fin POIDS
                      FORCE = BLOC(condition = "TYPE == 'FORCE' ",fr="Application d'une force ponctuelle",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique le moment (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant le moment (N/m)"),
				              #FONC_APPLI = SIMP(statut='f',typ='R',min=2,max=2,defaut=None,fr="Renseignement de la fonction appliquee"),
                      ), # fin FORCE
                      MOMENT = BLOC(condition = "TYPE == 'MOMENT' ",fr="Application d'un moment ponctuel",
				              POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la position axiale ou s'applique le moment (m)"),
				              MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des 3 composantes decrivant le moment (N/m)"),
                      ), # fin MOMENT
                      HARMONIQUE = BLOC(condition = "TYPE == 'HARMONIQUE' ",fr="Charge harmonique",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la position axiale ou s'applique la charge harmonique (m)"),
                              FREQUENCE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence d'excitation harmonique (Hz)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de l'amplitude de la charge harmonique, (N)"),
                              #FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge harmonique (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge harmonique (degres)"),
                              TYPE_DDL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('DX','DRX','DY','DRY','DZ','DRZ'),defaut=None,fr="Renseignement du DDL sur lequel s'applique la charge harmonique"),
                      ), # fin HARMONIQUE
                      ), #fin CHARGES
                      ETAT_INIT = FACT(statut='o',fr="Renseignement de l'etat initial du calcul",
                              #RESULTAT = SIMP(statut='o',typ=('sd_resultat'),max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              # 20121126
                              #RESULTAT = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              INST_INIT = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de l'instant initial a partir duquel il faut lancer le calcul (s)"),
                      ), # fin ETAT_INIT
                      #PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS','LIST_INST'),defaut=None,fr="Choix du type de parametrage temporel"),
                      # 20121126
                      PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS'),defaut="PAS",fr="Choix du type de discretisation temporelle",),
                      PAS = BLOC(condition = "PARAM_TEMPS == 'PAS' ",fr="Renseignement de pas de temps",
                              PAS_ASTER = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps d'integration Code_Aster (en s)",),
                              PAS_EDYOS = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps d'integration Edyos (en s)",),
                              INST_FIN = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement de l'instant final du calcul (en s)",),
                      ), # fin TEMPS_PAS
                      #LIST_INST = BLOC(condition = "PARAM_TEMPS == 'LIST_INST' ",fr="Renseignement d'une liste de pas",
                              #LISTE = SIMP(statut='f',typ='R',min=1,max='**',defaut=None,fr="Renseignement d'une liste de pas"),
                      #), # fin LIST_INST
                      PAS_ARCHIVAGE = SIMP(statut='o',typ='I',max=1,defaut=1,fr="Renseignement du pas d'archivage des resultats (une sauvegarde tous les 'PAS_ARCHIVAGE' instants d'integration)",),
                      PARA_MEM = SIMP(statut='f',typ='I',max=1,defaut=6400,fr="Renseigner la taille maximale de la memoire (Mo)",),
                      PARA_CPU = SIMP(statut='f',typ='I',max=1,defaut=10000,fr="Renseigner le temps CPU maximal (s)",),
                      SCHEMA_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('EULER','ADAPT_ORDRE1','ADAPT_ORDRE2'),defaut='ADAPT_ORDRE2',fr="Choix d'un schema d'integration temporelle"),
                      
                      ## POST_TRAITEMENTS de l'analyse transitoire
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Definition et renseignement des post-traitements",
			      TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			      DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",
				      POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      PALIER = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      ), # fin DEPL
			      # pas d'info à rentrer pour les efforts palier (post-traitement sur tout les paliers)
			      #EFFORTS_PAL = BLOC(condition = "TYPE == 'EFFORTS_PAL'", fr = "Efforts paliers",
			          #PALIER = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      #), # fin EFFORTS_PAL
			      CONTRAINTES = BLOC(condition = "TYPE == 'CONTRAINTES' ",fr="Export des contraintes",
						regles=UN_PARMI('POSITION','ZONE','TOUT'),
				      POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				      ZONE = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette de la zone de la contrainte"),
				      TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),max=1,fr="Export pour tous les noeuds"),
			      ), # fin CONTRAINTES
		      ), # fin POST_TRAITEMENTS
                      
                      
              ), # fin ANALYSE_TRANSITOIRE_ACCIDENTEL
                 
)# fin SPECIFICATION_ANALYSE
