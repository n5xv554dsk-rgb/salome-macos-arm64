// Copyright (C) 2009-2026  EDF
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

#ifndef _cppcomposGUI_H_
#define _cppcomposGUI_H_

#include <SalomeApp_Module.h>
#include "ui_demo.h"

class cppcomposGUI: public SalomeApp_Module
{
  Q_OBJECT

public:
  cppcomposGUI();
  void    initialize( CAM_Application* );
  QString engineIOR() const;
  virtual void  windows( QMap<int, int>& theMap ) const;

public slots:
  bool    deactivateModule( SUIT_Study* );
  bool    activateModule( SUIT_Study* );

protected slots:
  void            OnGetBanner();
  void            OnDesigner();

};

class MyDemo: public QDialog
{
  Q_OBJECT

public:
  MyDemo(QWidget *parent = 0);

private:
  Ui::DemoDialog ui;

};

#endif
