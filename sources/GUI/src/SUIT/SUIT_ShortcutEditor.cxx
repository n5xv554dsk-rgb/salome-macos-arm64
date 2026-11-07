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

#include "SUIT_ShortcutEditor.h"
#include "Tools/SUIT_extensions.h"

#include <QWidget>
#include <QLayout>
#include <QList>
#include <QMap>

#include <QToolButton>
#include <QLineEdit>
#include <QLabel>
#include <QTableWidgetItem>
#include <QTextEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QBrush>
#include <QColor>
#include <QHeaderView>

#include <QKeyEvent>
#include <QKeySequence>
#include <QCollator>

#include <algorithm>
#include <stdexcept>


SUIT_KeySequenceEdit::SUIT_KeySequenceEdit(QWidget* parent)
: QFrame(parent)
{
  initialize();
  myKeySequenceLineEdit->installEventFilter(this);
}

void SUIT_KeySequenceEdit::setConfirmedKeySequence(const QKeySequence& theKeySequence)
{
  myConfirmedKeySequenceString = theKeySequence.toString();
  myKeySequenceLineEdit->setText(myConfirmedKeySequenceString);
  myPrevKeySequenceString = myConfirmedKeySequenceString;
}

void SUIT_KeySequenceEdit::setEditedKeySequence(const QKeySequence& theKeySequence)
{
  const QString keySequenceString = theKeySequence.toString();
  myKeySequenceLineEdit->setText(keySequenceString);
  myPrevKeySequenceString = keySequenceString;
}

QKeySequence SUIT_KeySequenceEdit::editedKeySequence() const
{
  return QKeySequence::fromString(myKeySequenceLineEdit->text());
}

bool SUIT_KeySequenceEdit::isKeySequenceModified() const
{
  return QKeySequence(myConfirmedKeySequenceString) != editedKeySequence();
}

void SUIT_KeySequenceEdit::restoreKeySequence()
{
  myKeySequenceLineEdit->setText(myConfirmedKeySequenceString);
  myPrevKeySequenceString = myConfirmedKeySequenceString;
}

/*static*/ QString SUIT_KeySequenceEdit::parseEvent(QKeyEvent* e)
{
  bool isShiftPressed = e->modifiers() & Qt::ShiftModifier;
  bool isControlPressed = e->modifiers() & Qt::ControlModifier;
  bool isAltPressed = e->modifiers() & Qt::AltModifier;
  bool isMetaPressed = e->modifiers() & Qt::MetaModifier;
  bool isModifiersPressed = isControlPressed || isAltPressed || isMetaPressed; // Do not treat Shift alone as a modifier!
  int result=0;
  if(isControlPressed)
    result += Qt::CTRL;
  if(isAltPressed)
    result += Qt::ALT;
  if(isShiftPressed)
    result += Qt::SHIFT;
  if(isMetaPressed)
    result += Qt::META;

  int aKey = e->key();
  if ((isValidKey(aKey) && isModifiersPressed) || ((aKey >= Qt::Key_F1) && (aKey <= Qt::Key_F12)) || aKey == Qt::Key_Delete)
    result += aKey;

  return QKeySequence(result).toString();
}

/*static*/ bool SUIT_KeySequenceEdit::isValidKey(int theKey)
{
  if ( theKey == Qt::Key_Underscore || theKey == Qt::Key_Escape ||
     ( theKey >= Qt::Key_Backspace && theKey <= Qt::Key_Delete ) ||
     ( theKey >= Qt::Key_Home && theKey <= Qt::Key_PageDown ) ||
     ( theKey >= Qt::Key_F1 && theKey <= Qt::Key_F12 )  ||
     ( theKey >= Qt::Key_Space && theKey <= Qt::Key_Asterisk ) ||
     ( theKey >= Qt::Key_Comma && theKey <= Qt::Key_AsciiTilde ) )
    return true;
  return false;
}

void SUIT_KeySequenceEdit::onClear()
{
  myKeySequenceLineEdit->setText("");
  myPrevKeySequenceString = "";
  emit editingFinished();
}

void SUIT_KeySequenceEdit::onEditingFinished()
{
  if (myKeySequenceLineEdit->text().endsWith("+"))
    myKeySequenceLineEdit->setText(myPrevKeySequenceString);
  else
    myPrevKeySequenceString = myKeySequenceLineEdit->text();
    emit editingFinished();
}

bool SUIT_KeySequenceEdit::eventFilter(QObject* theObject, QEvent* theEvent)
{
  if (theObject == myKeySequenceLineEdit) {
    if (theEvent->type() == QEvent::KeyPress) {
      QKeyEvent* keyEvent = static_cast<QKeyEvent*>(theEvent);
      QString text = parseEvent(keyEvent);
      if (keyEvent->key() == Qt::Key_Delete || keyEvent->key() == Qt::Key_Backspace)
        myKeySequenceLineEdit->setText("");
      if (!text.isEmpty())
        myKeySequenceLineEdit->setText(text);

      emit editingStarted();
      return true;
    }
    if (theEvent->type() == QEvent::KeyRelease) {
      onEditingFinished();
      return true;
    }
  }
  return false;
}

void SUIT_KeySequenceEdit::initialize()
{
  QHBoxLayout* base = new QHBoxLayout( this );
  base->setMargin(0);
  base->setSpacing(5);

  base->addWidget(myKeySequenceLineEdit = new QLineEdit(this));
  setFocusProxy(myKeySequenceLineEdit);

  QToolButton* clearBtn = new QToolButton();
  clearBtn->setIcon(QIcon(":/resources/shortcut_disable.svg"));
  clearBtn->setToolTip(tr("Disable shortcut."));
  base->addWidget(clearBtn);

  QToolButton* restoreBtn = new QToolButton();
  restoreBtn->setIcon(QIcon(":/resources/shortcut_restore.svg"));
  restoreBtn->setToolTip(tr("Restore the currently applied key sequence."));
  base->addWidget(restoreBtn);

  myKeySequenceLineEdit->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::Fixed);
  clearBtn->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  restoreBtn->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);

  connect(clearBtn, SIGNAL(clicked()), this, SLOT(onClear()));
  connect(restoreBtn, SIGNAL(clicked()), this, SIGNAL(restoreFromShortcutMgrClicked()));
  connect(myKeySequenceLineEdit, SIGNAL(editingFinished()), this, SLOT(onEditingFinished()));
}


