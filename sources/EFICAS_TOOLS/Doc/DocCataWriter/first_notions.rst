First notions of Catalogs 
==========================

Catalog
-------

Catalogs are a simple way to express a data model.
They organize the elements and specify the relationships between them.

A Catalog defines the rules of parameters validity  but also, and above all, the rules of consistency of a dataset, of its structure.
For example, this means :

     - the type and cardinality of elements,
     - how to order the elements in their relationship to each other,
     - the simultaneous (or exclusive) existence of certain parameters/groups of parameters.  

These rules ensure that a dataset is a consistent entity.

Once the catalog is well-defined, EFICAS generates automatically an XSD file.
These are two views of the same data model. 

Dataset
-------
The python user dataset and/or xml file(s) is/are validated  and compliant(s) with the catalog and/or XSD file.
The generated python/xml parameter files can be seen  :

  1.  as hierarchical data ordered in a tree.

  2.  as an organized way of calling data object contructors with their parameters.
     
  3.  as a set of computational steps (commands) with their arguments (very close to python code)

| The data/commands roots are called steps.
| A user data/commands set is a collection of 'steps'.
| Each step is a consistent process/part of a complete workflow/dataflow. 

