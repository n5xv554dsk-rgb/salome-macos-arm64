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
 * Test_BatchManager.cxx :
 *
 * Author : Renaud BARATE - EDF R&D
 * Date   : Jan 2013
 *
 */

#include <iostream>
#include <fstream>
#include <cstring>

#include <Constants.hxx>
#include <Job.hxx>
#include <BatchManagerCatalog.hxx>
#include <FactBatchManager.hxx>
#include <BatchManager.hxx>

#include "SimpleParser.hxx"

#include <Test_config.h>

using namespace std;
using namespace Batch;

void print_usage()
{
  cout << "usage: Test_BatchManager BATCH_MANAGER PROTOCOL" << endl;
  cout << "    BATCH_MANAGER \"CCC\", \"LL\", \"LOCAL\", \"LSF\", \"PBS\", " <<
          "\"SGE\", \"SLURM\" or \"VISHNU\"" << endl;
  cout << "    PROTOCOL      \"SH\", \"SSH\" or \"RSH\"" << endl;
}

int main(int argc, char** argv)
{
  // Parse argument
  if (argc != 3) {
    print_usage();
    return 1;
  }
  const char * bmType = argv[1];
  const char * protocolStr = argv[2];
  CommunicationProtocolType protocol;
  if (strcmp(protocolStr, "SSH") == 0)
    protocol = SSH;
  else if (strcmp(protocolStr, "RSH") == 0)
    protocol = RSH;
  else if (strcmp(protocolStr, "SH") == 0)
    protocol = SH;
  else {
    print_usage();
    return 1;
  }

  cout << "*******************************************************************************************" << endl;
  cout << "This program tests the batch submission of a job using the batch manager \"" << bmType << "\"" << endl;
  cout << "and the communication protocol \"" << protocolStr << "\"." << endl;
  if (protocol == RSH || protocol == SSH) {
    cout << "Passwordless authentication must be used for this test to pass." << endl;
    if (protocol == SSH) {
      cout << "This can be configured with ssh-agent for instance." << endl;
    } else if (protocol == RSH) {
      cout << "This can be configured with the .rhosts file." << endl;
    }
  }
  cout << "*******************************************************************************************" << endl;

  // eventually remove any previous result
  remove("resultdir/seconddirname/result.txt");

  try {
    // Get the catalog and the BatchManager factory
    BatchManagerCatalog& cata = BatchManagerCatalog::getInstance();
    FactBatchManager * fbm = cata(bmType);

    // Parse the test configuration file
    SimpleParser parser;
    parser.parseTestConfigFile();
    const string & workdir = parser.getTestValue(bmType, protocolStr, "WORKDIR");
    const string & host = parser.getTestValue(bmType, protocolStr, "HOST");
    const string & user = parser.getTestValue(bmType, protocolStr, "USER");
    int timeout = parser.getTestValueAsInt(bmType, protocolStr, "TIMEOUT");

#ifdef WIN32
    const char separator = '\\';
#else
    const char separator = '/';
#endif

    // Define the job...
    Job job;
    // ... and its parameters ...
    Parametre p;
    p[EXECUTABLE]    = string(CMAKE_CURRENT_SOURCE_DIR) + separator + "test_script.py";
    p[ARGUMENTS]     = "copied_seta.py";
    p[ARGUMENTS]    += "copied_setb.py";
    p[ARGUMENTS]    += "orig_result.txt";
    p[NAME]          = string("Test ") + bmType + " " + argv[2];
    p[WORKDIR]       = workdir;
    p[INFILE]        = Couple(string(CMAKE_CURRENT_SOURCE_DIR) + "/seta.py", "copied_seta.py");
    p[INFILE]       += Couple(string(CMAKE_CURRENT_SOURCE_DIR) + "/setb.py", "copied_setb.py");
    p[OUTFILE]       = Couple("result.txt", "orig_result.txt");
    p[NBPROC]        = 1;
    p[MAXWALLTIME]   = 1;
    p[MAXRAMSIZE]    = 50;
    job.setParametre(p);
    // ... and its environment
    Environnement e;
    e["MYENVVAR"] = "MYVALUE";
    job.setEnvironnement(e);
    cout << job << endl;

    // Create the BatchManager
    BatchManager * bm = (*fbm)(host.c_str(), user.c_str(), protocol);

    // Submit the job to the BatchManager
    JobId jobid = bm->submitJob(job);
    cout << jobid.__repr__() << endl;

    // Wait for the end of the job
    string state = bm->waitForJobEnd(jobid, timeout);

    if (state == FINISHED) {
      cout << "Job " << jobid.__repr__() << " is done" << endl;
      bm->importOutputFiles(job, "resultdir/seconddirname");
    } else if (state == FAILED) {
      cerr << "Job " << jobid.__repr__() << " finished in error" << endl;
      bm->importOutputFiles(job, "resultdir/seconddirname");
      return 1;
    } else {
      cerr << "Timeout while executing job" << endl;
      return 1;
    }

  } catch (const GenericException & e) {
    cerr << "Error: " << e << endl;
    return 1;
  } catch (const ParserException & e) {
    cerr << "Parser error: " << e.what() << endl;
    return 1;
  }

  // test the result file
  try {
    SimpleParser resultParser;
    resultParser.parse("resultdir/seconddirname/result.txt");
    cout << "Result:" << endl << resultParser;
    const string & envvar = resultParser.getValue("MYENVVAR");
    int result = resultParser.getValueAsInt("c");
    if (envvar == "MYVALUE" && result == 12) {
      cout << "OK, Expected result found." << endl;
      return 0;
    } else {
      cerr << "Error, result is not the expected one (MYENVVAR = MYVALUE, c = 12)." << endl;
      return 1;
    }
  } catch (const ParserException & e) {
    cerr << "Parser error on result file: " << e.what() << endl;
    return 1;
  }
}
