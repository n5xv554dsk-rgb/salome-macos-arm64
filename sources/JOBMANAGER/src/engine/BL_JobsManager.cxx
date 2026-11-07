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

#include "BL_JobsManager.hxx"
#include <sstream>

#ifdef WNT
#undef ERROR
#endif

BL::JobsManager::JobsManager(BL::SALOMEServices * salome_services)
{
  DEBTRACE("Creating BL::JobsManager");
  BL_ASSERT(salome_services);
  _salome_services = salome_services;
  _salome_services->set_manager(this);
  _observer = NULL;
  _name_counter = 0;
}

BL::JobsManager::~JobsManager()
{
  DEBTRACE("Destroying BL::JobsManager");

  // Delete All Jobs !
  _jobs_it = _jobs.begin();
  for(;_jobs_it != _jobs.end();_jobs_it++)
    delete _jobs_it->second;
}

void 
BL::JobsManager::setObserver(BL::Observer * observer)
{
  BL_ASSERT(observer);
  _observer = observer;
}

BL::Job *
BL::JobsManager::createJob(const std::string & name)
{
  DEBTRACE("createJob BL::JobsManager");

  BL::Job * new_job = NULL;

  _thread_mutex_jobs_map.lock();
  _jobs_it = _jobs.find(name);
  if (_jobs_it == _jobs.end())
  {
    new_job = new BL::Job(name);

    // Ajout dans la liste
    _jobs[name] = new_job;
  }
  else
    DEBTRACE("createJob Error !!!! Job already exist: " << name);

  _thread_mutex_jobs_map.unlock();
  return new_job;
}

void
BL::JobsManager::addJobToLauncher(const std::string & name)
{
  DEBTRACE("addJobToLauncher BL::JobsManager");

  _thread_mutex_jobs_map.lock();
  _jobs_it = _jobs.find(name);
  if (_jobs_it == _jobs.end())
  {
    // TODO: SHOULD SEND an exeception...
    DEBMSG("[addJobToLauncher] failed, job was not found");
  }
  std::string result = "";
  result = _salome_services->create_job(_jobs_it->second);

  // Unlock is here to be sure that
  // method setSalomeLauncherId is called if
  // the creation is successfull
  _thread_mutex_jobs_map.unlock();

  if (_observer)
    if (result != "")
    {
      _jobs_it->second->setState(BL::Job::NOT_CREATED);
      _observer->sendEvent("create_job", "Error", name, result);
    }
    else
      _observer->sendEvent("create_job", "Ok", name, "");
}

void
BL::JobsManager::removeJob(const std::string & name)
{
  DEBTRACE("removeJob BL::JobsManager");
  _thread_mutex_jobs_map.lock();
  _jobs_it = _jobs.find(name);
  if (_jobs_it != _jobs.end())
  {
    std::string result = "";
    if (_jobs_it->second->getSalomeLauncherId() != -1)
      result = _salome_services->delete_job(_jobs_it->second);

    delete _jobs_it->second;
    _jobs.erase(_jobs_it->first);

    if (_observer)
      if (result != "")
        _observer->sendEvent("delete_job", "Error", name, result);
      else
        _observer->sendEvent("delete_job", "Ok", name, "");
  }
  else
    DEBTRACE("removeJob Error !!!! Job does not exist: " << name);
  _thread_mutex_jobs_map.unlock();
}

BL::Job *
BL::JobsManager::getJob(const std::string & name)
{
  DEBTRACE("getJob BL::JobsManager called");
  return _jobs[name];
}

std::map<std::string, BL::Job *> & 
BL::JobsManager::getJobs()
{
  return _jobs;
}

bool 
BL::JobsManager::job_already_exist(const std::string & name)
{
  bool result = true;

  _thread_mutex_jobs_map.lock();
  _jobs_it = _jobs.find(name);
  if (_jobs_it == _jobs.end())
    result = false;
  _thread_mutex_jobs_map.unlock();

  return result;
}

void
BL::JobsManager::start_job(const std::string & name)
{
  DEBTRACE("BL::JobsManager::start_job called for job: " << name);
  // Prepare Info for thread
  BL::JobsManager::thread_info * ti = new thread_info();
  ti->object_ptr = this;
  ti->job_name = name;
  omni_thread::create(BL::JobsManager::starting_job_thread, ti);

}

