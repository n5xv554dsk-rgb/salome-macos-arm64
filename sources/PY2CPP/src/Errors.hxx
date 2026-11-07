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
#ifndef PY2CPP_ERRORS_HXX
#define PY2CPP_ERRORS_HXX

#include "py2cppExports.hxx"

#include <string>
#include <exception>
#include <Python.h>

namespace py2cpp
{
/*!
 * Retrieve the last python error and return it as a formated string, containing
 * the traceback when possible.
 * After the call of this function, the python error indicator is cleared.
 * see PyErr_Fetch.
 */
PY2CPP_EXPORT std::string getLastPyError();

/*!
 * ConversionCheck class gathers the errors within fromPy functions.
 */
class PY2CPP_EXPORT ConversionCheck
{
public:
  ConversionCheck();
  ConversionCheck(const std::string& error);
  ~ConversionCheck();
  operator bool()const; //! true means no error
  void addError(const std::string& expectedType, PyObject * obj);
  void addError(const ConversionCheck& err);
  void addErrorMessage(const std::string& message);
  void reset(); //! Empty the error message.
  const std::string& getMessage()const;
private:
  std::string _message;
};

class PY2CPP_EXPORT Exception:public std::exception
{
public:
  Exception(const std::string& message);
  virtual const char* what() const noexcept;
private:
  std::string _message;
};

class PY2CPP_EXPORT ConversionException:public Exception
{
public:
  ConversionException(const std::string& message);
};

class PY2CPP_EXPORT ExecutionException:public Exception
{
public:
  ExecutionException(const std::string& message);
};

class PY2CPP_EXPORT AttributeException:public Exception
{
public:
  AttributeException(const std::string& message);
};

}

#endif //PY2CPP_ERRORS_HXX
