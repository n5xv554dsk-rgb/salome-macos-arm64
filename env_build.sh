#!/bin/zsh
export SALOME_BASE="${0:A:h}"
export CMAKE_POLICY_VERSION_MINIMUM=3.5
export SALOME_USE_64BIT_IDS=1

export PYTHON_VERSION=3.15
export PYTHON_ROOT_DIR=/opt/homebrew/opt/python@3.15/Frameworks/Python.framework/Versions/3.15
export PYTHONBIN=${PYTHON_ROOT_DIR}/bin/python3.15

export PATH="${PYTHON_ROOT_DIR}/bin:/opt/homebrew/opt/qt@5/bin:/opt/homebrew/opt/libxml2/bin:/opt/homebrew/opt/swig/bin:/opt/homebrew/opt/omniorb/bin:${SALOME_BASE}/prereq/sip/bin:/opt/homebrew/opt/pyqt@5/bin:/opt/homebrew/opt/doxygen/bin:/opt/homebrew/opt/graphviz/bin:${SALOME_BASE}/prereq/hdf5/bin:${SALOME_BASE}/prereq/medfile/bin:${SALOME_BASE}/prereq/paraview/bin:${SALOME_BASE}/prereq/gmsh/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export CONFIGURATION_ROOT_DIR=${SALOME_BASE}/sources/CONFIGURATION
export BOOST_ROOT_DIR=/opt/homebrew/opt/boost
export CAS_ROOT_DIR=/opt/homebrew/opt/opencascade
export CASROOT=/opt/homebrew/opt/opencascade
export CSF_ShadersDirectory=/opt/homebrew/opt/opencascade/share/opencascade/resources/Shaders
export CSF_UnitsLexicon=/opt/homebrew/opt/opencascade/share/opencascade/resources/UnitsAPI/Lexi_Expr.dat
export CSF_UnitsDefinition=/opt/homebrew/opt/opencascade/share/opencascade/resources/UnitsAPI/Units.dat
export CSF_SHMessage=/opt/homebrew/opt/opencascade/share/opencascade/resources/SHMessage
export CSF_XSMessage=/opt/homebrew/opt/opencascade/share/opencascade/resources/XSMessage
export FREETYPE_ROOT_DIR=/opt/homebrew/opt/freetype
export FREEIMAGE_ROOT_DIR=/opt/homebrew/opt/freeimage
export HDF5_ROOT_DIR=${SALOME_BASE}/prereq/hdf5
export MEDFILE_ROOT_DIR=${SALOME_BASE}/prereq/medfile
export OMNIORB_ROOT_DIR=/opt/homebrew/opt/omniorb
export OMNIORBPY_ROOT_DIR=/opt/homebrew/opt/omniorb
export QT5_ROOT_DIR=/opt/homebrew/opt/qt@5
export Qt5_DIR=/opt/homebrew/opt/qt@5/lib/cmake/Qt5
export QWT_ROOT_DIR=/opt/homebrew/opt/qwt-qt5
export PYQT5_ROOT_DIR=/opt/homebrew/opt/pyqt@5
export SIP_ROOT_DIR=${SALOME_BASE}/prereq/sip
export SWIG_ROOT_DIR=/opt/homebrew/opt/swig
export DOXYGEN_ROOT_DIR=/opt/homebrew/opt/doxygen
export CPPUNIT_ROOT_DIR=/opt/homebrew/opt/cppunit
export LIBXML2_ROOT_DIR=/opt/homebrew/opt/libxml2
export GRAPHVIZ_ROOT_DIR=/opt/homebrew/opt/graphviz
export EIGEN_ROOT_DIR=/opt/homebrew/opt/eigen
export TBB_ROOT_DIR=/opt/homebrew/opt/tbb
export CGNS_ROOT_DIR=/opt/homebrew/opt/cgns
export METIS_ROOT_DIR=/opt/homebrew/opt/metis
export SCOTCH_ROOT_DIR=/opt/homebrew/opt/scotch
export PTSCOTCH_ROOT_DIR=/opt/homebrew/opt/scotch
export GMSH_ROOT_DIR=${SALOME_BASE}/prereq/gmsh
export NLOPT_ROOT_DIR=/opt/homebrew/opt/nlopt
export PETSC_ROOT_DIR=/opt/homebrew/opt/petsc
export PLANEGCS_ROOT_DIR=${SALOME_BASE}/prereq/planegcs
export NETGEN_ROOT_DIR=${SALOME_BASE}/prereq/netgen
export PARAVIEW_ROOT_DIR=${SALOME_BASE}/prereq/paraview
export VTK_ROOT_DIR=${SALOME_BASE}/prereq/paraview
export NUMPY_ROOT_DIR=/opt/homebrew/opt/numpy
export SCIPY_ROOT_DIR=/opt/homebrew/opt/scipy
export SPHINX_ROOT_DIR=${PYTHON_ROOT_DIR}
export CYTHON_ROOT_DIR=${PYTHON_ROOT_DIR}
export PSUTIL_ROOT_DIR=${PYTHON_ROOT_DIR}