void 
BL::JobsManager::starting_job_thread(void * object_ptr)
{
  DEBTRACE("starting_job_thread BL::JobsManager called");
  BL::JobsManager::thread_info * ti = reinterpret_cast<BL::JobsManager::thread_info*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  std::string job_name =  ti->job_name;

  // Check job exits
  object->_thread_mutex_jobs_map.lock();
  object->_jobs_it = object->_jobs.find(job_name);
  if (object->_jobs_it == object->_jobs.end())
  {
    DEBTRACE("BL::JobsManager::start_job job unknown: " << job_name);
  }
  else
  {
    BL::Job * job = object->getJob(job_name);
    std::string result = object->_salome_services->start_job(job);
    if (result == "")
    {
      job->setState(BL::Job::QUEUED);
      job->setThreadState(BL::Job::NOTHING);
      if (object->_observer)
        object->_observer->sendEvent("start_job", "Ok", job_name, "");
    }
    else
    {
      job->setState(BL::Job::ERROR);
      job->setThreadState(BL::Job::NOTHING);
      if (object->_observer)
        object->_observer->sendEvent("start_job", "Error", job_name, result);
    }
  }
  object->_thread_mutex_jobs_map.unlock();
}

void
BL::JobsManager::stop_job(const std::string & name)
{
  DEBTRACE("stop_job BL::JobsManager called");

  _thread_mutex_jobs_map.lock();
  // Check job exits
  _jobs_it = _jobs.find(name);
  if (_jobs_it == _jobs.end())
  {
    DEBTRACE("BL::JobsManager::stop_job job unknown: " << name);
    _thread_mutex_jobs_map.unlock();
    return;
  }
  else
  {
    // Prepare Info for thread
    BL::JobsManager::thread_info * ti = new thread_info();
    ti->object_ptr = this;
    ti->job_name = name;
    omni_thread::create(BL::JobsManager::stop_job_thread, ti);
  }
}

void 
BL::JobsManager::stop_job_thread(void * object_ptr)
{
  DEBTRACE("stop_job_thread BL::JobsManager called");
  BL::JobsManager::thread_info * ti = reinterpret_cast<BL::JobsManager::thread_info*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  std::string job_name =  ti->job_name;
  BL::Job * job = object->getJob(job_name);

  std::string result = object->_salome_services->stop_job(job);

  // End
  if (result == "")
  {
    if (object->_observer)
      object->_observer->sendEvent("stop_job", "Ok", job_name, "");
  }
  else
  {
    if (object->_observer)
      object->_observer->sendEvent("stop_job", "Error", job_name, result);
  }
  object->_thread_mutex_jobs_map.unlock();
}

void
BL::JobsManager::refresh_jobs()
{
  DEBTRACE("refresh_jobs BL::JobsManager called");

  omni_thread::create(BL::JobsManager::refresh_jobs_thread, this);
}

void
BL::JobsManager::refresh_jobs_thread(void * object_ptr)
{
  DEBTRACE("refresh_job BL::JobsManager called");
  BL::JobsManager * object = reinterpret_cast<BL::JobsManager*>(object_ptr);

  //iterate on all jobs
  object->_thread_mutex_jobs_map.lock();
  _jobs_map::iterator jobs_it;
  jobs_it = object->_jobs.begin();
  for(;jobs_it != object->_jobs.end();jobs_it++)
  {
    BL::Job * job = jobs_it->second;
    if (job->getSalomeLauncherId() != -1)
    {
      if (job->getThreadState() == BL::Job::NOTHING)
      {
        BL::Job::State job_state = job->getState();
        if (job_state != BL::Job::FINISHED &&
            job_state != BL::Job::ERROR    &&
            job_state != BL::Job::FAILED   &&
            job_state != BL::Job::NOT_CREATED)
        {
          std::string result_launcher = object->_salome_services->refresh_job(job);
          std::string result_job = job->setStringState(result_launcher);
          if (result_job == "RefreshError")
          {
            // Error using launcher...
            if (object->_observer)
              object->_observer->sendEvent("refresh_job", "Error", job->getName(), result_launcher);
          }
          else if (result_job != "")
          {
            if (object->_observer)
			{
              object->_observer->sendEvent("refresh_job", "Ok", job->getName(), result_job);

			  // get assigned hostnames when the job will start
			  if (result_job == "RUNNING")
			  {
				std::string assigned_hostnames = object->_salome_services->get_assigned_hostnames(job);
				if (assigned_hostnames != "")
				{
					// sent event "get_assigned_hostnames"
					object->_observer->sendEvent("get_assigned_hostnames", "Ok", job->getName(), assigned_hostnames);
				}
			  }
			}
          }
        }
      }
    }
  }
  object->_thread_mutex_jobs_map.unlock();
}

