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

# The following import is made in the execution environment and in the working
# directory of the job.
import samplecsviterator
import os

class SampleIterator(samplecsviterator.SampleIterator):
  """
  Example of an iterator which uses insitu computation.
  """
  def __init__(self, directory=None):
    super().__init__(directory)
    self.insitu_result = 0

  def addResult(self, currentId, currentInput, currentOutput, currentError):
    """
    currentId    : integer. Index of the curent point.
    currentInput : dictionary of curent input values (name, value)
    currentOutput: tuple with the output values
    currentError : string. Empty if no error.
    """
    super().addResult(currentId, currentInput, currentOutput, currentError)
    value_of_interest = currentOutput
    self.insitu_result = self.insitu_result + value_of_interest

  def terminate(self):
    super().terminate()
    result_file = os.path.join(self.result_directory, "insitu_result.txt")
    with open(result_file, "w") as f:
      f.write(repr(self.insitu_result))