# SALOME Module Root Dirs
for _salome_mod in SALOMEBOOTSTRAP LIBBATCH KERNEL MEDCOUPLING GUI CommonGeomLib GEOM SHAPER SHAPERSTUDY SMESH FIELDS NETGENPLUGIN GMSHPLUGIN MMGPLUGIN MESHBOOLEANPLUGIN BLSURFPLUGIN GHS3DPLUGIN HYBRIDPLUGIN HexoticPLUGIN HEXABLOCK HEXABLOCKPLUGIN HOMARD PARAVIS PARAVISADDONS JOBMANAGER YACS YACSGEN PY2CPP YDEFX PMML SOLVERLAB EFICAS_TOOLS EFICAS ADAO ADAO_INTERFACE COMPONENT CALCULATOR PYCALCULATOR HELLO PYHELLO SAMPLES DOCUMENTATION SALOME TopIIVolMesh MEDREADER; do
  export ${_salome_mod}_ROOT_DIR=${SALOME_BASE}/install/${_salome_mod}
  if [ -d "${SALOME_BASE}/install/${_salome_mod}/bin/salome" ]; then
    export PATH="${SALOME_BASE}/install/${_salome_mod}/bin/salome:${PATH}"
  fi
  if [ -d "${SALOME_BASE}/install/${_salome_mod}/bin" ]; then
    export PATH="${SALOME_BASE}/install/${_salome_mod}/bin:${PATH}"
  fi
done

export SALOME_APPLICATION_DIR=${SALOME_BASE}/install/SALOMEBOOTSTRAP
export DYLD_LIBRARY_PATH="${SALOME_BASE}/install/SALOMEBOOTSTRAP/__RUN_SALOME__/lib/salome:${SALOME_BASE}/prereq/hdf5/lib:${SALOME_BASE}/prereq/medfile/lib:${SALOME_BASE}/prereq/netgen/lib:${SALOME_BASE}/prereq/planegcs/lib:${SALOME_BASE}/prereq/paraview/lib:${SALOME_BASE}/prereq/gmsh/lib:${PYTHON_ROOT_DIR}/lib:/opt/homebrew/opt/qt@5/lib:/opt/homebrew/opt/qwt-qt5/lib:/opt/homebrew/opt/opencascade/lib:/opt/homebrew/opt/omniorb/lib:/opt/homebrew/opt/boost/lib:/opt/homebrew/opt/cppunit/lib:/opt/homebrew/opt/libxml2/lib:/opt/homebrew/opt/graphviz/lib:/opt/homebrew/opt/tbb/lib:/opt/homebrew/opt/cgns/lib:/opt/homebrew/opt/metis/lib:/opt/homebrew/opt/scotch/lib:/opt/homebrew/opt/gmsh/lib:/opt/homebrew/opt/nlopt/lib:/opt/homebrew/opt/petsc/lib:/opt/homebrew/opt/slepc/lib:/opt/homebrew/opt/open-mpi/lib:/opt/homebrew/opt/libomp/lib:/opt/homebrew/opt/gcc/lib/gcc/current"

