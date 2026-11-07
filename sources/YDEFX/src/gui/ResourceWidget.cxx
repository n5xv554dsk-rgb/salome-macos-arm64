// Copyright (C) 2019-2026 EDF
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

#include "ResourceWidget.hxx"
#include "QuickConfig.hxx"
#include "PathsConfig.hxx"
#include "ParamsConfig.hxx"

namespace ydefx
{
ResourceWidget::ResourceWidget(ydefx::JobParametersProxy& model,
                               QWidget* parent)
: QTabWidget(parent)
, _model(model)
{
  QuickConfigWidget* quickWidget = new QuickConfigWidget(_model, parent);
  PathsConfigWidget* pathsWidget = new PathsConfigWidget(_model, parent);
  ParamsConfigWidget* paramsWidget = new ParamsConfigWidget(_model, parent);
  addTab(quickWidget, tr("&Quick configuration"));
  addTab(paramsWidget, tr("Advanced &parameters"));
  addTab(pathsWidget, tr("&Files and directories"));
  connect(quickWidget, SIGNAL(defaultNbBranches(int)),
          paramsWidget, SIGNAL(defaultNbBranches(int)));
  connect(quickWidget, SIGNAL(defaultWcKey(const QString&)),
          paramsWidget, SIGNAL(defaultWcKey(const QString&)));
  connect(quickWidget, SIGNAL(defaultWorkingDir(const QString&)),
          pathsWidget, SIGNAL(defaultWorkingDir(const QString&)));
}

ResourceWidget::~ResourceWidget()
{
}
}
