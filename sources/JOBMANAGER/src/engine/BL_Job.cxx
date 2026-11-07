// Copyright (C) 2009-2026  CEA, EDF
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

#include "BL_Job.hxx"

BL::Job::Job()
{
  DEBTRACE("Creating BL::Job");
  _name = "";
  _type = COMMAND;
  _job_file = "";
  _env_file = "";
  _pre_command = "";
  _batch_params.batch_directory = "";
  _batch_params.maximum_duration = "";
  _batch_params.mem_limit = 0;
  _batch_params.mem_req_type = MEM_PER_NODE;
  _batch_params.nb_proc = 0;
  _batch_params.nb_node = 0;
  _batch_params.exclusive = false;
  _files_params.result_directory = "";
  _resource_choosed = "";
  _batch_queue = "";
  _batch_partition = "";
  _state = BL::Job::CREATED;
  _thread_state = BL::Job::NOTHING;
  _salome_launcher_id = -1;
  _dump_yacs_state = 0;
  _yacs_driver_options = "";
  _ll_jobtype = "";

  // Parameters for COORM
  _batch_params.launcher_file = "";
  _batch_params.launcher_args = "";
}

BL::Job::Job(const std::string & name)
{
  DEBTRACE("Creating BL::Job with name : " << name);
  _name = name;
  _type = COMMAND;
  _job_file = "";
  _env_file = "";
  _pre_command = "";
  _batch_params.batch_directory = "";
  _batch_params.maximum_duration = "";
  _batch_params.mem_limit = 0;
  _batch_params.mem_req_type = MEM_PER_NODE;
  _batch_params.nb_proc = 0;
  _batch_params.nb_node = 0;
  _batch_params.exclusive = false;
  _files_params.result_directory = "";
  _resource_choosed = "";
  _batch_queue = "";
  _batch_partition = "";
  _state = BL::Job::CREATED;
  _thread_state = BL::Job::NOTHING;
  _salome_launcher_id = -1;
  _dump_yacs_state = 0;
  _yacs_driver_options = "";
  _ll_jobtype = "";

  // Parameters for COORM
  _batch_params.launcher_file = "";
  _batch_params.launcher_args = "";
}

BL::Job::~Job()
{}

void
BL::Job::setName(const std::string & name)
{
  _name = name;
}

std::string
BL::Job::getName()
{
  return _name;
}

void
BL::Job::setType(BL::Job::JobType type)
{
  _type = type;
}

void
BL::Job::setType(const std::string & type)
{
  if (type == "command")
  {
    setType(BL::Job::COMMAND);
  }
  else if (type == "yacs_file")
  {
    setType(BL::Job::YACS_SCHEMA);
  }
  else if (type == "python_salome")
  {
    setType(BL::Job::PYTHON_SALOME);
  }
  else if (type == "command_salome")
  {
    setType(BL::Job::COMMAND_SALOME);
  }
}

BL::Job::JobType
BL::Job::getType()
{
  return _type;
}

void
BL::Job::setDumpYACSState(const int & dump_yacs_state)
{
  _dump_yacs_state = dump_yacs_state;
}

int
BL::Job::getDumpYACSState()
{
  return _dump_yacs_state;
}

void
BL::Job::setYacsDriverOptions(const std::string& options)
{
  _yacs_driver_options = options;
}

const std::string&
BL::Job::getYacsDriverOptions()const
{
  return _yacs_driver_options;
}

void 
BL::Job::setJobFile(const std::string & job_file)
{
  _job_file = job_file;
}

std::string & 
BL::Job::getJobFile()
{
  return _job_file;
}

void 
BL::Job::setEnvFile(const std::string & env_file)
{
  _env_file = env_file;
}

std::string & 
BL::Job::getEnvFile()
{
  return _env_file;
}

void 
BL::Job::setPreCommand(const std::string & pre_command)
{
  _pre_command = pre_command;
}

std::string & 
BL::Job::getPreCommand()
{
  return _pre_command;
}

void 
BL::Job::setBatchParameters(const BL::Job::BatchParam & param)
{
  _batch_params = param;
}

const BL::Job::BatchParam &
BL::Job::getBatchParameters()
{
  return _batch_params;
}

