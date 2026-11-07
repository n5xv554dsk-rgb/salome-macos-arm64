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
              TYPE_COMPORTEMENT = BLOC(condition = "TYPE_ANALYSE in ('MODALE','HARMONIQUE','STATIQUE','TRANSITOIRE','TRANSITOIRE_ACCIDENTEL','SYNTHESE')",
                                        FLEXION = SIMP(statut='o',typ='TXM',into=('OUI',),defaut='OUI',fr="Inclure la flexion ?"),
                                        TORSION = SIMP(statut='f',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Inclure la torsion ?"),
                                        COMPRESSION = SIMP(statut='f',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Inclure la compression ?"),
                                      ),
### ----- CALCUL STATIQUE ----- ##
              ANALYSE_STATIQUE = BLOC(condition = "TYPE_ANALYSE == 'STATIQUE' ",
              
                      POIDS = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='OUI',fr="Choix d'application d'un poids"),
                      CHARGES = SIMP(statut='o',typ='TXM',into=('DELIGNAGE','FORCE','AUCUNE'),defaut=None,fr="Choix d'application d'une charge"),
                      DELIGNAGE = BLOC(condition = "CHARGES == 'DELIGNAGE' ",fr="Application d'un delignage",
                              PARAM_DELIGNAGE = FACT(statut='o',min=1,max='**',fr="Parametres du delignage",
			              NOM_PALIER = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom d'un palier deligne"),
				      #VALEURS = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des valeurs du delignage du palier"),
				      DX = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du DX du delignage du palier"),
				      DY = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du DY du delignage du palier"),
		              ), # fin PARAM_DELIGNAGE
                      ), # fin DELIGNAGE
                      # min=1,max=2,
                      FORCE = BLOC(condition = "CHARGES == 'FORCE' ",fr="Application d'une force",
                              PARAM_FORCE = FACT(statut='o',min=1,max='**',fr="Parametres de la force",
				      POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la coordonnee de la force"),
				      MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement de la magnitude de la force"),
				      FONC_APPLI = SIMP(statut='f',typ='R',min=2,max=2,defaut=None,fr="Renseignement de la fonction appliquee"),
                              ), # fin PARAM_FORCE
                      ), # fin FORCE
                      ## fin specification calcul statique
                      
                      ## POST-TRAITEMENTS DU CALCUL STATIQUE
		      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Choix du type de post-traitement",
		          TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','REAC_NODA','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
                          DEPL = BLOC(condition="TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',defaut=None,fr="Renseignement de la coordonnee du deplacement"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
                          ), # fin DEPL
                          CONTRAINTES = BLOC(condition="TYPE == 'CONTRAINTES' ",fr="Contraintes",regles=UN_PARMI('POSITION','ZONE','TOUT'),
                              POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
                              ZONE = SIMP(statut='f',typ='TXM',defaut=None,fr="Renseignement de la zone de la contrainte"),
                              TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),fr="Choix de toutes les containtes"),
                          ), # fin CONTRAINTES
                          #REAC_NODA = BLOC(condition="TYPE == 'REAC_NODA' ", fr="Reaction nodale",regles=UN_PARMI('POSITION','ZONE','TOUT'),
                          #REAC_NODA = BLOC(condition="TYPE == 'REAC_NODA' ", fr="Reaction nodale",regles=UN_PARMI('POSITION','TOUT'),
                          REAC_NODA = BLOC(condition="TYPE == 'REAC_NODA' ", fr="Reaction nodale",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la reaction"),
                              #ZONE = SIMP(statut='f',typ='TXM',defaut=None,fr="Renseignement de l'etiquette de la zone de la reaction"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
                          ), # fin REAC_NODA
		      ), # fin POST_TRAITEMENT
                      ## fin bloc POST_TRAITEMENTS
                      
              ),# fin ANALYSE_STATIQUE

