// Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
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
// See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
//
/*
 * _typemap.i : 
 *
 * Auteur : Ivan DUTKA-MALEN - EDF R&D
 * Date   : Septembre 2003
 * Projet : SALOME 2
 *
 */

%{
#include <string>
#include <list>
#include <map>
#include "ParameterTypeMap.hxx"
#include "Parametre.hxx"
#include "JobId.hxx"
#include "FactBatchManager.hxx"
#include "RunTimeException.hxx"
%}

# // supprime toutes les definitions par defaut => sert au debug
# %typemap(in) SWIGTYPE ;

%{
// Helper function to initialize a Batch::Versatile from a PyObj
static bool initVersatile(Batch::Versatile & newVersatile, PyObject * input)
{
  if (PyList_Check(input)) { // c'est une liste
    for (Py_ssize_t i=0; i<PyList_Size(input); i++) {
      PyObject * val = PyList_GetItem(input, i);
      if (PyUnicode_Check(val)) {
        newVersatile += PyUnicode_AsUTF8(val);
      } else if (PyTuple_Check(val) &&
          (PyTuple_Size(val) == 2) &&
          PyUnicode_Check( PyTuple_GetItem(val,0) ) &&
          PyUnicode_Check( PyTuple_GetItem(val,1) )   ) {
        newVersatile += Batch::Couple( PyUnicode_AsUTF8(PyTuple_GetItem(val,0)),
                                       PyUnicode_AsUTF8(PyTuple_GetItem(val,1)));

      } else {
        PyErr_SetString(PyExc_RuntimeWarning, "initVersatile : invalid PyObject");
        return false;
      }
    }

  } else if (PyUnicode_Check(input)) { // c'est une string
    newVersatile = PyUnicode_AsUTF8(input);
  } else if (PyBool_Check(input)) { // c'est un bool
    newVersatile = (input == Py_True);
  } else if (PyInt_Check(input)) { // c'est un int
    newVersatile = PyInt_AsLong(input);
  } else { // erreur
    PyErr_SetString(PyExc_RuntimeWarning, "initVersatile : invalid PyObject");
    return false;
  }
  return true;
}

// Helper function to create a PyObj from a Batch::Versatile
static PyObject * versatileToPyObj(const Batch::Versatile & vers)
{
  PyObject * obj;

  if (vers.getMaxSize() != 1) { // une liste
    obj = PyList_New(0);
    for(Batch::Versatile::const_iterator it=vers.begin(); it!=vers.end(); it++) {
      std::string st;
      Batch::Couple cp;
      switch (vers.getType()) {
      case Batch::LONG:
        PyList_Append(obj, PyInt_FromLong(* static_cast<Batch::LongType *>(*it)));
        break;

      case Batch::STRING:
        st = * static_cast<Batch::StringType *>(*it);
        PyList_Append(obj, PyString_FromString(st.c_str()));
        break;

      case Batch::COUPLE:
        cp = * static_cast<Batch::CoupleType *>(*it);
        PyList_Append(obj, Py_BuildValue("(ss)", cp.getLocal().c_str(), cp.getRemote().c_str() ));
        break;

      default:
        throw Batch::RunTimeException("Versatile object cannot be converted to Python object");
      }

    }

  } else {
    bool b;
    std::string st;
    Batch::Couple cp;
    switch (vers.getType()) {
    case Batch::BOOL:
      b = (* static_cast<Batch::BoolType *>(vers.front()));
      obj = PyBool_FromLong(b);
      break;

    case Batch::LONG:
      obj = PyInt_FromLong(* static_cast<Batch::LongType *>(vers.front()));
      break;

    case Batch::STRING:
      st = * static_cast<Batch::StringType *>(vers.front());
      obj = PyString_FromString(st.c_str());
      break;

    case Batch::COUPLE:
      cp = * static_cast<Batch::CoupleType *>(vers.front());
      obj = Py_BuildValue("[(ss)]", cp.getLocal().c_str(), cp.getRemote().c_str() );
      break;

    default:
      throw Batch::RunTimeException("Versatile object cannot be converted to Python object");
    }
  }

  return obj;
}

// Helper function to initialize a Batch::Parametre from a PyObj
static bool initParameter(Batch::Parametre & newParam, PyObject * input)
{
  if (!PyDict_Check(input)) {
    PyErr_SetString(PyExc_ValueError, "Expected a dictionnary");
    return false;
  }

  try {
    // on itere sur toutes les clefs du dictionnaire, et on passe par la classe PyVersatile
    // qui convertit un Versatile en PyObject et vice versa
    PyObject *key, *value;
    Py_ssize_t pos = 0;
    while (PyDict_Next(input, &pos, &key, &value)) {
      std::string mk = PyUnicode_AsUTF8(key);
      bool res = initVersatile(newParam[mk], value);
      if (!res)
        return false;
    }
  }
  catch (Batch::GenericException & ex) {
      std::string msg = ex.type + " : " + ex.message;
      PyErr_SetString(PyExc_RuntimeWarning, msg.c_str());
      return false;
  }
  catch (...) {
      PyErr_SetString(PyExc_RuntimeWarning, "unknown exception");
      return false;
  }
  return true;
}

// Helper function to initialize a Batch::Environnement from a PyObj
static bool initEnvironment(Batch::Environnement & newEnv, PyObject * input)
{
  if (!PyDict_Check(input)) {
    PyErr_SetString(PyExc_ValueError, "Expected a dictionnary");
    return false;
  }

  // on itere sur toutes les clefs du dictionnaire
  PyObject *key, *value;
  Py_ssize_t pos = 0;
  while (PyDict_Next(input, &pos, &key, &value)) {
    std::string mk  = PyUnicode_AsUTF8(key);
    std::string val = PyUnicode_AsUTF8(value);
    newEnv[mk] = val;
  }
  return true;
}
%}

