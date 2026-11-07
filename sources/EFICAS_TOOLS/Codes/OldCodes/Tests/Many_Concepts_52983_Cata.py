# coding: utf-8

from Accas import *

#class myMesh(ASSD): pass
class myModel(ASSD): pass

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
               regles=(UN_PARMI('DEBUT', 'POURSUITE'),
                       AU_MOINS_UN('FIN'),
                       A_CLASSER(('DEBUT', 'POURSUITE'), 'FIN')))

DEBUT=PROC(nom="DEBUT", op=68, repetable='n', UIinfo={"groupes":("Group1",)}, ang="Debut Eng help",
        PAR_LOT=SIMP(ang="Debut Par Lot help En",statut='o',typ=bool, defaut=True),
)
AFFE_MODELE=OPER(nom="AFFE_MODELE",op=None,sd_prod=myModel,
         UIinfo={"groupes":("Group1",)},
         ang="Model mesh definition EN",
         MESH=SIMP(statut='o',typ='TXM',into=("mesh_01","mesh_02","mesh_03","mesh_04",) , defaut="mesh_01"),
    #reentrant='n',
    #regles=(AU_MOINS_UN('AFFE','AFFE_SOUS_STRUC'),UN_PARMI('MAILLAGE','GRILLE')),


    block_mesh_01=BLOC(condition="MESH=='mesh_01'",
        AFFE=FACT(statut='o', 
            ALL=SIMP(statut='o', typ=bool,ang='ALL 01 help EN', defaut=True),
            PHENOMENA=SIMP(statut='o',typ='TXM',into=('phenomena_01','phenomena_02',), defaut='phenomena_01'),
            #MODELISATION=SIMP(statut='o',typ='TXM', min=2,max='**', into=("mesh_01","mesh_02","mesh_03","mesh_04",) ,ang='Input 01 list EN', fr='Input 01 list FR'),
            MODELISATION=SIMP(statut='o',typ='TXM', min=2,max='**', into=('Item_01_01','Item_01_02',) ,ang='Input 01 list EN', fr='Input 01 list FR'),
        ),
    ),
)
FIN=PROC(nom="FIN",op=9999,repetable='n',ang="Finish help EN",UIinfo={"groupes":("Group1",)},
    FORMAT_HDF =SIMP(ang="Save HDF EN",statut='f',typ='TXM',defaut="NON",into=("OUI","NON",) ), 
)

Classement_Commandes_Ds_Arbre=('DEBUT','MESH','AFFE_MODELE','FIN')
Ordre_Des_Commandes = ('DEBUT','MESH','AFFE_MODELE','FIN')