### ----- CALCUL MODALE ----- ##
              ANALYSE_MODALE = BLOC(condition = "TYPE_ANALYSE == 'MODALE' ",
                      BASE_CALCUL = SIMP(statut='o',typ="TXM",into=('MODALE','PHYSIQUE'),defaut=None,fr="Choix de la base du calcul modal"),
                      BASE_MODALE = BLOC(condition="BASE_CALCUL=='MODALE'",fr="Calcul sur base modale",
                                         regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                         NB_MODES=SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
                                         FREQ_MAX=SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
                      ), # fin BASE_MODALE
                      AMORTISSEMENT = SIMP(statut='o',typ='TXM',min=1,max=1,into=('OUI','NON'),defaut='OUI',fr="Choix de prise en compte de l'amortissment"),
                      GYROSCOPIE = SIMP(statut='o',typ='TXM',min=1,max=1,into=('OUI','NON'),defaut='OUI',fr="Choix de prise en compte de la gyroscopie"),
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la liste des vitesses de rotation (tr/min)"),
		      OPTION_CALCUL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('PLUS_PETITE','CENTRE'),defaut=None,fr="Choix de l'option de calcul"),
		      # 20121018 EDF demande de retirer cette option : l'option bande ne fonctionne pas avec MODE_ITER_SIMULT
		      #OPTION_CALCUL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('BANDE','PLUS_PETITE','CENTRE'),defaut=None,fr="Choix de l'option de calcul"),
                      #BANDE = BLOC(condition="OPTION_CALCUL=='BANDE'",fr="Option BANDE",
			#      FREQ_MIN = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence minimale (Hz)"),
			#     FREQ_MAX = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale (Hz)"),
                      #), # fin BANDE
                      PLUS_PETITE = BLOC(condition="OPTION_CALCUL=='PLUS_PETITE'",fr="Option PLUS_PETITE",
			      NMAX_FREQ = SIMP(statut='o',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre maximal de frequence"),
                      ), # fin PLUS_PETITE
                      CENTRE = BLOC(condition="OPTION_CALCUL=='CENTRE'",fr="Option CENTRE",
			      FREQ = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence centrale (Hz)"),
			      NMAX_FREQ = SIMP(statut='o',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre maximal de frequence"),
                      ), # fin CENTRE
                      METHODE=SIMP(statut='f',typ='TXM',min=1,max=1,into=('QZ','SORENSEN'),defaut='SORENSEN',fr="Choix de la méthode de résolution"),
                      
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Choix du type de post-traitement",
			      TYPE = SIMP(statut='o',typ='TXM',defaut=None,into=('TABLEAU_PARAM_MODAUX','DIAG_CAMPBELL'),),
			      #TABLEAU_PARAM_MODAUX = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,into=('SIMPLE','COMPLET'),fr="Choix du type de tableau"),
			      TABLEAU_PARAM_MODAUX = BLOC(condition = "TYPE == 'TABLEAU_PARAM_MODAUX'",fr="Choix du type de tableau",
			              TABLEAU = SIMP(statut='o',max=1,typ='TXM',defaut='SIMPLE',into=('SIMPLE','COMPLET'),),
			      ), # fin TABLEAU_PARAM_MODAUX
			      DIAG_CAMPBELL = BLOC(condition = "TYPE == 'DIAG_CAMPBELL'", fr = "Choix des options du diagramme de Campbell",
			              PRECESSION = SIMP(statut='o',typ='TXM',max=1,defaut=None,into=('SOMME','PLUS_GRANDE_ORBITE'),),
			              SUIVI = SIMP(statut='o',typ='TXM',max=1,defaut=None,into=('SANS_TRI','TRI_PREC','TRI_FORM_MOD'),),
                                      # 20121018 ajout de NB_MODES a la demande de Ionel Nistor
				      NB_MODES = SIMP(statut='o',typ='I',max=1,defaut=None,fr="Nombre de modes affiches dans le diagramme, doit etre inferieur au nombre de modes calcules"),
			      ), # fin DIAG_CAMPBELL
			      #DIAG_CAMPBELL = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,into=('OUI','NON'),fr="Choix de calcul du diagramme de Campbell (uniquement si plusieurs vitesses de rotation ont ete renseignees)",),
                      ), # fin POST_TRAITEMENTS
                      
                      
              ), # fin ANALYSE_MODALE

