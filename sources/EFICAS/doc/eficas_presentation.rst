What's EFICAS
=============

Name's origin
-------------
EFICAS is the acronym of ' Editeur de FIchier de Commandes et Analyseur Sémantique'. 
That means that EFICAS allows users to write a parameter file for a code.  
It handles whith syntax and semantics.  
It avoids misuse of commands which are not allowed in a given context.
It insures integrity of the file.  

General Behaviour
-----------------
* Catalogs

EFICAS can be used by multiple codes and handles with multiple versions of each code. It is customized with files named "Catalogue" : It contains all commands for a code.  Each command has a name and parametres which are defined by developpers.


* Outputs

Eficas's output is a commands file named ".comm". It may be able to produce various file formats such as .xml for OpenTurns. However, you always must have a '.comm" output: this is the only format Eficas is able to reread. 

Both Command Files and Catalogs are python file. So you have to remind some 
:ref:`python-label`

 
