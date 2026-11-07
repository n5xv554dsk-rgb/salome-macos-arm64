.. _Defining-steps-in-a-catalog:

Defining steps in a catalog
===========================


Step nodes
__________


General syntax
~~~~~~~~~~~~~~
A step can be :
 * PROC  : a simple procedure 
 * OPER  : a command returning a concept/user type

A PROC definition aggregates hierarchical data to express a consistent part of your modeling.

::

  MonPROC = PROC (nom = 'MonPROC', ..
  );
  MonOPER = OPER (nom = 'MonOPER', sd_prod= myUserClass,
  );  

To describe a PROC, the attribute "name" is mandatory and must  be the stringfield lvalue. Note that the variable name must begin with an **upper character**. Once a PROC or an OPER is defined you can add elements FACT, BLOC or SIMP inside .

::

   Solver_Input = PROC(nom = 'Solver_Input',
     simulation_title 		   = SIMP(statut='o', typ='TXM', defaut='Simple test'),
     time_step 			   = SIMP(statut='o', typ='R'  , defaut=0.01 , val_min=0),
     number_of_steps 		   = SIMP(statut='o', typ='I'  , defaut=10000, val_min=1),
     number_of_equilibration_steps = SIMP(statut='o', typ='I'  , defaut=1000 , val_min=1),
     job_properties= FACT(statut='o',
        job_duration 	= SIMP(statut='o', typ='R'  , defaut=1000, val_min=0),
        stack_size 	= SIMP(statut='f', typ='R'  , defaut=1000, val_min=0),
        print_frequency = SIMP(statut='f', typ='TXM', defaut='every', into=['every','never','sometimes']),
        close_time 	= SIMP(statut='f', typ='R'  , defaut=1000, val_min=0),
       ),
  );

.. _Defining-a-concept-type-user:

Defining a concept type / user type
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An OPER definition agregates hierarchical data in order to express a coherent part of your modelisation.
Despite a PROC, an OPER produces a new data(object) that you can reuse in further defintion. 
An oper can be considered as a function call with many parameters more or less complex and which returns a new one.

To describe an OPER , you have first to describe a user-defined concept type.
Declarations appear at the beginning of the catalogs. User classes inherits from ASSD. Most of the time the pass statement is all you need to write.

::

  from Accas import *
  class myInteger(ASSD)      : pass
  class mesh(ASSD)           : pass
  class meshEntity(ASSD)     : pass
  class meshNode(meshEntity) : pass
  class meshEdges(meshEntity): pass
  class field(ASSD)    	     : pass

OPERs return  value. The return_type is a user-defined data type.

::
   
   class mesh(ASSD)      : pass
   ReadMesh = OPER (nom = 'ReadMesh', sd_prod = mesh,
     MyFile= (typ=’Fichier’, statut ='o'),
   );
   CalculateField = OPER( nom = 'CalculateField', sd_prod=field,
    is_on_mesh=SIMP(typ=mesh, statut='o'),
    calculFunction = FACT(...),
   );


::

   mymesh  = ReadMesh(MyFile="/tmp/vimmp.mesh");
   myField = CalculateField(is_on_mesh=mymesh, calculFunction=...);

The end user can define a mesh with ReadMesh OPER (This mesh will be named) and then use this mesh in order to defined a Field....

Other useful attributes 
~~~~~~~~~~~~~~~~~~~~~~~
  +-------------+-------------------------------------------------+-----------+
  |*attribute*  |*Description*                                    |*default*  |
  +=============+=================================================+===========+
  | statut      |status  'o' if mandatory and 'f' if not          |    f      |
  +-------------+-------------------------------------------------+-----------+
  |ang          |short documentation                              |           |
  +-------------+-------------------------------------------------+-----------+
  
