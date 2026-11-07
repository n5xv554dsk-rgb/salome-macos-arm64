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

# only the first two characters of the map are actually used to find out in/out caracteristic
cpp2idl_mapping={}
cpp2idl_mapping["int"]="in long"
cpp2idl_mapping["bool"]="in boolean"
cpp2idl_mapping["double"]="in double"
cpp2idl_mapping["float"]="in float"
cpp2idl_mapping["long"]="in long"
cpp2idl_mapping["short"]="in short"
cpp2idl_mapping["unsigned"]="in unsigned long"
cpp2idl_mapping["const char*"]="in string"
cpp2idl_mapping["const std::string&"]="in string"
cpp2idl_mapping["int&"]="out long"
cpp2idl_mapping["bool&"]="out boolean"
cpp2idl_mapping["double&"]="out double"
cpp2idl_mapping["float&"]="out float"
cpp2idl_mapping["long&"]="out long"
cpp2idl_mapping["short&"]="out short"
cpp2idl_mapping["unsigned&"]="out unsigned long"
cpp2idl_mapping["std::string&"]="out string"
cpp2idl_mapping["const MEDMEM::MESH&"]="in SALOME_MED::MESH"
cpp2idl_mapping["const MEDMEM::MESH*"]="in SALOME_MED::MESH"
cpp2idl_mapping["const MEDMEM::SUPPORT&"]="in SALOME_MED::SUPPORT"
cpp2idl_mapping["const MEDMEM::SUPPORT*"]="in SALOME_MED::SUPPORT"
cpp2idl_mapping["const MEDMEM::FIELD<double>*"]="in SALOME_MED::FIELDDOUBLE"
cpp2idl_mapping["const MEDMEM::FIELD<double>&"]="in SALOME_MED::FIELDDOUBLE"
cpp2idl_mapping["MEDMEM::FIELD<double>*&"]="out SALOME_MED::FIELDDOUBLE"
cpp2idl_mapping["const std::vector<double>&"]="in %(module)s::dblevec"
cpp2idl_mapping["const std::vector<std::vector<double> >&"]="in SALOME::Matrix"
cpp2idl_mapping["std::vector<double>*&"]="out %(module)s::dblevec"
cpp2idl_mapping["const MEDMEM::FIELD<int>*"]="in SALOME_MED::FIELDINT"
cpp2idl_mapping["const MEDMEM::FIELD<int>&"]="in SALOME_MED::FIELDINT"
cpp2idl_mapping["MEDMEM::FIELD<int>*&"]="out SALOME_MED::FIELDINT"
cpp2idl_mapping["const std::vector<int>&"]="in %(module)s::intvec"
cpp2idl_mapping["std::vector<int>*&"]="out %(module)s::intvec"
cpp2idl_mapping["const MEDCoupling::MEDCouplingFieldDouble*"]="in SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
cpp2idl_mapping["const MEDCoupling::MEDCouplingFieldDouble&"]="in SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
cpp2idl_mapping["MEDCoupling::MEDCouplingFieldDouble*&"]="out SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
cpp2idl_mapping["const MEDCoupling::MEDCouplingUMesh*"]="in SALOME_MED::MEDCouplingUMeshCorbaInterface"

# ['stringvec', 'string', 'double', 'long', 'dblevec', 'file', 'intvec', 'dataref', 'GEOM_Object', 'SMESH_Mesh', 'SMESH_Hypothesis', 'SALOME_MED/MED', 'SALOME_MED/MESH', 'SALOME_MED/SUPPORT', 'SALOME_MED/FIELD', 'SALOME_MED/FIELDDOUBLE', 'SALOME_MED/FIELDINT']
cpp2yacs_mapping={}
cpp2yacs_mapping["int"]="long"
cpp2yacs_mapping["bool"]="boolean"
cpp2yacs_mapping["double"]="double"
#cpp2yacs_mapping["float"]="in float"
cpp2yacs_mapping["long"]="long"
#cpp2yacs_mapping["short"]="in short"
#cpp2yacs_mapping["unsigned"]="in unsigned long"
cpp2yacs_mapping["const char*"]="string"
cpp2yacs_mapping["const std::string&"]="string"
cpp2yacs_mapping["int&"]="long"
cpp2yacs_mapping["bool&"]="boolean"
cpp2yacs_mapping["double&"]="double"
#cpp2yacs_mapping["float&"]="out float"
cpp2yacs_mapping["long&"]="long"
#cpp2yacs_mapping["short&"]="out short"
#cpp2yacs_mapping["unsigned&"]="out unsigned long"
cpp2yacs_mapping["std::string&"]="string"
cpp2yacs_mapping["const MEDMEM::MESH&"]="SALOME_MED/MESH"
cpp2yacs_mapping["const MEDMEM::MESH*"]="SALOME_MED/MESH"
cpp2yacs_mapping["const MEDMEM::SUPPORT&"]="SALOME_MED/SUPPORT"
cpp2yacs_mapping["const MEDMEM::SUPPORT*"]="SALOME_MED/SUPPORT"
cpp2yacs_mapping["const MEDMEM::FIELD<double>*"]="SALOME_MED/FIELDDOUBLE"
cpp2yacs_mapping["const MEDMEM::FIELD<double>&"]="SALOME_MED/FIELDDOUBLE"
cpp2yacs_mapping["MEDMEM::FIELD<double>*&"]="SALOME_MED/FIELDDOUBLE"

