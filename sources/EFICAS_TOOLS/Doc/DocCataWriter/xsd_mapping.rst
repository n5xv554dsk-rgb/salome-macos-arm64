.. _mapping-label:

..
   Le TEST_ROOT n'est pas évalué dans le literalinclude
.. |TEST_ROOT| replace:: ../Tests/MappingAccasXsd/
.. |cata_1.py| replace:: :download:`cata_1.py <../Tests/MappingAccasXsd/cata_1.py>`
.. |cata_1.xsd| replace:: :download:`cata_1.xsd <../Tests/MappingAccasXsd/cata_1.xsd>`
.. |cata_1_test1.xml| replace:: :download:`cata_1_test_1.xml <../Tests/MappingAccasXsd/cata_1_test_1.xml>`
				 
Generating the XSD file from the catalog file
=============================================

generateXSD command
____________________

To obtain the |cata_1.xsd| file corresponding to the |cata_1.py| file just enter ::
  
   python ./generateXSD.py -c ./cata_1.py


Here is the interesting part of |cata_1.py| content. 
   
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-after: beginJdC
    :end-before: endJdC


The generateXSD command has created the |cata_1.xsd| file.

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml

You may check it with xmllint command.
You may visualize it with xsddiagram command.

Using PyXB to generate drivers
______________________________

Using the XSD model file to get an XML generated driver is as simple as typing ::

  pyxbgen -m cata_1_genere -u cata_1.xsd  --write-for-customization

It will create an raw/ directory containing various classes imported from the ./cata_1_genere.py file.
  

Using PyXB generated drivers 
_____________________________

You can use the driver to load an xml file like |cata_1_test1.xml| conforming to the |cata_1.xsd| file. 

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1_test_1.py
   :end-before: CONFIGURATION

Once the .xml file is loaded you can display it in a pretty xml format.

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1_test_1.py	     
   :start-after: _setOrphanElementInContent

Understanding the XSD mapping for SIMP
______________________________________

SIMP for type simple type {'I','R', bool, 'TXM'}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Declaring an SIMP with a *type* attribute
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The *SIMP* is mapped to an xsd global type and an xsd element.
The xsd element is defined locally and may appear multiple times depending on the use the catalog does of it. 

If we look at the test_simp_2 in |cata_1.py| content, we get an example of an *SIMP* of *type* 'I' (int type).

.. todo::
   Give the possibility of customizing the xsd type used by an eficas type

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2
    :end-at: test_simp_2

Here is the corresponding mapped XSD type :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_2"
   :end-at:   /xs:simpleType

An XSD element local declaration using this type is obviously defined since we declare it in the catalog :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_2"
   :end-at:   name="test_simp_2"
	   
You may notice that the XSD elements attributes **minOccurs** and **maxOccurs** are defined by default to 1 since the *statut* attribute is obligatory *'o'*.
The XSD attribute **default** value is set to 2 conforming to the catalog *defaut* attribute.

.. note::
   * The xsd **minOccurs** attribute value of an element declaration that comes from an *SIMP* is either 0 or 1. 
   * The xsd **maxOccurs** attribute value of an element declaration that comes from an *SIMP* will alway be 1.

If we look at the test_simp_4 in |cata_1.py| content, we get an example of an *SIMP* of *type* bool (boolean type).

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_4
    :end-at: test_simp_4

Here is the corresponding mapped XSD type :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_4"
   :end-at:   /xs:simpleType

And the XSD element local declaration :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_4"
   :end-at:   name="test_simp_4"

.. note:: Notice that the eficas *defaut* attribute is set to the python value True and the **default** xsd attribute is set to the xsd value true

.. note:: If two *SIMP* have the same name (so, not sibling *SIMP* ) and different *type* attributes, there will be two local element declarations with the same name and two global xsd **type** with two different typenames

		 
Defining how many times a *SIMP* may appear
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If we look at the test_simp_2_3 in |cata_1.py| content, we get an example of an *SIMP* of type 'I' using *min* and *max* attributes. 
   
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2_3
    :end-at: test_simp_2_3
	    
Here is the corresponding mapped XSD type :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_2_3"
   :end-before:  T_test_simp_2_4

..
   ATTENTION, JE N'AI PAS TROUVE UNE MEILLEURE BALISE DE FIN que le nom du test suivant : T_test_simp_2_4.
		 
