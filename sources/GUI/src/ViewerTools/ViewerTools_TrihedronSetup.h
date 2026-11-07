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

#ifndef VIEWERTOOLS_TRIHEDRON_SETUP_H
#define VIEWERTOOLS_TRIHEDRON_SETUP_H

#include "ViewerTools.h"

class QFont;
class QColor;

/*!
 * Class       : ViewerTools_TrihedronSetupBase
 * Description : Helper class to setup trihedron settings for different viewers
 */
class VIEWERTOOLS_EXPORT ViewerTools_TrihedronSetupBase
{
public:
    virtual ~ViewerTools_TrihedronSetupBase() {}

    bool isCustomTextFontOn() const;
    bool isCustomTextColorOn() const;

    virtual void setTextFont();
    virtual void setTextColor();

protected:
    // Pure virtual methods should be implemented for each trihedron class
    virtual QFont getDefaultTextFont() const = 0;

    virtual void setTextFontX(const QFont& font) = 0;
    virtual void setTextFontY(const QFont& font) = 0;
    virtual void setTextFontZ(const QFont& font) = 0;

    virtual void setTextColorX(const QColor& color) = 0;
    virtual void setTextColorY(const QColor& color) = 0;
    virtual void setTextColorZ(const QColor& color) = 0;
};

#endif
