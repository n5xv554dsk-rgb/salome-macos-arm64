# Copyright (C) 2009-2026  EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

###########################################################
#             Types definitions                           #
###########################################################
corbaTypes = {"double":"CORBA::Double", "long":"CORBA::Long",
              "string":"const char*", "dblevec":"const %s::dblevec&",
              "stringvec":"const %s::stringvec&", "intvec":"const %s::intvec&",
              "file":None, "boolean":"CORBA::Boolean", "void":"void"
             }

corbaOutTypes = {"double":"CORBA::Double&", "long":"CORBA::Long&",
                 "string":"CORBA::String_out", "dblevec":"%s::dblevec_out",
                 "stringvec":"%s::stringvec_out", "intvec":"%s::intvec_out",
                 "file":None, "boolean":"CORBA::Boolean_out", "void":None
                }
moduleTypes = {"double":"", "long":"", "string":"", "dblevec":"", "stringvec":"", "intvec":"", "file":"", "pyobj":"", "boolean":"", "void":"" }

idlTypes = {"double":"double", "long":"long", "string":"string", "dblevec":"dblevec", "stringvec":"stringvec", "intvec":"intvec", 
            "file":"", "boolean":"boolean", "void":"void" }

corbaRtnTypes = {"double":"CORBA::Double", "long":"CORBA::Long",
                 "string":"char*", "dblevec":"%s::dblevec*",
                 "stringvec":"%s::stringvec*", "intvec":"%s::intvec*",
                 "file":None, "boolean":"CORBA::Boolean", "void":"void"
                }



def corba_in_type(typ, module):
  if corbaTypes[typ].count("%s")>0:
    return corbaTypes[typ] % (module+"_ORB")
  else:
    return corbaTypes[typ]

def corba_out_type(typ, module):
  if corbaOutTypes[typ].count("%s")>0:
    return corbaOutTypes[typ] % (module+"_ORB")
  else:
    return corbaOutTypes[typ]

def corba_rtn_type(typ, module):
  if corbaRtnTypes[typ].count("%s")>0:
    return corbaRtnTypes[typ] % (module+"_ORB")
  else:
    return corbaRtnTypes[typ]

ValidTypes = list(corbaTypes.keys())
PyValidTypes = ValidTypes+["pyobj"]

def add_type(typename, corbaType=None, corbaOutType=None, module="", idltype=None, corbaRtnType=None):
  """ add a data type YACS from other module than KERNEL to the list of available types

       :param typename: YACS data type name
       :type typename: string
       :param corbaType: representation for C++ CORBA in parameter
       :type corbaType: string
       :param corbaOutType: representation for C++ CORBA out parameter
       :type corbaOutType: string
       :param module: name of the module that defines the data type (GEOM for GEOM_Object)
       :type module: string
       :param idltype: representation for CORBA idl
       :type idltype: string
       :param corbaRtnType: representation for C++ CORBA return parameter
       :type corbaRtnType: string
  """
  corbaTypes[typename] = corbaType or "const "+typename.replace("/","::")+"&"
  corbaOutTypes[typename] = corbaOutType or typename.replace("/","::")+"_out"
  corbaRtnTypes[typename] = corbaRtnType or typename.replace("/","::")+"*"
  moduleTypes[typename] = module
  idlTypes[typename] = idltype or typename.replace("/","::")
  ValidTypes.append(typename)
  PyValidTypes.append(typename)

calciumTypes = {"CALCIUM_double":"CALCIUM_double",
                "CALCIUM_integer":"CALCIUM_integer",
                "CALCIUM_real":"CALCIUM_real",
                "CALCIUM_string":"CALCIUM_string",
                "CALCIUM_complex":"CALCIUM_complex",
                "CALCIUM_logical":"CALCIUM_logical",
                "CALCIUM_long":"CALCIUM_long",
               }

DatastreamParallelTypes = {"Param_Double_Port":"Param_Double_Port"}

ValidImpl = ("CPP", "PY", "F77", "ASTER", "PACO")
ValidImplTypes = ("sequential", "parallel")
ValidStreamTypes = list(calciumTypes.keys())
ValidParallelStreamTypes = list(DatastreamParallelTypes.keys())
ValidDependencies = ("I", "T")