# // construction d'un dictionnaire Python a partir d'un objet BatchManagerCatalog C++
%typemap(out) std::map<std::string, Batch::FactBatchManager *> *
{
  $result = PyDict_New();

  // on itere sur toutes les clefs de la map
  for(std::map<std::string, Batch::FactBatchManager *>::const_iterator it=(* $1).begin(); it!=(* $1).end(); it++) {
    std::string key = (*it).first;
    PyObject * obj  = SWIG_NewPointerObj((void *) (*it).second, SWIGTYPE_p_Batch__FactBatchManager, 0);
    PyDict_SetItem($result, PyString_FromString(key.c_str()), obj);
  }
}

%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) Batch::Parametre
{
  $1 = PyDict_Check($input)? 1 : 0;
}

# // construction d'un dictionnaire Python a partir d'un objet Parametre C++
%typemap(out) Batch::Parametre
{
  $result = PyDict_New();

  // on itere sur toutes les clefs de la map, et on passe par la classe PyVersatile
	// qui convertit un Versatile en PyObject et vice versa
  for(Batch::Parametre::const_iterator it=$1.begin(); it!=$1.end(); it++) {
    const std::string & key = (*it).first;
    const Batch::Versatile & vers = (*it).second;
    PyDict_SetItem($result, PyString_FromString(key.c_str()), versatileToPyObj(vers));
  }
}

// Build a C++ object Batch::Parametre from a Python dictionary
%typemap(in) const Batch::Parametre & (Batch::Parametre PM)
{
  bool res = initParameter(PM, $input);
  if (res)
    $1 = &PM;
  else
    return NULL;
}

%typemap(in) Batch::Parametre
{
  bool res = initParameter($1, $input);
  if (!res) return NULL;
}

%typemap(typecheck,precedence=SWIG_TYPECHECK_POINTER) Batch::Environnement
{
  $1 = PyDict_Check($input)? 1 : 0;
}

# // construction d'un dictionnaire Python a partir d'un objet Environnement C++
%typemap(out) Batch::Environnement
{
  $result = PyDict_New();

  // on itere sur toutes les clefs de la map
  for(Batch::Environnement::const_iterator it=$1.begin(); it!=$1.end(); it++) {
    std::string key = (*it).first;
    std::string val = (*it).second;
    PyDict_SetItem($result, 
		   PyString_FromString(key.c_str()),
		   PyString_FromString(val.c_str()));
  }
}

// Build a C++ object Batch::Environnement from a Python dictionary
%typemap(in) const Batch::Environnement & (Batch::Environnement E)
{
  bool res = initEnvironment(E, $input);
  if (res)
    $1 = &E;
  else
    return NULL;
}

%typemap(in) Batch::Environnement
{
  bool res = initEnvironment($1, $input);
  if (!res) return NULL;
}