You may notice that the XSD type is very different from the **T_test_simp_2** one.
This is because the XSD list type is used for multiple occurrences of a *SIMP* and the XSD list must be derived by restriction to get our own list type.

An XSD element declaration using this type is also defined as for test_simp2 :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_2_3"
   :end-at:   name="test_simp_2_3"

You may notice that the minimum and maximum sizes of an XSD list are defined in the type definition thanks to a facet :

..  code-block:: xml
    
	<xs:minLength value = "3"/>


Remind that in XSD, if there is no **maxLength** facet definition, the size of the list is considered unlimited. 
If a *max* eficas attribute is set to a number instead of '**' you get a additional **maxLength** xsd attribute as for type *test_simp_2_4* :
   
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2_4
    :end-at: test_simp_2_4
	    
Here is the corresponding mapped XSD type :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_2_4"
   :end-before:  T_test_simp_2_5

The XSD elements attributes **minOccurs** and **maxOccurs** are also defined to 1 conforming to the *statut* value *'o'*.
		 
Defining an *SIMP* default value
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The *defaut* eficas attribute provide a way to give a default value to an *SIMP* if it isn't defined by the user :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2_5
    :end-at: test_simp_2_5

The *defaut* eficas attribute take into account the *min* and *max* eficas attribute. The number of values given in the *defaut* must be in the inclusive [ *min*, *max* ] range.
	     
If we look at the XSD element declaration, you can see the **default** xsd attribute which is set to a list of 4 numbers. 

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_2_5"
   :end-at:   name="test_simp_2_5"

..
   ATTENTION, si un type T_test_simp_2_6 est défini, il faut modifier la balise de fin à cette valeur

We observe that :
 * the value of the XSD attribute **default** is set to a list conforming to the catalog *defaut* attribute
 * the XSD elements attributes **minOccurs** is set to 0 conforming to the *statut* value *'f'*.
 
.. note::  As you may have already noticed, some eficas *attribute* may be mapped to the **xsd type** and others to the **element declaration**.

Constraining the range of possible values
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Thanks to *val_min*, *val_max*, and *into* eficas attributes you may constraint the range of values allowed for the elements.
Here is an example of produced **xsd type** for *val_min*, *val_max* usage :

When we define the fololwing eficas keyword with *val_min*, *val_max* attributes

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2_1
    :end-at: test_simp_2_1
	    
The corresponding generated XSD type is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_2_1"
   :end-before:  T_test_simp_2_2

When we define the following eficas keyword with *into*  attribute :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_2_2
    :end-at: test_simp_2_2
	    
The corresponding mapped XSD type is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_2_2"
   :end-before:  T_test_simp_2_3

The use of the *into* attribute implies a xsd type definition using **xsd enumeration**.

.. note:: Hence it's possible to define an *into* attribute with an *SIMP* of *type* 'R', it is generaly not very useful
		 
Declaring an SIMP with a *type* 'TXM' with an occurence of 1
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The use of 'TXM' type is quite the same as 'I' or 'R' types.
Here is an example for a SIMP with type 'TXM' :

The *SIMP* declaration is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_1_1
    :end-at: test_simp_1_1

You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_1_1"
   :end-at:   /xs:simpleType

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_1_1"
   :end-at:   name="test_simp_1_1"

	      
Declaring an SIMP with a *type* 'TXM' with an occurence >  1
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Here is an example for a SIMP with type 'TXM' with multiple ocurrences :

The *SIMP* declaration is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_1_3
    :end-before: test_simp_2
..
   ATTENTION, si un type T_test_simp_1_4 est défini, il faut modifier la balise de fin à cette valeur

You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_1_3"
   :end-before:  T_test_simp_2
..
   ATTENTION, si un type T_test_simp_1_4 est défini, il faut modifier la balise de fin à cette valeur

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_1_3"
   :end-at:   name="test_simp_1_3"

.. note::
   * The use of eficas *attributes* *val_min* and *val_max* for *type* == 'TXM' may be used to enforce values to be between the *val_min* , *val_max* strings in alphabetical order. The use of eficas *validator* keyword is a better way to check regexp for string values
   * The use of eficas *attributes* *into* is often very convenient to enforce the only predefined possible strings 

