.. _gui_create_yacs_aster:

A schema YACS for *Code_Aster*
##############################
.. index:: single: YACS
.. index:: single: Code_Aster

If the schema implies a coupling between *Code_Aster* and HOMARD, some comments are included here.

Preparations
************
The directory for the computation
=================================
The first phase consists in creating a directory which will gather the files of the calculation and the files of the successive meshes.

Commands
========
The commands of the calculation are to be defined as for any calculation. The only point is about the test value for the convergence.

The test value
--------------
To get back the test value ``V_TEST``, the script fetches in the file ``resu`` a line such as:
::

    V_TEST    0.02071983

For that purpose, the best way consists in placing the test value in an entitled table ``V_TEST``, for example after an extraction from a result:

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 53-59

Then print this table for the two parameters ``INTITULE`` and component:

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 63-64

To drive the adaptation
-----------------------
If the adaptation is driven by a field, it will be necessary to write this field in the exit MED file. It can be an error indicator (CALC_ERREUR command) or another field.

For example :

.. literalinclude:: ../files/yacs_aster_01.comm
   :language: python
   :lines: 68-78

The script
==========
The script for running *Code_Aster* to supply in the schema YACS is to be downloaded here: :download:`ScriptAster<../files/yacs_script.py>`. This file can be moved anywhere.

How to do ?
***********
A first calculation
===================
As soon as the commands are correct, a first calculation has to be done. That gives the opportunity to choose the parameters: *Code_Aster* version, calculation server, interactive/batch, and so on. These parameters will be used for the successive computations. Launching *Code_Aster* gathers these informations into a file ``export``. This file must be renamed as ``calcul.ref.export`` in the directory for the computation.

Creation of the schema
======================
When the computation is over, the following steps must be done:

- to check that the result MED file was created and that the ligne with the test value is written down into the result file ``resu``;
- to activate the module HOMARD in SALOME;
- to create a case from the initial mesh;
- to create an iteration based on the selected field;
- possibly to calculate this iteration to check choices, but it is not compulsory;
- to create the schema based on this case.

To launch the schema
====================
The schema is written in the file ``schema.xml`` in the directory connected to the case which is the support. This file can be moved with no problem at all. The default parameters of control of the loop of the alternation (calculation/adaptation) can be modified.

The module YACS is activated, the schema is imported and it is launched.



