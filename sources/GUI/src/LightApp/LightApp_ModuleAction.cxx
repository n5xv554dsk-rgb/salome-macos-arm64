// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
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

// File   : LightApp_ModuleAction.cxx
// Author : Sergey TELKOV, Vadim SANDLER
//
#include "LightApp_ModuleAction.h"

#include <QtxActionSet.h>
#include <QtxComboBox.h>
#include <QtxResourceMgr.h>
#include <QVBoxLayout>
#include <QApplication>
#include <QEvent>
#include <QMenu>
#include <QSignalMapper>

#include <utilities.h>

// Prevent slot compilation error
#pragma push_macro("slots")
#undef slots
#include "PyInterp_Utils.h"
#pragma pop_macro("slots")

/*!
  \class LightApp_ModuleAction::ActionSet
  \brief Internal class to represent list of modules buttons.
  \internal
*/

class LightApp_ModuleAction::ActionSet : public QtxActionSet
{
public:
  ActionSet( QObject* );
  QAction* moduleAction( const QString& ) const;
  int      moduleId( const QString& ) const;
  int      moduleId( QAction* ) const;
  void     setVisible( bool );
};

/*!
  \brief Constructor.
  \internal
  \param parent parent object
*/
LightApp_ModuleAction::ActionSet::ActionSet( QObject* parent )
: QtxActionSet( parent )
{
}

/*!
  \brief Get action corresponding to the specified module.
  \internal
  \param name module name
  \return module action or 0 if \a name is invalid
*/
QAction* LightApp_ModuleAction::ActionSet::moduleAction( const QString& name ) const
{
  QAction* a = 0;

  QList<QAction*> alist = actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end() && !a; ++it )
  {
    if ( (*it)->text() == name )
      a = *it;
  }

  return a;
}

/*!
  \brief Get module action identifier.
  \internal
  \param name module name
  \return module action ID or -1 if \a name is invalid
*/
int LightApp_ModuleAction::ActionSet::moduleId( const QString& name ) const
{
  int id = -1;

  QList<QAction*> alist = actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end() && id == -1; ++it )
  {
    if ( (*it)->text() == name )
      id = actionId( *it );
  }

  return id;
}

/*!
  \brief Get module action identifier.
  \internal
  \param a module action
  \return module action ID or -1 if \a a is null or invalid
*/
int LightApp_ModuleAction::ActionSet::moduleId( QAction* a ) const
{
  return actionId( a );
}

/*!
  \brief Show/hide modules actions.
  \internal
  \param on new visibility state
*/
void LightApp_ModuleAction::ActionSet::setVisible( bool on )
{
  QList<QAction*> alist = actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end(); ++it )
    (*it)->setVisible( on );

  QtxActionSet::setVisible( on );
}

/*!
  \class LightApp_ModuleAction::ComboAction
  \brief Internal class to represent combo box with the list of modules in the toolbar.
  \internal
*/

/*!
  \brief Constructor.
  \internal
  \param parent parent object
*/
LightApp_ModuleAction::ComboAction::ComboAction( QObject* parent )
: QtxAction( parent )
{
}

/*!
  \brief Get list of associated widgets.
  \internal
  \return list of created widgets (QtxComboBox)
*/
QList<QtxComboBox*> LightApp_ModuleAction::ComboAction::widgets() const
{
  QList<QtxComboBox*> lst;

  QList<QWidget*> wlist = createdWidgets();
  for ( QList<QWidget*>::const_iterator wit = wlist.begin(); wit != wlist.end(); ++wit )
    lst += qobject_cast<QtxComboBox*>(*wit);

  return lst;
}

/*!
  \brief Create combo box widget by request from the toolbar.
  \internal
  \param parent parent widget (should be QToolBar or its successor)
  \return new custom widget, containing combo box
*/
QWidget* LightApp_ModuleAction::ComboAction::createWidget( QWidget* parent )
{
  if ( !parent->inherits( "QToolBar" ) )
    return 0;

  QtxComboBox* cb = new QtxComboBox( parent );
  cb->setSizeAdjustPolicy( QComboBox::AdjustToContents );
  cb->setFocusPolicy( Qt::NoFocus );
  connect( cb, SIGNAL( activatedId( int ) ), this, SIGNAL( activatedId( int ) ) );
  return cb;
}

/*!
  \fn void LightApp_ModuleAction::ComboAction::activatedId( int id );
  \internal
  \brief Emitted when the combo box item is activated
  \param item identifier
*/

