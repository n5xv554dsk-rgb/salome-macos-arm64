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
// See https://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//

#include "SVTK_TrihedronSetup.h"

#include "VTKViewer_Trihedron.h"

#include "salomevtkPVAxesWidget.h"
#include "salomevtkPVAxesActor.h"

#include "vtkProperty.h"

#include <QFont>
#include <QColor>

// Common helper functions to separate algorithm from implementation
// and reduce code repetition.
namespace
{
    void setTextColorByAxis(VTKViewer_Trihedron* trihedron, VTKViewer_Trihedron::Axis axis, const QColor& color)
    {
        trihedron->SetTextColor(axis, color.red(), color.green(), color.blue());
    }

    void setTextColorByAxis(vtkProperty* property, const QColor& color)
    {
        property->SetColor(color.redF(), color.greenF(), color.blueF());
    }
}

/*!
 * Class       : SVTK_TrihedronSetupVTK
 * Description : Helper class to setup trihedron settings for VTKViewer_Trihedron (Vtk viewer)
 */

QFont SVTK_TrihedronSetupVTK::getDefaultTextFont() const
{
    // TODO: implement this method
    return {};
}

void SVTK_TrihedronSetupVTK::setTextFontX(const QFont& font)
{
    // TODO: find an easy method to change font for vtkVectorText (VTKViewer_Axis::myVectorText).
    // Vtk defines only VTK_ARIAL, VTK_COURIER, VTK_TIMES and VTK_FONT_FILE ids to use with vtkTextProperty.
    // Maybe vtkFreeTypeTools class could give some hints.
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupVTK::setTextFontY(const QFont& font)
{
    // TODO: implement this method
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupVTK::setTextFontZ(const QFont& font)
{
    // TODO: implement this method
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupVTK::setTextColorX(const QColor& color)
{
    setTextColorByAxis(myTrihedron, VTKViewer_Trihedron::Axis::X, color);
}

void SVTK_TrihedronSetupVTK::setTextColorY(const QColor& color)
{
    setTextColorByAxis(myTrihedron, VTKViewer_Trihedron::Axis::Y, color);
}

void SVTK_TrihedronSetupVTK::setTextColorZ(const QColor& color)
{
    setTextColorByAxis(myTrihedron, VTKViewer_Trihedron::Axis::Z, color);
}


/*!
 * Class       : SVTK_TrihedronSetupPVAxes
 * Description : Helper class to setup static trihedron settings for salomevtk::vtkPVAxesActor (Vtk viewer)
 */

QFont SVTK_TrihedronSetupPVAxes::getDefaultTextFont() const
{
    // TODO: implement this method
    return {};
}

void SVTK_TrihedronSetupPVAxes::setTextFontX(const QFont& font)
{
    // TODO: find an easy method to change font for vtkVectorText (VTKViewer_Axis::myVectorText).
    // Vtk defines only VTK_ARIAL, VTK_COURIER, VTK_TIMES and VTK_FONT_FILE ids to use with vtkTextProperty.
    // Maybe vtkFreeTypeTools class could give some hints.
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupPVAxes::setTextFontY(const QFont& font)
{
    // TODO: implement this method
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupPVAxes::setTextFontZ(const QFont& font)
{
    // TODO: implement this method
    (void)font; // disable unused param warning
}

void SVTK_TrihedronSetupPVAxes::setTextColorX(const QColor& color)
{
    setTextColorByAxis(myTrihedron->GetAxesActor()->GetXAxisLabelProperty(), color);
}

void SVTK_TrihedronSetupPVAxes::setTextColorY(const QColor& color)
{
    setTextColorByAxis(myTrihedron->GetAxesActor()->GetYAxisLabelProperty(), color);
}

void SVTK_TrihedronSetupPVAxes::setTextColorZ(const QColor& color)
{
    setTextColorByAxis(myTrihedron->GetAxesActor()->GetZAxisLabelProperty(), color);
}
