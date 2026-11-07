#include "ICOCO.hxx"

#include "MEDCouplingUMesh.hxx"
#include "MEDCouplingMemArray.hxx"
#include "MEDCouplingFieldDouble.hxx"
#include <iterator>
#include <iostream>

using namespace std;

const char ICOCO::FIELD_NAME1[]="SourceField";
const char ICOCO::FIELD_NAME2[]="TargetField";

ICOCO::ICOCO():_field_source(0),_field_target(0)
{
}

ICOCO::~ICOCO()
{
  if(_field_source)
    _field_source->decrRef();
  if(_field_target)
    _field_target->decrRef();
}

bool ICOCO::solve()
{
  if(!_field_source)
    _field_source=buildSourceField();
  else
    {
      double *values=_field_source->getArray()->getPointer();
      int nbOfValues=_field_source->getNumberOfTuples()*_field_source->getNumberOfComponents();
      std::transform(values,values+nbOfValues,values,std::bind2nd(std::multiplies<double>(),2.));
      _field_source->declareAsNew();
    }
  if(!_field_target)
    _field_target=buildTargetField();
  else
    {
      double *values=_field_target->getArray()->getPointer();
      int nbOfValues=_field_target->getNumberOfTuples()*_field_target->getNumberOfComponents();
      std::transform(values,values+nbOfValues,values,std::bind2nd(std::multiplies<double>(),3.));
      _field_target->declareAsNew();
    }
}

void ICOCO::initialize()
{
  if(_field_source)
    _field_source->decrRef();
  _field_source=0;
  if(_field_target)
    _field_target->decrRef();
  _field_target=0;
}

std::vector<std::string> ICOCO::getInputFieldsNames()
{
    std::vector<std::string> ret;
    ret.push_back(FIELD_NAME1);
    ret.push_back(FIELD_NAME2);
    return ret;
}

MEDCoupling::MEDCouplingUMesh *ICOCO::getInputFieldTemplate(const char *name)
{
  std::string nameCpp(name);
  if(nameCpp==FIELD_NAME1)
    return buildSourceUMesh();
  if(nameCpp==FIELD_NAME2)
    return buildTargetUMesh();
  return 0;
}

MEDCoupling::MEDCouplingFieldDouble *ICOCO::getOutputField(const char *fieldName)
{
  std::string fieldNameCpp(fieldName);
  if(fieldNameCpp==FIELD_NAME1)
    {
      if(_field_source)
        _field_source->incrRef();
      return _field_source;
    }
  if(fieldNameCpp==FIELD_NAME2)
    {
      if(_field_target)
        _field_target->incrRef();
      return _field_target;
    }
  return 0;
}

void ICOCO::printField(const MEDCoupling::MEDCouplingFieldDouble *field)
{
    std::copy(field->getArray()->getConstPointer(),field->getArray()->getConstPointer()+field->getArray()->getNbOfElems(),std::ostream_iterator<double>(cout," "));
    std::cout << endl;
}

void ICOCO::setInputField(const char *name, const MEDCoupling::MEDCouplingFieldDouble *field)
{
  std::string nameCpp(name);
  if(nameCpp==FIELD_NAME1)
    {
      if(_field_source)
        _field_source->decrRef();
      _field_source=(MEDCoupling::MEDCouplingFieldDouble *)field;
      if(_field_source)
        _field_source->incrRef();
    }
  if(nameCpp==FIELD_NAME2)
    {
      if(_field_target)
        _field_target->decrRef();
      _field_target=(MEDCoupling::MEDCouplingFieldDouble *)field;
      if(_field_target)
        _field_target->incrRef();
    }
}

