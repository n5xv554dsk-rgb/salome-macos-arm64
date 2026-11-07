.. _bloc-label:


Defining a conditional Group  
=============================

Definition and Usage
____________________

| In a user dataset, a conditional group will exist (or not) depending on the evaluation of a python condition which often takes the form parameter == value). This python condition is dynamically evaluated.
| Apart from its cardinality, a conditional group has the same syntax as non-conditional group.

Syntax
______

General syntax 
~~~~~~~~~~~~~~

Syntax is  :
::
   
     myConditionalGroup = BLOC( condition= " python statement",
        ... #included SIMP or others FACT/BLOC
     )

BLOC can be seen as an 'if' statement.
Python statement contains often <, >, ==  but it can be any expression returning True or False.


.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-after: Test_proc_5
    :end-before: #Test_proc_5

This means :
 * if frequency_every == 'every', particule_printed (only one) is requested 
 * else step_to_be_printed (list) is required. 
     

Don't forget that catalogs are python code. All "keywords" are arguments and in python, arguments are separated by comma "," and must be enclosed in parenthesis. Note that conditions are statements but also python strings.  Use single quotes within double quotes if needed.



Cardinality
~~~~~~~~~~~
- A BLOC appears based on the evaluation of the conditional statement. it has no mandatory or optional status 
- Also, a BLOC has no cardinality. It cannot be repeated. On the other hand, the FACT or SIMPs that make it up may have multiple cardinality and may appear several times.
- if keywords within a BLOC have a status,it is applied within the BLOC.

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-after: Test_proc_6
    :end-before: #Test_proc_6

This means :
  * if wind_speed > 0.5,  wind_direction is needed and rain_speed can be added
   

    

Other useful attributes 
~~~~~~~~~~~~~~~~~~~~~~~
  +-------------+-------------------------------------------------+-----------+
  |*attribute*  |*Description*                                    |*default*  |
  +=============+=================================================+===========+
  |ang          |short documentation                              |           |
  +-------------+-------------------------------------------------+-----------+
  
    
