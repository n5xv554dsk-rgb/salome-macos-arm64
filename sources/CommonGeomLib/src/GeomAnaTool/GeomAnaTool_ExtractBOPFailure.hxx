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
#ifndef GeomAnaTool_ExtractBOPFailure_HeaderFile
#define GeomAnaTool_ExtractBOPFailure_HeaderFile

#include "GeomAnaTool.h"
#include "GeomAnaTool_Tools.hxx"

#include <BOPAlgo_Builder.hxx>
#include <BOPAlgo_GlueEnum.hxx>
#include <BOPAlgo_PaveFiller.hxx>
#include <TopoDS_Shape.hxx>
#include <TopTools_DataMapOfIntegerListOfShape.hxx>
#include <TopTools_ListOfShape.hxx>

class GeomAnaTool_ExtractBOPFailure {
public:
  GEOMANATOOL_EXPORT
    GeomAnaTool_ExtractBOPFailure();

  GEOMANATOOL_EXPORT
    GeomAnaTool_ExtractBOPFailure(const TopTools_ListOfShape& theShapes);

  GEOMANATOOL_EXPORT
    virtual ~GeomAnaTool_ExtractBOPFailure();

  /// Set the shapes for the operation
  GEOMANATOOL_EXPORT
    void SetShapes(const TopTools_ListOfShape& theShapes);

  /// Return the shapes for the operation
  GEOMANATOOL_EXPORT
    const TopTools_ListOfShape& Shapes() const;

  /// Set whether to check the geometry (or topology only)
  GEOMANATOOL_EXPORT
    void SetCheckGeometry(const Standard_Boolean aFlag);

  /// Return whether the geometry is checked, too
  GEOMANATOOL_EXPORT Standard_Boolean CheckGeometry() const;

  /// Set whether to run the timer during the operation
  GEOMANATOOL_EXPORT
    void SetUseTimer(const Standard_Boolean aFlag);

  /// Return whether the timer is running during the operation
  GEOMANATOOL_EXPORT
    Standard_Boolean UseTimer() const;

  /// Set whether to run the operation in parallel
  GEOMANATOOL_EXPORT
    void SetRunParallel(const Standard_Boolean aFlag);

  /// Return whether the operation is run in parallel
  GEOMANATOOL_EXPORT
    Standard_Boolean RunParallel() const;

  /// Set whether to perform exact check
  GEOMANATOOL_EXPORT
    void SetExactCheck(const Standard_Boolean aFlag);

  /// Return whether to perform exact check
  GEOMANATOOL_EXPORT
    Standard_Boolean ExactCheck() const;
  
  /// Perform the operation
  GEOMANATOOL_EXPORT
    virtual void Perform();

  /// Return the shape errors
  GEOMANATOOL_EXPORT
    const std::list<GeomAnaTool::ShapeError>& ShapeErrors() const;

  /// Return the result shape of partition (may be invalid)
  GEOMANATOOL_EXPORT
    const TopoDS_Shape& Result() const;

  /// Return the report on algorithm execution
  GEOMANATOOL_EXPORT
  const Handle(Message_Report) GetReport() const
  { return myReport; }

  /// Return true, if there are failures on algorithm execution
  GEOMANATOOL_EXPORT
  Standard_Boolean HasFailureAlerts() const;

protected:
  /// Set the default values
  void SetDefaults();

  /// Perform the bfillds operation
  void Perform_bfillds();

  /// Perform the bbuild operation
  void Perform_bbuild();

  /// Perform the checkshape operation
  void Perform_checkshape();

private:
  TopTools_ListOfShape  myShapes;         // The arguments of the operation
  Standard_Boolean      myCheckGeometry;  // Whether to check the geometry (or topology only)
  Standard_Boolean      myUseTimer;       // Whether to use the timer
  Standard_Boolean      myRunParallel;    // Whether to run the operation in parallel
  Standard_Boolean      myExactCheck;     // Whether to perform exact check
  Standard_Boolean      myNonDestructive; // Whether to perform non-destructive operations
  Standard_Boolean      myUseOBB;         // Whether to use Oriented Bounding Boxes
  Standard_Real         myFuzzy;          // The fuzzy value
  BOPAlgo_GlueEnum      myGlue;           // The glue option

  TopoDS_Shape          myResult;         // The result shape of the operation (may be invalid)
  std::list<GeomAnaTool::ShapeError> myErrors;     // The list of shape errors

  std::shared_ptr<BOPAlgo_PaveFiller> myPaveFiller; // The pave filler
  std::shared_ptr<BOPAlgo_Builder>    myBuilder;    // The General Fuse algorithm for Boolean operations

  Handle(Message_Report) myReport; // Errors of execution
};

#endif // GeomAnaTool_ExtractBOPFailure_HeaderFile
