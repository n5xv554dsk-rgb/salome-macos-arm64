Getting Started with Eficas  
===========================

Installation
_____________

       - clone  https://git.forge.pleiade.edf.fr/git/eficas.git
       - cd UiQT5; make
       or
       - cd UiQT6; make


Using Eficas GUI
________________

Eficas is a DSL, reads data models and generates dynamically 
Th data model takes the form of a python file named catalogue. 
An empty python template file CataTemplate.py and a file containing some examples of simple parameters cataAZ.py are present under the Tools directory. They should help you write your own data model.  
You can test the GUI part 

..  code-block:: python

    $EFICAS_ROOT_DIR/Tools/qtEficasGui.py -c $Home/EficasFilesForMyCode/CodeCatalog.py


Appropriate sections explain in detail each catalogue concept. 
Working with the GUI to write the catalogue is a good way to check both its syntax and semantics. Best is to start the GUI by copying and modifying one of the sample catalogues


For each code and each version of code, a catalog is created 
If a file named pref_code  



      

(
