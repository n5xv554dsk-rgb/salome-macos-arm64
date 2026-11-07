## -*- coding: utf-8 -*-
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
                regles=(AU_MOINS_UN('STRUCTURE_SIMPLE',),),
                       )# Fin JDC_CATA
#


STRUCTURE_SIMPLE= MACRO (nom       = 'STRUCTURE_SIMPLE',
              op        = None,
              sd_prod   = None,
              reentrant = 'n',
              UIinfo    = {"groupes":("Outils métier",)},
              fr        = "sous epaisseur  ",
              dir_name  = SIMP(statut='o', typ='TXM',),
              
              CHARGE_LIMITE     = SIMP(statut='o', typ='TXM',into=('OUI', 'NON')),
              
              TYPE_SEP          = SIMP(statut='o', typ='TXM',into=('TUBE_SOUS_EP_INTERNE','COUDE_SOUS_EP_INTERNE')),
              
                         
                b_tube_sous_epaisseur =BLOC(condition="(TYPE_SEP=='TUBE_SOUS_EP_INTERNE') ",
                         
                           points_de_mesure = FACT( statut='o',max='**',
                                                        FICHIER =SIMP(statut='o',typ='Fichier',
                                                                                 fr="Format du fichier : CSV.",),
                                                                                 ), 
                         
                            
                           MAIL_TUBE = FACT( statut='f',max='**',
                                    fr        = "Parametres maillage du tube  ",

                                    unite_longueur=SIMP(statut='o', typ='TXM', defaut='mm',into=('mm',),),
                                    r_ext=SIMP(statut='o', typ='R', defaut=228.6,val_min=100,val_max=300, fr="rayon exterieur du tube"),
                                    ep_nominale=SIMP(statut='o', typ='R', defaut=22.0, fr="epaisseur nominale du tube sans sous epaisseur"),
                                    nb_seg_amortissement=SIMP(statut='o', typ='I', defaut=11, fr="nombre de segments dans la longueur d'amortissement"),
                                    nb_seg_transition=SIMP(statut='o', typ='I', defaut=4, fr="nombre de segments dans longueur de transition"),
                                    nb_seg_generatrices=SIMP(statut='o', typ='I', defaut=5, fr="nombre de segments dans la longueur des generatrices dans la zone de sous épaisseur"),
                                    petite_distance=SIMP(statut='o', typ='R', defaut=100.0, fr="distance entre deux abscisses de points de mesure au dessous de laquelle on discrétise avec nb_seg_petites_distances au lieu de nb_seg_generatrices"),
                                    nb_seg_petites_distances=SIMP(statut='o', typ='I', defaut=3, fr="nombre de segments dans les aretes dont la longueur est inferieur a petite distance"),
                                    nb_seg_arc=SIMP(statut='o', typ='I', defaut=5, fr="nombre de segments dans l'arc du tube entre deux generatrices"),
                                    nb_seg_ep=SIMP(statut='o', typ='I', defaut=3, fr="nombre de segments dans l'epaisseur du tube"),
                                    critere_dist_radial=SIMP(statut='o', typ='R', defaut=0.5, fr="Critère de raffinement de maillage"),
                                      ),
                           INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                                   ),


                b_coude_sous_epaisseur =BLOC(condition="(TYPE_SEP=='COUDE_SOUS_EP_INTERNE') ",
                            
                            points_de_mesure = FACT( statut='o',max='**',
                                                        FICHIER =SIMP(statut='o',typ='Fichier',
                                                                                 fr="Format du fichier : CSV.",),
                                                        FORMAT =SIMP(statut='f',typ='TXM',defaut="CSV",into=("CSV"),
                                                                                 fr="Format du fichier : CSV",),
                                                                                 ),
                            MAIL_COUDE = FACT( statut='f',max='**',
                                        fr        = "Parametres maillage du coude  ",

                                        unite_longueur=SIMP(statut='o', typ='TXM', defaut='mm',into=('mm',),),
                                        r_coude=SIMP(statut='o', typ='R', defaut=381.,val_min=100,val_max=500,fr="rayon du coude"),
                                        r_ext=SIMP(statut='o', typ='R', defaut=136.5,val_min=100,val_max=200,fr="rayon exterieur"),
                                        ep_nominale=SIMP(statut='o', typ='R', defaut=15.1,fr="epaisseur nominale sans sous epaisseur"),
                                        angle_coude=SIMP(statut='o', typ='R', defaut=90,fr="angle du coude"),
                                        orientation_coude=SIMP(statut='o', typ='TXM', defaut='D',into=('D','G'),fr="orientation du coude"),
                                        longueur_prolongement_amont=SIMP(statut='o', typ='R', defaut=150.,fr="longueur du prolongement amont"),
                                        longueur_prolongement_aval=SIMP(statut='o', typ='R', defaut=150.,fr="longueur du prologenment aval"),
                                        pas_mesure=SIMP(statut='o', typ='I', defaut=80,fr="pas de la mesure"),
                                        debut_mesure=SIMP(statut='o', typ='R', defaut=40.,fr="distance de la premiere mesure"),
                                        angle_mesure=SIMP(statut='o', typ='R', defaut=45.,fr="angle entre deux generatrices"),
                                        nb_seg_prolongement_amont = SIMP(statut='o', typ='I', defaut=6, fr="nombre de segments dans la longueur de prolongement amont"),
                                        nb_seg_prolongement_aval  = SIMP(statut='o', typ='I', defaut=6, fr="nombre de segments dans la longueur de prolongement aval"),
                                        nb_seg_amortissement=SIMP(statut='o', typ='I', defaut=11, fr="nombre de segments dans la longueur d'amortissement"),
                                        nb_seg_transition=SIMP(statut='o', typ='I', defaut=5, fr="nombre de segments dans longueur de transition"),
                                        nb_seg_generatrices=SIMP(statut='o', typ='I', defaut=25, fr="nombre de segments dans la longueur des generatrices dans la zone de sous épaisseur"),
                                        nb_seg_arc=SIMP(statut='o', typ='I', defaut=7, fr="nombre de segments dans l'arc du coude entre deux generatrices"),
                                        nb_seg_ep=SIMP(statut='o', typ='I', defaut=3, fr="nombre de segments dans l'epaissuer"),
                                        critere_dist_radial=SIMP(statut='o', typ='R', defaut=0.5, fr="critère de rafinement de maillage"),
                                         
                                              ),
                            INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                                   ),
                                              
                             
                            b_charge_limite_non=BLOC(condition = "CHARGE_LIMITE == 'NON' ",
                                                INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                                        ),
                            b_charge_limite_oui=BLOC(condition = "CHARGE_LIMITE == 'OUI' ",
                              
                              TYPE_CHARGE_LIMITE= SIMP(statut='o', typ='TXM',into=('CHARGE_LIMITE_INF','CHARGE_LIMITE_SUP')),
                                                
                                                PARAMETRES = FACT( statut='o',max='**',
                                                    fr        = "Parametres pour calcul de charge limite  ",
                                                    
                                                    unite_mem=SIMP(statut='o', typ='TXM', defaut='Mo',into=('Mo',),),
                                                    memoire=SIMP(statut='o', typ='I', defaut=2000,val_min=128,val_max=8000),
                                                    unite_temps=SIMP(statut='o', typ='TXM', defaut='h',into=('h',),),
                                                    temps=SIMP(statut='o', typ='R', defaut=50.),
                                                    machine=SIMP(statut='o', typ='TXM', defaut='locale',into=('locale','distante'),),
                                                    unite_sig=SIMP(statut='o', typ='TXM', defaut='MPa',into=('Pa','MPa'),),
                                                    
                                                    E =SIMP(statut='o', typ='R', defaut=200000., fr="Module d'Young"),
                                                    NU=SIMP(statut='o', typ='R', defaut=0.3    , fr="coefficient de poisson"),
                                                    SY=SIMP(statut='o', typ='R', defaut=98.7   , fr="limite d'elasticite"),
                                                                    ),
                                                
                                                CHARGE_LIMITE_INF = BLOC(condition="(TYPE_CHARGE_LIMITE =='CHARGE_LIMITE_INF') ",
                                                  FICHIER =SIMP(statut='o',typ='Fichier',
                                                                                 fr="Format du fichier : .COMM",),
                                                                                 ),                    
                                                
                                                CHARGE_LIMITE_SUP = BLOC(condition="(TYPE_CHARGE_LIMITE =='CHARGE_LIMITE_SUP') ",
                                                  FICHIER =SIMP(statut='o',typ='Fichier',
                                                                                 fr="Format du fichier : .COMM",),
                                                                                 ),                    
                                                                    
                                                INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
                                                         ),         
           
            
)