.. note::
   * Since the xsd type used to map the eficas attribute *max* when it is >1 is a **list** and since the xsd **list** separator is a space character then you can't use a space character in your strings
   * The xsd type **list** used to map eficas attribute *max* when it is >1 is a choice of mapping which avoid the use of an xml element for each value in the .xml dataset file. Even if you can't express the direct access to an element of the list in the xpath language, it's not an issue in the PyxB generated driver because you get a Python list with its classic acessors
  
SIMP with type { 'Fichier', 'Repertoire', 'FichierOuRepertoire', 'FichierNoAbs' }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Whatever the *typ* is for managing file or directory, by now the xsd mapping is a simple string.
There are possible improvements such as managing xsd regexp expression.

Here is an example for a SIMP with type 'Fichier' with a filename filter :

The *SIMP* declaration is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_7_4
    :end-at: test_simp_7_4

You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_7_4"
   :end-at: /xs:simpleType

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_7_4"
   :end-at:   name="test_simp_7_4"

.. note:: It could be useful to define a specic xsd type for using a well-known type for managing files and directories. 
		 

SIMP of UserASSD type
~~~~~~~~~~~~~~~~~~~~~~
An SIMP may have a user defined type.
Depending on the way you declare the SIMP, you can either create a new data or refer to a previoulsy created one.

Declaration of an UserASSD type SIMP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Here is a declaration example for a SIMP with user type *User_Data*  :

The *SIMP* declaration is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: class User_Data
    :end-at: class User_Data

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_8_1
    :end-at: test_simp_8_1

The *UserASSD* class declared this way is quite the same notion as using an *ASSD* class in an *OPER* command (:ref:`Defining a concept type <Defining-a-concept-type-user>`). The *UserASSD* differs from an ASSD by :
  * the *UserASSD* *SIMP* can be declared where ever you like in the catalog (not just at first level like for an *OPER*)
  * the generated python code (.comm) will call the object constructor of the *UserASSD* type with no parameter

.. todo:: Expliciter le mécanisme en oeuvre au niveau python.

You get the xsd type :
	  
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_8_1"
   :end-at: /xs:simpleType

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_8_1"
   :end-at:   name="test_simp_8_1"

Referencing a UserASSD type SIMP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The *SIMP* reference is done this way:

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :dedent: 8
    :start-at: test_simp_8_2
    :end-at: test_simp_8_2

Note the User_Data type given to the *typ* attribute.
	     
You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_test_simp_8_2"
   :end-at: /xs:simpleType

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="test_simp_8_2"
   :end-at:   name="test_simp_8_2"		 
     
SIMP for complex type {'C'}
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Not yet implemented !

SIMP for type {Tuple}
~~~~~~~~~~~~~~~~~~~~~

Not yet implemented !


Understanding the XSD mapping for JdC, OPER and PROC
____________________________________________________

The JdC root level
~~~~~~~~~~~~~~~~~~

As explained in section :ref:`Defining steps in a catalog<Defining-steps-in-a-catalog>` OPER and PROC commands are the very first keywords that appears under the root node. They both provide a way to agregate data.


The *OPER* command returns a user type while a *PROC* doesn't and just agregate a first level coherent set of data. 

If we have a look to a JdC definition :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: JDC_CATA
    :end-at: JDC_CATA

We notice that the *code* parameter declares the name of the code for which the catalog is written.
The xsd mapping  is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_Test1"
   :end-at:   /xs:complexType

The **xsd:choice** with a **maxOccurs=unbounded** is used because the user may choose how many *PROC* / *OPER* he/she wants and in the order he/she decided.

The root element declaration is :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="Test1"
   :end-at:   name="Test1"

The name of the element comes from the *code* parameter previously defined.
You find all the element declarations that come from all the *PROC* / *OPER* declared in the catalog.

.. note:: For generate drivers with PyXB, it's a really bad idea to define xsd **element** with **maxOccurs** > 1 in a **xs:choice** with a **maxOccurs** == 'unbounded'. Despite the generate code is correct, it produce a python class unusable since the PyXB Finite Automate with Counter can't decide from which schema component two elements of the same type comes from. This ambighuity interrupt the xml production from your python object.

.. note:: TODO : We have to explain the way we use the schema namespaces.

