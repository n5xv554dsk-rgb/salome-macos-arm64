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
#include <SUIT_ViewWindow.h>
#include <SUIT_ViewManager.h>
#include <SalomeApp_Application.h>

#include <SALOMEconfig.h>

// QT Includes
#include <QInputDialog>
#include <QIcon>
#include <QLabel>

// Export the module
extern "C" {
  CAM_Module* createModule()
  {
    return new cppcomposGUI();
  }
}

// Constructor
cppcomposGUI::cppcomposGUI() :
  LightApp_Module( "cppcompos" ) // default name
{
}

//static cppcompos_ORB::cppcompos_var engine;

// Module's initialization
void cppcomposGUI::initialize( CAM_Application* app )
{

  LightApp_Module::initialize( app );

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
  
  _myWidget = new QLabel("My module!", aParent);
  _myViewManager = getApp()->createViewManager("cppcompos", _myWidget);
  _myViewManager->getActiveView()->setClosable( false );
  if(app->desktop() )
     connect( app->desktop(), SIGNAL( windowActivated( SUIT_ViewWindow* ) ),
              this, SLOT(onWindowActivated( SUIT_ViewWindow* )) );
    
}

// Get compatible dockable windows.
void cppcomposGUI::windows( QMap<int, int>& theMap ) const
{
  theMap.clear();
//  theMap.insert( SalomeApp_Application::WT_ObjectBrowser, Qt::LeftDockWidgetArea );
//  theMap.insert( SalomeApp_Application::WT_PyConsole,     Qt::BottomDockWidgetArea );
}

// Module's activation
bool cppcomposGUI::activateModule( SUIT_Study* theStudy )
{
  bool bOk = LightApp_Module::activateModule( theStudy );

  if(bOk)
  {
    setMenuShown( true );
    setToolShown( true );
    _myViewManager->setShown(true);
    _myWidget->setVisible(true);
    _myViewManager->getActiveView()->setFocus();
  }
  return bOk;
}

// Module's deactivation
bool cppcomposGUI::deactivateModule( SUIT_Study* theStudy )
{
  setMenuShown( false );
  setToolShown( false );
  _myWidget->setVisible(false);
  _myViewManager->setShown(false);

  return LightApp_Module::deactivateModule( theStudy );
}

void cppcomposGUI::onWindowActivated( SUIT_ViewWindow* svw)
{
  if(_myViewManager->getActiveView()->getId() == svw->getId())
    if (!getApp()->activeModule() ||
        getApp()->activeModule()->moduleName() != "cppcompos")
      getApp()->activateModule("cppcompos");
}

// Action slot
void cppcomposGUI::OnGetBanner()
{
  // Dialog to get the Name
  bool ok = false;
  QString myName = QInputDialog::getText( getApp()->desktop(), "label", "name", QLineEdit::Normal, QString::null, &ok );

  if ( ok && !myName.isEmpty()) 
  {
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
