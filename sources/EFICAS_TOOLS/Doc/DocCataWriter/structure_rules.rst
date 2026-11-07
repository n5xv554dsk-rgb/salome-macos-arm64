.. _rules-label:

Defining rules 
==============

Definition and Usage
____________________

Sometimes the user wants his data to comply with certain construction rules.
These rules affect the structure of the user's data set (not the value).
They can be applied to any entity (OPER, PROC, JDC, BLOC or MYCONCEPT).

Syntax
______

General syntax
~~~~~~~~~~~~~~

Syntax is  :
::
   
     regles = (..list of rules),


AU_MOINS_UN
-----------
AU_MOINS_UN rule requires to create at least one eficas_keyword from the list. More than one can be created. 
::
   
    Structure = FACT ( statut ='f',
        regles = (AU_MOINS_UN( 'Beam', 'Bar', 'Grid'),)
        Beam = FACT (...),
        Bar = FACT (...),
        Grid = FACT (...),
     );

If 'Structure' is  defined, one of the keyword 'Beam', 'Bar', 'Grid' is also defined.
   * If none of these keywords is present, the structure is invalid. 
   * If only the word "Beam" is present, the structure is valid. 
   * If both keywords "Beam" and "Bar" are present, the structure is valid. 

UN_PARMI
--------
UN_PARMI rule forces the end user to create one and only one eficas_keyword from the list.
::
   
   FOR_DPD = BLOC(condition = "code=='DPD'",
           regles=(UN_PARMI('Initialisation', 'Solver_Input'),
                   ),
           ...),

The end user must select 'Initialisation' or (exclusive or) 'Solver_Input'.

   * If the user does not select any of these keywords, the dataset is invalid. 
   * If he selects only 'Solver_Input', the dataset is valid. 
   * If he selects only 'Initialisation', the dataset is valid. 
   * If he selects both, the dataset is invalid. (Ihm will not proposed the keyword 'Initialisation' if 'Solver_Input' already exists.)


EXCLUS
------
EXCLUS means that, if one of the eficas_keyword is created, the others will not be allowed. 
::
   
     JOB_DURATION = FACT(statut='o',
            regles=( EXCLUS('duration','number_of_time_step','end_at'),
                   ),
           ...),


Only one or none of the keyword are allowed. 
   * If the user does not select any of these keywords, JOB_DURATION  is  valid. 
   * If he only selects 'duration', JOB_DURATION is valid. 
   * If he only selects 'number_of_time_step', JOB_DURATION is valid. 
   * If he only selects 'end_at', JOB_DURATION is valid. 
   * Otherwise, JOB_DURATION is invalid

ENSEMBLE
--------
The rule means that if one eficas_keyword is selected, the others must be selected as well.
::
   
    GRILLE = FACT(statut='f',
            regles=( ENSEMBLE('ORIG_AXE','AXE'),
                   ),
           ...),

if GRILLE is used in the dataset
   * If the user does not select any of these keywords, GRILLE  is  valid. 
   * If he selects only 'ORIG_AXE', GRILLE is invalid. 
   * If he selects both 'ORIG_AXE' and 'AXE', GRILLE is valid. 


PRESENT_PRESENT
---------------
The rule means that if the FIRST eficas_keyword is selected, the others must be selected as well.
::
   
    FREQUENCE = FACT(statut='f',
            regles=( PRESENT_PRESENT('FREQ_MIN','FREQ_MAX','FREQ_PAS')
                   ),
           ...),

That means  :

   * If the user does not select any of these keywords, 'FREQUENCE' is  valid. 
   * If he selects only 'FREQ_MAX', 'FREQUENCE' is valid. 
   * If he selects only 'FREQ_MIN', 'FREQUENCE' is invalid. 
   * If he selects both 'FREQ_MIN', 'FREQ_MAX' and 'FREQ_PAS', 'FREQUENCE' is valid. 


PRESENT_ABSENT
--------------
The rule means that if the FIRST eficas_keyword is selected, the others are not allowed.
::
   
     GRID  = FACT(statut='f',
         regles=( PRESENT_ABSENT('GroupOfNodes','GroupOfFaces','GroupOfEdges'),
                ),
     ...),

This means  :

     * If the user does not select any of these keywords, 'GRID' is  valid. 
     * If he selects only 'GroupOfNodes', 'GRID' is valid. 
     * If he selects both 'GroupOfFaces' and 'GroupOfNodes', 'GRID' is invalid. 


All rules can be combinated, which creates more complicated rules.

::
   
     GRID  = FACT(statut='f',
         regles=( PRESENT_ABSENT('GroupOfNodes','GroupOfFaces','GroupOfEdges'),
                  ENSEMBLE('GroupOfFaces','GroupOfEdges'),
                ),
     ...),


That means  :

     * If the user select 'GroupOfNodes', GRID  is  valid. 
     * If the user select 'GroupOfFaces' and 'GroupOfEdges', GRID  is  valid. 
     * If he selects none of these keywords  GRID is valid. 
     * Otherwise 'GRID' is invalid
