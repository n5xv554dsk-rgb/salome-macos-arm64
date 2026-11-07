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
#include "ParamsConfig.hxx"

namespace ydefx
{
ParamsConfigWidget::ParamsConfigWidget(ydefx::JobParametersProxy& model,
                                       QWidget* parent)
: QScrollArea(parent)
, _model(model)
, _extraEdit(nullptr)
{
  QWidget* mainWidget = new QWidget();
  QVBoxLayout *mainLayout = new QVBoxLayout();
  mainWidget->setLayout(mainLayout);

  QLabel *label;
  QSpinBox *editSpin;
  QHBoxLayout *hLayout;
  QLineEdit *editLine;
  mainLayout->addWidget(new QLabel(tr(
    "Use 0 or empty fields for default or unspecified values."
  )));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Number of cores:"));
  editSpin = new QSpinBox();
  editSpin->setRange(1, 10000);
  editSpin->setValue(_model.nb_proc());
  hLayout->addWidget(label);
  hLayout->addWidget(editSpin);
  mainLayout->addLayout(hLayout);
  connect(this, SIGNAL(defaultNbBranches(int)),
          editSpin, SLOT(setValue(int)));
  connect(editSpin, SIGNAL(valueChanged(int)),
          this, SLOT(updateNbCores(int)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Number of nodes:"));
  editSpin = new QSpinBox();
  editSpin->setRange(0, 10000);
  editSpin->setValue(_model.nb_node());
  hLayout->addWidget(label);
  hLayout->addWidget(editSpin);
  mainLayout->addLayout(hLayout);
  connect(editSpin, SIGNAL(valueChanged(int)),
          this, SLOT(updateNbNodes(int)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Maximum memory (MB):"));
  editSpin = new QSpinBox();
  editSpin->setRange(0, 1000000);
  editSpin->setValue(_model.mem_mb());
  hLayout->addWidget(label);
  hLayout->addWidget(editSpin);
  mainLayout->addLayout(hLayout);
  connect(editSpin, SIGNAL(valueChanged(int)),
          this, SLOT(updateMemory(int)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Memory per CPU (MB):"));
  editSpin = new QSpinBox();
  editSpin->setRange(0, 10000);
  editSpin->setValue(_model.mem_per_cpu());
  hLayout->addWidget(label);
  hLayout->addWidget(editSpin);
  mainLayout->addLayout(hLayout);
  connect(editSpin, SIGNAL(valueChanged(int)),
          this, SLOT(updateMemoryPerCPU(int)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Maximum duration (\"hh:mm\"):"));
  editLine = new QLineEdit();
  editLine->setText(_model.maximum_duration().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateDuration(const QString&)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Queue:"));
  editLine = new QLineEdit();
  editLine->setText(_model.queue().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateQueue(const QString&)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Partition:"));
  editLine = new QLineEdit();
  editLine->setText(_model.partition().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updatePartition(const QString&)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("WcKey:"));
  editLine = new QLineEdit();
  editLine->setText(_model.wckey().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(this, SIGNAL(defaultWcKey(const QString&)),
          editLine, SLOT(setText(const QString&)));
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateWckey(const QString&)));

  QCheckBox * exclusiveCheckBox = new QCheckBox(tr("Exclusive"));
  exclusiveCheckBox->setChecked(_model.exclusive());
  mainLayout->addWidget(exclusiveCheckBox);
  connect(exclusiveCheckBox, SIGNAL(stateChanged(int)),
          this, SLOT(updateExclusive(int)));

  label = new QLabel(tr("Extra parameters:"));
  mainLayout->addWidget(label);
  _extraEdit = new QTextEdit;
  _extraEdit->setText(_model.extra_params().c_str());
  mainLayout->addWidget(_extraEdit);
  connect(_extraEdit, SIGNAL(textChanged()),
          this, SLOT(updateExtraParams()));

//  mainLayout->addStretch();
  setWidget(mainWidget);
  setWidgetResizable (true);
}

ParamsConfigWidget::~ParamsConfigWidget()
{
}

void ParamsConfigWidget::updateNbCores(int value)
{
  _model.nb_proc(value);
}

void ParamsConfigWidget::updateNbNodes(int value)
{
  _model.nb_node(value);
}

void ParamsConfigWidget::updateMemory(int value)
{
  _model.mem_mb(value);
}

void ParamsConfigWidget::updateMemoryPerCPU(int value)
{
  _model.mem_per_cpu(value);
}

void ParamsConfigWidget::updateDuration(const QString& value)
{
  _model.maximum_duration(value.toStdString());
}

void ParamsConfigWidget::updateQueue(const QString& value)
{
  _model.queue(value.toStdString());
}

void ParamsConfigWidget::updatePartition(const QString& value)
{
  _model.partition(value.toStdString());
}

void ParamsConfigWidget::updateWckey(const QString& value)
{
  _model.wckey(value.toStdString());
}

void ParamsConfigWidget::updateExclusive(int value)
{
  _model.exclusive(Qt::Checked == value);
}

void ParamsConfigWidget::updateExtraParams()
{
  _model.extra_params(_extraEdit->toPlainText().toStdString());
}

}
