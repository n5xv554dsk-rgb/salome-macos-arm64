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

#include "StudyData_Operation.h"

#include <Precision.hxx>
#include <TopoDS.hxx>
#include <TopoDS_Shape.hxx>
#include <TopoDS_Iterator.hxx>
#include <BRep_Builder.hxx>
#include <BRepTools.hxx>
#include <Bnd_Box.hxx>
#include <BRepBndLib.hxx>
#include <TopTools_MapOfShape.hxx>
#include <TColStd_HArray1OfInteger.hxx>
#include <TopExp.hxx>
#include <TopExp_Explorer.hxx>
#include <TopTools_ListOfShape.hxx>
#include <GProp_GProps.hxx>
#include <BRepGProp.hxx>

#include <vector>
#include <algorithm>
#include <functional>

static const int TopAbs_FLAT = TopAbs_SHAPE+1;

static void AddFlatSubShapes(const TopoDS_Shape& S, TopTools_ListOfShape& L, TopTools_MapOfShape& M)
{
  if (S.ShapeType() != TopAbs_COMPOUND) {
    L.Append(S);
  }
  else {
    TopoDS_Iterator It(S, Standard_True, Standard_True);
    for (; It.More(); It.Next()) {
      TopoDS_Shape SS = It.Value();
      if (M.Add(SS))
        AddFlatSubShapes(SS, L, M);
    }
  }
}

static std::pair<double, double> ShapeToDouble (const TopoDS_Shape& S)
{
  // Computing of CentreOfMass
  gp_Pnt GPoint;
  double Len;

  if (S.ShapeType() == TopAbs_VERTEX) {
    GPoint = BRep_Tool::Pnt(TopoDS::Vertex(S));
    Len = (double)S.Orientation();
  }
  else {
    GProp_GProps GPr;
    if (S.ShapeType() == TopAbs_EDGE || S.ShapeType() == TopAbs_WIRE) {
      BRepGProp::LinearProperties(S, GPr);
    }
    else if (S.ShapeType() == TopAbs_FACE || S.ShapeType() == TopAbs_SHELL) {
      BRepGProp::SurfaceProperties(S, GPr);
    }
    else {
      BRepGProp::VolumeProperties(S, GPr);
    }
    GPoint = GPr.CentreOfMass();
    Len = GPr.Mass();
  }

  double dMidXYZ = GPoint.X() * 999.0 + GPoint.Y() * 99.0 + GPoint.Z() * 0.9;
  return std::make_pair(dMidXYZ, Len);
}

/// Sort shapes in the list by their coordinates.
struct CompareShapes : public std::function<bool(TopoDS_Shape&, TopoDS_Shape&)>
{
  CompareShapes () {}
  bool operator() (const TopoDS_Shape& lhs, const TopoDS_Shape& rhs);
  typedef NCollection_DataMap<TopoDS_Shape, std::pair<double, double> > GEOMUtils_DataMapOfShapeDouble;
  GEOMUtils_DataMapOfShapeDouble myMap;
};

