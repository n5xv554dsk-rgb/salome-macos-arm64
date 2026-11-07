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

#include "SPV3D_CADSelection.h"

#include <pqActiveObjects.h>
#include <pqRenderView.h>
#include <pqUndoStack.h>
#include <pqCoreUtilities.h>

#include <vtkDataObject.h>
#include <vtkCollection.h>
#include <vtkRenderWindowInteractor.h>
#include <vtkPVRenderView.h>
#include <vtkPVDataInformation.h>
#include <vtkPVArrayInformation.h>
#include <vtkPVRenderViewSettings.h>
#include <vtkSMRenderViewProxy.h>
#include <vtkSMPropertyHelper.h>
#include <vtkSMSessionProxyManager.h>
#include <vtkSMStringVectorProperty.h>
#include <vtkSMRepresentationProxy.h>
#include <vtkPVDataSetAttributesInformation.h>

#include <QDebug>

#include "SPV3D_Prs.h"



//-----------------------------------------------------------------------------
SPV3D_CADSelection::SPV3D_CADSelection(QObject *parent,
  pqRenderView* view, SelectionMode mode):QObject(parent)
{
  this->View = view;
  this->Mode = mode;
  this->PreviousRenderViewMode = -1;
  this->MousePosition[0] = 0;
  this->MousePosition[1] = 0;
  //this->selectionComboBox = comboBox;

  for (size_t i = 0; i < sizeof(this->ObserverIds) / sizeof(this->ObserverIds[0]); ++i)
  {
    this->ObserverIds[i] = 0;
  }

  //QObject::connect(button, SIGNAL(toggled(bool)), this, SLOT(actionTriggered(bool)));

  // if view == nullptr, we track the active view.
  if (view == nullptr)
  {
    QObject::connect(
      &pqActiveObjects::instance(), SIGNAL(viewChanged(pqView*)), this, SLOT(setView(pqView*)));
    // this ensure that the enabled-state is set correctly.
    this->setView(nullptr);
  }

  this->setRepresentation(nullptr);
  QObject::connect(&pqActiveObjects::instance(),
    SIGNAL(representationChanged(pqDataRepresentation*)), this,
    SLOT(setRepresentation(pqDataRepresentation*)));

  vtkPVRenderViewSettings::GetInstance()->SetEnableFastPreselection(true);

  this->updateEnableState();
}

