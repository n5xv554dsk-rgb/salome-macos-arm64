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

#include "SUIT_FindActionDialog.h"
#include "Tools/SUIT_extensions.h"

#include <QAction>
#include <QWidget>
#include <QLayout>
#include <QList>
#include <QMap>
#include <QApplication>

#include <QCollator>

#include <QCheckBox>
#include <QLineEdit>
#include <QBrush>
#include <QColor>
#include <QHeaderView>
#include <QKeyEvent>

#include <algorithm>
#include <limits>


SUIT_FindActionDialog::SUIT_FindActionDialog(QWidget* theParent)
: QDialog(theParent)
{
  setMinimumWidth(800);
  setWindowTitle(tr("Find action"));

  QVBoxLayout* layout = new QVBoxLayout(this);

  const auto callback = std::bind(&SUIT_FindActionDialog::executeAction, this, std::placeholders::_1, std::placeholders::_2);
  myFindActionWidget = new SUIT_FindActionWidget(this, std::move(callback), tr("Double click to start."), false /*theEnableItemsOfUnavailableActions*/);
  layout->addWidget(myFindActionWidget);
}

void SUIT_FindActionDialog::setActiveModuleID(const QString& theModuleID)
{
  myFindActionWidget->setIncludedModuleIDs({theModuleID});
}

void SUIT_FindActionDialog::executeAction(const QString& theModuleID, const QString& theInModuleActionID)
{
  bool atLeastOneActionTriggered = false;
  const auto& actions = SUIT_ShortcutMgr::get()->getActions(theModuleID, theInModuleActionID);
  for (const auto& action : actions) {
    if (action->isEnabled()) {
      action->trigger();
      atLeastOneActionTriggered = true;
    }
  }

  if (atLeastOneActionTriggered)
    accept();
}


SUIT_FindActionWidget::SUIT_FindActionWidget(
  QWidget* theParent,
  const std::function<void(const QString&, const QString&)> theCallback,
  const QString& theActionItemToolTip,
  bool theEnableItemsOfUnavailableActions,
  bool theShowKeySequenceColumn,
  const std::function<std::pair<QString, bool>(const QString&, const QString&)>& theKeySequenceGetter
) : QWidget(theParent), myCallback(theCallback)
{
  QVBoxLayout* layout = new QVBoxLayout(this);

  myQueryLineEdit = new QLineEdit(this);
  layout->addWidget(myQueryLineEdit);
  myQueryLineEdit->setSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::Fixed);
  setFocusProxy(myQueryLineEdit);

  QHBoxLayout* searchOptionsLayout = new QHBoxLayout(this);
  layout->addLayout(searchOptionsLayout);
  myIncludeUnavailableActionsCB = new QCheckBox(tr("Unavailable actions"), this);
  myIncludeUnavailableActionsCB->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  myIncludeUnavailableActionsCB->setCheckState(Qt::CheckState::Checked);

  { // Setup ActionSearcher.
    if (theKeySequenceGetter) {
      myActionSearcher.setKeySequenceGetter(
        [theKeySequenceGetter](const QString& theModuleID, const QString& theInModuleActionID) {
          return theKeySequenceGetter(theModuleID, theInModuleActionID).first;
        },
        true /*doNotUpdateResults*/
      );
    }

    auto fieldsToMatch = std::set<SUIT_ActionSearcher::MatchField>({ SUIT_ActionSearcher::MatchField::Name, SUIT_ActionSearcher::MatchField::ToolTip });
    if (theShowKeySequenceColumn)
      fieldsToMatch.emplace(SUIT_ActionSearcher::MatchField::KeySequence);

    myActionSearcher.setFieldsToMatch(fieldsToMatch, true /*doNotUpdateResults*/);
    myActionSearcher.includeDisabledActions(true, true /*doNotUpdateResults*/);
  }

  myIncludeInactiveModulesCB = new QCheckBox(tr("Inactive modules"), this);
  myIncludeInactiveModulesCB->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  myIncludeInactiveModulesCB->setCheckState(Qt::CheckState::Unchecked);
  searchOptionsLayout->addWidget(myIncludeUnavailableActionsCB);
  searchOptionsLayout->addWidget(myIncludeInactiveModulesCB);

  myFoundActionsTree = new SUIT_FoundActionTree(this, theActionItemToolTip, theEnableItemsOfUnavailableActions, theShowKeySequenceColumn, theKeySequenceGetter);
  layout->addWidget(myFoundActionsTree);

  connect(myQueryLineEdit, SIGNAL(textChanged(const QString&)), this, SLOT(onQueryChanged(const QString&)));
  connect(myIncludeUnavailableActionsCB, SIGNAL(stateChanged(int)), this, SLOT(onSearchOptionUnavailableActionsChanged(int)));
  connect(myIncludeInactiveModulesCB, SIGNAL(stateChanged(int)), this, SLOT(onSearchOptionInactiveModulesChanged(int)));

  myQueryLineEdit->installEventFilter(myFoundActionsTree);
}

