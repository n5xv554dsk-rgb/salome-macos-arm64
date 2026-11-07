# -*- coding: utf-8 -*-
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

class StudyResult:
  """
  This class gathers global information about the execution of the study (global
  errors, global result).
  """
  def __init__(self):
    self.result = None
    self.exit_code = None
    self.error_message = None

  def isExitCodeAvailable(self):
    return not self.exit_code is None

  def getExitCode(self):
    return self.exit_code

  def isResultAvailable(self):
    return not self.exit_code is None

  def getResult(self):
    return self.result

  def hasErrors(self):
    return not self.error_message is None and len(self.error_message) > 0

  def getErrors(self):
    return self.error_message

  def __str__(self):
    result = """Exit code : {}
Error message : {}
Result:
{}""".format(self.exit_code, self.error_message, self.result)
    return result