The OPER command
~~~~~~~~~~~~~~~~


The *OPER* command returns an *ASSD* type (not a *UserASSD*).
An *ASSD* type provides the ability to declare and use a user class in a eficas catalog.

Producing an *ASSD* :
^^^^^^^^^^^^^^^^^^^^^

After having declared the new typename *ASSD* :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: class Mesh
    :end-at: class Mesh

The *OPER* command describes a way to create user type instances :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: ReadMesh
    :end-at: ,)
  

You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_ReadMesh"
   :end-at:   /xs:complexType

.. note::
   * The  **attribute** 'name' is used in the xml dataset to hold the name of the user data *Mesh*.
   * The two xsd **attribute** 'accasType' and 'typeUtilisateur' are for eficas internal use

The element declaration is :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="ReadMesh"
   :end-at:   name="ReadMesh"

Using an already produced *ASSD* object :
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you want to declare in a catalog that a specific data of the dataset is a reuse of an already produced data by an *OPER*, you have to declare it within an SIMP. This SIMP must have the *typ* attribute equals to the *sd_prod* attribute value of the corresponding *OPER* : 
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: MyField
    :end-at: ,)

You get the xsd types :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_MyField"
   :end-at:   /xs:complexType

.. todo:: Revisit the statut attribute use, here if you don't set statut='o' you have **minOccurs** == 0  

and

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_onMesh"
   :end-at:   /xs:simpleType

	      
Concerning the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="MyField"
   :end-at:   name="MyField"

The way we choose to map the *OPER* to xsd allows users to create a cross reference system using name of produced structure in their dataset.

.. todo:: Generate a schema validation rule to check that a name used as a reference is unique and exists in the corresponding object, we have to add in the root element declaration the following code :

..  code-block:: xml
		 
   	<xs:key name="Key_Name_In_CreateMesh">
	  <xs:selector xpath="./Test1:CreateMesh"/>
	  <xs:field xpath="./@nom"/>
	</xs:key>
   
	<xs:keyref name="MyField_Ref_A_CreateMesh" refer="Test1:Key_Name_In_CreateMesh">
	  <xs:selector xpath="./Test1:MyField/Test1:onMesh"/>
	  <xs:field xpath="."/>
	</xs:keyref>

.. note:: PyXB doesn't care about these rules, it relies on the sax/dom parsers capabilities. By default, using the libxml library, these checks are not performed. Anyway it's always possible to fully validate xml datasets by using a parser which have this kind of capability. 

.. todo:: PyXB doesn't automaticaly create links between the objects using the ref name contract. Either the user have to recrate the links or we have to provide a PyXB extension to do so.

The PROC command
~~~~~~~~~~~~~~~~

The *PROC* command agregates a first level coherent set of data.

The *PROC* declaration is :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: Test_proc_2
    :end-at: Test_proc_2

You get the xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_Test_proc_2"
   :end-at:   /xs:complexType

And the element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="Test_proc_2"
   :end-at:   name="Test_proc_2"

Declaring an SIMP of type UserASSD in a PROC or a FACT :
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

Here is a *PROC* declaration using an SIMP UserASSD  :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: class MeshU
    :end-at: class MeshU

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: Meshes
    :end-at: #Meshes
	       
You get the *PROC* xsd type :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_Meshes"
   :end-at:   /xs:complexType

And the associated element declaration :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="Meshes"
   :end-at:   name="Meshes"

.. todo:: We will have an eficas *xsdattribute* attribute to get the *SIMP* as an xsd attribute instead of an xsd element 

Concerning the *FACT* xsd type, you get :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_mesh"
   :end-at:   /xs:complexType
	      
The *SIMP* of UserASSD type becomes :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_name"
   :end-at:   /xs:simpleType
	      
Using an already defined SIMP of type UserASSD :
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you want to declare somewhere in a catalog that a specific data is a reuse of an already defined *UserASSD* *SIMP* data, you have to declare it within an SIMP of type *UserASSD* thanks to the *typ* attribute : 
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: MyFieldBis
    :end-at: ,)

.. note:: Note that this is exactly the same as using an *ASSD* provided by an *OPER*.
	     
You get the xsd types :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_MyFieldBis"
   :end-at:   /xs:complexType