/*! \brief No need to call it, if expected search result changes are triggered by interaction with subwidgets. */
void SUIT_FindActionWidget::updateUI()
{
  myFoundActionsTree->updateItems(myActionSearcher.getSearchResults());
}

void SUIT_FindActionWidget::setColumnWidth(int theColumnIdx, int theColumnWidth)
{
  myFoundActionsTree->setColumnWidth(theColumnIdx, theColumnWidth);
}

void SUIT_FindActionWidget::showOptions(bool theToShow)
{
  myIncludeUnavailableActionsCB->setVisible(theToShow);
  myIncludeInactiveModulesCB->setVisible(theToShow);
}

void SUIT_FindActionWidget::setIncludedModuleIDs(const std::set<QString>& theModuleIDs, bool doNotUpdateResults)
{
  myIncludedModuleIDs = theModuleIDs;
  myIncludedModuleIDs.emplace(SUIT_ShortcutMgr::ROOT_MODULE_ID);

  if (myActionSearcher.setIncludedModuleIDs(myIncludedModuleIDs, doNotUpdateResults))
    updateUI();
}

const std::set<QString>& SUIT_FindActionWidget::getIncludedModuleIDs() const
{
  return myIncludedModuleIDs;
}

void SUIT_FindActionWidget::onQueryChanged(const QString& theQuery)
{
  if (myActionSearcher.setQuery(theQuery))
    updateUI();
}

void SUIT_FindActionWidget::onSearchOptionUnavailableActionsChanged(int theState)
{
  if (myActionSearcher.includeDisabledActions(theState == Qt::CheckState::Checked))
    updateUI();
}

void SUIT_FindActionWidget::onSearchOptionInactiveModulesChanged(int theState)
{
  bool resultsChanged = false;
  if (theState == Qt::CheckState::Checked) {
    myIncludeUnavailableActionsCB->setDisabled(true);
    myIncludeUnavailableActionsCB->setCheckState(Qt::CheckState::Checked);
    resultsChanged = myActionSearcher.setIncludedModuleIDs(SUIT_ShortcutMgr::get()->getShortcutContainer().getIDsOfAllModules());
  }
  else {
    myIncludeUnavailableActionsCB->setDisabled(false);
    resultsChanged = myActionSearcher.setIncludedModuleIDs(myIncludedModuleIDs);
  }

  if (resultsChanged)
    updateUI();
}


/*static*/ const QList<std::pair<SUIT_FoundActionTree::SortKey, Qt::SortOrder>> SUIT_FoundActionTree::DEFAULT_SORT_SCHEMA =
{
  {SUIT_FoundActionTree::SortKey::MatchMetrics, Qt::SortOrder::AscendingOrder},
  {SUIT_FoundActionTree::SortKey::Name, Qt::SortOrder::AscendingOrder},
  {SUIT_FoundActionTree::SortKey::ToolTip, Qt::SortOrder::AscendingOrder},
  {SUIT_FoundActionTree::SortKey::ID, Qt::SortOrder::AscendingOrder},
  {SUIT_FoundActionTree::SortKey::KeySequence, Qt::SortOrder::AscendingOrder}
};

/*! \brief Default key sequence getter.
  \returns {keySequence, false} */
