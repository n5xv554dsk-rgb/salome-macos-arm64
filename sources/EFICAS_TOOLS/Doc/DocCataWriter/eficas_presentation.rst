Eficas Tool 
===========
Eficas is an open source DSL (Domain Specific Languages). It is a formal language for designing domain-specific models.
Based on Python, this DSL defines an easy to use grammar. It can be used to quickly express data models and describe tree structures. Validity rules are used to ensure data/parameter validity and global data structure consistency.
In addition to automatically generating an equivalent XSD model, Eficas also provides a graphical interface that automatically adapts to changes in the description of the model.  Eficas' approach is a hybrid one, involving the development of a Python grammar from which an XSD can be generated.
The specification of a model takes the form of Python files. These files are also known as catalogues.


Eficas DataModels Usage
________________________

Eficas is designed to help code developpers. It allows to:

        * simplify the writing of data models thanks to Eficas definition specific langage (DSL) in python.
        * automatically generate a corresponding unambiguous XSD description.
        * propose dynamic validation that takes into account the value of certain parameters to activate specific parts of the model
        * maintain consistency between the  version of the model expressed in the Eficas grammar and the corresponding XSD version.
        * validate datasets against these data models (one of them or both)
        * use directly the produced XSDs (thanks to their unambiguity) in automatic driver generation tools (such as pyxb) and  thus easely generate XML drivers (in C++ and Python) for input/output parameters.
        * automatically generate a GUI which allows end users to write a specific code parameter file / dataset in xml or python format. This GUI frees the user from syntax and semantic issues and guarantees data integrity
        * provide help to define the calculation scheme / calculation workflows in Salome environment.

The dataset format is either python or XML, or both.
A valid dataset conforms to the structure and the rules  of the data model against both XSD and DSL python format.
Eficas is developped in python. 
For Gui Part, QT5 is needed. 

General Behaviour
_________________

 * Models
 Most automatic driver generation tools require an XSD definition of the data model.  However, writing  a  data model directly into XSD is often painful and time consuming.
 the Eficas grammar is used to express a data model faster in a python-like format (called catalog).  Then, Eficas provides  an .xsd mapping able to transcribe level of validation  made in Eficas.  Translation from this grammar to XSD is done automatically. Resulting XSD are unambiguous and can also be used easely with automatic drivers generating tools. Eficas allows to manages dynamic validation rules (a simple way to activate part of the XSD description according to the values of certain parameters,). It  also provides a graphical (model-compliant) interface to create valid sets of documents / user data. In addition, this generated graphical representation allows a virtuous cycle between the design of the model and the visual representation.

 An Eficas catalog can contain other Eficas catalogs.  This means that others catalogs can be used to supplement the structure of another catalog through inclusion/import mechanisms.

 * Data Sets
 The available commands are defined in the data model.
 In order to create a new valid data set, the end user can use the GUI and choose parameters/commands  (parts of the XSD schema) from those available. He defines valid values for mandatory parameters (cardinality, type...) and adds optional parameters if necessary.

 Data sets can be built/modified/validated by command line (TUI).

Eficas data files (in Python) can be seen, and most of the time they are, as a set of parameters. but they can also be seen as a set of function calls with their arguments. This python/XML  duality of the dataset expression  allows on  the one hand to execute the dataset in a proper python context, and/or, on the other hand to use it as a set of input parameters for code. 

 * Workflows
 Workflows managed by an orchestrator such as the YACS module of the SALOME project manipulate the parameters to launch codes.
 Some parameters are common to several workflows. With Eficas, it is possible to define a common data model for launching workflows and to enrich it with specific data models for each code in each workflow node.

