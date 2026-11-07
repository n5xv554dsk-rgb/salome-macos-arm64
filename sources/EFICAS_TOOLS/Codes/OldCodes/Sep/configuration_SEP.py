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
"""
    Ce module sert pour charger les paramètres de configuration d'EFICAS
"""
# Modules Python
import os, sys, string, types, re
import traceback
from PyQt4.QtGui  import *

# Modules Eficas
import configuration
import os


class CONFIG(configuration.CONFIG_BASE):

  #-----------------------------------
  def __init__(self,appli,repIni):
  #-----------------------------------

      self.labels_user=['PedfReader', 'catalogues','savedir']
      self.labels_eficas=['path_doc','PedfReader','lang','rep_cata','catalogues']

      self.INSTALLDIR =os.path.dirname(__file__)
      configuration.CONFIG_BASE.__init__(self,appli,repIni)



def make_config(appli,rep):
    return CONFIG(appli,rep)