/*static*/ std::pair<QString, bool> SUIT_FoundActionTree::getKeySequenceFromShortcutMgr(const QString& theModuleID, const QString& theInModuleActionID)
{
  return std::pair<QString, bool>(SUIT_ShortcutMgr::get()->getKeySequence(theModuleID, theInModuleActionID).toString(), false);
}

/*! \param theKeySequenceGetter If default or empty, SUIT_FoundActionTree::getKeySequenceFromShortcutMgr is used.*/
SUIT_FoundActionTree::SUIT_FoundActionTree(
  SUIT_FindActionWidget* theParent,
  const QString& theActionItemToolTip,
  bool theEnableItemsOfUnavailableActions,
  bool theShowKeySequenceColumn,
  const std::function<std::pair<QString, bool>(const QString&, const QString&)>& theKeySequenceGetter
) : QTreeWidget(theParent), myEnableItemsOfUnavailableActions(theEnableItemsOfUnavailableActions),
myActionItemToolTip(theActionItemToolTip), myShowKeySequenceColumn(theShowKeySequenceColumn),
myKeySequenceGetter(theKeySequenceGetter ? theKeySequenceGetter : std::bind(&SUIT_FoundActionTree::getKeySequenceFromShortcutMgr, std::placeholders::_1, std::placeholders::_2))
{
  setColumnCount(myShowKeySequenceColumn ? 3 : 2);
  setSelectionMode(QAbstractItemView::SingleSelection);
  setSortingEnabled(false);
  header()->setSectionResizeMode(QHeaderView::Interactive);
  {
    QMap<int, QString> labelMap;
    labelMap[SUIT_FoundActionTree::ColumnIdx::Name]    = SUIT_FindActionWidget::tr("Action");
    labelMap[SUIT_FoundActionTree::ColumnIdx::ToolTip] = SUIT_FindActionWidget::tr("Description");
    if (myShowKeySequenceColumn)
      labelMap[SUIT_FoundActionTree::ColumnIdx::KeySequence] = SUIT_FindActionWidget::tr("Key sequence");

    setHeaderLabels(labelMap.values());
  }
  setExpandsOnDoubleClick(false); // Implemented manually.
  setSizeAdjustPolicy(QAbstractScrollArea::AdjustToContents);
  setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);

  setColumnWidth(SUIT_FoundActionTree::ColumnIdx::Name, 350);
  setColumnWidth(SUIT_FoundActionTree::ColumnIdx::ToolTip, 500);
  setColumnWidth(SUIT_FoundActionTree::ColumnIdx::KeySequence, 150);
  setMinimumHeight(300);

  setWindowFlags(windowFlags() | Qt::FramelessWindowHint);

  mySortKey = SUIT_FoundActionTree::SortKey::MatchMetrics;
  mySortOrder = Qt::SortOrder::AscendingOrder;

  connect(this, SIGNAL(itemDoubleClicked(QTreeWidgetItem*, int)), this, SLOT(onItemExecuted(QTreeWidgetItem*, int)));
}

