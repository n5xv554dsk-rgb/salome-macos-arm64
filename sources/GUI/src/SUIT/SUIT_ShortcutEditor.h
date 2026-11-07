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

#ifndef SUIT_SHORTCUTEDITOR_H
#define SUIT_SHORTCUTEDITOR_H

#include "SUIT.h"
#include <QDialog>
#include <QFrame>
#include <QTreeWidget>
#include <QHeaderView>
#include <QTabWidget>
#include <QTabBar>
#include <QPainter>
#include "SUIT_ShortcutMgr.h"
#include "SUIT_FindActionDialog.h"
#include <memory>
#include <map>
#include <set>
#include <functional>


class QLineEdit;
class QLabel;
class QPushButton;
class QTreeWidgetItem;

class SUIT_EXPORT SUIT_KeySequenceEdit : public QFrame
{
  Q_OBJECT

public:
  SUIT_KeySequenceEdit(QWidget* = nullptr);
  virtual ~SUIT_KeySequenceEdit() = default;

  /*! \brief Set a key sequence to edit. */
  void setConfirmedKeySequence(const QKeySequence&);
  void setEditedKeySequence(const QKeySequence&);
  QKeySequence   editedKeySequence() const;

  /*! \returns true, if the edited key sequence differs from confirmed one. */
  bool isKeySequenceModified() const;

  /*! \brief Set confirmed key sequence to line editor. */
  void restoreKeySequence();

  /*! \brief Extracts key sequnce string from theEvent. */
  static QString parseEvent(QKeyEvent* theEvent);

  /*! \brief Check if the key event contains a 'valid' key.
  \param theKey Code of the key. */
  static bool isValidKey(int theKey);

signals:
  void editingStarted();


  void editingFinished();
  void restoreFromShortcutMgrClicked();

private slots:
  /*! \brief Called when "Clear" button is clicked. */
  void onClear();

  /*! \brief Called when myKeySequenceLineEdit loses focus. */
  void onEditingFinished();

protected:
  /*! \returns \c true if further event processing should be stopped. */
  virtual bool eventFilter(QObject* theObject, QEvent* theEvent);

private:
  void initialize();

private:
  QLineEdit* myKeySequenceLineEdit;
  QString myConfirmedKeySequenceString;

  // Last valid key sequence string from myKeySequenceLineEdit.
  QString myPrevKeySequenceString;
};

class SUIT_ShortcutTabWidget;
class SUIT_ShortcutTree;
class SUIT_ShortcutTreeItem;
class QTextEdit;


class SUIT_EXPORT SUIT_EditKeySequenceDialog : public QDialog
{
  Q_OBJECT

public:
  /*! \param theParent must not be nullptr. */
  SUIT_EditKeySequenceDialog(SUIT_ShortcutTabWidget* theParent);
  SUIT_EditKeySequenceDialog(const SUIT_EditKeySequenceDialog&) = delete;
  SUIT_EditKeySequenceDialog& operator=(const SUIT_EditKeySequenceDialog&) = delete;
  virtual ~SUIT_EditKeySequenceDialog() = default;

  void setModuleAndActionID(const QString& theModuleID, const QString& theInModuleActionID);
  const QString& moduleID() const;
  const QString& inModuleActionID() const;

  void setModuleAndActionName(const QString& theModuleName, const QString& theActionName, const QString& theActionToolTip = "");

  void setConfirmedKeySequence(const QKeySequence& theSequence);
  QKeySequence editedKeySequence() const;

  /*! \brief Updates message with list of actions, whose shortcuts will be disabled on Confirm. */
  void updateConflictsMessage();

  int exec();

private slots:
  void onEditingStarted();
  void onEditingFinished();
  void onRestoreFromShortcutMgr();
  void onConfirm();

private:
  QString myModuleID;
  QString myInModuleActionID;
  QLabel* myActionName;
  SUIT_KeySequenceEdit* myKeySequenceEdit;
  QTextEdit* myTextEdit;
};


/*! \brief Main element of Shotcut Editor GUI. Each tab presents a shortcut tree of a module. */
class SUIT_EXPORT SUIT_ShortcutTabWidget : public QTabWidget
{
  Q_OBJECT

  friend class SUIT_ShortcutTree;

private:
  /**
   * Ensures that, if several SUIT_ShortcutTab instances coexist,
   * all of them are updated when one of them applies pending changes to SUIT_ShortcutMgr.
   *
   * Sharing of SUIT_ShortcutContainer allows to keep trees in tabs synchronized even without
   * applying changes to SUIT_ShortcutMgr. Why? See SUIT_PagePrefShortcutTreeItem.
   *
   * Access is not synchronized in assumption, that all instances live in the same thread.
  */
  static std::map<SUIT_ShortcutContainer*, std::set<SUIT_ShortcutTabWidget*>> instances;

public:
  /*! \param theContainer Share the same container between several trees,
  to edit them synchronously even without exchange of changes with SUIT_ShortcutMgr.
  Pass nullptr to create non-synchronized tab widget. */
  SUIT_ShortcutTabWidget(
    const std::set<QString>& theIDsOfModulesToShow,
    std::shared_ptr<SUIT_ShortcutContainer> theContainer = std::shared_ptr<SUIT_ShortcutContainer>(),
    QWidget* theParent = nullptr
  );

