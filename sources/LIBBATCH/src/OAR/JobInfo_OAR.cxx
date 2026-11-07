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

#include <cstdio>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

#include "Constants.hxx"
#include "Parametre.hxx"
#include "Environnement.hxx"
#include "RunTimeException.hxx"
#include "APIInternalFailureException.hxx"
#include "JobInfo_OAR.hxx"

using namespace std;

namespace Batch {

	// Constructeurs
	JobInfo_OAR::JobInfo_OAR(const std::string & id, const std::string & queryOutput) : JobInfo()
	{
	  _param[ID] = id;

		// read query output
		istringstream logfile(queryOutput);

		string sline, state, assigned_hostnames;

		if (logfile)
		{
			while (getline(logfile, sline) && sline != "")
			{
				vector<string> tokens;

				JobInfo::Tokenize(sline, tokens, "= ");

				if (tokens[0] == "state")
				{
					state = tokens[1];
				}

				if (tokens[0] == "assigned_hostnames")
				{
					assigned_hostnames = tokens[1];
				}
			}

			_param[ASSIGNEDHOSTNAMES] = assigned_hostnames;

			if (state == "Terminated")
			{
				// Completed
				_param[STATE] = FINISHED;
			} 
			else if (state == "Running") 
			{ 
				// Running
				_param[STATE] = RUNNING;
			} 
			else if (state == "Waiting") 
			{ 
				// Waiting
				_param[STATE] = QUEUED;
			} 
			else if (state == "Error" || state == "Finishing") 
			{ 
				// Error
				_param[STATE] = FAILED;
			} 
			else if (state == "Launching" || state == "toLaunch") 
			{ 
				// Launching
				_param[STATE] = IN_PROCESS;
			} 
			else 
			{
				cerr << "Unknown job state code: " << state << endl;
			}
		} 
		else 
		{
			throw RunTimeException("Error of connection on remote host");
		}
	}

	// Destructeur
	JobInfo_OAR::~JobInfo_OAR()
	{
		// Nothing to do
	}

	// Convertit une date HH:MM:SS en secondes
	long JobInfo_OAR::HMStoLong(const string & s)
	{
		long hour, min, sec;

		sscanf( s.c_str(), "%ld:%ld:%ld", &hour, &min, &sec);
		return ( ( ( hour * 60L ) + min ) * 60L ) + sec;
	}

	// Methode pour l'interfacage avec Python (SWIG) : affichage en Python
	string JobInfo_OAR::__str__() const
	{
		ostringstream sst;
		sst << "<JobInfo_eOAR (" << this << ") :" << endl;
		sst << " ID = " <<_param[ID] << endl;
		sst << " STATE = " <<_param[STATE] << endl;

		return sst.str();
	}
}
