How to activate uncertainty for specific keywords 
===================

Definition and Usage
____________________

A model keyword defines an input parameter. It specifies the information (ie name, type) and some of the constraints on the parameter value. 
A model keyword has a parent : it is located in a command (in a PROC or OPER at the second level of the tree) or within a group (BLOC or FACT).

Syntax
______


General syntax 
~~~~~~~~~~~~~~

Source line code is  :
::
   
   myKeyword = SIMP (typ = 'R')

| The *typ* attribute precises the type of keyword (in this case, float)
| "myKeyword" is the name of the keyword. It is a python label. A keyword can not have the same name as its brothers.
| The *typ* attribute  is mandatory. The other SIMP attributes (see below) have a default value and are optional. 


Typ
~~~

The *typ* attribute can take the following values :

  - A  simple type :
     *  boolean (bool)
     *  integer (I)
     *  float   (R) 
     *  complex (C)
     *  text    (TXM)

    Examples :

    ::

         number_of_species    = SIMP( typ='I'   ),
         YoungModulus         = SIMP( typ='R'   ),
         electrostatics_is_on = SIMP( typ=bool, ),


    * Valid values for number_of_species    : 1, -6, 128 
    * Valid values for YoungModulus         : 1, 110.3,  -6., 14.5×10−3 
    * Valid values for electrostatics_is_on : True, False , 0, 1
  |

  - A tuple of N elements (Tuple(3)). 

    * Within each tuple, each model element has a specified type. 

    ::

         pair_identification  = SIMP(statut ='o', typ=Tuple(2), validators=VerifTypeTuple(('TXM','TXM'   )),),
         simulation_box_sizes = SIMP(statut ='o', typ=Tuple(3), validators=VerifTypeTuple(('R'  ,'R', 'R')),),
         length               = SIMP(statut ='o', typ=Tuple(2), validators=VerifTypeTuple(('R'  ,'TXM'   )),),


    means that pair_identification is a tuple of two strings, simulation_box_sizes a tuple of three floats and length a tuple whose first parameter is a float and second one a string.
       	  
       * Valid values for pair_identification  : ('A', 'A'), ('A','B')
       * Valid values for simulation_box_sizes : (1,1.,0), (2.,-2.5, 10+3)
       * Valid values for length               : (1,'m'), (2., 'cm') but also (and badly) (-500, 'Fahr') or (32, 'fareneit') 

    .. note:: A tuple element is not seen as a list but as ONE element. (it is possible to define list of tuple -see the paragraph 'cardinality' )


  -  A directory  or a file (existing or not)

     +-------------------------------------+-----------------------------------------------------+
     | parameter is  :                     | catalog's description is :                          |
     +=====================================+=====================================================+
     |an existing file                     | typ='Fichier'                                       |
     +-------------------------------------+-----------------------------------------------------+
     |a directory                          | typ='Repertoire'                                    |
     +-------------------------------------+-----------------------------------------------------+
     |an existing file with specific suffix| typ=('Fichier','JDC Files (*.comm);;All Files (*)') |
     +-------------------------------------+-----------------------------------------------------+
     |a non-existing file                  | typ=('Fichier',"",'Sauvegarde'),                    |
     +-------------------------------------+-----------------------------------------------------+
     |a file (existing or not)             | typ='FichierNoAbs'                                  |
     +-------------------------------------+-----------------------------------------------------+
     |a file or a directory                | typ='FichierOuRepertoire'                           |
     +-------------------------------------+-----------------------------------------------------+

     .. note:: To filter filenames, you have to set the *typ* attribute with a python tuple :

	    * The first element is a fixed string value : *'Fichier'* , *'Repertoire'* , *'FichierNoAbs'* , *'FichierOuRepertoire'*
	    * The second element is a Qt filter string as defined by QT. This string is only used  by the graphical interface. The filter is inactive for *typ* *'Repertoire'* . 
	    * The third element is only used with the value *'Sauvegarde'* in the triple *('Fichier',"",'Sauvegarde')* to activate the non-existing file usecase. 

  -  Or previously user defined type in the catalog (a mesh for example)

     A user-defined class inherits from the class ASSD 

     ::
     
         class mesh (ASSD) : pass
         myMesh=SIMP(typ = 'mesh')
 
     In this case, myMesh is a keyword waiting for a mesh instance. This instance has to be created with an OPER command.
     (todo label)


Cardinality
~~~~~~~~~~~
It is possible to constrain the number of occurences (cardinality) of a keyword. The cardinality is set using the min and max attributes.
If min=max=1 (default), the keyword is only one (unique) value. if max > 1, parameter is a list. min/max specify the minimum/maximum number of occurences in the list. 'max= "**"' does not set an upper limit for the maximum cardinality, but allows you to enter as many values as needed.

..  code-block:: python

      scalar 		    = SIMP(typ = 'R')
      list_of_scalars	    = SIMP(typ = 'R',max="**")
      list_of_3_to_5_scalars= SIMP(typ = 'R',max=5, min=3)


* Valid values for scalar 		      : 1., 2., 
* Valid values for list_of_scalars	      : (1.,1.,0), (2.,5., 7.,8,.,... 999.), (1.,)
* Valid values for list_of_3_to_5_scalars : (1.,1.,1), (1.,1.,1.,1.),(1.,1.,1.)

Note that a list may be mandatory or optional. 
    

Other useful attributes 
~~~~~~~~~~~~~~~~~~~~~~~
  +-------------+-------------------------------------------------+-----------+
  |*attribute*  |*Description*                                    |*default*  |
  +=============+=================================================+===========+
  | statut      |status  'o' if mandatory and 'f' if not          |    f      |
  +-------------+-------------------------------------------------+-----------+
  |into         |finite set of value                              |  None     |
  +-------------+-------------------------------------------------+-----------+
  |val_min      |minimal value                                    |float(-inf)|
  +-------------+-------------------------------------------------+-----------+
  |val_max      |maximal value                                    |float(inf) |
  +-------------+-------------------------------------------------+-----------+
  |ang          |short documentation                              |  None     |
  +-------------+-------------------------------------------------+-----------+
  |defaut       |default value                                    |  None     |
  +-------------+-------------------------------------------------+-----------+
  
  And some examples :

..  code-block:: python
		   
    print_frequency = SIMP(statut='f', typ='TXM', defaut='every', into=['every','never','10 steps'])
    close_time 	    = SIMP(statut='f', typ='R'  , defaut=1000, val_min=0)
    number_of_steps = SIMP(statut='f', typ='I'  , defaut=100 , val_min=0, val_max=1000)


* Valid values for print_frequency : 'every','never','10 steps' and nothing else
* Valid values for close_time 	    : positive float (not nul)
* Valid values for number_of_steps : integer between 1 and 999
    

