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

#include "BL_SALOMEServices.hxx"
#include <sstream>

static std::ostream & 
operator<<(std::ostream & os, const CORBA::Exception & e)
{
  CORBA::Any tmp;
  tmp <<=e ;
  CORBA::TypeCode_var tc = tmp.type();
  const char * p = tc->name ();
  if (*p != '\0')
    os << p;
  else
    os << tc->id();
  return os;
}

BL::SALOMEServices::SALOMEServices()
{
  int nbargs = 0; char **args = 0;
  _orb = CORBA::ORB_init (nbargs, args);
  _salome_naming_service = NULL;
  _lcc = NULL;
  _state = false;
  _manager = NULL;
}

BL::SALOMEServices::~SALOMEServices() {}

void
BL::SALOMEServices::end()
{
  if (!CORBA::is_nil(_salome_launcher))
    _salome_launcher->removeObserver(_this());
  if (_salome_naming_service)
    delete _salome_naming_service;
  if (_lcc)
    delete _lcc;
}

bool
BL::SALOMEServices::initNS()
{
  bool return_value = true;
  _salome_naming_service = new BL_SALOME_NamingService_Wrapper(_orb);
  _lcc = new SALOME_LifeCycleCORBA(_salome_naming_service);
  CORBA::Object_var obj = _salome_naming_service->Resolve("/SalomeLauncher");
  _salome_launcher = Engines::SalomeLauncher::_narrow(obj);

  if (CORBA::is_nil(_salome_launcher))
  {
    DEBMSG("SALOME Launcher is not reachable!")
    return_value = false;
  }
  _salome_launcher->addObserver(_this());
  _remove_ref(); // POA will automatically destroy the object

  obj = _salome_naming_service->Resolve("/ResourcesManager");
  _resources_manager = Engines::ResourcesManager::_narrow(obj);
  if (CORBA::is_nil(_resources_manager))
  {
    DEBMSG("SALOME Resource Manager is not reachable !");
    return_value = false;
  }

  _state = return_value;
  return return_value;
}

std::list<std::string> 
BL::SALOMEServices::getResourceList(bool batch_only)
{
  std::list<std::string> resource_list;
  
  if (_state)
  {
    Engines::ResourceParameters params;
    _lcc->preSet(params);
    params.can_launch_batch_jobs = batch_only;
    Engines::ResourceList * resourceList = NULL;
    try
    {
      resourceList = _resources_manager->GetFittingResources(params);
    }
    catch (const SALOME_CMOD::SALOME_Exception & ex)
    {
      DEBMSG("SALOME Exception in addResource ! " << ex.details.text.in());
    }
    catch (const CORBA::SystemException& ex)
    {
      DEBMSG("Receive SALOME System Exception: " << ex);
      DEBMSG("Check SALOME servers...");
    }
    if (resourceList)
    {
      for (int i = 0; i < resourceList->length(); i++)
      {
        const char* aResource = (*resourceList)[i];
        resource_list.push_back(aResource);
      }
      delete resourceList;
    }
  }
  return resource_list;
}

BL::ResourceDescr
BL::SALOMEServices::getResourceDescr(const std::string& name)
{
  Engines::ResourceDefinition * resource_definition = NULL;
  BL::ResourceDescr resource_descr;

  try 
  {
    resource_definition = _resources_manager-> GetResourceDefinition(name.c_str());
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in addResource ! " << ex.details.text.in());
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
  }

  if(resource_definition)
  {
    resource_descr.name = resource_definition->name.in();
    resource_descr.hostname = resource_definition->hostname.in();
    resource_descr.protocol = resource_definition->protocol.in();
    resource_descr.username = resource_definition->username.in();
    resource_descr.applipath = resource_definition->applipath.in();
    for (int i = 0; i < resource_definition->componentList.length(); i++)
    {
      resource_descr.componentList.push_back(resource_definition->componentList[i].in());
    }

    resource_descr.OS = resource_definition->OS.in();
    resource_descr.mem_mb = resource_definition->mem_mb;
    resource_descr.cpu_clock = resource_definition->cpu_clock;
    resource_descr.nb_node = resource_definition->nb_node;
    resource_descr.nb_proc_per_node = resource_definition->nb_proc_per_node;
    resource_descr.batch = resource_definition->batch.in();
    resource_descr.mpiImpl = resource_definition->mpiImpl.in();
    resource_descr.iprotocol = resource_definition->iprotocol.in();
    resource_descr.can_launch_batch_jobs = resource_definition->can_launch_batch_jobs;
    resource_descr.can_run_containers = resource_definition->can_run_containers;
    resource_descr.working_directory = resource_definition->working_directory.in();

    delete resource_definition;
  }
  return resource_descr;
}