SUIT_EditKeySequenceDialog::SUIT_EditKeySequenceDialog(SUIT_ShortcutTabWidget* theParent)
: QDialog(theParent)
{
  setMinimumWidth(500);
  setWindowTitle(tr("Change key sequence"));
  QVBoxLayout* layout = new QVBoxLayout(this);
  myActionName = new QLabel(this);
  myActionName->setTextFormat(Qt::RichText);
  myKeySequenceEdit = new SUIT_KeySequenceEdit(this);
  myTextEdit = new QTextEdit(this);
  layout->addWidget(myActionName);
  layout->addWidget(myKeySequenceEdit);
  layout->addWidget(myTextEdit);
  myActionName->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::Fixed);
  myKeySequenceEdit->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::Fixed);
  myTextEdit->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::MinimumExpanding);
  myTextEdit->setReadOnly(true);
  myTextEdit->setAcceptRichText(true);
  myTextEdit->setPlaceholderText(tr("No conflicts."));
  setFocusProxy(myKeySequenceEdit);

  QHBoxLayout* buttonLayout = new QHBoxLayout(this);
  layout->addLayout(buttonLayout);
  QPushButton* confirmButton = new QPushButton(tr("Confirm"), this);
  confirmButton->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  QPushButton* cancelButton = new QPushButton(tr("Cancel"), this);
  cancelButton->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  buttonLayout->addStretch();
  buttonLayout->addWidget(confirmButton);
  buttonLayout->addWidget(cancelButton);

  connect(myKeySequenceEdit, SIGNAL(editingStarted()), this, SLOT(onEditingStarted()));
  connect(myKeySequenceEdit, SIGNAL(editingFinished()), this, SLOT(onEditingFinished()));
  connect(myKeySequenceEdit, SIGNAL(restoreFromShortcutMgrClicked()), this, SLOT(onRestoreFromShortcutMgr()));
  connect(confirmButton, SIGNAL(clicked()), this, SLOT(onConfirm()));
  connect(cancelButton, SIGNAL(clicked()), this, SLOT(reject()));
}

void SUIT_EditKeySequenceDialog::setModuleAndActionID(const QString& theModuleID, const QString& theInModuleActionID)
{
  myModuleID = theModuleID;
  myInModuleActionID = theInModuleActionID;
}

const QString& SUIT_EditKeySequenceDialog::moduleID() const { return myModuleID; }
const QString& SUIT_EditKeySequenceDialog::inModuleActionID() const { return myInModuleActionID; }

void SUIT_EditKeySequenceDialog::setModuleAndActionName(const QString& theModuleName, const QString& theActionName, const QString& theActionToolTip)
{
  myActionName->setText("<b>" + theModuleName + "</b>&nbsp;&nbsp;" + theActionName);
  myActionName->setToolTip(theActionToolTip);
}

void SUIT_EditKeySequenceDialog::setConfirmedKeySequence(const QKeySequence& theSequence)
{
  myKeySequenceEdit->setConfirmedKeySequence(theSequence);
}

QKeySequence SUIT_EditKeySequenceDialog::editedKeySequence() const
{
  return myKeySequenceEdit->editedKeySequence();
}

int SUIT_EditKeySequenceDialog::exec()
{
  myKeySequenceEdit->setFocus(Qt::ActiveWindowFocusReason);
  return QDialog::exec();
}

void SUIT_EditKeySequenceDialog::onEditingStarted()
{
  myTextEdit->setEnabled(false);
}

void SUIT_EditKeySequenceDialog::onEditingFinished()
{
  updateConflictsMessage();
}

void SUIT_EditKeySequenceDialog::onRestoreFromShortcutMgr()
{
  const auto mgr = SUIT_ShortcutMgr::get();
  myKeySequenceEdit->setEditedKeySequence(mgr->getKeySequence(myModuleID, myInModuleActionID));
  updateConflictsMessage();
}

void SUIT_EditKeySequenceDialog::updateConflictsMessage()
{
  myTextEdit->setEnabled(true);
  QTextDocument* doc = myTextEdit->document();
  if (!doc) {
    doc = new QTextDocument(myTextEdit);
    myTextEdit->setDocument(doc);
  }

  if (!myKeySequenceEdit->isKeySequenceModified()) {
    doc->clear();
    return;
  }

  const QKeySequence newKeySequence = editedKeySequence();

  const auto tabWidget = static_cast<SUIT_ShortcutTabWidget*>(parentWidget());
  /** {moduleID, inModuleActionID}[] */
  std::set<std::pair<QString, QString>> conflicts = tabWidget->shortcutContainer()->getConflicts(myModuleID, myInModuleActionID, newKeySequence);
  if (!conflicts.empty()) {
    const auto mgr = SUIT_ShortcutMgr::get();

    QString report = "<b>" + tr("These shortcuts will be disabled on confirm:") + "</b>";
    {
      report += "<ul>";
      for (const auto& conflict : conflicts) {
        const QString conflictingModuleName = mgr->getModuleName(conflict.first);
        const auto actionAssets = SUIT_ShortcutMgr::get()->getActionAssets(conflict.first, conflict.second);
#ifdef SHORTCUT_MGR_DBG
        if (!actionAssets)
          ShCutDbg("SUIT_EditKeySequenceDialog::updateConflictsMessage(): action assets of \"" + conflict.first + "/" + conflict.second + "\" are absent in SUIT_ShortcutMgr.");
#endif
        const QString conflictingActionName = actionAssets ? actionAssets->bestPath() : conflict.second;
        report += "<li><b>" + conflictingModuleName + "</b>&nbsp;&nbsp;" + conflictingActionName + "</li>";
      }
      report += "</ul>";
    }
    doc->setHtml(report);
  }
  else /* if no conflicts */ {
    doc->clear();
  }
}

void SUIT_EditKeySequenceDialog::onConfirm()
{
  if (myKeySequenceEdit->isKeySequenceModified())
    accept();
  else
    reject();
}


/*static*/ std::map<SUIT_ShortcutContainer*, std::set<SUIT_ShortcutTabWidget*>> SUIT_ShortcutTabWidget::instances =
std::map<SUIT_ShortcutContainer*, std::set<SUIT_ShortcutTabWidget*>>();

