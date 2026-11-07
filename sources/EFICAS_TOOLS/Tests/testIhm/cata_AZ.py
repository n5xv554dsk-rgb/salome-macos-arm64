import types
from Accas import *

class grno(GEOM):
    """
    Classe servant à définir le nom d'un groupe de noeuds dans le fichier de commande
    En clair : un chaine de longueur 24.
    """
    def __convert__(cls,valeur):
        """
        Fonction de verification de la longueur de la chaine
        """
        if isinstance(valeur, (str,unicode)) and len(valeur.strip()) <= 24:
            return valeur.strip()
        raise ValueError(_(u'On attend une chaine de caractères (de longueur <= 24).'))
    __convert__ = classmethod(__convert__)

class grma(GEOM):
    """
    Classe servant à définir le nom d'un groupe de mailles dans le fichier de commande
    En clair : un chaine de longueur 24.
    """
    def __convert__(cls,valeur):
        """
        Fonction de verification de la longueur de la chaine
        """
        if isinstance(valeur, (str,unicode)) and len(valeur.strip()) <= 24:
            return valeur.strip()
        raise ValueError(_(u'On attend une chaine de caractères (de longueur <= 24).'))
    __convert__ = classmethod(__convert__)


class ObjetUtilisateur(ASSD): pass


JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
                )


MAISON = PROC (nom = 'MAISON',
    POUTRE =  FACT( max='**', 
       Hauteur =  SIMP(statut ='o', typ = 'R', val_min=0, unite='m'),
       Largeur =  SIMP(statut ='o', typ = 'R', val_min=0,),
       Epaisseur =  SIMP(statut ='o', typ = 'R', val_min=0,),
       Trouee = SIMP(statut ='o', typ = bool, defaut= False),
       BTrouee = BLOC ( condition = 'Trouee == True',
           FormeDuTrou = SIMP(statut ='o', typ ='TXM', into = ['rond', 'carré', 'indefinie'],),
           Brond = BLOC ( condition = 'FormeDuTrou == "rond"',
               Rayon = SIMP(statut ='o', typ = 'R')
               ),
           ),
      ),
)

TousLesWidgets = PROC(nom="TousLesWidgets",
    op=None,
    UIinfo={"groupes":("Group1",)},

    # When a single value is attended, LineEdit is used if type of the parameter is text, int or float
    # a default value can be specified  
    # suggested values can also be specified, but some other value is also valid  
    EnterOneValue   = FACT ( statut = 'o',
       AnInt    = SIMP(statut ='f', typ = 'I'),
       AFloat   = SIMP(statut ='o', typ = 'R', defaut = 1.,),
       ABoolean = SIMP(statut ='o', typ = bool,),
       AText    = SIMP(statut ='o', typ = 'TXM',),
       AComplex = SIMP(statut ='f', typ = 'C'),
       AFile    = SIMP(statut ='o', typ = ('Fichier','All Files (*)')),
       ADirectory  = SIMP(statut ='o', typ = 'Repertoire'),
       AnExistingFile    = SIMP(statut ='f', typ = ('FichierNoAbs','All Files (*)')),
       AFilePyExtension  = SIMP(statut ='f', typ = ('Fichier','Python Files (*.py);;All Files (*)')),
       AFileOrADirectory = SIMP(statut ='o', typ = 'FichierOuRepertoire'),
       #AnEntryInSalome  = SIMP(statut ='o', typ = SalomeEntry),
    ),

    # Eficas chooses an adapted widget  depending on number of possible values : n>3 or 6 or < 7
    # if fenetreIhm is set to menuDeroulant, combobox widget is used regarless of the length of the values list
    ChooseOneValueInASet   = FACT ( statut = 'o',
       Of3PossibleValues         = SIMP(statut ='o', typ = 'I', into = [1,2,3],),
       Of6PossibleValues         = SIMP(statut ='f', typ = 'I', into = [1,2,3,4,5,6,],),
       BetweenMoreThan3Values    = SIMP(statut ='o', typ = 'I', into = [1,2,3,4,5,6,7,8,9],),
       InAComboBox               = SIMP(statut ='f', typ = 'I', into = [1,2,3],fenetreIhm = "menuDeroulant"),
       WithNoRestrictiveChoices  = SIMP(statut ='o', typ = 'TXM', intoSug = ('Suggestion', 'Suggestion2'),)
    ),
    
    EnterATupleOrMatrix = FACT ( statut = 'o',
        Tuple2    = SIMP(statut ='o', typ = Tuple(2), validators=VerifTypeTuple(('R','R'))),
        Tuple3    = SIMP(statut ='o', typ = Tuple(3), validators=VerifTypeTuple(('R','R','R'))),
    ),

    EnterList = FACT ( statut = 'o',
       LREEL    = SIMP(statut ='f', typ = 'R', max='**', defaut = '',),
       LRB2      = SIMP(statut ='o', typ = 'I', max = '**', into = [1,2,3,4,5,6,],),
       LCB       = SIMP(statut ='o', typ = 'I', max = '**', homo="SansOrdreNiDoublon", into = [1,2,3,4,5,6,7,8,9],),
       LReel1    = SIMP(statut ='o', typ = 'R', max = "**"),
       LCompl    = SIMP(statut ='o', typ = 'C', max = "**"),
       LTuple2   = SIMP(statut ='o', typ = Tuple(2), validators=VerifTypeTuple(('R','R')), max = "**"),
       LTuple3   = SIMP(statut ='o', typ = Tuple(3), validators=VerifTypeTuple(('R','R','R')), max = "**"),
       #LInSalome = SIMP(statut ='o', typ = SalomeEntry, max="**"),
    ),
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