void
BL::SALOMEServices::addResource(BL::ResourceDescr & new_resource)
{
  Engines::ResourceDefinition_var resource_definition = new Engines::ResourceDefinition;

  resource_definition->name = CORBA::string_dup(new_resource.name.c_str());
  resource_definition->hostname = CORBA::string_dup(new_resource.hostname.c_str());
  if (new_resource.batch == "none")
    resource_definition->type = CORBA::string_dup("single_machine");
  else
    resource_definition->type = CORBA::string_dup("cluster");
  resource_definition->protocol = CORBA::string_dup(new_resource.protocol.c_str());
  resource_definition->username = CORBA::string_dup(new_resource.username.c_str());
  resource_definition->applipath = CORBA::string_dup(new_resource.applipath.c_str());

  int i = 0;
  std::list<std::string>::iterator it = new_resource.componentList.begin();
  resource_definition->componentList.length(new_resource.componentList.size());
  for(; it != new_resource.componentList.end(); it++)
  {
    resource_definition->componentList[i] = CORBA::string_dup((*it).c_str());
    i++;
  }

  resource_definition->OS = CORBA::string_dup(new_resource.OS.c_str());
  resource_definition->mem_mb = new_resource.mem_mb;
  resource_definition->cpu_clock = new_resource.cpu_clock;
  resource_definition->nb_node = new_resource.nb_node;
  resource_definition->nb_proc_per_node = new_resource.nb_proc_per_node;  
  resource_definition->batch = CORBA::string_dup(new_resource.batch.c_str());
  resource_definition->mpiImpl = CORBA::string_dup(new_resource.mpiImpl.c_str());
  resource_definition->iprotocol = CORBA::string_dup(new_resource.iprotocol.c_str());
  resource_definition->can_launch_batch_jobs = new_resource.can_launch_batch_jobs;
  resource_definition->can_run_containers = new_resource.can_run_containers;
  resource_definition->working_directory = CORBA::string_dup(new_resource.working_directory.c_str());

  try
  {
    _resources_manager->AddResource(resource_definition, true, "");
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in addResource ! " << ex.details.text.in());
    throw(BL::Exception(ex.details.text.in()));
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    throw(BL::Exception("SALOME System Exception"));
  }
}

void 
BL::SALOMEServices::removeResource(const std::string & name)
{
  try
  {
    _resources_manager->RemoveResource(name.c_str(), true, "");
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in removeResource ! " << ex.details.text.in());
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
  }
}

