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

#######################################################################
#         SALOME modules                                              #
#######################################################################
salome_modules={}

def add_module(module,idldefs="",linklibs=""):
  """ add a module configuration for other module than KERNEL

       :param module: module name (GEOM, SMESH, VISU, ...)
       :type module: string
       :param idldefs:  definition instructions to add to idl files when using this module
       :type idldefs: string
       :param linklibs:  options to add to _link_LIBRARIES in CMakeLists
       :type linklibs: string
  """
  salome_modules[module]={"idldefs" : idldefs, "linklibs" : linklibs}

#module GEOM
idldefs="""
#include "GEOM_Gen.idl"
"""

linklibs="""  ${GEOM_SalomeIDLGEOM}
"""
add_module("GEOM",idldefs,linklibs)

#module MED
idldefs="""
#include "MEDCouplingCorbaServant.idl"
"""

linklibs="""
  ${FIELDS_SalomeIDLMED}
  ${FIELDS_medcouplingcorba}
  ${FIELDS_medcouplingclient}
"""
salome_modules["MED"]={"idldefs" : idldefs, "linklibs" : linklibs}

#module SMESH
idldefs="""
#include "SMESH_Gen.idl"
#include "SMESH_Mesh.idl"
"""

linklibs="""  ${SMESH_SalomeIDLSMESH}
"""
salome_modules["SMESH"]={"idldefs" : idldefs, "linklibs" : linklibs,
                         "depends":["GEOM","MED"]}
