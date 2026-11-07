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
#ifndef IDEFX_ParamsConfigWidget_HXX
#define IDEFX_ParamsConfigWidget_HXX
#include "JobParametersProxy.hxx"
#include <QtWidgets>

namespace ydefx
{
class ParamsConfigWidget: public QScrollArea
{
  Q_OBJECT
public:
  ParamsConfigWidget(ydefx::JobParametersProxy& model, QWidget* parent=0);
  virtual ~ParamsConfigWidget();

public slots:
  void updateNbCores(int value);
  void updateNbNodes(int value);
  void updateMemory(int value);
  void updateMemoryPerCPU(int value);
  void updateDuration(const QString& value);
  void updateQueue(const QString& value);
  void updatePartition(const QString& value);
  void updateWckey(const QString& value);
  void updateExclusive(int value);
  void updateExtraParams();

signals:
  void defaultNbBranches(int value);
  void defaultWcKey(const QString& value);

private:
  ydefx::JobParametersProxy& _model;
  QTextEdit * _extraEdit;
};
}
#endif //IDEFX_ParamsConfigWidget_HXX