cpp2yacs_mapping["const std::vector<double>&"]="dblevec"

cpp2yacs_mapping["const std::vector<std::vector<double> >&"]="SALOME/Matrix"

cpp2yacs_mapping["std::vector<double>*&"]="dblevec"

cpp2yacs_mapping["const MEDMEM::FIELD<int>*"]="SALOME_MED/FIELDINT"
cpp2yacs_mapping["const MEDMEM::FIELD<int>&"]="SALOME_MED/FIELDINT"
cpp2yacs_mapping["MEDMEM::FIELD<int>*&"]="SALOME_MED/FIELDINT"
cpp2yacs_mapping["const std::vector<int>&"]="intvec"
cpp2yacs_mapping["std::vector<int>*&"]="intvec"

cpp2yacs_mapping["void"]="void"
cpp2yacs_mapping["char*"]="string"
cpp2yacs_mapping["std::string"]="string"
cpp2yacs_mapping["MEDMEM::MESH&"]="SALOME_MED/MESH"
cpp2yacs_mapping["MEDMEM::MESH*"]="SALOME_MED/MESH"
cpp2yacs_mapping["MEDMEM::SUPPORT*"]="SALOME_MED/SUPPORT"
cpp2yacs_mapping["MEDMEM::FIELD<double>*"]="SALOME_MED/FIELDDOUBLE"
cpp2yacs_mapping["MEDMEM::FIELD<double>&"]="SALOME_MED/FIELDDOUBLE"
cpp2yacs_mapping["MEDMEM::FIELD<int>*"]="SALOME_MED/FIELDINT"
cpp2yacs_mapping["MEDMEM::FIELD<int>&"]="SALOME_MED/FIELDINT"

cpp2yacs_mapping["std::vector<double>*"]="dblevec"
cpp2yacs_mapping["std::vector<int>*"]="intvec"