SUIT_ShortcutTabWidget::SUIT_ShortcutTabWidget(
  const std::set<QString>& theIDsOfModulesToShow,
  std::shared_ptr<SUIT_ShortcutContainer> theContainer,
  QWidget* theParent
) : QTabWidget(theParent),
myModuleIDs(theIDsOfModulesToShow.empty() ? std::set<QString>({SUIT_ShortcutMgr::ROOT_MODULE_ID}) : theIDsOfModulesToShow),
myShortcutContainer(theContainer ? theContainer : std::shared_ptr<SUIT_ShortcutContainer>(new SUIT_ShortcutContainer())),
myIsPopulated(false)
{
  setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
  myEditDialog = new SUIT_EditKeySequenceDialog(this);
  myFindActionWidget = new SUIT_FindActionWidget(
    this,
    std::bind(&SUIT_ShortcutTabWidget::jumpToTreeItem, this, std::placeholders::_1, std::placeholders::_2) /*call back on item double clicked*/,
    tr("Double click to edit key sequence."),
    true /*theEnableItemsOfUnavailableActions*/,
    true /*theShowKeySequenceColumn*/,
    std::bind(&SUIT_ShortcutTabWidget::getConfirmedKeySequence, this, std::placeholders::_1, std::placeholders::_2) /*theKeySequenceGetter*/
  );
  myFindActionWidget->showOptions(false);
  myFindActionWidget->setIncludedModuleIDs(myModuleIDs, true /*doNotUpdateResults*/);

  const auto tabBar = new SUIT_ShortcutTabWidgetBar(this);
  setTabBar(tabBar);

  insertTab(0, myFindActionWidget, QIcon(":/resources/find.svg"), ""/*Tab name*/);
  setTabToolTip(0, tr("Find shortcut"));

  SUIT_ShortcutTabWidget::instances[myShortcutContainer.get()].emplace(this);
}

SUIT_ShortcutTabWidget::~SUIT_ShortcutTabWidget()
{
  SUIT_ShortcutTabWidget::instances[myShortcutContainer.get()].erase(this);
  if (SUIT_ShortcutTabWidget::instances[myShortcutContainer.get()].empty())
    SUIT_ShortcutTabWidget::instances.erase(myShortcutContainer.get());
}

void SUIT_ShortcutTabWidget::setShortcutsFromManager()
{
  *myShortcutContainer = SUIT_ShortcutMgr::get()->getShortcutContainer();
  // nb! ShortcutMgr never removes shortcuts from its container, only disables.

  updateTabs(false /*theHighlightModifiedTreeItems*/, true /*theUpdateSyncTabs*/);
}

void SUIT_ShortcutTabWidget::setDefaultShortcuts()
{
  SUIT_ShortcutContainer defaultShortcuts;
  SUIT_ShortcutMgr::fillContainerFromPreferences(defaultShortcuts, true /*theDefaultOnly*/);

  myShortcutContainer->merge(defaultShortcuts, true /*theOverride*/, true /*theTreatAbsentIncomingAsDisabled*/);
  // nb! SUIT_ShortcutContainer never erases shortcuts, only disables.

  updateTabs(true /*theHighlightModifiedTreeItems*/, true /*theUpdateSyncTabs*/);
}

void SUIT_ShortcutTabWidget::applyChangesToShortcutMgr()
{
  const auto mgr = SUIT_ShortcutMgr::get();
  mgr->mergeShortcutContainer(*myShortcutContainer);

  // Update non-synchronized with this instances.
  for (const auto& containerAndSyncTabWidgets : SUIT_ShortcutTabWidget::instances) {
    if (containerAndSyncTabWidgets.first == myShortcutContainer.get())
      continue; // Synchronized instances are updated in SUIT_ShortcutTabWidget::updateTabs.

    const std::set<SUIT_ShortcutTabWidget*>& syncTabWidgets = containerAndSyncTabWidgets.second;
    const auto itFirstSyncTabWidget = syncTabWidgets.begin();
    if (itFirstSyncTabWidget == syncTabWidgets.end())
      continue;

     // No need to update each synchronized instance with the same SUIT_ShortcutContainer.
     // Update just one of them, SUIT_ShortcutTabWidget::setShortcutsFromManager does rest.
    (*itFirstSyncTabWidget)->setShortcutsFromManager();
    const auto editDialog = (*itFirstSyncTabWidget)->myEditDialog;
    editDialog->setConfirmedKeySequence(mgr->getShortcutContainer().getKeySequence(editDialog->moduleID(), editDialog->inModuleActionID()));
    editDialog->updateConflictsMessage();
  }
}

std::shared_ptr<const SUIT_ShortcutContainer> SUIT_ShortcutTabWidget::shortcutContainer() const
{
  return myShortcutContainer;
}

void SUIT_ShortcutTabWidget::onTreeItemDoubleClicked(SUIT_ShortcutTree* theTree, SUIT_ShortcutTreeItem* theItem)
{
  const auto mgr = SUIT_ShortcutMgr::get();

  if (!theItem->isAction())
    return;

  myEditDialog->setModuleAndActionID(theTree->moduleID(), theItem->inModuleID());
  myEditDialog->setModuleAndActionName(theTree->name(), theItem->path(), theItem->toolTip());
  myEditDialog->setConfirmedKeySequence(QKeySequence::fromString(theItem->keySequence()));
  myEditDialog->updateConflictsMessage();
  const bool somethingChanged = myEditDialog->exec() == QDialog::Accepted;

  if (!somethingChanged)
    return;

  const QKeySequence newKeySequence = myEditDialog->editedKeySequence();

  /** { moduleID, inModuleID }[] */
  std::set<std::pair<QString, QString>> disabledActionIDs = myShortcutContainer->setShortcut(theTree->moduleID(), theItem->inModuleID(), newKeySequence, true /*override*/);

  /** { moduleID, {inModuleID, keySequence}[] }[] */
  std::map<QString, std::map<QString, QString>> changes;
  changes[theTree->moduleID()][theItem->inModuleID()] = newKeySequence.toString();
  for (const auto moduleAndActionID : disabledActionIDs) {
    changes[moduleAndActionID.first][moduleAndActionID.second] = QString();
  }

  std::map<int, bool> moduleModifiedStatuses;

  // Set new key sequences to shortcut items.
  for (const auto& moduleIDAndChanges : changes) {
    const QString& moduleID = moduleIDAndChanges.first;
    bool moduleModified = false;

    const auto itModuleTree = myModuleTrees.find(moduleID);
    if (itModuleTree == myModuleTrees.end())
      continue;

    SUIT_ShortcutTree* const moduleTree = itModuleTree->second;

    /** {inModuleID, newKeySequence}[] */
    const std::map<QString, QString>& moduleChanges = moduleIDAndChanges.second;
    for (const auto& inModuleIDAndKS : moduleChanges) {
      const QString& inModuleID = inModuleIDAndKS.first;
      const QString& keySequence = inModuleIDAndKS.second;

      SUIT_ShortcutTreeItem* const item = moduleTree->findItem(SUIT_ShortcutMgr::splitIntoTokens(inModuleID));
      if (!item) {
        ShCutDbg("No SUIT_ShortcutTreeItem for \"" + moduleID + "/" + inModuleID + "\" is found.");
        continue;
      }

      item->setKeySequence(keySequence);

      const QKeySequence& appliedKeySequence = mgr->getKeySequence(moduleID, inModuleID);
      const bool keySequenceModified = QKeySequence::fromString(keySequence) != appliedKeySequence;
      item->styleAsKeySequenceModified(keySequenceModified);
      moduleModified = moduleModified || keySequenceModified;
    }

    moduleModifiedStatuses[indexOf(moduleTree)] = moduleModified;
  }
  static_cast<SUIT_ShortcutTabWidgetBar*>(tabBar())->mergeTabModifiedStatuses(moduleModifiedStatuses);

  // Key sequences have been changed. Update search tab.
  myFindActionWidget->updateUI();
}

