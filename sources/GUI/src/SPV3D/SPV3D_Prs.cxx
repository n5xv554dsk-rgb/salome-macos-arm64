// Copyright (C) 2023-2026  CEA, EDF
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

//  SALOME PV3DViewer : build PV3D viewer into Salome desktop
//  File   : SPV3D_Prs.cxx

#include "SPV3D_Prs.h"
#include "SPV3D_ViewWindow.h"

#include <vtkAppendPolyData.h>
#include "vtkActor.h"
#include "vtkPolyData.h"
#include "vtkCellData.h"
#include "vtkMapper.h"
#include "pqServer.h"
#include "pqApplicationCore.h"
#include "pqServerManagerModel.h"
#include "pqObjectBuilder.h"
#include "pqPipelineSource.h"
#include "vtkSMSourceProxy.h"
#include "vtkPVTrivialProducer.h"
#include <pqDataRepresentation.h>

#include <QDebug>

vtkIdType SPV3D_Prs::cellid = 0;
vtkIdType SPV3D_Prs::nbsolid = 0;

SPV3D_EXPORTSPV3DData::SPV3D_EXPORTSPV3DData()
{
  nbsolid = 0;
  _multiGEOMData = vtkSmartPointer<vtkMultiBlockDataSet>::New();
  pqServer *serv(pqApplicationCore::instance()->getServerManagerModel()->findServer(pqServerResource("builtin:")));
  pqObjectBuilder *builder(pqApplicationCore::instance()->getObjectBuilder());
  _sourceProducer = builder->createSource("sources","PVTrivialProducer",serv);
}
void SPV3D_EXPORTSPV3DData::SetPolyData(vtkPolyData* ds)
{
  _multiGEOMData->SetBlock(nbsolid , ds);
  nbsolid++;
}

void SPV3D_EXPORTSPV3DData::SetPrs(vtkPolyData* ds, const char* entry)
{
  unsigned int id;
  if (havePrs(entry, id))
    return;
  auto nbCells( ds->GetNumberOfCells() );

  vtkNew<vtkIdTypeArray> solidIdArray;
  qInfo() << "nb of cells: " << nbCells;
  solidIdArray->SetNumberOfComponents(1);
  solidIdArray->SetNumberOfTuples( nbCells );
  solidIdArray->SetName("Solid id");

//  vtkNew<vtkIdTypeArray> cellIdArray;
//  cellIdArray->SetNumberOfComponents(1);
//  cellIdArray->SetNumberOfTuples( nbCells );
//  cellIdArray->SetName("Edge id");

  vtkIdType *pt( solidIdArray->GetPointer(0) );
  vtkIdType solidid = SPV3D_Prs::FromEntryToVtkId(entry);
  std::for_each(pt,pt+nbCells,[solidid](vtkIdType& elt) { elt = solidid;});
// pt = cellIdArray->GetPointer(0);
// std::for_each(pt,pt+nbCells,[](vtkIdType& elt) { elt = SPV3D_Prs::cellid;SPV3D_Prs::cellid++; });

  ds->GetCellData()->AddArray( solidIdArray );
// ->GetCellData()->AddArray( cellIdArray );
  SetPolyData(ds);
  updateSource_for_display();
}

void SPV3D_EXPORTSPV3DData::RemovePrs(const char* entry)
{
  unsigned int id;
  if (!havePrs(entry, id))
  {
    qWarning() << "Can not find solid with entry: " << entry;
    return;
  }
  _multiGEOMData->RemoveBlock(id);
  updateSource_for_display();
}

void SPV3D_EXPORTSPV3DData::updateSource_for_display()
{
  vtkNew<vtkAppendPolyData> appendFilter;
  nbsolid = _multiGEOMData->GetNumberOfBlocks();
  qInfo() <<"number of block: " << nbsolid;
  for (unsigned int i = 0; i < nbsolid; ++i)
  {
      vtkPolyData* polyData = vtkPolyData::SafeDownCast(_multiGEOMData->GetBlock(i));
      if (polyData)
      {
        vtkIdTypeArray* retrievedArray = vtkIdTypeArray::SafeDownCast(polyData->GetCellData()->GetArray("Solid id"));
        if (retrievedArray)
          appendFilter->AddInputData(polyData);
      }
  }
  appendFilter->Update();
  vtkNew<vtkPolyData> ds;
  ds->ShallowCopy(appendFilter->GetOutput());

  vtkSMProxy* producerBase = _sourceProducer->getProxy();
  vtkSMSourceProxy *producer(vtkSMSourceProxy::SafeDownCast(producerBase));
  vtkObjectBase *clientSideObject(producer->GetClientSideObject());
  vtkPVTrivialProducer *clientSideObjectCast = vtkPVTrivialProducer::SafeDownCast(clientSideObject);
  clientSideObjectCast->SetOutput(ds);
  _sourceProducer->updatePipeline();

  //pqServerManagerModel* smmodel = pqApplicationCore::instance()->getServerManagerModel();
  //pqProxy *producerBase2( smmodel->findItem<pqProxy*>(producerBase) );
  //if(producerBase2 && !_name.empty())
  //  producerBase2->rename( _name.c_str() );
}

