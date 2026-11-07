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

try:
  from string import Template
except:
  from module_generator.compat import Template,set

hxxgui_cxx="""
#include "${component_name}GUI.h"

#include <SUIT_MessageBox.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_Desktop.h>
#include <SUIT_Session.h>
#include <SalomeApp_Application.h>
#include <LightApp_Preferences.h>

#include <SALOME_LifeCycleCORBA.hxx>
#include <utilities.h>

#define COMPONENT_NAME "${component_name}"

using namespace std;

// Constructor
${component_name}GUI::${component_name}GUI() :
  SalomeApp_Module( COMPONENT_NAME ) // Module name
{
  // Initializations
  default_bool = false;
  default_int = 0;
  default_spinInt = 0;
  default_spinDbl = 0.;
  default_selection = QString("");
  
  // List for the selector
  selector_strings.clear();
  selector_strings.append( tr( "PREF_LIST_TEXT_0" ) );
  selector_strings.append( tr( "PREF_LIST_TEXT_1" ) );
  selector_strings.append( tr( "PREF_LIST_TEXT_2" ) );
}

// Gets a reference to the module's engine
${component_name}_ORB::${component_name}_Gen_ptr ${component_name}GUI::Init${component_name}Gen( SalomeApp_Application* app )
{
  Engines::EngineComponent_var comp = app->lcc()->FindOrLoad_Component( "FactoryServer",COMPONENT_NAME );
  ${component_name}_ORB::${component_name}_Gen_ptr clr = ${component_name}_ORB::${component_name}_Gen::_narrow(comp);
  ASSERT(!CORBA::is_nil(clr));
  return clr;
}

// Module's initialization
void ${component_name}GUI::initialize( CAM_Application* app )
{
  // Get handle to Application, Desktop and Resource Manager
  SalomeApp_Module::initialize( app );

  Init${component_name}Gen( dynamic_cast<SalomeApp_Application*>( app ) );

  QWidget* aParent = app->desktop();
  
  SUIT_ResourceMgr* aResourceMgr = application()->resourceMgr();
  
  // GUI items
  // --> Create actions: 190 is linked to item in "File" menu 
  //     and 901 is linked to both specific menu and toolbar
  createAction( 190, tr( "TLT_MY_NEW_ITEM" ), QIcon(), tr( "MEN_MY_NEW_ITEM" ), tr( "STS_MY_NEW_ITEM" ), 0, aParent, false,
		this, SLOT( OnMyNewItem() ) );

  QPixmap aPixmap = aResourceMgr->loadPixmap( COMPONENT_NAME,tr( "ICON_${component_name}" ) );
  createAction( 901, tr( "TLT_${component_name}_ACTION" ), QIcon( aPixmap ), tr( "MEN_${component_name}_ACTION" ), tr( "STS_${component_name}_ACTION" ), 0, aParent, false,
		this, SLOT( OnCallAction() ) );

  // --> Create item in "File" menu
  int aMenuId;
  aMenuId = createMenu( tr( "MEN_FILE" ), -1, -1 );
  createMenu( separator(), aMenuId, -1, 10 );
  aMenuId = createMenu( tr( "MEN_FILE_${component_name}" ), aMenuId, -1, 10 );
  createMenu( 190, aMenuId );

  // --> Create specific menu
  aMenuId = createMenu( tr( "MEN_${component_name}" ), -1, -1, 30 );
  createMenu( 901, aMenuId, 10 );

  // --> Create toolbar item
  int aToolId = createTool ( tr( "TOOL_${component_name}" ) );
  createTool( 901, aToolId );
}

// Module's engine IOR
QString ${component_name}GUI::engineIOR() const
{
  CORBA::String_var anIOR = getApp()->orb()->object_to_string( Init${component_name}Gen( getApp() ) );
  return QString( anIOR.in() );
}

// Module's activation
bool ${component_name}GUI::activateModule( SUIT_Study* theStudy )
{
  bool bOk = SalomeApp_Module::activateModule( theStudy );

  setMenuShown( true );
  setToolShown( true );

  return bOk;
}

// Module's deactivation
bool ${component_name}GUI::deactivateModule( SUIT_Study* theStudy )
{
  setMenuShown( false );
  setToolShown( false );

  return SalomeApp_Module::deactivateModule( theStudy );
}

// Default windows
void ${component_name}GUI::windows( QMap<int, int>& theMap ) const
{
  theMap.clear();
  theMap.insert( SalomeApp_Application::WT_ObjectBrowser, Qt::LeftDockWidgetArea );
  theMap.insert( SalomeApp_Application::WT_PyConsole,     Qt::BottomDockWidgetArea );
}

// Action slot: Launched with action 190
void ${component_name}GUI::OnMyNewItem()
{
  SUIT_MessageBox::warning( getApp()->desktop(),tr( "INF_${component_name}_TITLE" ), tr( "INF_${component_name}_TEXT" ), tr( "BUT_OK" ) );
}

// Action slot: Launched with action 901
void ${component_name}GUI::OnCallAction()
{
  // Create a ${component_name} component
  ${component_name}_ORB::${component_name}_Gen_ptr ${component_name}gen = ${component_name}GUI::Init${component_name}Gen( getApp() );
  
  // Do the job...
  //
  // ${component_name}gen->method( arg1, arg2, ... );
  
  // Open a dialog showing Preferences values (just to display something)
  
  // ****** Direct access to preferences: implementation at 12/12/05 ******
  // Comment out this section when "preferencesChanged" called back
  SUIT_ResourceMgr* mgr = SUIT_Session::session()->resourceMgr();
  
  default_bool = mgr->booleanValue(COMPONENT_NAME, "default_bool", false);

  default_int = mgr->integerValue(COMPONENT_NAME, "default_integer", 3);

  default_spinInt = mgr->integerValue(COMPONENT_NAME, "default_spinint", 4);

  default_spinDbl = mgr->doubleValue(COMPONENT_NAME, "default_spindbl", 4.5);

  int selectorIndex = mgr->integerValue(COMPONENT_NAME, "default_selector");
  default_selection = (0<=selectorIndex && selectorIndex<=selector_strings.count() ? selector_strings[selectorIndex]: QString("None"));
  // ****** End of section to be commented out ******
  
  QString SUC = ( default_bool ? QString( tr ("INF_${component_name}_CHECK") ) : QString( tr("INF_${component_name}_UNCHECK") ) ) ;
    
  QString textResult = QString( tr( "RES_${component_name}_TEXT" ) ).arg(SUC).arg(default_int).arg(default_spinInt).arg(default_spinDbl).arg(default_selection);
  SUIT_MessageBox::information( getApp()->desktop(), tr( "RES_${component_name}_TITLE" ), textResult, tr( "BUT_OK" ) );
}

void ${component_name}GUI::createPreferences()
{
  // A sample preference dialog
  
  // One only tab
  int genTab = addPreference( tr( "PREF_TAB_GENERAL" ) );

  // One only group
  int defaultsGroup = addPreference( tr( "PREF_GROUP_DEFAULTS" ), genTab );
  
  // A checkbox
  addPreference( tr( "PREF_DEFAULT_BOOL" ), defaultsGroup, LightApp_Preferences::Bool, COMPONENT_NAME, "default_bool" );
  
  // An entry for integer
  addPreference( tr( "PREF_DEFAULT_INTEGER" ), defaultsGroup, LightApp_Preferences::Integer, COMPONENT_NAME, "default_integer" );

  // An integer changed by spinbox
  int spinInt = addPreference( tr( "PREF_DEFAULT_SPININT" ), defaultsGroup, LightApp_Preferences::IntSpin, COMPONENT_NAME, "default_spinint" );
  setPreferenceProperty( spinInt, "min", 0 );
  setPreferenceProperty( spinInt, "max", 20 );
  setPreferenceProperty( spinInt, "step", 2 );

  // A Double changed by spinbox
  int spinDbl = addPreference( tr( "PREF_DEFAULT_SPINDBL" ), defaultsGroup, LightApp_Preferences::DblSpin, COMPONENT_NAME, "default_spindbl" );
  setPreferenceProperty( spinDbl, "min", 1 );
  setPreferenceProperty( spinDbl, "max", 10 );
  setPreferenceProperty( spinDbl, "step", 0.1 );

  // A choice in a list
  int options = addPreference( tr( "PREF_DEFAULT_SELECTOR" ), defaultsGroup, LightApp_Preferences::Selector, COMPONENT_NAME, "default_selector" );
  QList<QVariant> indices;
  indices.append( 0 );
  indices.append( 1 );
  indices.append( 2 );
  setPreferenceProperty( options, "strings", selector_strings );
  setPreferenceProperty( options, "indexes", indices );
}

void ${component_name}GUI::preferencesChanged( const QString& sect, const QString& name )
{
// ****** This is normal way: Not yet called back at 12/12/05 ******
  SUIT_ResourceMgr* mgr = SUIT_Session::session()->resourceMgr();
  if( sect==COMPONENT_NAME )
  {
    if( name=="default_bool" )
	default_bool = mgr->booleanValue(COMPONENT_NAME, "default_bool", false);
    if( name=="default_integer" )
	default_int = mgr->integerValue(COMPONENT_NAME, "default_integer", 3);
    if( name=="default_spinint" )
	default_spinInt = mgr->integerValue(COMPONENT_NAME, "default_spinint", 4);
    if( name=="default_spindbl" )
	default_spinDbl = mgr->doubleValue(COMPONENT_NAME, "default_spindbl", 4.5);
    if( name=="default_selector" )
    {
  	int selectorIndex = mgr->integerValue(COMPONENT_NAME, "default_selector");
  	default_selection = (0<=selectorIndex && selectorIndex<=selector_strings.count() ? selector_strings[selectorIndex]: QString("None"));
    }
  }
}

// Export the module
extern "C" {
  CAM_Module* createModule()
  {
    return new ${component_name}GUI();
  }
}
"""
hxxgui_cxx=Template(hxxgui_cxx)

