# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
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
import re
from convert_python import Pythonparser


def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {"name": "openturns_study", "factory": OTStudyparser}


class OTStudyparser(Pythonparser):
    """
    This converter works like Pythonparser, except that it also initializes all
    model variables to None in order to avoid Python syntax errors when loading
    a file with a different or inexistent definition of variables.
    """

    # We look for pattern "ModelVariable=NOMVAR,"
    pattern_model_variable = re.compile(r"ModelVariable\s*=\s*(\w+)\s*,")

    def convert(self, outformat, appli=None):
        text = Pythonparser.convert(self, outformat, appli)
        varnames = self.pattern_model_variable.findall(text)
        newtext = ""
        for var in varnames:
            newtext += "%s = None\n" % var
        newtext += text
        return newtext
