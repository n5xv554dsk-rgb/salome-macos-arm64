.. _fact-label:

Defining a Group of Keywords  
=============================

Definition and Usage
____________________

| A group is a set of elements. Grouping these elements is meaningfull  from a business data modeling perspective. These elements are either keywords or groups themselves.
| A group has a parent : It is located  in a command (in a PROC or OPER at the second level of the tree) or inside a group (BLOC or FACT).

Syntax
______

General syntax 
~~~~~~~~~~~~~~

Syntax is  :
::
   
     myGroup = FACT (
        ... #included SIMP or  others FACT/BLOC
     )

"myGroup" is a python label. A group can not have the same name as its brothers.
It contains simple elements or groups. There is no recursivity depth limit.

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: job_properties
    :end-at: #job_properties

Definition of FACT including an other FACT : 

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: ThresholdExceedence
    :end-at: #ThresholdExceedence


Cardinality
~~~~~~~~~~~
It is possible to constrain the number of instances (cardinality) of a FACT. The cardinality is specified using the min and max attributes which specifies the minimum/maximum number of repetitions :
 - If min=max=1 (default), the FACT appears only once in a valid dataset. 
 - If min=max=n    the FACT appears n times in a valid dataset. 
 - If max > 1, the group of parameters can appear more than once.
 - "**" means there is no upper limit for the maximal cardinality.

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: species_parameters
    :end-at: #species_parameters

Note that a group status can be mandatory or optional. Regardless of its status, The group contains optional and mandatory elements. In the previous example, species_parameters has to be defined at least one time (in a valid dataset). Within this group, species_is_frozen is not mandatory. For each instance of species_parameters, species_is_frozen can appear or not.
    
Other useful attributes 
~~~~~~~~~~~~~~~~~~~~~~~
  +-------------+-------------------------------------------------+-----------+
  |*attribute*  |*Description*                                    |*default*  |
  +=============+=================================================+===========+
  | statut      |status  'o' if mandatory and 'f' if not          |    f      |
  +-------------+-------------------------------------------------+-----------+
  |ang          |short documentation                              |           |
  +-------------+-------------------------------------------------+-----------+
  
