# coding: utf-8
#
from Accas import JDC_CATA, PROC, EXAMPLE

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
                )


EXAMPLE = PROC (nom = 'EXAMPLE',
    op=None,

    TITRE =  SIMP(statut ='o', typ = 'TXM', defaut = 'Mon Etude',),
    TITRE2 =  SIMP(statut ='f', typ = 'TXM', ),
)
CREEOBJET = OPER (nom="CREEOBJET",
    op=None,
    sd_prod=ObjetUtilisateur,
    UIinfo={"groupes":("Group1",)},

    TITLE     = SIMP(statut ='o', typ = 'TXM', defaut = '',),
    RB1       = SIMP(statut ='o', typ = 'I', into = [1,2,3],),
    RB2       = SIMP(statut ='o', typ = 'I', into = [1,2,3,4,5,6,],),
    CB        = SIMP(statut ='o', typ = 'I', into = [1,2,3,4,5,6,7,8,9],),
    MBool     = SIMP(statut ='o', typ = bool,),
    MFile     = SIMP(statut ='o', typ = ('Fichier','All Files (*)')),
    MDir      = SIMP(statut ='o', typ = 'Repertoire'),
    Reel1     = SIMP(statut ='o', typ = 'R'),
    Compl     = SIMP(statut ='o', typ = 'C'),
    Tuple2    = SIMP(statut ='o', typ = Tuple(2), validators=VerifTypeTuple(('R','R'))),
    Tuple3    = SIMP(statut ='o', typ = Tuple(3), validators=VerifTypeTuple(('R','R','R'))),

    LTITLE    = SIMP(statut ='o', typ = 'TXM', max='**', defaut = '',),
    LRB2      = SIMP(statut ='o', typ = 'I', max = '**', into = [1,2,3,4,5,6,],),
    LCB       = SIMP(statut ='o', typ = 'I', max = '**', homo="SansOrdreNiDoublon", into = [1,2,3,4,5,6,7,8,9],),
    LReel1    = SIMP(statut ='o', typ = 'R', max = "**"),
    LCompl    = SIMP(statut ='o', typ = 'C', max = "**"),
    LTuple2   = SIMP(statut ='o', typ = Tuple(2), validators=VerifTypeTuple(('R','R')), max = "**"),
    LTuple3   = SIMP(statut ='o', typ = Tuple(3), validators=VerifTypeTuple(('R','R','R')), max = "**"),

    LREEL    = SIMP(statut ='f', typ = 'R', max='**', defaut = '',),
)

UTILISEOBJET = PROC (nom="UTILISEOBJET",
    op=None,
    UIinfo={"groupes":("Group1",)},
    Obj   = SIMP (statut ='o', typ = ObjetUtilisateur,)
)

ESSAI_FACT=OPER(nom="ESSAI_FACT",
   sd_prod=ObjetUtilisateur,
   op=None,
   fr="Affectation de caractéristiques à des éléments de structure",
   regles = (AU_MOINS_UN('Poutre','Barre'),
             EXCLUS('Discret','Discret_2D'),),
   Info   = SIMP(statut='f',typ='I', defaut= 1 ,into=(1,2) ),
   Verif  = SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**',into=("Maille","Noeud") ),
#
# ==============================================================================
    Poutre  = FACT(statut= 'f',max= '**',
        Section = SIMP(statut= 'o',typ= 'TXM' ,into= ("GENERALE","RECTANGLE","CERCLE") ),

        b_generale = BLOC(condition = " Section == 'GENERALE'",
            regles = (UN_PARMI('Maille','GroupeMailles'),),
            Maille    = SIMP(statut= 'f',typ= 'TXM'  ,validators= NoRepeat(),max= '**'),
            GroupeMailles  = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),

            Vari = SIMP(statut= 'f',typ= 'TXM',into= ("CONSTANT","HOMOTHETIQUE"),defaut= "CONSTANT"),

            b_constant = BLOC(condition = "Vari == 'CONSTANT'",
                regles = (PRESENT_ABSENT('Table','Cara'),
                          PRESENT_PRESENT('Table','Nom'),
                          PRESENT_PRESENT('Cara','Valeur'),),
                Table = SIMP(statut= 'f',typ='TXM'),
                Nom    = SIMP(statut= 'f',typ= 'TXM'),
                Cara       = SIMP(statut= 'o',typ= 'TXM',min= 4 ,max= 5,
                    fr= "A,IY,IZ,JX sont des paramètres obligatoires",
                    validators= [NoRepeat(), Compulsory(['A','IY','IZ','JX'])],
                    into= ("A","IY","IZ","AY","AZ","EY","EZ","JX","RY","RZ","RT","JG","IYR2","IZR2","AI") ),
                Valeur       = SIMP(statut= 'f',typ= 'R',min= 4 ,max= 15),
            ),
        ),
        b_rectangle = BLOC(condition = "Section == 'RECTANGLE'",
            regles = (UN_PARMI('Maille','GroupeMailles'),),
            Maille    = SIMP(statut= 'f',typ= 'TXM'  ,validators= NoRepeat(),max= '**'),
            GroupeMailles  = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),
            Vari = SIMP(statut= 'f',typ= 'TXM',into= ("CONSTANT","HOMOTHETIQUE","AFFINE"),defaut= "CONSTANT"),
            b_constant = BLOC(condition = "Vari == 'CONSTANT'",
                Cara  = SIMP(statut= 'o',typ= 'TXM',min= 1 ,max= 4,
                    validators = [NoRepeat(),
                                  OrVal( [AndVal( [Compulsory(['H']),Absent(['HY','HZ','EPY','EPZ'])] ),
                                          AndVal( [Compulsory(['HY','HZ']),Together(['EPY','EPZ']),Absent(['H','EP'])] )] )],
                    into= ("H","EP", "HY","HZ","EPY","EPZ"),),
                Valeur  = SIMP(statut= 'o',typ= 'R',min= 1 ,max= 4),
            ),

            Metrique = SIMP(statut= 'f',typ= 'TXM',defaut= "NON",into= ("OUI","NON") ),
            Fcx           = SIMP(statut= 'f',typ= 'R'),
            Tuyau    = SIMP(statut= 'f',typ= 'I',val_max= 10,defaut= 3),
        ),
    ),
