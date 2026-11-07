## -*- coding: utf-8 -*-
#
## --------------------------------------------------
## debut entete
## --------------------------------------------------
#
from Accas import *

#
#CONTEXT.debug = 1
JdC = JDC_CATA ( code = 'SEP',
                execmodul = None,
               # regles=(AU_MOINS_UN('STRUCTURE_SIMPLE','STRUCTURE_COMPOSEE',),),
                regles=(AU_PLUS_UN('STRUCTURE_SIMPLE',),),
                       )# Fin JDC_CATA
#


STRUCTURE_SIMPLE= MACRO (nom       = 'STRUCTURE_SIMPLE',
              op        = None,
              sd_prod   = None,
              reentrant = 'n',
              UIinfo    = {"groupes":("Outils métier",)},
              fr        = "sous epaisseur  ",
              dir_name  = SIMP(statut='o', typ='TXM',),
              
              
              TYPE_SEP          = SIMP(statut='o', typ='TXM',into=('TUBE_SOUS_EP_INTERNE','COUDE_SOUS_EP_INTERNE')),
             
              CHARGE_LIMITE     = SIMP(statut='o', typ='TXM',into=('OUI', 'NON')),
                              

              b_tube_sous_epaisseur =BLOC(condition="(TYPE_SEP=='TUBE_SOUS_EP_INTERNE') ",
                           
                      MAIL_TUBE = FACT( statut='o',
                          fr        = "Parametres maillage du tube  ",
                          POINTS_DE_MESURE = FACT( statut='o',
                                    FICHIER1 =SIMP(statut='f',typ='Fichier',
                                                   fr="Format du fichier : CSV.",),
                                    FICHIER2 =SIMP(statut='f',typ='Fichier',
                                                   fr="Format du fichier : CSV.",),                         
                                                 ), 
                          R_EXT                    =SIMP(statut='o', typ='R', fr="rayon exterieur du tube"),
                          EP_NOMINALE              =SIMP(statut='o', typ='R', fr="epaisseur nominale du tube sans sous epaisseur"),
                          NB_SEG_AMORTISSEMENT     =SIMP(statut='o', typ='I', defaut=11    , val_min=1, fr="nombre de segments dans la longueur d'amortissement"),
                          NB_SEG_TRANSITION        =SIMP(statut='o', typ='I', defaut=4     , val_min=1, fr="nombre de segments dans longueur de transition"),
                          NB_SEG_GENERATRICES      =SIMP(statut='o', typ='I', defaut=5     , val_min=1, fr="nombre de segments dans la longueur des generatrices dans la zone de sous épaisseur"),
                          PETITE_DISTANCE          =SIMP(statut='o', typ='R', defaut=100.0 , fr="distance entre deux abscisses de points de mesure au dessous de laquelle on discrétise avec nb_seg_petites_distances au lieu de nb_seg_generatrices"),
                          NB_SEG_PETITES_DISTANCES =SIMP(statut='o', typ='I', defaut=3  , val_min=3   , fr="nombre de segments dans les aretes dont la longueur est inferieur a petite distance"),
                          NB_SEG_ARC               =SIMP(statut='o', typ='I', defaut=5  , val_min=2   , fr="nombre de segments dans l'arc du tube entre deux generatrices"),
                          NB_SEG_EP                =SIMP(statut='o', typ='I', defaut=3  , val_min=1   , fr="nombre de segments dans l'epaisseur du tube"),
                                       ),
                         
                          INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                          ),


                b_coude_sous_epaisseur =BLOC(condition="(TYPE_SEP=='COUDE_SOUS_EP_INTERNE') ",
                                                                                
                          MAIL_COUDE = FACT( statut='o',
                              fr        = "Parametres maillage du coude  ",
                              POINTS_DE_MESURE = FACT( statut='o',
                                        FICHIER1 =SIMP(statut='f',typ='Fichier',
                                                       fr="Format du fichier : CSV.",),
                                                     ),
                              R_COUDE                    =SIMP(statut='o', typ='R', fr="rayon du coude"),
                              R_EXT                      =SIMP(statut='o', typ='R', fr="rayon exterieur"),
                              EP_NOMINALE                =SIMP(statut='o', typ='R', fr="epaisseur nominale sans sous epaisseur"),
                              ANGLE_COUDE                =SIMP(statut='o', typ='R', defaut=90  , val_min=90. , val_max=90.   ,fr="angle du coude"),
                              ORIENTATIOP_COUDE          =SIMP(statut='o', typ='TXM',defaut='D',into=('D','G'),fr="orientation du coude"),
                              LONGUEUR_PROLONGEMENT_AMONT=SIMP(statut='o', typ='R', fr="longueur du prolongement amont"),
                              LONGUEUR_PROLONGEMENT_AVAL =SIMP(statut='o', typ='R', fr="longueur du prologenment aval"),
                              PAS_MESURE                 =SIMP(statut='o', typ='I', fr="pas de la mesure"),
                              DEBUT_MESURE               =SIMP(statut='o', typ='R', fr="distance de la premiere mesure"),
                              ANGLE_MESURE               =SIMP(statut='o', typ='R', defaut=45.  ,fr="angle entre deux generatrices"),
                              NB_SEG_PROLONGEMENT_AMONT  =SIMP(statut='o', typ='I', defaut=6   , val_min=1  ,fr="nombre de segments dans la longueur de prolongement amont"),
                              NB_SEG_PROLONGEMENT_AVAL   =SIMP(statut='o', typ='I', defaut=6   , val_min=1  ,fr="nombre de segments dans la longueur de prolongement aval"),
                              NB_SEG_AMORTISSEMENT       =SIMP(statut='o', typ='I', defaut=10  , val_min=1  ,fr="nombre de segments dans la longueur d'amortissement"),
                              NB_SEG_TRANSITION          =SIMP(statut='o', typ='I', defaut=5   , val_min=1  ,fr="nombre de segments dans longueur de transition"),
                              NB_SEG_GENERATRICES        =SIMP(statut='o', typ='I', defaut=25  , val_min=25  ,fr="nombre de segments dans la longueur des generatrices dans la zone de sous épaisseur"),
                              NB_SEG_ARC                 =SIMP(statut='o', typ='I', defaut=7   , val_min=2  ,fr="nombre de segments dans l'arc du coude entre deux generatrices"),
                              NB_SEG_EP                  =SIMP(statut='o', typ='I', defaut=3   , val_min=1  ,fr="nombre de segments dans l'epaissuer"),
                                           ),
                    
                              INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                            ),
                                              
                             
                 b_charge_limite_non=BLOC(condition = "CHARGE_LIMITE == 'NON' ",
                              INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                         ),

                 b_charge_limite_oui=BLOC(condition = "((CHARGE_LIMITE == 'OUI') )",
                                                                                                                                    
                              TYPE_CHARGE_LIMITE= SIMP(statut='o', typ='TXM', into=('CHARGE_LIMITE_INF','CHARGE_LIMITE_SUP',),),
                                                
                              PARAMETRES_CALCUL = FACT( statut='o',
                                   fr        = "Parametres pour calcul de charge limite  ",
                                                    
                                   MEMOIRE=SIMP(statut='o', typ='I', ),
                                   TEMPS  =SIMP(statut='o', typ='I', ),
                                   MACHINE=SIMP(statut='o', typ='TXM', defaut='LOCAL',into=('LOCAL','DISTANT'),),
                                                    
                                                      ),
                              PARAMETRES_CHARGE_LIMITE = FACT( statut='o',
                                   fr        = "Parametres materiau pour calcul de charge limite   ", 
                                                    
                                   E =SIMP(statut='o', typ='R', fr="Module d'Young"),
                                   NU=SIMP(statut='o', typ='R', fr="coefficient de poisson"),
                                   SY=SIMP(statut='o', typ='R', fr="limite d'elasticite"),
                                                             ),   
                                                  
                                         ),
)
