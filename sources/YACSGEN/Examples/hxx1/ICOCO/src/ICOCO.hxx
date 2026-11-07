#ifndef _ICOCO_HXX_
#define _ICOCO_HXX_

// forward declaration
#include <vector>
#include <string>

namespace MEDCoupling
{
  class MEDCouplingUMesh;
  class MEDCouplingFieldDouble;
}

class ICOCO
{
// Méthodes publiques
public:
  ICOCO();
  ~ICOCO();
  void initialize();
  bool solve();
  std::vector<std::string> getInputFieldsNames();
  MEDCoupling::MEDCouplingUMesh *getInputFieldTemplate(const char *name);
  MEDCoupling::MEDCouplingFieldDouble *getOutputField(const char *fieldName);
  void printField(const MEDCoupling::MEDCouplingFieldDouble *field);
  void setInputField(const char *name, const MEDCoupling::MEDCouplingFieldDouble *field);
private:
  MEDCoupling::MEDCouplingUMesh *buildSourceUMesh();
  MEDCoupling::MEDCouplingUMesh *buildTargetUMesh();
  MEDCoupling::MEDCouplingFieldDouble *buildSourceField();
  MEDCoupling::MEDCouplingFieldDouble *buildTargetField();
private:
  MEDCoupling::MEDCouplingFieldDouble *_field_source;
  MEDCoupling::MEDCouplingFieldDouble *_field_target;
private:
  static const char FIELD_NAME1[];
  static const char FIELD_NAME2[];
};

#endif