#Add KERNEL YACS types : YACS name, c++ corba arg in, c++ corba arg out,defining module, repr corba idl, c++ corba return
add_type("dataref", "const Engines::dataref&", "Engines::dataref_out", "", "dataref","Engines::dataref*")
add_type("SALOME_TYPES/Parameter")
add_type("SALOME_TYPES/ParameterList", "const SALOME_TYPES::ParameterList&", "SALOME_TYPES::ParameterList_out", "", "SALOME_TYPES::ParameterList","SALOME_TYPES::ParameterList*")
add_type("SALOME_TYPES/VarList", "const SALOME_TYPES::VarList&", "SALOME_TYPES::VarList_out", "", "SALOME_TYPES::VarList","SALOME_TYPES::VarList*")
add_type("SALOME_TYPES/Variable", "const SALOME_TYPES::Variable&", "SALOME_TYPES::Variable_out", "", "SALOME_TYPES::Variable","SALOME_TYPES::Variable*")
add_type("SALOME_TYPES/VariableSequence", "const SALOME_TYPES::VariableSequence&", "SALOME_TYPES::VariableSequence_out", "", "SALOME_TYPES::VariableSequence","SALOME_TYPES::VariableSequence*")
add_type("SALOME_TYPES/StateSequence", "const SALOME_TYPES::StateSequence&", "SALOME_TYPES::StateSequence_out", "", "SALOME_TYPES::StateSequence","SALOME_TYPES::StateSequence*")
add_type("SALOME_TYPES/TimeSequence", "const SALOME_TYPES::TimeSequence&", "SALOME_TYPES::TimeSequence_out", "", "SALOME_TYPES::TimeSequence","SALOME_TYPES::TimeSequence*")
add_type("SALOME_TYPES/ParametricInput", "const SALOME_TYPES::ParametricInput&", "SALOME_TYPES::ParametricInput_out", "", "SALOME_TYPES::ParametricInput","SALOME_TYPES::ParametricInput*")
add_type("SALOME_TYPES/ParametricOutput", "const SALOME_TYPES::ParametricOutput&", "SALOME_TYPES::ParametricOutput_out", "", "SALOME_TYPES::ParametricOutput","SALOME_TYPES::ParametricOutput*")

#Add GEOM YACS types
add_type("GEOM_Object", "GEOM::GEOM_Object_ptr", "GEOM::GEOM_Object_out", "GEOM", "GEOM::GEOM_Object","GEOM::GEOM_Object_ptr")

#Add SMESH YACS types
add_type("SMESH_Mesh", "SMESH::SMESH_Mesh_ptr", "SMESH::SMESH_Mesh_out", "SMESH", "SMESH::SMESH_Mesh","SMESH::SMESH_Mesh_ptr")
add_type("SMESH_Hypothesis", "SMESH::SMESH_Hypothesis_ptr", "SMESH::SMESH_Hypothesis_out", "SMESH", "SMESH::SMESH_Hypothesis", "SMESH::SMESH_Hypothesis_ptr")

#Add MED YACS types
add_type("SALOME_MED/MED", "SALOME_MED::MED_ptr", "SALOME_MED::MED_out", "MED", "SALOME_MED::MED", "SALOME_MED::MED_ptr")
add_type("SALOME_MED/MESH", "SALOME_MED::MESH_ptr", "SALOME_MED::MESH_out", "MED", "SALOME_MED::MESH", "SALOME_MED::MESH_ptr")
add_type("SALOME_MED/SUPPORT", "SALOME_MED::SUPPORT_ptr", "SALOME_MED::SUPPORT_out", "MED", "SALOME_MED::SUPPORT", "SALOME_MED::SUPPORT_ptr")
add_type("SALOME_MED/FIELD", "SALOME_MED::FIELD_ptr", "SALOME_MED::FIELD_out", "MED", "SALOME_MED::FIELD", "SALOME_MED::FIELD_ptr")
add_type("SALOME_MED/FIELDDOUBLE", "SALOME_MED::FIELDDOUBLE_ptr", "SALOME_MED::FIELDDOUBLE_out", "MED", "SALOME_MED::FIELDDOUBLE", "SALOME_MED::FIELDDOUBLE_ptr")
add_type("SALOME_MED/FIELDINT", "SALOME_MED::FIELDINT_ptr", "SALOME_MED::FIELDINT_out", "MED", "SALOME_MED::FIELDINT", "SALOME_MED::FIELDINT_ptr")
add_type("SALOME/Matrix", "SALOME::Matrix_ptr", "SALOME::Matrix_out", "MED", "SALOME::Matrix", "SALOME::Matrix_ptr")
add_type("SALOME_MED/MEDCouplingFieldDoubleCorbaInterface", "SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr", "SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_out", "MED", "SALOME_MED::MEDCouplingFieldDoubleCorbaInterface", "SALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr")
add_type("SALOME_MED/MPIMEDCouplingFieldDoubleCorbaInterface", "SALOME_MED::MPIMEDCouplingFieldDoubleCorbaInterface_ptr", "SALOME_MED::MPIMEDCouplingFieldDoubleCorbaInterface_out", "MED", "SALOME_MED::MPIMEDCouplingFieldDoubleCorbaInterface", "SALOME_MED::MPIMEDCouplingFieldDoubleCorbaInterface_ptr")
add_type("SALOME_MED/MEDCouplingUMeshCorbaInterface", "SALOME_MED::MEDCouplingUMeshCorbaInterface_ptr", "SALOME_MED::MEDCouplingUMeshCorbaInterface_out", "MED", "SALOME_MED::MEDCouplingUMeshCorbaInterface", "SALOME_MED::MEDCouplingUMeshCorbaInterface_ptr")
add_type("SALOME_MED/DataArrayDoubleCorbaInterface", "SALOME_MED::DataArrayDoubleCorbaInterface_ptr", "SALOME_MED::DataArrayDoubleCorbaInterface_out", "MED", "SALOME_MED::DataArrayDoubleCorbaInterface", "SALOME_MED::DataArrayDoubleCorbaInterface_ptr")