## ----- CALCUL HARMONIQUE ----- ##
              ANALYSE_HARMONIQUE = BLOC(condition = "TYPE_ANALYSE == 'HARMONIQUE' ",fr="Analyse harmonique",
              
                      ## specification calcul harmonique
	              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('PHYSIQUE','MODALE'),defaut=None,fr="Choix de la base du calcul harmonique"),
		      BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Calcul harmonique sur base modale",
		              #MODALE = FACT(statut='o',
		                      regles=UN_PARMI('NB_MODES','FREQ_MAX'),
	                              NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
			              FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
			      #),# fin MODALE
		      ),# fin BASE_MODALE
		      AMORTISSEMENT_P = BLOC(condition = "BASE_CALCUL == 'PHYSIQUE' ",
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      ), # fin AMORTISSEMENT_P
		      AMORTISSEMENT_M = BLOC(condition = "BASE_CALCUL == 'MODALE' ",
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		              # cft modif 20130603
		              #AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		              #        LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		              #),# fin AMOR_REDUIT
		              AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                      #AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		                      AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes"),
		              ),# fin AMOR_MODALE
		      ), # fin AMORTISSEMENT_M
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la liste des vitesses de rotation"),
                      # 20121018 retrait de defaut_fn a la demande de EDF
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','HARMONIQUE','DEFAUT_FN','EXTERNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','DELIGNAGE','HARMONIQUE','EXTERNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','HARMONIQUE','EXTERNE','AUCUNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      BALOURD = BLOC(condition = "CHARGES == 'BALOURD' ",fr="Charge balourd appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge balourd"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la magnitude de la charge balourd (en kg.m)"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge balourd (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (en degres)"),
                      ),# fin BALOURD
                      # 20121106 retrait de delgnage a le demande de EDF
                      #DELIGNAGE = BLOC(condition = "CHARGES == 'DELIGNAGE' ",fr="Application d'un delignage",
                              #PARAM_DELIGNAGE = FACT(statut='o',min=1,max='**',fr="Parametres du delignage",
			              #PALIERS = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom d'un palier deligne"),
				      #VALEURS = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des valeurs du delignage du palier"),
		              #), # fin PARAM_DELIGNAGE
                      #), # fin DELIGNAGE
                      HARMONIQUE = BLOC(condition = "CHARGES == 'HARMONIQUE' ",fr="Charge harmonique appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge harmonique"),
                              PUIS_PULS = SIMP(statut='o',typ='I',min=1,max=1,into=(0,1,2),defaut=None,fr="Renseignement de la puissance de pulsation de la charge harmonique"),
                              PULSATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la pulsation d'excitation harmonique (en rad/s)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la magnitude de la charge harmonique, (unite : N.s^i (avec i = PUIS_PULS))"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge harmonique (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge harmonique (en degres)"),
                              TYPE_DDL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('DX','DRX','DY','DRY'),defaut=None,fr="Renseignement du type de DDL excite sur lequel porte la charge"),
                      ), # fin HARMONIQUE
                      # 20121018 retrait de defaut_fn a la demande de EDF
                      #DEFAUT_FN = BLOC(condition = "CHARGES == 'DEFAUT_FN' ",fr="Charge defaut de fibre neutre appliquee",
                              #POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du defaut de fibre neutre"),
                              #TR_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Y du defaut de fibre neutre"),
                              #TR_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Z du defaut de fibre neutre"),
                              #ROT_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Y du defaut de fibre neutre"),
                              #ROT_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Z du defaut de fibre neutre"),
                      #), # fin DEFAUT_FN
                      EXTERNE = BLOC(condition = "CHARGES == 'EXTERNE' ",fr="Charge externe appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge externe"),
                              FONC_APPLI = SIMP(typ=('Fichier','Charge Externe (*.csv)'),docu='',min=1,max=1,statut='o',defaut=None,fr="Renseignement de la fonction appliquee à la charge externe (fichier cvs)"),
                      ), # fin EXTERNE
                      ## fin secification calcul harmonique
                      
                      # test cft 20120531
                      ## POST-TRAITEMENTS DU CALCUL HARMONIQUE
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Choix du type de post-traitement",
		          #TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
		          # 2012119 retrait de DEPL_ABS
		          #TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
		          # 20130513 ajout de REAC_NODA
		          TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_RELA','REAC_NODA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			  DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
                              POSITION = SIMP(statut='f',typ='R',defaut=None,fr="Renseignement de la coordonnee du deplacement"),
                              PALIER = SIMP(statut='f',max='**',typ='TXM',defaut=None,fr="Renseignement du nom du palier"),
			  ), # fin DEPL
			  # pas d'options pour EFFORTS_PAL et REAC_NODA
			  #EFFORTS_PAL = BLOC(condition = "TYPE == 'EFFORTS_PAL'", fr = "Efforts paliers",
			          #PALIER = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			  #), # fin EFFORTS_PAL
			  # BASE_CALCUL == 'MODALE'
			  CONTRAINTES = BLOC(condition="TYPE == 'CONTRAINTES' ",fr="Contraintes",regles=UN_PARMI('POSITION','ZONE','TOUT'),
				  POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				  ZONE = SIMP(statut='f',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la zone de la contrainte"),
				  TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),min=1,max=1,fr="Renseignement de la contrainte"),
			  ), # fin CONTRAINTES
		      ),
		      ## fin bloc POST_TRAITEMENTS
                      
              ),# fin ANALYSE_HARMONIQUE