//-----------------------------------------------------------------------------
SPV3D_CADSelection::~SPV3D_CADSelection()
{
  this->cleanupObservers();
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::SetMode(const SPV3D_CADSelection::SelectionMode mode)
{
  this->Mode = mode;
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::updateEnableState()
{
  this->endSelection();

  //auto paction = this->parentAction();
  //bool state = false;
  if (this->Representation)
  {
    vtkSMProxy* proxy = this->Representation->getProxy();
    vtkSMStringVectorProperty* prop =
      vtkSMStringVectorProperty::SafeDownCast(proxy->GetProperty("ColorArrayName"));
    if (prop)
    {
      int association = std::atoi(prop->GetElement(3));
      const char* arrayName = prop->GetElement(4);

      vtkPVDataInformation* dataInfo = this->Representation->getInputDataInformation();

      vtkPVDataSetAttributesInformation* info = nullptr;
      if (association == vtkDataObject::CELL &&
        this->Mode == SELECT_FACES)
      {
        info = dataInfo->GetCellDataInformation();
      }
      if (association == vtkDataObject::POINT &&
        this->Mode == SELECT_VERTICES)
      {
        info = dataInfo->GetPointDataInformation();
      }

      if (info)
      {
        /*vtkPVArrayInformation* arrayInfo = */info->GetArrayInformation(arrayName);
        //state = arrayInfo && arrayInfo->GetDataType() == VTK_ID_TYPE;
      }
    }
  }
  //paction->setEnabled(state);
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::actionTriggered(bool val)
{
  if (val)
  {
    this->beginSelection();
  }
  else
  {
    this->endSelection();
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::setView(pqView* view)
{
  if (this->View != view)
  {
    // if we were currently in selection, finish that before changing the view.
    this->endSelection();
  }

  this->View = qobject_cast<pqRenderView*>(view);

  // update enable state.
  //this->parentAction()->setEnabled(this->View != nullptr);
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::setRepresentation(pqDataRepresentation* representation)
{
  if (this->Representation != representation)
  {
    // if we are currently in selection, finish that before changing the representation.
    this->endSelection();

    if (this->Representation != nullptr)
    {
      QObject::disconnect(this->RepresentationConnection);
    }

    this->Representation = representation;

    if (this->Representation != nullptr)
    {
      this->RepresentationConnection = this->connect(
        this->Representation, SIGNAL(colorArrayNameModified()), SLOT(updateEnableState()));
    }

    // update enable state.
    this->updateEnableState();
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::beginSelection()
{
  if (!this->View)
  {
    return;
  }

  //QAction* actn = this->parentAction();
  //if (actn->isCheckable())
  {
    //this->selectionComboBox->setEnabled(false);

    vtkSMRenderViewProxy* rmp = this->View->getRenderViewProxy();
    vtkSMPropertyHelper(rmp, "InteractionMode").Get(&this->PreviousRenderViewMode);

    //QString currentPrimitive = this->selectionComboBox->currentText();
    pqCoreUtilities::promptUser("SPV3D_CADSelection", QMessageBox::Information,
      "Interactive Selection Information",
      "You are entering interactive selection mode to highlight.\n"
      "Move the mouse point over the dataset to interactively highlight elements.\n\n"
      "Press Ctrl + click to add the currently highlighted element.\n"
      "Press Shift + click to remove the element.\n\n"
      "Click on Select button to exit this mode.",
      QMessageBox::Ok | QMessageBox::Save);
    this->View->setCursor(Qt::CrossCursor);
    vtkSMPropertyHelper(rmp, "InteractionMode").Set(vtkPVRenderView::INTERACTION_MODE_SELECTION);

    rmp->UpdateVTKObjects();

    // Setup observer.
    assert(this->ObserverIds[0] == 0 && this->ObservedObject == nullptr && this->ObserverIds[1] == 0);
    this->ObservedObject = rmp->GetInteractor();
    this->ObserverIds[0] = this->ObservedObject->AddObserver(
      vtkCommand::MouseMoveEvent, this, &SPV3D_CADSelection::onMouseMove);
    this->ObserverIds[1] = this->ObservedObject->AddObserver(vtkCommand::LeftButtonReleaseEvent,
      this, &SPV3D_CADSelection::onLeftButtonRelease);
    this->ObserverIds[2] = this->ObservedObject->AddObserver(vtkCommand::RightButtonPressEvent,
      this, &SPV3D_CADSelection::onRightButtonPress);
    this->ObserverIds[3] = this->ObservedObject->AddObserver(vtkCommand::RightButtonReleaseEvent,
      this, &SPV3D_CADSelection::onRightButtonRelease);

    //this->parentAction()->setChecked(true);
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::endSelection()
{
  if (!this->View)
  {
    return;
  }

  if (this->PreviousRenderViewMode == -1)
  {
    return;
  }

  //QAction* actn = this->parentAction();
  //if (actn->isCheckable())
  {
    vtkSMRenderViewProxy* rmp = this->View->getRenderViewProxy();
    vtkSMPropertyHelper(rmp, "InteractionMode").Set(this->PreviousRenderViewMode);
    this->PreviousRenderViewMode = -1;
    rmp->UpdateVTKObjects();
    this->View->setCursor(QCursor());
    this->cleanupObservers();
    //this->parentAction()->setChecked(false);

    if (this->CurrentRepresentation != nullptr)
    {
      vtkSMSessionProxyManager* pxm = rmp->GetSessionProxyManager();
      vtkSMProxy* emptySel = pxm->NewProxy("sources", "IDSelectionSource");

      this->CurrentRepresentation->UpdateVTKObjects();
      this->CurrentRepresentation = nullptr;
      emptySel->Delete();

      rmp->StillRender();
    }

    //this->selectionComboBox->setEnabled(true);
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::onMouseMove()
{
  if (!this->DisablePreSelection && vtkPVRenderViewSettings::GetInstance()->GetEnableFastPreselection())
  {
    this->fastSelection(true);
  }

  // get preselected id here
  vtkSMProxy* proxyRepresentation = this->Representation->getProxy();
  if (!proxyRepresentation)
  {
    qWarning()<< "There is no representation in the active view for the Geometry Source.";
    return;
  }


  // Retrieve the wanted information property
  vtkSMProperty* PreselectedIDProperty =
    proxyRepresentation->GetProperty("PreSelectedID");
  if (!PreselectedIDProperty)
  {
    qWarning()<< "The representation named '" << proxyRepresentation->GetXMLName()<< "' didn't have a property named 'SelectedIDInfo'.";
    return;
  }

  // Force to update the information property
  proxyRepresentation->UpdatePropertyInformation(PreselectedIDProperty);

  vtkIdType PreSelectedID =
    vtkSMPropertyHelper(proxyRepresentation,"PreSelectedID").GetAsInt(0);
  qInfo() << "entry from client: "<< SPV3D_Prs::FromVtkIdToEntry(PreSelectedID);
  
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::onLeftButtonRelease()
{
  if (vtkPVRenderViewSettings::GetInstance()->GetEnableFastPreselection())
  {
    this->fastSelection();
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::onRightButtonPress()
{
  this->DisablePreSelection = true;
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::onRightButtonRelease()
{
  this->DisablePreSelection = false;
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::fastSelection(bool presel)
{
  vtkSMRenderViewProxy* rmp = this->View->getRenderViewProxy();
  assert(rmp != nullptr);

  int x = rmp->GetInteractor()->GetEventPosition()[0];
  int y = rmp->GetInteractor()->GetEventPosition()[1];
  this->MousePosition[0] = x;
  this->MousePosition[1] = y;

  int region[4] = { x, y, x, y };

  vtkNew<vtkCollection> selectedRepresentations;
  vtkNew<vtkCollection> selectionSources;
  bool status = false;
  // Do the selection on the current region
  switch (this->Mode)
  {
    case SELECT_SOLIDS:
      status = rmp->SelectSurfaceCells(region, selectedRepresentations, selectionSources, false, 0, false, "Solid id");
      break;
    case SELECT_FACES:
      status = rmp->SelectSurfaceCells(region, selectedRepresentations, selectionSources, false, 0, false, "Face id");
      break;
    case SELECT_EDGES:
      status = rmp->SelectSurfaceCells(region, selectedRepresentations, selectionSources, false, 0, false, "Edge id");
      break;
    case SELECT_VERTICES:
      status = rmp->SelectSurfaceCells(region, selectedRepresentations, selectionSources, false, 0, false, "Vertex id");
      break;
    default:
      qCritical("Invalid call to SPV3D_CADSelection::fastSelection");
      return;
  }

  vtkSMRepresentationProxy* repr =
    vtkSMRepresentationProxy::SafeDownCast(selectedRepresentations->GetItemAsObject(0));

  if (repr && !presel)
  {
    repr->InvokeCommand("BeginSelect");
  }

  // If something has been preselected or selected
  if (status)
  {
    vtkSMRepresentationProxy* repr =
      vtkSMRepresentationProxy::SafeDownCast(selectedRepresentations->GetItemAsObject(0));

    // If the selection occurs on a new represention, clean the selection on the
    // current representation before continuing
    if (this->CurrentRepresentation != nullptr && repr != this->CurrentRepresentation)
    {
      vtkSMSessionProxyManager* pxm = repr->GetSessionProxyManager();
      vtkSMProxy* emptySel = pxm->NewProxy("sources", "IDSelectionSource");

      vtkSMPropertyHelper(this->CurrentRepresentation, "Selection").Set(emptySel);
      this->CurrentRepresentation->UpdateVTKObjects();
      emptySel->Delete();
    }

    this->CurrentRepresentation = repr;

    // Set the selection (selection source) to the current representation
    vtkSMSourceProxy* sel = vtkSMSourceProxy::SafeDownCast(selectionSources->GetItemAsObject(0));
    vtkSMPropertyHelper(repr, "Selection").Set(sel);
    repr->UpdateVTKObjects();
  }
  // If nothing has been selected then clean current representation
  // with an "empty" selection source
  else if (this->CurrentRepresentation != nullptr)
  {
    vtkSMSessionProxyManager* pxm = rmp->GetSessionProxyManager();
    vtkSMProxy* emptySel = pxm->NewProxy("sources", "IDSelectionSource");

    vtkSMPropertyHelper(this->CurrentRepresentation, "Selection").Set(emptySel);
    this->CurrentRepresentation->UpdateVTKObjects();
    this->CurrentRepresentation = nullptr;
    emptySel->Delete();
  }

  this->View->forceRender();
  this->View->forceRender();
  // TODO improve this to avoid double render

  if (repr && !presel)
  {
    repr->InvokeCommand("EndSelect");
  }
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::selectionChanged(vtkObject*, unsigned long, void* calldata)
{
  BEGIN_UNDO_EXCLUDE();

  int selectionModifier = this->getSelectionModifier();
  int* region = reinterpret_cast<int*>(calldata);
// Simple version check to change once 5.10 support is dropped
  this->View->selectCellsOnSurface(region, selectionModifier);
  //this->View->selectOnSurface(region, selectionModifier);
  END_UNDO_EXCLUDE();

  this->endSelection();
}

//-----------------------------------------------------------------------------
int SPV3D_CADSelection::getSelectionModifier()
{
  int selectionModifier = pqView::PV_SELECTION_DEFAULT;//this->Superclass::getSelectionModifier();

  vtkSMRenderViewProxy* rmp = this->View->getRenderViewProxy();
  assert(rmp != nullptr);

  bool ctrl = rmp->GetInteractor()->GetControlKey() == 1;
  bool shift = rmp->GetInteractor()->GetShiftKey() == 1;
  selectionModifier = pqView::PV_SELECTION_TOGGLE;

  if (ctrl)
  {
    selectionModifier = pqView::PV_SELECTION_ADDITION;
  }
  else if (shift)
  {
    selectionModifier = pqView::PV_SELECTION_SUBTRACTION;
  }
  return selectionModifier;
}

//-----------------------------------------------------------------------------
void SPV3D_CADSelection::cleanupObservers()
{
  for (size_t i = 0; i < sizeof(this->ObserverIds) / sizeof(this->ObserverIds[0]); ++i)
  {
    if (this->ObservedObject != nullptr && this->ObserverIds[i] > 0)
    {
      this->ObservedObject->RemoveObserver(this->ObserverIds[i]);
    }
    this->ObserverIds[i] = 0;
  }
  this->ObservedObject = nullptr;
}
