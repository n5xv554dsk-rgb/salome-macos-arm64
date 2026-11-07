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
 * Utils.cxx
 *
 *  Created on: 30 jan. 2012
 *  Author : Renaud BARATE - EDF R&D
 */

#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <time.h>

#ifdef WIN32
#  include <Windows.h>
#  include <io.h>
#  define popen _popen
#  define pclose _pclose
#else
#  include <sys/stat.h>
#  include <unistd.h>
#endif

#include <libbatch_config.h>
#include "Utils.hxx"
#include "RunTimeException.hxx"

using namespace std;
namespace Batch {

int Utils::getCommandOutput(const string & command, string & output)
{
  // Reinitialize output
  output = "";

  // Call command
  FILE * fp = popen(command.c_str(), "r");
  if (fp == NULL) {
    return -1;
  }

  // Read the output and store it
  char buf[1024];
  while (fgets(buf, sizeof(buf), fp) != NULL) {
    output += buf;
  }

  // close and get status
  int status = pclose(fp);
  return status;
}

bool Utils::isAbsolutePath(const string & path)
{
  if (path.size() == 0)
    return false;
#ifdef WIN32
  // On Windows, absolute paths may begin with something like "C:"
  if (path[1] == ':')
    return true;
#endif
  return path[0] == '/';
}

std::string Utils::dirname(const std::string & path)
{
#ifdef WIN32
  const char separator = '\\';
#else
  const char separator = '/';
#endif
  std::size_t found = path.rfind(separator);
  if(found != std::string::npos)
    return path.substr(0, found+1);
  else
    return std::string(".");
}

bool Utils::isOption(const std::string & val)
{
  return val.size() > 0 && val[0] == '-';
}

bool Utils::usesRsyncRelativePath(const std::string & path)
{
  return path.find("/./") != std::string::npos;
}

string Utils::createAndOpenTemporaryFile(const string & prefix, ofstream & outputStream)
{
  if (outputStream.is_open())
    outputStream.close();

  // Find directory for temporary files
  const char * tmpDirName = getenv("TEMP");
  if (tmpDirName == NULL) tmpDirName = getenv("TMP");
  if (tmpDirName == NULL) tmpDirName = getenv("TEMPDIR");
  if (tmpDirName == NULL) tmpDirName = getenv("TMPDIR");
  if (tmpDirName == NULL) tmpDirName = "/tmp";

#ifdef WIN32

  string fileName = (string)tmpDirName + "\\libbatch-" + prefix + "-XXXXXX";
  char randstr[7];
  srand(time(NULL));

  do {
    sprintf(randstr, "%06d", rand() % 1000000);
    fileName.replace(fileName.size()-6, 6, randstr);
  } while (_access_s(fileName.c_str(), 0) == 0);

  // Open the file as binary to avoid problems with Windows newlines
  outputStream.open(fileName.c_str(), ios_base::binary | ios_base::out);

#else
  string fileName = (string)tmpDirName + "/libbatch-" + prefix + "-XXXXXX";
  char * buf = new char[fileName.size()+1];
  fileName.copy(buf, fileName.size());
  buf[fileName.size()] = '\0';

  int fd = mkstemp(buf);
  if (fd == -1) {
    delete[] buf;
    throw RunTimeException(string("Can't create temporary file ") + fileName);
  }
  fileName = buf;
  delete[] buf;

  outputStream.open(fileName.c_str());
  close(fd);  // Close the file descriptor so that the file is not opened twice

#endif

  if (outputStream.fail())
    throw RunTimeException(string("Can't open temporary file ") + fileName);

  return fileName;
}

int Utils::chmod(const char *path, int mode)
{
#ifdef WIN32
  return _chmod(path, mode);
#else
  return ::chmod(path, mode);
#endif
}

void Utils::sleep(unsigned int seconds)
{
#ifdef WIN32
  Sleep((seconds)*1000);
#else
  ::sleep(seconds);
#endif
}

string Utils::fixPath(const string & path)
{
  string fixedPath = path;
#ifdef WIN32
  for (unsigned int i=0 ; i<fixedPath.size() ; i++) {
    if (fixedPath[i] == '/') fixedPath[i] = '\\';
  }
#endif
  return fixedPath;
}

}
