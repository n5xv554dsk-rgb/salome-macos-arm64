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
 * Constants.cxx :
 *
 * Auteur : Renaud BARATE - EDF R&D
 * Date   : January 2010
 *
 */

#include "Constants.hxx"

namespace Batch {

  // Definition of the string constants (keys for the parameter map)
  def_Constant(ARGUMENTS);
  def_Constant(ASSIGNEDHOSTNAMES);
  def_Constant(EXECUTABLE);
  def_Constant(ID);
  def_Constant(INFILE);
  def_Constant(MAXCPUTIME);
  def_Constant(MAXDISKSIZE);
  def_Constant(MAXRAMSIZE);
  def_Constant(MAXWALLTIME);
  def_Constant(NAME);
  def_Constant(NBPROC);
  def_Constant(NBPROCPERNODE);
  def_Constant(OUTFILE);
  def_Constant(QUEUE);
  def_Constant(STATE);
  def_Constant(WORKDIR);
  def_Constant(EXCLUSIVE);
  def_Constant(MEMPERCPU);
  def_Constant(WCKEY);
  def_Constant(EXTRAPARAMS);
  def_Constant(PREPROCESS);
  def_Constant(PARTITION);
  def_Constant(NBNODE);

  // Parameters for COORM
  def_Constant(LAUNCHER_FILE);
  def_Constant(LAUNCHER_ARGS);

  // These constants define the status of a job (parameter STATE);
  def_Constant(CREATED);
  def_Constant(IN_PROCESS);
  def_Constant(QUEUED);
  def_Constant(RUNNING);
  def_Constant(PAUSED);
  def_Constant(FINISHED);
  def_Constant(FAILED);

}