/*!
  \class LightApp_ModuleAction::ActivateEvent
  \brief Internal class to represent custom event for transfer the activation item id.
  \internal
*/
class LightApp_ModuleAction::ActivateEvent : public QEvent
{
public:
  ActivateEvent( QEvent::Type type, int id ) : QEvent( type ), myId( id ) {};
  ~ActivateEvent() {};

  int     id() const { return myId; }

private:
  int     myId;
};

/*!
  \class LightApp_ModuleAction
  \brief An action, representing the list of modules to be inserted to the
  toolbar.

  In the toolbar this action is represented as the combo box with the list of
  available modules, and a set of buttons for each module. Additionally, combo box
  contains an item representing "neutral point" of the application (i.e. no active module).

  In menu, the action is represented as a plain list of items, one per module.

  Only one module can be active at the moment. It can be set programmatically
  with setActiveModule() function. Use this method with empty string to turn
  to the "neutral point". To get active module, use activeModule() function.

  When user activates/deactivates a module, the moduleActivated() signal
  is emitted.

  The action also provides an additional separate item "Add modules"; when
  this button is pressed, a adding() signal is emitted. This signal
  can be connected to a dedicated slot aimed to dynamically add a new module
  into the application. In addition, a button "Remove module" shows a dropdown menu
  with the list of user modules; when any item is selected, the removing() signal
  is emitted. This signal may be connected to a slot aimed to dynamically remove
  selected user module from application.

  It is possible to customize which elements to show via the setMode() of setModeEnabled()
  functions. By default, all elements are shown. The following choices are possible:

  - LightApp_ModuleAction::Buttons: show separate items for all modules
  - LightApp_ModuleAction::List: show combo box with list of modules (in toolbar only)
  - LightApp_ModuleAction::AddRemove: show "Add modules" and "Remove modules" items
  - LightApp_ModuleAction::All: show all items
*/

/*!
  \brief Constructor
  \param resMgr resource manager
  \param parent parent object
*/
LightApp_ModuleAction::LightApp_ModuleAction( QtxResourceMgr* resMgr, QObject* parent )
: QtxAction( parent )
{
  setText( tr( "APP_NAME" ) );
  setIcon( resMgr->loadPixmap( "LightApp", tr( "APP_DEFAULT_ICO" ), false ) );
  setVisible( false );

  myMode = All;
  myCombo = new ComboAction( this );
  myAdd = new QtxAction( tr( "ADD_MODULE"),
			 resMgr->loadPixmap( "LightApp", tr( "ICON_ADD_MODULE" ), false ),
			 tr( "ADD_MODULE"),
			 0, this );
  myRemove = new QtxAction( tr( "REMOVE_MODULE"),
			    resMgr->loadPixmap( "LightApp", tr( "ICON_REMOVE_MODULE" ), false ),
			    tr( "REMOVE_MODULE"),
			    0, this );
  myRemove->setEnabled( false );
  myRemove->setMenu( new QMenu() );
  myInfo = new QtxAction( tr( "INFO_MODULE"),
			    resMgr->loadPixmap( "LightApp", tr( "ICON_INFO_MODULE" ), false ),
			    tr( "INFO_MODULE"),
			    0, this );
  mySeparator = new QAction( this );
  mySeparator->setSeparator( true );
  mySet = new ActionSet( this );

  myMapper = new QSignalMapper( this );

  connect( this,     SIGNAL( changed() ),          this, SLOT( onChanged() ) );
  connect( myAdd,    SIGNAL( triggered( bool ) ),  this, SIGNAL( adding() ) );
  connect( myInfo,   SIGNAL( triggered( bool ) ),  this, SIGNAL( showExtInfo() ) );
  connect( mySet,    SIGNAL( triggered( int ) ),   this, SLOT( onTriggered( int ) ) );
  connect( myCombo,  SIGNAL( activatedId( int ) ), this, SLOT( onComboActivated( int ) ) );
  connect( myMapper, SIGNAL( mapped( QString ) ),  this, SIGNAL( removing( QString ) ) );
}

/*!
  \brief Destructor
*/
LightApp_ModuleAction::~LightApp_ModuleAction()
{
}

/*!
  \brief Get number of registered modules.
  \return modules count
*/
int LightApp_ModuleAction::count() const
{
  return modules().count();
}