bool CompareShapes::operator() (const TopoDS_Shape& theShape1,
  const TopoDS_Shape& theShape2)
{
  if (!myMap.IsBound(theShape1)) {
    myMap.Bind(theShape1, ShapeToDouble(theShape1));
  }

  if (!myMap.IsBound(theShape2)) {
    myMap.Bind(theShape2, ShapeToDouble(theShape2));
  }

  std::pair<double, double> val1 = myMap.Find(theShape1);
  std::pair<double, double> val2 = myMap.Find(theShape2);

  double tol = Precision::Confusion();
  bool exchange = Standard_False;

  double dMidXYZ = val1.first - val2.first;
  if (dMidXYZ >= tol) {
    exchange = Standard_True;
  }
  else if (Abs(dMidXYZ) < tol) {
    double dLength = val1.second - val2.second;
    if (dLength >= tol) {
      exchange = Standard_True;
    }
    else if (Abs(dLength) < tol && theShape1.ShapeType() <= TopAbs_FACE) {
      Bnd_Box box1,box2;
      BRepBndLib::Add(theShape1, box1);
      if (!box1.IsVoid()) {
        BRepBndLib::Add(theShape2, box2);
        Standard_Real dSquareExtent = box1.SquareExtent() - box2.SquareExtent();
        if (dSquareExtent >= tol) {
          exchange = Standard_True;
        }
        else if (Abs(dSquareExtent) < tol) {
          Standard_Real aXmin, aYmin, aZmin, aXmax, aYmax, aZmax, val1, val2;
          box1.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
          val1 = (aXmin+aXmax)*999.0 + (aYmin+aYmax)*99.0 + (aZmin+aZmax)*0.9;
          box2.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
          val2 = (aXmin+aXmax)*999.0 + (aYmin+aYmax)*99.0 + (aZmin+aZmax)*0.9;
          if ((val1 - val2) >= tol) {
            exchange = Standard_True;
          }
        }
      }
    }
  }

  //return val1 < val2;
  return !exchange;
}


static void SortShapes (TopTools_ListOfShape& SL)
{
  std::vector<TopoDS_Shape> aShapesVec;
  aShapesVec.reserve(SL.Extent());

  TopTools_ListIteratorOfListOfShape it (SL);
  for (; it.More(); it.Next()) {
    aShapesVec.push_back(it.Value());
  }
  SL.Clear();

  CompareShapes shComp;
  std::stable_sort(aShapesVec.begin(), aShapesVec.end(), shComp);
  //std::sort(aShapesVec.begin(), aShapesVec.end(), shComp);

  std::vector<TopoDS_Shape>::const_iterator anIter = aShapesVec.begin();
  for (; anIter != aShapesVec.end(); ++anIter) {
    SL.Append(*anIter);
  }
}


std::list<long> StudyData_Operation::GetAllSubShapesIDs(
  const long long theShape, const int theShapeType, const bool isSorted)
{
  TopoDS_Shape* aShape = (TopoDS_Shape*)theShape;

  std::list<long> aResult;
  TopTools_MapOfShape mapShape;
  TopTools_ListOfShape listShape;

  if (aShape->ShapeType() == TopAbs_COMPOUND &&
    (theShapeType == TopAbs_SHAPE || theShapeType == TopAbs_FLAT || theShapeType == TopAbs_COMPOUND)) {
    TopoDS_Iterator It (*aShape, Standard_True, Standard_True);
    for (; It.More(); It.Next()) {
      TopoDS_Shape SS = It.Value();
      if (mapShape.Add(SS)) {
        if (theShapeType == TopAbs_FLAT) {
          AddFlatSubShapes(SS, listShape, mapShape);
        } else if (theShapeType == TopAbs_SHAPE || theShapeType == SS.ShapeType()) {
          listShape.Append(SS);
        }
      }
    }
  } else {
    TopExp_Explorer exp (*aShape, TopAbs_ShapeEnum(theShapeType));
    for (; exp.More(); exp.Next())
      if (mapShape.Add(exp.Current()))
        listShape.Append(exp.Current());
  }

  if (listShape.IsEmpty()) {
    return aResult;
  }

  if (isSorted) {
    SortShapes(listShape);
  }

  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aShape, anIndices);

  TopTools_ListIteratorOfListOfShape itSub (listShape);
  for (int index = 1; itSub.More(); itSub.Next(), ++index) {
    TopoDS_Shape aValue = itSub.Value();
    aResult.push_back(anIndices.FindIndex(aValue));
  }

  return aResult;
}

