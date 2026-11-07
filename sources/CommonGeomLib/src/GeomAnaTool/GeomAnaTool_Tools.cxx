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

#include "GeomAnaTool_Tools.hxx"

#include <TopExp.hxx>
#include <TopExp_Explorer.hxx>
#include <TopTools_DataMapOfIntegerListOfShape.hxx>
#include <TopTools_IndexedMapOfShape.hxx>
#include <TopTools_MapOfShape.hxx>

namespace GeomAnaTool
{
  //=======================================================================
  //function : FillErrorsSub
  //purpose  : Fill the errors list of subshapes on shape.
  //=======================================================================
  static void FillErrorsSub(const BRepCheck_Analyzer             &theAna,
                            const TopoDS_Shape                   &theShape,
                            const TopAbs_ShapeEnum                theSubType,
                            TopTools_DataMapOfIntegerListOfShape &theMapErrors)
  {
    TopExp_Explorer anExp(theShape, theSubType);
    TopTools_MapOfShape aMapSubShapes;

    for (; anExp.More(); anExp.Next()) {
      const TopoDS_Shape &aSubShape = anExp.Current();

      if (aMapSubShapes.Add(aSubShape)) {
        const Handle(BRepCheck_Result) &aRes = theAna.Result(aSubShape);

        for (aRes->InitContextIterator();
             aRes->MoreShapeInContext(); 
             aRes->NextShapeInContext()) {
          if (aRes->ContextualShape().IsSame(theShape)) {
            BRepCheck_ListIteratorOfListOfStatus itl(aRes->StatusOnShape());

            if (itl.Value() != BRepCheck_NoError) {
              // Add all errors for theShape and its sub-shape.
              for (;itl.More(); itl.Next()) {
                const Standard_Integer aStat = (Standard_Integer)itl.Value();

                if (!theMapErrors.IsBound(aStat)) {
                  TopTools_ListOfShape anEmpty;

                  theMapErrors.Bind(aStat, anEmpty);
                }

                TopTools_ListOfShape &theShapes = theMapErrors.ChangeFind(aStat);

                theShapes.Append(aSubShape);
                theShapes.Append(theShape);
              }
            }
          }

          break;
        }
      }
    }
  }


  //=======================================================================
  //function : FillErrors
  //purpose  : Fill the errors list.
  //=======================================================================
  static void FillErrors (const BRepCheck_Analyzer             &theAna,
                          const TopoDS_Shape                   &theShape,
                          TopTools_DataMapOfIntegerListOfShape &theMapErrors,
                          TopTools_MapOfShape                  &theMapShapes)
  {
    if (theMapShapes.Add(theShape)) {
      // Fill errors of child shapes.
      for (TopoDS_Iterator iter(theShape); iter.More(); iter.Next()) {
        FillErrors(theAna, iter.Value(), theMapErrors, theMapShapes);
      }

      // Fill errors of theShape.
      const Handle(BRepCheck_Result) &aRes = theAna.Result(theShape);

      if (!aRes.IsNull()) {
        BRepCheck_ListIteratorOfListOfStatus itl(aRes->Status());

        if (itl.Value() != BRepCheck_NoError) {
          // Add all errors for theShape.
          for (;itl.More(); itl.Next()) {
            const Standard_Integer aStat = (Standard_Integer)itl.Value();

            if (!theMapErrors.IsBound(aStat)) {
              TopTools_ListOfShape anEmpty;

              theMapErrors.Bind(aStat, anEmpty);
            }

            theMapErrors.ChangeFind(aStat).Append(theShape);
          }
        }
      }

      // Add errors of subshapes on theShape.
      const TopAbs_ShapeEnum aType = theShape.ShapeType();

      switch (aType) {
      case TopAbs_EDGE:
        FillErrorsSub(theAna, theShape, TopAbs_VERTEX, theMapErrors);
        break;
      case TopAbs_FACE:
        FillErrorsSub(theAna, theShape, TopAbs_WIRE, theMapErrors);
        FillErrorsSub(theAna, theShape, TopAbs_EDGE, theMapErrors);
        FillErrorsSub(theAna, theShape, TopAbs_VERTEX, theMapErrors);
        break;
      case TopAbs_SOLID:
        FillErrorsSub(theAna, theShape, TopAbs_SHELL, theMapErrors);
        break;
      default:
        break;
      }
    }
  }

  //=======================================================================
  //function : FillErrors
  //purpose  : Fill the errors list.
  //=======================================================================
  void FillErrors (const BRepCheck_Analyzer   &theAna,
                   const TopoDS_Shape         &theShape,
                   std::list<GeomAnaTool::ShapeError>  &theErrors)
  {
    // Fill the errors map.
    TopTools_DataMapOfIntegerListOfShape aMapErrors;
    TopTools_MapOfShape                  aMapShapes;

    FillErrors(theAna, theShape, aMapErrors, aMapShapes);

    // Map sub-shapes and their indices
    TopTools_IndexedMapOfShape anIndices;

    TopExp::MapShapes(theShape, anIndices);

    TopTools_DataMapIteratorOfDataMapOfIntegerListOfShape aMapIter(aMapErrors);

    for (; aMapIter.More(); aMapIter.Next()) {
      GeomAnaTool::ShapeError anError;

      anError.error = (BRepCheck_Status)aMapIter.Key();

      TopTools_ListIteratorOfListOfShape aListIter(aMapIter.Value());
      TopTools_MapOfShape                aMapUnique;

      for (; aListIter.More(); aListIter.Next()) {
        const TopoDS_Shape &aShape = aListIter.Value();

        if (aMapUnique.Add(aShape)) {
          const Standard_Integer anIndex = anIndices.FindIndex(aShape);

          anError.incriminated.push_back(anIndex);
        }
      }

      if (!anError.incriminated.empty()) {
        theErrors.push_back(anError);
      }
    }
  }

} // namespace GeomAnaTool
