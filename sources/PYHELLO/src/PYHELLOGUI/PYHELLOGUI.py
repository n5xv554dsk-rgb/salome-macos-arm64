# Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

# ---
# File   : PYHELLOGUI.py
# Author : Vadim SANDLER, Open CASCADE S.A.S. (vadim.sandler@opencascade.com)
# ---
#
import traceback

from PYHELLO_utils import (moduleName, getObjectID, verbose,
                           moduleID, objectID, getEngineIOR, getEngine)
from SalomePyQt import (usePySide, SalomePyQt, WT_ObjectBrowser, WT_PyConsole, PT_Selector,  # @UnresolvedImport
                        PT_String)  # @UnresolvedImport
if usePySide():
  from PySide2.QtWidgets import (QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,  # @UnresolvedImport
                                 QPushButton, QMessageBox, QInputDialog)  # @UnresolvedImport
  from PySide2.QtCore import Qt
else:
  from PyQt5.Qt import (QDialog, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,  # @UnresolvedImport
                        QPushButton, QMessageBox, QInputDialog, Qt)  # @UnresolvedImport
from salome.kernel.salome.kernel import termcolor
from salome.kernel.salome.kernel.logger import Logger
import libSALOME_Swig


logger = Logger(moduleName(), color=termcolor.RED_FG)

from salome.kernel import salome

################################################
# GUI context class
# Used to store actions, menus, toolbars, etc...
################################################

class GUIcontext:
    # menus/toolbars/actions IDs
    PYHELLO_MENU_ID  = 90
    HELLO_ID         = 941
    CREATE_OBJECT_ID = 942
    OPTIONS_ID       = 943
    OPTION_1_ID      = 944
    OPTION_2_ID      = 945
    OPTION_3_ID      = 946
    PASSWORD_ID      = 947
    PYHELLO_TB_ID    = 90
    DELETE_ALL_ID    = 951
    SHOW_ME_ID       = 952
    DELETE_ME_ID     = 953
    RENAME_ME_ID     = 954
    # default object name
    DEFAULT_NAME     = "Object"
    # default password
    DEFAULT_PASSWD   = "Passwd"

    # constructor
    def __init__( self ):
        # create top-level menu
        mid = sgPyQt.createMenu( "PyHello", -1, GUIcontext.PYHELLO_MENU_ID, sgPyQt.defaultMenuGroup() )
        # create toolbar
        tid = sgPyQt.createTool( "PyHello" )
        # create actions and fill menu and toolbar with actions
        a = sgPyQt.createAction( GUIcontext.HELLO_ID, "Hello", "Hello", "Show hello dialog box", "ExecPYHELLO.png" )
        sgPyQt.createMenu( a, mid )
        sgPyQt.createTool( a, tid )
        a = sgPyQt.createSeparator()
        sgPyQt.createMenu( a, mid )
        a = sgPyQt.createAction( GUIcontext.CREATE_OBJECT_ID, "Create object", "Create object", "Create object" )
        sgPyQt.createMenu( a, mid )
        a = sgPyQt.createSeparator()
        sgPyQt.createMenu( a, mid )
        try:
            ag = sgPyQt.createActionGroup( GUIcontext.OPTIONS_ID )
            ag.setText( "Creation mode" )
            ag.setUsesDropDown(True)
            a = sgPyQt.createAction( GUIcontext.OPTION_1_ID, "Default name", "Default name", "Use default name for the objects" )
            a.setCheckable( True )
            ag.add( a )
            a = sgPyQt.createAction( GUIcontext.OPTION_2_ID, "Generate name", "Generate name", "Generate name for the objects" )
            a.setCheckable( True )
            ag.add( a )
            a = sgPyQt.createAction( GUIcontext.OPTION_3_ID, "Ask name", "Ask name", "Request object name from the user" )
            a.setCheckable( True )
            ag.add( a )
            sgPyQt.createMenu( ag, mid )
            sgPyQt.createTool( ag, tid )
            default_mode = sgPyQt.integerSetting( "PYHELLO", "creation_mode", 0 )
            sgPyQt.action( GUIcontext.OPTION_1_ID + default_mode ).setChecked( True )
        except:
            pass
        a = sgPyQt.createSeparator()
        a = sgPyQt.createAction( GUIcontext.PASSWORD_ID, "Display password", "Display password", "Display password" )
        sgPyQt.createMenu( a, mid )
        
        # the following action are used in context popup
        a = sgPyQt.createAction( GUIcontext.DELETE_ALL_ID, "Delete all", "Delete all", "Delete all objects" )
        a = sgPyQt.createAction( GUIcontext.SHOW_ME_ID,    "Show",       "Show",       "Show object name" )
        a = sgPyQt.createAction( GUIcontext.DELETE_ME_ID,  "Delete",     "Delete",     "Remove object" )
        a = sgPyQt.createAction( GUIcontext.RENAME_ME_ID,  "Rename",     "Rename",     "Rename object" )
        pass
    pass

