Introduction
============
CMake is a configuration tool generating the build chain (e.g. Makefiles on Linux)
of a software project.
This documentation describes the goals and the good practices to be applied when writing
the CMake files for the configuration of a SALOME module.

This documentation is best browsed with the SALOME KERNEL's sources at hand, in order to be able to 
take a look at code snipets. Most references in this document points to KERNEL sources.

The section marked as ADVANCED need not be read by someone only trying to compile SALOME. Those
sections are intented to the core SALOME developers, to help them understand/fix/improve
the process.

Motivations and overview
========================

CMake must be user-friendly
---------------------------

Every beginner should be able to build SALOME, without any previous knowledge of SALOME. 
With a tool like cmake-gui or ccmake, the user must obtain useful messages to find what is wrong or missing.

The general philosophy is thus to allow a developper to build SALOME with a minimal effort, setting only the 
minimal set of variables (via the command line or the environment). 

Basic usage
-----------
Once the sources have been retrieved (via a clone of the repository or an extraction of the tarball)
one typically:

* creates a dedicated build directory, e.g. KERNEL_BUILD.
* switches to it, and invoke the ccmake (or cmake-gui) command::

    cd KERNEL_BUILD
    ccmake ../KERNEL_SRC

* sets all the xyz_ROOT_DIR to point to the root paths of the package <xyz>.
* sets the installation directory in the variable CMAKE_INSTALL_PREFIX.
* generates the build files (hiting 'g' under ccmake).
* invokes the make command in the usual way::

    make
    make install

* if you see an error complaining that the package was not found, double check that the XYZ_ROOT_DIR variable was correctly set, and delete everything in your build directory before retrying::

    cd KERNEL_BUILD
    rm -rf *
    ccmake ../KERNEL_SRC

If you want to use a specific Python installation to configure and build SALOME, you should ensure that:

* the interpreter is in your path.
* the variables LD_LIBRARY_PATH (PATH under Windows) and PYTHONPATH are properly pointing to the desired Python installation.

Variable reference
------------------

The following list indicates the expected variables for each module. They can be specified on the CMake command line (with the -D flag) or in the environment.

KERNEL module:

* LIBBATCH_ROOT_DIR: LibBatch package - already uses Python, Swig and PThread
* PYTHON_ROOT_DIR: Python package
* PTHREAD_ROOT_DIR: PThread package - typically not need on Unix systems
* SWIG_ROOT_DIR: SWIG package
* LIBXML2_ROOT_DIR: LibXml2 package
* HDF5_ROOT_DIR: HDF5 package - if HDF5 was compiled with MPI support, the corresponding MPI root directory will be exposed automatically (no need to set MPI_ROOT_DIR)
* BOOST_ROOT_DIR: Boost package
* OMNIORB_ROOT_DIR: OmniORB package
* OMNIORBPY_ROOT_DIR: OmniORB Python backend - if not given, OMNIORB_ROOT_DIR will be tried
* MPI_ROOT_DIR: MPI package (see HDF5_ROOT_DIR above)
* CPPUNIT_ROOT_DIR: CppUnit package
* DOXYGEN_ROOT_DIR: Doxygen package
* GRAPHVIZ_ROOT_DIR: Graphviz package
* SPHINX_ROOT_DIR: Sphinx package - requires setuptools and docutils to work properly.
* SETUPTOOLS_ROOT_DIR: Setuptools package. This package is not detected explicitly in the KERNEL, but the path is used to complete the PYTHON path given to Sphinx.
* DOCUTILS_ROOT_DIR: Docutils package. This package is not detected explicitly in the KERNEL, but the path is used to complete the PYTHON path given to Sphinx.

GUI module - on top of some of the KERNEL prerequisites, the following variables are used:

* VTK_ROOT_DIR: VTK package. If not given, PARAVIEW_ROOT_DIR is used to look for a VTK installation inside the ParaView installation
* (optional) PARAVIEW_ROOT_DIR: see above
* CAS_ROOT_DIR: Cascade package
* SIP_ROOT_DIR: SIP package
* QT4_ROOT_DIR: Qt4 package (only some components are loaded)
* PYQT4_ROOT_DIR: PyQt4 package
* QWT_ROOT_DIR: Qwt package
* OPENGL_ROOT_DIR: OpenGL package

FIELDS module - on top of some of the KERNEL and GUI prerequisites, the following variables are used:

* MEDFILE_ROOT_DIR: MEDFile package
* METIS_ROOT_DIR (optional): Metis package
* PARMETIS_ROOT_DIR (optional): ParMetis package
* SCOTCH_ROOT_DIR (optional): Scotch package

PARAVIS module - on top of some of the KERNEL, GUI and FIELDS prerequisites, the following variables are used:

* PARAVIEW_ROOT_DIR: ParaView package
* at present for a proper build of PARAVIS, the env variables LD_LIBRARY_PATH and PYTHONPATH should be set to contain the HDF5 and ParaView libraries. This is required since the configuration process itself uses a Python script in which the environment is not overriden::

    # Paravis compilation needs ParaView (and hence HDF5) in the Python path:
    export PYTHONPATH=$PARAVIEW_ROOT_DIR/lib/paraview-3.98/site-packages:$PARAVIEW_ROOT_DIR/lib/paraview-3.98:$PYTHONPATH
    export LD_LIBRARY_PATH=$PARAVIEW_ROOT_DIR/lib/paraview-3.98:$HDF5_ROOT_DIR/lib:$LD_LIBRARY_PATH



Overview of the logic (advanced)
--------------------------------

Here are the general principles guiding the implementation:

* Only taking into account the first order prerequisites of a module should be required.
  For instance, CASCADE uses Tbb : 

  * CASCADE is a prerequisite of first order (level 1) of GUI,
  * Tbb is a prerequisite of second order (level 2) of GUI,
  * GUI CMake files must reference explicitly CASCADE, but never Tbb. The detection logic of CASCADE should make sure Tbb gets included.

* Being able to use different versions/installations of the same product, in the system, or generated by the user. 
  For instance, using the system python 2.7, or a user-compiled python 2.6.
* The detection of prerequisites is driven by user options. 
  For example MPI is detected only if option SALOME_USE_MPI is ON.
*	Detection of first order prerequisites is based on a <Product>_ROOT_DIR variable or on what has been detected in another   dependency. For example if both HDF5 and MPI are needed by the current module, we try to detect with which MPI installation HDF5 was compiled, and to offer this one as a default choice for the package itself. Other variables (PATH, LD_LIBRARY_PATH, PYTHONPATH) should never be needed at compile time.
* The only exception to the previous point is Python, which is so central to the process that we assume that LD_LIBRARY_PATH and PYTHONPATH are already correctly pointing to the correct Python installation.
* Trying as much as possible to detect potential conflict, and warn the user:

  * if the package was detected at a place different from what was specified in XYZ_ROOT_DIR
  * if there is a conflict between what was explicitly set in XYZ_ROOT_DIR, and what was previously used in a dependency