void SUIT_ShortcutTabWidget::jumpToTreeItem(const QString& theModuleID, const QString& theInModuleID)
{
  const auto itModuleTree = myModuleTrees.find(theModuleID);
  if (itModuleTree == myModuleTrees.end()) {
    ShCutDbg("SUIT_ShortcutTabWidget::jumpToTreeItem( moduleID = " + theModuleID + ", inModuleID = " + theInModuleID + "): the tab widget is set to not show the module.");
    return;
  }

  const auto moduleTree = itModuleTree->second;
  const auto item = moduleTree->findItem(SUIT_ShortcutMgr::splitIntoTokens(theInModuleID));
  if (!item) {
    ShCutDbg("SUIT_ShortcutTabWidget::jumpToTreeItem( moduleID = " + theModuleID + ", inModuleID = " + theInModuleID + "): tree widget does not have such item.");
    return;
  }

  setCurrentWidget(moduleTree);
  moduleTree->scrollToItem(item);
  moduleTree->setCurrentItem(item);
  onTreeItemDoubleClicked(moduleTree, item);
}

std::pair<QString, bool> SUIT_ShortcutTabWidget::getConfirmedKeySequence(const QString& theModuleID, const QString& theInModuleActionID) const
{
  const QKeySequence& ksInMgr = SUIT_ShortcutMgr::get()->getKeySequence(theModuleID, theInModuleActionID);
  const auto itModuleTree = myModuleTrees.find(theModuleID);
  if (itModuleTree == myModuleTrees.end())
    std::pair<QString, bool>(QString(), !ksInMgr.isEmpty());

  const auto moduleTree = itModuleTree->second;
  const auto item = moduleTree->findItem(SUIT_ShortcutMgr::splitIntoTokens(theInModuleActionID));
  if (!item)
    std::pair<QString, bool>(QString(), !ksInMgr.isEmpty());

  const QString itemKSString = item->keySequence();
  return std::pair<QString, bool>(itemKSString, itemKSString != ksInMgr.toString());
}

void SUIT_ShortcutTabWidget::updateTabs(bool theHighlightModifiedTreeItems, bool theUpdateSyncTabWidgets)
{
  const auto mgr = SUIT_ShortcutMgr::get();
  const QString lang = SUIT_ShortcutMgr::currentLang();

  std::map<int, bool> moduleModifiedStatuses;

  for (const QString& moduleID : myModuleIDs) {
    const auto moduleAssets = mgr->getModuleAssets(moduleID);

    if (!moduleAssets) {
      ShCutDbg("SUIT_ShortcutTabWidget::updateTabs: SUIT_ShortcutMgr does not have assets of module \"" + moduleID + "\"." );
      const auto itModuleIDAndTree = myModuleTrees.find(moduleID);
      if (itModuleIDAndTree != myModuleTrees.end()) {
        SUIT_ShortcutTree* const moduleTree = itModuleIDAndTree->second;
        removeTab(indexOf(moduleTree));
        myModuleTrees.erase(itModuleIDAndTree);
        delete moduleTree;
      }
      continue;
    }

    auto itModuleIDAndTree = myModuleTrees.find(moduleID);
    if (itModuleIDAndTree == myModuleTrees.end()) {
      SUIT_ShortcutTree* const moduleTree = new SUIT_ShortcutTree(this, moduleAssets, lang);
      itModuleIDAndTree = myModuleTrees.emplace(moduleID, moduleTree).first;

      const int tabIndex = ::SUIT_tools::distanceFromBegin(myModuleIDs, myModuleIDs.find(moduleID));
      insertTab(tabIndex + 1 /*The first tab is SUIT_FindActionWidget.*/, moduleTree, moduleAssets->myIcon, moduleTree->name());
    }

    SUIT_ShortcutTree* const moduleTree = itModuleIDAndTree->second;
    const bool isTreeShortcutModified = moduleTree->updateItems(theHighlightModifiedTreeItems);

    moduleModifiedStatuses[indexOf(moduleTree)] = isTreeShortcutModified;
  }

  if (!myIsPopulated) {
    setCurrentWidget(myModuleTrees.begin()->second); // Set active first tab with shortcut tree.
    myIsPopulated = true;

    // Adjust widths of Find tab' columns.
    for (int colIdx = 0; colIdx < SUIT_ShortcutTree::ColumnIdx::NotExist; colIdx++) {
      int colWidth = 0;
      for (const auto& moduleIDAndTree : myModuleTrees) {
        const SUIT_ShortcutTree* const moduleTree = moduleIDAndTree.second;
        const int treeColWidth = moduleTree->columnWidth(colIdx);
        if (treeColWidth > colWidth)
          colWidth = treeColWidth;
      }
      myFindActionWidget->setColumnWidth(SUIT_ShortcutTree::toFoundActionTreeColIdx(SUIT_ShortcutTree::ColumnIdx(colIdx)), colWidth);
    }
  }

  static_cast<SUIT_ShortcutTabWidgetBar*>(tabBar())->mergeTabModifiedStatuses(moduleModifiedStatuses);

  // Key sequences have been changed. Update search tab.
  myFindActionWidget->updateUI();

  if (theUpdateSyncTabWidgets) {
    const std::set<SUIT_ShortcutTabWidget*>& syncTabWidgets = SUIT_ShortcutTabWidget::instances[myShortcutContainer.get()];
    for (const auto syncTabWidget : syncTabWidgets) {
      if (syncTabWidget == this)
        continue;

      syncTabWidget->updateTabs(theHighlightModifiedTreeItems, false /*theUpdateSyncTabWidgets*/);
      const auto editDialog = syncTabWidget->myEditDialog;
      editDialog->setConfirmedKeySequence(myShortcutContainer->getKeySequence(editDialog->moduleID(), editDialog->inModuleActionID()));
      editDialog->updateConflictsMessage();
    }
  }
}


SUIT_ShortcutTabWidgetBar::SUIT_ShortcutTabWidgetBar(SUIT_ShortcutTabWidget* theTabWidget) : QTabBar(theTabWidget) {}