################################################
# Global variables
################################################

# object counter
__objectid__ = 0

################################################
       
# Get SALOME PyQt interface
sgPyQt = SalomePyQt()

# Get SALOME Swig interface
sg = libSALOME_Swig.SALOMEGUI_Swig()

################################################

################################################
# Internal methods
################################################

###
# returns True if object has children
###
def _hasChildren( sobj ):
    if sobj:
        iter  = salome.myStudy.NewChildIterator( sobj )
        while iter.More():
            name = iter.Value().GetName()
            if name:
                return True
            iter.Next()
            pass
        pass
    return False

###
# increment object counter in the map
###
def _incObjToMap( m, id ):
    if id not in m: m[id] = 0
    m[id] += 1
    pass

###
# analyse selection
###
def _getSelection():
    selcount = sg.SelectedCount()
    seltypes = {}
    for i in range( selcount ):
        _incObjToMap( seltypes, getObjectID( sg.getSelected( i ) ) )
        pass
    return selcount, seltypes

################################################
# Callback functions
################################################

# called when module is initialized
# perform initialization actions
def initialize():
    if verbose() : print("PYHELLOGUI.initialize()")
    # set default preferences values
    if not sgPyQt.hasSetting( "PYHELLO", "def_obj_name"):
        sgPyQt.addSetting( "PYHELLO", "def_obj_name", GUIcontext.DEFAULT_NAME )
    if not sgPyQt.hasSetting( "PYHELLO", "creation_mode"):
        sgPyQt.addSetting( "PYHELLO", "creation_mode", 0 )
    if not sgPyQt.hasSetting( "PYHELLO", "Password"):
        sgPyQt.addSetting( "PYHELLO", "Password", GUIcontext.DEFAULT_PASSWD )
    pass

# called when module is initialized
# return map of popup windows to be used by the module
def windows():
    if verbose() : print("PYHELLOGUI.windows()")
    wm = {}
    wm[WT_ObjectBrowser] = Qt.LeftDockWidgetArea
    wm[WT_PyConsole] = Qt.BottomDockWidgetArea
    return wm

# called when module is initialized
# return list of 2d/3d views to be used ny the module
def views():
    if verbose() : print("PYHELLOGUI.views()")
    return []

# called when module is initialized
# export module's preferences
def createPreferences():
    if verbose():
        print("PYHELLOGUI.createPreferences()")
    gid = sgPyQt.addPreference("General")
    gid = sgPyQt.addPreference("Object creation", gid)
    sgPyQt.addPreference("Default name", gid, PT_String, "PYHELLO", "def_obj_name")
    pid = sgPyQt.addPreference("Default creation mode", gid, PT_Selector, "PYHELLO", "creation_mode")
    strings = ["Default name", "Generate name", "Ask name"]
    indexes = [0, 1, 2]
    sgPyQt.setPreferenceProperty(pid, "strings", strings)
    sgPyQt.setPreferenceProperty(pid, "indexes", indexes)
    pid = sgPyQt.addPreference("Password", gid, PT_String, "PYHELLO", "Password")
    sgPyQt.setPreferenceProperty(pid, "echo", 2)
    pass

# called when module is activated
# returns True if activating is successfull and False otherwise
def activate():
    if verbose() : print("PYHELLOGUI.activate()")
    GUIcontext()
    return True

# called when module is deactivated
def deactivate():
    if verbose() : print("PYHELLOGUI.deactivate()")
    pass

