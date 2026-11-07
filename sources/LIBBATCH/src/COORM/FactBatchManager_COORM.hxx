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

#ifndef _FACTBATCHMANAGER_COORM_H_
#define _FACTBATCHMANAGER_COORM_H_

#include <string>
#include <map>

#include "Defines.hxx"
#include "BatchManager.hxx"
#include "FactBatchManager.hxx"

namespace Batch
{
	class BatchManager_COORM;

	class BATCH_EXPORT FactBatchManager_COORM : public FactBatchManager
	{
		public:
			// Constructeur
			FactBatchManager_COORM();

			// Destructeur
			virtual ~FactBatchManager_COORM();

			// Functor
			virtual BatchManager * operator() (const char * hostname,
					const char * username,
					CommunicationProtocolType protocolType,
					const char * mpiImpl) const;

		protected:

		private:

	};
}

#endif
