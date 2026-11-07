# -*- coding: utf-8 -*-
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
from __future__ import absolute_import
try :
   from builtins import str
except : pass
import os

from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException
from .generator_python import PythonGenerator
import six

def entryPoint():
    """
    Return a dictionary containing the description needed to load the plugin
    """
    return {'name' : 'file_from_template',
            'factory' : FileFromTemplateGenerator}


class FileFromTemplateGenerator(PythonGenerator):
    """
    This generator creates an output file from a template (file with holes) in
    addition to Eficas .comm file. The parts to replace in the template must be
    in the form %KEYWORD%, where KEYWORD may be either the name of the Eficas
    element (short form, for instance MY_MCSIMP) or the "path" to the Eficas
    element (long form, for instance MYPROC.MYBLOC.MY_MCSIMP).
    
    To use this generator, the configuration of the code must implement two
    methods: get_extension() that must return the extension of the output file
    and get_template_file() that must return the path of the template file. Be
    sure also that your catalog is coherent with your template file.
    """
    
    def gener(self, obj, format = 'brut', config = None):
        self.config = config
        self.kw_dict = {}
        self.text = PythonGenerator.gener(self, obj, format)
        return self.text
    
    def generate_output_from_template(self) :
        """
        Generate the output text from the template file and the keywords
        """
        templateFileName = self.config.get_template_file()
        if not os.path.isfile(templateFileName):
            raise EficasException(tr("Fichier patron %s n'existe pas.",
                                    str( templateFileName)))
        f = open(templateFileName, "r")
        template = f.read()  
        f.close()
        self.output_text = self.replace_keywords(template)

    def generMCSIMP(self, obj) :
        """
        Save object value in the keyword dict for further use, then generate
        the text corresponding to the MCSIMP element.
        """
        short_keyword = obj.nom.strip()
        long_keyword = ""
        for i in obj.getGenealogie()[:-1]:
            long_keyword += i + "."
        long_keyword += short_keyword
        self.kw_dict[short_keyword] = obj.valeur
        self.kw_dict[long_keyword] = obj.valeur
        return PythonGenerator.generMCSIMP(self, obj)

    def replace_keywords(self, template_string):
        result = template_string
        for item in six.iteritems(self.kw_dict):
            replace_str = "%" + item[0] + "%"
            result = result.replace(replace_str, str(item[1]))
        return result
    
    def writeDefault(self, basefilename):
        self.generate_output_from_template()
        output_filename = os.path.splitext(basefilename)[0] + \
                          self.config.get_extension()
        f = open(output_filename, 'w')
        f.write(self.output_text)
        f.close()
