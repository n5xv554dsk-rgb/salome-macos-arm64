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

#ifndef OCCVIEWER_TRIHEDRON_SETUP_H
#define OCCVIEWER_TRIHEDRON_SETUP_H

#include "OCCViewer.h"
#include "ViewerTools_TrihedronSetup.h"

class AIS_Trihedron;
class V3d_Trihedron;

/*!
 * Class       : OCCViewer_TrihedronSetupAIS
 * Description : Helper class to setup trihedron settings for AIS_Trihedron (OCCT viewer)
 */
class OCCVIEWER_EXPORT OCCViewer_TrihedronSetupAIS : public ViewerTools_TrihedronSetupBase
{
public:
    OCCViewer_TrihedronSetupAIS(const Handle(AIS_Trihedron)& trihedron) : myTrihedron(trihedron) {}
    virtual ~OCCViewer_TrihedronSetupAIS() {}

protected:
    virtual QFont getDefaultTextFont() const override;

    virtual void setTextFontX(const QFont& font) override;
    virtual void setTextFontY(const QFont& font) override;
    virtual void setTextFontZ(const QFont& font) override;

    virtual void setTextColorX(const QColor& color) override;
    virtual void setTextColorY(const QColor& color) override;
    virtual void setTextColorZ(const QColor& color) override;

private:
    const Handle(AIS_Trihedron)& myTrihedron;
};

/*!
 * Class       : OCCViewer_TrihedronSetupV3d
 * Description : Helper class to setup trihedron settings for V3d_Trihedron (OCCT viewer)
 */
class OCCVIEWER_EXPORT OCCViewer_TrihedronSetupV3d : public ViewerTools_TrihedronSetupBase
{
public:
    OCCViewer_TrihedronSetupV3d(const Handle(V3d_Trihedron)& trihedron) : myTrihedron(trihedron) {}
    virtual ~OCCViewer_TrihedronSetupV3d() {}

protected:
    virtual QFont getDefaultTextFont() const override;

    virtual void setTextFontX(const QFont& font) override;
    virtual void setTextFontY(const QFont& font) override;
    virtual void setTextFontZ(const QFont& font) override;

    virtual void setTextColorX(const QColor& color) override;
    virtual void setTextColorY(const QColor& color) override;
    virtual void setTextColorZ(const QColor& color) override;

private:
    const Handle(V3d_Trihedron)& myTrihedron;
};

#endif