#
# ==============================================================================
    Barre = FACT(statut='f',max='**',
        regles = (UN_PARMI('Maille','GroupeMailles'),),
        Maille   = SIMP(statut='f',typ='TXM'  ,validators=NoRepeat(),max='**'),
        GroupeMailles = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        Section  = SIMP(statut='o',typ='TXM',into=("GENERALE","RECTANGLE","CERCLE") ),
        b_generale = BLOC(condition = "Section=='GENERALE'",
            regles = (PRESENT_ABSENT('Table','Cara'),
                      PRESENT_PRESENT('Table','Nom'),
                      PRESENT_PRESENT('Cara','Valeur')),
            Table = SIMP(statut='f',typ='TXM'),
            Nom    = SIMP(statut='f',typ='TXM',validators=LongStr(1,24) ),
            Cara       = SIMP(statut='f',typ='TXM',into=("A",) ),
            Valeur       = SIMP(statut='f',typ='R',min=1,max=1 ),
        ),
        b_rectangle = BLOC(condition = "Section=='RECTANGLE'",
            Cara = SIMP(statut='o',typ='TXM', min=1, max=4,
                validators = [NoRepeat(),
                              OrVal( [AndVal( [Compulsory(['H']),Absent(['HY','HZ','EPY','EPZ'])] ),
                                      AndVal( [Compulsory(['HY','HZ']),Together(['EPY','EPZ']),Absent(['H','EP'])] )] )],
                into=("H","EP","HZ","HY","EPY","EPZ"), ),
            Valeur = SIMP(statut='o',typ='R',min=1,max=4 ), ),
        b_cercle = BLOC(condition = "Section=='CERCLE'",
            Cara = SIMP(statut='o',typ='TXM',validators=[NoRepeat(),Compulsory(['R'])],min=1,max=2,into=("R","EP") ),
            Valeur = SIMP(statut='o',typ='R',min=1,max=2 ), ),
    ),
#
# ==============================================================================
    Discret = FACT(statut='f',max='**',
        REPERE    = SIMP(statut='f',typ='TXM',into=("LOCAL","GLOBAL") ),
        AMOR_HYST = SIMP(statut='f',typ='R' ),
        SYME      = SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"),),
        b_SYME_OUI = BLOC(condition="SYME=='OUI'",
            fr="SYMETRIQUE: Affectation de matrices de rigidité, de masse ou d'amortissement à des mailles ou noeuds",
            Cara = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=1,defaut="None",
            into = ("K_T_D_N", "K_T_D_L", "K_TR_D_N", "K_TR_D_L", "K_T_N", "K_T_L", "K_TR_N", "K_TR_L",
                    "M_T_D_N", "M_T_D_L", "M_TR_D_N", "M_TR_D_L", "M_T_N", "M_T_L", "M_TR_N", "M_TR_L",
                    "A_T_D_N", "A_T_D_L", "A_TR_D_N", "A_TR_D_L", "A_T_N", "A_T_L", "A_TR_N", "A_TR_L",),),
            #  Affection des caractéristiques de RIGIDITE/AMORTISSEMENT/MASSE
            b_AK_T_D_N = BLOC(condition = "((Cara=='K_T_D_N')or(Cara=='A_T_D_N'))",
                fr       = "Noeud: 3 valeurs (triangulaire supérieure par colonne)",
                regles   = (UN_PARMI('Maille','GroupeMailles','Noeud','GROUP_NO'),),
                Noeud    = SIMP(statut='f',typ='TXM'  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                Maille   = SIMP(statut='f',typ='TXM'  ,validators=NoRepeat(),max='**'),
                GroupeMailles = SIMP(statut='f',typ=grma,validators=NoRepeat(),homo='SansOrdreNiDoublon',max='**'),
                Valeur     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
        ),
    ),
#
# ==============================================================================
    Discret_2D = FACT(statut='f',max='**',
        REPERE    = SIMP(statut='f',typ='TXM',into=("LOCAL","GLOBAL") ),
        AMOR_HYST = SIMP(statut='f',typ='R' ),
        SYME      = SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"),),
        ),
)


