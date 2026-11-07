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
import sys

import SalomePyQt
sgPyQt = SalomePyQt.SalomePyQt()

import eficasSalome

class EficasForBoundaryConditionsAppli(eficasSalome.MyEficas):
  """
  This class launches Eficas with "boundary_conditions" catalog.
  """
  def __init__(self, fichier = None, version = None):
    self.codedir = os.path.dirname(__file__)
    sys.path[:0] = [self.codedir]
    eficasSalome.MyEficas.__init__(self, sgPyQt.getDesktop(), "boundary_conditions",
                                   fichier, version = version)

  def addJdcInSalome(self, jdcPath):
    """
    Those files are not added in Salome study tree for now.
    """
    pass

  def closeEvent(self, event):
    while self.codedir in sys.path:
      sys.path.remove(self.codedir)
    eficasSalome.MyEficas.closeEvent(self, event)
