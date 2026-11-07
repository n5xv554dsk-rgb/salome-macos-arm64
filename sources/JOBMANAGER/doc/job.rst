Main JOBMANAGER concept: Job
============================

This chapter explains the main JOBMANAGER concept: a job. 

What is a job?
++++++++++++++

A job is a work that a user wants to perform on a computation resource (single computer or a cluster).
The JOBMANAGER provides different types of job depending of what a user wants to do.

There are three types of described in the table below.

======================== ==============================================================================
**Type of job**          **Description**
======================== ==============================================================================
**Command script**       It's a shell script containing the user's commands. This kind of job is not 
                         related to SALOME. It could be used to launch any codes.
**SALOME Python script** It's a Python script that will be launched into a SALOME session dedicated to 
                         this script.
**YACS schema**          It's a YACS schema that will be launched into a SALOME session dedicated to this
                         schema.
======================== ==============================================================================

Job content description
+++++++++++++++++++++++

All types of job share some attributes. There could be specific attributes for some types of jobs. These exceptions
will be indicated in the future in this documentation. A job has two kinds of attributes:
attributes that describes the job himself, and attributes that describes the computation requirements.

The first table below describes the attributes of a job.

======================== ================ ==============================================================================
**Attribute**            **Mandatory**    **Description**
======================== ================ ==============================================================================
**Name**                 Yes              This is the name of the job. It's unique into a SALOME session.
**Type**                 Yes              This is the type of the job. Currently, there are three types: *command*,
                                          *python_salome* and *yacs_file*.
**Job file**             Yes              This is the name, with the location, of the file containing the job's data.
                                          Depending of the type it could a *shell* script, a *Python script* or
                                          a *YACS schema*, e.g. **/home/user/work.sh**.
**Env file**             No               An environment file could be attached to the job. It will be executed before
                                          the job.
**Input files**          No               A list of files or directories in the user computer that have to copied into 
                                          the job's *work directory*.
**Output files**         No               A list of files or directories that have to be copied from the job's resource
                                          to the user computer into the *result directory*.
**Work directory**       Yes              It's the directory on the job's resource where the job will be executed.
**Result directory**     Yes              It's the directory in the user computer where the job's results have to be 
                                          copied at the end of the job.
**WC Key**               No               The Workload Characterization Key is used on some clusters to associate each
                                          job with a project or organization.
======================== ================ ==============================================================================

The second table below describes the attributes of computation requirements.

======================== ==============================================================================
**Attribute**            **Description**
======================== ==============================================================================
**Maximum duration**     It's the maximum expected duration of the job. When a batch manager is used, this
                         time is interpreted as a **walltime** and not as a **cputime**. If maximum
                         duration is not set or set to 0, the time will be set to the default value of the
                         batch queue selected.
**Number of cpu**        It's the number of cpus/cores requested.
**Memory**               It's the amount of required memory. It is generally specified **per node**.
                         With some batch mangers, it is possible to specify the required memory
                         **per core** (only available with SLURM for now).
**Queue**                It's optional. It permits to choose a specific batch queue on the targeted cluster.
                         If it is not defined, most of the batch systems will affect your job to the queue
                         that fits with the other attributes requirements.
**Exclusive**            It indicates if the job can share nodes with other jobs or not.
======================== ==============================================================================

In addition to those attributes, the user can also specify some extra parameters with a few lines that
will be added "as is" to the job submission file.

Job's states
++++++++++++

A job could have many states in the JOBMANAGER. The table below describes the normal states.

======================== ==============================================================================
**State**                **Description**
======================== ==============================================================================
**Created**              The job is correctly created and could be launched.
**In_Process**           It's a transient state between *Created* and *Queued*.
**Queued**               The job is queued into the resource's batch manager.
**Paused**               The job is paused. Currently the JOBMANAGER GUI does not allow to paused a 
                         job.
**Running**              The job is running on the resource.
**Finished**             The job has run and it's finished.
======================== ==============================================================================

The table below describes the error states.

======================== ==============================================================================
**State**                **Description**
======================== ==============================================================================
**Not Created**          This state means that the job cannot be created with it's current description.
                         It's often a problem with the selected resource.
**Failed**               This state means that the execution of the job in the resource failed.
**Error**                This state is used when a job is loaded and that it cannot be followed. It
                         mainly happens when a job was launched into a *ssh* resource. If the list is
                         saved, an error will happen when the list is loaded (*ssh* resource cannot
                         be followed).
======================== ==============================================================================
