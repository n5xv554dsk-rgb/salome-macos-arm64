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
#---------------------------#
class PopUpMenuRacine(object) :
#---------------------------#

    def createPopUpMenu(self):
        print ("createPopUpMenu de MenuRacine")


    def addParametersApres(self):
        print ("addParametersApres de MenuRacine")

#---------------------------#
class PopUpMenuNodeMinimal(object) :
#---------------------------#

    def createPopUpMenu(self):
        print ("createPopUpMenu de PopUpMenuNodeMinimal")

    def createActions(self):
        print ("createActions")

    def supprimeNoeud(self):
        print ("supprimeNoeud")

    def viewDoc(self):
        print ("viewDoc")

    def addParametersApres(self):
        print ("addParametersApres")

    def addParametersAvant(self):
        print ("addParametersAvant")

    def addCommApres(self):
        print ("addCommApres")

    def addCommAvant(self):
        print ("addCommAvant")

    def deplieCeNiveau(self):
        print ("deplieCeNiveau")

#--------------------------------------------#
class PopUpMenuNodePartiel (PopUpMenuNodeMinimal):
#---------------------------------------------#
    def createPopUpMenu(self):
        PopUpMenuNodeMinimal.createPopUpMenu(self)
        print ("createPopUpMenu de PopUpMenuNodePartiel")


#-----------------------------------------#
class PopUpMenuNode(PopUpMenuNodePartiel) :
#-----------------------------------------#
    def createPopUpMenu(self):
        PopUpMenuNodePartiel.createPopUpMenu(self)
        print ("createPopUpMenu de PopUpMenuNode")

    def commenter(self):
        print ("commenter")
