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

// File:      LightApp_ExtInfoDlg.cxx
// Author:    Konstantin Leontev
//
#include "LightApp_ExtInfoDlg.h"
#include "utilities.h"

// Prevent slot compilation error
#pragma push_macro("slots")
#undef slots
#include "PyInterp_Utils.h"
#pragma pop_macro("slots")

#include <QHBoxLayout>
#include <QScrollArea>
#include <QSplitter>
// Show extensions info
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QHeaderView>

// Render dependency tree
#include <QSvgWidget>
#include <QByteArray>
#include <graphviz/gvc.h>


/*! RAII wrapper to graphviz Agraph_t.*/
class GraphWrapper
{
  public:
    virtual ~GraphWrapper();

    void init(char* name, Agdesc_t desc = Agstrictdirected, Agdisc_t* disc = nullptr);

    Agraph_t* getGraph() const { return m_graph; }
    GVC_t* getGvc() const { return m_gvc; }

  private:
    Agraph_t* m_graph = nullptr;
    GVC_t* m_gvc = nullptr;
};

GraphWrapper::~GraphWrapper()
{
  if (m_graph)
  {
    agclose(m_graph);
    m_graph = nullptr;
  }

  if (m_gvc)
  {
    gvFreeContext(m_gvc);
    m_gvc = nullptr;
  }
}

void GraphWrapper::init(char *name, Agdesc_t desc /* = Agstrictdirected */, Agdisc_t* disc /* = nullptr */)
{
  m_graph = agopen(name, desc, disc);
  m_gvc = gvContext();
}

/*!Constructor.
Creates the array and image in a splitter
*/
LightApp_ExtInfoDlg::LightApp_ExtInfoDlg(QWidget* parent)
: QtxDialog(parent, true, true, ButtonFlags::OK)
{
  MESSAGE("Start creating a dialog...\n");

  setObjectName("salome_ext_info_dialog");
  setWindowTitle(tr("EXT_INFO_CAPTION"));
  setSizeGripEnabled(true); // allows resizing by the corner
  setButtonPosition(ButtonPosition::Center, ButtonFlags::OK);

  // Create the main widgets
  auto extInfoWidget = getExtListWidget(mainFrame());
  auto extTreeWidget = getExtTreeWidget(mainFrame());

  // Horizontal splitter: array | picture
  auto splitter = new QSplitter(Qt::Horizontal, mainFrame());
  splitter->addWidget(extInfoWidget);
  splitter->addWidget(extTreeWidget);
  splitter->setStretchFactor(0, 3);
  splitter->setStretchFactor(1, 0);

  auto layout = new QHBoxLayout(mainFrame());
  layout->addWidget(splitter);
}

/*!Destructor.*/
LightApp_ExtInfoDlg::~LightApp_ExtInfoDlg()
{
  //! Do nothing.
}

/*! Fill the given widget with info about installed extensions */
bool LightApp_ExtInfoDlg::fillExtListWidget(QTableWidget* extListWidget) const
{
  MESSAGE("Getting info from SalomeOnDemandTK.extension_query...\n");

  // Import Python module that manages SALOME extensions
  PyLockWrapper lck; // acquire GIL
  PyObjWrapper extensionQuery = PyImport_ImportModule((char*)"SalomeOnDemandTK.extension_query_impl");
  auto extRootDir = getenv("SALOME_APPLICATION_DIR");
  PyObjWrapper extInfoDict = PyObject_CallMethod(extensionQuery, (char*)"ext_info_list", (char*)"s", extRootDir);
  if (!extInfoDict)
  {
    PyErr_Print();
    return false;
  }

  // Check if we have any info to display
  Py_ssize_t rowCount = PyDict_Size(extInfoDict);
  if (!rowCount)
  {
    MESSAGE("Didn't find any extensions! Return.\n");
    return false;
  }

  extListWidget->setRowCount(rowCount);
  const int columnCount = extListWidget->columnCount();

  auto makeTableWidgetItem = [](PyObject* itemText) -> QTableWidgetItem*
  {
    const char* itemTextStr = PyUnicode_AsUTF8(itemText);
    SCRUTE(itemTextStr);

    return new QTableWidgetItem(itemTextStr);
  };

  PyObject* keyName = nullptr;
  PyObject* infoList = nullptr;
  Py_ssize_t keyNamePos = 0;

  // Iterate name:info_list dictionary
  while (PyDict_Next(extInfoDict, &keyNamePos, &keyName, &infoList))
  {
    // ---- Name column ----
    auto nameItem = makeTableWidgetItem(keyName);

    // keyNamePos is already 1 on the first iteration, so we need to decrease it 
    extListWidget->setItem(keyNamePos - 1, 0, nameItem);

    // Tooltip = Description (assume infoList[0] = Description)
    const char* tooltipStr = nullptr;
    if (PyList_Size(infoList) >= 1)
    {
      PyObject* descriptionObj = PyList_GetItem(infoList, 0);
      tooltipStr = PyUnicode_AsUTF8(descriptionObj);
      nameItem->setToolTip(tooltipStr);
    }

    // ---- Size column ----
    if (PyList_Size(infoList) >= 4) // infoList[3] = Size
    {
      PyObject* sizeObj = PyList_GetItem(infoList, 3);
      auto sizeItem = makeTableWidgetItem(sizeObj);

      // keyNamePos started from 1 instead of 0, so decrease
      extListWidget->setItem(keyNamePos - 1, 1, sizeItem);

      // Tooltip also on size column
      if (tooltipStr)
        sizeItem->setToolTip(tooltipStr);
    }
  }

  return true;
}

