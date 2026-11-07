#  Copyright (C) 2012-2026 EDF
#
#  This file is part of SALOME HYDRO module.
#
#  SALOME HYDRO module is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SALOME HYDRO module is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SALOME HYDRO module.  If not, see <http://www.gnu.org/licenses/>.

import os
from generator.generator_python import PythonGenerator

def entryPoint():
  return {'name': 'boundary_conditions',
          'factory': BoundaryConditionsGenerator}

class BoundaryConditionsGenerator(PythonGenerator):
  """
  This generator creates files containing associations between groups and
  boundary conditions (.bcd files, for Boundary Conditions Definition).
  Those files contain one line per group, each line containing four fields
  separated by spaces: LIHBOR LIUBOR LIVBOR GROUP.
  LIHBOR, LIUBOR and LIVBOR are integer values, GROUP is a string (the name of
  the group).
  
  Example:
  
  
  """

  def gener(self, obj, format = 'brut', config = None):
    self.group_list = []
    self.text = PythonGenerator.gener(self, obj, format)
    return self.text
  
  def generPROC_ETAPE(self, obj):
    group_dict = {}
    for keyword in obj.mc_liste:
      group_dict[keyword.nom] = keyword.valeur
    self.group_list.append(group_dict)
    return PythonGenerator.generPROC_ETAPE(self, obj)

  def writeDefault(self, basefilename):
    output_filename = os.path.splitext(basefilename)[0] + ".bcd"
    f = open(output_filename, 'w')
    f.write("%d\n" % len(self.group_list))
    for group_dict in self.group_list:
      f.write("%(LIHBOR)d %(LIUBOR)d %(LIVBOR)d %(GROUP)s\n" % group_dict)
    f.close()
