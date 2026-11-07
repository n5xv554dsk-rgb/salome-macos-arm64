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

#ifndef _BL_JOBSMANAGER_HXX_
#define _BL_JOBSMANAGER_HXX_

#include "BL_Engine.hxx"
#include "BL_Job.hxx"
#include "BL_SALOMEServices.hxx"
#include "BL_Traces.hxx"
#include "BL_Observer.hxx"

#include <map>
#include <string>

#include <omnithread.h>

namespace BL{

  class SALOMEServices;

  class BL_Engine_EXPORT JobsManager
  {
    public:
      JobsManager(BL::SALOMEServices * salome_services);
      virtual ~JobsManager();

      // Add QT observer
      void setObserver(BL::Observer * observer);

      // useful methods
      BL::Job * createJob(const std::string & name);
      BL::Job * getJob(const std::string & name);
      std::map<std::string, BL::Job *> & getJobs();
      bool job_already_exist(const std::string & name);

      // remote methods
      void addJobToLauncher(const std::string & name);
      void removeJob(const std::string & name);

      virtual void start_job(const std::string & name);
      static void starting_job_thread(void * object_ptr);

      virtual void stop_job(const std::string & name);
      static void stop_job_thread(void * object_ptr);

      virtual void get_results_job(const std::string & name);
      static void get_results_job_thread(void * object_ptr);

      virtual void refresh_jobs();
      static void refresh_jobs_thread(void * object_ptr);

      virtual void load_jobs(const std::string & xml_file);
      virtual void save_jobs(const std::string & xml_file);
      static void load_jobs_thread(void * object_ptr);
      static void save_jobs_thread(void * object_ptr);

      // event from launcher
      void launcher_event_save_jobs(const std::string & data);
      void launcher_event_load_jobs(const std::string & data);
      void launcher_event_new_job(const std::string & data);
      static void launcher_event_new_job_thread(void * object_ptr);
      void launcher_event_remove_job(const std::string & data);
      static void launcher_event_remove_job_thread(void * object_ptr);
      void launcher_event_update_job_state(const std::string & data);

      bool emptyJobsList() {return _jobs.empty();}

      struct thread_info
      {
        BL::JobsManager * object_ptr;
        std::string job_name;
      };

      struct thread_info_file
      {
        BL::JobsManager * object_ptr;
        std::string file_name;
      };

      struct thread_info_new_job
      {
        BL::JobsManager * object_ptr;
        int job_number;
      };

    protected:
      BL::SALOMEServices * _salome_services;
      BL::Observer * _observer;

    private:
      typedef std::map<std::string, BL::Job *> _jobs_map;
      _jobs_map _jobs;
      _jobs_map::iterator _jobs_it;

      // Mutex used for the jobs map
      omni_mutex _thread_mutex_jobs_map;

      // To avoid two jobs with the same name
      int _name_counter;
  };

}

#endif

