.. _python-label:

===============================
Rules for python syntax
===============================

Variable names and identifiers are similar to those in many other languages :
-----------------------------------------------------------------------------

* They start with a letter (A_Z or a-z) or an underscore "_"".
* They are followed by letters, numbers or underscores.
* They are case-sensitive.
* A string is a sequence of caracters enclosed by a pair of matching single or double quotation marks.



Some identifiers are reserved words :
-------------------------------------

* You cannot use words of the python language as identifiers.
* Some identifiers are reserved words. For example, you cannot use the following words, even if they sound like interesting names:
	- ASSD, BLOC, EXCLUS, 
	- ENTITE, ETAPE, EVAL, , JDC
	- OPER, PROC, 
        - REGLE, VALIDATOR 
        

Catalogs are executable python files:
-------------------------------------
Keep in mind that :

* The simplest form of assignement is : variable = value
* The hash character (#) starts a comment
* Tuples are enclosed in square brackets. 
* Lists are enclosed in parentheses.
* Brackets have to be closed.
* To create a list, elements must be separated by ','. Do not forget this ',' even if the list contains only one element.
* If necessary, classes or functions must be defined.
* Arguments are separated with ','

::

     #code python :
     time_step = SIMP(statut='o', typ='R',)

This is a instantiation operation. It creates an object of type SIMP. the SIMP  __init__() is called with two arguments statut and typ.

You must respect the python syntax and remember that the commands (OPER and PROC) must begin with a capital letter.