/*! Return widget with info about installed extensions */
/*!
  * Creates the extensions table
  * Columns: Name, Size
  * Description is displayed as a tooltip
*/
QWidget* LightApp_ExtInfoDlg::getExtListWidget(QWidget* parent) const
{
  MESSAGE("Make a widget to display extensions info...\n");

  auto extListWidget = new QTableWidget(parent);

  // Setup the table params
  const QStringList headerLabels = {
    "Name", "Size"
    };

  extListWidget->setColumnCount(headerLabels.count());
  extListWidget->setHorizontalHeaderLabels(headerLabels);

  // Fill it with data about extensions
  if (fillExtListWidget(extListWidget))
  {
    // Tune an appearance
    extListWidget->sortItems(0);
    extListWidget->horizontalHeader()->setStretchLastSection(true);
    extListWidget->resizeColumnsToContents();
    extListWidget->setSizeAdjustPolicy(QAbstractScrollArea::AdjustToContents);
  }

  return extListWidget;
}

/*! Fill a given extension tree graph with nodes and edges */
bool LightApp_ExtInfoDlg::fillExtTreeGraph(const GraphWrapper& graph) const
{
  MESSAGE("Start to get info from SalomeOnDemandTK.extension_query...\n");

  // Import Python module that manages SALOME extensions
  PyLockWrapper lck; // acquire GIL
  PyObjWrapper extensionQuery = PyImport_ImportModule((char*)"SalomeOnDemandTK.extension_query_impl");
  auto extRootDir = getenv("SALOME_APPLICATION_DIR");
  PyObjWrapper dependencyTree = PyObject_CallMethod(extensionQuery, (char*)"dependency_tree", (char*)"s", extRootDir);
  if (!dependencyTree)
  {
    PyErr_Print();
    return false;
  }

  Agraph_t* extTreeGraph = graph.getGraph();

  // Python declarations
  PyObject* extName = nullptr;
  PyObject* dependantsList = nullptr;
  Py_ssize_t pos = 0;

  // Iterate the tree
  while (PyDict_Next(dependencyTree, &pos, &extName, &dependantsList))
  {
    // Create a parent node if it doesn't already exist
    auto parentName = PyUnicode_AsUTF8(extName);
    Agnode_t* parentNode = agnode(extTreeGraph, const_cast<char*>(parentName), true);
    SCRUTE(parentName);

    // Iterate a list of dependants
    for (Py_ssize_t depPos = 0; depPos < PyList_Size(dependantsList); ++depPos)
    {
      auto dependant = PyList_GetItem(dependantsList, depPos);

      // Create a child node if it doesn't already exist
      auto dependantName = PyUnicode_AsUTF8(dependant);
      Agnode_t* dependantNode = agnode(extTreeGraph, const_cast<char*>(dependantName), true);
      SCRUTE(dependantName);

      // Make an edge
      std::string edgeNameStr(parentName);
      edgeNameStr += dependantName;
      auto edgeName = edgeNameStr.c_str();
      agedge(extTreeGraph, parentNode, dependantNode, const_cast<char*>(edgeName), true);
      SCRUTE(edgeName);
    }
  }

  return true;
}

/*! Render dependency tree to array of bytes */
QByteArray LightApp_ExtInfoDlg::renderExtTreeGraph(const GraphWrapper& graph) const
{
  Agraph_t* extTreeGraph = graph.getGraph();
  GVC_t* gvc = graph.getGvc();

  // Layout and render to buffer
  MESSAGE("Layout dependency tree...\n");
  int res = gvLayout(gvc, extTreeGraph, "dot");
  if (res)
  {
    MESSAGE("gvLayout failed!\n");
    return {};
  }

  MESSAGE("Render dependency tree...\n");
  char* buffer = nullptr;
  long unsigned int bufferLength = 0;
  res = gvRenderData(gvc, extTreeGraph, "svg", &buffer, &bufferLength);
  if (res)
  {
    MESSAGE("gvRenderData failed!\n");
    return {};
  }

  QByteArray renderedGraph(buffer, bufferLength);
  
  // Clean up layout and buffer
  gvFreeLayout(gvc, extTreeGraph);
  gvFreeRenderData(buffer);

  return renderedGraph;
}

/*! Return widget with an image of dependency tree fot installed extensions */
QWidget* LightApp_ExtInfoDlg::getExtTreeWidget(QWidget* parent) const
{
  MESSAGE("Start to make a widget to show dependency tree...\n");

  auto extTreeWidget = new QSvgWidget(parent);

  // Graph to be filled up from python data
  GraphWrapper extTreeGraph;
  char graphName[] = "extTreeGraph";
  extTreeGraph.init(graphName);
  if (fillExtTreeGraph(extTreeGraph))
  {
    extTreeWidget->load(renderExtTreeGraph(extTreeGraph));
  }

    // scroll area
    QScrollArea* extTreeScroll = new QScrollArea(parent);
    extTreeScroll->setWidget(extTreeWidget);
    extTreeScroll->setWidgetResizable(false);

    return extTreeScroll;
}