std::string
BL::SALOMEServices::create_job(BL::Job * job)
{
  DEBMSG("Begin of create_job");
  std::string ret = "";
  Engines::JobParameters_var job_parameters = new Engines::JobParameters;

  // Job type
  if (job->getType() == BL::Job::COMMAND)
  {
    job_parameters->job_type = CORBA::string_dup("command");
  }
  else if (job->getType() == BL::Job::YACS_SCHEMA)
  {
    job_parameters->job_type = CORBA::string_dup("yacs_file");
  }
  else if (job->getType() == BL::Job::PYTHON_SALOME)
  {
    job_parameters->job_type = CORBA::string_dup("python_salome");
  }
  else if (job->getType() == BL::Job::COMMAND_SALOME)
  {
    job_parameters->job_type = CORBA::string_dup("command_salome");
  }

  // Specific parameters
  if (job->getType() == BL::Job::YACS_SCHEMA)
  {
    if (job->getDumpYACSState() > 0)
    {
      job_parameters->specific_parameters.length(job_parameters->specific_parameters.length() + 1);
      std::ostringstream oss;
      oss << job->getDumpYACSState();
      Engines::Parameter_var new_parameter = new Engines::Parameter;
      new_parameter->name = CORBA::string_dup("EnableDumpYACS");
      new_parameter->value = CORBA::string_dup(oss.str().c_str());
      job_parameters->specific_parameters[job_parameters->specific_parameters.length() - 1] = new_parameter;
    }
    if (!job->getYacsDriverOptions().empty())
    {
      job_parameters->specific_parameters.length(job_parameters->specific_parameters.length() + 1);
      Engines::Parameter_var new_parameter = new Engines::Parameter;
      new_parameter->name = CORBA::string_dup("YACSDriverOptions");
      new_parameter->value = CORBA::string_dup(job->getYacsDriverOptions().c_str());
      job_parameters->specific_parameters[job_parameters->specific_parameters.length() - 1] = new_parameter;
    }
  }
  if (job->getLoadLevelerJobType() != "")
  {
    job_parameters->specific_parameters.length(job_parameters->specific_parameters.length() + 1);
    Engines::Parameter_var new_parameter = new Engines::Parameter;
    new_parameter->name = CORBA::string_dup("LoalLevelerJobType");
    new_parameter->value = CORBA::string_dup(job->getLoadLevelerJobType().c_str());
    job_parameters->specific_parameters[job_parameters->specific_parameters.length() - 1] = new_parameter;
  }

  // Files
  job_parameters->job_name = CORBA::string_dup(job->getName().c_str());
  job_parameters->job_file = CORBA::string_dup(job->getJobFile().c_str());
  job_parameters->env_file = CORBA::string_dup(job->getEnvFile().c_str());
  job_parameters->pre_command = CORBA::string_dup(job->getPreCommand().c_str());
  BL::Job::FilesParam files = job->getFilesParameters();
  std::list<std::string>::iterator it;
  int i = 0;
  int j = 0;

  job_parameters->in_files.length(files.input_files_list.size());
  for (it = files.input_files_list.begin() ; it != files.input_files_list.end(); it++)
  {
    job_parameters->in_files[i] = CORBA::string_dup((*it).c_str());
    i++;
  }

  job_parameters->out_files.length(files.output_files_list.size());
  for (it = files.output_files_list.begin() ; it != files.output_files_list.end(); it++)
  {
    job_parameters->out_files[j] = CORBA::string_dup((*it).c_str());
    j++;
  }
  job_parameters->local_directory = CORBA::string_dup("");
  job_parameters->result_directory = CORBA::string_dup(files.result_directory.c_str());

  BL::Job::BatchParam cpp_batch_params =  job->getBatchParameters();
  job_parameters->work_directory = CORBA::string_dup(cpp_batch_params.batch_directory.c_str());

  // Resource
  job_parameters->maximum_duration = CORBA::string_dup(cpp_batch_params.maximum_duration.c_str());
  job_parameters->resource_required.name = CORBA::string_dup(job->getResource().c_str());
  job_parameters->resource_required.nb_proc = cpp_batch_params.nb_proc;
  job_parameters->resource_required.nb_node = cpp_batch_params.nb_node;
  job_parameters->queue = CORBA::string_dup(job->getBatchQueue().c_str());
  job_parameters->partition = CORBA::string_dup(job->getBatchPartition().c_str());
  job_parameters->exclusive = cpp_batch_params.exclusive;
  job_parameters->wckey = CORBA::string_dup(job->getWCKey().c_str());
  job_parameters->extra_params = CORBA::string_dup(job->getExtraParams().c_str());

  // Memory
  switch (cpp_batch_params.mem_req_type)
  {
  case BL::Job::MEM_PER_NODE:
    job_parameters->resource_required.mem_mb = cpp_batch_params.mem_limit;
    job_parameters->mem_per_cpu = 0;
    break;
  case BL::Job::MEM_PER_CPU:
    job_parameters->resource_required.mem_mb = 0;
    job_parameters->mem_per_cpu = cpp_batch_params.mem_limit;
    break;
  default:
    throw Exception("Unknown memory requirement, unable to create job");
  }

  // Unused parameters
  job_parameters->resource_required.nb_proc_per_node = -1;
  job_parameters->resource_required.cpu_clock = -1;

  // Parameters for COORM
  job_parameters->launcher_file = CORBA::string_dup(cpp_batch_params.launcher_file.c_str());
  job_parameters->launcher_args = CORBA::string_dup(cpp_batch_params.launcher_args.c_str());

  // Create Job
  try
  {
    int job_id = _salome_launcher->createJob(job_parameters);
    job->setSalomeLauncherId(job_id);
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in createJob !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::start_job(BL::Job * job)
{
  std::string ret = "";
  // Launch Job !
  try
  {
    _salome_launcher->launchJob(job->getSalomeLauncherId());
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in launchJob !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::refresh_job(BL::Job * job)
{
  std::string ret = "";

  // Refresh Job !
  try
  {
    CORBA::String_var result = _salome_launcher->getJobState(job->getSalomeLauncherId());
    ret = result.in();
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in getJobState !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::delete_job(BL::Job * job)
{
  std::string ret = "";
  // Delete Job !
  try
  {
    _salome_launcher->removeJob(job->getSalomeLauncherId());
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in removeJob !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::stop_job(BL::Job * job)
{
  std::string ret = "";
  try
  {
    _salome_launcher->stopJob(job->getSalomeLauncherId());
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in stopJob !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::get_results_job(BL::Job * job)
{
  std::string ret = "";

  BL::Job::FilesParam files = job->getFilesParameters();
  CORBA::String_var directory = CORBA::string_dup(files.result_directory.c_str());

  // get job results !
  try
  {
    _salome_launcher->getJobResults(job->getSalomeLauncherId(), directory);
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in refresh_job !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

// Get names or ids of hosts assigned to the job
std::string
BL::SALOMEServices::get_assigned_hostnames(BL::Job * job)
{
  std::string ret = "";

  try
  {
    CORBA::String_var result = _salome_launcher->getAssignedHostnames(job->getSalomeLauncherId());
    ret = result.in();
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in get_assigned_hostnames !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive SALOME System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "SALOME System Exception - see logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::save_jobs(const std::string & file_name)
{
  CORBA::String_var file = CORBA::string_dup(file_name.c_str());
  std::string ret = "";
  try
  {
    _salome_launcher->saveJobs(file);
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in saveJobs !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive CORBA System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "CORBA System Exception - see SALOME logs";
  }
  return ret;
}

std::string
BL::SALOMEServices::load_jobs(const std::string & file_name)
{
  CORBA::String_var file = CORBA::string_dup(file_name.c_str());
  std::string ret = "";
  try
  {
    _salome_launcher->loadJobs(file);
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in loadJobs !");
    ret = ex.details.text.in();
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive CORBA System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
    ret = "CORBA System Exception - see SALOME logs";
  }
  return ret;
}

void
BL::SALOMEServices::notify(const char* event_name, const char * event_data)
{
  DEBMSG("Launcher event received " << event_name << " " << event_data);

  std::string event(event_name);
  std::string data(event_data);

  if (event == "SAVE_JOBS")
  {
    _manager->launcher_event_save_jobs(data);
  }
  else if (event == "LOAD_JOBS")
  {
    _manager->launcher_event_load_jobs(data);
  }
  else if (event == "NEW_JOB")
  {
    _manager->launcher_event_new_job(data);
  }
  else if (event == "REMOVE_JOB")
  {
    _manager->launcher_event_remove_job(data);
  }
  else if (event == "UPDATE_JOB_STATE")
  {
    _manager->launcher_event_update_job_state(data);
  }
  else
  {
    DEBMSG("Unkown launcher event received");
  }
}

BL::Job * 
BL::SALOMEServices::get_new_job(int job_number)
{
  DEBMSG("Start of BL::SALOMEServices::get_new_job");
  BL::Job * job_return = NULL;
  Engines::JobParameters * job_parameters = NULL;
  try
  {
    job_parameters = _salome_launcher->getJobParameters(job_number);
  }
  catch (const SALOME_CMOD::SALOME_Exception & ex)
  {
    DEBMSG("SALOME Exception in saveJobs !");
  }
  catch (const CORBA::SystemException& ex)
  {
    DEBMSG("Receive CORBA System Exception: " << ex);
    DEBMSG("Check SALOME servers...");
  }

  if (job_parameters)
  {
    job_return = new BL::Job();
    job_return->setSalomeLauncherId(job_number);

    job_return->setName(job_parameters->job_name.in());
    job_return->setType(job_parameters->job_type.in());
    job_return->setJobFile(job_parameters->job_file.in());
    job_return->setEnvFile(job_parameters->env_file.in());
    job_return->setPreCommand(job_parameters->pre_command.in());
    job_return->setBatchQueue(job_parameters->queue.in());
    job_return->setBatchPartition(job_parameters->partition.in());
    job_return->setWCKey(job_parameters->wckey.in());
    job_return->setExtraParams(job_parameters->extra_params.in());

    BL::Job::FilesParam param;
    param.result_directory = job_parameters->result_directory.in();
    for (CORBA::ULong i = 0; i < job_parameters->in_files.length(); i++)
      param.input_files_list.push_back(job_parameters->in_files[i].in());
    for (CORBA::ULong i = 0; i < job_parameters->out_files.length(); i++)
      param.output_files_list.push_back(job_parameters->out_files[i].in());
    job_return->setFilesParameters(param);

    BL::Job::BatchParam batch_param;
    batch_param.batch_directory = job_parameters->work_directory.in();
    batch_param.maximum_duration = job_parameters->maximum_duration.in();
    batch_param.nb_proc = job_parameters->resource_required.nb_proc;
    batch_param.nb_node = job_parameters->resource_required.nb_node;
    batch_param.exclusive = job_parameters->exclusive;

    if (job_parameters->mem_per_cpu != 0)
    {
      batch_param.mem_limit = job_parameters->mem_per_cpu;
      batch_param.mem_req_type = BL::Job::MEM_PER_CPU;
    }
    else
    {
      batch_param.mem_limit = job_parameters->resource_required.mem_mb;
      batch_param.mem_req_type = BL::Job::MEM_PER_NODE;
    }

    // Parameters for COORM
    batch_param.launcher_file = job_parameters->launcher_file.in();
    batch_param.launcher_args = job_parameters->launcher_args.in();

    job_return->setBatchParameters(batch_param);

    job_return->setResource(job_parameters->resource_required.name.in());

    // Specific parameters
    for (CORBA::ULong i = 0; i < job_parameters->specific_parameters.length(); i++)
    {
      if (std::string(job_parameters->specific_parameters[i].name.in()) == "EnableDumpYACS")
      {
        std::string user_value = job_parameters->specific_parameters[i].value.in();
        std::istringstream iss(user_value);
        int value;
        iss >> value;
        job_return->setDumpYACSState(value);
      }
      if (std::string(job_parameters->specific_parameters[i].name.in()) == "YACSDriverOptions")
      {
        std::string user_value = job_parameters->specific_parameters[i].value.in();
        job_return->setYacsDriverOptions(user_value);
      }
      if (std::string(job_parameters->specific_parameters[i].name.in()) == "LoalLevelerJobType")
      {
        std::string user_value = job_parameters->specific_parameters[i].value.in();
        job_return->setLoadLevelerJobType(user_value);
      }
    }

    // Get current state
    std::string result_job = job_return->setStringState(refresh_job(job_return));
    if (result_job != "RefreshError") {}
    else
    {
      // Error in getting state
      DEBMSG("Error in getting state of the new job!");
      delete job_return;
      job_return = NULL;
    }
    delete job_parameters;
  }

  return job_return;
}
