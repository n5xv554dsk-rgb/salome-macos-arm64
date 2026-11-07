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

"""
The python module module_generator defines classes which can be used to define a SALOME module, its components and
generates a SALOME source module, its installation and a SALOME application including this module and
other preexisting SALOME modules like GEOM, SMESH or others.
"""
from module_generator.gener import Module, Service, Generator
from module_generator.fcompo import F77Component
from module_generator.cppcompo import CPPComponent
from module_generator.pacocompo import PACOComponent
from module_generator.pycompo import PYComponent
from module_generator.astcompo import ASTERComponent
from module_generator.hxxcompo import HXX2SALOMEComponent
from module_generator.hxxparacompo import HXX2SALOMEParaComponent
from module_generator.yacstypes import add_type
from module_generator.salomemodules import add_module
from module_generator.gener import Library
from module_generator.mpicompo import MPIComponent