  SUIT_ShortcutTabWidget& operator=(const SUIT_ShortcutTree&) = delete;
  virtual ~SUIT_ShortcutTabWidget();

  /*! \brief Copies shortcuts from ShortcutMgr. (Re)displays shortcuts of myModuleIDs. */
  void setShortcutsFromManager();

  /*! \brief Copies shortcuts from resources, user files are not accounted. (Re)displays shortcuts of myModuleIDs. */
  void setDefaultShortcuts();

  /*! \brief Applies pending changes to ShortcutMgr. Updates other instances of SUIT_ShortcutTabWidget. */
  void applyChangesToShortcutMgr();

  std::shared_ptr<const SUIT_ShortcutContainer> shortcutContainer() const;

  void onTreeItemDoubleClicked(SUIT_ShortcutTree* theTree, SUIT_ShortcutTreeItem* theItem);

private:
  void jumpToTreeItem(const QString& theModuleID, const QString& theInModuleID);

  /*! \returns Key sequence from the tree and true, if it differs from a keysequence in ShortcutMgr (applied key sequence). */
  std::pair<QString, bool> getConfirmedKeySequence(const QString& theModuleID, const QString& theInModuleActionID) const;

  /*! \param If theUpdateSyncTabWidgets, ShortcutTabWidgets sharing the same shortcut container are updated. */
  void updateTabs(bool theHighlightModifiedTreeItems, bool theUpdateSyncTabWidgets);

public:
  /** Keeps IDs of modules, which will are shown on setShortcutsFromManager(). */
  const std::set<QString> myModuleIDs;

private:
  /** Allows to modify plenty of shortcuts and then apply them to SUIT_ShortcutMgr as a batch. Never nullpt. */
  const std::shared_ptr<SUIT_ShortcutContainer> myShortcutContainer;

  SUIT_FindActionWidget* myFindActionWidget;

  /** {moduleID, SUIT_ShortcutTree}. All tabs share the same SUIT_ShortcutContainer. */
  std::map<QString, SUIT_ShortcutTree*> myModuleTrees;

  SUIT_EditKeySequenceDialog* myEditDialog;
  bool myIsPopulated; // If SUIT_ShortcutTabWidget::updateTabs(bool, bool) was called at least once.
};


class SUIT_ShortcutTabWidgetBar : public QTabBar
{
  Q_OBJECT

public:
  SUIT_ShortcutTabWidgetBar(SUIT_ShortcutTabWidget* theTabWidget);

  void mergeTabModifiedStatuses(const std::map<int, bool>& theTabModifiedStatuses);

protected:
  void paintEvent(QPaintEvent* theEvent);

private:
  /** {tabIdx, isKeySequenceModified}[] */
  std::map<int, bool> myTabModifiedStatuses;
};


class SUIT_EXPORT SUIT_ShortcutTree : public QTreeWidget
{
  Q_OBJECT

  friend class SUIT_ShortcutTabWidget;

public:
  enum ColumnIdx {
    Name,
    KeySequence, // Empty, if item is pure folder item.
    ToolTip,
    /////////////////////////////////////////////////////////////
    NotExist // Columns with the index and greater are not exist.
  };

  enum class SortKey {
    ID,
    Name,
    ToolTip,
    KeySequence,
  };

  static SUIT_FoundActionTree::ColumnIdx toFoundActionTreeColIdx(const SUIT_ShortcutTree::ColumnIdx theColumnIdx);
  static SUIT_ShortcutTree::SortKey toSortKey(const SUIT_ShortcutTree::ColumnIdx theColumnIdx);
  static SUIT_ShortcutTree::ColumnIdx toColumnIdx(const SUIT_ShortcutTree::SortKey theSortKey);
  static const QList<std::pair<SUIT_ShortcutTree::SortKey, Qt::SortOrder>> DEFAULT_SORT_SCHEMA;

private:
  /*!
  \param theParent must not be nullptr.
  \param theAssets must not be nullptr. */
  SUIT_ShortcutTree(
    SUIT_ShortcutTabWidget* theParent,
    std::shared_ptr<const SUIT_ShortcutModuleAssets> theAssets,
    const QString& theLang
  );
  SUIT_ShortcutTree(const SUIT_ShortcutTree&) = delete;
  SUIT_ShortcutTree& operator=(const SUIT_ShortcutTree&) = delete;

public:
  virtual ~SUIT_ShortcutTree() = default;

