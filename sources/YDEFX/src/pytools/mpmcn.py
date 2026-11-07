#!/usr/bin/env python3
#  -*- coding: utf-8 -*-
# Copyright (C) 2022-2026 EDF
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

import pydefx

class Pool:
    def __init__(self, params):
        """
        :param params: parameter of the job
        :type params: pydefx.Parameters
        """
        self.myStudy = None
        self.myScript = pydefx.PyScript()
        self.mySample = None
        self.myParams = params
        self.removeTmpDir = False

    def getResultDirectory(self):
        return self.myParams.salome_parameters.result_directory
    
    def map(self, func, iterable):
        if len(iterable) == 0:
            return []
        #
        import inspect
        if not inspect.isfunction(func):
            raise RuntimeError("Input is expected to be a function")
        import importlib
        fModule = importlib.import_module(func.__module__)
        if fModule == "__main__":
            raise RuntimeError("Input function is expected to be part of a module")
        st = None
        with open(fModule.__file__,"r") as ff:
            st = ff.read()
        # retrieve the varname holding the function in its module
        fStr = func.__code__.co_name
        if fStr is None:
            raise RuntimeError("Impossible to locate function in the module containing it !")
        # retrieve args of the func passed in input
        fArgs = inspect.getfullargspec(func).args
        # agregate the content of the Python module containing the function with expected _exec function for pydfx
        pyScript = """{}
def _exec({}):
    yxyx = {}({})
    return yxyx
""".format(st,", ".join(fArgs),fStr,", ".join(fArgs))
        #
        self.myScript.loadString(pyScript)
        self.mySample = self.myScript.CreateEmptySample()
        # management of the case of single input
        if not hasattr(iterable[0],"__iter__"):
            iterable = [[elt] for elt in iterable]
        #
        self.mySample.setInputValues( {k:v for k,*v in zip(fArgs,*iterable)} )
        #
        self.myStudy.createNewJob(self.myScript, self.mySample, self.myParams)
        #
        self.myStudy.launch()
        self.myStudy.wait()
        # ask for result : this call implicitely copy back results to the client
        self.myStudy.getResult()
        #
        if self.myStudy.getJobState() == "FINISHED" and self.myStudy.global_result.exit_code == "0":
            messageFromSlaves = self.myStudy.sample.getMessages()
            if all( [elt == "" for elt in messageFromSlaves] ):
                ret = [elt for elt in zip(*[self.myStudy.sample.getOutput(n) for n in self.myStudy.sample.getOutputNames()])]
                if len(self.myStudy.sample.getOutputNames()) == 1:
                    ret = [elt[0] for elt in ret]
                self.removeTmpDir = True
                return ret
            else:
                excMsg = "\n".join(["Error for sample # {} : \'{}\' ".format(i,elt) for i,elt in enumerate(messageFromSlaves) if elt != ""])
                excMsg += "\nDirectory containing information for debug : {}".format(self.getResultDirectory())
                exc = RuntimeError( excMsg )
                exc.tmp_dir = self.getResultDirectory()
                raise exc
        else:
            raise RuntimeError( "Error during job submission or during the driver execution (that should never happend). Internal error : {}".format(self.myStudy.getResult().getErrors()) )

    def __enter__(self):
        self.myStudy = pydefx.PyStudy()
        return self
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        import os
        from glob import glob
        import shutil
        if self.removeTmpDir:
            for fn in glob(os.path.join(self.getResultDirectory(),"*")):
                if os.path.isdir( fn ):
                    shutil.rmtree( fn)
                else:
                    os.unlink( fn )
        pass
    pass

def init(resourceName, resultDirectory = "/tmp"):
    """
    Instanciate a pydefx.Parameters intance that can be overriden right after.
    Here some example of typical override of the returned object of this method :

    define a local directory for working files :
    myParams.salome_parameters.result_directory with existing directory. If not myParams.createResultDirectory("/tmp")

    Define additionnal files necessary for computation.
    They will be copied to the remote working directory.
    This parameter is empty by default :
    myParams.salome_parameters.in_files = []

    Override computation ressource :
    myParams.salome_parameters.resource_required.name)

    Override default # of parallel evaluation :
    myParams.nb_branches

    Override number of cores requested by the job when job resource is a cluster (for job scheduler query) :
    myParams.salome_parameters.resource_required.nb_proc

    Override number of computationnal nodes on cluster to be allocated when job resource is a cluster (for job scheduler query) :
    myParams.salome_parameters.resource_required.nb_node

    Override working directory :
    myParams.salome_parameters.work_directory

    :param resourceName: Name of the resource matching one of the ${KERNEL_ROOT_DIR}/share/salome/resources/kernel/CatalogResources.xml
    :param resultDirectory: Directory used to transfer results
    :return: a pydefx.Parameters instance
    """
    myParams = pydefx.Parameters()
    from pydefx import configuration
    if resourceName not in configuration.availableResources():
        raise RuntimeError("Resource \"{}\" is not existing or not declared as able to launch job. Available resources are : {}".format(resourceName,str(configuration.availableResources())))
    myParams.configureResource(resourceName)
    myParams.createResultDirectory(resultDirectory)
    if resourceName == "localhost":
        myParams.nb_branches = configuration.allCoresAvailable()
    return myParams
