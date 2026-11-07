
.. include:: ../../rst_prolog.rst

Command package
****************

Description
============
The **package** command creates a SALOME archive (usually a compressed Tar_ file .tgz).
This tar file is used later to install SALOME on other remote computer.

Depending on the selected options, the archive includes sources and binaries
of SALOME products and prerequisites.

Usually utility *sat* is included in the archive.

.. note::
  By default the package includes the sources of prerequisites and products.
  To select a subset, use the *--without_property* or *--with_vcs* options.
   

Usage
=====
* Create a package for a product (example as *SALOME-master*): ::

    sat package SALOME-master
    
  This command will create an archive named ``SALOME-master.tar.gz`` 
  in the working directory (``USER.workDir``).
  If the archive already exists, do nothing.


* Create a package with a specific name: ::

    sat package SALOME-master --name YourSpecificName

.. note::
    By default, the archive is created in the working directory of the user (``USER.workDir``).
    
    If the option *--name* is used with a path (relative or absolute) it will be used.
    
    If the option *--name* is not used and binaries (prerequisites and products) 
    are included in the package, the OS_ architecture
    will be appended to the name (example: ``SALOME-master-UB24.04.tar.gz``).
    
    Examples: ::
    
        # Creates SALOME-master.tgz in $USER.workDir
        sat package SALOME-master
        
        # Creates SALOME-master_<arch>.tar.gz in $USER.workDir
        sat package SALOME-master --binaries
        
        # Creates MySpecificName.tar.gz in $USER.workDir
        sat package SALOME-master --name MySpecificName
    
    
* Force the creation of the archive (if it already exists): ::

    sat package SALOME-master --force


* Include the binaries in the archive (products and prerequisites): ::

    sat package SALOME-master --binaries
    
  This command will create an archive named ``SALOME-master _<arch>.tar.gz`` 
  where <arch> is the OS architecture of the machine.


* Create a binary archive with ``extra.env.d`` subdirectory which implements each product environment: ::

    sat package SALOME-master --binaries --with-extra.env.d

    
* Do not delete Version Control System (VCS_) information from the configuration files of the embedded sat: ::

    sat package SALOME-master --with_vcs

  The version control systems known by this option are CVS_, SVN_ and Git_.

* Create binary archives for each product: ::

    # Create binary product archives for all products
    sat package SALOME-master --bin_products

    # Create binary product archives only for VCS products
    sat package SALOME-master --bin_products --with_vcs

Some useful configuration paths
=================================

No specific configuration.