for _salome_mod in SALOMEBOOTSTRAP LIBBATCH KERNEL MEDCOUPLING GUI CommonGeomLib GEOM SHAPER SHAPERSTUDY SMESH FIELDS NETGENPLUGIN GMSHPLUGIN MMGPLUGIN MESHBOOLEANPLUGIN GHS3DPLUGIN HYBRIDPLUGIN HexoticPLUGIN HEXABLOCK HEXABLOCKPLUGIN HOMARD PARAVIS PARAVISADDONS JOBMANAGER YACS PY2CPP YDEFX PMML SOLVERLAB ADAO ADAO_INTERFACE COMPONENT CALCULATOR PYCALCULATOR HELLO PYHELLO SAMPLES TopIIVolMesh MEDREADER; do
  export DYLD_LIBRARY_PATH="${SALOME_BASE}/install/${_salome_mod}/lib/salome:${SALOME_BASE}/install/${_salome_mod}/lib:${DYLD_LIBRARY_PATH}"
done

export PYTHONPATH="${SALOME_BASE}/install/SALOMEBOOTSTRAP/__SALOME_BOOTSTRAP__:${SALOME_BASE}/install/SALOMEBOOTSTRAP/__RUN_SALOME__/lib/python${PYTHON_VERSION}/site-packages:${SALOME_BASE}/install/SALOMEBOOTSTRAP/__RUN_SALOME__/lib/salome:${SALOME_BASE}/prereq/sip/lib/python${PYTHON_VERSION}/site-packages:${SALOME_BASE}/prereq/medfile/lib/python${PYTHON_VERSION}/site-packages:${SALOME_BASE}/prereq/paraview/lib/python${PYTHON_VERSION}/site-packages:/opt/homebrew/opt/pyqt@5/lib/python${PYTHON_VERSION}/site-packages:/opt/homebrew/opt/omniorb/lib/python${PYTHON_VERSION}/site-packages:/opt/homebrew/opt/numpy/lib/python${PYTHON_VERSION}/site-packages:/opt/homebrew/opt/scipy/lib/python${PYTHON_VERSION}/site-packages:/opt/homebrew/lib/python${PYTHON_VERSION}/site-packages"
for _salome_mod in SALOMEBOOTSTRAP LIBBATCH KERNEL MEDCOUPLING GUI CommonGeomLib GEOM SHAPER SHAPERSTUDY SMESH FIELDS NETGENPLUGIN GMSHPLUGIN MMGPLUGIN MESHBOOLEANPLUGIN GHS3DPLUGIN HYBRIDPLUGIN HexoticPLUGIN HEXABLOCK HEXABLOCKPLUGIN HOMARD PARAVIS PARAVISADDONS JOBMANAGER YACS YACSGEN PY2CPP YDEFX PMML SOLVERLAB EFICAS_TOOLS EFICAS ADAO ADAO_INTERFACE COMPONENT CALCULATOR PYCALCULATOR HELLO PYHELLO SAMPLES TopIIVolMesh MEDREADER SALOME; do
  export PYTHONPATH="${SALOME_BASE}/install/${_salome_mod}/lib/python${PYTHON_VERSION}/site-packages/salome:${SALOME_BASE}/install/${_salome_mod}/lib/salome:${SALOME_BASE}/install/${_salome_mod}/bin/salome:${PYTHONPATH}"
