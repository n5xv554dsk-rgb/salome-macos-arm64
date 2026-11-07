.. _rules-label:

============
Eficas rules 
============

All the rules can be combinated, creating more complicated rules.

AU_MOINS_UN
-----------

    AU_MOINS_UN rule obliges the user to create at least one concept of the list. More than one can be created. 

-    Example

     Keyword POUTRE in OPER AFFE_CARA_ELEM contains the rule :

    regles=(AU_MOINS_UN(
    'POUTRE','COQUE','DISCRET','CABLE','BARRE','MASSIF','ASSE_GRIL','GRILLE'),)

-     That means if AFFE_CARA_ELEM is used in the JDC, the user must select one at least of the Keyword between POUTRE, COQUE, DISCRET, CABLE, BARRE, MASSIF, ASSE_GRIL, GRILLE :

       * If the user doesn't select any of these keywords, AFFE_CARA_ELEM is unvalid. 
       * If he selects POUTRE, AFFE_CARA_ELEM is valid. 
       * If he selects both  POUTRE and DISCRET, AFFE_CARA_ELEM is valid. 
    

UN_PARMI
--------

    AU_MOINS_UN rule obliges the user to create  one and only one concept of the list.

-    Example

     Oper AFFE_CHAR_MECA contains the rules :

                 regles=(UN_PARMI('VECT_Y','ANGL_VRIL'),

-     That means if AFFE_CHAR_MECA is used in the JDC, the user must select VECT_Y or ANGL_VRIL.

       * If the user doesn't select any of these keywords, DEFI_GROUP is unvalid. 
       * If he selects only VECT_Y, DEFI_GROUP is valid. 
       * Eficas will not proposed the keyword ANGL_VRIL if VECT_Y already exists.


EXCLUS
------

    EXCLUS means that, if one of the keyword is created, the other won't be allowed. 
 
 -   Example :
     DEFI_SQUELETTE contains the rules :

                     EXCLUS('SOUS_STRUC','SECTEUR')

-     That means if DEFI_SQUELETTE is used in the JDC

       * If the user doesn't select any of these keywords, DEFI_SQUELETTE  is  valid. 
       * If he selects only SOUS_STRUC, DEFI_SQUELETTE is valid. 
       * Eficas will not proposed the keyword SECTEUR if SOUS_STRUC already exists.

ENSEMBLE
--------

    the rule means that if one keyword is selected, the others have to be also.
    the keywords order is not meaningful.

-    Example

    GRILLE in  AFFE_CARA_ELEM, contains :

                       ENSEMBLE('ORIG_AXE','AXE')

-   That means if GRILLE is used in the JDC

       * If the user doesn't select any of these keywords, GRILLE  is  valid. 
       * If he selects only ORIG_AXE, GRILLE is invalid. 
       * If he selects both ORIG_AXE and AXE, GRILLE is valid. 

PRESENT_PRESENT
---------------

    the rule means that if the FIRST keyword is selected, the others have to be also.

-     Example

    MACRO_MISS_3D contains the rule

                     PRESENT_PRESENT('FREQ_MIN','FREQ_MAX','FREQ_PAS')

-   That means if MACRO_MISS_3D is used in the JDC

       * If the user doesn't select any of these keywords, GRILLE  is  valid. 
       * If he selects only FREQ_MAX, GRILLE is unvalid. 
       * If he selects only FREQ_PAS, GRILLE is valid. 
       * If he selects only FREQ_MIN, GRILLE is invalid. 
       * If he selects both FREQ_MIN, FREQ_MAX  and FREQ_PAS, GRILLE is valid. 


PRESENT_ABSENT
--------------

    the rule means that if the FIRST keyword is selected, the others aren't allowed.

-    Example
     FORCE_COQUE in AFFE_CHAR_MECA contains 

                 regles=( PRESENT_ABSENT('FX','PRES','F1','F2','F3','MF1','MF2'),

-   That means if FORCE_COQUE is used in the JDC

       * If the user doesn't select any of these keywords, FORCE_COQUE  is  valid. 
       * If he selects only FX, FORCE_COQUE is valid. 
       * If he selects both PRES and F1, FORCE_COQUE is valid. 


     