void 
BL::Job::setFilesParameters(BL::Job::FilesParam & param)
{
  _files_params.result_directory = param.result_directory;
  _files_params.input_files_list = param.input_files_list;
  _files_params.output_files_list = param.output_files_list;
}

BL::Job::FilesParam & 
BL::Job::getFilesParameters()
{
  return _files_params;
}

void
BL::Job::setResource(const std::string & resource)
{
  _resource_choosed = resource;
}

std::string &
BL::Job::getResource()
{
  return _resource_choosed;
}

void
BL::Job::setBatchQueue(const std::string & queue)
{
  _batch_queue = queue;
}

std::string &
BL::Job::getBatchQueue()
{
  return _batch_queue;
}

void
BL::Job::setBatchPartition(const std::string & partition)
{
  _batch_partition = partition;
}

std::string &
BL::Job::getBatchPartition()
{
  return _batch_partition;
}

void
BL::Job::setWCKey(const std::string & wckey)
{
  _wckey = wckey;
}

const std::string &
BL::Job::getWCKey()
{
  return _wckey;
}

void
BL::Job::setExtraParams(const std::string & extra_params)
{
  _extra_params = extra_params;
}

const std::string &
BL::Job::getExtraParams()
{
  return _extra_params;
}

void
BL::Job::setLoadLevelerJobType(const std::string & jobtype)
{
  _ll_jobtype = jobtype;
}

std::string &
BL::Job::getLoadLevelerJobType()
{
  return _ll_jobtype;
}

void 
BL::Job::setState(BL::Job::State state)
{
  _state = state;
}

BL::Job::State 
BL::Job::getState()
{
  return _state;
}

std::string
BL::Job::setStringState(const std::string & state)
{
  std::string result("");

  // Check if state is an error
  if (state != "CREATED"     &&
      state != "IN_PROCESS"  &&
      state != "QUEUED"      &&
      state != "RUNNING"     &&
      state != "PAUSED"      &&
      state != "FINISHED"    &&
      state != "FAILED"      &&
      state != "NOT_CREATED" &&
      state != "ERROR"
     )
  {
    DEBTRACE("Error state in setStringState");
    result = "RefreshError";
  }

  if (result == "")
  {
    if (state == "CREATED")
    {
      if (_state != BL::Job::CREATED)
      {
        setState(BL::Job::CREATED);
        result = state;
      }
    }
    else if (state == "NOT_CREATED")
    {
      if (_state != BL::Job::NOT_CREATED)
      {
        setState(BL::Job::NOT_CREATED);
        result = state;
      }
    }
    else if (state == "QUEUED")
    {
      if (_state != BL::Job::QUEUED)
      {
        setState(BL::Job::QUEUED);
        result = state;
      }
    }
    else if (state == "IN_PROCESS")
    {
      if (_state != BL::Job::IN_PROCESS)
      {
        setState(BL::Job::IN_PROCESS);
        result = state;
      }
    }
    else if (state == "RUNNING")
    {
      if (_state != BL::Job::RUNNING)
      {
        setState(BL::Job::RUNNING);
        result = state;
      }
    }
    else if (state == "PAUSED")
    {
      if (_state != BL::Job::PAUSED)
      {
        setState(BL::Job::PAUSED);
        result = state;
      }
    }
    else if (state == "FINISHED")
    {
      if (_state != BL::Job::FINISHED)
      {
        setState(BL::Job::FINISHED);
        result = state;
      }
    }
    else if (state == "ERROR")
    {
      if (_state != BL::Job::ERROR)
      {
        setState(BL::Job::ERROR);
        result = state;
      }
    }
    else if (state == "FAILED")
    {
      if (_state != BL::Job::FAILED)
      {
        setState(BL::Job::FAILED);
        result = state;
      }
    }
  }
  return result;
}

void 
BL::Job::setThreadState(BL::Job::ThreadState state)
{
  _thread_state = state;
}

BL::Job::ThreadState 
BL::Job::getThreadState()
{
  return _thread_state;
}

void 
BL::Job::setSalomeLauncherId(int id)
{
  _salome_launcher_id = id;
}

int 
BL::Job::getSalomeLauncherId()
{
  return _salome_launcher_id;
}
