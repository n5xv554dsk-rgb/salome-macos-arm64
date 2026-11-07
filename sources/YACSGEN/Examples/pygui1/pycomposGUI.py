# Copyright (C) 2009-2026  EDF
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

import os
usePySide = 'SALOME_USE_PYSIDE' in os.environ
if usePySide:
  from PySide2 import QtCore, QtWidgets
  from PySide2.QtCore import
  from PySide2.QtWidgets import
  from PySide2.QtUiTools import QUiLoader
  from PySide2.QtCore import QFile
  from PySide2.QtCore import Slot
else:
 from PyQt5.QtCore import *
 from PyQt5.QtWidgets import *
 from PyQt5 import QtCore, uic, QtWidgets
 from PyQt5.QtCore import pyqtSlot as QtPySlot

from salome.kernel import salome
import pycompos_ORB

# Get SALOME PyQt interface
import SalomePyQt
sgPyQt = SalomePyQt.SalomePyQt()

# Get SALOME Swig interface
import libSALOME_Swig
sg = libSALOME_Swig.SALOMEGUI_Swig()

# object counter
__objectid__ = 0

###
# get active study ID
###
def _getStudyId():
    return sgPyQt.getStudyId()

###
# get active study
###
def _getStudy():
    studyId = _getStudyId()
    study = salome.myStudyManager.GetStudyByID( studyId )
    return study

# called when module is initialized
# return map of popup windows to be used by the module
def windows():
  wm = {}
  wm[SalomePyQt.WT_ObjectBrowser] = Qt.LeftDockWidgetArea
  wm[SalomePyQt.WT_PyConsole]     = Qt.BottomDockWidgetArea
  return wm

# called when module is initialized
# return list of 2d/3d views to be used ny the module
def views():
  return []

# called when module is activated
# returns True if activating is successfull and False otherwise
def activate():
  # create top-level menu
  mid = sgPyQt.createMenu( "pycompos", -1, 90, sgPyQt.defaultMenuGroup() )
  # create toolbar
  tid = sgPyQt.createTool( "pycompos" )
  # create actions and fill menu and toolbar with actions
  a = sgPyQt.createAction( 941, "Hello", "Hello", "Show hello dialog box" ,"exec.png")
  sgPyQt.createMenu( a, mid )
  sgPyQt.createTool( a, tid )
  a = sgPyQt.createAction( 942, "Hello2", "Hello2", "Show hello2 dialog box" ,"exec.png")
  sgPyQt.createMenu( a, mid )
  sgPyQt.createTool( a, tid )
  a = sgPyQt.createAction( 943, "Create object", "Create object", "Create object","exec.png" )
  sgPyQt.createMenu( a, mid )
  sgPyQt.createTool( a, tid )

  return True

# called when module is deactivated
def deactivate():
  pass

_engine=None
def getEngine():
  global _engine
  if not _engine:
    _engine= salome.lcc.FindOrLoadComponent( "FactoryServerPy", "pycompos" )
  return _engine

###
# Create new object
###
def CreateObject():
    global __objectid__
    default_name = str( sgPyQt.stringSetting( "pycompos", "def_obj_name", "Object" ).lstrip().rstrip() )
    # generate object name
    __objectid__  = __objectid__ + 1
    name = "%s_%d" % ( default_name, __objectid__ )
    if not name: return
    getEngine().createObject( _getStudy(), name )
    print(getEngine().s1(4,5))
    print(getEngine().ComponentDataType())
    sg.updateObjBrowser( True )

class DemoImpl(QtWidgets.QDialog):
    def __init__(self, *args):
        super(DemoImpl, self).__init__(*args)
        if usePySide:
          loader = QUiLoader()
          ui_file = QFile(os.path.join(os.environ["pycompos_ROOT_DIR"],"share","salome","resources","pycompos","demo.ui"))
          ui_file.open(QFile.ReadOnly)
          loader.load(ui_file, self)
          ui_file.close()
        else:
          uic.loadUi(os.path.join(os.environ["pycompos_ROOT_DIR"],"share","salome","resources","pycompos","demo.ui"), self)

    @QtPySlot()
    def on_button1_clicked(self):
        for s in "This is a demo".split(" "):
            self.list.addItem(s)

# called when GUI action is activated
# action ID is passed as parameter
def OnGUIEvent( commandID ):
  print("pycompos.OnGUIEvent(): command = %d" % commandID)
  if commandID==941:
    widget=QMainWindow(sgPyQt.getDesktop())
    mywidget = QLabel("Hello world!", widget)
    widget.setCentralWidget(mywidget)
    widget.show()

  elif commandID==942:
    widget = DemoImpl(sgPyQt.getDesktop())
    widget.show()

  elif commandID==943:
    CreateObject()


