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
#include "QuickConfig.hxx"

namespace ydefx
{
QuickConfigWidget::QuickConfigWidget(ydefx::JobParametersProxy& model,
                                     QWidget* parent)
: QScrollArea(parent)
, _model(model)
{
  QWidget* mainWidget = new QWidget();
  QVBoxLayout *mainLayout = new QVBoxLayout();
  mainWidget->setLayout(mainLayout);
  
  QHBoxLayout *hLayout = new QHBoxLayout();
  QComboBox* resourcesComboBox = new QComboBox;
  std::list<std::string> resources = _model.AvailableResources();
  for(const std::string& it : resources)
    resourcesComboBox->addItem(QString(it.c_str()));
  resourcesComboBox->setCurrentIndex(
                    resourcesComboBox->findText(model.resource_name().c_str()));
  connect(resourcesComboBox, SIGNAL(currentIndexChanged( const QString &)),
          this, SLOT(updateResource( const QString &)));

  QPushButton* resetBtn = new QPushButton(tr("Default parameters"));
  connect(resetBtn,SIGNAL(clicked()),this, SLOT(resetParams()));

  QLabel * resourcesLabel = new QLabel(tr("Computing resource:"));
  hLayout->addWidget(resourcesLabel);
  hLayout->addWidget(resourcesComboBox);
  hLayout->addWidget(resetBtn);
  mainLayout->addLayout(hLayout);
  
  QLabel *nb_branchesLabel = new QLabel(tr("Number of parallel evaluations:"));
  QSpinBox *nb_branchesEdit = new QSpinBox();
  nb_branchesEdit->setRange(1, 10000);
  nb_branchesEdit->setValue(_model.nb_branches());
  hLayout = new QHBoxLayout();
  hLayout->addWidget(nb_branchesLabel);
  hLayout->addWidget(nb_branchesEdit);
  mainLayout->addLayout(hLayout);
  connect(this, SIGNAL(defaultNbBranches(int)),
          nb_branchesEdit, SLOT(setValue(int)));
  connect(nb_branchesEdit, SIGNAL(valueChanged(int)),
          this, SLOT(updateNbBranches(int)));

  hLayout = new QHBoxLayout();
  QLabel *label = new QLabel(tr("Job name:"));
  QLineEdit *editLine = new QLineEdit();
  editLine->setText(_model.job_name().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateJobName(const QString&)));

  mainLayout->addStretch();
  setWidget(mainWidget);
  setWidgetResizable (true);
}

QuickConfigWidget::~QuickConfigWidget()
{
}

void QuickConfigWidget::updateJobName(const QString& value)
{
  _model.job_name(value.toStdString());
}

void QuickConfigWidget::updateResource(const QString& value)
{
  _model.resource_name(value.toStdString());
}

void QuickConfigWidget::resetParams()
{
  _model.configureResource(_model.resource_name());
  emit defaultNbBranches(_model.nb_branches());
  emit defaultWorkingDir(_model.work_directory().c_str());
  emit defaultWcKey(_model.wckey().c_str());
}

void QuickConfigWidget::updateNbBranches(int value)
{
  _model.nb_branches(value);
  emit defaultNbBranches(value);
}
}