void SUIT_FoundActionTree::updateItems(const std::map<QString, std::map<QString, SUIT_ActionSearcher::AssetsAndSearchData>>& theActionAssetsAndSD)
{
  std::set<QString> shownModuleIDs; // To sort module-items by their IDs.

  // Remove shown module items, if updated search results have no matching actions from these modules.
  for (int moduleIdx = 0; moduleIdx < topLevelItemCount(); ) {
    SUIT_FoundActionTreeModule* moduleItem = static_cast<SUIT_FoundActionTreeModule*>(topLevelItem(moduleIdx));
    myModuleItemExpansionStates[moduleItem->myModuleID] = moduleItem->isExpanded();

    const auto itUpdatedAssetsOfShownModule = theActionAssetsAndSD.find(moduleItem->myModuleID);
    if (itUpdatedAssetsOfShownModule == theActionAssetsAndSD.end()) {
      delete takeTopLevelItem(moduleIdx);
      continue;
    }

    if (itUpdatedAssetsOfShownModule->second.empty()) {
      delete takeTopLevelItem(moduleIdx);
      continue;
    }

    shownModuleIDs.emplace(moduleItem->myModuleID);
    moduleIdx++;
  }

  const auto shortcutMgr = SUIT_ShortcutMgr::get();
  const QString lang = SUIT_ShortcutMgr::currentLang();

  const auto findActionWidget = static_cast<const SUIT_FindActionWidget*>(parentWidget());
  SUIT_FoundActionTreeAction* preselectedActionItem = nullptr;

  for (const auto& moduleIDAndActionAssetsAndSD : theActionAssetsAndSD) {
    const QString& moduleID = moduleIDAndActionAssetsAndSD.first;
    const auto& moduleActionAssetsAndSD = moduleIDAndActionAssetsAndSD.second;
    if (moduleActionAssetsAndSD.empty())
      continue;

    const auto moduleItemAndIdx = findModuleItem(moduleID);
    SUIT_FoundActionTreeModule* moduleItem = moduleItemAndIdx.first;
    if (!moduleItem) {
      moduleItem = new SUIT_FoundActionTreeModule(moduleID);

      const auto moduleAssets = shortcutMgr->getModuleAssets(moduleID);
      if (moduleAssets)
        moduleItem->setAssets(*moduleAssets, lang);
      else
        ShCutDbg("SUIT_FoundActionTree can't retrieve module assets of \"" + moduleID + "\" from ShortcutMgr.");

      const auto& includedModuleIDs = findActionWidget->getIncludedModuleIDs();
      if (includedModuleIDs.find(moduleID) == includedModuleIDs.end())
        moduleItem->styleAsDimmed();

      const auto emplaceRes = shownModuleIDs.emplace(moduleID);
      insertTopLevelItem(::SUIT_tools::distanceFromBegin(shownModuleIDs, emplaceRes.first), moduleItem);

      moduleItem->setFlags(Qt::ItemIsEnabled);

      const auto itExpansionState = myModuleItemExpansionStates.find(moduleID);
      if (itExpansionState == myModuleItemExpansionStates.end())
        moduleItem->setExpanded(true); // Make module item expanded at first appearance.
      else
        moduleItem->setExpanded(itExpansionState->second);
    }
    else /* if the tree has the module-item */ {
      const auto actionItems = moduleItem->takeChildren();
      for (const auto actionItem : actionItems) {
        delete actionItem;
      }
    }

    // Fill module item with action items.
    auto sortedActionItems = createActionSetWithComparator();
    for (const auto& actionIDAndAssetsAndSD : moduleActionAssetsAndSD) {
      const QString& inModuleActionID = actionIDAndAssetsAndSD.first;
      const SUIT_ActionSearcher::AssetsAndSearchData& assetsAndSearchData = actionIDAndAssetsAndSD.second;

      auto actionItem = SUIT_FoundActionTreeAction::create(moduleID, inModuleActionID);
      if (!actionItem) {
        ShCutDbg("SUIT_FoundActionTree can't create child item for action ID = \"" + SUIT_ShortcutMgr::makeActionID(moduleID, inModuleActionID) + "\".");
        continue;
      }

      actionItem->setAssetsAndSearchData(assetsAndSearchData, lang);
      if (myShowKeySequenceColumn) {
        const auto KSAndToStyle = myKeySequenceGetter(moduleID, inModuleActionID);
        actionItem->setKeySequence(KSAndToStyle.first);
        actionItem->styleAsKeySequenceModified(KSAndToStyle.second);
      }

      sortedActionItems.emplace(actionItem);
    }

    SUIT_FoundActionTreeAction* preselectedActionItemCand = nullptr;
    for (const auto actionItem : sortedActionItems) {
      moduleItem->addChild(actionItem);
      actionItem->setToolTip(myActionItemToolTip);

      // Consider first ranked available action in the module (if user did not collapsed it) as a candidate for preselected action.
      if (!preselectedActionItemCand && moduleItem->isExpanded() && actionItem->isEnabledBufferedValue())
        preselectedActionItemCand = actionItem;
    }

    if (preselectedActionItem) {
      if (preselectedActionItemCand) {
        if (preselectedActionItemCand->matchMetrics() < preselectedActionItem->matchMetrics())
          preselectedActionItem = preselectedActionItemCand;
      }
    }
    else
      preselectedActionItem = preselectedActionItemCand;
  }

  if (preselectedActionItem)
    setCurrentItem(preselectedActionItem);
}

