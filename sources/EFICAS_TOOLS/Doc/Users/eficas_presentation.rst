What's Eficas
==============

Name's origin
-------------
Eficas is the acronym of ' **E**\ diteur de **FI**\ chier de **C**\ ommandes et **A**\ nalyseur **S**\ émantique'. 
That means that Eficas allows users to write a parameter file for a code.  
It handles with syntax and semantic.  
It avoids misuse of commands which are not allowed in a given context.
It insures integrity of the file.  

General Behaviour
------------------
* Catalogs

Eficas can be used by multiple codes and handles with multiple versions of each code. It is customized with files named "Catalogs (or Catalogues)" : It contains all commands for a code.  Each command has a name and parameters which are defined by developpers.


* Outputs

Eficas's output is a commands file (dataset file or Jeux De Données)  ".comm". It may be able to produce various file formats such as .xml, .py or specific format. However, you always must have a '.comm" output: this is the only format Eficas is able to reread. 

Both commands Files and Catalogs are python file. So you have to remind some 
:ref:`python-label`

 