# called when popup menu is invoked
# popup menu and menu context are passed as parameters
def createPopupMenu( popup, context ):
    if verbose() : print("PYHELLOGUI.createPopupMenu(): context = %s" % context)
    selcount, selected = _getSelection()
    if verbose() : print(selcount, selected)
    if selcount == 1:
        # one object is selected
        if moduleID() in selected:
            # menu for component
            popup.addAction( sgPyQt.action( GUIcontext.DELETE_ALL_ID ) )
        elif objectID() in selected:
            # menu for object
            popup.addAction( sgPyQt.action( GUIcontext.SHOW_ME_ID ) )
            popup.addAction( sgPyQt.action( GUIcontext.RENAME_ME_ID ) )
            popup.addSeparator()
            popup.addAction( sgPyQt.action( GUIcontext.DELETE_ME_ID ) )
            pass
        pass
    elif selcount > 1:
        # several objects are selected
        if len( selected ) == 1:
            if moduleID() in selected:
                # menu for component
                popup.addAction( sgPyQt.action( GUIcontext.DELETE_ALL_ID ) )
            elif objectID() in selected:
                # menu for list of objects
                popup.addAction( sgPyQt.action( GUIcontext.DELETE_ME_ID ) )
                pass
            pass
        pass
    pass

# called when GUI action is activated
# action ID is passed as parameter
def OnGUIEvent( commandID ):
    if verbose() : print("PYHELLOGUI.OnGUIEvent(): command = %d" % commandID)
    if commandID in dict_command:
        try:
            dict_command[commandID]()
        except:
            traceback.print_exc()
    else:
        if verbose() : print("The command is not implemented: %d" % commandID)
    pass

# called when module's preferences are changed
# preference's resources section and setting name are passed as parameters
def preferenceChanged( section, setting ):
    if verbose() : print("PYHELLOGUI.preferenceChanged(): %s / %s" % ( section, setting ))
    pass

# called when active view is changed
# view ID is passed as parameter
def activeViewChanged( viewID ):
    if verbose() : print("PYHELLOGUI.activeViewChanged(): %d" % viewID)
    pass

# called when active view is cloned
# cloned view ID is passed as parameter
def viewCloned( viewID ):
    if verbose() : print("PYHELLOGUI.viewCloned(): %d" % viewID)
    pass

# called when active view is viewClosed
# view ID is passed as parameter
def viewClosed( viewID ):
    if verbose() : print("PYHELLOGUI.viewClosed(): %d" % viewID)
    pass

# called when study is opened
# returns engine IOR
def engineIOR():
    if verbose() : print("PYHELLOGUI.engineIOR()")
    return getEngineIOR()

# called to check if object can be dragged
# returns True if drag operation is allowed for this object
def isDraggable(what):
    if verbose() : print("PYHELLOGUI.isDraggable()")
    # return True if object is draggable
    return False

# called to check if object allows dropping on it
# returns True if drop operation is allowed for this object
def isDropAccepted(where):
    if verbose() : print("PYHELLOGUI.isDropAccepted()")
    # return True if object accept drops
    return False

# called when drag and drop operation is finished
# performs corresponding data re-arrangement if allowed
def dropObjects(what, where, row, action):
    if verbose() :
        print("PYHELLOGUI.dropObjects()")
        # 'what' is a list of entries of objects being dropped
        for i in what: print("- dropped:", i)
        # 'where' is a parent object's entry
        print("- dropping on:", where)
        # 'row' is an position in the parent's children list;
        # -1 if appending to the end of children list is performed
        print("- dropping position:", row)
        # 'action' is a dropping action being performed:
        # - 0x01 (Qt::CopyAction) for copy
        # - 0x02 (Qt::MoveAction) for move
        print("- drop action:", action)
        pass
    pass

################################################
# GUI actions implementation
################################################

###
# 'HELLO' dialog box
###
class MyDialog( QDialog ):
    # constructor
    def __init__( self, parent = None, modal = 0):
        QDialog.__init__( self, parent )
        self.setObjectName( "MyDialog" )
        self.setModal( modal )
        self.setWindowTitle( "HELLO!" )
        vb = QVBoxLayout( self )
        vb.setContentsMargins( 8, 8, 8, 8 )

        hb0 = QHBoxLayout( self )
        label = QLabel( "Prenom: ", self )
        hb0.addWidget( label )
        self.entry = QLineEdit( self )
        self.entry.setMinimumWidth( 200 )
        hb0.addWidget( self.entry )
        vb.addLayout( hb0 )
        
        hb1 = QHBoxLayout( self )
        bOk = QPushButton( "&OK", self )
        bOk.setIcon( sgPyQt.loadIcon( 'PYHELLO', 'ICO_HANDSHAKE' ) )
        bOk.clicked.connect(self.accept)
        hb1.addWidget( bOk )
        
        hb1.addStretch( 10 )
        
        bCancel = QPushButton( "&Cancel", self )
        bCancel.setIcon( sgPyQt.loadIcon( 'PYHELLO', 'ICO_STOP' ) )
        bCancel.clicked.connect(self.close)
        hb1.addWidget( bCancel )
        vb.addLayout( hb1 )
        pass
    
    # OK button slot
    def accept( self ):
        name = str( self.entry.text() )
        if name != "":
            banner = getEngine().makeBanner( name )
            QMessageBox.information( self, 'Info', banner )
            self.close()
        else:
            QMessageBox.warning( self, 'Error!', 'Please, enter the name!' )
        pass

