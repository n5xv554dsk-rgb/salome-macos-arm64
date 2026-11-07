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

#ifndef StudyData_Object_H

#include "StudyData.h"
#include <XAO_Xao.hxx>
#include <XAO_Step.hxx>
#include <XAO_Field.hxx>

#include <list>
#include <map>

class TopoDS_Shape;

class StudyData_XAO
{
  TopoDS_Shape* myShape; ///< the shape, part of XAO
  XAO::Xao* myExport; ///< the XAO instance for export
  XAO::Xao* myImport; ///< the XAO instance for export
  std::map<int, XAO::Group*> myGroups; ///< id of group to the group structure
  std::map<int, XAO::Field*> myFields; ///< id of field to the field structure
  std::map<int, std::map<int, XAO::Step*> > mySteps; ///< id of field to the field structure
  int myCurrentElementID; ///< to add elements of step one by one
  XAO::stepIterator myStepIterator; ///< contains a current steps iterator (on import)

public:
  StudyData_EXPORT StudyData_XAO();

  // defines the shape for XAO export
  StudyData_EXPORT void SetShape(const long long theShapePtr);

  // add a new group for export to XAO; returns id of this group
  StudyData_EXPORT int AddGroup(const int theSelType, const std::string theGroupName);
  // sets the selection for an already added group
  StudyData_EXPORT void AddGroupSelection(const int theGroupID, const int theSelection);

  // add a new field for export to XAO; returns id of this field
  StudyData_EXPORT int AddField(const int theValType, const int theSelType,
                                const int theCompsNum, const std::string theFieldName);
  // set the component name for the exported field
  StudyData_EXPORT void SetFieldComponent(const int theFieldID, const int theCompIndex,
                                          const std::string theCompName);
  // adds a step to the exported field
  StudyData_EXPORT void AddStep(const int theFieldID, const int theStepID, const int theStampID);
  // adds the value to the step of the exported field. values must come one by one (row by row)
  StudyData_EXPORT void AddStepValue(
    const int theFieldID, const int theStepID, std::string theValue);

  // performs the export to XAO
  StudyData_EXPORT void Export(const std::string theFileName);

  // Imports the XAO data, returns the error string or empty one if it is ok.
  StudyData_EXPORT std::string Import(const std::string theFileName);

  // Returns a pointer to the shape from XAO after import
  StudyData_EXPORT long long GetShape();

  // Returns a selection type of the group
  StudyData_EXPORT int GetGroupDimension(const int theGroupID);

  // Returns a selection list of indices of the group
  StudyData_EXPORT std::list<long> GetGroupSelection(const int theGroupID);

  // Returns a value type of the imported field
  StudyData_EXPORT int GetValuesType(const int theFieldID);
  // Returns a selection type of the imported field
  StudyData_EXPORT int GetSelectionType(const int theFieldID);
  // Returns components names of the imported field
  StudyData_EXPORT std::list<std::string> GetComponents(const int theFieldID);
  // Starts iteration of steps
  StudyData_EXPORT void BeginSteps(const int theFieldID);
  // Returns true if steps iteration contains a current step
  StudyData_EXPORT bool More(const int theFieldID);
  // Iterates the step iterator contains a current step
  StudyData_EXPORT void Next();
  // Returns a stamp ID of the imported field step
  StudyData_EXPORT int GetStamp();
  // Returns a step ID of the imported field step
  StudyData_EXPORT int GetStepIndex();
  // Returns string values of the imported field step
  StudyData_EXPORT std::list<std::string> GetValues();
};

#endif // !StudyData_XAO_H
