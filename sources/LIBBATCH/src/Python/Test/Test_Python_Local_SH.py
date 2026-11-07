# Copyright (C) 2007-2021  CEA/DEN, EDF R&D, OPEN CASCADE
#
# Copyright (C) 2003-2007  OPEN CASCADE, EADS/CCR, LIP6, CEA/DEN,
# CEDRAT, EDF R&D, LEG, PRINCIPIA R&D, BUREAU VERITAS
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

import config
import os
import sys
import time

# Import libbatch library
from libbatch import *

def work():
    print("*******************************************************************************************")
    print("This script tests the local batch submission based on SH. No specific configuration is")
    print("needed for this test.")
    print("*******************************************************************************************")

    # eventually remove any previous result
    if (os.path.exists("resultdir/seconddirname/result.txt")):
        os.remove("resultdir/seconddirname/result.txt")

    # Define the job...
    job = Job()
    # ... and its parameters ...
    p = {}
    p[EXECUTABLE] = config.TEST_SOURCE_DIR + "/test_script.py";
    p[ARGUMENTS]  = ["copied_seta.py", "copied_setb.py", "orig_result.txt"];
    p[NAME] = 'Test_Python_Local_SH'
    p[WORKDIR] = config.TEST_LOCAL_SH_WORKDIR
    p[INFILE] = [(config.TEST_SOURCE_DIR + '/seta.py', 'copied_seta.py'),
                 (config.TEST_SOURCE_DIR + '/setb.py', 'copied_setb.py')]
    p[OUTFILE] = [('result.txt', 'orig_result.txt')]
    job.setParametre(p)
    # ... and its environment
    e = {}
    e["MYENVVAR"] = "MYVALUE";
    job.setEnvironnement(e)
    print(job)

    # Get the catalog
    c = BatchManagerCatalog.getInstance()

    # Create a BatchManager of type Local_SH on localhost
    bm = c('LOCAL')('localhost', '', SH)

    # Submit the job to the BatchManager
    jobid = bm.submitJob(job)
    print(jobid)

    # Query the job
    jobid.queryJob()

    # Wait for the end of the job
    state = bm.waitForJobEnd(jobid, config.TEST_LOCAL_SH_TIMEOUT);


    if state == FINISHED:
        print("Job", jobid, "is done")
        bm.importOutputFiles(job, "resultdir/seconddirname")
    elif state == FAILED:
        print("Job", jobid, " finished in error")
        bm.importOutputFiles(job, "resultdir/seconddirname")
        return 1
    else:
        print("Timeout while executing job")
        return 1

    if state != FINISHED and state != FAILED:
        print("Error: Job not finished after timeout")
        return 1;

    # test the result file
    res = {}
    exec(compile(open('resultdir/seconddirname/result.txt').read(), 'resultdir/seconddirname/result.txt', 'exec'), res)
    if (res["c"] == 12 and res["MYENVVAR"] == "MYVALUE"):
      print("OK, Expected result found.")
      return 0
    else:
      print("result found : %s, expected : %s" % (res, 'res["c"] == 12 and res["MYENVVAR"] == "MYVALUE"'))
      return 1

if __name__ == "__main__":
    retcode = work()
    sys.exit(retcode)
