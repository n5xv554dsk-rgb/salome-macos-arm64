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
import inspect
import pathlib
import os
import shutil

class DefaultSchemaBuilder:
  def __init__(self, prescript=None):
    """
    This object builds the YACS schema for the parametric computation.
    prescript: contains python code that is executed before any evaluation.
    """
    self.prescript = prescript

  def buildSchema(self, local_work_dir):
    """
    Create the YACS schema and copy it to local_work_dir.
    local_work_dir : path where the schema will be created.
    return:
      path to the created file,
      list of additional files needed for running.
    """
    # use generic schema
    filename = inspect.getframeinfo(inspect.currentframe()).filename
    install_directory = pathlib.Path(filename).resolve().parent
    yacs_schema_path = os.path.join(install_directory, "schemas",
                                    "idefix_pyschema.xml")
    plugin_path = os.path.join(install_directory, "schemas", "plugin.py")
    yacs_schema_path = shutil.copy(yacs_schema_path, local_work_dir)
    plugin_path = shutil.copy(plugin_path, local_work_dir)
    files = [plugin_path]
    if self.prescript:
      prescript_path = os.path.join(local_work_dir, "idefix_prescript.py")
      with open(prescript_path, "w") as f:
        f.write(self.prescript)
      files.append(prescript_path)
    return yacs_schema_path, files
