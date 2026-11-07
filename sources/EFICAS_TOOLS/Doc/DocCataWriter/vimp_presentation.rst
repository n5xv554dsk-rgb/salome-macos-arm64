VIMMP DataModel
===============

Definition and Usage
____________________

The VIMMP data model is designed to help code developers:
        * Automatically generate XML drivers for input / output parameters
        * Allow users to write a specific code parameter file in xml or python format. It deals with syntax and semantics issues ensuring the integrity of the file.
        * Provide help to define the calculation scheme

The generated python input parameter files can also be seen as a way to supervise a set of computational steps (commands) with their arguments.
The available commands are defined by the data model (also called catalog).
Building a new user data set that conforms to a data model consists of choosing the desired commands from the available commands.
Each selected command has its specific parameters that the user must define. Some are required, some require multiple occurrences, others require the user to name the returned concept.


General Behaviour
_________________

Xml driver generation requires an XML schema definition describing the data model.
You may be writing your data model in XSD, but it will be painful and time consuming.
In addition, there are several ways to describe the same model in XSD.
Eficas tool is useful to describe quickly your data model in a catalog and will provides you an .xsd mapping involving easy to use generated drivers.
Eficas manages dynamic validation rules and also provides a graphical (model-compliant) interface for creating valid sets of documents / user data.


Common Data Model
_________________

The set of VIMMP usecases are converted into executable workflows managed by an orchestrator as YACS module of the SALOME project.
These workflows manipulate parameters to launch the different codes.
Some parameters are common to multiple workflows and define the VIMMP common data model for launching the workflows.

Specific Data Model
___________________

Some parameters are specific to a workflow/a code and is useless to the others.
However they are needed to launch the workflow then you will have to define the VIMMP specific data model for being able to launch the workflows.