MEDCoupling::MEDCouplingUMesh *ICOCO::buildSourceUMesh()
{
  double sourceCoords[27]={ 0.0, 0.0, 200.0, 0.0, 0.0, 0.0, 0.0, 200.0, 200.0, 0.0, 200.0, 0.0, 200.0, 0.0, 200.0,
                            200.0, 0.0, 0.0, 200.0, 200.0, 200.0, 200.0, 200.0, 0.0, 100.0, 100.0, 100.0 };
  int sourceConn[48]={8,1,7,3, 6,0,8,2, 7,4,5,8, 6,8,4,7, 6,8,0,4, 6,8,7,3, 8,1,3,0, 4,1,5,8, 1,7,5,8, 0,3,8,2, 8,1,0,4, 3,6,8,2};
  MEDCoupling::MEDCouplingUMesh *sourceMesh=MEDCoupling::MEDCouplingUMesh::New();
  sourceMesh->setMeshDimension(3);
  sourceMesh->allocateCells(12);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+4);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+8);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+12);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+16);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+20);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+24);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+28);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+32);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+36);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+40);
  sourceMesh->insertNextCell(INTERP_KERNEL::NORM_TETRA4,4,sourceConn+44);
  sourceMesh->finishInsertingCells();
  MEDCoupling::DataArrayDouble *myCoords=MEDCoupling::DataArrayDouble::New();
  myCoords->alloc(9,3);
  std::copy(sourceCoords,sourceCoords+27,myCoords->getPointer());
  sourceMesh->setCoords(myCoords);
  myCoords->decrRef();
  return sourceMesh;
}

MEDCoupling::MEDCouplingUMesh *ICOCO::buildTargetUMesh()
{
  double targetCoords[81]={ 0., 0., 0., 50., 0., 0. , 200., 0., 0.  , 0., 50., 0., 50., 50., 0. , 200., 50., 0.,   0., 200., 0., 50., 200., 0. , 200., 200., 0. ,
                            0., 0., 50., 50., 0., 50. , 200., 0., 50.  , 0., 50., 50., 50., 50., 50. , 200., 50., 50.,   0., 200., 50., 50., 200., 50. , 200., 200., 50. ,
                            0., 0., 200., 50., 0., 200. , 200., 0., 200.  , 0., 50., 200., 50., 50., 200. , 200., 50., 200.,   0., 200., 200., 50., 200., 200. , 200., 200., 200. };
  int targetConn[64]={0,1,4,3,9,10,13,12, 1,2,5,4,10,11,14,13, 3,4,7,6,12,13,16,15, 4,5,8,7,13,14,17,16,
                      9,10,13,12,18,19,22,21, 10,11,14,13,19,20,23,22, 12,13,16,15,21,22,25,24, 13,14,17,16,22,23,26,25};
  MEDCoupling::MEDCouplingUMesh *targetMesh=MEDCoupling::MEDCouplingUMesh::New();
  targetMesh->setMeshDimension(3);
  targetMesh->allocateCells(12);
  for(int i=0;i<8;i++)
    targetMesh->insertNextCell(INTERP_KERNEL::NORM_HEXA8,8,targetConn+8*i);
  targetMesh->finishInsertingCells();
  MEDCoupling::DataArrayDouble *myCoords=MEDCoupling::DataArrayDouble::New();
  myCoords->alloc(27,3);
  std::copy(targetCoords,targetCoords+81,myCoords->getPointer());
  targetMesh->setCoords(myCoords);
  myCoords->decrRef();
  return targetMesh;
}

MEDCoupling::MEDCouplingFieldDouble *ICOCO::buildSourceField()
{
  MEDCoupling::MEDCouplingUMesh *mesh=buildSourceUMesh();
  MEDCoupling::MEDCouplingFieldDouble *fieldOnCells=MEDCoupling::MEDCouplingFieldDouble::New(MEDCoupling::ON_CELLS);
  fieldOnCells->setMesh(mesh);
  MEDCoupling::DataArrayDouble *array=MEDCoupling::DataArrayDouble::New();
  array->alloc(mesh->getNumberOfCells(),1);
  fieldOnCells->setArray(array);
  double *values=array->getPointer();
  for(int i=0;i<mesh->getNumberOfCells();i++)
    values[i]=2.*((double)i);
  mesh->decrRef();
  array->decrRef();
  return fieldOnCells;
}

MEDCoupling::MEDCouplingFieldDouble *ICOCO::buildTargetField()
{
  MEDCoupling::MEDCouplingUMesh *mesh=buildTargetUMesh();
  MEDCoupling::MEDCouplingFieldDouble *fieldOnCells=MEDCoupling::MEDCouplingFieldDouble::New(MEDCoupling::ON_CELLS);
  fieldOnCells->setMesh(mesh);
  MEDCoupling::DataArrayDouble *array=MEDCoupling::DataArrayDouble::New();
  array->alloc(mesh->getNumberOfCells(),1);
  fieldOnCells->setArray(array);
  double *values=array->getPointer();
  for(int i=0;i<mesh->getNumberOfCells();i++)
    values[i]=7.*((double)i);
  mesh->decrRef();
  array->decrRef();
  return fieldOnCells;
}