### ----- CALCUL TRANSITOIRE ----- ##
              ANALYSE_TRANSISTOIRE = BLOC(condition = "TYPE_ANALYSE == 'TRANSITOIRE' ",fr="Analyse transitoire",
                      POIDS = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='OUI',fr="Choix d'application d'un poids"),
                      VITESSE = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,into=('CONSTANTE','VARIABLE'),fr="Renseignement du type de vitesse de rotation"),
                      BASE_C = BLOC(condition ="VITESSE == 'CONSTANTE'",
                              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('PHYSIQUE','MODALE'),defaut=None,fr="Choix de la base du calcul transitoire"),
                              BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Calcul transitoire sur base modale",
	                                         regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                      NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
		                      FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
		              ),# fin BASE_MODALE
		              AMORTISSEMENT_M = BLOC(condition = "BASE_CALCUL == 'MODALE' ",
		                      AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		                      # cft modif 20130603
		                      #AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                      #        LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		                      #),# fin AMOR_REDUIT
		                      AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                              AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes"),
		                      ),# fin AMOR_MODALE
		              ), # fin AMORTISSEMENT_M
                      ), # fin BASE_C
                      BASE_V = BLOC(condition ="VITESSE == 'VARIABLE'",
                              BASE_CALCUL = SIMP(statut='o',typ='TXM',into=('MODALE'),defaut='MODALE',fr="Choix de la base du calcul transitoire"),
                              BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Calcul transitoire sur base modale",
	                                         regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                                      NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
		                      FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
		              ),# fin BASE_MODALE
		              AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		              # cft modif 20130603
		              #AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		              #        LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		              #),# fin AMOR_REDUIT
		              AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		                      #AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		                      AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max='**',defaut=None,fr="Renseignement de l'amortissement modal reduit (en %), la taille de la liste doit etre egale au nombre de modes"),
		              ),# fin AMOR_MODALE
                      ), # fin BASE_C
                      #BASE_MODALE = BLOC(condition = "BASE_CALCUL == 'MODALE' ", fr="Calcul transitoire sur base modale",
	              #                   regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                      #        NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
		      #        FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
		      #),# fin BASE_MODALE
		      # cft modif 20130603
		      
		      #AMORTISSEMENT_P = BLOC(condition = "BASE_CALCUL == 'PHYSIQUE' ",
		      #        AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      #), # fin AMORTISSEMENT_P
		      #AMORTISSEMENT_M = BLOC(condition = "BASE_CALCUL == 'MODALE' ",
		      #        AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('REDUIT','STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      #        # cft modif 20130603
		      #        #AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		      #        #        LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		      #        #),# fin AMOR_REDUIT
		      #        AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		      #                AMOR_REDUIT = SIMP(statut='o', typ='R', min=1, max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		      #        ),# fin AMOR_MODALE
		      #), # fin AMORTISSEMENT_M
		      
		      
		      #AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL','REDUIT'),defaut=None,fr="Choix du type d'amortissement"),
		      #AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		      #        LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		      #),# fin AMOR_REDUIT
		      #AMOR_MODAL = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		      #        AMOR_REDUIT = SIMP(statut='o', typ='R', min=1,max=1,defaut=None,fr="Renseignement de l'amortissement modal reduit (en %)"),
		      #),# fin AMOR_MODALE
		      #VITESSE = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,into=('CONSTANTE','VARIABLE'),fr="Renseignement du type de vitesse de rotation"),
		      VITESSE_CONSTANTE = BLOC(condition = "VITESSE == 'CONSTANTE' ", fr="Vitesse de rotation constante",
                              VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation"),
                      ),# fin VITESSE_CONSTANTE
                      VITESSE_VARIABLE = BLOC(condition = "VITESSE == 'VARIABLE' ", fr="Vitesse de rotation variable", regles=UN_PARMI('LINEAIRE','EXPONENTIELLE','FORMULE'),
                              LINEAIRE = FACT(statut='f',min=1,max=1,fr="Renseignement de la fonction lineaire de la vitesse de rotation",
                                      VITESSE_INITIALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation initiale (en tr/min)",),
                                      VITESSE_FINALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation finale (en tr/min)",),
                                      DEPHASAGE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la postion angulaire (en degre)"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement du pas (ou liste) de mise a jour des matrices des paliers (en tours)"),
                              ),# fin LINEAIRE
                              EXPONENTIELLE = FACT(statut='f',min=1,max=1,fr="Renseignement de la fonction exponentielle de la vitesse de rotation",
                                      VITESSE_INITIALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation initiale (en tr/min)",),
                                      VITESSE_FINALE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation finale (en tr/min)",),
                                      DEPHASAGE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la postion angulaire (en degre)"),
                                      LAMBDA = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du parametre de l'exponentielle"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement du pas (ou liste) de mise a jour des matrices des paliers (en tours)"),
                              ),# fin VITESSE_EXPONENTIELLE
                              FORMULE = FACT(statut='f',min=1,max=1,fr="Renseignement de la fonction de la vitesse de rotation",
                                      FICHIER = SIMP(statut='o',typ=('Fichier','Formule vitesse rotation (*.*)'),min=1,max=1,defaut=None,fr="Renseignement du fichier contenant les fonctions de la vitesse de rotation"),
                                      OM = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule de position angulaire (max 8 caractere)"),
                                      PHI = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule de vitesse angulaire (max 8 caractere)"),
                                      ACC = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom de la formule d'acceleration angulaire (max 8 caractere)"),
                                      PAS_MAJ = SIMP(statut='f',typ='R',min=1,max='**',defaut=None,fr="Renseignement du pas (ou liste) de mise a jour des matrices des paliers (en tours)"),
                              ),# fin VITESSE_EXPONENTIELLE
                      ),# fin VITESSE_VARIABLE
                      #POIDS_PROPRE = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Choix d'application du poids propre (pesanteur)"),
                      # 20121018 retrait de defaut_fn a la demande de EDF
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','DEFAUT_FN','DELIGNAGE','EXTERNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      # 20121119 retrait de delignage
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','DELIGNAGE','EXTERNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','FORCE','HARMONIQUE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      BALOURD = BLOC(condition = "CHARGES == 'BALOURD' ",fr="Charge balourd appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge balourd"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la magnitude de la charge balourd (en kg.m)"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge balourd (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (en degres)"),
                              INST_APPLI= SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseigner l'instant pour déclencher le balourd"),
                              TEMPS_MONTEE=SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseigner le temps pour la montée jusqu'à la valeur finale du balourd"),
                      ),# fin BALOURD
                      FORCE = BLOC(condition = "CHARGES == 'FORCE' ",fr="Application d'une force",
                              PARAM_FORCE = FACT(statut='o',min=1,max='**',fr="Parametres de la force",
				      POSITION = SIMP(statut='o',typ='R',defaut=None,fr="Renseignement de la coordonnee de la force"),
				      MAGNITUDE = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement de la magnitude de la force"),
				      FONC_APPLI = SIMP(statut='f',typ='R',min=2,max=2,defaut=None,fr="Renseignement de la fonction appliquee"),
                              ), # fin PARAM_FORCE
                      ), # fin FORCE
                      HARMONIQUE = BLOC(condition = "CHARGES == 'HARMONIQUE' ",fr="Charge harmonique appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge harmonique"),
                              PUIS_PULS = SIMP(statut='o',typ='I',min=1,max=1,into=(0,1,2),defaut=None,fr="Renseignement de la puissance de pulsation de la charge harmonique"),
                              PULSATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la pulsation d'excitation harmonique (en rad/s)"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la magnitude de la charge harmonique, (unite : N.s^i (avec i = PUIS_PULS)"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge harmonique (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge harmonique (en degres)"),
                              TYPE_DDL = SIMP(statut='o',typ='TXM',min=1,max=1,into=('DX','DRX','DY','DRY'),defaut=None,fr="Renseignement du type de DDL excite sur lequel porte la charge"),
                      ), # fin HARMONIQUE
		      # 20121018 retrait de defaut_fn a la demande de EDF
                      #DEFAUT_FN = BLOC(condition = "CHARGES == 'DEFAUT_FN' ",fr="Charge defaut de fibre neutre appliquee",
                              #POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du defaut de fibre neutre"),
                              #TR_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Y du defaut de fibre neutre"),
                              #TR_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Z du defaut de fibre neutre"),
                              #ROT_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Y du defaut de fibre neutre"),
                              #ROT_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Z du defaut de fibre neutre"),
                      #), # fin DEFAUT_FN
                      # 20121119 retrait de delignage
                      #DELIGNAGE = BLOC(condition = "CHARGES == 'DELIGNAGE' ",fr="Application d'un delignage",
                              #PARAM_DELIGNAGE = FACT(statut='o',min=1,max='**',fr="Parametres du delignage",
			              #PALIERS = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom d'un palier deligne"),
				      #VALEURS = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des valeurs du delignage du palier"),
		              #), # fin PARAM_DELIGNAGE
                      #), # fin DELIGNAGE
                      # retrait force fichier externe
                      #EXTERNE = BLOC(condition = "CHARGES == 'EXTERNE' ",fr="Charge externe appliquee",
                              #POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge externe"),
                              #FONC_APPLI = SIMP(typ=('Fichier','Charge Externe (*.csv)'),docu='',min=1,max=1,statut='o',defaut=None,fr="Renseignement de la fonction appliquee à la charge externe (fichier cvs)"),
                      #), # fin EXTERNE
                      ETAT_INIT = FACT(statut='o',fr="Renseignement de l'etat initial",
                              #RESULTAT = SIMP(statut='o',typ=('sd_resultat'),max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              RESULTAT = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              INST_INIT = SIMP(statut='f',typ='R',max=1,defaut=0.0,fr="Renseignement de l'instant initial"),
                      ), # fin ETAT_INIT
                      PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS','LISTE'),defaut=None,fr="Choix du type de parametrage temporel"),
                      #PAS = BLOC(condition = "VITESSE == 'VARIABLE'",fr="Renseignement des parametres des pas",
                      PAS = BLOC(condition = "PARAM_TEMPS == 'PAS'",fr="Renseignement des parametres des pas",
                              TEMPS_PAS = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps (en s)"),
                              INST_INI = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de l'instant initial du pas"),
                              INST_FIN = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement de l'instant final du pas"),
                      ), # fin TEMPS_PAS
                      LIST_INST = BLOC(condition = "PARAM_TEMPS == 'LISTE'",fr="Renseignement d'une liste de pas",
                              LISTE = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement d'une liste de pas"),
                      ), # fin LIST_INST
                      PAS_ARCHIVAGE = SIMP(statut='o',typ='I',max=1,defaut=None,fr="Renseignement du pas d'archivage",),
                      SCHEMA_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('NEWMARK','EULER','WILSON','ADAPT_ORDRE1','ADAPT_ORDRE2','DIFF_CENTRE'),defaut='NEWMARK',fr="Choix d'un schema temporel"),
                      NEWMARK = BLOC(condition = "SCHEMA_TEMPS == 'NEWMARK' ",fr="Choix de la methode de NEWMARK",
                              BETA = SIMP(statut='f',typ='R',max=1,defaut=0.25,fr="Renseignement de la valeur beta pour la methode de NEWMARK"),
                              GAMMA = SIMP(statut='f',typ='R',max=1,defaut=0.25,fr="Renseignement de la valeur gamma pour la methode de NEWMARK"),
                      ),# fin NEWMARK
                      WILSON = BLOC(condition = "SCHEMA_TEMPS == 'WILSON' ",fr="Choix de la methode de WILSON",
                              THETA = SIMP(statut='f',typ='R',max=1,defaut=1.4,fr="Renseignement de la valeur theta pour la methode de WILSON"),
                      ), # fin WILSON
                      #Ionel le 19122012, FISSURE n'est pas dans la V1
		      #FISSURE = BLOC(condition = "BASE_CALCUL == 'MODALE' ",fr="Choix de calcul avec fissure",
                      #        EMPLACEMENT = FACT(statut='o',fr="Renseignement de l'emplacement de la fissure",
                      #                           regles=UN_PARMI('POSITION','NOEUD'),
                      #                POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la fissure"),
                      #                NOEUD = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du noeud de la fissure"),
                      #        ), # fin EMPLACEMENT
                      #        VITE_ROTA = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de ?? "),
                      #        ANGL_INIT = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement de ?? "),
                      #        K_PHI = SIMP(statut='o',typ=('Fichier','K.PHI (*.*)'),docu='',min=1,max=1,defaut=None,fr="Renseignement de la loi de comportement en raideur de la fissure"),
                      #        DK_DPHI = SIMP(statut='o',typ=('Fichier','DK.DPHI (*.*)'),docu='',min=1,max=1,defaut=None,fr="Renseignement de la deivee de la loi de comportement en raideur de la fissure"),
                      #), # fin FISSURE
                      
                      ## POST_TRAITEMENTS de l'analyse transitoire
                      POST_TRAITEMENTS = FACT(statut='o',max='**',fr="Choix des post-traitements",
			      TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			      DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",regles=UN_PARMI('POSITION','PALIER'),
				      #POSITION_DEPL = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      POSITION = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      PALIER = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      ), # fin DEPL
			      # 20121119 pas de mots-cles specifique pour efforts_paliers
			      #EFFORTS_PAL = BLOC(condition = "TYPE == 'EFFORTS_PAL'", fr = "Efforts paliers",
			          #PALIER = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      #), # fin EFFORTS_PAL
			      CONTRAINTES = BLOC(condition = "TYPE == 'CONTRAINTES' ",fr="Contraintes",
						regles=UN_PARMI('POSITION','ZONE','TOUT'),
				      POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				      ZONE = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette de la zone de la contrainte"),
				      TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),max=1,fr="tout"),
			      ), # fin CONTRAINTES
		      ), # fin POST_TRAITEMENTS
              
              ), # fin ANALYSE_TRANSISTOIRE
              