void SUIT_ShortcutTabWidgetBar::mergeTabModifiedStatuses(const std::map<int, bool>& theTabModifiedStatuses)
{
  for (const auto& tabModifiedStatus : theTabModifiedStatuses) {
    myTabModifiedStatuses[tabModifiedStatus.first] = tabModifiedStatus.second;
  }
}

void SUIT_ShortcutTabWidgetBar::paintEvent(QPaintEvent* theEvent)
{
  QTabBar::paintEvent(theEvent);

  QPainter painter(this);
  QStyleOptionTab option;

  for (const auto& tabModifiedStatus : myTabModifiedStatuses) {
    const int tabIdx = tabModifiedStatus.first;
    const bool isKeySequenceModified = tabModifiedStatus.second;

    initStyleOption(&option, tabIdx);
    if (isKeySequenceModified)
      painter.fillRect(tabRect(tabIdx), Qt::darkGreen);
    else
      painter.fillRect(tabRect(tabIdx), palette().background());

    style()->drawControl(QStyle::CE_TabBarTab, &option, &painter, this);
  }

  const int activeTabIdx = static_cast<SUIT_ShortcutTabWidget*>(parentWidget())->currentIndex();
  const auto itActiveTabModifiedStatus = myTabModifiedStatuses.find(activeTabIdx);
  if (itActiveTabModifiedStatus != myTabModifiedStatuses.end()) {
    const bool isActiveTabModified = itActiveTabModifiedStatus->second;
    if (isActiveTabModified) {
      setStyleSheet(
        "QTabBar::tab:selected {"
        "    background: darkgreen;"
        "    color: white;"
        "}"
      );
    }
    else {
      setStyleSheet(
        "QTabBar::tab:selected {}"
      );
    }
  }
}


/*static*/ SUIT_FoundActionTree::ColumnIdx SUIT_ShortcutTree::toFoundActionTreeColIdx(const SUIT_ShortcutTree::ColumnIdx theColumnIdx)
{
  switch (theColumnIdx) {
    case SUIT_ShortcutTree::ColumnIdx::Name:
      return SUIT_FoundActionTree::ColumnIdx::Name;
    case SUIT_ShortcutTree::ColumnIdx::ToolTip:
      return SUIT_FoundActionTree::ColumnIdx::ToolTip;
    case SUIT_ShortcutTree::ColumnIdx::KeySequence:
      return SUIT_FoundActionTree::ColumnIdx::KeySequence;
    default:
      throw std::invalid_argument("SUIT_ShortcutTree::toFoundActionTreeColIdx(const SUIT_ShortcutTree::ColumnIdx): not handled ColumnIdx case.");
  }
}

/*static*/ SUIT_ShortcutTree::SortKey SUIT_ShortcutTree::toSortKey(const SUIT_ShortcutTree::ColumnIdx theColumnIdx)
{
  switch (theColumnIdx) {
    case SUIT_ShortcutTree::ColumnIdx::Name:
      return SUIT_ShortcutTree::SortKey::Name;
    case SUIT_ShortcutTree::ColumnIdx::ToolTip:
      return SUIT_ShortcutTree::SortKey::ToolTip;
    case SUIT_ShortcutTree::ColumnIdx::KeySequence:
      return SUIT_ShortcutTree::SortKey::KeySequence;
    default:
      throw std::invalid_argument("SUIT_ShortcutTree::toSortKey(const SUIT_ShortcutTree::ColumnIdx): not handled ColumnIdx case.");
  }
}

/*static*/ SUIT_ShortcutTree::ColumnIdx SUIT_ShortcutTree::toColumnIdx(const SUIT_ShortcutTree::SortKey theSortKey)
{
  switch (theSortKey)
  {
    case SUIT_ShortcutTree::SortKey::Name:
      return SUIT_ShortcutTree::ColumnIdx::Name;
    case SUIT_ShortcutTree::SortKey::ToolTip:
      return SUIT_ShortcutTree::ColumnIdx::ToolTip;
    case SUIT_ShortcutTree::SortKey::KeySequence:
      return SUIT_ShortcutTree::ColumnIdx::KeySequence;
    default:
      return SUIT_ShortcutTree::ColumnIdx::NotExist;
  }
}

/*static*/ const QList<std::pair<SUIT_ShortcutTree::SortKey, Qt::SortOrder>> SUIT_ShortcutTree::DEFAULT_SORT_SCHEMA =
{
  {SUIT_ShortcutTree::SortKey::Name, Qt::SortOrder::AscendingOrder},
  {SUIT_ShortcutTree::SortKey::ToolTip, Qt::SortOrder::AscendingOrder},
  {SUIT_ShortcutTree::SortKey::KeySequence, Qt::SortOrder::AscendingOrder},
  {SUIT_ShortcutTree::SortKey::ID, Qt::SortOrder::AscendingOrder}
};

SUIT_ShortcutTree::SUIT_ShortcutTree(
  SUIT_ShortcutTabWidget* theParent,
  std::shared_ptr<const SUIT_ShortcutModuleAssets> theAssets,
  const QString& theLang
) : QTreeWidget(theParent),
myParentTabWidget(theParent), myAssets(theAssets),
myLeadingSortKey(SUIT_ShortcutTree::SortKey::Name), myIsPopulated(false)
{
  for (const auto& keyAndOrder : SUIT_ShortcutTree::DEFAULT_SORT_SCHEMA) {
    mySortSchema[keyAndOrder.first] = keyAndOrder.second;
  }

  setLang(theLang);

  setSelectionMode(QAbstractItemView::SingleSelection);
  setColumnCount(int(SUIT_ShortcutTree::ColumnIdx::NotExist) - 1);
  setHeaderItem(new SUIT_ShortcutTreeHeaderItem(mySortSchema, SUIT_ShortcutTree::toColumnIdx(myLeadingSortKey)));
  setSortingEnabled(false); // Custom sorting is engaged.
  header()->setSectionResizeMode(QHeaderView::Interactive);
  header()->setSectionsClickable(true);

  setExpandsOnDoubleClick(false); // Open shortcut editor, if item is action, on double click instead.
  setSizeAdjustPolicy(QAbstractScrollArea::AdjustToContents);
  setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);

  this->installEventFilter(this);

  connect(header(), SIGNAL(sectionClicked(int)), this, SLOT(onHeaderItemClicked(int)));
  connect(header(), SIGNAL(sortIndicatorChanged(int, Qt::SortOrder)), this, SLOT(onSortColOrOrderChanged(int, Qt::SortOrder)));
  connect(this, SIGNAL(itemDoubleClicked(QTreeWidgetItem*, int)), this, SLOT(onItemDoubleClicked(QTreeWidgetItem*, int)));
  connect(this, SIGNAL(itemExpanded(QTreeWidgetItem*)),  this, SLOT(onItemExpanded(QTreeWidgetItem*)));
  connect(this, SIGNAL(itemCollapsed(QTreeWidgetItem*)), this, SLOT(onItemCollapsed(QTreeWidgetItem*)));
}

