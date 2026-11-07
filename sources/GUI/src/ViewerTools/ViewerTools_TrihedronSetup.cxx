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

#include "ViewerTools_TrihedronSetup.h"

#include "SUIT_ResourceMgr.h"
#include "SUIT_Session.h"

#include <QFont>
#include <QColor>

namespace
{
    // Settings names to use with resource manager
    const char* THE_3DSECTION_TITLE = "3DViewer";
};

/*!
 * Class       : ViewerTools_TrihedronSetupBase
 * Description : Helper class to setup trihedron settings for different viewers
 */

bool ViewerTools_TrihedronSetupBase::isCustomTextFontOn() const
{
    return SUIT_Session::session()->resourceMgr()->booleanValue(
        THE_3DSECTION_TITLE, "trihedron_text_font_custom", false);
}

bool ViewerTools_TrihedronSetupBase::isCustomTextColorOn() const
{
    return SUIT_Session::session()->resourceMgr()->booleanValue(
        THE_3DSECTION_TITLE, "trihedron_text_color_custom", false);
}

void ViewerTools_TrihedronSetupBase::setTextFont()
{
    if (isCustomTextFontOn())
    {
        const SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();

        // Set the fonts from application settings
        setTextFontX(resMgr->fontValue(THE_3DSECTION_TITLE, "trihedron_x_text_font"));
        setTextFontY(resMgr->fontValue(THE_3DSECTION_TITLE, "trihedron_y_text_font"));
        setTextFontZ(resMgr->fontValue(THE_3DSECTION_TITLE, "trihedron_z_text_font"));
    }
    else
    {
        // Set the font defined for trihedron by default
        setTextFontX(getDefaultTextFont());
        setTextFontY(getDefaultTextFont());
        setTextFontZ(getDefaultTextFont());
    }
}

void ViewerTools_TrihedronSetupBase::setTextColor()
{
    if (isCustomTextColorOn())
    {
        const SUIT_ResourceMgr* resMgr = SUIT_Session::session()->resourceMgr();

        // Set the colors from application settings
        setTextColorX(resMgr->colorValue(THE_3DSECTION_TITLE, "trihedron_x_text_color"));
        setTextColorY(resMgr->colorValue(THE_3DSECTION_TITLE, "trihedron_y_text_color"));
        setTextColorZ(resMgr->colorValue(THE_3DSECTION_TITLE, "trihedron_z_text_color"));
    }
    else
    {
        // Set the colors defined for trihedron by default
        static const QColor colorX = QColor(255, 0.0, 0.0);
        static const QColor colorY = QColor(0.0, 255, 0.0);
        static const QColor colorZ = QColor(0.0, 0.0, 255);

        setTextColorX(colorX);
        setTextColorY(colorY);
        setTextColorZ(colorZ);
    }
}
