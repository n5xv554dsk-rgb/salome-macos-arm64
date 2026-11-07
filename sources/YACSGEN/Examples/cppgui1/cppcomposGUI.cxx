// Copyright (C) 2009-2026  EDF
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
//
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

#include "cppcomposGUI.h"
#include <SUIT_MessageBox.h>
#include <SUIT_ResourceMgr.h>
#include <SUIT_Desktop.h>
#include <SUIT_Study.h>
#include <SalomeApp_Application.h>
#include <SALOME_LifeCycleCORBA.hxx>
#include <SALOME_KernelServices.hxx>

#include <SALOMEconfig.h>
#include CORBA_CLIENT_HEADER(cppcompos)
#include CORBA_CLIENT_HEADER(SALOMEDS)
#include CORBA_CLIENT_HEADER(SALOMEDS_Attributes)

// QT Includes
#include <QInputDialog>
#include <QIcon>

// Export the module
extern "C" {
  CAM_Module* createModule()
  {
    return new cppcomposGUI();
  }
}

// Constructor
cppcomposGUI::cppcomposGUI() :
  SalomeApp_Module( "cppcompos" ) // default name
{
}

static cppcompos_ORB::cppcompos_var engine;

// Module's initialization
void cppcomposGUI::initialize( CAM_Application* app )
{

  SalomeApp_Module::initialize( app );

  Engines::EngineComponent_var comp = dynamic_cast<SalomeApp_Application*>(app)->lcc()->FindOrLoad_Component( "FactoryServer","cppcompos" );
  engine = cppcompos_ORB::cppcompos::_narrow(comp);

  QWidget* aParent = application()->desktop();
  SUIT_ResourceMgr* aResourceMgr = app->resourceMgr();

  // create actions
  QPixmap aPixmap = aResourceMgr->loadPixmap( "cppcompos","exec.png" );
  createAction( 901, "Banner", QIcon( aPixmap ), "Banner", "Banner", 0, aParent, false, this, SLOT( OnGetBanner() ) );
  createAction( 902, "Designer", QIcon( aPixmap ), "Designer", "Designer", 0, aParent, false, this, SLOT( OnDesigner() ) );

  // create menus
  int aMenuId;
  aMenuId = createMenu( "cppcompos", -1, -1, 30 );
  createMenu( 901, aMenuId, 10 );

  // create toolbars
  int aToolId = createTool ( "cppcompos" );
  createTool( 901, aToolId );
  createTool( 902, aToolId );
}

// Get compatible dockable windows.
void cppcomposGUI::windows( QMap<int, int>& theMap ) const
{
  theMap.clear();
  theMap.insert( SalomeApp_Application::WT_ObjectBrowser, Qt::LeftDockWidgetArea );
  theMap.insert( SalomeApp_Application::WT_PyConsole,     Qt::BottomDockWidgetArea );
}

// Module's engine IOR
QString cppcomposGUI::engineIOR() const
{
  return "bidon";
}

// Module's activation
bool cppcomposGUI::activateModule( SUIT_Study* theStudy )
{
  bool bOk = SalomeApp_Module::activateModule( theStudy );

  setMenuShown( true );
  setToolShown( true );

  SALOMEDS::Study_var aDSStudy = KERNEL::getStudyServant();

  SALOMEDS::SComponent_var aFather = aDSStudy->FindComponent("cppcompos");
  if (aFather->_is_nil())
    {
      SALOMEDS::StudyBuilder_var aStudyBuilder = aDSStudy->NewBuilder();
      aFather = aStudyBuilder->NewComponent("cppcompos");
      SALOMEDS::GenericAttribute_var anAttr = aStudyBuilder->FindOrCreateAttribute(aFather, "AttributeName");
      SALOMEDS::AttributeName_var aName = SALOMEDS::AttributeName::_narrow(anAttr);
      aName->SetValue("cppcompos");
      aName->UnRegister();
      aStudyBuilder->DefineComponentInstance(aFather, engine);
    }
  CORBA::Boolean valid;
  engine->DumpPython(1,0,valid);

  return bOk;
}

// Module's deactivation
bool cppcomposGUI::deactivateModule( SUIT_Study* theStudy )
{
  setMenuShown( false );
  setToolShown( false );

  return SalomeApp_Module::deactivateModule( theStudy );
}

// Action slot
void cppcomposGUI::OnGetBanner()
{
  // Dialog to get the Name
  bool ok = false;
  QString myName = QInputDialog::getText( getApp()->desktop(), "label", "name", QLineEdit::Normal, QString::null, &ok );

  if ( ok && !myName.isEmpty()) 
  {
    ::CORBA::Double c;
    engine->s1(1.,2.,c);
    std::cerr << c << std::endl;
    QString banner = "Hello " + myName;
    SUIT_MessageBox::information( getApp()->desktop(), "info", banner, "OK" );
  }
}

// Action slot
void cppcomposGUI::OnDesigner()
{
  QWidget* wid= new MyDemo(getApp()->desktop());
  wid->show();
}

MyDemo::MyDemo(QWidget *parent)
        :QDialog(parent)
{
  ui.setupUi(this);
}