SUIT_ShortcutTabWidget* SUIT_ShortcutTree::parentTabWidget() const
{
  return myParentTabWidget; // static_cast<SUIT_ShortcutTabWidget*>(QWidget::parentWidget()) somehow is not the same.
}

const SUIT_ShortcutContainer& SUIT_ShortcutTree::shortcutContainer() const
{
  return *(myParentTabWidget->myShortcutContainer);
}

const QString& SUIT_ShortcutTree::moduleID() const
{
  return myAssets->myModuleID;
}

void SUIT_ShortcutTree::setLang(const QString& theLang)
{
  myName = myAssets->bestName(theLang);
  myToolTip = myAssets->bestToolTip(theLang);
}

const QString& SUIT_ShortcutTree::name() const
{
  return myName;
}

const QString& SUIT_ShortcutTree::toolTip() const
{
  return myToolTip;
}

void SUIT_ShortcutTree::sort(SUIT_ShortcutTree::SortKey theLeadingKey, Qt::SortOrder theOrder)
{
  if (theLeadingKey == myLeadingSortKey && theOrder == mySortSchema[theLeadingKey])
    return;

  myLeadingSortKey = theLeadingKey;
  mySortSchema[theLeadingKey] = theOrder;

  const auto selectedItem = currentItem();
  sortRecursive(invisibleRootItem());
  if (selectedItem) {
    scrollToItem(selectedItem);
    setCurrentItem(selectedItem);
  }
}

void SUIT_ShortcutTree::sortRecursive(QTreeWidgetItem* theParentItem)
{
  const auto sortedChildren = getSortedChildren(theParentItem);

  theParentItem->takeChildren();

  for (const auto childItem : sortedChildren) {
    theParentItem->addChild(childItem);
    childItem->setExpanded(childItem->isExpanded());
    sortRecursive(childItem);
  }
}

bool SUIT_ShortcutTree::updateItems(bool theHighlightModified)
{
  const std::shared_ptr<const SUIT_ShortcutModuleAssets> moduleAssets = SUIT_ShortcutMgr::get()->getModuleAssets(moduleID());
  const bool isKeySequenceModified = updateChildrenItemsRecursively(theHighlightModified, invisibleRootItem(), true /*theItemIsInvisibleRoot*/);

  if (!myIsPopulated) { // Do not adjust column widths more than once to not reset user-made adjustments.
    for (int colIdx = 0; colIdx < columnCount(); colIdx++) {
      resizeColumnToContents(colIdx);
    }
    myIsPopulated = true;
  }

  return isKeySequenceModified;
}

bool SUIT_ShortcutTree::updateChildrenItemsRecursively(
    bool theHighlightModified,
    QTreeWidgetItem* const theItem,
    bool theItemIsInvisibleRoot
) {
  const auto mgr = SUIT_ShortcutMgr::get();
  const QString lang = SUIT_ShortcutMgr::currentLang();

  // { IDLastToken, assets }.
  const auto& childrenAssets = theItemIsInvisibleRoot ? myAssets->children() : static_cast<SUIT_ShortcutTreeItem*>(theItem)->myAssets->children();
  const auto& moduleShortcuts = shortcutContainer().getModuleShortcutsInversed(moduleID());

  bool isKSModified = false;

  // Update exisiting child items.
  for (int childItemIdx = 0; childItemIdx < theItem->childCount(); childItemIdx++) {
    const auto childItem = static_cast<SUIT_ShortcutTreeItem*>(theItem->child(childItemIdx));
    const auto itChildAssets = childrenAssets.find(childItem->lastTokenOfID());
    if (itChildAssets == childrenAssets.end()) {
      // Assets of the child item has been removed from ShortcutMgr - impossible.
      ShCutDbg("Invalid logics: assets of \"" + moduleID() + "/" + childItem->inModuleID() + "\" are missing in ShortcutMgr.");
      continue;
    }

    if (childItem->isAction()) {
      const bool isChildKSModified = updateItemShortcut(childItem, moduleShortcuts, theHighlightModified);
      isKSModified = isKSModified || isChildKSModified;
    }

    const bool isDescendantKSModified = updateChildrenItemsRecursively(theHighlightModified, childItem);
    isKSModified = isKSModified || isDescendantKSModified;
  }

  // Add new child items.
  if (theItem->childCount() < childrenAssets.size()) {
    auto sortedChildren = getSortedChildren(theItem);
    for (const auto& childTokenAndAssets : childrenAssets) {
      const QString& childToken = childTokenAndAssets.first;
      const auto& childAssets = childTokenAndAssets.second;

      const auto predicate = [&childToken](const SUIT_ShortcutTreeItem* const theItem) -> bool {
        return theItem->lastTokenOfID() == childToken;
      };

      if (std::find_if(sortedChildren.begin(), sortedChildren.end(), predicate) == sortedChildren.end()) {
        if (!childAssets->isAction() && childAssets->children().empty())
          continue; // Do not create empty pure folders.

        const auto newChildItem = new SUIT_ShortcutTreeItem(childAssets, lang);
        if (newChildItem->isAction()) {
          const bool isChildKSModified = updateItemShortcut(newChildItem, moduleShortcuts, theHighlightModified);
          isKSModified = isKSModified || isChildKSModified;
        }

        insertChild(theItem, sortedChildren, newChildItem);
        newChildItem->setExpanded(true); // Make tree expanded on first show.
        const bool isDescendantKSModified = updateChildrenItemsRecursively(theHighlightModified, newChildItem);
        isKSModified = isKSModified || isDescendantKSModified;
      }
    }
  }

  return isKSModified;
}

bool SUIT_ShortcutTree::updateItemShortcut(
  SUIT_ShortcutTreeItem* const theItem,
  const std::map<QString, QKeySequence>& theModuleShortcuts,
  bool theHighlightIfModified
) const {
  static const QKeySequence NO_KEYSEQUENCE = QKeySequence();

  const auto itShortcut = theModuleShortcuts.find(theItem->inModuleID());
  const QKeySequence& newKeySequence = itShortcut == theModuleShortcuts.end() ? NO_KEYSEQUENCE : itShortcut->second;
  const QString newKeySequenceString = newKeySequence.toString();

  if (theItem->keySequence() != newKeySequenceString)
    theItem->setKeySequence(newKeySequenceString);

  const QKeySequence& appliedKeySequence = SUIT_ShortcutMgr::get()->getKeySequence(moduleID(), theItem->inModuleID());
  const bool isKeySequenceModified = newKeySequence != appliedKeySequence;
  if (theHighlightIfModified)
    theItem->styleAsKeySequenceModified(isKeySequenceModified);
  else
    theItem->styleAsKeySequenceModified(false);

  return isKeySequenceModified;
}

