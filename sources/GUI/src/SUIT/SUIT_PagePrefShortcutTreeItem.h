// Copyright (C) 2007-2026  CEA, EDF, OPEN CASCADE
//
// Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
// CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

#ifndef SUIT_PAGEPREFSHORTCUTTREEITEM_H
#define SUIT_PAGEPREFSHORTCUTTREEITEM_H

#include "SUIT.h"
#include <QtxPagePrefMgr.h>

#include <map>
#include <memory>


class SUIT_ShortcutTree;
class SUIT_ShortcutContainer;


class SUIT_EXPORT SUIT_PagePrefShortcutTreeItem : public QtxPagePrefItem
{
public:
  SUIT_PagePrefShortcutTreeItem(QtxPreferenceItem* theParent);
  virtual ~SUIT_PagePrefShortcutTreeItem() = default;

  virtual void     retrieve();
  virtual void     retrieveDefault();
  virtual void     store();

private:
  // { root item (preference window), shortcut container of synchronized SUIT_ShortcutTabWidgets (widgets within the same window) }
  static std::map<QtxPreferenceItem*, std::weak_ptr<SUIT_ShortcutContainer>> shortcutContainers;
  /** Why is this?
   * Every QtxPagePrefMgr is eventually a preference window. Each preference window has button "Apply".
   * When the button is pressed, all descendants of the QtxPagePrefMgr store changes they carry into preferences.
   * The pitfall with SUIT_ShortcutTabWidgets is as follows: made in independent instance of SUIT_ShortcutTabWidget, changes may conflict,
   * and merge of such changes is ambiguous. And the solution is to keep SUIT_ShortcutTabWidgets within the same window
   * synchronized - all changes being made in a SUIT_ShortcutTabWidget of a synchronized bundle are projected to other SUIT_ShortcutTabWidgets from the bundle
   * without interacting with SUIT_ShortcutMgr.
   *
   * Every time shortcut preferences stored to the ShortcutMgr, all instances of SUIT_ShortcutTabWidget are updated.
  */
};

#endif // SUIT_PAGEPREFSHORTCUTTREEITEM_H