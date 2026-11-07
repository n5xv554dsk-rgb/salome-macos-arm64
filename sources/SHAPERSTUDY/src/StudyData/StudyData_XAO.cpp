// Copyright (C) 2019-2026  CEA, EDF
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

#include "StudyData_XAO.h"

#include <XAO_Group.hxx>
#include <XAO_Field.hxx>
#include <XAO_Geometry.hxx>
#include <XAO_XaoExporter.hxx>
#include <XAO_BrepGeometry.hxx>


StudyData_XAO::StudyData_XAO() : myExport(NULL), myImport(NULL), myCurrentElementID(0)
{}

void StudyData_XAO::SetShape(const long long theShapePtr)
{
  myShape = (TopoDS_Shape*)(theShapePtr);
  if (!myExport)
    myExport = new XAO::Xao();
  XAO::BrepGeometry* aGeometry = new XAO::BrepGeometry;
  myExport->setGeometry(aGeometry);
  aGeometry->setTopoDS_Shape(*myShape);
}

static XAO::Dimension GetDimension(const int theSelType) {
  switch(theSelType) {
  case 7: return XAO::VERTEX;
  case 6: return XAO::EDGE;
  case 4: return XAO::FACE;
  case 2: return XAO::SOLID;
  default: return XAO::WHOLE;
  };
  return XAO::WHOLE;
}

int StudyData_XAO::AddGroup(const int theSelType, const std::string theGroupName)
{
  XAO::Group* aNewGroup = myExport->addGroup(GetDimension(theSelType), theGroupName);
  int anID = (int)myGroups.size();
  myGroups[anID] = aNewGroup;
  return anID;
}

void StudyData_XAO::AddGroupSelection(const int theGroupID, const int theSelection)
{
  XAO::Group* aGroup = myGroups[theGroupID];
  std::string aReferenceString = XAO::XaoUtils::intToString(theSelection);
  XAO::Geometry* aGeometry = myExport->getGeometry();
  int anElementID =
    aGeometry->getElementIndexByReference(aGroup->getDimension(), aReferenceString);
  aGroup->add(anElementID);
}

void StudyData_XAO::Export(const std::string theFileName)
{
  myExport->setAuthor("ShaperStudy");

  XAO::XaoExporter::saveToFile(myExport, theFileName, "");
}

int StudyData_XAO::AddField(const int theValType, const int theSelType,
  const int theCompsNum, const std::string theFieldName)
{
  XAO::Field* aNewField = myExport->addField(
    XAO::Type(theValType), GetDimension(theSelType), theCompsNum, theFieldName);
  int anID = (int)myFields.size();
  myFields[anID] = aNewField;
  return anID;
}

void StudyData_XAO::SetFieldComponent(const int theFieldID, const int theCompIndex,
  const std::string theCompName)
{
  myFields[theFieldID]->setComponentName(theCompIndex, theCompName);
}

void StudyData_XAO::AddStep(const int theFieldID, const int theStepID, const int theStampID)
{
  XAO::Step* aNewStep = myFields[theFieldID]->addNewStep(theStepID);
  aNewStep->setStamp(theStampID);
  if (mySteps.find(theFieldID) == mySteps.end())
    mySteps[theFieldID] = std::map<int, XAO::Step*>();
  mySteps[theFieldID][theStepID] = aNewStep;
  myCurrentElementID = 0;
}

void StudyData_XAO::AddStepValue(
  const int theFieldID, const int theStepID, std::string theValue)
{
  int aColumns = myFields[theFieldID]->countComponents();
  mySteps[theFieldID][theStepID]->setStringValue(
    myCurrentElementID / aColumns, myCurrentElementID % aColumns, theValue);
  myCurrentElementID++;
}

std::string StudyData_XAO::Import(const std::string theFileName)
{
  std::string anError;
  myImport = new XAO::Xao();
  try {
    if (XAO::XaoExporter::readFromFile(theFileName, myImport)) {
      XAO::Geometry* aGeometry = myImport->getGeometry();
      XAO::Format aFormat = aGeometry->getFormat();
      if (aFormat == XAO::BREP) {
        if (XAO::BrepGeometry* aBrepGeometry = dynamic_cast<XAO::BrepGeometry*>(aGeometry))
          myShape = new TopoDS_Shape(aBrepGeometry->getTopoDS_Shape());
      } else {
        anError = "Unsupported XAO geometry format:" + XAO::XaoUtils::shapeFormatToString(aFormat);
      }
    } else {
      anError = "XAO object was not read successful";
    }
  } catch (XAO::XAO_Exception& e) {
    anError = e.what();
  }

  return anError;
}

long long StudyData_XAO::GetShape()
{
  return (long long)(myShape);
}

static int GetSelectionTypeInt(const XAO::Dimension theDimension) {
  switch(theDimension) {
  case XAO::VERTEX: return 7;
  case XAO::EDGE: return 6;
  case XAO::FACE: return 4;
  case XAO::SOLID: return 2;
  default: return -1;
  }
  return -1;
}

int StudyData_XAO::GetGroupDimension(const int theGroupID)
{
  XAO::Group* aXaoGroup = myImport->getGroup(theGroupID);
  return GetSelectionTypeInt(aXaoGroup->getDimension());
}

std::list<long> StudyData_XAO::GetGroupSelection(const int theGroupID)
{
  XAO::Group* aXaoGroup = myImport->getGroup(theGroupID);
  XAO::Geometry* aGeometry = myImport->getGeometry();
  std::list<long> aResult;
  for (int anElementIndex = 0; anElementIndex < aXaoGroup->count(); ++anElementIndex) {
    int anElementID = aXaoGroup->get(anElementIndex);
    std::string aReferenceString =
      aGeometry->getElementReference(aXaoGroup->getDimension(), anElementID);
    int aReferenceID = XAO::XaoUtils::stringToInt(aReferenceString);
    aResult.push_back(aReferenceID);
  }
  return aResult;
}

int StudyData_XAO::GetValuesType(const int theFieldID)
{
  XAO::Field* aField = myImport->getField(theFieldID);
  return (int)(aField->getType());
}

int StudyData_XAO::GetSelectionType(const int theFieldID)
{
  XAO::Field* aField = myImport->getField(theFieldID);
  return GetSelectionTypeInt(aField->getDimension());
}

std::list<std::string> StudyData_XAO::GetComponents(const int theFieldID)
{
  XAO::Field* aField = myImport->getField(theFieldID);
  std::list<std::string> aResult;
  int aNum = aField->countComponents();
  for(int a = 0; a < aNum; a++) {
    aResult.push_back(aField->getComponentName(a));
  }
  return aResult;
}

void StudyData_XAO::BeginSteps(const int theFieldID)
{
  myStepIterator = myImport->getField(theFieldID)->begin();
}

bool StudyData_XAO::More(const int theFieldID)
{
  return myStepIterator != myImport->getField(theFieldID)->end();
}

void StudyData_XAO::Next()
{
  myStepIterator++;
}

int StudyData_XAO::GetStamp()
{
  return (*myStepIterator)->getStamp();
}

int StudyData_XAO::GetStepIndex()
{
  return (*myStepIterator)->getStep();
}

std::list<std::string> StudyData_XAO::GetValues()
{
  std::list<std::string> aResult;
  int aComps = (*myStepIterator)->countComponents();
  int aVals = (*myStepIterator)->countValues();
  for(int a = 0; a < aVals; a++) {
    aResult.push_back((*myStepIterator)->getStringValue(a / aComps, a % aComps));
  }

  return aResult;
}
