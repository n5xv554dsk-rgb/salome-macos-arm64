#  -*- coding: utf-8 -*-
# Copyright (C) 2024-2026  CEA, EDF
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#

from salome.kernel import salome_utils
import unittest
import os
from pathlib import Path
import pydefx

class TestYdefxBase(unittest.TestCase):
  def test0(self):
    """
    See EDF31521
    """
    myParams = pydefx.Parameters("localhost", 4)
    myParams.salome_parameters.work_directory = "{}".format(Path( myParams.salome_parameters.work_directory ) / "my_base_case" )
    myParams.salome_parameters.verbose_py_log_level = "ERROR" # ERROR - WARNING - INFO - DEBUG
    myParams.createResultDirectory("/tmp")
    myParams.salome_parameters.in_files = []
    salome_utils.logger.info( f"ressource de calcul: {myParams.salome_parameters.resource_required.name}")
    salome_utils.logger.info( f"nombre d'évaluations parallèles: {myParams.nb_branches}")
    salome_utils.logger.info( f"nombre de coeurs demandés: {myParams.salome_parameters.resource_required.nb_proc}" )
    salome_utils.logger.info( f"nombre de noeuds demandés: {myParams.salome_parameters.resource_required.nb_node}" )
    salome_utils.logger.info( f"répertoire de travail: {myParams.salome_parameters.work_directory}" )
    salome_utils.logger.info( f"répertoire local de gestion: {myParams.salome_parameters.result_directory}" )
    myScript = pydefx.PyScript()
    myScript.loadString("""from salome.kernel import salome_utils
def _exec(x, y):
  from salome.kernel import KernelBasis
  cst = 1.28
  salome_utils.logger.info("Je suis une info")
  KernelBasis.HeatMarcel(cst*1.0,1)
  d = y / x
  t = "{} / {} = {}".format(x, y, d)
  print(f"****** {x}")
  return d, t
""")
    salome_utils.logger.info( f"Inputs : {myScript.getInputNames()}")
    salome_utils.logger.info( f"Outputs : {myScript.getOutputNames()}")
    mySample = myScript.CreateEmptySample()
    mySample.setInputValues({ "x":[ 10, 20, 30, 40],
                            "y":[ 20, 60, 120, 200]})
    myStudy = pydefx.PyStudy()
    myStudy.createNewJob(myScript, mySample, myParams)
    myStudy.launch() 
    salome_utils.logger.info( f"Avancement: {myStudy.getProgress()}")
    salome_utils.logger.info( f"Etat: {myStudy.getJobState()}" )

    # Attendre la fin des calculs
    myStudy.wait()

    salome_utils.logger.info( f"Etat: {myStudy.getJobState()}" )
    salome_utils.logger.info( f"Etat: {myStudy.getJobState()}" )
    res = myStudy.getResult()
    self.assertEqual(res.result.getOutput("d"), [ 2.0, 3.0, 4.0, 5.0 ] )
    self.assertEqual( res.result.getOutput("t"), [ '10.0 / 20.0 = 2.0', '20.0 / 60.0 = 3.0', '30.0 / 120.0 = 4.0', '40.0 / 200.0 = 5.0' ] )

if __name__ == '__main__':
  from salome.kernel import KernelBasis
  KernelBasis.SetVerbosityLevel("WARNING")
  salome_utils.positionVerbosityOfLoggerRegardingState()
  unittest.main()
