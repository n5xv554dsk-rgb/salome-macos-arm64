#include "SUIT_PagePrefShortcutTreeItem.h"

#include "SUIT_ShortcutEditor.h"
#include "SUIT_ShortcutMgr.h"


/*!
  \brief Creates preference item for editing of key bindings
  \param theParent Must not be nullptr.
*/
SUIT_PagePrefShortcutTreeItem::SUIT_PagePrefShortcutTreeItem(QtxPreferenceItem* theParent)
 : QtxPagePrefItem(QString(), theParent)
{
  auto container = std::shared_ptr<SUIT_ShortcutContainer>();
  const auto itContainers = SUIT_PagePrefShortcutTreeItem::shortcutContainers.find(rootItem());
  if (itContainers == SUIT_PagePrefShortcutTreeItem::shortcutContainers.end()) {
    container.reset(new SUIT_ShortcutContainer());
    SUIT_PagePrefShortcutTreeItem::shortcutContainers.emplace(rootItem(), container);
  }
  else {
    container = itContainers->second.lock();
    if (!container) {
      container.reset(new SUIT_ShortcutContainer());
      itContainers->second = container;
    }
  }

  SUIT_ShortcutTabWidget* tabWidget = new SUIT_ShortcutTabWidget(SUIT_ShortcutMgr::get()->getShortcutModuleIDs(), container);
  setWidget(tabWidget);
}

/*!
  \brief Retrieves shortcut preferences from ShortcutMgr.
  Updates UI of controlling widget.
  \sa store()
*/
void SUIT_PagePrefShortcutTreeItem::retrieve()
{
  static_cast<SUIT_ShortcutTabWidget*>(widget())->setShortcutsFromManager();
}

/*!
  \brief Retrieves shortcut preferences from resource files, ignoring user preferences.
  Updates UI of controlling widget.
  \sa store()
*/
void SUIT_PagePrefShortcutTreeItem::retrieveDefault()
{
  static_cast<SUIT_ShortcutTabWidget*>(widget())->setDefaultShortcuts();
}

/*!
  \brief Applies modified shortcut preferences to ShortcutMgr.
  Updates UI of controlling widget.
  And ShortcutMgr, in turn, serilizes shortcut preferences using the resource manager.
  \sa retrieve()
*/
void SUIT_PagePrefShortcutTreeItem::store()
{
  static_cast<SUIT_ShortcutTabWidget*>(widget())->applyChangesToShortcutMgr();
}

/*static*/ std::map<QtxPreferenceItem*, std::weak_ptr<SUIT_ShortcutContainer>> SUIT_PagePrefShortcutTreeItem::shortcutContainers =
std::map<QtxPreferenceItem*, std::weak_ptr<SUIT_ShortcutContainer>>();