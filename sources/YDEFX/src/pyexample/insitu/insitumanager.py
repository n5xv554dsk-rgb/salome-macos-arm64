# Copyright (C) 2019-2026 EDF
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

import pydefx.samplecsvmanager
import inspect
import os
import pathlib

class InsituManager(pydefx.samplecsvmanager.SampleManager):
  def prepareRun(self, sample, directory):
    files_list = super().prepareRun(sample, directory)
    # add the insituiterator file to the list
    filename = inspect.getframeinfo(inspect.currentframe()).filename
    install_directory = pathlib.Path(filename).resolve().parent
    iteratorFile = os.path.join(install_directory, "insituiterator.py")
    files_list.append(iteratorFile)
    return files_list

  def loadResult(self, sample, directory):
    super().loadResult(sample, directory)
    # load the insitu result and return it
    insitu_result_file = os.path.join(directory,
                                      self.getResultFileName(),
                                      "insitu_result.txt")
    with open(insitu_result_file, "r") as f:
      result_string = f.read()
    return eval(result_string)

  def getModuleName(self):
    return "insituiterator"
