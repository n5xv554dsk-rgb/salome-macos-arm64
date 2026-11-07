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

#include "OCCViewer_TrihedronSetup.h"

#include <Basics_OCCTVersion.hxx>
#include <AIS_Trihedron.hxx>
#include <V3d_View.hxx>
#include <V3d_Trihedron.hxx>

#include <QFont>
#include <QColor>


// Common helper functions to separate algorithm from implementation
// and reduce code repetition.
namespace
{
    Font_FontAspect getFontAspect(const QFont& font)
    {
        if (font.bold() && font.italic())
        {
            return Font_FontAspect_BoldItalic;
        }
        else if (font.bold())
        {
            return Font_FontAspect_Bold;
        }
        else if (font.italic())
        {
            return Font_FontAspect_Italic;
        }

        return Font_FontAspect_Regular;
    }

    void setTextFontByAxis(const Handle(AIS_Trihedron)& trihedron, Prs3d_DatumParts axis, const QFont& font)
    {
#if OCC_VERSION_LARGE >= 0x07070000
        Handle(Prs3d_Drawer) drawer = trihedron->Attributes();
        if (!drawer->HasOwnDatumAspect())
        {
            return;
        }

        Handle(Prs3d_DatumAspect) daspect = drawer->DatumAspect();
        daspect->TextAspect(axis)->SetFont(font.family().toStdString().c_str());

        const Font_FontAspect fontAspect = getFontAspect(font);
        daspect->TextAspect(axis)->Aspect()->SetTextFontAspect(fontAspect);
#endif // OCC_VERSION_LARGE >= 0x0707000
    }

    void setTextColorByAxis(const Handle(AIS_Trihedron)& trihedron, Prs3d_DatumParts axis, const QColor& color)
    {
#if OCC_VERSION_LARGE >= 0x07070000
        trihedron->SetTextColor(axis, OCCViewer::color(color));
#endif // OCC_VERSION_LARGE >= 0x0707000
    }

    void setTextFontByAxis(const Handle(V3d_Trihedron)& trihedron, V3d_TypeOfAxe axis, const QFont& font)
    {
#if OCC_VERSION_LARGE >= 0x07070000
        const Handle(Prs3d_TextAspect)& labelAspect = trihedron->LabelAspect(axis);
        labelAspect->SetFont(font.family().toStdString().c_str());

        const Font_FontAspect fontAspect = getFontAspect(font);
        labelAspect->Aspect()->SetTextFontAspect(fontAspect);
#endif // OCC_VERSION_LARGE >= 0x0707000
    }

    void setTextColorByAxis(const Handle(V3d_Trihedron)& trihedron, V3d_TypeOfAxe axis, const QColor& color)
    {
#if OCC_VERSION_LARGE >= 0x07070000
        trihedron->LabelAspect(axis)->SetColor(OCCViewer::color(color));
#endif // OCC_VERSION_LARGE >= 0x0707000
    }
}


/*!
 * Class       : OCCViewer_TrihedronSetupAIS
 * Description : Helper class to setup trihedron settings for AIS_Trihedron (OCCT viewer)
 */

QFont OCCViewer_TrihedronSetupAIS::getDefaultTextFont() const
{
    return QFont(Font_NOF_ASCII_MONO);
}

void OCCViewer_TrihedronSetupAIS::setTextFontX(const QFont& font)
{
    setTextFontByAxis(myTrihedron, Prs3d_DP_XAxis, font);
}

void OCCViewer_TrihedronSetupAIS::setTextFontY(const QFont& font)
{
    setTextFontByAxis(myTrihedron, Prs3d_DP_YAxis, font);
}

void OCCViewer_TrihedronSetupAIS::setTextFontZ(const QFont& font)
{
    setTextFontByAxis(myTrihedron, Prs3d_DP_ZAxis, font);
}

void OCCViewer_TrihedronSetupAIS::setTextColorX(const QColor& color)
{
    setTextColorByAxis(myTrihedron, Prs3d_DP_XAxis, color);
}

void OCCViewer_TrihedronSetupAIS::setTextColorY(const QColor& color)
{
    setTextColorByAxis(myTrihedron, Prs3d_DP_YAxis, color);
}

void OCCViewer_TrihedronSetupAIS::setTextColorZ(const QColor& color)
{
    setTextColorByAxis(myTrihedron, Prs3d_DP_ZAxis, color);
}

/*!
 * Class       : OCCViewer_TrihedronSetupV3d
 * Description : Helper class to setup trihedron settings for V3d_Trihedron (OCCT viewer)
 */

QFont OCCViewer_TrihedronSetupV3d::getDefaultTextFont() const
{
    return QFont(Font_NOF_ASCII_MONO);
}

void OCCViewer_TrihedronSetupV3d::setTextFontX(const QFont& font)
{
    setTextFontByAxis(myTrihedron, V3d_TypeOfAxe::V3d_X, font);
}

void OCCViewer_TrihedronSetupV3d::setTextFontY(const QFont& font)
{
    setTextFontByAxis(myTrihedron, V3d_TypeOfAxe::V3d_Y, font);
}

void OCCViewer_TrihedronSetupV3d::setTextFontZ(const QFont& font)
{
    setTextFontByAxis(myTrihedron, V3d_TypeOfAxe::V3d_Z, font);
}

void OCCViewer_TrihedronSetupV3d::setTextColorX(const QColor& color)
{
    setTextColorByAxis(myTrihedron, V3d_TypeOfAxe::V3d_X, color);
}

void OCCViewer_TrihedronSetupV3d::setTextColorY(const QColor& color)
{
    setTextColorByAxis(myTrihedron, V3d_TypeOfAxe::V3d_Y, color);
}

void OCCViewer_TrihedronSetupV3d::setTextColorZ(const QColor& color)
{
    setTextColorByAxis(myTrihedron, V3d_TypeOfAxe::V3d_Z, color);
}