void
BL::JobsManager::get_results_job(const std::string & name)
{
  DEBTRACE("get_results_job BL::JobsManager called");

  _thread_mutex_jobs_map.lock();
  // Check job exits
  _jobs_it = _jobs.find(name);
  if (_jobs_it == _jobs.end())
  {
    DEBTRACE("BL::JobsManager::get_results_job job unknown: " << name);
    _thread_mutex_jobs_map.unlock();
    return;
  }
  else
  {
    BL::Job * job = _jobs_it->second; 
    if (job->getState() == BL::Job::FINISHED ||
        job->getState() == BL::Job::ERROR    ||
        job->getState() == BL::Job::FAILED
        )
    {
      // Prepare Info for thread
      BL::JobsManager::thread_info * ti = new thread_info();
      ti->object_ptr = this;
      ti->job_name = name;
      omni_thread::create(BL::JobsManager::get_results_job_thread, ti);
    }
    else
    {
      DEBTRACE("BL::JobsManager::get_results_job job bad job state !");
      _thread_mutex_jobs_map.unlock();
      return;
    }
  }
}

void 
BL::JobsManager::get_results_job_thread(void * object_ptr)
{
  DEBTRACE("get_results_job_thread BL::JobsManager called");
  BL::JobsManager::thread_info * ti = reinterpret_cast<BL::JobsManager::thread_info*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  std::string job_name =  ti->job_name;
  BL::Job * job = object->getJob(job_name);

  std::string result = object->_salome_services->get_results_job(job);

  // End
  if (result == "")
  {
    if (object->_observer)
      object->_observer->sendEvent("get_results_job", "Ok", job_name, "");
  }
  else
  {
    if (object->_observer)
      object->_observer->sendEvent("get_results_job", "Error", job_name, result);
  }
  object->_thread_mutex_jobs_map.unlock();
}

void
BL::JobsManager::save_jobs(const std::string & xml_file)
{
  DEBTRACE("BL::JobsManager::save_jobs called for : " << xml_file);

  // Prepare Info for thread
  BL::JobsManager::thread_info_file * ti = new thread_info_file();
  ti->object_ptr = this;
  ti->file_name = xml_file;
  omni_thread::create(BL::JobsManager::save_jobs_thread, ti);
}

void
BL::JobsManager::load_jobs(const std::string & xml_file)
{
  DEBTRACE("BL::JobsManager::load_jobs called for : " << xml_file);

  // Prepare Info for thread
  BL::JobsManager::thread_info_file * ti = new thread_info_file();
  ti->object_ptr = this;
  ti->file_name = xml_file;
  omni_thread::create(BL::JobsManager::load_jobs_thread, ti);
}

void
BL::JobsManager::save_jobs_thread(void * object_ptr)
{
  DEBTRACE("save_jobs_thread BL::JobsManager called");
  BL::JobsManager::thread_info_file * ti = reinterpret_cast<BL::JobsManager::thread_info_file*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  std::string file_name =  ti->file_name;

  object->_thread_mutex_jobs_map.lock();
  std::string result = object->_salome_services->save_jobs(file_name);
  object->_thread_mutex_jobs_map.unlock();

  if (result != "")
    if (object->_observer)
      object->_observer->sendEvent("save_jobs", "Error", "", result);
}

void
BL::JobsManager::load_jobs_thread(void * object_ptr)
{
  DEBTRACE("load_jobs_thread BL::JobsManager called");
  BL::JobsManager::thread_info_file * ti = reinterpret_cast<BL::JobsManager::thread_info_file*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  std::string file_name =  ti->file_name;

  object->_thread_mutex_jobs_map.lock();
  std::string result = object->_salome_services->load_jobs(file_name);
  object->_thread_mutex_jobs_map.unlock();

  if (result != "")
    if (object->_observer)
      object->_observer->sendEvent("load_jobs", "Error", "", result);
}