### ----- CALCUL COUPLE CODE_ASTER/EYDOS ----- ##
              ANALYSE_TRANSITOIRE_ACCIDENTEL = BLOC(condition = "TYPE_ANALYSE == 'TRANSITOIRE_ACCIDENTEL' ",fr="Analyse transitoire accidentelle",
                      #BASE_MODALE = FACT(statut='o', fr="Choix des parametres de la base modale",	              		   
		      POIDS = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='OUI',fr="Choix d'application d'un poids"),
		      BASE_MODALE = BLOC(condition = "True", fr="Choix des parametres de la base modale",
	                                 regles=UN_PARMI('NB_MODES','FREQ_MAX'),
                              NB_MODES = SIMP(statut='f',typ='I',min=1,max=1,defaut=None,fr="Renseignement du nombre de mode"),
		              FREQ_MAX = SIMP(statut='f',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la frequence maximale"),
		      ),# fin BASE_MODALE      
                      # cft 20131217 suppression amortissement reduit
		      #AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL','REDUIT'),defaut=None,fr="Choix du type d'amortissement"),
		      AMORTISSEMENT = SIMP(statut='o', typ='TXM',into=('STRUCTUREL'),defaut=None,fr="Choix du type d'amortissement"),
		      AMOR_REDUIT = BLOC(condition = "AMORTISSEMENT == 'REDUIT' ",
		              #LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements"),
		              LIST_AMOR = SIMP(statut='o', typ='R', min=1,max='**',defaut=None,fr="Renseignement de la liste des amortissements modaux reduits (en %), la taille de la liste doit etre egale au nombre de modes"),
		      ),# fin AMOR_REDUIT
                      VITESSE_ROTATION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la vitesse de rotation"),
                      #POIDS_PROPRE = SIMP(statut='o',typ='TXM',into=('OUI','NON'),defaut='NON',fr="Choix d'application du poids propre (pesanteur)"),
                      # 20121018 retrait de defaut_fn a la demande de EDF
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','DEFAUT_FN','DELIGNAGE','EXTERNE','EFFORTS_PALIERS'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      #CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','DELIGNAGE','EXTERNE','EFFORTS_PALIERS'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      CHARGES = SIMP(statut='o',typ='TXM',into=('BALOURD','EXTERNE'),defaut=None,min=1,max=1,fr="Choix du type de charge a appliquer"),
                      BALOURD = BLOC(condition = "CHARGES == 'BALOURD' ",fr="Charge balourd appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge balourd"),
                              MAGNITUDE = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la magnitude de la charge balourd (en kg.m)"),
                              FONC_APPLI = SIMP(statut='o',typ='R',min=1,max='**',defaut=None,fr="Renseignement de la fonction appliquee de la charge balourd (autant de valeurs que de vitesses de rotation)"),
                              PHASE_DEG = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du decalage de la phase de la charge balourd (en degres)"),
                              INST_APPLI= SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseigner l'instant pour déclencher le balourd"),
                              TEMPS_MONTEE=SIMP(statut='f',typ='R',min=1,max=1,defaut=0,fr="Renseigner le temps pour la montée jusqu'à la valeur finale du balourd"),
                      ),# fin BALOURD
		      # a commenter
		      # 20121018 retrait de defaut_fn a la demande de EDF
                      #DEFAUT_FN = BLOC(condition = "CHARGES == 'DEFAUT_FN' ",fr="Charge defaut de fibre neutre appliquee",
                              #POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du defaut de fibre neutre"),
                              #TR_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Y du defaut de fibre neutre"),
                              #TR_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du vecteur de translation en Z du defaut de fibre neutre"),
                              #ROT_Y = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Y du defaut de fibre neutre"),
                              #ROT_Z = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement du moment de rotation en Z du defaut de fibre neutre"),
                      #), # fin DEFAUT_FN
                      #DELIGNAGE = BLOC(condition = "CHARGES == 'DELIGNAGE' ",fr="Application d'un delignage",
                              #PARAM_DELIGNAGE = FACT(statut='o',min=1,max='**',fr="Parametres du delignage",
			              #PALIERS = SIMP(statut='o',typ='TXM',min=1,max=1,defaut=None,fr="Renseignement du nom d'un palier deligne"),
				      #VALEURS = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignement des valeurs du delignage du palier"),
		              #), # fin PARAM_DELIGNAGE
                      #), # fin DELIGNAGE
                      EXTERNE = BLOC(condition = "CHARGES == 'EXTERNE' ",fr="Charge externe appliquee",
                              POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee de la charge externe"),
                              FONC_APPLI = SIMP(typ=('Fichier','Charge Externe (*.csv)'),docu='',min=1,max=1,statut='o',defaut=None,fr="Renseignement de la fonction appliquee à la charge externe (fichier cvs)"),
                      ), # fin EXTERNE
                      #EFFORTS_PALIERS = BLOC(condition = "CHARGES == 'EFFORTS_PALIERS' ",fr="Application d'un effort palier",
                              #PALIER = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier de l'effort"),
                              #VALEURS = SIMP(statut='o',typ='R',min=3,max=3,defaut=None,fr="Renseignment de la valeur de l'effort sur le palier"),
                      #), # fin EFFORTS_PALIERS
                      ETAT_INIT = FACT(statut='o',fr="Renseignement de l'etat initial",
                              #RESULTAT = SIMP(statut='o',typ=('sd_resultat'),max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              # 20121126
                              #RESULTAT = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Choix de la structure de donnees resultat de code aster "),
                              INST_INIT = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de l'instant initial"),
                      ), # fin ETAT_INIT
                      #PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS','LIST_INST'),defaut=None,fr="Choix du type de parametrage temporel"),
                      # 20121126
                      PARAM_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('PAS'),defaut="PAS",fr="Choix du type de parametrage temporel",),
                      PAS = BLOC(condition = "PARAM_TEMPS == 'PAS' ",fr="Renseignement des parametres des pas",
                              PAS_ASTER = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps Aster (en s)",),
                              PAS_EDYOS = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement du pas de temps Edyos (en s)",),
                              INST_FIN = SIMP(statut='o',typ='R',max=1,defaut=None,fr="Renseignement de l'instant final (en s)",),
                      ), # fin TEMPS_PAS
                      #LIST_INST = BLOC(condition = "PARAM_TEMPS == 'LIST_INST' ",fr="Renseignement d'une liste de pas",
                              #LISTE = SIMP(statut='f',typ='R',min=1,max='**',defaut=None,fr="Renseignement d'une liste de pas"),
                      #), # fin LIST_INST
                      PAS_ARCHIVAGE = SIMP(statut='o',typ='I',max=1,defaut=None,fr="Renseignement du pas d'archivage",),
                      PARA_MEM = SIMP(statut='f',typ='I',max=1,defaut=6400,fr="Renseigner la taille de la memoire en Mo",),
                      PARA_CPU = SIMP(statut='f',typ='I',max=1,defaut=10000,fr="Renseigner le temps CPU max en secondes",),
                      SCHEMA_TEMPS = SIMP(statut='o',typ='TXM',max=1,into=('EULER','ADAPT_ORDRE1','ADAPT_ORDRE2'),defaut='ADAPT_ORDRE2',fr="Choix d'un schema temporel"),
                      
                      ## POST_TRAITEMENTS de l'analyse transitoire
                      POST_TRAITEMENTS = FACT(statut='o',fr="Choix des post-traitements",
			      TYPE = SIMP(statut='o',typ='TXM',into=('DEPL_ABS','DEPL_RELA','EFFORTS_PAL','CONTRAINTES'),defaut=None,fr="Choix du type de post-traitement"),
			      DEPL = BLOC(condition = "TYPE in ('DEPL_ABS','DEPL_RELA') ",fr="Deplacement",
				      POSITION = SIMP(statut='o',typ='R',min=1,max=1,defaut=None,fr="Renseignement de la coordonnee du deplacement"),
				      PALIER = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      ), # fin DEPL
			      # pas d'info à rentrer pour les efforts palier (post-traitement sur tout les paliers)
			      #EFFORTS_PAL = BLOC(condition = "TYPE == 'EFFORTS_PAL'", fr = "Efforts paliers",
			          #PALIER = SIMP(statut='o',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette du palier"),
			      #), # fin EFFORTS_PAL
			      CONTRAINTES = BLOC(condition = "TYPE == 'CONTRAINTES' ",fr="Contraintes",
						regles=UN_PARMI('POSITION','ZONE','TOUT'),
				      POSITION = SIMP(statut='f',typ='R',max=1,defaut=None,fr="Renseignement de la coordonnee de la contrainte"),
				      ZONE = SIMP(statut='f',typ='TXM',max=1,defaut=None,fr="Renseignement de l'etiquette de la zone de la contrainte"),
				      TOUT = SIMP(statut='f',typ='TXM',into=('OUI'),max=1,fr="tout"),
			      ), # fin CONTRAINTES
		      ), # fin POST_TRAITEMENTS
                      
                      
              ), # fin ANALYSE_TRANSITOIRE_ACCIDENTEL
                 
)# fin SPECIFICATION_ANALYSE