void SUIT_FoundActionTree::sort(SUIT_FoundActionTree::SortKey theKey, Qt::SortOrder theOrder)
{
  if (theKey == mySortKey && theOrder == mySortOrder)
    return;

  mySortKey = theKey;
  mySortOrder = theOrder;

  for (int moduleIdx = 0; moduleIdx < topLevelItemCount(); moduleIdx++) {
    const auto moduleItem = static_cast<SUIT_FoundActionTreeModule*>(topLevelItem(moduleIdx));

    auto sortedActionItems = createActionSetWithComparator();
    for (int childIdx = 0; childIdx < moduleItem->childCount(); childIdx++) {
      SUIT_FoundActionTreeAction* const actionItem = static_cast<SUIT_FoundActionTreeAction*>(moduleItem->child(childIdx));
      sortedActionItems.emplace(actionItem);
    }

    moduleItem->takeChildren();

    for (const auto actionItem : sortedActionItems) {
      moduleItem->addChild(actionItem);
    }
  }
}

void SUIT_FoundActionTree::keyPressEvent(QKeyEvent* theEvent)
{
  const auto key = theEvent->key();
  const auto selectedItem = currentItem();
  if ((key == Qt::Key_Enter || key == Qt::Key_Return) && selectedItem)
    onItemExecuted(selectedItem, SUIT_FoundActionTree::ColumnIdx::Name);
  else
    QTreeWidget::keyPressEvent(theEvent);
}

bool SUIT_FoundActionTree::eventFilter(QObject* theQObject, QEvent* theEvent)
{
  if (theEvent->type() == QEvent::KeyPress) {
    QKeyEvent* const keyEvent = static_cast<QKeyEvent*>(theEvent);
    const auto key = keyEvent->key();

    if (key == Qt::Key_Enter || key == Qt::Key_Return || key == Qt::Key_Up || key == Qt::Key_Down) {
      keyPressEvent(keyEvent);
      return true;
    }
  }

  return false;
}

std::pair<SUIT_FoundActionTreeModule*, int> SUIT_FoundActionTree::findModuleItem(const QString& theModuleID) const
{
  for (int moduleIdx = 0; moduleIdx < topLevelItemCount(); moduleIdx++) {
    SUIT_FoundActionTreeModule* moduleItem = static_cast<SUIT_FoundActionTreeModule*>(topLevelItem(moduleIdx));
    if (moduleItem->myModuleID == theModuleID)
      return std::pair<SUIT_FoundActionTreeModule*, int>(moduleItem, moduleIdx);
  }
  return std::pair<SUIT_FoundActionTreeModule*, int>(nullptr, -1);
}

template <typename Float>
bool approximatelyEqual(Float a, Float b, Float relativeTol = std::numeric_limits<Float>::epsilon())
{
    return std::abs(a - b) <= ( (std::abs(a) < std::abs(b) ? std::abs(b) : std::abs(a)) * relativeTol);
}

std::set<SUIT_FoundActionTreeAction*, std::function<bool(SUIT_FoundActionTreeAction*, SUIT_FoundActionTreeAction*)>> SUIT_FoundActionTree::createActionSetWithComparator() const
{
  QList<std::pair<SUIT_FoundActionTree::SortKey, Qt::SortOrder>> sortSchema = SUIT_FoundActionTree::DEFAULT_SORT_SCHEMA;
  {
    for (auto itSameKey = sortSchema.begin(); itSameKey != sortSchema.end(); itSameKey++) {
      if (itSameKey->first == mySortKey) {
        sortSchema.erase(itSameKey);
        break;
      }
    }
    sortSchema.push_front(std::pair<SUIT_FoundActionTree::SortKey, Qt::SortOrder>(mySortKey, mySortOrder));
  }

  const std::function<bool(SUIT_FoundActionTreeAction*, SUIT_FoundActionTreeAction*)> comparator =
  [sortSchema](const SUIT_FoundActionTreeAction* theItemA, const SUIT_FoundActionTreeAction* theItemB) {
    const auto collator = QCollator();
    for (const auto& keyAndOrder : sortSchema) {
      const QVariant fieldOfA = theItemA->getValue(keyAndOrder.first);
      const QVariant fieldOfB = theItemB->getValue(keyAndOrder.first);

      bool* const fieldOfAIsDouble = new bool(false);
      bool* const fieldOfBIsDouble = new bool(false);
      const double matchMetricsA = fieldOfA.toDouble(fieldOfAIsDouble);
      const double matchMetricsB = fieldOfB.toDouble(fieldOfBIsDouble);
      if (*fieldOfAIsDouble && *fieldOfBIsDouble) {
        if (!approximatelyEqual(matchMetricsA, matchMetricsB)) {
          const double res = matchMetricsA - matchMetricsB;
          return keyAndOrder.second == Qt::SortOrder::AscendingOrder ? res < 0 : res > 0;
        }
      }
      else {
        const int res = collator.compare(fieldOfA.toString(), fieldOfB.toString());
        if (res != 0)
          return keyAndOrder.second == Qt::SortOrder::AscendingOrder ? res < 0 : res > 0;
      }
    }
    return false;
  };

  return std::set<SUIT_FoundActionTreeAction*, std::function<bool(SUIT_FoundActionTreeAction*, SUIT_FoundActionTreeAction*)>>(comparator);
}