hxxgui_h="""
#ifndef _${component_name}GUI_H_
#define _${component_name}GUI_H_

#include <SalomeApp_Module.h>

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(${component_name})

class SalomeApp_Application;
class ${component_name}GUI: public SalomeApp_Module
{
  Q_OBJECT

public:
  ${component_name}GUI();

  void    initialize( CAM_Application* );
  QString engineIOR() const;
  void    windows( QMap<int, int>& ) const;

  static ${component_name}_ORB::${component_name}_Gen_ptr Init${component_name}Gen( SalomeApp_Application* );

  virtual void                createPreferences();
  virtual void                preferencesChanged( const QString&, const QString& );

public slots:
  bool    deactivateModule( SUIT_Study* );
  bool    activateModule( SUIT_Study* );

protected slots:
  void            OnMyNewItem();
  void            OnCallAction();

private:
  bool default_bool;
  int default_int;
  int default_spinInt;
  double default_spinDbl;
  QString default_selection;
  
  QStringList selector_strings;
  
};

#endif
"""
hxxgui_h=Template(hxxgui_h)
hxxgui_icon_ts="""
<!DOCTYPE TS>
<TS version="1.1" >
    <context>
        <name>@default</name>
        <message>
            <source>ICON_${component_name}</source>
            <translation>Exec${component_name}.png</translation>
        </message>
    </context>
</TS>
"""
hxxgui_icon_ts=Template(hxxgui_icon_ts)
hxxgui_message_en="""
<!DOCTYPE TS>
<TS version="1.1" >
    <context>
        <name>@default</name>
        <message>
            <source>TLT_MY_NEW_ITEM</source>
            <translation>A ${component_name} owned menu item</translation>
        </message>
        <message>
            <source>MEN_MY_NEW_ITEM</source>
            <translation>My menu</translation>
        </message>
        <message>
            <source>STS_MY_NEW_ITEM</source>
            <translation>Display a simple dialog</translation>
        </message>
        <message>
            <source>TLT_${component_name}_ACTION</source>
            <translation>Open ${component_name} dialog</translation>
        </message>
        <message>
            <source>MEN_FILE</source>
            <translation>File</translation>
        </message>
        <message>
            <source>MEN_FILE_${component_name}</source>
            <translation>${component_name} menu</translation>
        </message>
        <message>
            <source>MEN_${component_name}</source>
            <translation>${component_name}</translation>
        </message>
        <message>
            <source>TOOL_${component_name}</source>
            <translation>${component_name}</translation>
        </message>
    </context>
    <context>
        <name>${component_name}GUI</name>
        <message>
            <source>BUT_OK</source>
            <translation>OK</translation>
        </message>
        <message>
            <source>BUT_CANCEL</source>
            <translation>Cancel</translation>
        </message>
        <message>
            <source>INF_${component_name}_TITLE</source>
            <translation>${component_name} Information</translation>
        </message>
        <message>
            <source>INF_${component_name}_TEXT</source>
            <translation>This is just a test</translation>
        </message>
        <message>
            <source>INF_${component_name}_CHECK</source>
            <translation>checked</translation>
        </message>
        <message>
            <source>INF_${component_name}_UNCHECK</source>
            <translation>Unchecked</translation>
        </message>
        <message>
            <source>RES_${component_name}_TITLE</source>
            <translation>Sample ${component_name} dialog</translation>
        </message>
        <message>
            <source>RES_${component_name}_TEXT</source>
            <translation>Preferences are: \n\tCheckbox: %1\n\tInteger: %2\n\tInteger2: %3\n\tDouble: %4\n\tText: %5</translation>
        </message>
        <message>
            <source>PREF_TAB_GENERAL</source>
            <translation>General</translation>
        </message>
        <message>
            <source>PREF_GROUP_DEFAULTS</source>
            <translation>Default Values</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_BOOL</source>
            <translation>Check me</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_INTEGER</source>
            <translation>Enter an integer :</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SPININT</source>
            <translation>Click arrows (integer) :</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SPINDBL</source>
            <translation>Click arrows (double)</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SELECTOR</source>
            <translation>Select an option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_0</source>
            <translation>first option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_1</source>
            <translation>second option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_2</source>
            <translation>third option</translation>
        </message>
    </context>
</TS>
"""
hxxgui_message_en=Template(hxxgui_message_en)
hxxgui_message_fr="""
<!DOCTYPE TS>
<TS version="1.1" >
    <context>
        <name>@default</name>
        <message>
            <source>TLT_MY_NEW_ITEM</source>
            <translation>Un article de menu propre a ${component_name}</translation>
        </message>
        <message>
            <source>MEN_MY_NEW_ITEM</source>
            <translation>Mon menu</translation>
        </message>
        <message>
            <source>STS_MY_NEW_ITEM</source>
            <translation>Affiche une boite de dialogue simple</translation>
        </message>
        <message>
            <source>TLT_${component_name}_ACTION</source>
            <translation>Ouvre la boite de dialogue de ${component_name}</translation>
        </message>
        <message>
            <source>MEN_FILE</source>
            <translation>File</translation>
        </message>
        <message>
            <source>MEN_FILE_${component_name}</source>
            <translation>Menu de ${component_name}</translation>
        </message>
        <message>
            <source>MEN_${component_name}</source>
            <translation>${component_name}</translation>
        </message>
        <message>
            <source>TOOL_${component_name}</source>
            <translation>${component_name}</translation>
        </message>
    </context>
    <context>
        <name>${component_name}GUI</name>
        <message>
            <source>BUT_OK</source>
            <translation>OK</translation>
        </message>
        <message>
            <source>BUT_CANCEL</source>
            <translation>Annuler</translation>
        </message>
        <message>
            <source>INF_${component_name}_TITLE</source>
            <translation>Information ${component_name}</translation>
        </message>
        <message>
            <source>INF_${component_name}_TEXT</source>
            <translation>Ceci est un simple test</translation>
        </message>
        <message>
            <source>INF_${component_name}_CHECK</source>
            <translation>coche</translation>
        </message>
        <message>
            <source>INF_${component_name}_UNCHECK</source>
            <translation>decoche</translation>
        </message>
        <message>
            <source>RES_${component_name}_TITLE</source>
            <translation>Dialogue example de ${component_name}</translation>
        </message>
        <message>
            <source>RES_${component_name}_TEXT</source>
            <translation>Les preferences sont : \n\tCase a cocher : %1\n\tEntier : %2\n\tEntier2 : %3\n\tDouble : %4\n\tTexte : %5</translation>
        </message>
        <message>
            <source>PREF_TAB_GENERAL</source>
            <translation>General</translation>
        </message>
        <message>
            <source>PREF_GROUP_DEFAULTS</source>
            <translation>valeur par defaut</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_BOOL</source>
            <translation>Cochez-moi</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_INTEGER</source>
            <translation>Entrez un entier :</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SPININT</source>
            <translation>cliquez sur les fleches (entier)</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SPINDBL</source>
            <translation>cliquez sur les fleches (double)</translation>
        </message>
        <message>
            <source>PREF_DEFAULT_SELECTOR</source>
            <translation>Choisissez une option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_0</source>
            <translation>premiere option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_1</source>
            <translation>deuxieme option</translation>
        </message>
        <message>
            <source>PREF_LIST_TEXT_2</source>
            <translation>troisieme option</translation>
        </message>
    </context>
</TS>
"""
hxxgui_message_fr=Template(hxxgui_message_fr)
hxxgui_config="""
language=en
"""
hxxgui_config=Template(hxxgui_config)
hxxgui_xml_en="""
<?xml version='1.0' encoding='us-ascii'?>
<!DOCTYPE application PUBLIC "" "desktop.dtd">
<application title="${component_name} component" date="9/12/2001" author="C Caremoli" appId="${component_name}" >
<desktop>
<!-- ### MENUBAR ###  -->
<menubar>

 <menu-item label-id="File" item-id="1" pos-id="">
  <submenu label-id="Hello" item-id="19" pos-id="9">
   <popup-item item-id="190" pos-id="" label-id="MyNewItem" icon-id="" tooltip-id="" accel-id="" toggle-id="" execute-action=""/>
  </submenu>
  <endsubmenu />
 </menu-item>

 <menu-item label-id="${component_name}" item-id="90" pos-id="3">
  <popup-item item-id="901" label-id="Get banner" icon-id="" tooltip-id="Get ${component_name} banner" accel-id="" toggle-id="" execute-action=""/>

 </menu-item>
</menubar>
<!-- ### TOOLBAR ###  -->
<toolbar label-id="${component_name}">
 <toolbutton-item item-id="901" label-id="Get banner" icon-id="Exec${component_name}.png" tooltip-id="Get ${component_name} banner" accel-id="" toggle-id="" execute-action=""/>
</toolbar>
</desktop>
</application>
"""
hxxgui_xml_en=Template(hxxgui_xml_en)
hxxgui_xml_fr="""
<?xml version='1.0' encoding='us-ascii'?>
<!DOCTYPE application PUBLIC "" "desktop.dtd">
<application title="${component_name} component" date="9/12/2001" author="C Caremoli" appId="${component_name}" >
<desktop>
<!-- ### MENUBAR ###  -->
<menubar>
 <menu-item label-id="File" item-id="1" pos-id="">
  <submenu label-id="Hello" item-id="19" pos-id="9">
   <popup-item item-id="190" pos-id="" label-id="MyNewItem" icon-id="" tooltip-id="" accel-id="" toggle-id="" execute-action=""/>
  </submenu>
  <endsubmenu />
 </menu-item>
 <menu-item label-id="${component_name}" item-id="90" pos-id="3">
  <popup-item item-id="941" label-id="Lancer IHM" icon-id="" tooltip-id="Lancer IHM ${component_name}" accel-id="" toggle-id="" execute-action=""/>
 </menu-item>
</menubar>
<!-- ### TOOLBAR ###  -->
<toolbar label-id="${component_name}">
 <toolbutton-item item-id="941" label-id="Lancer IHM" icon-id="Exec${component_name}.png" tooltip-id="Lancer IHM ${component_name}" accel-id="" toggle-id="" execute-action=""/>
</toolbar>
</desktop>
</application>
"""
hxxgui_xml_fr=Template(hxxgui_xml_fr)