cpp2yacs_mapping["std::vector<std::vector<double> >*"]="SALOME/Matrix"
cpp2yacs_mapping["std::vector<std::string>"]="stringvec"
cpp2yacs_mapping["const MEDCoupling::MEDCouplingFieldDouble*"]="SALOME_MED/MEDCouplingFieldDoubleCorbaInterface"
cpp2yacs_mapping["const MEDCoupling::MEDCouplingFieldDouble&"]="SALOME_MED/MEDCouplingFieldDoubleCorbaInterface"
cpp2yacs_mapping["const MEDCoupling::MEDCouplingUMesh*"]="SALOME_MED/MEDCouplingUMeshCorbaInterface"
cpp2yacs_mapping["MEDCoupling::MEDCouplingFieldDouble*&"]="SALOME_MED/MEDCouplingFieldDoubleCorbaInterface"
cpp2yacs_mapping["MEDCoupling::MEDCouplingUMesh*"]="SALOME_MED/MEDCouplingUMeshCorbaInterface"
cpp2yacs_mapping["MEDCoupling::MEDCouplingFieldDouble*"]="SALOME_MED/MEDCouplingFieldDoubleCorbaInterface"
cpp2yacs_mapping["MEDCoupling::DataArrayDouble*"]="SALOME_MED/DataArrayDoubleCorbaInterface"
# table for c++ code generation : argument's processing
cpp_impl_a={}
cpp_impl_a["int"]="\tint _%(arg)s(%(arg)s);\n"
cpp_impl_a["bool"]="\tbool _%(arg)s(%(arg)s);\n"
cpp_impl_a["double"]="\tdouble _%(arg)s(%(arg)s);\n"
cpp_impl_a["float"]="\tfloat _%(arg)s(%(arg)s);\n"
cpp_impl_a["long"]="\tlong _%(arg)s(%(arg)s);\n"
cpp_impl_a["short"]="\tshort _%(arg)s(%(arg)s);\n"
cpp_impl_a["unsigned"]="\tunsigned _%(arg)s(%(arg)s);\n"
cpp_impl_a["const char*"]="\tconst char* _%(arg)s(%(arg)s);\n"
cpp_impl_a["const std::string&"]="\tconst std::string _%(arg)s(%(arg)s);\n"
cpp_impl_a["int&"]="\tint _%(arg)s;\n"
cpp_impl_a["bool&"]="\tbool _%(arg)s;\n"
cpp_impl_a["double&"]="\tdouble _%(arg)s;\n"
cpp_impl_a["float&"]="\tfloat _%(arg)s;\n"
cpp_impl_a["long&"]="\tlong _%(arg)s;\n"
cpp_impl_a["short&"]="\tshort _%(arg)s;\n"
cpp_impl_a["unsigned&"]="\tunsigned _%(arg)s;\n"
cpp_impl_a["std::string&"]="\tstd::string _%(arg)s;\n"
cpp_impl_a["const MEDMEM::MESH&"]="\tMEDMEM::MESHClient* _%(arg)s = new MEDMEM::MESHClient(%(arg)s);\n\t _%(arg)s->fillCopy();\n" # MESHClient cannot be created on the stack (private constructor), so we create it on the heap and dereference it later (in treatment 4)
cpp_impl_a["const MEDMEM::MESH*"]="\tMEDMEM::MESHClient* _%(arg)s = new MEDMEM::MESHClient(%(arg)s);\n\t _%(arg)s->fillCopy();\n"
cpp_impl_a["const MEDMEM::SUPPORT&"]="\tMEDMEM::SUPPORTClient* _%(arg)s = new MEDMEM::SUPPORTClient(%(arg)s);\n" # SUPPORTClient cannot be created on the stack (protected destructor), so we create it on the heap and dereference it later (in treatment 4)
cpp_impl_a["const MEDMEM::SUPPORT*"]="\tMEDMEM::SUPPORTClient* _%(arg)s = new MEDMEM::SUPPORTClient(%(arg)s);\n"
cpp_impl_a["MEDMEM::FIELD<double>*&"]="\tMEDMEM::FIELD<double>* _%(arg)s;\n"
cpp_impl_a["const MEDMEM::FIELD<double>*"]="\tstd::auto_ptr<MEDMEM::FIELD<double> > _%(arg)s ( new MEDMEM::FIELDClient<double,MEDMEM::FullInterlace>(%(arg)s) );\n"
cpp_impl_a["const MEDMEM::FIELD<double>&"]="\tMEDMEM::FIELDClient<double,MEDMEM::FullInterlace> _%(arg)s(%(arg)s);\n"
cpp_impl_a["const std::vector<double>&"]="\tlong _%(arg)s_size=%(arg)s.length();\n\tconst double *_%(arg)s_value = &%(arg)s[0];\n"\
           "\tstd::vector<double> _%(arg)s(_%(arg)s_value,_%(arg)s_value+_%(arg)s_size);\n"
cpp_impl_a["std::vector<double>*&"]="\tstd::vector<double>* _%(arg)s;\n"
cpp_impl_a["const std::vector<std::vector<double> >&"]="\tMatrixClient _%(arg)s_client;\n\tint _%(arg)s_nbRow;\n\tint _%(arg)s_nbCol;\n"\
           "\tdouble* _%(arg)s_tab = _%(arg)s_client.getValue(%(arg)s,_%(arg)s_nbCol,_%(arg)s_nbRow);\n\tstd::vector<std::vector<double> > _%(arg)s(_%(arg)s_nbRow);\n"\
           "\tfor (int i=0; i!=_%(arg)s_nbRow; ++i)\n\t{\n\t    _%(arg)s[i].resize(_%(arg)s_nbCol);\n"\
           "\t    std::copy(_%(arg)s_tab+_%(arg)s_nbCol*i,_%(arg)s_tab+_%(arg)s_nbCol*(i+1), _%(arg)s[i].begin());\n\t}\n\tdelete [] _%(arg)s_tab;\n"
cpp_impl_a["MEDMEM::FIELD<int>*&"]="\tMEDMEM::FIELD<int>* _%(arg)s;\n"
cpp_impl_a["const MEDMEM::FIELD<int>*"]="\tstd::auto_ptr<MEDMEM::FIELD<int> > _%(arg)s ( new MEDMEM::FIELDClient<int>(%(arg)s) );\n"
cpp_impl_a["const MEDMEM::FIELD<int>&"]="\tMEDMEM::FIELDClient<int> _%(arg)s(%(arg)s);\n"
cpp_impl_a["const std::vector<int>&"]="\tlong _%(arg)s_size=%(arg)s.length();\n"\
	                 "\tstd::vector<int> _%(arg)s(_%(arg)s_size);\n"\
			 "\tfor (int i=0; i!=_%(arg)s_size; ++i)\n\t    _%(arg)s[i]=%(arg)s[i];"