###
# Show 'HELLO' dialog box
###
def ShowHELLO():
    # create dialog box
    d = MyDialog( sgPyQt.getDesktop(), 1 )
    # show dialog box
    d.exec_()
    pass

###
# Create new object
###
def CreateObject():
    global __objectid__
    default_name = sgPyQt.stringSetting("PYHELLO", "def_obj_name", GUIcontext.DEFAULT_NAME).strip()
    try:
        if sgPyQt.action(GUIcontext.OPTION_3_ID).isChecked():
            # request object name from the user
            name, ok = QInputDialog.getText(sgPyQt.getDesktop(),
                                                      "Create Object",
                                                      "Enter object name:",
                                                      QLineEdit.Normal,
                                                      default_name)
            if not ok:
                return
            name = name.strip()
        elif sgPyQt.action(GUIcontext.OPTION_2_ID).isChecked():
            # generate object name
            __objectid__ = __objectid__ + 1
            name = "%s %d" % (default_name, __objectid__)
        else:
            name = default_name
            pass
        pass
    except Exception as e:
        logger.debug(e)
        # generate object name
        __objectid__ = __objectid__ + 1
        name = "%s %d" % (default_name, __objectid__)
        pass
    if not name:
        return
    getEngine().createObject( name)
    sg.updateObjBrowser()
    pass

###
# Delete all objects
###
def DeleteAll():
    father = salome.myStudy.FindComponent( moduleName() )
    if father:
        iter = salome.myStudy.NewChildIterator( father )
        builder = salome.myStudy.NewBuilder()
        while iter.More():
            sobj = iter.Value()
            iter.Next()
            builder.RemoveObjectWithChildren( sobj )
            pass
        sg.updateObjBrowser()
        pass
    pass

###
# Show object's name
###
def ShowMe():
    entry = sg.getSelected( 0 )
    if entry != '':
        sobj = salome.myStudy.FindObjectID( entry )
        if ( sobj ):
            test, attr = sobj.FindAttribute( "AttributeName" )
            if test:
                QMessageBox.information( sgPyQt.getDesktop(), 'Info', "My name is '%s'" % attr.Value() )
                pass
            pass
        pass
    pass

###
# Delete selected object(s)
###
def Delete():
    builder = salome.myStudy.NewBuilder()
    if sg.SelectedCount() <= 0: return
    for i in range( sg.SelectedCount() ):
        entry = sg.getSelected( i )
        if entry != '':
            sobj = salome.myStudy.FindObjectID( entry )
            if ( sobj ):
                builder.RemoveObject( sobj )
                pass
            pass
        pass
    sg.updateObjBrowser()
    pass

###
# Rename selected object
###
def Rename():
    builder = salome.myStudy.NewBuilder()
    entry = sg.getSelected( 0 )
    if entry != '':
        sobj = salome.myStudy.FindObjectID( entry )
        if ( sobj ):
            name, ok = QInputDialog.getText( sgPyQt.getDesktop(),
                                             "Object name",
                                             "Enter object name:",
                                             QLineEdit.Normal,
                                             sobj.GetName() )
            name = str( name ).strip()
            if not ok or not name: return
            attr = builder.FindOrCreateAttribute( sobj, "AttributeName" )
            attr.SetValue( name )
            sg.updateObjBrowser()
            pass
        pass
    pass

###
# Display password stored in the preferences
###
def Password():
  passwd = str( sgPyQt.stringSetting( "PYHELLO", "Password", GUIcontext.DEFAULT_PASSWD ) ).strip()
  QMessageBox.information(sgPyQt.getDesktop(),
                          "Password",
                          passwd)

###
# Commands dictionary
###
dict_command = {
    GUIcontext.HELLO_ID         : ShowHELLO,
    GUIcontext.CREATE_OBJECT_ID : CreateObject,
    GUIcontext.DELETE_ALL_ID    : DeleteAll,
    GUIcontext.SHOW_ME_ID       : ShowMe,
    GUIcontext.DELETE_ME_ID     : Delete,
    GUIcontext.RENAME_ME_ID     : Rename,
    GUIcontext.PASSWORD_ID      : Password,
    }