bool SPV3D_EXPORTSPV3DData::IsVisible() const
{
  if( IsNull() )
    return false;
  return GetRepresentation()->isVisible();
}

bool SPV3D_EXPORTSPV3DData::havePrs(const char* entry, unsigned int & id)
{
  vtkIdType solid_id = SPV3D_Prs::FromEntryToVtkId(entry);
  id = 0;
  while (id < _multiGEOMData->GetNumberOfBlocks())
  {
      vtkPolyData* polyData = vtkPolyData::SafeDownCast(_multiGEOMData->GetBlock(id));
      if (polyData)
      {
        vtkIdTypeArray* retrievedArray = vtkIdTypeArray::SafeDownCast(polyData->GetCellData()->GetArray("Solid id"));
        if (retrievedArray && retrievedArray->GetValue(0) == solid_id)
          break;
      }
    id++;
  }

  return id < _multiGEOMData->GetNumberOfBlocks();
}

void SPV3D_EXPORTSPV3DData::Hide() const
{
  if( GetRepresentation() )
    GetRepresentation()->setVisible(0);
}

SPV3D_Prs::SPV3D_Prs( const char* entry , SPV3D_ViewWindow *view) : SALOME_PV3DPrs(entry),_view(view)
{
}

vtkIdType SPV3D_Prs::FromEntryToVtkId (const char* entry)
{
  char *str = new char[strlen(entry)+1];
  strcpy(str, entry);

  const char delimiter[2] = ":";

  char* token;
  token = strtok(str, delimiter);

  std::uint32_t ret(atoi(token));
  token = strtok(NULL, delimiter);

  while (token != NULL) {
      ret <<=8;
      ret |= atoi(token);
      token = strtok(NULL, delimiter);
  }

  return static_cast<vtkIdType> (ret);
}

const char* SPV3D_Prs::FromVtkIdToEntry(vtkIdType id)
{
  int d = id & 0xFF;
  std::uint32_t c_work = ( id & 0xFF00 ); int c = c_work >> 8;
  std::uint32_t b_work = ( id & 0xFF0000 ); int b = b_work >> 16;
  std::uint32_t a_work = ( id & 0xFF000000 ); int a = a_work >> 24;
  std::string ret = std::to_string(a) + ":" + std::to_string(b) + ":" + std::to_string(c)+ ":" + std::to_string(d);
  return ret.c_str();
}

SPV3D_Prs *SPV3D_Prs::deepCopy() const
{
  SPV3D_Prs *ret = new SPV3D_Prs( *this );
  return ret;
}

pqProxy *getPQProxy(vtkSMProxy *proxy)
{
  pqServerManagerModel* smmodel = pqApplicationCore::instance()->getServerManagerModel();
  return smmodel->findItem<pqProxy*>(proxy);
}

SPV3D_Prs:: ~SPV3D_Prs() 
{
}

void SPV3D_Prs::DisplayIn( SALOME_View* v ) const
{
  SALOME_PV3DPrs::DisplayIn(v);
}

bool SPV3D_Prs::IsNull() const
{
  if(_pvRendInfo)
  {
    unsigned int id;
    return !_pvRendInfo->havePrs(GetEntry(),id);
  }
  return true;
}

void SPV3D_Prs::FillUsingActor(vtkActor *actor) const
{
  std::cout << "Hello FillUsingActor"<<std::endl;
  int id = _view->isEntryAlreadyExist( GetEntry() );

  if(id == -1) // not exist
  {
    actor->GetMapper()->Update();
    vtkDataObject *ds = actor->GetMapper()->GetInput();
    vtkPolyData *ds2 = vtkPolyData::SafeDownCast(ds);
    if(ds2)
    {
      _view->ExportToSPV3D(ds2, GetEntry());
    }
  }
  else
  {
    qWarning() << "Geometry Object is already in viewer window";
  }
}
