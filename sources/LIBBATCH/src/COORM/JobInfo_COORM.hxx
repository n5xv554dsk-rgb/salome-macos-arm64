// Copyright (C) 2012-2021  INRIA
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

#ifndef _JOBINFO_COORM_H_
#define _JOBINFO_COORM_H_

#include <string.h>
#include "RunTimeException.hxx"
#include "JobInfo.hxx"

namespace Batch
{
	class JobInfo_COORM : public JobInfo
	{
		public:
			// Constructeur
			JobInfo_COORM() {};

			// Constructeur
			JobInfo_COORM(const std::string & id, const std::string & queryOutput);

			// Destructeur
			virtual ~JobInfo_COORM();

			// Constructeur par recopie
			JobInfo_COORM(const JobInfo_COORM & jinfo) : JobInfo(jinfo) {};

			// Methodes pour l'interfacage avec Python (SWIG)
			// TODO : supprimer ces methodes et transferer leur definitions dans SWIG
			std::string  __str__() const; // SWIG : affichage en Python
			std::string  __repr__() const { return __str__(); }; // SWIG : affichage en Python

		private:
			// Convertit une date HH:MM:SS en secondes
			long HMStoLong(const std::string &);
	};
}

#endif