and

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_onMesh_1"
   :end-at:   /xs:simpleType

	      
Concerning the element declaration, you get :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="MyFieldBis"
   :end-at:   name="MyFieldBis"

.. note:: The string **onMesh** element value must be a valid name of a **name** element value from a **mesh** element.
			
.. todo:: We have to write a rule to check this.

			
Understanding the XSD mapping for FACT
______________________________________

As explain in :ref:`fact-label` section, the *FACT* keyword provide a way of grouping elements. It may appear *PROC*, *OPER*, *BLOC* or *FACT*. If we review the following catalog from the :ref:`fact-label` section :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: ThresholdExceedence
    :end-at: #ThresholdExceedence
	     
You get the two xsd complex types using the **<xs:sequence>** xsd element :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_ThresholdExceedence"
   :end-at:   /xs:complexType

and

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_Event"
   :end-at:   /xs:complexType

	      
The element declaration is :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="ThresholdExceedence"
   :end-at:   name="ThresholdExceedence"

In order to illustrate the management of the cardinality, we can review the second example from the :ref:`fact-label` section :			


.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-at: species_parameters
    :end-at: #species_parameters
	     
You get the xsd complex types using the **<xs:sequence>** xsd element :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_species_parameters"
   :end-at:   /xs:complexType

	      
The element declaration is :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-at: name="species_parameters"
   :end-at:   name="species_parameters"

.. note:: The *FACT* cardinality is carry out by the **maxOccurs** attribute of the element declaration. The **minOccurs** attribute deserve the *statut* eficas attribute.

Understanding the XSD mapping for BLOC
______________________________________

As explain in :ref:`bloc-label` section, the *BLOC* keyword provides a conditional way to activate a group of elements. Apart from the *condition* eficas attribute, it's quite the same as the *FACT* keyword.

If we review the following catalog from the :ref:`fact-label` section :

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.py
    :language: python
    :start-after: Test_proc_5
    :end-before: #Test_proc_5

The xsd mapping provides two **<xs:group>** elements :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_frequency_every"
   :end-at:   /xs:group

.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :start-at: name="T_frequ_not_every"
   :end-at:   /xs:group
     
The parent xsd type uses **group ref** declarations :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/cata_1.xsd
   :language: xml
   :dedent: 2
   :start-after: name="T_Test_proc_5"
   :end-before:  /xs:complexType

The content of these groups may appear or not in the parent structure.
Using **group ref** allows the apparition of group content without any additionnal element level.
Considering the *BLOC* semantic, the **minOccurs** attribute is always 0 and **maxOccurs** is always 1.
			   
.. note:: An ambiguity problem may appear if an element with the same name is present in different group's contents.
		   
.. todo:: The *BLOC* xsd mapping must be refine. We may use **key**, **keyref** xsd element to restrict the possibility of activating only one branch of the conditional. However, the semantic of the *BLOC* keyword is wide.

We may have that kind of usescases :
   * A conditional E1 python expression for a B1 bloc with content C1 following a not(E1) expression for a B2 bloc with content C2
   * A conditional E1 python expression for a B1 bloc with content C1 following a not(E1) expression for a B2 bloc with content almost C1, the difference being the type of an SIMP with the same name
   * A conditional E1 python expression for a B1 bloc with content C1 following a E2 expression for a B2 bloc with content C2 including partially or totally C1
   * ....
 
 
		    
Understanding the XSD mapping for included catalogs
___________________________________________________

Eficas offers the possibility to include one catalog from an other. There will be a main catalog from which the *JdC* keyword is defined and non-main catalogs from which there is no *JdC* keyword. A catalog may be included mutiple times in different catalogs. Whatever the catalog is (main/non-main), it is mandatory to declare :
 * from which the current catalog may be included using the *importedBy* keyword
 * the code name for which the data model is implemented by the current catalog. This is done thanks to the *code* keyword in the *JdC* of the main catalog and thanks to the *implement* keyword non-main catalog. 

Here is an exemple with three levels of catalogs.
   
First, the main common catalog :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.py
    :language: python

The *JdC* definition declares the main property of this catalog.


The given values in the *importedBy* keyword declare middle level/domain specific catalogs that may import this catalog.
			   
For each catalog declared in the *importedBy* keyword  **one global xsd type and one global element declaration** are produced :
	      
