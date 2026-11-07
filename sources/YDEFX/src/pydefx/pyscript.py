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
from . import sample
from salome.yacs import py2yacs

class PyScriptException(Exception):
  pass

class PyScript:
  def __init__(self):
    self.script = ""
    self.properties, self.errors = py2yacs.get_properties(self.script)

  def loadFile(self,path):
    with open(path, "r") as f:
      self.script = f.read()
    self.properties, self.errors = py2yacs.get_properties(self.script)

  def loadString(self, script):
    self.script = script
    self.properties, self.errors = py2yacs.get_properties(self.script)

  def content(self):
    return self.script

  def saveFile(self, path):
    with open(path, "w") as f:
      f.write(self.script)

  def getAllProperties(self):
    """
    functions,errors = myscript.getAllProperties()
    print(errors)      # list of syntax errors in the script
    for f in functions:
      print(f.name)    # function name
      print(f.inputs)  # list of input variable names
      print(f.outputs) # list of output variable names
      print(f.errors)  # list of py2yacs errors in the function
      print(f.imports) # list of import statements in the function
    """
    return py2yacs.get_properties(self.script)

  def getFunctionProperties(self, fname = "_exec"):
    """
    Properties of the _exec function:
    fn_properties = myscript.getFunctionProperties()
    fn_properties.name    : "_exec"
    fn_properties.inputs  : list of input variable names
    fn_properties.outputs : list of output variable names
    fn_properties.errors  : list of py2yacs errors in the function
    fn_properties.imports : list of import statements in the function
    fn_properties is None if the "_exec" function does not exist.
    """
    fn_properties = next((f for f in self.properties if f.name == fname), None)
    return fn_properties

  def getOutputNames(self, fname = "_exec"):
    errorsText = self.getErrors(fname)
    if len(errorsText) > 0:
      raise PyScriptException(errorsText)
    fnProperties = self.getFunctionProperties(fname)
    return fnProperties.outputs

  def getInputNames(self, fname = "_exec"):
    errorsText = self.getErrors(fname)
    if len(errorsText) > 0:
      raise PyScriptException(errorsText)
    fnProperties = self.getFunctionProperties(fname)
    return fnProperties.inputs

  def getErrors(self, fname = "_exec"):
    error_string = ""
    if len(self.errors) > 0:
      error_string = "global errors:\n"
      error_string += '\n'.join(self.errors)
    else:
      properties = self.getFunctionProperties(fname)
      if properties is None:
        error_string += "Function {} not found in the script!".format(fname)
      else:
        error_string += '\n'.join(properties.errors)
    return error_string

  def CreateEmptySample(self):
    """
    Create a sample with input and output variable names set.
    """
    fn = "_exec"
    errors = self.getErrors(fn)
    if len(errors) > 0:
      raise PyScriptException(errors)
    fn_properties = self.getFunctionProperties(fn)
    return sample.Sample(fn_properties.inputs, fn_properties.outputs)
