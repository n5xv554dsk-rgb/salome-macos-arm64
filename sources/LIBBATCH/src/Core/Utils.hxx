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
 * Utils.hxx
 *
 *  Created on: 30 jan. 2012
 *  Author : Renaud BARATE - EDF R&D
 */

#ifndef BATCH_UTILS_HXX_
#define BATCH_UTILS_HXX_

#include <string>

namespace Batch {

class Utils {
public:

  /**
   * Call a command with the system shell and stores its output in parameter "output".
   * Returns the return code of the command.
   */
  static int getCommandOutput(const std::string & command, std::string & output);

  /**
   * Test if the path in parameter is an absolute path (does not test the existence of
   * a file or directory at this path).
   */
  static bool isAbsolutePath(const std::string & path);

  /**
   * Returns the directory name of a path.
   * "/a/b/file.txt" -> "/a/b"
   * "a/file.txt" -> "a"
   * "file.txt" -> "."
   */
  static std::string dirname(const std::string & path);

  /**
   * Test if the string in parameter begins with '-' and it should be processed
   * as an option, not as a path.
   */
  static bool isOption(const std::string & val);

  /**
   * Test if the path in parameter contains a "/./" sequence.
   */
  static bool usesRsyncRelativePath(const std::string & path);

  /**
   * Create a temporary file and open an output stream to write into this file.
   * The file is created with the pattern "<tmpdir>/libbatch-<prefix>-XXXXXX" where <tmpdir> is the
   * directory for temporary files and the X's are replaced by random characters. The caller is
   * responsible for closing and deleting the file when it is no more used.
   * <tmpdir> is found by looking for environment variables TEMP, TMP, TEMPDIR, TMPDIR, and defaults
   * to "/tmp" if none of them is defined.
   * \param prefix the prefix to use for the temporary file.
   * \param outputStream an output stream that will be opened for writing in the temporary file. If
   * the stream is already open, it will be closed first.
   * \return the name of the created file.
   */
  static std::string createAndOpenTemporaryFile(const std::string & prefix,
                                                std::ofstream & outputStream);

  /**
   * Change permissions of a file
   */
  static int chmod(const char *path, int mode);

  /**
   * Sleep for the number of specified seconds
   */
  static void sleep(unsigned int seconds);

  /**
   * Simple method to fix path strings depending on the platform. On Windows, it will replace
   * forward slashes '/' by backslashes '\'. On Unix, the path is just copied without change.
   */
  static std::string fixPath(const std::string & path);

private:

  // No instanciation possible as this class provides only static methods
  Utils() { }

};

}

#endif /* BATCH_UTILS_HXX_ */
