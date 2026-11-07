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
#include "PathsConfig.hxx"

namespace ydefx
{
PathsConfigWidget::PathsConfigWidget(ydefx::JobParametersProxy& model,
                                     QWidget* parent)
: QScrollArea(parent)
, _model(model)
, _localdirEdit(nullptr)
, _inputFilesList(nullptr)
, _removeInputFilesButton(nullptr)
{
  QWidget* mainWidget = new QWidget();
  QVBoxLayout *mainLayout = new QVBoxLayout();
  mainWidget->setLayout(mainLayout);

  QLabel *label;
  QHBoxLayout *hLayout;
  QLineEdit *editLine;

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Remote work directory:"));
  editLine = new QLineEdit();
  editLine->setText(_model.work_directory().c_str());
  hLayout->addWidget(label);
  hLayout->addWidget(editLine);
  mainLayout->addLayout(hLayout);
  connect(this, SIGNAL(defaultWorkingDir(const QString&)),
          editLine, SLOT(setText(const QString&)));
  connect(editLine, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateWorkingDirectory(const QString&)));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Temporary local directory:"));
  _localdirEdit = new QLineEdit();
  _localdirEdit->setText(_model.result_directory().c_str());
  QPushButton* localdirButton = new QPushButton("...");
  hLayout->addWidget(label);
  hLayout->addWidget(_localdirEdit);
  hLayout->addWidget(localdirButton);
  mainLayout->addLayout(hLayout);
  connect(_localdirEdit, SIGNAL(textChanged(const QString &)),
          this, SLOT(updateLocalDirectory(const QString&)));
  connect(localdirButton,SIGNAL(clicked()),this, SLOT(onChoseLocaldir()));

  hLayout = new QHBoxLayout();
  label = new QLabel(tr("Preprocessing script for the frontal:"));
  _preprocScriptEdit = new QLineEdit();
  _preprocScriptEdit->setText(_model.pre_command().c_str());
  QPushButton* preprocButton = new QPushButton("...");
  hLayout->addWidget(label);
  hLayout->addWidget(_preprocScriptEdit);
  hLayout->addWidget(preprocButton);
  mainLayout->addLayout(hLayout);
  connect(_preprocScriptEdit, SIGNAL(textChanged(const QString &)),
          this, SLOT(updatePreprocessingScript(const QString&)));
  connect(preprocButton,SIGNAL(clicked()),
          this, SLOT(onChosePreprocessingScript()));

  QGroupBox * inputFilesBox = new QGroupBox;
  inputFilesBox->setTitle(tr("Additional input files:"));
  hLayout = new QHBoxLayout();
  inputFilesBox->setLayout(hLayout);
  _inputFilesList = new QListWidget;
  _inputFilesList->setSelectionMode(QAbstractItemView::MultiSelection);
  for(const std::string& it : _model.in_files())
    _inputFilesList->addItem(it.c_str());
  QVBoxLayout *inputButtonsLayout = new QVBoxLayout;
  QPushButton *addInputFilesButton = new QPushButton(tr("+"));
  _removeInputFilesButton = new QPushButton(tr("-"));
  inputButtonsLayout->addWidget(addInputFilesButton);
  inputButtonsLayout->addWidget(_removeInputFilesButton);
  hLayout->addWidget(_inputFilesList);
  hLayout->addLayout(inputButtonsLayout);
  mainLayout->addWidget(inputFilesBox);
  _removeInputFilesButton->setEnabled(false);
  connect(addInputFilesButton, SIGNAL(clicked()), this, SLOT(addInputFiles()));
  connect(_removeInputFilesButton, SIGNAL(clicked()),
          this, SLOT(removeInputFiles()));
  connect(_inputFilesList, SIGNAL(itemSelectionChanged()),
          this, SLOT(inputSelectionChanged()));

  setWidget(mainWidget);
  setWidgetResizable (true);
}

PathsConfigWidget::~PathsConfigWidget()
{
}

void PathsConfigWidget::updateWorkingDirectory(const QString& value)
{
  _model.work_directory(value.toStdString());
}

void PathsConfigWidget::updateLocalDirectory(const QString& value)
{
  _model.result_directory(value.toStdString());
}

void PathsConfigWidget::updatePreprocessingScript(const QString& value)
{
  _model.pre_command(value.toStdString());
}

void PathsConfigWidget::onChoseLocaldir()
{
  QString dir;
  dir = QFileDialog::getExistingDirectory(this,
                                          tr("Choose temporary local directory"),
                                          "",
                                          QFileDialog::ShowDirsOnly
                                          | QFileDialog::DontResolveSymlinks);

  if (dir != "")
  {
    _model.result_directory(dir.toStdString());
    _localdirEdit->setText(dir);
  }
}

void PathsConfigWidget::onChosePreprocessingScript()
{
  QString file;
  file = QFileDialog::getOpenFileName(this,
                                      tr("Choose a script file"),
                                      "");

  if (file != "")
  {
    _model.pre_command(file.toStdString());
    _preprocScriptEdit->setText(file);
  }
}

void PathsConfigWidget::inputSelectionChanged()
{
  bool canRemove = (_inputFilesList->selectedItems().size() > 0);
  _removeInputFilesButton->setEnabled(canRemove);
}

void PathsConfigWidget::addInputFiles()
{
  // We need to be able to select both files and folders.
  // Standard QFileDialog cannot do it.
  QFileDialog w(this, tr("Select input files"),
              "", tr("All files and folders(*)")) ;
  w.setOption(QFileDialog::DontUseNativeDialog,true);
  QListView *l = w.findChild<QListView*>("listView");
  if (l)
  {
    l->setSelectionMode(QAbstractItemView::MultiSelection);
  }
  QTreeView *t = w.findChild<QTreeView*>();
  if (t)
  {
    t->setSelectionMode(QAbstractItemView::MultiSelection);
  }
  if(w.exec())
  {
    QStringList fileNames = w.selectedFiles();
    for (int i = 0; i < fileNames.size(); ++i) 
    {
      QString fileName = fileNames.at(i);
      std::list<std::string> additionalFiles;
      if (_inputFilesList->findItems(fileName,Qt::MatchFixedString).size() == 0)
      {
        additionalFiles.push_back(fileName.toStdString());
        _inputFilesList->addItem(fileName);
      }
      _model.add_in_files(additionalFiles);
    }
  }
}

void PathsConfigWidget::removeInputFiles()
{
  QList<QListWidgetItem *> list = _inputFilesList->selectedItems();
  for (int i = 0; i < list.size(); ++i)
  {
    int row = _inputFilesList->row( list.at(i) );
    QListWidgetItem * item = _inputFilesList->takeItem(row);
    std::string itemName = item->text().toStdString();
    _model.remove_in_file(itemName);
    delete item;
  }
}
}
