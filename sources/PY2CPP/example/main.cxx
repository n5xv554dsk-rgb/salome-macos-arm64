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
#include "TypeConversions.hxx"
#include "Result.hxx"
#include "PyFunction.hxx"

#include <iostream>

int main()
{
  Py_Initialize();
  {
  std::string s;
  double d;
  py2cpp::PyFunction fn;
  fn.load("mymodule", "myfunction");
  if(!fn)
  {
    std::cerr << "Impossible to load myfunction from the module mymodule!";
    std::cerr << std::endl;
    std::cerr << py2cpp::getLastPyError();
  }
  else
  {
    try
    {
      py2cpp::pyResult(s,d) = fn(1, 2);
      std::cout << "String parameter from the python function:" << s << std::endl;
      std::cout << "Double parameter from the python function:" << d << std::endl;
    }
    catch(const py2cpp::Exception& err)
    {
      std::cerr << err.what();
    }
  }
  }
  Py_Finalize();
  return 0;
}
