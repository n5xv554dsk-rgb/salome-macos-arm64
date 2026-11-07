EFICAS terms
============

Apart of a root node (named JDC_CATA), catalogs contain different types of entities :
 
  - terminal_symbol         : SIMP (SIMPle type) or SIMP_keyword
  - group_of_eficas_keyword : FACT (shorcut for FACTOR) or BLOC (conditionnal FACT): 
          - Content elements are terminal_symbol or group_of_eficas_keyword
          - The grouping of these keywords is important  from a data modelling perpective.
          - The group_of_eficas_keyword can be conditional and only becomes necessary  if another parameter meets a condition (ie wind_direction is only necssary if wind_speed is not nul) 
  - eficas_keyword         : terminal_symbol or group_of_eficas_keyword
  - commands               : PROC (shortcut for procedure) or OPER (shortcut for operator). 
	  - they constitute the second level of the hierachical tree (after root node). 
          - PROC and OPER both contain other keywords (group or terminal_symbol). 
          - an OPER returns a user class, unlike PROC which returns nothing.
          - this objet has a type and a name.
  - rules                  : defines the structure of the dataset (if element A is present, element B has to be present also) or order of the commands (ie : element START is defined before END) 
           
  - concept                : is a user defined class declaration. It can be used  as a type for a parameter. Nothing is pre-judged about this class implementation. The actual definition/implementation can be found in the context of code project.

Catalogs have a python syntax :ref:`python-label`