  SUIT_ShortcutTabWidget* parentTabWidget() const;
  const SUIT_ShortcutContainer& shortcutContainer() const;
  const QString& moduleID() const;

  void setLang(const QString& theLang);
  const QString& name() const;
  const QString& toolTip() const;

  void sort(SUIT_ShortcutTree::SortKey theLeadingKey, Qt::SortOrder theOrder);

private:
  void sortRecursive(QTreeWidgetItem* theParentItem);

  /*! \returns True, if at least one key sequence is modified (differs from applied one). */
  bool updateItems(bool theHighlightModified);

  /*! \returns True, if at least one key sequence is modified (differs from applied one). */
  bool updateChildrenItemsRecursively(
    bool theHighlightModified,
    QTreeWidgetItem* const theItem,
    bool theItemIsInvisibleRoot = false
  );

  /*! \returns True, if key sequence is modified (differs from applied one). */
  bool updateItemShortcut(
    SUIT_ShortcutTreeItem* const theItem,
    const std::map<QString, QKeySequence>& theModuleShortcuts,
    bool theHighlightModified
  ) const;

  SUIT_ShortcutTreeItem* findItem(QStringList theRelativeIDTokens, const QTreeWidgetItem* theAncestorItem = nullptr) const;

  /*! \returns Children of theParentItem being sorted according to current sort mode and order. */
  std::set<SUIT_ShortcutTreeItem*, std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)>> getSortedChildren(QTreeWidgetItem* theParentItem);

  /*! \brief Inserts theChildItem to theParentItem and theSortedChildren.
  Does not check whether theSortedChildren are actually child items of theParentItem.
  Does not check whether current item sort schema is same as one of theSortedChildren. */
  void insertChild(
    QTreeWidgetItem* theParentItem,
    std::set<SUIT_ShortcutTreeItem*, std::function<bool(SUIT_ShortcutTreeItem*, SUIT_ShortcutTreeItem*)>>& theSortedChildren,
    SUIT_ShortcutTreeItem* theChildItem
  );

private slots:
  void onItemExpanded(QTreeWidgetItem* theItem);
  void onItemCollapsed(QTreeWidgetItem* theItem);
  void onHeaderItemClicked(int theColIdx);
  void onItemDoubleClicked(QTreeWidgetItem* theWidgetItem, int theColIdx);

public:
  const std::shared_ptr<const SUIT_ShortcutModuleAssets> myAssets;

private:
  SUIT_ShortcutTabWidget* const myParentTabWidget; // Because dynamic_cast<SUIT_ShortcutTabWidget*>(QWidget::parentWidget()) == nullptr.

  SUIT_ShortcutTree::SortKey myLeadingSortKey;
  std::map<SUIT_ShortcutTree::SortKey, Qt::SortOrder> mySortSchema;

  QString myName;
  QString myToolTip;

  bool myIsPopulated; // If SUIT_ShortcutTree::updateItems(bool) was called at least once.
};


class SUIT_ShortcutTreeItem : public QTreeWidgetItem
{
public:
  /*! \param theAssets must not be nullptr. */
  SUIT_ShortcutTreeItem(const std::shared_ptr<const SUIT_ShortcutItemAssets> theAssets, const QString& theLang);

  void setLang(const QString& theLang);

  const QString& moduleID() const;
  const QString& inModuleID() const;
  const QString& lastTokenOfID() const;
  bool isAction() const;
  bool isFolder() const;

  QString name() const;
  const QString& path() const;
  const QString& toolTip() const;
  QString getValue(SUIT_ShortcutTree::SortKey theKey) const;
  void setKeySequence(const QString& theKeySequence);
  QString keySequence() const;

  void styleAsFolder(bool theIsFolder);
  void styleAsKeySequenceModified(bool theIsModified);

  void setExpanded(bool theVal);
  bool isExpanded() const;

public:
  const std::shared_ptr<const SUIT_ShortcutItemAssets> myAssets;
  bool myIsExpanded;

private:
  QString myPath;
  QString myToolTip;
};


class SUIT_ShortcutTreeHeaderItem : public QTreeWidgetItem
{
public:
  SUIT_ShortcutTreeHeaderItem(const std::map<SUIT_ShortcutTree::SortKey, Qt::SortOrder>& theSortSchema, SUIT_ShortcutTree::ColumnIdx theLeadingColIdx);
  SUIT_ShortcutTreeHeaderItem(const SUIT_ShortcutTreeHeaderItem&) = delete;
  SUIT_ShortcutTreeHeaderItem& operator=(const SUIT_ShortcutTreeHeaderItem&) = delete;
  ~SUIT_ShortcutTreeHeaderItem() = default;

  void setSortSchemaAndLeadingColIdx(const std::map<SUIT_ShortcutTree::SortKey, Qt::SortOrder>& theSortSchema, SUIT_ShortcutTree::ColumnIdx theLeadingColIdx);
};

#endif // SUIT_SHORTCUTEDITOR_H
