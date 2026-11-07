# Copyright (C) 2016-2026  CEA, EDF
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

from . import _use_pyqt
if _use_pyqt:
  from PyQt5.QtGui import * 
else:
  from PySide2.QtGui import *

  __original_ofn = QFileDialog.getOpenFileName
  __original_sfn = QFileDialog.getSaveFileName

  # In PySide2, getOpenFileName and co returns 2 values, and only one in PyQt ...
  def newOfn(cls,*args, **kargs):
    tup = __original_ofn(*args, **kargs)
    return tup[0]

  def newSfn(cls,*args, **kargs):
    tup = __original_sfn(*args, **kargs)
    return tup[0]

  QFileDialog.getOpenFileName = classmethod(newOfn)
  QFileDialog.getSaveFileName = classmethod(newSfn)