/*!
  \brief Get list of modules.
  \return modules names list
*/
QStringList LightApp_ModuleAction::modules() const
{
  QStringList lst;

  QList<QAction*> alist = mySet->actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end(); ++it )
    lst.append( (*it)->text() );

  return lst;
}

/*!
  \brief Get module icon.
  \param name module name
  \return module icon
  \sa setModuleIcon()
*/
QIcon LightApp_ModuleAction::moduleIcon( const QString& name ) const
{
  QAction* a = mySet->moduleAction( name );
  return a ? a->icon() : QIcon();
}

/*!
  \brief Set module icon.
  \param name module name
  \param ico new module icon
  \sa moduleIcon()
*/
void LightApp_ModuleAction::setModuleIcon( const QString& name, const QIcon& ico )
{
  QAction* a = mySet->moduleAction( name );
  if ( !a )
    return;

  a->setIcon( ico );
  update();
}

/*!
  \brief Get module action.
  \param name module name
*/
QAction* LightApp_ModuleAction::moduleAction( const QString& name ) const
{
  return mySet->moduleAction( name );
}

/*!
  \brief Add module into the list.
  \param name module name
  \param ico module icon
  \param idx position in the module list (if -1, the module is added to the end of list)
  \sa removeModule()
*/
void LightApp_ModuleAction::insertModule( const QString& name, const QIcon& ico,
                                          const int idx )
{
  insertModule( name, ico, false, idx );
}

/*!
  \brief Add module into the list.
  \param name module name
  \param ico module icon
  \param isCustom \c false to insert regular module, \c true to insert user module
  \param idx position in the module list (if -1, the module is added to the end of list)
  \sa removeModule()
*/
void LightApp_ModuleAction::insertModule( const QString& name, const QIcon& ico,
					  bool isCustom, const int idx)

{
  QtxAction* a = new QtxAction( name, ico, name, 0, this, true );
  a->setStatusTip( tr( "ACTIVATE_MODULE_TOP" ).arg( name ) );
 
  // Commented because the next call mySet->insertAction() overrides it with
  // action id int != 0 value, so test a->data().toBool() is always true after that.
  // Leave it here to mention that we need other approach to mark module as custom.
  // a->setData( isCustom );

  mySet->insertAction( a, -1, idx );
  update();
}

/*!
  \brief Remove module from the list.
  \param name module name
  \sa insertModule()
*/
void LightApp_ModuleAction::removeModule( const QString& name )
{
  MESSAGE("Start to remove module...");

  int id = mySet->moduleId( name );
  SCRUTE(id);
  if ( id == -1 )
  {
    MESSAGE("Can't get a module's id! Return");
    return;
  }

  MESSAGE("Remove action by id...");
  mySet->removeAction(id);

  update();

  MESSAGE("Module was removed");
}

/*!
  \brief Add an installed extension. Now only to the Remove button's menu.
  \param name an extension's name
  \sa removeExtension()
*/
void LightApp_ModuleAction::insertExtension(const QString& name)
{
  MESSAGE("Insert an extension's action...");
  SCRUTE(name.toStdString());

  myRemove->setEnabled(true);

  // Find a place to insert in the alphabetical order
  QAction* insertBefore = nullptr;
  foreach(QAction* curAction, myRemove->menu()->actions())
  {
    int compareRes = QString::compare(curAction->text(), name, Qt::CaseInsensitive);
    if (!compareRes)
    {
      return; // already added
    }
    else if (compareRes > 0)
    {
      insertBefore = curAction;

      SCRUTE(insertBefore->text().toStdString());
      break;
    }
  }

  QAction* inserted = new QAction(name);

  myRemove->menu()->insertAction(insertBefore, inserted);
  connect(inserted, SIGNAL(triggered()), myMapper, SLOT(map()));
  myMapper->setMapping(inserted, name);

  MESSAGE("An extension's action was inserted");
}

/*!
  \brief Remove an installed extension.
  \param name an extension's name
  \sa insertExtension()
*/
void LightApp_ModuleAction::removeExtension(const QString& name)
{
  MESSAGE("Remove an extension's action...");
  SCRUTE(name.toStdString());

  foreach(QAction* ma, myRemove->menu()->actions())
  {
    if (ma->text() == name)
    {
      myRemove->menu()->removeAction(ma);

      MESSAGE("Extension's action was removed");
      break;
    }
  }

  myRemove->setEnabled(!myRemove->menu()->actions().isEmpty());

  updateExtActions();
  update();
}