SUIT_ShortcutTreeItem* SUIT_ShortcutTree::findItem(QStringList theRelativeIDTokens, const QTreeWidgetItem* theAncestorItem) const
{
  if (theRelativeIDTokens.isEmpty())
    return nullptr;

  if (!theAncestorItem)
    theAncestorItem = invisibleRootItem();

  const QString& token = theRelativeIDTokens.front();
  for (int childIdx = 0; childIdx < theAncestorItem->childCount(); childIdx++) {
    const auto childItem = static_cast<SUIT_ShortcutTreeItem*>(theAncestorItem->child(childIdx));
    if (childItem->lastTokenOfID() == token) {
      if (theRelativeIDTokens.length() > 1) {
        theRelativeIDTokens.pop_front();
        return findItem(std::move(theRelativeIDTokens), childItem);
      }
      else
        return childItem;
    }
  }

  return nullptr;
}

std::set<SUIT_ShortcutTreeItem*, std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)>> SUIT_ShortcutTree::getSortedChildren(QTreeWidgetItem* theParentItem)
{
  auto sortSchema = SUIT_ShortcutTree::DEFAULT_SORT_SCHEMA;
  for (auto itKeyAndOrder = sortSchema.begin(); itKeyAndOrder != sortSchema.end();) {
    if (itKeyAndOrder->first == myLeadingSortKey)
      sortSchema.erase(itKeyAndOrder);
    else
      itKeyAndOrder->second = mySortSchema[itKeyAndOrder->first];

    itKeyAndOrder++;
  }
  sortSchema.push_front(std::pair<SUIT_ShortcutTree::SortKey, Qt::SortOrder>(myLeadingSortKey, mySortSchema[myLeadingSortKey]));

  const std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)> comparator =
  [this, sortSchema](const SUIT_ShortcutTreeItem* theItemA, const SUIT_ShortcutTreeItem* theItemB) {
    // Folders first.
    if (theItemA->isFolder()) {
      if (!theItemB->isFolder())
        return true;
    }
    else {
      if (theItemB->isFolder())
        return false;
    }

    const auto collator = QCollator();
    for (const auto& keyAndOrder : sortSchema) {
      const QString valA = theItemA->getValue(keyAndOrder.first);
      const QString valB = theItemB->getValue(keyAndOrder.first);

      // Empty lines last.
      if (valA.isEmpty()) {
        if (!valB.isEmpty())
          return false;
      }
      else {
        if (valB.isEmpty())
          return true;
      }

      const int res = collator.compare(valA, valB);
      if (res != 0)
        return keyAndOrder.second == Qt::SortOrder::AscendingOrder ? res < 0 : res > 0;
    }
    return false;
  };

  std::set<SUIT_ShortcutTreeItem*, std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)>> sortedChildren(comparator);
  for (int childIdx = 0; childIdx < theParentItem->childCount(); childIdx++) {
    SUIT_ShortcutTreeItem* const childItem = static_cast<SUIT_ShortcutTreeItem*>(theParentItem->child(childIdx));
    sortedChildren.emplace(childItem);
  }
  return sortedChildren;
}

void SUIT_ShortcutTree::insertChild(
  QTreeWidgetItem* theParentItem,
  std::set<SUIT_ShortcutTreeItem*, std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)>>& theSortedChildren,
  SUIT_ShortcutTreeItem* theChildItem
) {
  const auto emplaceRes = theSortedChildren.emplace(theChildItem);
  theParentItem->insertChild(::SUIT_tools::distanceFromBegin(theSortedChildren, emplaceRes.first), theChildItem);
}

void SUIT_ShortcutTree::onItemExpanded(QTreeWidgetItem* theItem)
{
  static_cast<SUIT_ShortcutTreeItem*>(theItem)->setExpanded(true);
}

void SUIT_ShortcutTree::onItemCollapsed(QTreeWidgetItem* theItem)
{
  static_cast<SUIT_ShortcutTreeItem*>(theItem)->setExpanded(false);
}

void SUIT_ShortcutTree::onHeaderItemClicked(int theColIdx)
{
  const auto customHeaderItem = static_cast<SUIT_ShortcutTreeHeaderItem*>(headerItem());

  const auto theLeadingColIdx = static_cast<SUIT_ShortcutTree::ColumnIdx>(theColIdx);
  const auto theNewLeadingSortKey = SUIT_ShortcutTree::toSortKey(theLeadingColIdx);
  if (myLeadingSortKey == theNewLeadingSortKey) { // Click on active column. Change order.
    const auto newSortOrder = mySortSchema[myLeadingSortKey] == Qt::SortOrder::AscendingOrder ? Qt::SortOrder::DescendingOrder : Qt::SortOrder::AscendingOrder;
    sort(myLeadingSortKey, newSortOrder);
  }
  else /* if click on inactive column. Change sorting key, preserve order. */
    sort(theNewLeadingSortKey, mySortSchema[theNewLeadingSortKey]);

  customHeaderItem->setSortSchemaAndLeadingColIdx(mySortSchema, theLeadingColIdx);
}

void SUIT_ShortcutTree::onItemDoubleClicked(QTreeWidgetItem* theItem, int theColIdx)
{
  parentTabWidget()->onTreeItemDoubleClicked(this, static_cast<SUIT_ShortcutTreeItem*>(theItem));
}


SUIT_ShortcutTreeItem::SUIT_ShortcutTreeItem(const std::shared_ptr<const SUIT_ShortcutItemAssets> theAssets, const QString& theLang)
: QTreeWidgetItem(), myAssets(theAssets), myIsExpanded(QTreeWidgetItem::isExpanded())
{
  setFlags(Qt::ItemIsEnabled);
  setIcon(SUIT_ShortcutTree::ColumnIdx::Name, myAssets->icon());
  setLang(theLang);

  if (myAssets->isFolder())
    styleAsFolder(true);
}