cpp_impl_a["std::vector<int>*&"]="\tstd::vector<int>* _%(arg)s;\n"
cpp_impl_a["const MEDCoupling::MEDCouplingFieldDouble*"]="\tMEDCoupling::MEDCouplingFieldDouble* _%(arg)s=MEDCoupling::MEDCouplingFieldDoubleClient::New(%(arg)s);\n"
cpp_impl_a["const MEDCoupling::MEDCouplingFieldDouble&"]="\tMEDCoupling::MEDCouplingFieldDouble* __%(arg)s=MEDCoupling::MEDCouplingFieldDoubleClient::New(%(arg)s);\n"\
                         "\tMEDCoupling::MEDCouplingFieldDouble& _%(arg)s=*__%(arg)s;\n"
cpp_impl_a["MEDCoupling::MEDCouplingFieldDouble*&"]="\tMEDCoupling::MEDCouplingFieldDouble* _%(arg)s;\n"
cpp_impl_a["const MEDCoupling::MEDCouplingUMesh*"]="\tMEDCoupling::MEDCouplingUMesh* _%(arg)s=MEDCoupling::MEDCouplingUMeshClient::New(%(arg)s);\n"


# table for c++ code generation : returned value processing
cpp_impl_b={}
cpp_impl_b["void"]=""
cpp_impl_b["int"]="\tCORBA::Long _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["bool"]="\tCORBA::Boolean _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["double"]="\tCORBA::Double _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["float"]="\tCORBA::Float _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["long"]="\tCORBA::Long _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["short"]="\tCORBA::Short _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["unsigned"]="\tCORBA::ULong _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["const char*"]="\tchar* _rtn_ior = CORBA::string_dup(_rtn_cpp);\n"
cpp_impl_b["char*"]="\tchar* _rtn_ior(_rtn_cpp);\n"
cpp_impl_b["std::string"]="""\tchar* _rtn_ior=CORBA::string_dup(_rtn_cpp.c_str());\n
\tstd::copy(_rtn_cpp.begin(),_rtn_cpp.end(),_rtn_ior);\n"""
cpp_impl_b["const MEDMEM::MESH&"]="""\tMEDMEM::MESH_i * _rtn_mesh_i = new MEDMEM::MESH_i(const_cast<MEDMEM::MESH*>(&_rtn_cpp));\n
\tSALOME_MED::MESH_ptr _rtn_ior = _rtn_mesh_i->_this();\n"""
cpp_impl_b["MEDMEM::MESH&"]="\tMEDMEM::MESH_i * _rtn_mesh_i = new MEDMEM::MESH_i(&_rtn_cpp);\n\tSALOME_MED::MESH_ptr _rtn_ior = _rtn_mesh_i->_this();\n"
cpp_impl_b["MEDMEM::MESH*"]= "\tMEDMEM::MESH_i * _rtn_mesh_i = new MEDMEM::MESH_i(_rtn_cpp);\n\tSALOME_MED::MESH_ptr _rtn_ior = _rtn_mesh_i->_this();\n"
cpp_impl_b["const MEDMEM::MESH*"]="\tMEDMEM::MESH_i * _rtn_mesh_i = new MEDMEM::MESH_i(const_cast<MEDMEM::MESH*>(_rtn_cpp));\n\tSALOME_MED::MESH_ptr _rtn_ior = _rtn_mesh_i->_this();\n"
cpp_impl_b["MEDMEM::SUPPORT*"]="\tMEDMEM::SUPPORT_i * _rtn_support_i = new MEDMEM::SUPPORT_i(_rtn_cpp);\n\tSALOME_MED::SUPPORT_ptr _rtn_ior = _rtn_support_i->_this();\n"
cpp_impl_b["const MEDMEM::FIELD<double>*"]="""\tMEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace> * _rtn_field_i = new MEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace>(const_cast<MEDMEM::FIELD<double>*>(_rtn_cpp),false);\n
\tSALOME_MED::FIELDDOUBLE_ptr _rtn_ior = _rtn_field_i->_this();\n"""
cpp_impl_b["MEDMEM::FIELD<double>*"]="""\tMEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace> * _rtn_field_i = new MEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace>(_rtn_cpp,true);\n
\tSALOME_MED::FIELDDOUBLE_ptr _rtn_ior = _rtn_field_i->_this();\n"""
cpp_impl_b["MEDMEM::FIELD<double>&"]="""\tMEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace> * _rtn_field_i = new MEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace>(&_rtn_cpp,false);\n
\tSALOME_MED::FIELDDOUBLE_ptr _rtn_ior = _rtn_field_i->_this();\n"""
cpp_impl_b["const MEDMEM::FIELD<double>&"]="""\tMEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace> * _rtn_field_i = new MEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace>(const_cast<MEDMEM::FIELD<double>*>(&_rtn_cpp),false);\n
\tSALOME_MED::FIELDDOUBLE_ptr _rtn_ior = _rtn_field_i->_this();\n"""
cpp_impl_b["std::vector<double>*"]="""\t%(module)s::dblevec * _rtn_ior = new %(module)s::dblevec;\n
\tint _rtn_cpp_length=(*_rtn_cpp).size();\n
\t_rtn_ior->length(_rtn_cpp_length);\n
\tfor (int i=0; i<_rtn_cpp_length; ++i)\n\t    (*_rtn_ior)[i] = (*_rtn_cpp)[i];\n"""
cpp_impl_b["std::vector<std::vector<double> >*"]="""\tint _rtn_cpp_i=(*_rtn_cpp).size();\n\tint _rtn_cpp_j=(*_rtn_cpp)[0].size();\n
\tdouble* _rtn_tab = new double[_rtn_cpp_i*_rtn_cpp_j];\n
\tfor (int i=0; i!=_rtn_cpp_i; ++i)\n\t    std::copy((*_rtn_cpp)[i].begin(),(*_rtn_cpp)[i].end(),_rtn_tab+i*_rtn_cpp_j);\n
\tSALOME_Matrix_i* _rtn_matrix_i = new SALOME_Matrix_i(*this,_rtn_tab,_rtn_cpp_i,_rtn_cpp_j,true);\n
\tSALOME::Matrix_ptr _rtn_ior = _rtn_matrix_i->_this();\n\tdelete _rtn_cpp;\n"""
cpp_impl_b["const MEDMEM::FIELD<int>*"]="\tMEDMEM::FIELDINT_i * _rtn_field_i = new MEDMEM::FIELDINT_i(const_cast<MEDMEM::FIELD<int>*>(_rtn_cpp),false);\n\tSALOME_MED::FIELDINT_ptr _rtn_ior = _rtn_field_i->_this();\n"
cpp_impl_b["MEDMEM::FIELD<int>*"]="\tMEDMEM::FIELDINT_i * _rtn_field_i = new MEDMEM::FIELDINT_i(_rtn_cpp,true);\n\tSALOME_MED::FIELDINT_ptr _rtn_ior = _rtn_field_i->_this();\n"
cpp_impl_b["MEDMEM::FIELD<int>&"]="\tMEDMEM::FIELDINT_i * _rtn_field_i = new MEDMEM::FIELDINT_i(&_rtn_cpp,false);\n\tSALOME_MED::FIELDINT_ptr _rtn_ior = _rtn_field_i->_this();\n"
cpp_impl_b["const MEDMEM::FIELD<int>&"]="\tMEDMEM::FIELDINT_i * _rtn_field_i = new MEDMEM::FIELDINT_i(const_cast<MEDMEM::FIELD<int>*>(&_rtn_cpp),false);\n\tSALOME_MED::FIELDINT_ptr _rtn_ior = _rtn_field_i->_this();\n"
cpp_impl_b["std::vector<int>*"]="""\t%(module)s::intvec * _rtn_ior = new %(module)s::intvec;
\tint _rtn_cpp_length=(*_rtn_cpp).size();
\t_rtn_ior->length(_rtn_cpp_length);
\tfor (int i=0; i<_rtn_cpp_length; ++i)\n\t    (*_rtn_ior)[i] = (*_rtn_cpp)[i];\n"""
cpp_impl_b["std::vector<std::string>"]="""\t%(module)s::stringvec * _rtn_ior = new %(module)s::stringvec;
\tint _rtn_cpp_length=_rtn_cpp.size();
\t_rtn_ior->length(_rtn_cpp_length);
\tfor (int i=0; i<_rtn_cpp_length; ++i)
\t    (*_rtn_ior)[i] = _rtn_cpp[i].c_str();\n"""
cpp_impl_b["MEDCoupling::MEDCouplingFieldDouble*"]="""\tMEDCoupling::MEDCouplingFieldDoubleServant * _rtn_field_i = new MEDCoupling::MEDCouplingFieldDoubleServant(_rtn_cpp);
\t_rtn_cpp->decrRef();
\tSALOME_MED::MEDCouplingFieldDoubleCorbaInterface_ptr _rtn_ior = _rtn_field_i->_this();\n"""
cpp_impl_b["MEDCoupling::MEDCouplingUMesh*"]="""\tMEDCoupling::MEDCouplingUMeshServant * _rtn_mesh_i = new MEDCoupling::MEDCouplingUMeshServant(_rtn_cpp);
\t_rtn_cpp->decrRef();
\tSALOME_MED::MEDCouplingUMeshCorbaInterface_ptr _rtn_ior = _rtn_mesh_i->_this();\n"""
cpp_impl_b["MEDCoupling::DataArrayDouble*"]="""\tMEDCoupling::DataArrayDoubleServant * _rtn_field_i = new MEDCoupling::DataArrayDoubleServant(_rtn_cpp);
\t_rtn_cpp->decrRef();
\tSALOME_MED::DataArrayDoubleCorbaInterface_ptr _rtn_ior = _rtn_field_i->_this();\n"""
#
# table for c++ code generation : out parameters processing and removeRef for reference counted objects
#
cpp_impl_c={}
cpp_impl_c["MEDMEM::FIELD<double>*&"]="""\tMEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace> * %(arg)s_ior = new MEDMEM::FIELDTEMPLATE_I<double,MEDMEM::FullInterlace>(_%(arg)s, true);\n
\t%(arg)s = %(arg)s_ior->_this();\n"""
cpp_impl_c["MEDMEM::FIELD<int>*&"]=""" \tMEDMEM::FIELDINT_i * %(arg)s_ior = new MEDMEM::FIELDINT_i(_%(arg)s, true);\n
\t%(arg)s = %(arg)s_ior->_this();\n"""
cpp_impl_c["std::vector<double>*&"]="""\t%(arg)s = new %(module)s::dblevec;\n
\t%(arg)s->length((*_%(arg)s).size());\n
\tfor (int i=0; i<(*_%(arg)s).size(); ++i)\n\t    (*%(arg)s)[i] = (*_%(arg)s)[i];\n"""
cpp_impl_c["std::vector<int>*&"]="""\t%(arg)s = new %(module)s::intvec;\n
\t%(arg)s->length((*_%(arg)s).size());\n
\tfor (int i=0; i<(*_%(arg)s).size(); ++i)\n\t    (*%(arg)s)[i] = (*_%(arg)s)[i];\n"""
cpp_impl_c["std::string&"]="\t%(arg)s = CORBA::string_dup(_%(arg)s.c_str());\n"
cpp_impl_c["int&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["bool&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["double&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["float&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["long&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["short&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["unsigned&"]="\t%(arg)s = _%(arg)s;\n"
cpp_impl_c["const MEDMEM::MESH&"]="\t_%(arg)s->removeReference();\n"
cpp_impl_c["const MEDMEM::MESH*"]="\t_%(arg)s->removeReference();\n"
cpp_impl_c["const MEDMEM::SUPPORT&"]="\t_%(arg)s->removeReference();\n"
cpp_impl_c["const MEDMEM::SUPPORT*"]="\t_%(arg)s->removeReference();\n"
cpp_impl_c["const MEDCoupling::MEDCouplingFieldDouble*"]="\t_%(arg)s->decrRef();\n"
cpp_impl_c["const MEDCoupling::MEDCouplingUMesh*"]="\t_%(arg)s->decrRef();\n"
cpp_impl_c["const MEDCoupling::MEDCouplingFieldDouble&"]="\t__%(arg)s->decrRef();\n"
cpp_impl_c["MEDCoupling::MEDCouplingFieldDouble*&"]="""\tMEDCoupling::MEDCouplingFieldDoubleServant * %(arg)s_out=new MEDCoupling::MEDCouplingFieldDoubleServant(_%(arg)s);
\t_%(arg)s->decrRef();
\t%(arg)s = %(arg)s_out->_this();\n"""

#
# the following awk files (extracted from hxx2saloe) are used to parse hxx file
# 
#
parse01="""
# This awk program deletes C like comments '*/  ...  /*'  
# --
# Copyright (C) CEA
# Author : Nicolas Crouzet (CEA)
# --
{
    if (t = index($0, "/*")) {
	if (t > 1)
	    tmp = substr($0, 1, t - 1)
	else
	    tmp = ""
	u = index(substr($0, t + 2), "*/")
	while (u == 0) {
	    getline
            t = -1
            u = index($0, "*/")
	}
	if (u <= length($0) - 2)
	    $0 = tmp substr($0, t + u + 3)
	else
	    $0 = tmp
    }
    print $0
}
"""
parse1="""
# This awk program extract public functions of the class definition present in hxx interface
# --
# Copyright (C) CEA
# Author : Nicolas Crouzet (CEA)
# --

BEGIN { public=0 }

# we want to extract each function that is public and that does'nt contain
# the patterns : public, protected, private, // (comments), { and }
public == 1     && 
$1 !~ /public/  && 
$1 !~ /protected/ && 
$1 !~ /private/ && 
$1 !~ /\/\/*/   && 
$1 !~ /{|}/  {
   for (i=1; i<=NF; i++)
      printf "%s ", $i
#  change line if last field contains ";" -> one function per line in output
   if ( $NF ~ /;/ ) 
      printf "\\n"
}
   
$1 == "class" && $0 !~ /;/ {public=1} # we test matching against /;/  to get rid of forward declaration
$1 ~ /public/ {public=1}
$1 ~ /protected/ {public=0}
$1 ~ /private/ {public=0}
$1 ~ /}/      {public=0}
"""
parse2="""
# suppress blanks between type and indirection or reference operators (* and &)
# --
# Copyright (C) CEA
# Author : Nicolas Crouzet (CEA)
# --
{ gsub(/[ \\t]+&/,"\\\\& ")
  gsub(/[ \\t]+\*/,"* ")
  print $0 }
"""
parse3="""
# This awk program contains the type mapping tables - and the treatments
# --
# Copyright (C) CEA, EDF
# Author : Nicolas Crouzet (CEA)
# --
# for code generation
#
BEGIN { 
#
# file name generation
  class_i=class_name"_i"
#
#
# type mapping from c++ component to idl
#
  idl_arg_type["int"]="in long"
  idl_arg_type["bool"]="in boolean"
  idl_arg_type["double"]="in double"
  idl_arg_type["float"]="in float"
  idl_arg_type["long"]="in long"
  idl_arg_type["short"]="in short"
#  idl_arg_type["unsigned"]="in unsigned long"
  idl_arg_type["const char*"]="in string"
  idl_arg_type["const std::string&"]="in string"
  idl_arg_type["int&"]="out long"
  idl_arg_type["bool&"]="out boolean"
  idl_arg_type["double&"]="out double"
  idl_arg_type["float&"]="out float"
  idl_arg_type["long&"]="out long"
  idl_arg_type["short&"]="out short"
  idl_arg_type["unsigned&"]="out unsigned long"
  idl_arg_type["std::string&"]="out string"
  idl_arg_type["const MEDMEM::MESH&"]="in SALOME_MED::MESH"
  idl_arg_type["const MEDMEM::MESH*"]="in SALOME_MED::MESH"
  idl_arg_type["const MEDMEM::SUPPORT&"]="in SALOME_MED::SUPPORT"
  idl_arg_type["const MEDMEM::SUPPORT*"]="in SALOME_MED::SUPPORT"
  idl_arg_type["const MEDMEM::FIELD<double>*"]="in SALOME_MED::FIELDDOUBLE"
  idl_arg_type["const MEDMEM::FIELD<double>&"]="in SALOME_MED::FIELDDOUBLE"
  idl_arg_type["MEDMEM::FIELD<double>*&"]="out SALOME_MED::FIELDDOUBLE"
  idl_arg_type["const std::vector<double>&"]="in SALOME::vectorOfDouble"
  idl_arg_type["const std::vector<std::vector<double> >&"]="in SALOME::Matrix"
  idl_arg_type["std::vector<double>*&"]="out SALOME::vectorOfDouble"
  idl_arg_type["const MEDMEM::FIELD<int>*"]="in SALOME_MED::FIELDINT"
  idl_arg_type["const MEDMEM::FIELD<int>&"]="in SALOME_MED::FIELDINT"
  idl_arg_type["MEDMEM::FIELD<int>*&"]="out SALOME_MED::FIELDINT"
  idl_arg_type["const std::vector<int>&"]="in SALOME::vectorOfLong"
  idl_arg_type["std::vector<int>*&"]="out SALOME::vectorOfLong"
  idl_arg_type["const MEDCoupling::MEDCouplingFieldDouble*"]="in SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
  idl_arg_type["const MEDCoupling::MEDCouplingFieldDouble&"]="in SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
  idl_arg_type["MEDCoupling::MEDCouplingFieldDouble*&"]="out SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
  idl_arg_type["const MEDCoupling::MEDCouplingUMesh*"]="in SALOME_MED::MEDCouplingUMeshCorbaInterface"
#
#
# mapping for returned types
#
  idl_rtn_type["void"]="void"
  idl_rtn_type["int"]="long"
  idl_rtn_type["bool"]="boolean"
  idl_rtn_type["double"]="double"
  idl_rtn_type["float"]="float"
  idl_rtn_type["long"]="long"
  idl_rtn_type["short"]="short"
  idl_rtn_type["unsigned"]="unsigned long"
  idl_rtn_type["const char*"]="string"
  idl_rtn_type["char*"]="string"
  idl_rtn_type["std::string"]="string"
  idl_rtn_type["const MEDMEM::MESH&"]="SALOME_MED::MESH"
  idl_rtn_type["MEDMEM::MESH&"]="SALOME_MED::MESH"
  idl_rtn_type["MEDMEM::MESH*"]="SALOME_MED::MESH"
  idl_rtn_type["const MEDMEM::MESH*"]="SALOME_MED::MESH"
  idl_rtn_type["MEDMEM::SUPPORT*"]="SALOME_MED::SUPPORT"
  idl_rtn_type["const MEDMEM::FIELD<double>*"]="SALOME_MED::FIELDDOUBLE"
  idl_rtn_type["MEDMEM::FIELD<double>*"]="SALOME_MED::FIELDDOUBLE"
  idl_rtn_type["MEDMEM::FIELD<double>&"]="SALOME_MED::FIELDDOUBLE"
  idl_rtn_type["const MEDMEM::FIELD<double>&"]="SALOME_MED::FIELDDOUBLE"
  idl_rtn_type["std::vector<double>*"]="SALOME::vectorOfDouble"
  idl_rtn_type["std::vector<std::vector<double> >*"]="SALOME::Matrix"
  idl_rtn_type["const MEDMEM::FIELD<int>*"]="SALOME_MED::FIELDINT"
  idl_rtn_type["MEDMEM::FIELD<int>*"]="SALOME_MED::FIELDINT"
  idl_rtn_type["MEDMEM::FIELD<int>&"]="SALOME_MED::FIELDINT"
  idl_rtn_type["const MEDMEM::FIELD<int>&"]="SALOME_MED::FIELDINT"
  idl_rtn_type["std::vector<int>*"]="SALOME::vectorOfLong"
  idl_rtn_type["std::vector<std::string>"]="StrSeq"
  idl_rtn_type["MEDCoupling::MEDCouplingUMesh*"]="SALOME_MED::MEDCouplingUMeshCorbaInterface"
  idl_rtn_type["MEDCoupling::MEDCouplingFieldDouble*"]="SALOME_MED::MEDCouplingFieldDoubleCorbaInterface"
  idl_rtn_type["MEDCoupling::DataArrayDouble*"]="SALOME_MED::DataArrayDoubleServantCorbaInterface"
#
#
# record sep is ");\\n" whith blanks all around, and optional "(" at the beginning
  RS="[(]?[ \\t]*[)][ \\t]*(const)?[ \\t]*[;][ \\t]*[\\n]"  
  FS="[ \\t]*[(,][ \\t]*"  # field sep is either "(" or "," surrounded by blanks 
}

# --------------------- treatment 1 ----------------------------------
#
#  extract from fields types, function name, and argument's names
#
{
  print "Function : ",$0 >> "parse_result"  # print for debug
  for (i=1; i<=NF; i++) {
      print "\\t-> ",i," : ",$i >> "parse_result"
  }
  ok1=0;ok=1
  error_message="\\t  The non compatible types are : "
  # check if returned type ($1) is one of the accepted types (idl_rtn_type)
  for (cpptype in idl_rtn_type) {
    if ( substr($1,1,length(cpptype)) == cpptype ) {
      # if compatible, store returned type and function name
      type[1]=cpptype
      name[1]=substr($1,length(cpptype)+1)
      sub("^[ \\t]*","",name[1]) # get rid of leading blanks
      ok1=1
      break
    }
  }
  ok*=ok1
  if ( ! ok1) {
      split($1,tab," ") 
      error_message=error_message sprintf("\\n\\t\\t-> %s (return type)",tab[1])
  }
  # for each argument ($i), check if it is compatible (belongs to idl_arg_type)
  for (i=2; i<=NF; i++) {
    ok2=0
    split($i,tab,"=") # get rid of default value
    item=tab[1]
    sub("/[ \\t]*&[ \\t]*/", "&", item) # supress spaces around * and $
    sub("/[ \\t]**[ \\t]*/", "*", item)
    for (cpptype in idl_arg_type) {
	l = length(cpptype)
	s0 = substr(item,1,l) # to discriminate between int and int&, ...
	s1 = " "
	if (length(item) > l)
	    s1 = substr(item, l+1, 1)

	if ( (s0 == cpptype) && (s1 == " ") ) {
          # if compatible, store argument type and name
          type[i]=cpptype
          name[i]=substr(item,length(cpptype)+1)
          sub("^[ \\t]*","",name[i]) # get rid of leading blanks
          if ( length(name[i]) == 0 ) # automatic name if argument's name wasn't precised
             name[i]=sprintf("_arg%d",i-1)
          ok2=1
	  break
       }
    }
    ok*=ok2 # ok=0 if one of the type is not compatible
    if ( ! ok2) {
	error_message=error_message "\\n\\t\\t-> "item
    }
  }

  # print compatibility 
  if ( $0 !~ class_name ) { # constructor are not considered, but we don't print it
      if ( ok == 0){ # if one of the c++ type is not compatible
          printf "     [KO]     :  %s",$0
      }
      else
          printf "     [OK]     :  %s",$0
	
      if ( $0 !~ /\(/  ) {
          printf "(" # if there is no argument, parenthesis was suppressed, so we add it for printing
      }
      printf ");\\n"
      if ( ok == 0){ #print the error message
          printf "%s\\n\\n",error_message
      }
  }    
  if ( ok == 0) # pass to the next function if one of the c++ type is not compatible
      next
}
#
# --------------------- treatment 1 bis ------------------------------
{
    printf "Function;%s;%s\\n",type[1],name[1] > "parse_type_result"
    for (i=2; i<=NF; i++) {
	printf "%s;%s\\n",type[i],name[i] >> "parse_type_result"
    }
}
"""
