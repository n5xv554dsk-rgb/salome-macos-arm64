// Copyright (C) 2023-2026  CEA, EDF
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

#pragma once

#include <pqSelectionReaction.h>

#include <vtkSmartPointer.h>
#include <vtkWeakPointer.h>

#include <QCursor>
#include <QPointer>
#include <QTimer>
#include <QPushButton>
#include <QComboBox>

class vtkObject;
class pqView;
class pqRenderView;
class vtkIntArray;
class pqDataRepresentation;
class vtkSMRepresentationProxy;
class vtkSMSourceProxy;

/**
 * SPV3D_CADSelection handles various selection modes available on
 * RenderViews. Simply create multiple instances of
 * SPV3D_CADSelection to handle selection modes for that RenderView.
 * SPV3D_CADSelection uses internal static members to ensure that
 * at most 1 view (and 1 type of selection) is in selection-mode at any given
 * time.
 */
class SPV3D_CADSelection : public QObject
{
  Q_OBJECT

public:
  enum SelectionMode
  {
    SELECT_SOLIDS,
    SELECT_FACES,
    SELECT_EDGES,
    SELECT_VERTICES
  };

  /**
   * If \c view is nullptr, this reaction will track the active-view maintained by
   * pqActiveObjects.
   */
  SPV3D_CADSelection(QObject *parent, pqRenderView* view, SelectionMode mode);
  
  ~SPV3D_CADSelection() override;

  /**
   * Set the selectionMode
   */
  void SetMode(const SPV3D_CADSelection::SelectionMode mode);
  
public Q_SLOTS:
  /**
   * For checkable actions, this calls this->beginSelection() or
   * this->endSelection() is val is true or false, respectively. For
   * non-checkable actions, this call this->beginSelection() and
   * this->endSelection() in that order.
   */
  virtual void actionTriggered(bool val);
  
private Q_SLOTS:
  /**
   * Called when this object was created with nullptr as the view and the active
   * view changes.
   */
  void setView(pqView* view);

  /**
   * Called when the active representation changes.
   */
  void setRepresentation(pqDataRepresentation* representation);

  /**
   * starts the selection i.e. setup render view in selection mode.
   */
  void beginSelection();

  /**
   * finishes the selection. Doesn't cause the selection, just returns the
   * render view to previous interaction mode.
   */
  void endSelection();

  void updateEnableState();

  ///@{
  /**
   * Disable preselection during rotation using the right button.
   */
  void onRightButtonPress();
  void onRightButtonRelease();
  ///@}

private:

  /**
   * callback called when the vtkPVRenderView is done with selection.
   */
  void selectionChanged(vtkObject*, unsigned long, void* calldata);

  /**
   * callback called for mouse move events when in 'interactive selection'
   * modes.
   */
  void onMouseMove();

  /**
   * callback called for click events when in 'interactive selection' modes.
   */
  void onLeftButtonRelease();

  // Get the current state of selection modifier
  int getSelectionModifier();

  /**
   * makes fast selection.
   */
  void fastSelection(bool presel = false);

  /**
   * cleans up observers.
   */
  void cleanupObservers();

  Q_DISABLE_COPY(SPV3D_CADSelection)
  QPointer<pqRenderView> View;
  QPointer<pqDataRepresentation> Representation;
  QMetaObject::Connection RepresentationConnection;
  vtkSMRepresentationProxy* CurrentRepresentation = nullptr;
  SelectionMode Mode;
  int PreviousRenderViewMode;
  vtkWeakPointer<vtkObject> ObservedObject;
  unsigned long ObserverIds[4];
  int MousePosition[2];
  QComboBox* selectionComboBox;
  bool DisablePreSelection = false;
};
