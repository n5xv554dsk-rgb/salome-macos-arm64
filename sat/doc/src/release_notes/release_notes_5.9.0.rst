*****************
SAT version 5.9.0
*****************

Release Notes, July 2024
============================


New features and improvements
-----------------------------


**New key git_info.git_server**

Each project, e.g. salome.pyconf, implements a new section named git_info with various git servers. This new section is introduced in order to cope with different mirrors, like closed and opensource git repositories.
This git_options key should be added in the git_info section of each new project: ::

    git_info : 
    {
      git_server :
      {
        tuleap : {url : "https://codev-tuleap.cea.fr/plugins/git/", opensource_only: 'no' }
        github : {url : "https://github.com/SalomePlatform/",       opensource_only: 'yes'}
        gitpub : {url : "https://git.salome-platform.org/gitpub/",  opensource_only: 'yes'}
      }
    }


**New property APPLICATION.git_server**

Each application implemented in a given project, defines a new key named git_server, aimed to define the default git server in use. ::

    APPLICATION :
    {
      properties :
      {
        git_server : 'tuleap'
      }
    }


**New property APPLICATION.cmake_build_type**

A new key named cmake_build_type is implemented for cmake based builds only. This variable can be set to Debug, RelWithDebInfo, Release or MinSizeRel.

The introduction of this key was motivated by the need to be able to compile SALOME in Release with debug information.

The syntax reads: ::

    APPLICATION :
    {
      cmake_generator : 'Visual Studio 15 2017'
      cmake_build_type: 'Release' # Debug, RelWithDebInfo, Release, MinSizeRel
    }  


This feature can also be used at product level.

