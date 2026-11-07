import pydefx.configuration
import pydefx.salome_proxy
import os
import time

def _exec(n):
  # get the job parameters
  salome_parameters = pydefx.configuration.loadJobConfig()

  launcher = pydefx.salome_proxy.getLauncher() # CORBA or not CORBA

  # have a different working directory for each computation
  resource = salome_parameters.resource_required.name
  default_wd = pydefx.configuration.defaultWorkingDir(resource)
  new_wd = os.path.join(default_wd, "myjob_"+str(n))
  salome_parameters.work_directory = new_wd

  # create and launch the job
  job_id = launcher.createJob(salome_parameters)
  launcher.launchJob(job_id)

  # wait for the end of the job
  jobState = launcher.getJobState(job_id)
  while jobState != "FINISHED" and jobState != "FAILED" :
    time.sleep(5)
    jobState = launcher.getJobState(job_id)
  return jobState