std::list<long long> StudyData_Operation::GetSharedShapes(
  const long long theShape1, const long long theShape2, const int theShapeType)
{
  std::list<long long> aResult;

  TopoDS_Shape* aShape1 = (TopoDS_Shape*)theShape1;
  TopoDS_Shape* aShape2 = (TopoDS_Shape*)theShape2;
  if (aShape1->IsNull() || aShape2->IsNull())
    return aResult;
  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aShape1, anIndices);
  Handle(TColStd_HArray1OfInteger) anArray;

  TopTools_IndexedMapOfShape mapShape1;
  TopExp::MapShapes(*aShape1, TopAbs_ShapeEnum(theShapeType), mapShape1);
  TopTools_MapOfShape mapShape2;
  TopExp_Explorer exp (*aShape2, TopAbs_ShapeEnum(theShapeType));
  for (; exp.More(); exp.Next()) {
    TopoDS_Shape aSS = exp.Current();
    if (mapShape2.Add(aSS) && mapShape1.Contains(aSS)) {
      // for the current moment there are no sub-shape managed in the SHAPER-STUDY, so,
      // store just shape in heap and return pointer to it (otherwise it will be disappeared)
      long long aNewShapePointer = (long long)(new TopoDS_Shape(aSS));
      aResult.push_back(aNewShapePointer);
    }
  }

  return aResult;
}

int StudyData_Operation::GetSubShapeIndex(const long long theMainShape, const long long theSubShape)
{
  TopoDS_Shape* aMainShape = (TopoDS_Shape*)theMainShape;
  TopoDS_Shape* aSubShape = (TopoDS_Shape*)theSubShape;
  if ( !aMainShape || !aSubShape || aMainShape->IsNull() || aSubShape->IsNull())
    return 0;

  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aMainShape, anIndices);
  return anIndices.FindIndex(*aSubShape);
}

int StudyData_Operation::GetTopologyIndex(const long long theMainShape, const long long theSubShape)
{
  TopoDS_Shape* aMainShape = (TopoDS_Shape*)theMainShape;
  TopoDS_Shape* aSubShape = (TopoDS_Shape*)theSubShape;
  if ( !aMainShape || !aSubShape || aMainShape->IsNull() || aSubShape->IsNull())
    return 0;

  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aMainShape, aSubShape->ShapeType(), anIndices);
  return anIndices.FindIndex(*aSubShape);
}

long long StudyData_Operation::GetSubShape(const long long theMainShape, long theID)
{
  TopoDS_Shape* aMainShape = (TopoDS_Shape*)theMainShape;
  if (aMainShape->IsNull())
    return 0;
  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aMainShape, anIndices);
  if (anIndices.Size() < theID)
    return 0;
  const TopoDS_Shape& aFound = anIndices.FindKey(theID);
  // for the current moment there are no sub-shape managed in the SHAPER-STUDY, so,
  // store just shape in heap and return pointer to it (otherwise it will be disappeared)
  return (long long)(new TopoDS_Shape(aFound));
}

std::list<long long> StudyData_Operation::ExtractSubShapes(const long long theMainShape,
                                                           const int       theShapeType,
                                                           const bool      theIsSorted)
{
  std::list<long long> resultList;

  TopoDS_Shape* aShape = (TopoDS_Shape*)theMainShape;
  if ( !aShape || aShape->IsNull())
    return resultList;

  std::list<long> aResult;
  TopTools_MapOfShape mapShape;
  TopTools_ListOfShape listShape;

  if (aShape->ShapeType() == TopAbs_COMPOUND &&
    (theShapeType == TopAbs_SHAPE || theShapeType == TopAbs_FLAT || theShapeType == TopAbs_COMPOUND)) {
    TopoDS_Iterator It (*aShape, Standard_True, Standard_True);
    for (; It.More(); It.Next()) {
      TopoDS_Shape SS = It.Value();
      if (mapShape.Add(SS)) {
        if (theShapeType == TopAbs_FLAT) {
          AddFlatSubShapes(SS, listShape, mapShape);
        } else if (theShapeType == TopAbs_SHAPE || theShapeType == SS.ShapeType()) {
          listShape.Append(SS);
        }
      }
    }
  } else {
    TopExp_Explorer exp (*aShape, TopAbs_ShapeEnum(theShapeType));
    for (; exp.More(); exp.Next())
      if (mapShape.Add(exp.Current()))
        listShape.Append(exp.Current());
  }

  if (listShape.IsEmpty()) {
    return resultList;
  }

  if (theIsSorted) {
    SortShapes(listShape);
  }

  TopTools_ListIteratorOfListOfShape itSub (listShape);
  for ( ; itSub.More(); itSub.Next() ) {
    TopoDS_Shape aValue = itSub.Value();
    resultList.push_back( (long long)(new TopoDS_Shape(aValue)) );
  }

  return resultList;
}