.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="T_MDCommun_Abstract"
   :end-at:   name="T_MDCommun_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="MDCommun_Abstract"
   :end-at:   name="MDCommun_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="T_CFDCommun_Abstract"
   :end-at:   name="T_CFDCommun_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="CFDCommun_Abstract"
   :end-at:   name="CFDCommun_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="T_DomainSpecific_Abstract"
   :end-at:   name="T_DomainSpecific_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="DomainSpecific_Abstract"
   :end-at:   name="DomainSpecific_Abstract"

The **abstract="true"** attribute implies that the xsd type have be be derivated in subsequent catalogs to be concretly defined.
		
The abstract complex type says nothing about what will be the concrete type.

.. note:: If *importedBy* keyword is not defined, there will be no generation of xsd abstract types.
	  
The root xsd is element type is :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_modeleCommun.xsd
   :language: xml
   :start-at: name="T_modeleCommun"
   :end-at:   /xs:complexType

.. note:: The three *importedBy* catalogs appear as optional **element ref**. This give the possibility to complete the main root catalog with elements coming from subsequent catalogs knowing nothing about them.

Second, the intermediate/domain specific catalog :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This catalog finality is to gather common informations from a class of code. For example, it could be a "domain specific catalog".

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.py
    :language: python

* Since a catalog is a python script, it is possible to define an *autonome* variable to easily switch between a main/non-main catalog.
* A main catalog must declare a *JdC = JDC_CATA* definition as explained in :ref:`Defining-steps-in-a-catalog` (in our example, if *autonome* is True).
* In this example, the *importedBy* values declare the specific/final catalogs 'MD1', 'MD2' and 'MDSpecific' that may use this catalog.
* The *implement* keyword declares the abstract typename it implements and from which catalog. In this example, it implements the **T_MDCommun_Abstract** type from the *modeleCommun* catalog.
	     
For each catalog declared in the *importedBy* keyword we get global xsd types and global element declaration production (as for the upper level before) :
	      
	      
.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="T_MD1_Abstract"
   :end-at:   name="T_MD1_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="MD1_Abstract"
   :end-at:   name="MD1_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="T_MD2_Abstract"
   :end-at:   name="T_MD2_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="MD2_Abstract"
   :end-at:   name="MD2_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="T_MDSpecific_Abstract"
   :end-at:   name="T_MDSpecific_Abstract"

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="MDSpecific_Abstract"
   :end-at:   name="MDSpecific_Abstract"

As in the main catalog, the **abstract="true"** attribute implies that the xsd type must be derivated in subsequent catalogs to be concretly defined.
The abstract complex type still says nothing about what will be the concrete type.			

The root xsd element type is :
	     
.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MDCommun.xsd
   :language: xml
   :start-at: name="T_MDCommun"
   :end-at:   /xs:complexType

.. note:: Notice the presence of our three *importedBy* catalogs that appear as optional **element ref**. This give the possibility to complete the intermediate root catalog with elements coming from subsequent catalogs. Since the root main common catalog hosts itself intermediate elements, we have a sort of transitivity which allows to produce a unique xsd file combining different levels of description.   		

Third, the final/specific catalog :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In our three level exemple, this level is the final/fully specialized catalog.


Nobody includes it since *importedBy* is empty.

This catalog finality is to describe all the informations that are not in the scope of the common model or domain specific codes but are specfic to a code.
Many code specific catalogs may use the same intermediate catalog or even directly the common catalog.

.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MD1.py
    :language: python

* The *importedBy* keyword is empty. It could be absent only in standalone catalogs. In this example, if the *importedBy* keyword is omitted, since the catalog imports (in the python way) the intermediate one, *importedBy* keyword would have the value defined in the intermediate catalog. 
* The *implement* keyword still declares the abstract typename it implements and from which catalog. In this example, it implements the **T_MD1_Abstract** type from the *MDCommun* catalog.
	     
Since the  *importedBy* keyword is empty, there is no abstract type production.
	      
.. literalinclude:: ../Tests/MappingAccasXsd/MultipleCata/cata_MD1.xsd
   :language: xml
   :start-at: name="T_MD1"
   :end-at:   /xs:complexType

Understanding the XSD mapping for RULES
_______________________________________

.. todo:: Not implemented yet.
