.. _concept-label:

Eficas Concepts
================

Commands in the Data Set (or JDC Jeu De Commandes )
---------------------------------------------------

A dataset is made of a collection of commands. Each command have parameters (keywords). They can return concept or not: 

* Command not returning concept : they are described as "PROC" in catalogs.

  - example:
   	 - DEBUT() is a proc.  
   	 - for ASTER, it initializes memory and files.

* Command returning a concept :
  The concept has a specific type (defined in the catalog) and a name (given by the user).  These commandes are described as "OPER" in catalogs.

  - example :
         - MONMAIL=LIRE_MAILLAGE(UNITE=20);
         - This line creates a new concept MONMAIL of type "maillage", which can be re-used as entry for another keyword.

  When an object is valid, the user has to named it. In tree view, a yellow square shows valid objects that have to be nammed. 

Commands are composed of keywords, or groups of keywords.  These items are associated according to rules or conditions. 
They are described in the catalog.


Keywords
---------

* Group of keywords  (mot-clef facteur )

   This is a list of keywords which jointly have a meaning for the code.
   It is composed of group of keywords and simple keywords.
   Some are mandatory, repeatable.
   This list can depend on conditionnal rules.
   

* Simple keyword (mot-clef simple) .

   This is a parameter. It also can be mandatory or not.
   It has attributes.
   

Attributes of a keyword
---------------------------

a parameter (simple keyword or "mot-clef simple") has :

- a type : real, string, complex, integer, matrix, file (existing or allready existing), directory or a concept class which is defined in the catalog. 
- a cardinality.

a parameter (simple keyword or "mot-clef simple") should have :

- a default value 
- a short documentation
- a long documentation
- an interval of values 
- a set of discrete values


Input data panel depends on both these attributes. Eficas ensures that data are valid. It forces the user to enter a list if needed, it verifies the input type. It displays only possible values.