std::list<double> StudyData_Operation::PointCoordinates(const long long theVertex)
{
  std::list<double> xyz;

  TopoDS_Shape* aShape = (TopoDS_Shape*)theVertex;
  if ( !aShape || aShape->IsNull() || aShape->ShapeType() != TopAbs_VERTEX )
    return xyz;

  gp_Pnt p = BRep_Tool::Pnt( TopoDS::Vertex( *aShape ));
  xyz.push_back( p.X() );
  xyz.push_back( p.Y() );
  xyz.push_back( p.Z() );

  return xyz;
}

double StudyData_Operation::MinDistance(const long long theVertex1, const long long theVertex2)
{
  double result = -1;
  TopoDS_Shape* aShape1 = (TopoDS_Shape*)theVertex1;
  TopoDS_Shape* aShape2 = (TopoDS_Shape*)theVertex2;

  if ( !aShape1 || aShape1->IsNull() || aShape1->ShapeType() != TopAbs_VERTEX ||
       !aShape2 || aShape2->IsNull() || aShape2->ShapeType() != TopAbs_VERTEX )
    return result;

  gp_Pnt p1 = BRep_Tool::Pnt( TopoDS::Vertex( *aShape1 ));
  gp_Pnt p2 = BRep_Tool::Pnt( TopoDS::Vertex( *aShape2 ));

  result = p1.Distance( p2 );
  return result;
}

int StudyData_Operation::NumberOfEdges(const long long theShape)
{
  int nb = -1;

  TopoDS_Shape* aShape = (TopoDS_Shape*)theShape;
  if ( !aShape || aShape->IsNull() )
    return nb;

  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aShape, TopAbs_EDGE, anIndices);
  nb = anIndices.Extent();

  return nb;
}
  
int StudyData_Operation::NumberOfFaces(const long long theShape)
{
  int nb = -1;

  TopoDS_Shape* aShape = (TopoDS_Shape*)theShape;
  if ( !aShape || aShape->IsNull() )
    return nb;

  TopTools_IndexedMapOfShape anIndices;
  TopExp::MapShapes(*aShape, TopAbs_FACE, anIndices);
  nb = anIndices.Extent();

  return nb;
}
  
double StudyData_Operation::GetTolerance( const long long theVertex )
{
  double tol = -1;

  TopoDS_Shape* aShape = (TopoDS_Shape*)theVertex;
  if ( !aShape || aShape->IsNull() || aShape->ShapeType() != TopAbs_VERTEX )
    return tol;

  tol = BRep_Tool::Tolerance( TopoDS::Vertex( *aShape ));

  return tol;
}

long long StudyData_Operation::GetVertexByIndex(const long long theEdge,
                                                int             theIndex,
                                                bool            theUseOri )
{
  TopoDS_Shape* aShape = (TopoDS_Shape*)theEdge;
  if ( !aShape || aShape->IsNull() || aShape->ShapeType() != TopAbs_EDGE )
    return 0;

  if ( !theUseOri )
    aShape->Orientation( TopAbs_FORWARD );

  TopoDS_Vertex aVertex;
  if ( theIndex == 0 )
    aVertex = TopExp::FirstVertex( TopoDS::Edge( *aShape ));
  else
    aVertex = TopExp::LastVertex( TopoDS::Edge( *aShape ));

  return (long long)(new TopoDS_Shape( aVertex ));
}
