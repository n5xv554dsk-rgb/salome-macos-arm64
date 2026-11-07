Advanced part
=============

This chapter is a melting pot of information about what the JOBMANAGER do.

Logs files
++++++++++

Whatever the type of job, the JOBMANAGER provides many files for logging
what happens during the job. These files are located in the work directory
of the job in a directory named **logs**.

For **command** type of job, one log file is created. This file contains the normal
and error output of the job. The file name contains the type of job and the date, e.g. 
**command_Thu_Sep_30_15_04_51_2010.log**.

For **SALOME** type of job, two log files are created. The common file contains the 
normal and error output of the SALOME services. The file name is like this:
**salome_Wed_Feb_10_13_54_00_2010.log**. The other file depends of the type of SALOME jobs:

- For **Python** type of job, the file contains all the output of the scripts. The file name is
  like this: **python_Wed_Feb_10_13_54_00_2010.log**.
- For **YACS** type of job, the file contains all the output of the schema. The file name is
  like this: **yacs_Wed_Feb_10_13_54_00_2010.log**.

For jobs that are launched in a batch resource like PBS or LSF, two more files are provided
that contains the normal and error output messages of the PBS or LSF job. These files are like this:
**error.log.runCommand_test_command_Wed_Sep__8_17_02_44_2010** and
**output.log.runCommand_test_command_Wed_Sep__8_17_02_44_2010**

How the JOBMANAGER launch the job
+++++++++++++++++++++++++++++++++

For each type of job, the JOBMANAGER creates a shell that permits to launch in the resource
the job file. It's in this file that the environment file is used. For a command job,
the file name is like this: **runCommand_test_command_Wed_Sep__8_16_59_08_2010.sh**.

If a job has to be launched in a resource with a batch manager like PBS or LSF an another
file is created that contains batch directives. For a command job, the file name is like
this: **runCommand_test_command_Wed_Sep__8_16_59_08_2010_Batch.sh**.


Current limitations
+++++++++++++++++++

Currently, for SALOME type of jobs, the scope of the environment file is
restricted to the main SALOME session. Distributed containers launched in remote
computers are not in the scope of the environment file. If you want to give an environment file to all
your containers, use a SALOME application and copy this environment file into the **env.d**
directory. 

Currently, logs files do not contain remote containers outputs.
