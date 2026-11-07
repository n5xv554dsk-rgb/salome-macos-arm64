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
import configuration
import os


class CONFIG(configuration.CONFIG_BASE):

  #-----------------------------------
  def __init__(self,appli,repIni):
  #-----------------------------------


      self.labels_user=['PedfReader', 'catalogues','savedir','path_doc']
      self.labels_eficas=["OpenTURNS_path","path_doc","PedfReader"]
      self.labels_eficas=self.labels_eficas+["rep_cata","lang","catalogues"]
      configuration.CONFIG_BASE.__init__(self,appli,repIni)

  #---------------------------------------
  def lecture_fichier_ini_standard(self):
  #---------------------------------------
       configuration.CONFIG_BASE.lecture_fichier_ini_standard(self)
       if hasattr(self,'OpenTURNS_path') : self.oldOTPath=self.OpenTURNS_path

  #---------------------------------------
  def lecture_fichier_ini_integrateur(self):
  #---------------------------------------
       configuration.CONFIG_BASE.lecture_fichier_ini_utilisateur(self)
       if hasattr(self,'OpenTURNS_path') :
          if hasattr(self,'oldOTPath') and (self.OpenTURNS_path != self.oldOTPath):
               import sys
               sys.path.remove(self.oldOTPath)
               sys.path[:0]=[self.OpenTURNS_path]
               self.oldOTPath=self.OpenTURNS_path

def make_config(appli,rep):
    return CONFIG(appli,rep)