/*!
  \brief Get active module.

  If there is no active module ("neutral point"), then the null string
  is returned.

  \return active module name
  \sa setActiveModule()
*/
QString LightApp_ModuleAction::activeModule() const
{
  QAction* a = active();
  return a ? a->text() : QString();
}

/*!
  \brief Set active module.

  To turn to the "neutral point" (no active module), pass empty string.

  \param name new active module name
  \sa activeModule()
*/
void LightApp_ModuleAction::setActiveModule( const QString& name )
{
  if ( name == activeModule() )
    return;

  int id = mySet->moduleId( name );
  if ( name.isEmpty() || id != -1 )
    activate( id, false );
}

/*!
  \brief Set action display mode.
  \param mode action display options (combination of flags)
  \sa mode()
*/
void LightApp_ModuleAction::setMode( const LightApp_ModuleAction::Mode& mode )
{
  myMode = mode;
  update();
}

/*!
  \brief Enable / disable action display mode.
  \param mode action display options (combination of flags)
  \param enabled \c true to enable mode, \c false to disable mode
  \sa mode()
*/
void LightApp_ModuleAction::setModeEnabled( const LightApp_ModuleAction::Mode& mode, bool enabled )
{
  if ( enabled )
    myMode |= mode;
  else
    myMode &= ~mode;
  update();
}

/*!
  \brief Get action display mode.
  \param mode action display mode
  \sa setMode()
*/
bool LightApp_ModuleAction::isModeEnabled( const LightApp_ModuleAction::Mode& mode ) const
{
  return (bool)( myMode & mode );
}

/*!
  \brief Called when the action is added to the widget.
  \param w widget (not used)
*/
void LightApp_ModuleAction::addedTo( QWidget* w )
{
  if ( w->inherits( "QToolBar" ) )
    w->insertAction( this, myCombo );
  w->insertAction( this, myAdd );
  w->insertAction( this, myRemove );
  w->insertAction( this, myInfo );
  w->insertAction( this, mySeparator );
  w->insertAction( this, mySet );
  update();
}

/*!
  \brief Remove action from widget.
  \param w widget (menu or toolbar)
  \return \c true if the action is removed successfully and \c false otherwise.
  \sa addTo()
*/
void LightApp_ModuleAction::removedFrom( QWidget* w )
{
  if ( w->inherits( "QToolBar" ) )
    w->removeAction( myCombo );
  w->removeAction( myAdd );
  w->removeAction( myRemove );
  w->removeAction( myInfo );
  w->removeAction( mySeparator );
  w->removeAction( mySet );
}

/*!
  \brief Perform delayed activation with specified id.
  \param e custom event
  \return \c true if the event was processed successfully and \c false otherwise.
*/
bool LightApp_ModuleAction::event( QEvent* e )
{
  if ( e->type() == QEvent::MaxUser ) {
    activate( ((ActivateEvent*)e)->id(), false );
    return true;
  }
  return QtxAction::event( e );
}

/*!
  \fn void LightApp_ModuleAction::moduleActivated( const QString& name );
  \brief Emitted when the module is activated
  \param name module name (empty string for neutral point)
*/

/*!
  \brief Update an action.
  \internal
*/
void LightApp_ModuleAction::update()
{
  QList<QtxComboBox*> lst = myCombo->widgets();
  for ( QList<QtxComboBox*>::const_iterator it = lst.begin(); it != lst.end(); ++it )
    update( *it );


  myCombo->setVisible( myMode & List );
  if ( QString::compare(getenv("SALOME_ON_DEMAND"),"HIDE", Qt::CaseInsensitive) != 0)
  {
    myAdd->setVisible( myMode & AddRemove );
    myRemove->setVisible( myMode & AddRemove );
    myInfo->setVisible( myMode & All );
  }
  else
  {
    myAdd->setVisible(false);
    myRemove->setVisible( false );
    myInfo->setVisible( false );
  }
  mySet->setVisible( myMode & Buttons );
}

/*!
  \brief Update combo box.
  \internal
  \param cb combo box
*/
void LightApp_ModuleAction::update( QtxComboBox* cb )
{
  if ( !cb )
    return;

  bool blocked = cb->blockSignals( true );
  int curId = mySet->moduleId( active() );
  QList<QAction*> alist = mySet->actions();
  cb->clear();

  cb->addItem( icon(), text() );
  cb->setId( 0, -1 );

  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end(); ++it )
  {
    QAction* a = *it;
    int id = mySet->moduleId( a );
    cb->addItem( a->icon(), a->text() );
    cb->setId( cb->count() - 1, id );
  }

  cb->setCurrentId( curId );
  cb->blockSignals( blocked );
}