void SUIT_FoundActionTree::onItemExecuted(QTreeWidgetItem* theItem, int theColIdx)
{
  const auto parent = static_cast<SUIT_FindActionWidget*>(parentWidget());
  SUIT_FoundActionTreeItem* const item = static_cast<SUIT_FoundActionTreeItem*>(theItem);

  if (item->type() == SUIT_FoundActionTreeItem::Type::Action) {
    SUIT_FoundActionTreeAction* const actionItem = static_cast<SUIT_FoundActionTreeAction*>(theItem);
    parent->myCallback(actionItem->myModuleID, actionItem->myInModuleActionID);
  }
  else /* if (item->type() == SUIT_FoundActionTreeItem::Type::Module) */ {
    item->setExpanded(!item->isExpanded());
  }
}


/*! \param theTree must not be nullptr. */
SUIT_FoundActionTreeItem::SUIT_FoundActionTreeItem(const QString& theModuleID)
: QTreeWidgetItem(), myModuleID(theModuleID)
{ }

QString SUIT_FoundActionTreeItem::name() const
{
  return text(SUIT_FoundActionTree::ColumnIdx::Name);
}

QString SUIT_FoundActionTreeItem::toolTip() const
{
  return text(SUIT_FoundActionTree::ColumnIdx::ToolTip);
}

void SUIT_FoundActionTreeItem::styleAsDimmed() {
  static const QBrush greyedOutBrush = QBrush(Qt::gray);
  setForeground(SUIT_FoundActionTree::ColumnIdx::Name,    greyedOutBrush);
  setForeground(SUIT_FoundActionTree::ColumnIdx::ToolTip, greyedOutBrush);
}


SUIT_FoundActionTreeModule::SUIT_FoundActionTreeModule(const QString& theModuleID)
: SUIT_FoundActionTreeItem(theModuleID)
{
  QFont f = font(SUIT_FoundActionTree::ColumnIdx::Name);
  f.setBold(true);
  setFont(SUIT_FoundActionTree::ColumnIdx::Name, f);
  setText(SUIT_FoundActionTree::ColumnIdx::Name, theModuleID);
}

void SUIT_FoundActionTreeModule::setAssets(const SUIT_ShortcutModuleAssets& theAssets, const QString& theLang)
{
  setText(SUIT_FoundActionTree::ColumnIdx::Name, theAssets.bestName(theLang));
  setIcon(SUIT_FoundActionTree::ColumnIdx::Name, theAssets.myIcon);
}

QVariant SUIT_FoundActionTreeModule::getValue(SUIT_FoundActionTree::SortKey theKey) const
{
  switch (theKey) {
    case SUIT_FoundActionTree::SortKey::MatchMetrics:
      return double(0);
    case SUIT_FoundActionTree::SortKey::ID:
      return myModuleID;
    case SUIT_FoundActionTree::SortKey::Name:
      return name();
    case SUIT_FoundActionTree::SortKey::ToolTip:
      return toolTip();
    default:
      return QString();
  }
}