done
for _salome_mod in SALOMEBOOTSTRAP LIBBATCH KERNEL MEDCOUPLING GUI CommonGeomLib GEOM SHAPER SHAPERSTUDY SMESH FIELDS NETGENPLUGIN GMSHPLUGIN MMGPLUGIN MESHBOOLEANPLUGIN GHS3DPLUGIN HYBRIDPLUGIN HexoticPLUGIN HEXABLOCK HEXABLOCKPLUGIN HOMARD PARAVIS PARAVISADDONS JOBMANAGER YACS YACSGEN PY2CPP YDEFX PMML SOLVERLAB EFICAS_TOOLS EFICAS ADAO ADAO_INTERFACE COMPONENT CALCULATOR PYCALCULATOR HELLO PYHELLO SAMPLES TopIIVolMesh MEDREADER SALOME; do
  export PYTHONPATH="${SALOME_BASE}/install/${_salome_mod}/lib/python${PYTHON_VERSION}/site-packages:${PYTHONPATH}"
done

export PV_PLUGIN_PATH="${SALOME_BASE}/install/PARAVIS/lib/paraview:${SALOME_BASE}/install/PARAVISADDONS/lib/paraview:${SALOME_BASE}/install/MEDREADER/lib/paraview"
export SalomeAppConfig="${SALOME_BASE}/install/SALOME/share/salome/resources/salome:${SALOME_BASE}/install/GUI/share/salome/resources/gui:${SALOME_BASE}/install/SHAPER/share/salome/resources/shaper:${SALOME_BASE}/install/SHAPERSTUDY/share/salome/resources/shaperstudy:${SALOME_BASE}/install/GEOM/share/salome/resources/geom:${SALOME_BASE}/install/SMESH/share/salome/resources/smesh:${SALOME_BASE}/install/PARAVIS/share/salome/resources/paravis:${SALOME_BASE}/install/FIELDS/share/salome/resources/fields:${SALOME_BASE}/install/YACS/share/salome/resources/yacs:${SALOME_BASE}/install/JOBMANAGER/share/salome/resources/jobmanager:${SALOME_BASE}/install/HOMARD/share/salome/resources/homard:${SALOME_BASE}/install/HEXABLOCK/share/salome/resources/hexablock:${SALOME_BASE}/install/HEXABLOCKPLUGIN/share/salome/resources/hexablockplugin:${SALOME_BASE}/install/NETGENPLUGIN/share/salome/resources/netgenplugin:${SALOME_BASE}/install/GMSHPLUGIN/share/salome/resources/gmshplugin:${SALOME_BASE}/install/GHS3DPLUGIN/share/salome/resources/ghs3dplugin:${SALOME_BASE}/install/HYBRIDPLUGIN/share/salome/resources/hybridplugin:${SALOME_BASE}/install/HexoticPLUGIN/share/salome/resources/hexoticplugin:${SALOME_BASE}/install/SOLVERLAB/share/salome/resources/solverlab:${SALOME_BASE}/install/EFICAS/share/salome/resources/eficas:${SALOME_BASE}/install/ADAO/share/salome/resources/adao:${SALOME_BASE}/install/COMPONENT/share/salome/resources/component:${SALOME_BASE}/install/CALCULATOR/share/salome/resources/calculator:${SALOME_BASE}/install/PYCALCULATOR/share/salome/resources/pycalculator:${SALOME_BASE}/install/HELLO/share/salome/resources/hello:${SALOME_BASE}/install/PYHELLO/share/salome/resources/pyhello"
export SHAPERConfig="${SALOME_BASE}/install/SHAPER/share/salome/resources/shaper"
export SHAPER_ROOT_DIR="${SALOME_BASE}/install/SHAPER"
export SHAPER_PluginList=""
export GEOM_PluginsList="BREPPlugin:STEPPlugin:IGESPlugin:STLPlugin:XAOPlugin:VTKPlugin:AdvancedGEOM"
export CSF_ShHealingDefaults="${SALOME_BASE}/install/GEOM/share/salome/resources/geom"
export PARALLEL_VISU="1"
export SMESH_MeshersList="StdMeshers:NETGENPlugin:GMSHPlugin:GHS3DPlugin:HexoticPLUGIN:HYBRIDPlugin:HEXABLOCKPlugin"
export HOMARD_REP_EXE="${SALOME_BASE}/install/HOMARD/bin/salome"
export HOMARD_EXE="homard"
export EFICAS_ROOT="${SALOME_BASE}/install/EFICAS"
export EFICAS_TOOLS_ROOT="${SALOME_BASE}/install/EFICAS_TOOLS"
export ADAO_ENGINE_ROOT_DIR="${SALOME_BASE}/install/ADAO"
export CURRENT_SOFTWARE_INSTALL_DIR="${SALOME_BASE}/install/ADAO"
export CoreFlows_INSTALL="${SALOME_BASE}/install/SOLVERLAB"
export CoreFlows_ROOT_DIR="${SALOME_BASE}/install/SOLVERLAB"
export CoreFlows_ROOT="${SALOME_BASE}/install/SOLVERLAB"
export COREFLOWS_ROOT_DIR="${SALOME_BASE}/install/SOLVERLAB"
export CoreFlows_PYTHON="ON"
export CoreFlows_DOC="ON"
export CoreFlows_GUI="ON"
export CoreFlows="${SALOME_BASE}/install/SOLVERLAB/bin/CoreFlowsMainExe"
export CoreFlowsGUI="${SALOME_BASE}/install/SOLVERLAB/bin/CoreFlows_Standalone.py"
export SAMPLES_SRC_DIR="${SALOME_BASE}/sources/SAMPLES"
export DATA_DIR="${SALOME_BASE}/sources/SAMPLES"
export MESHBOOLEANGPLUGIN_ROOT_DIR="${SALOME_BASE}/install/MESHBOOLEANPLUGIN"
export PYTHONPATH="${SALOME_BASE}/install/MESHBOOLEANPLUGIN/plugins:${SALOME_BASE}/install/MMGPLUGIN/plugins:${SALOME_BASE}/install/SOLVERLAB:${SALOME_BASE}/install/SOLVERLAB/lib:${SALOME_BASE}/install/SOLVERLAB/bin:${SALOME_BASE}/install/SOLVERLAB/lib/coreflows:${SALOME_BASE}/install/SOLVERLAB/bin/coreflows:${SALOME_BASE}/install/SOLVERLAB/lib/cdmath:${SALOME_BASE}/install/SOLVERLAB/bin/cdmath:${SALOME_BASE}/install/SOLVERLAB/bin/cdmath/postprocessing:${SALOME_BASE}/install/EFICAS_TOOLS:${SALOME_BASE}/install/EFICAS_TOOLS/Accas:${SALOME_BASE}/install/EFICAS_TOOLS/Aide:${SALOME_BASE}/install/EFICAS_TOOLS/convert:${SALOME_BASE}/install/EFICAS_TOOLS/Doc:${SALOME_BASE}/install/EFICAS_TOOLS/Editeur:${SALOME_BASE}/install/EFICAS_TOOLS/Efi2Xsd:${SALOME_BASE}/install/EFICAS_TOOLS/Extensions:${SALOME_BASE}/install/EFICAS_TOOLS/generator:${SALOME_BASE}/install/EFICAS_TOOLS/Ihm:${SALOME_BASE}/install/EFICAS_TOOLS/InterfaceQT:${SALOME_BASE}/install/EFICAS_TOOLS/Noyau:${SALOME_BASE}/install/EFICAS_TOOLS/Telemac:${SALOME_BASE}/install/EFICAS_TOOLS/Traducteur:${SALOME_BASE}/install/EFICAS_TOOLS/UiQT5:${SALOME_BASE}/install/YACSGEN/bin:${SALOME_BASE}/install/PMML/bin:${SALOME_BASE}/install/PARAVISADDONS/bin:${PYTHONPATH}"