void SUIT_ShortcutTreeItem::setLang(const QString& theLang)
{
  setText(SUIT_ShortcutTree::ColumnIdx::Name, myAssets->bestName(theLang));
  myPath = myAssets->bestPath(theLang);

  myToolTip = myAssets->bestToolTip(theLang);
  if (!myToolTip.isEmpty() && myToolTip.at(myToolTip.length()-1) != ".")
     myToolTip += ".";

  setText(SUIT_ShortcutTree::ColumnIdx::ToolTip, myToolTip);

  if (isAction()) {
    if (myToolTip.isEmpty())
      setToolTip(
        SUIT_ShortcutTree::ColumnIdx::Name,
        SUIT_ShortcutTree::tr("Double click to edit key sequence.")
      );
    else
      setToolTip(
        SUIT_ShortcutTree::ColumnIdx::Name,
        myToolTip + "\n" + SUIT_ShortcutTree::tr("Double click to edit key sequence.")
      );
  }
  else {
    setToolTip(
      SUIT_ShortcutTree::ColumnIdx::Name,
      myToolTip
    );
  }
}

const QString& SUIT_ShortcutTreeItem::moduleID() const
{
  return myAssets->myModuleID;
}

const QString& SUIT_ShortcutTreeItem::inModuleID() const
{
  return myAssets->myInModuleID;
}

const QString& SUIT_ShortcutTreeItem::lastTokenOfID() const
{
  return myAssets->myIDLastToken;
}

bool SUIT_ShortcutTreeItem::isAction() const
{
  return myAssets->isAction();
}

bool SUIT_ShortcutTreeItem::isFolder() const
{
  return myAssets->isFolder();
}

QString SUIT_ShortcutTreeItem::name() const
{
  return text(SUIT_ShortcutTree::ColumnIdx::Name);
}

const QString& SUIT_ShortcutTreeItem::path() const
{
  return myPath;
}

const QString& SUIT_ShortcutTreeItem::toolTip() const
{
  return myToolTip;
}

QString SUIT_ShortcutTreeItem::getValue(SUIT_ShortcutTree::SortKey theKey) const
{
  switch (theKey) {
    case SUIT_ShortcutTree::SortKey::ID:
      return inModuleID();
    case SUIT_ShortcutTree::SortKey::Name:
      return name();
    case SUIT_ShortcutTree::SortKey::ToolTip:
      return myToolTip;
    case SUIT_ShortcutTree::SortKey::KeySequence:
      return keySequence();
    default:
      return QString();
  }
}

void SUIT_ShortcutTreeItem::setKeySequence(const QString& theKeySequence)
{
  if (!isAction())
    return;

  setText(SUIT_ShortcutTree::ColumnIdx::KeySequence, theKeySequence);
}

QString SUIT_ShortcutTreeItem::keySequence() const
{
  if (!isAction())
    return QString();

  return text(SUIT_ShortcutTree::ColumnIdx::KeySequence);
}

void SUIT_ShortcutTreeItem::styleAsFolder(bool theIsFolder)
{
  QFont f = font(SUIT_ShortcutTree::ColumnIdx::Name);
  f.setBold(theIsFolder);
  setFont(SUIT_ShortcutTree::ColumnIdx::Name, f);
}

void SUIT_ShortcutTreeItem::styleAsKeySequenceModified(bool theIsModified)
{
  if (!isAction())
    return;

  static const QBrush bgHighlitingBrush = QBrush(Qt::darkGreen);
  static const QBrush fgHighlitingBrush = QBrush(Qt::white);
  static const QBrush noBrush = QBrush();

  setBackground(SUIT_ShortcutTree::ColumnIdx::KeySequence, theIsModified ? bgHighlitingBrush : noBrush);
  setForeground(SUIT_ShortcutTree::ColumnIdx::KeySequence, theIsModified ? fgHighlitingBrush : noBrush);

  { // Style ascendant folders as "descendant' key sequence is modified".
    SUIT_ShortcutTreeItem* ascendant = dynamic_cast<SUIT_ShortcutTreeItem*>(parent());
    while (ascendant) {
      ascendant->setBackground(SUIT_ShortcutTree::ColumnIdx::Name, theIsModified ? bgHighlitingBrush : noBrush);
      ascendant->setForeground(SUIT_ShortcutTree::ColumnIdx::Name, theIsModified ? fgHighlitingBrush : noBrush);
      ascendant = dynamic_cast<SUIT_ShortcutTreeItem*>(ascendant->parent());
    }
  }
}

void SUIT_ShortcutTreeItem::setExpanded(bool theVal)
{
  myIsExpanded = theVal;
  QTreeWidgetItem::setExpanded(myIsExpanded);
}

bool SUIT_ShortcutTreeItem::isExpanded() const
{
  return myIsExpanded;
}


SUIT_ShortcutTreeHeaderItem::SUIT_ShortcutTreeHeaderItem(const std::map<SUIT_ShortcutTree::SortKey, Qt::SortOrder>& theSortSchema, SUIT_ShortcutTree::ColumnIdx theLeadingColIdx)
: QTreeWidgetItem()
{
  setText(SUIT_ShortcutTree::ColumnIdx::Name, SUIT_ShortcutTree::tr("Action"));
  setText(SUIT_ShortcutTree::ColumnIdx::ToolTip, SUIT_ShortcutTree::tr("Description"));
  setText(SUIT_ShortcutTree::ColumnIdx::KeySequence, SUIT_ShortcutTree::tr("Key sequence"));
  setSortSchemaAndLeadingColIdx(theSortSchema, theLeadingColIdx);
}

void SUIT_ShortcutTreeHeaderItem::setSortSchemaAndLeadingColIdx(const std::map<SUIT_ShortcutTree::SortKey, Qt::SortOrder>& theSortSchema, SUIT_ShortcutTree::ColumnIdx theLeadingColIdx)
{
  static const QIcon ICON_ASCENDING_ORDER = QIcon(":/resources/sort_ascending.svg");
  static const QIcon ICON_DESCENDING_ORDER = QIcon(":/resources/sort_descending.svg");
  static const QIcon ICON_ASCENDING_ORDER_LEADING = QIcon(":/resources/sort_ascending_leading_key.svg");
  static const QIcon ICON_DESCENDING_ORDER_LEADING = QIcon(":/resources/sort_descending_leading_key.svg");

  for (const auto& keyAndOrder : theSortSchema) {
    const auto colIdx = SUIT_ShortcutTree::toColumnIdx(keyAndOrder.first);
    if (colIdx >= SUIT_ShortcutTree::ColumnIdx::NotExist)
      continue;

    if (colIdx == theLeadingColIdx)
      setIcon(colIdx, keyAndOrder.second == Qt::SortOrder::AscendingOrder ? ICON_ASCENDING_ORDER_LEADING : ICON_DESCENDING_ORDER_LEADING);
    else
      setIcon(colIdx, keyAndOrder.second == Qt::SortOrder::AscendingOrder ? ICON_ASCENDING_ORDER : ICON_DESCENDING_ORDER);
  }
}