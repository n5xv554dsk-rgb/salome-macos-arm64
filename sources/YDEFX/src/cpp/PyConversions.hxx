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
#ifndef YDEFX_PYCONVERSIONS_HXX
#define YDEFX_PYCONVERSIONS_HXX
#include <py2cpp/PyPtr.hxx>

namespace ydefx
{
class JobParametersProxy;
class PyStudyFunction;
}
namespace py2cpp
{
PyObject * toPy(const ydefx::JobParametersProxy& jp);
PyObject * toPy(const ydefx::PyStudyFunction& jp);
}

#include <py2cpp/py2cpp.hxx>

#endif //YDEFX_PYCONVERSIONS_HXX
