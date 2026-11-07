// Copyright (C) 2024-2026  CEA, EDF
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

#include "GeomAnaTool_ExtractBOPFailure.hxx"

#include <BRepCheck.hxx>
#include <BRepCheck_Analyzer.hxx>
#include <Message_Msg.hxx>
#include <Message_Attribute.hxx>
#include <NCollection_BaseAllocator.hxx>
#include <OSD_Timer.hxx>
#include <TopExp_Explorer.hxx>
#include <TopoDS_AlertWithShape.hxx>

static TopTools_DataMapOfShapeListOfShape theMap;

GeomAnaTool_ExtractBOPFailure::GeomAnaTool_ExtractBOPFailure()
  : myReport(new Message_Report)
{
  myShapes.Clear();
  SetDefaults();
}

GeomAnaTool_ExtractBOPFailure::GeomAnaTool_ExtractBOPFailure(const TopTools_ListOfShape& theShapes)
  : myReport(new Message_Report)
{
  SetShapes(theShapes);
  SetDefaults();
}

GeomAnaTool_ExtractBOPFailure::~GeomAnaTool_ExtractBOPFailure()
{
}


void GeomAnaTool_ExtractBOPFailure::SetDefaults()
{
  myCheckGeometry = Standard_True;  // Check topology and geometry
  myUseTimer = Standard_False;      // Do not use any timer
  myRunParallel = Standard_False;   // Run the operation sequentially
  myExactCheck = Standard_False;    // Perform fast check
  myResult.Nullify();               // Clear the result shape
  myErrors.clear();                 // Clear the list of shape errors

  // The following options cannot be changed for this operation
  myNonDestructive = Standard_False;// Work on the shapes directly
  myUseOBB = Standard_False;        // Do not use Oriented Bounding Boxes
  myFuzzy = Precision::Confusion(); // Use the default tolerance
  myGlue = BOPAlgo_GlueOff;         // Do not glue the shapes
}

void GeomAnaTool_ExtractBOPFailure::SetShapes(const TopTools_ListOfShape& theShapes)
{
  myReport->Clear();

  if (theShapes.IsEmpty())
  {
    Message_AlertExtended::AddAlert
      (myReport,
       new Message_Attribute ("Error in SetShapes: the list of shapes is empty"),
       Message_Fail);
    return;
  }

  // Support passing all shapes in a single COMPOUND
  if (theShapes.Extent() == 1)
  {
    TopoDS_Shape aShape = theShapes.First();
    if (aShape.ShapeType() == TopAbs_COMPOUND)
    {
      myShapes.Clear();
      for (TopoDS_Iterator it(aShape); it.More(); it.Next())
      {
        myShapes.Append(it.Value());
      }
      return;
    }
    else
    {
      Message_AlertExtended::AddAlert
        (myReport, new Message_Attribute
         ("Error in SetShapes: the single given shape must be a COMPOUND"),
         Message_Fail);
      return;
    }
  }

  myShapes = theShapes;
}


const TopTools_ListOfShape& GeomAnaTool_ExtractBOPFailure::Shapes() const
{
  return myShapes;
}


void GeomAnaTool_ExtractBOPFailure::SetCheckGeometry(const Standard_Boolean aFlag)
{
  myCheckGeometry = aFlag;
}


Standard_Boolean GeomAnaTool_ExtractBOPFailure::CheckGeometry() const
{
  return myCheckGeometry;
}


void GeomAnaTool_ExtractBOPFailure::SetUseTimer(const Standard_Boolean aFlag)
{
  myUseTimer = aFlag;
}


Standard_Boolean GeomAnaTool_ExtractBOPFailure::UseTimer() const
{
  return myUseTimer;
}


void GeomAnaTool_ExtractBOPFailure::SetRunParallel(const Standard_Boolean aFlag)
{
  myRunParallel = aFlag;
}


Standard_Boolean GeomAnaTool_ExtractBOPFailure::RunParallel() const
{
  return myRunParallel;
}


void GeomAnaTool_ExtractBOPFailure::SetExactCheck(const Standard_Boolean aFlag)
{
  myExactCheck = aFlag;
}


Standard_Boolean GeomAnaTool_ExtractBOPFailure::ExactCheck() const
{
  return myExactCheck;
}


const std::list<GeomAnaTool::ShapeError>& GeomAnaTool_ExtractBOPFailure::ShapeErrors() const
{
  return myErrors;
}


const TopoDS_Shape& GeomAnaTool_ExtractBOPFailure::Result() const
{
  return myResult;
}