void
BL::JobsManager::launcher_event_save_jobs(const std::string & data)
{
  if (_observer)
    _observer->sendEvent("save_jobs", "Ok", "", data);
}

void
BL::JobsManager::launcher_event_load_jobs(const std::string & data)
{
  if (_observer)
    _observer->sendEvent("load_jobs", "Ok", "", data);
}

void
BL::JobsManager::launcher_event_new_job(const std::string & data)
{
  int job_number;
  std::istringstream job_number_stream(data);
  if (job_number_stream >> job_number)
  {
	DEBTRACE("Receive NEWJOB:" << job_number);
    BL::JobsManager::thread_info_new_job * ti = new thread_info_new_job();
    ti->object_ptr = this;
    ti->job_number = job_number;
    omni_thread::create(BL::JobsManager::launcher_event_new_job_thread, ti);
  }
}

void
BL::JobsManager::launcher_event_update_job_state(const std::string & data)
{
  refresh_jobs();
}

void
BL::JobsManager::launcher_event_new_job_thread(void * object_ptr)
{
  DEBTRACE("Start of BL::JobsManager::launcher_event_new_job_thread");
  BL::JobsManager::thread_info_new_job * ti = reinterpret_cast<BL::JobsManager::thread_info_new_job*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  int job_number =  ti->job_number;

  object->_thread_mutex_jobs_map.lock();

  // 1: Check if job is not already on our map
  bool job_in_map = false;
  _jobs_map::iterator jobs_it;
  jobs_it = object->_jobs.begin();
  for(;jobs_it != object->_jobs.end();jobs_it++)
  {
    BL::Job * job = jobs_it->second;
    if (job->getSalomeLauncherId() == job_number)
      job_in_map = true;
  }

  if (!job_in_map)
  {
    // 2: We try to get job informations

    BL::Job * new_job = object->_salome_services->get_new_job(job_number);

    // 3: We add it
    if (new_job)
    {
      // 4: Check if job has a name or if the name already exists
      if (new_job->getName() == "")
      {
        std::ostringstream name_stream;
        name_stream << "no_name_" << object->_name_counter;
        object->_name_counter++;
        new_job->setName(name_stream.str());
      }

      _jobs_map::iterator _jobs_it_name = object->_jobs.find(new_job->getName());
      if (_jobs_it_name != object->_jobs.end())
      {
        std::ostringstream name_stream;
        name_stream << new_job->getName() << "_" << object->_name_counter;
        object->_name_counter++;
        new_job->setName(name_stream.str());
      }
      // 5: Insert job
      object->_jobs[new_job->getName()] = new_job;
      if (object->_observer)
        object->_observer->sendEvent("add_job", "Ok", new_job->getName(), "");
    }
  }

  object->_thread_mutex_jobs_map.unlock();
}

void
BL::JobsManager::launcher_event_remove_job(const std::string & data)
{
  int job_number;
  std::istringstream job_number_stream(data);
  if (job_number_stream >> job_number)
  {
    BL::JobsManager::thread_info_new_job * ti = new thread_info_new_job();
    ti->object_ptr = this;
    ti->job_number = job_number;
    omni_thread::create(BL::JobsManager::launcher_event_remove_job_thread, ti);
  }
}

void
BL::JobsManager::launcher_event_remove_job_thread(void * object_ptr)
{
  DEBTRACE("Start of BL::JobsManager::launcher_event_remove_job_thread");
  BL::JobsManager::thread_info_new_job * ti = reinterpret_cast<BL::JobsManager::thread_info_new_job*>(object_ptr);
  BL::JobsManager * object = ti->object_ptr;
  int job_number =  ti->job_number;

  object->_thread_mutex_jobs_map.lock();

  _jobs_map::iterator jobs_it;
  jobs_it = object->_jobs.begin();
  for(;jobs_it != object->_jobs.end();jobs_it++)
  {
    BL::Job * job = jobs_it->second;
    if (job->getSalomeLauncherId() == job_number)
    {
      job->setSalomeLauncherId(-1);
      if (object->_observer)
        object->_observer->sendEvent("to_remove_job", "Ok", job->getName(), "");
    }
  }

  object->_thread_mutex_jobs_map.unlock();
}