SUIT_FoundActionTreeAction::SUIT_FoundActionTreeAction(const QString& theModuleID, const QString& theInModuleActionID)
: SUIT_FoundActionTreeItem(theModuleID), myInModuleActionID(theInModuleActionID),
  myMatchMetrics(std::numeric_limits<double>::infinity()), myIsEnabledBufferedValue(false)
{
  setText(SUIT_FoundActionTree::ColumnIdx::Name, theInModuleActionID);
}

/*static*/ SUIT_FoundActionTreeAction* SUIT_FoundActionTreeAction::create(const QString& theModuleID, const QString& theInModuleActionID)
{
  if (theInModuleActionID.isEmpty()) {
    ShCutDbg("SUIT_FoundActionTreeItem: attempt to create item with empty action ID.");
    return nullptr;
  }

  return new SUIT_FoundActionTreeAction(theModuleID, theInModuleActionID);
}

void SUIT_FoundActionTreeAction::setAssetsAndSearchData(const SUIT_ActionSearcher::AssetsAndSearchData& theAssetsAndSD, const QString& theLang)
{
  if (!theAssetsAndSD.myAssets)
    return;

  setText(SUIT_FoundActionTree::ColumnIdx::Name, theAssetsAndSD.myAssets->bestPath(theLang));
  setIcon(SUIT_FoundActionTree::ColumnIdx::Name, theAssetsAndSD.myAssets->icon());
  setText(SUIT_FoundActionTree::ColumnIdx::ToolTip, theAssetsAndSD.myAssets->bestToolTip(theLang));
  myMatchMetrics = theAssetsAndSD.matchMetrics();
}

void SUIT_FoundActionTreeAction::setToolTip(const QString& theToolTip)
{
  if (isEnabled()) {
    QTreeWidgetItem::setToolTip(
      SUIT_FoundActionTree::ColumnIdx::Name,
      theToolTip
    );

    QTreeWidgetItem::setToolTip(
      SUIT_FoundActionTree::ColumnIdx::ToolTip,
      theToolTip
    );
  }
  else
    styleAsDimmed();
}

void SUIT_FoundActionTreeAction::setKeySequence(const QString& theKeySequence)
{
  setText(SUIT_FoundActionTree::ColumnIdx::KeySequence, theKeySequence);
}

QString SUIT_FoundActionTreeAction::keySequence() const
{
  return text(SUIT_FoundActionTree::ColumnIdx::KeySequence);
}

void SUIT_FoundActionTreeAction::styleAsKeySequenceModified(bool theIsModified)
{
  static const QBrush bgHighlitingBrush = QBrush(Qt::darkGreen);
  static const QBrush fgHighlitingBrush = QBrush(Qt::white);
  static const QBrush noBrush = QBrush();

  setBackground(SUIT_FoundActionTree::ColumnIdx::KeySequence, theIsModified ? bgHighlitingBrush : noBrush);
  setForeground(SUIT_FoundActionTree::ColumnIdx::KeySequence, theIsModified ? fgHighlitingBrush : noBrush);
}

QVariant SUIT_FoundActionTreeAction::getValue(SUIT_FoundActionTree::SortKey theKey) const
{
  switch (theKey) {
    case SUIT_FoundActionTree::SortKey::MatchMetrics:
      return myMatchMetrics;
    case SUIT_FoundActionTree::SortKey::ID:
      return myInModuleActionID;
    case SUIT_FoundActionTree::SortKey::Name:
      return name();
    case SUIT_FoundActionTree::SortKey::ToolTip:
      return toolTip();
    case SUIT_FoundActionTree::SortKey::KeySequence:
      return keySequence();
    default:
      return QString();
  }
}

bool SUIT_FoundActionTreeAction::isEnabled() const
{
  const auto tree = static_cast<SUIT_FoundActionTree*>(treeWidget());
  if (tree->myEnableItemsOfUnavailableActions) {
    myIsEnabledBufferedValue = true;
    return true;
  }

  const auto& actions = SUIT_ShortcutMgr::get()->getActions(myModuleID, myInModuleActionID);
  myIsEnabledBufferedValue = std::find_if(actions.begin(), actions.end(), [](const QAction* const theAction){ return theAction->isEnabled(); }) != actions.end();
  return myIsEnabledBufferedValue;
}