void GeomAnaTool_ExtractBOPFailure::Perform_bfillds()
{
  Standard_Integer aNbShapes = myShapes.Extent();
  if (aNbShapes == 0)
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute("No shapes to process"), Message_Fail);
    return;
  }

  Handle(NCollection_BaseAllocator) aAllocator = NCollection_BaseAllocator::CommonBaseAllocator();
  myPaveFiller = std::make_shared<BOPAlgo_PaveFiller>(aAllocator);
  if (!myPaveFiller.get())
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute
       ("BOPAlgo_PaveFiller - Cannot create the pave filler"), Message_Fail);
    return;
  }
  myPaveFiller->SetArguments(myShapes);
  myPaveFiller->SetRunParallel(myRunParallel);
  myPaveFiller->SetNonDestructive(myNonDestructive);
  myPaveFiller->SetFuzzyValue(myFuzzy);
  myPaveFiller->SetGlue(myGlue);
  myPaveFiller->SetUseOBB(myUseOBB);

  OSD_Timer aTimer;
  aTimer.Start();
  myPaveFiller->Perform();
  myReport->Merge(myPaveFiller->GetReport());
  if (myPaveFiller->HasErrors())
  {
    return;
  }
  aTimer.Stop();
  if (myUseTimer)
  {
    char buf[128];
    Sprintf(buf, "PaveFiller - Tps: %7.2lf", aTimer.ElapsedTime());
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute (buf), Message_Info);
  }
}


void GeomAnaTool_ExtractBOPFailure::Perform_bbuild()
{
  BOPDS_PDS pDS = myPaveFiller->PDS();
  if (!pDS)
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute ("BOPDS_DS - Prepare PaveFiller first"),
       Message_Fail);
    return;
  }

  Handle(NCollection_BaseAllocator) aAllocator = NCollection_BaseAllocator::CommonBaseAllocator();
  myBuilder = std::make_shared<BOPAlgo_Builder>(aAllocator);
  if (!myBuilder.get())
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute
       ("BOPAlgo_Builder - Cannot create the builder"),
       Message_Fail);
    return;
  }
  myBuilder->Clear();

  // Add all shapes to the builder
  TopTools_ListIteratorOfListOfShape aIt;
  for (aIt.Initialize(myShapes); aIt.More(); aIt.Next())
  {
    const TopoDS_Shape& aShape = aIt.Value();
    myBuilder->AddArgument(aShape);
  }

  // Set all builder options
  myBuilder->SetRunParallel(myRunParallel);
  myBuilder->SetCheckInverted(Standard_True);
  myBuilder->SetToFillHistory(Standard_False);

  OSD_Timer aTimer;
  aTimer.Start();
  myBuilder->PerformWithFiller(*myPaveFiller); 
  myReport->Merge(myBuilder->GetReport());

  if (myBuilder->HasErrors())
  {
    return;
  }
  aTimer.Stop();
  if (myUseTimer)
  {
    char buf[128];
    Sprintf(buf, "Builder - Tps: %7.2lf", aTimer.ElapsedTime());
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute (buf), Message_Info);
  }

  myResult = myBuilder->Shape();
  if (myResult.IsNull())
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute ("Result is a null shape"), Message_Fail);
  }
}


void GeomAnaTool_ExtractBOPFailure::Perform_checkshape()
{
  if (myResult.IsNull()) 
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute ("Result is a null shape"), Message_Fail);
    return;
  }

  try
  {
    OCC_CATCH_SIGNALS
    BRepCheck_Analyzer anAna (myResult, myCheckGeometry, myRunParallel, myExactCheck);
    Standard_Boolean   isValid = anAna.IsValid();

    if (isValid)
    {
      Message_AlertExtended::AddAlert
        (myReport, new Message_Attribute ("Result shape seems to be valid"),
         Message_Info);
    }
    else
    {
      GeomAnaTool::FillErrors(anAna, myResult, myErrors);
    }
  }
  catch (Standard_Failure const& anException)
  {
    Message_AlertExtended::AddAlert
      (myReport, new Message_Attribute (anException.GetMessageString()), Message_Fail);
  }
}


Standard_Boolean GeomAnaTool_ExtractBOPFailure::HasFailureAlerts() const
{
  const Message_ListOfAlert& aListOfAllert = myReport->GetAlerts(Message_Fail);
  return aListOfAllert.Size() > 0;
}


void GeomAnaTool_ExtractBOPFailure::Perform()
{
  if (HasFailureAlerts())
    return;

  Perform_bfillds();
  if (HasFailureAlerts())
    return;

  Perform_bbuild();
  if (HasFailureAlerts())
    return;

  Perform_checkshape();
}