/*!
  \brief Update extension actions based on dependencies.
  \internal
  \param
*/
void LightApp_ModuleAction::updateExtActions()
{
  MESSAGE("Check dependencies to update extensions actions...");

  // It should be set on the app start
  auto extRootDir = getenv("SALOME_APPLICATION_DIR");
  if (!extRootDir)
  {
    MESSAGE("Cannot get SALOME_APPLICATION_DIR env variable! Cancel adding selected extensions.");
    return;
  }
  SCRUTE(extRootDir);

  // Import Python module that manages SALOME extensions.
  PyLockWrapper lck; // acquire GIL
  PyObjWrapper extensionQuery = PyImport_ImportModule((char*)"SalomeOnDemandTK.extension_query_impl");
  PyObjWrapper extCanRemoveDict = PyObject_CallMethod(extensionQuery, (char*)"ext_canremove_flags", (char*)"s", extRootDir);
  if (!extCanRemoveDict || extCanRemoveDict == Py_None)
  {
    MESSAGE("Couldn't get <ext>:<can_remove> dictionary from SalomeOnDemandTK.extension_query! Return.");
    return;
  }

  // Iterate extensions' actions to disable ones we can't remove because of dependencies.
  foreach(QAction* curAction, myRemove->menu()->actions())
  {
    const std::string action_name = curAction->text().toStdString();
    SCRUTE(action_name);

    PyObject* canRemoveObject = PyDict_GetItemString(extCanRemoveDict, action_name.c_str());
    if (!canRemoveObject)
    {
      MESSAGE("Couldn't get can remove flag from dictionary! Skip.");
      continue;
    }

    const int isTrueRes = PyObject_IsTrue(canRemoveObject);
    if (isTrueRes == -1)
    {
      MESSAGE("PyObject_IsTrue() failed. Using false value instead.");
    }
    const bool canRemove = isTrueRes == 1;
    SCRUTE(canRemove);

    curAction->setEnabled(canRemove);
  }
}

/*!
  \brief Get an action corresponding to the active module.
  \internal
  \return active module action or 0 if there is no active module
*/
QAction* LightApp_ModuleAction::active() const
{
  QAction* a = 0;

  QList<QAction*> alist = mySet->actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end() && !a; ++it )
  {
    if ( (*it)->isChecked() )
      a = *it;
  }

  return a;
}

/*!
  \brief Activate a module item.
  \internal
  \param id module identifier
  \param fromAction \c true if function is called from the module button
*/
void LightApp_ModuleAction::activate( int id, bool fromAction )
{
  bool checked = false;

  QList<QAction*> alist = mySet->actions();
  for ( QList<QAction*>::const_iterator it = alist.begin(); it != alist.end(); ++it )
  {
    if ( mySet->moduleId( *it ) != id ) {
      (*it)->setChecked( false );
    }
    else {
      if ( !fromAction )
        (*it)->setChecked( true );
      checked = (*it)->isChecked();
    }
  }

  QList<QtxComboBox*> widgets = myCombo->widgets();
  for ( QList<QtxComboBox*>::const_iterator wit = widgets.begin(); wit != widgets.end(); ++wit )
  {
    QtxComboBox* cb = *wit;
    bool blocked = cb->signalsBlocked();
    cb->blockSignals( true );
    cb->setCurrentId( checked ? id : -1 );
    cb->blockSignals( blocked );
  }

  emit moduleActivated( activeModule() );
}

/*!
  \brief Called when module button is triggered.
  \internal
  \param id module identifier
*/
void LightApp_ModuleAction::onTriggered( int id )
{
  activate( id );
}

/*!
  \brief Called when action state is changed.
  \internal

  This slot is used to prevent making the parent action visible.
*/
void LightApp_ModuleAction::onChanged()
{
  if ( !isVisible() )
    return;

  bool block = signalsBlocked();
  blockSignals( true );
  setVisible( false );
  blockSignals( block );
}

/*!
  \brief Called when combo box item is activated.
  \param id module identifier
*/
void LightApp_ModuleAction::onComboActivated( int id )
{
  QApplication::postEvent( this, new ActivateEvent( QEvent::MaxUser, id ) );
}
